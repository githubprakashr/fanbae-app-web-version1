import 'package:flutter/material.dart';
import 'package:fanbae/pages/profile.dart';
import 'package:fanbae/webservice/apiservice.dart';

import '../model/followers_model.dart';
import '../model/followers_model.dart' as followers;

import '../utils/color.dart';
import '../utils/customwidget.dart';
import '../utils/dimens.dart';
import '../utils/responsive_helper.dart';
import '../utils/utils.dart';
import '../widget/mynetworkimg.dart';
import '../widget/mytext.dart';

class Followers extends StatefulWidget {
  const Followers({super.key});

  @override
  State<Followers> createState() => _FollowersState();
}

class _FollowersState extends State<Followers> {
  FollowersModel followersModel = FollowersModel();
  List<followers.Result> followersList = [];
  bool followersModelLoading = false;
  bool isLoadingMore = false;
  int currentPage = 0;
  int totalPages = 1;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    followersChannels(currentPage);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !followersModelLoading &&
          !isLoadingMore &&
          currentPage < totalPages - 1) {
        loadMoreFollowers();
      }
    });
  }

  Future<void> followersChannels(int page) async {
    if (page == 0) {
      setState(() {
        followersModelLoading = true;
      });
    }

    try {
      final result = await ApiService().getFollowers(page);

      if (result.status == 200) {
        setState(() {
          if (page == 0) {
            followersList = result.result ?? [];
          } else {
            followersList.addAll(result.result ?? []);
          }

          currentPage = result.currentPage ?? page;
          totalPages = result.totalPage ?? 1;
        });
      } else {
        if (page == 0) {
          setState(() => followersList = []);
        }
      }
    } catch (e) {
      debugPrint('followersChannels error: $e');
      if (page == 0) {
        setState(() => followersList = []);
      }
    } finally {
      setState(() {
        followersModelLoading = false;
        isLoadingMore = false;
      });
    }
  }

  Future<void> loadMoreFollowers() async {
    setState(() {
      isLoadingMore = true;
    });

    int nextPage = currentPage + 1;
    final nextPageData = await ApiService().getFollowers(nextPage);

    setState(() {
      if (nextPageData.status == 200 && nextPageData.result != null) {
        followersList.addAll(nextPageData.result!);
        currentPage = nextPageData.currentPage ?? nextPage;
        totalPages = nextPageData.totalPage ?? totalPages;
      }
      isLoadingMore = false;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appbgcolor,
      appBar: ResponsiveHelper.checkIsWeb(context)
          ? Utils.webAppbarWithSidePanel(context: context)
          : Utils().otherPageAppBar(context, "Followers", false),
      body: ResponsiveHelper.checkIsWeb(context)
          ? Utils.sidePanelWithBody(myWidget: buildBody())
          : Utils().pageBg(context, child: buildBody()),
    );
  }

  Widget buildBody() {
    if (followersModelLoading && followersList.isEmpty) {
      return shimmer();
    }

    return RefreshIndicator(
      backgroundColor: colorPrimaryDark,
      color: colorAccent,
      displacement: 70,
      edgeOffset: 1.0,
      triggerMode: RefreshIndicatorTriggerMode.anywhere,
      strokeWidth: 3,
      onRefresh: () => followersChannels(0),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: followersList.length + (isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == followersList.length) {
            return const Padding(
              padding: EdgeInsets.all(10),
              child: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            );
          }
          final item = followersList[index];
          return InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Profile(
                    isProfile: false,
                    channelUserid: item.id.toString(),
                    channelid: item.channelId.toString(),
                  ),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 15),
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: buttonDisable,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    margin: const EdgeInsets.only(right: 13),
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
      ),
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
            CustomWidget.circular(width: 45, height: 45),
            SizedBox(width: 10),
            CustomWidget.roundrectborder(width: 100, height: 10),
          ],
        );
      },
    );
  }
}
