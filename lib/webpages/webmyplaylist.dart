import 'package:fanbae/provider/playlistprovider.dart';
import 'package:fanbae/utils/color.dart';
import 'package:fanbae/utils/constant.dart';
import 'package:fanbae/utils/customads.dart';
import 'package:fanbae/utils/dimens.dart';
import 'package:fanbae/utils/utils.dart';
import 'package:fanbae/webpages/weballcontent.dart';
import 'package:fanbae/webpages/weblogin.dart';
import 'package:fanbae/webpages/webplaylistcontent.dart';
import 'package:fanbae/widget/musictitle.dart';
import 'package:fanbae/widget/myimage.dart';
import 'package:fanbae/widget/mynetworkimg.dart';
import 'package:fanbae/widget/mytext.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

class WebMyPlayList extends StatefulWidget {
  const WebMyPlayList({super.key});

  @override
  State<WebMyPlayList> createState() => WebMyPlayListState();
}

class WebMyPlayListState extends State<WebMyPlayList> {
  late PlaylistProvider playlistProvider;
  final playlistTitleController = TextEditingController();
  late ScrollController _scrollController;
  bool isPublic = false;
  bool isPrivate = false;

  @override
  void initState() {
    playlistProvider = Provider.of<PlaylistProvider>(context, listen: false);
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    super.initState();
    _fetchData(0);
  }

  _scrollListener() async {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange &&
        (playlistProvider.currentPage ?? 0) <
            (playlistProvider.totalPage ?? 0)) {
      printLog("load more====>");
      await playlistProvider.setLoadMore(true);
      _fetchData(playlistProvider.currentPage ?? 0);
    }
  }

  Future<void> _fetchData(int? nextPage) async {
    printLog("isMorePage  ======> ${playlistProvider.isMorePage}");
    printLog("totalPage   ======> ${playlistProvider.totalPage}");
    printLog("nextpage   ======> $nextPage");
    printLog("Call MyCourse");
    printLog("Pageno:== ${(nextPage ?? 0) + 1}");
    await playlistProvider.getcontentbyChannel(
        Constant.userID, Constant.channelID, "5", (nextPage ?? 0) + 1);
  }

  @override
  void dispose() {
    playlistProvider.clearProvider();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appbgcolor,
      appBar: Utils.webAppbarWithSidePanel(
          context: context, contentType: Constant.videoSearch),
      body: Utils.sidePanelWithBody(
        myWidget: SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.vertical,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(15, 15, 15, 100),
          child: Column(
            children: [
              buildPlaylist(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPlaylist() {
    return Consumer<PlaylistProvider>(
        builder: (context, playlistprovider, child) {
      if (playlistprovider.loading && !playlistprovider.loadMore) {
        return playListShimmer();
      } else {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MusicTitle(
                color: white,
                text: "myplaylist",
                textalign: TextAlign.left,
                fontsizeNormal: Dimens.textExtraBig,
                fontsizeWeb: Dimens.textExtraBig,
                multilanguage: true,
                maxline: 1,
                fontwaight: FontWeight.w700,
                overflow: TextOverflow.ellipsis,
                fontstyle: FontStyle.normal),
            const SizedBox(height: 30),
            CustomAds(adType: Constant.bannerAdType),
            const SizedBox(height: 30),
            playList(),
            if (playlistProvider.loadMore)
              Container(
                height: 50,
                margin: const EdgeInsets.fromLTRB(5, 5, 5, 10),
                child: Utils.pageLoader(context),
              )
            else
              const SizedBox.shrink(),
          ],
        );
      }
    });
  }

  Widget playList() {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: ResponsiveGridList(
        minItemWidth: 120,
        minItemsPerRow: Utils.customCrossAxisCount(
            context: context,
            height1600: 7,
            height1200: 6,
            height800: 4,
            height600: 2),
        maxItemsPerRow: Utils.customCrossAxisCount(
            context: context,
            height1600: 7,
            height1200: 6,
            height800: 4,
            height600: 2),
        horizontalGridSpacing: 30,
        verticalGridSpacing: 30,
        listViewBuilderOptions: ListViewBuilderOptions(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
        ),
        children: List.generate(
          ((playlistProvider.playListData?.length ?? 0) + 1),
          (index) {
            if (index == 0) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () async {
                      if (Constant.userID == null) {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation1, animation2) =>
                                const WebLogin(),
                            transitionDuration: Duration.zero,
                            reverseTransitionDuration: Duration.zero,
                          ),
                        );
                      } else {
                        playlistDilog(isEditPlaylist: false);
                      }
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 180,
                      alignment: Alignment.center,
                      color: colorPrimaryDark,
                      child: Icon(
                        Icons.add,
                        size: 30,
                        color: white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  MusicTitle(
                      color: white,
                      text: "newplaylist",
                      textalign: TextAlign.left,
                      fontsizeNormal: Dimens.textMedium,
                      fontsizeWeb: Dimens.textMedium,
                      multilanguage: true,
                      maxline: 1,
                      fontwaight: FontWeight.w500,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal),
                ],
              );
            } else {
              if (playlistProvider.getContentbyChannelModel.status == 200 &&
                  playlistProvider.playListData != null) {
                if ((playlistProvider.playListData?.length ?? 0) > 0) {
                  return InkWell(
                    hoverColor: appbgcolor,
                    focusColor: appbgcolor,
                    splashColor: appbgcolor,
                    highlightColor: appbgcolor,
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation1, animation2) =>
                              WebPlaylistContent(
                            playlistId: playlistProvider
                                    .playListData?[index - 1].id
                                    .toString() ??
                                "",
                            title: playlistProvider
                                    .playListData?[index - 1].title
                                    .toString() ??
                                "",
                          ),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width,
                              height: 180,
                              color: colorPrimary,
                              child: playlistImages(
                                index: index - 1,
                                playListImg: playlistProvider
                                        .playListData?[index - 1]
                                        .playlistImage ??
                                    [],
                              ),
                            ),
                            Consumer<PlaylistProvider>(builder:
                                (context, deleteplaylistprovider, child) {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  /* Add Button */
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          pageBuilder: (context, animation1,
                                                  animation2) =>
                                              WebAllContent(
                                            playlistId: playlistProvider
                                                    .playListData?[index - 1].id
                                                    .toString() ??
                                                "",
                                          ),
                                          transitionDuration: Duration.zero,
                                          reverseTransitionDuration:
                                              Duration.zero,
                                        ),
                                      );
                                    },
                                    child: Icon(
                                      Icons.add_box_rounded,
                                      size: 20,
                                      color: white,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  /* Edit Button */
                                  InkWell(
                                    onTap: () {
                                      if (Constant.userID == null) {
                                        Navigator.push(
                                          context,
                                          PageRouteBuilder(
                                            pageBuilder: (context, animation1,
                                                    animation2) =>
                                                const WebLogin(),
                                            transitionDuration: Duration.zero,
                                            reverseTransitionDuration:
                                                Duration.zero,
                                          ),
                                        );
                                      } else {
                                        playlistDilog(
                                          isEditPlaylist: true,
                                          playlistId: playlistProvider
                                                  .playListData?[index - 1].id
                                                  .toString() ??
                                              "",
                                        );
                                        playlistTitleController.text =
                                            playlistProvider
                                                    .playListData?[index - 1]
                                                    .title
                                                    .toString() ??
                                                "";

                                        playlistProvider.selectPrivacy(
                                            type: int.parse(playlistProvider
                                                    .playListData?[index - 1]
                                                    .playlistType
                                                    .toString() ??
                                                ""));
                                      }
                                    },
                                    child: Icon(
                                      Icons.edit_note_rounded,
                                      size: 20,
                                      color: white,
                                    ),
                                  ),
                                  /* Delete Button */
                                  if (deleteplaylistprovider.position ==
                                          index - 1 &&
                                      deleteplaylistprovider
                                          .deletePlaylistloading)
                                    const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: SizedBox(
                                        height: 12,
                                        width: 12,
                                        child: CircularProgressIndicator(
                                          color: colorPrimary,
                                          strokeWidth: 1,
                                        ),
                                      ),
                                    )
                                  else
                                    InkWell(
                                      onTap: () async {
                                        if (Constant.userID == null) {
                                          Navigator.push(
                                            context,
                                            PageRouteBuilder(
                                              pageBuilder: (context, animation1,
                                                      animation2) =>
                                                  const WebLogin(),
                                              transitionDuration: Duration.zero,
                                              reverseTransitionDuration:
                                                  Duration.zero,
                                            ),
                                          );
                                        } else {
                                          await playlistProvider
                                              .getDeletePlayList(
                                                  index - 1,
                                                  playlistProvider
                                                          .playListData?[
                                                              index - 1]
                                                          .id
                                                          .toString() ??
                                                      "");
                                        }
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: MyImage(
                                            width: 15,
                                            height: 15,
                                            imagePath: "ic_delete.png"),
                                      ),
                                    ),
                                ],
                              );
                            })
                          ],
                        ),
                        const SizedBox(height: 15),
                        MusicTitle(
                            color: white,
                            text: playlistProvider
                                    .playListData?[index - 1].title ??
                                "",
                            textalign: TextAlign.left,
                            fontsizeNormal: Dimens.textMedium,
                            fontsizeWeb: Dimens.textMedium,
                            multilanguage: false,
                            maxline: 1,
                            fontwaight: FontWeight.w500,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal),
                        const SizedBox(height: 5),
                        MyText(
                            color: gray,
                            text: Utils.timeAgoCustom(
                              DateTime.parse(
                                playlistProvider
                                        .playListData?[index - 1].createdAt ??
                                    "",
                              ),
                            ),
                            fontsizeNormal: Dimens.textSmall,
                            fontsizeWeb: Dimens.textSmall,
                            fontwaight: FontWeight.w400,
                            multilanguage: false,
                            maxline: 1,
                            overflow: TextOverflow.ellipsis,
                            inter: false,
                            textalign: TextAlign.left,
                            fontstyle: FontStyle.normal),
                      ],
                    ),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              } else {
                return const SizedBox.shrink();
              }
            }
          },
        ),
      ),
    );
  }

  Widget playListShimmer() {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: ResponsiveGridList(
        minItemWidth: 120,
        minItemsPerRow: Utils.customCrossAxisCount(
            context: context,
            height1600: 7,
            height1200: 6,
            height800: 4,
            height600: 2),
        maxItemsPerRow: Utils.customCrossAxisCount(
            context: context,
            height1600: 7,
            height1200: 6,
            height800: 4,
            height600: 2),
        horizontalGridSpacing: 30,
        verticalGridSpacing: 30,
        listViewBuilderOptions: ListViewBuilderOptions(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
        ),
        children: List.generate(
          18,
          (index) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 180,
                  color: colorPrimaryDark,
                ),
                const SizedBox(height: 15),
                Container(
                  width: 150,
                  height: 5,
                  color: colorPrimaryDark,
                ),
                const SizedBox(height: 5),
                Container(
                  width: 100,
                  height: 5,
                  color: colorPrimaryDark,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  playlistDilog({required bool isEditPlaylist, playlistId}) {
    return showDialog(
      context: context,
      barrierColor: transparent,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          backgroundColor: colorPrimaryDark,
          child: Container(
            width: MediaQuery.of(context).size.width,
            alignment: Alignment.center,
            padding: const EdgeInsets.all(20.0),
            constraints: const BoxConstraints(
              minWidth: 400,
              maxWidth: 500,
              minHeight: 300,
              maxHeight: 350,
            ),
            child: Consumer<PlaylistProvider>(
                builder: (context, playlistprovider, child) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  MyText(
                      color: white,
                      multilanguage: true,
                      text: isEditPlaylist == true
                          ? "editplaylist"
                          : "newplaylist",
                      textalign: TextAlign.left,
                      fontsizeNormal: Dimens.textExtraBig,
                      fontsizeWeb: Dimens.textExtraBig,
                      inter: false,
                      maxline: 1,
                      fontwaight: FontWeight.w600,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal),
                  const SizedBox(height: 25),
                  TextField(
                    cursorColor: white,
                    controller: playlistTitleController,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                    style: Utils.googleFontStyle(1, Dimens.textBig,
                        FontStyle.normal, white, FontWeight.w500),
                    decoration: InputDecoration(
                      hintText: isEditPlaylist == true
                          ? "Change your playlist a title"
                          : "Give your playlist a title",
                      hintStyle: Utils.googleFontStyle(1, Dimens.textBig,
                          FontStyle.normal, gray, FontWeight.w500),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: gray),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: gray),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      MyText(
                          color: white,
                          multilanguage: true,
                          text: "privacy",
                          textalign: TextAlign.left,
                          fontsizeNormal: Dimens.textBig,
                          fontsizeWeb: Dimens.textBig,
                          maxline: 1,
                          fontwaight: FontWeight.w600,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal),
                      const SizedBox(width: 8),
                      MyText(
                          color: white,
                          multilanguage: false,
                          text: ":",
                          textalign: TextAlign.left,
                          fontsizeNormal: Dimens.textBig,
                          fontsizeWeb: Dimens.textBig,
                          maxline: 1,
                          fontwaight: FontWeight.w600,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal),
                      const SizedBox(width: 15),
                      InkWell(
                        onTap: () {
                          playlistprovider.selectPrivacy(type: 1);
                        },
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: playlistprovider.isType == 1
                                ? colorPrimary
                                : transparent,
                            border: Border.all(
                                width: 2,
                                color: playlistprovider.isType == 1
                                    ? colorPrimary
                                    : white),
                          ),
                          child: playlistprovider.isType == 1
                              ? Icon(
                                  Icons.check,
                                  color: colorAccent,
                                  size: 15,
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(width: 15),
                      MyText(
                          color: white,
                          multilanguage: false,
                          text: "Public",
                          textalign: TextAlign.left,
                          fontsizeNormal: Dimens.textBig,
                          fontsizeWeb: Dimens.textBig,
                          maxline: 1,
                          fontwaight: FontWeight.w500,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal),
                      const SizedBox(width: 15),
                      InkWell(
                        onTap: () {
                          playlistprovider.selectPrivacy(type: 2);
                        },
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: playlistprovider.isType == 2
                                ? colorPrimary
                                : transparent,
                            border: Border.all(
                                width: 2,
                                color: playlistprovider.isType == 2
                                    ? colorPrimary
                                    : white),
                          ),
                          child: playlistprovider.isType == 2
                              ? Icon(
                                  Icons.check,
                                  color: colorAccent,
                                  size: 15,
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(width: 15),
                      MyText(
                          color: white,
                          multilanguage: false,
                          text: "Private",
                          textalign: TextAlign.left,
                          fontsizeNormal: Dimens.textBig,
                          fontsizeWeb: Dimens.textBig,
                          maxline: 1,
                          fontwaight: FontWeight.w500,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        radius: 50,
                        autofocus: false,
                        onTap: () {
                          Navigator.pop(context);
                          playlistTitleController.clear();
                          playlistProvider.isType = 0;
                        },
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                          decoration: BoxDecoration(
                            color: colorPrimaryDark,
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: [
                              BoxShadow(
                                color: colorPrimary.withOpacity(0.40),
                                blurRadius: 10.0,
                                spreadRadius: 0.5, //New
                              )
                            ],
                          ),
                          child: MyText(
                              color: white,
                              multilanguage: true,
                              text: "cancel",
                              textalign: TextAlign.left,
                              fontsizeNormal: Dimens.textBig,
                              fontsizeWeb: Dimens.textBig,
                              maxline: 1,
                              fontwaight: FontWeight.w600,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal),
                        ),
                      ),
                      const SizedBox(width: 25),
                      InkWell(
                        onTap: () async {
                          if (playlistTitleController.text.isEmpty) {
                            Utils().showSnackBar(
                                context, "pleaseenterplaylistname", true);
                          } else if (playlistprovider.isType == 0) {
                            Utils().showSnackBar(
                                context, "pleaseselectplaylisttype", true);
                          } else {
                            if (isEditPlaylist == true) {
                              await playlistprovider.getEditPlayList(
                                  playlistId,
                                  playlistTitleController.text,
                                  playlistProvider.isType.toString());

                              if (!playlistprovider.loading) {
                                if (playlistprovider.editPlaylistModel.status ==
                                    200) {
                                  if (!context.mounted) return;
                                  Utils().showSnackBar(
                                      context,
                                      "${playlistprovider.editPlaylistModel.message}",
                                      false);
                                } else {
                                  if (!context.mounted) return;
                                  Utils().showSnackBar(
                                      context,
                                      "${playlistprovider.editPlaylistModel.message}",
                                      false);
                                }
                              }
                            } else {
                              await playlistprovider.getcreatePlayList(
                                Constant.channelID,
                                playlistTitleController.text,
                                playlistProvider.isType.toString(),
                              );
                              if (!playlistprovider.loading) {
                                if (playlistprovider.successModel.status ==
                                    200) {
                                  if (!context.mounted) return;
                                  Utils().showSnackBar(
                                      context,
                                      "${playlistprovider.successModel.message}",
                                      false);
                                } else {
                                  if (!context.mounted) return;
                                  Utils().showSnackBar(
                                      context,
                                      "${playlistprovider.successModel.message}",
                                      false);
                                }
                              }
                            }
                            if (!context.mounted) return;
                            Navigator.pop(context);
                            playlistTitleController.clear();
                            playlistProvider.isType = 0;
                            _fetchData(0);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                          decoration: BoxDecoration(
                            color: colorPrimary,
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: [
                              BoxShadow(
                                color: colorPrimary.withOpacity(0.40),
                                blurRadius: 10.0,
                                spreadRadius: 0.5, //New
                              )
                            ],
                          ),
                          child: MyText(
                              color: colorAccent,
                              multilanguage: true,
                              text: isEditPlaylist == true ? "edit" : "create",
                              textalign: TextAlign.left,
                              fontsizeNormal: Dimens.textBig,
                              fontsizeWeb: Dimens.textBig,
                              maxline: 1,
                              fontwaight: FontWeight.w600,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }),
          ),
        );
      },
    );
  }

  Widget playlistImages({required index, required List<dynamic>? playListImg}) {
    printLog("playlistIndex====> $index");
    if ((playListImg?.length ?? 0) == 4) {
      return SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              Flexible(
                flex: 1,
                child: Row(
                  children: [
                    Flexible(
                      flex: 1,
                      child: MyNetworkImage(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        fit: BoxFit.cover,
                        imagePath: playListImg?[0].toString() ?? "",
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      fit: FlexFit.tight,
                      child: MyNetworkImage(
                        width: MediaQuery.of(context).size.width,
                        height: 150,
                        fit: BoxFit.cover,
                        imagePath: playListImg?[1].toString() ?? "",
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                flex: 1,
                child: Row(
                  children: [
                    Flexible(
                      flex: 1,
                      child: MyNetworkImage(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        fit: BoxFit.cover,
                        imagePath: playListImg?[2].toString() ?? "",
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: MyNetworkImage(
                        width: MediaQuery.of(context).size.width,
                        height: 150,
                        fit: BoxFit.cover,
                        imagePath: playListImg?[3].toString() ?? "",
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ));
    } else if ((playListImg?.length ?? 0) == 3) {
      return SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              Flexible(
                flex: 1,
                child: Row(
                  children: [
                    Flexible(
                      flex: 1,
                      child: MyNetworkImage(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        fit: BoxFit.cover,
                        imagePath: playListImg?[0].toString() ?? "",
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      fit: FlexFit.tight,
                      child: MyNetworkImage(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        fit: BoxFit.cover,
                        imagePath: playListImg?[1].toString() ?? "",
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                flex: 1,
                child: MyNetworkImage(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  fit: BoxFit.cover,
                  imagePath: playListImg?[2].toString() ?? "",
                ),
              ),
            ],
          ));
    } else if ((playListImg?.length ?? 0) == 2) {
      return SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              Flexible(
                flex: 1,
                child: Row(
                  children: [
                    Flexible(
                      flex: 1,
                      child: MyNetworkImage(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        fit: BoxFit.cover,
                        imagePath: playListImg?[0].toString() ?? "",
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      fit: FlexFit.tight,
                      child: MyNetworkImage(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        fit: BoxFit.cover,
                        imagePath: playListImg?[1].toString() ?? "",
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ));
    } else if ((playListImg?.length ?? 0) == 1) {
      return SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: MyNetworkImage(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            fit: BoxFit.cover,
            imagePath: playListImg?[0].toString() ?? "",
          ));
    } else {
      return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: colorPrimaryDark,
        alignment: Alignment.center,
        child: MyImage(width: 35, height: 35, imagePath: "ic_music.png"),
      );
    }
  }
}
