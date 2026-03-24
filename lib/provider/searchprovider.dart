import 'package:fanbae/model/addremovecontenttoplaylistmodel.dart';
import 'package:fanbae/model/addremovewatchlatermodel.dart';
import 'package:fanbae/model/getcontentbychannelmodel.dart' as playlist;
import 'package:fanbae/model/getcontentbychannelmodel.dart';
import 'package:fanbae/model/successmodel.dart';
import 'package:flutter/material.dart';
import 'package:fanbae/model/searchmodel.dart';
import 'package:fanbae/webservice/apiservice.dart';
import 'package:fanbae/utils/utils.dart';

class SearchProvider extends ChangeNotifier {
  SearchModel searchmodel = SearchModel();
  AddremoveWatchlaterModel addremoveWatchlaterModel =
      AddremoveWatchlaterModel();

  GetContentbyChannelModel getContentbyChannelModel =
      GetContentbyChannelModel();

  AddremoveContentToPlaylistModel addremoveContentToPlaylistModel =
      AddremoveContentToPlaylistModel();

  SuccessModel createPlaylistModel = SuccessModel();
  bool searchloading = false;

  /* Get PlayList Field */
  int? playlisttotalRows, playlisttotalPage, playlistcurrentPage;
  bool? playlistmorePage;
  List<playlist.Result>? playlistData = [];
  bool playlistLoading = false, playlistLoadmore = false;
  String playlistId = "";
  int? playlistPosition;
  bool isSelectPlaylist = false;
  int isType = 0;

  getSearch(name, type) async {
    searchloading = true;
    searchmodel = await ApiService().search(name, type);
    searchloading = false;
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
    searchloading = true;
    createPlaylistModel =
        await ApiService().createPlayList(chennelId, title, playlistType);
    searchloading = false;
  }

/* Get Playlist Created By Perticular User End */

  /* Watch Later */
  addremoveWatchLater(contenttype, contentid, episodeid, type) async {
    searchloading = true;
    addremoveWatchlaterModel = await ApiService()
        .addremoveWatchLater(contenttype, contentid, episodeid, type);
    searchloading = false;
    notifyListeners();
  }

/* Add Remove Playlist */
  addremoveContentToPlaylist(
      chennelId, playlistId, contenttype, contentid, episodeid, type) async {
    searchloading = true;
    addremoveContentToPlaylistModel = await ApiService()
        .addremoveContenttoPlaylist(
            chennelId, playlistId, contenttype, contentid, episodeid, type);
    searchloading = false;
    notifyListeners();
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

  clearProvider() {
    searchmodel = SearchModel();
    addremoveWatchlaterModel = AddremoveWatchlaterModel();
    getContentbyChannelModel = GetContentbyChannelModel();
    addremoveContentToPlaylistModel = AddremoveContentToPlaylistModel();
    createPlaylistModel = SuccessModel();
    searchloading = false;
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
}
