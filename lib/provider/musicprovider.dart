import 'package:fanbae/model/addremovecontenttoplaylistmodel.dart';
import 'package:fanbae/model/addremovewatchlatermodel.dart';
import 'package:fanbae/model/getcontentbychannelmodel.dart' as playlist;
import 'package:fanbae/model/getcontentbychannelmodel.dart';
import 'package:fanbae/model/sectionlistmodel.dart' as section;
import 'package:fanbae/model/sectionlistmodel.dart';
import 'package:fanbae/model/successmodel.dart';
import 'package:fanbae/utils/utils.dart';
import 'package:fanbae/webservice/apiservice.dart';
import 'package:flutter/material.dart';

class MusicProvider extends ChangeNotifier {
  SectionListModel sectionListModel = SectionListModel();
  AddremoveWatchlaterModel addremoveWatchlaterModel =
      AddremoveWatchlaterModel();

  GetContentbyChannelModel getContentbyChannelModel =
      GetContentbyChannelModel();

  AddremoveContentToPlaylistModel addremoveContentToPlaylistModel =
      AddremoveContentToPlaylistModel();

  SuccessModel createPlaylistModel = SuccessModel();

  bool loading = false;
  int tabindex = 0;
  int count = 0;
  double podcastListHeight = 0.0;

  /* Section List Field  */
  List<section.Result>? sectionList = [];
  bool sectionloading = false, sectionLoadMore = false;
  int? sectiontotalRows, sectiontotalPage, sectioncurrentPage;
  bool? sectionisMorePage;

  /* Get PlayList Field */
  int? playlisttotalRows, playlisttotalPage, playlistcurrentPage;
  bool? playlistmorePage;
  List<playlist.Result>? playlistData = [];
  bool playlistLoading = false, playlistLoadmore = false;
  String playlistId = "";
  int? playlistPosition;
  bool isSelectPlaylist = false;
  int isType = 0;

  setLoading(bool isLoading) {
    sectionloading = isLoading;
    notifyListeners();
  }

/* SectionList Api */
  Future<void> getSeactionList(ishomescreen, contenttype, pageNo) async {
    sectionloading = true;
    sectionListModel =
        await ApiService().sectionList(ishomescreen, contenttype, pageNo);
    if (sectionListModel.status == 200) {
      setSectionPaginationData(
          sectionListModel.totalRows,
          sectionListModel.totalPage,
          sectionListModel.currentPage,
          sectionListModel.morePage);
      if (sectionListModel.result != null &&
          (sectionListModel.result?.length ?? 0) > 0) {
        printLog(
            "followingModel length :==> ${(sectionListModel.result?.length ?? 0)}");
        printLog('Now on page ==========> $sectioncurrentPage');
        if (sectionListModel.result != null &&
            (sectionListModel.result?.length ?? 0) > 0) {
          printLog(
              "followingModel length :==> ${(sectionListModel.result?.length ?? 0)}");
          for (var i = 0; i < (sectionListModel.result?.length ?? 0); i++) {
            sectionList?.add(sectionListModel.result?[i] ?? section.Result());
          }
          final Map<int, section.Result> postMap = {};
          sectionList?.forEach((item) {
            postMap[item.id ?? 0] = item;
          });
          sectionList = postMap.values.toList();
          printLog(
              "followFollowingList length :==> ${(sectionList?.length ?? 0)}");
          setSectionLoadMore(false);
        }
      }
    }
    sectionloading = false;
    notifyListeners();
  }

  setSectionPaginationData(int? sectiontotalRows, int? sectiontotalPage,
      int? sectioncurrentPage, bool? sectionisMorePage) {
    this.sectioncurrentPage = sectioncurrentPage;
    this.sectiontotalRows = sectiontotalRows;
    this.sectiontotalPage = sectiontotalPage;
    sectionisMorePage = sectionisMorePage;
    notifyListeners();
  }

  setSectionLoadMore(sectionLoadMore) {
    this.sectionLoadMore = sectionLoadMore;
    notifyListeners();
  }

/* Watch Later */
  addremoveWatchLater(contenttype, contentid, episodeid, type) async {
    loading = true;
    addremoveWatchlaterModel = await ApiService()
        .addremoveWatchLater(contenttype, contentid, episodeid, type);
    loading = false;
    notifyListeners();
  }

/* Add Remove Playlist */
  addremoveContentToPlaylist(
      chennelId, playlistId, contenttype, contentid, episodeid, type) async {
    loading = true;
    addremoveContentToPlaylistModel = await ApiService()
        .addremoveContenttoPlaylist(
            chennelId, playlistId, contenttype, contentid, episodeid, type);
    loading = false;
    notifyListeners();
  }

/* Get Playlist Created By Perticular User Start */

  Future<void> getcontentbyChannel(
      userid, chennelId, contenttype, pageNo) async {
    printLog("Playlist Position :==> $playlistPosition");
    printLog("getPostList pageNo :==> $pageNo");
    playlistLoading = true;
    getContentbyChannelModel = await ApiService()
        .contentbyChannel(userid, chennelId, contenttype, pageNo);
    printLog("getPlaylistList status :===> ${getContentbyChannelModel.status}");
    printLog(
        "getPlaylistList message :==> ${getContentbyChannelModel.message}");
    if (getContentbyChannelModel.status == 200) {
      setPlaylistPaginationData(
          getContentbyChannelModel.totalRows,
          getContentbyChannelModel.totalPage,
          getContentbyChannelModel.currentPage,
          getContentbyChannelModel.morePage);
      if (getContentbyChannelModel.result != null &&
          (getContentbyChannelModel.result?.length ?? 0) > 0) {
        printLog(
            "Playlist length first:==> ${(getContentbyChannelModel.result?.length ?? 0)}");

        printLog(
            "Playlist length :==> ${(getContentbyChannelModel.result?.length ?? 0)}");

        for (var i = 0;
            i < (getContentbyChannelModel.result?.length ?? 0);
            i++) {
          playlistData
              ?.add(getContentbyChannelModel.result?[i] ?? playlist.Result());
        }
        final Map<int, playlist.Result> postMap = {};
        playlistData?.forEach((item) {
          postMap[item.id ?? 0] = item;
        });
        playlistData = postMap.values.toList();
        printLog("Playlist length :==> ${(playlistData?.length ?? 0)}");
        setPlaylistLoadMore(false);
      }
    }
    playlistLoading = false;
    notifyListeners();
  }

  setPlaylistPaginationData(int? playlisttotalRows, int? playlisttotalPage,
      int? playlistcurrentPage, bool? playlistmorePage) {
    this.playlistcurrentPage = playlistcurrentPage;
    this.playlisttotalRows = playlisttotalRows;
    this.playlisttotalPage = playlisttotalPage;
    playlistmorePage = playlistmorePage;
    notifyListeners();
  }

  setPlaylistLoadMore(playlistLoadmore) {
    this.playlistLoadmore = playlistLoadmore;
    notifyListeners();
  }

  selectPlaylist(int index, isPlaylistId, isSelect) {
    playlistPosition = index;
    playlistId = isPlaylistId;
    isSelectPlaylist = isSelect;
    printLog("reasonId===> $playlistId");
    notifyListeners();
  }

  /* isType == 1 ==>  Public Playlist */
  /* isType == 2 ==>  Private Playlist */
  selectPrivacy({required int type}) {
    isType = type;
    notifyListeners();
  }

  getcreatePlayList(chennelId, title, playlistType) async {
    loading = true;
    createPlaylistModel =
        await ApiService().createPlayList(chennelId, title, playlistType);
    loading = false;
  }

/* Get Playlist Created By Perticular User End */

  chageTab(int index) {
    tabindex = index;
    notifyListeners();
  }

  clearTab() {
    sectionList = [];
    sectionList?.clear();
    sectionListModel = SectionListModel();
  }

  clearProvider() {
    sectionListModel = SectionListModel();
    addremoveWatchlaterModel = AddremoveWatchlaterModel();
    getContentbyChannelModel = GetContentbyChannelModel();
    addremoveContentToPlaylistModel = AddremoveContentToPlaylistModel();
    loading = false;
    tabindex = 0;
    count = 0;
    /* Section List Field  */
    sectionList = [];
    sectionloading = false;
    sectionLoadMore = false;
    sectiontotalRows;
    sectiontotalPage;
    sectioncurrentPage;
    sectionisMorePage;
    /* Get PlayList Field */
    playlisttotalRows;
    playlisttotalPage;
    playlistcurrentPage;
    playlistmorePage;
    playlistData = [];
    playlistLoading = false;
    playlistLoadmore = false;
    playlistId = "";
    playlistPosition;
    isSelectPlaylist = false;
    isType = 0;
  }

  clearPlaylistData() {
    /* Get PlayList Field */
    playlisttotalRows;
    playlisttotalPage;
    playlistcurrentPage;
    playlistmorePage;
    playlistData = [];
    playlistData?.clear();
    playlistLoading = false;
    playlistLoadmore = false;
    isSelectPlaylist = false;
    playlistId = "";
    playlistPosition;
    isType = 0;
  }
}
