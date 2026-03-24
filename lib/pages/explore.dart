import 'package:flutter/material.dart';
import '../model/ExploreChannelsModel.dart' as exploring;
import 'package:fanbae/pages/profile.dart';
import 'package:fanbae/webservice/apiservice.dart';
import '../model/ExploreChannelsModel.dart';

import '../utils/color.dart';
import '../utils/customwidget.dart';
import '../utils/dimens.dart';
import '../utils/responsive_helper.dart';
import '../utils/utils.dart';
import '../widget/mynetworkimg.dart';
import '../widget/mytext.dart';
import '../widget/nodata.dart';

class ExploreChannels extends StatefulWidget {
  const ExploreChannels({super.key});

  @override
  State<ExploreChannels> createState() => _ExploreChannelsState();
}

class _ExploreChannelsState extends State<ExploreChannels> {
  ExploreChannelsModel exploreChannelsModel = ExploreChannelsModel();
  List<exploring.Result> exploringList = [];
  List<exploring.Result> filteredList = [];
  bool exploreChannelsModelLoading = false;
  int position = 1;

  @override
  void initState() {
    subscribingChannels();
    super.initState();
  }

  Future<void> subscribingChannels() async {
    setState(() {
      exploreChannelsModelLoading = true;
    });

    exploreChannelsModel = await ApiService().getExploringChannels();

    setState(() {
      if (exploreChannelsModel.status == 200) {
        exploringList = exploreChannelsModel.result!;
        filteredList = List.from(exploringList);
      } else {
        exploringList = [];
        filteredList = List.from(exploringList);
      }
      exploreChannelsModelLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: appbgcolor,
        appBar: ResponsiveHelper.checkIsWeb(context)
            ? Utils.webAppbarWithSidePanel(context: context)
            : Utils().otherPageAppBar(context, "Explore", false),
        body: RefreshIndicator(
          onRefresh: () => subscribingChannels(),
          child: ResponsiveHelper.checkIsWeb(context)
              ? Utils.sidePanelWithBody(
                  myWidget: buildBody(),
                )
              : Utils().pageBg(
                  context,
                  child: buildBody(),
                ),
        ));
  }

  Widget buildBody() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: Container(
              height: 35,
              decoration: BoxDecoration(
                // gradient:  Constant.gradientColor,
                border: Border.all(
                  color: textColor,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextFormField(
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: white, fontWeight: FontWeight.w700),
                decoration: InputDecoration(
                  hintText: "Search",
                  hintStyle: TextStyle(color: white),
                  contentPadding: const EdgeInsets.only(top: 15, left: 10),
                  enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent)),
                  focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent)),
                ),
                onChanged: (value) {
                  setState(() {
                    final query = value.toLowerCase();
                    filteredList = exploringList.where((e) {
                      final name = e.fullName?.toLowerCase() ?? '';
                      final channel = e.channelName?.toLowerCase() ?? '';
                      return name.contains(query) || channel.contains(query);
                    }).toList();
                  });
                },
              ),
            ),
          ),
          buildExploring(),
        ],
      ),
    );
  }

  Widget buildExploring() {
    if (exploreChannelsModelLoading) {
      return shimmer();
    } else {
      print(exploringList.length);
      if ((exploringList.isNotEmpty)) {
        return Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.8,
              child: exploringListItem(),
            ),
          ],
        );
      } else {
        return const NoData();
      }
    }
  }

  Widget exploringListItem() {
    if (filteredList.isEmpty) {
      return const Center(child: NoData());
    }
    return ListView.separated(
      separatorBuilder: (context, index) => const SizedBox(height: 15),
      itemCount: filteredList.length,
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
      scrollDirection: Axis.vertical,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final item = filteredList[index];
        return InkWell(
          onTap: () async {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return Profile(
                    isProfile: false,
                    channelUserid: item.id.toString(),
                    channelid: item.channelId.toString(),
                  );
                },
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: buttonDisable,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  margin: const EdgeInsets.fromLTRB(1, 0, 13, 0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(width: 1, color: colorPrimary),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: MyNetworkImage(
                      width: 42,
                      height: 42,
                      imagePath: item.image ?? "",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText(
                      color: white,
                      text: item.fullName ?? "",
                      fontwaight: FontWeight.w500,
                      fontsizeNormal: Dimens.textMedium,
                      maxline: 1,
                      multilanguage: false,
                      overflow: TextOverflow.ellipsis,
                      textalign: TextAlign.center,
                      fontstyle: FontStyle.normal,
                    ),
                    const SizedBox(height: 5),
                    MyText(
                      color: white,
                      text: item.channelName ?? "",
                      fontwaight: FontWeight.w500,
                      fontsizeNormal: Dimens.textMedium,
                      maxline: 2,
                      multilanguage: false,
                      overflow: TextOverflow.ellipsis,
                      textalign: TextAlign.center,
                      fontstyle: FontStyle.normal,
                    ),
                    const SizedBox(height: 5),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget shimmer() {
    return ListView.separated(
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemCount: 10,
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
      scrollDirection: Axis.vertical,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return const Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomWidget.circular(
              width: 45,
              height: 45,
            ),
            SizedBox(height: 10),
            CustomWidget.roundrectborder(
              width: 100,
              height: 10,
            ),
          ],
        );
      },
    );
  }
}
