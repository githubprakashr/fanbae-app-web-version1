import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fanbae/model/getratingmodel.dart';
import 'package:fanbae/utils/color.dart';

import '../utils/utils.dart';
import '../webservice/apiservice.dart';
import '../widget/mynetworkimg.dart';
import '../widget/mytext.dart';
import '../widget/nodata.dart';

class ViewRatings extends StatefulWidget {
  final int id;
  const ViewRatings({super.key, required this.id});

  @override
  State<ViewRatings> createState() => _ViewRatingsState();
}

class _ViewRatingsState extends State<ViewRatings> {
  late GetRatingsModel ratingsModel;
  bool isLoad = false;

  @override
  void initState() {
    getRatings(context);
    super.initState();
  }

  Future<void> getRatings(BuildContext context) async {
    setState(() {
      isLoad = true;
    });
    ratingsModel = await ApiService().getRatings(widget.id);
    if (ratingsModel.status != 200) {
      Navigator.pop(context);
      Utils().showSnackBar(context, ratingsModel.message, false);
    }
    setState(() {
      isLoad = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appbgcolor,
      appBar: AppBar(
        backgroundColor: appbgcolor,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back,
            color: white,
          ),
        ),
        title: MyText(text: "rating", color: white),
      ),
      body: isLoad
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ratingsModel.result.isEmpty
              ? const NoData()
              : Utils().pageBg(
                  context,
                  child: ListView.builder(
                      itemCount: ratingsModel.result.length,
                      itemBuilder: (BuildContext context, int index) {
                        var rating = ratingsModel.result[index];
                        return Container(
                          decoration: BoxDecoration(
                              color: buttonDisable,
                              borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 12),
                          margin: EdgeInsets.symmetric(
                              horizontal: 15, vertical: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    clipBehavior: Clip.antiAlias,
                                    width: MediaQuery.of(context).size.width *
                                        0.095,
                                    height: MediaQuery.of(context).size.width *
                                        0.095,
                                    decoration: const BoxDecoration(
                                        shape: BoxShape.circle),
                                    child: MyNetworkImage(
                                      width: MediaQuery.of(context).size.width,
                                      height:
                                          MediaQuery.of(context).size.height,
                                      fit: BoxFit.cover,
                                      imagePath: rating.userImage,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 15,
                                  ),
                                  Text(
                                    rating.userName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                            color: white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 11.0),
                                child: RatingBarIndicator(
                                  rating:
                                      double.parse(rating.rating.toString()),
                                  itemBuilder: (context, index) => const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                  ),
                                  unratedColor: white.withOpacity(0.4),
                                  itemCount: 10,
                                  itemSize: 17,
                                  direction: Axis.horizontal,
                                ),
                              ),
                              Text(
                                rating.message,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: white),
                              ),
                            ],
                          ),
                        );
                      }),
                ),
    );
  }
}
