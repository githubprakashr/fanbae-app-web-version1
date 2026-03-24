import 'package:fanbae/model/addremoveblockchannelmodel.dart';
import 'package:fanbae/model/getcontentbychannelmodel.dart' as channelcontent;
import 'package:fanbae/model/getcontentbychannelmodel.dart';
import 'package:fanbae/model/getuserbyrentcontentmodel.dart' as rent;
import 'package:fanbae/model/getuserbyrentcontentmodel.dart';
import 'package:fanbae/model/subscriberlistmodel.dart' as subscriber;
import 'package:fanbae/model/subscriberlistmodel.dart';
import 'package:fanbae/model/successmodel.dart';
import 'package:fanbae/utils/constant.dart';
import 'package:fanbae/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:fanbae/model/profilemodel.dart';
import 'package:fanbae/webservice/apiservice.dart';

class SubscribedChannelProvider extends ChangeNotifier {
  ProfileModel profileModel = ProfileModel();
  SuccessModel successModel = SuccessModel();

  GetContentbyChannelModel getContentbyChannelModel =
      GetContentbyChannelModel();
  GetUserRentContentModel getUserRentContentModel = GetUserRentContentModel();
  AddremoveblockchannelModel addremoveblockchannelModel =
      AddremoveblockchannelModel();

  bool loading = false, profileloading = false;
  bool loadMore = false;
  bool loadingUpdate = false;
  bool deletecontentLoading = false;
  int deleteItemIndex = 0;
  int position = 0;

  List<channelcontent.Result>? channelContentList = [];
  int? totalRows, totalPage, currentPage;
  bool? isMorePage;

  List<rent.Result>? rentContentList = [];
  bool rentloadMore = false;
  int? renttotalRows, renttotalPage, rentcurrentPage;
  bool? rentisMorePage;

  SubscriberlistModel subscriberlistModel = SubscriberlistModel();
  List<subscriber.Result>? subscriberList = [];
  bool subscriberloadMore = false, subscriberLoading = false;
  int? subscribertotalRows, subscribertotalPage, subscribercurrentPage;
  bool? subscriberisMorePage;

  String channelUserId = "";
  String channelId = "";
  int channelPosition = 0;

  selectChannel(channelUserid, channelid, index) {
    channelUserId = channelUserid;
    channelId = channelid;
    channelPosition = index;
    notifyListeners();
  }

  Future<void> getprofile(BuildContext context, touserid) async {
    printLog("getProfile userID :==> ${Constant.userID}");
    profileloading = true;
    profileModel = await ApiService().profile(touserid);
    printLog("get_profile status :==> ${profileModel.status}");
    printLog("get_profile message :==> ${profileModel.message}");
    if (profileModel.status == 200 && profileModel.result != null) {
      if ((profileModel.result?.length ?? 0) > 0) {
        if (context.mounted) {
          printLog("========= get_profile loadAds =========");
          Utils.loadAds(context);
        }
      }
    }
    profileloading = false;
    notifyListeners();
  }

  getDeleteContent(index, contenttype, contentid, episodeid) async {
    deleteItemIndex = index;
    setDeletePlaylistLoading(true);
    successModel =
        await ApiService().deleteContent(contenttype, contentid, episodeid);
    setDeletePlaylistLoading(false);
    channelContentList?.removeAt(index);
  }

  setDeletePlaylistLoading(isSending) {
    printLog("isSending ==> $isSending");
    deletecontentLoading = isSending;
    notifyListeners();
  }

  addremoveBlockChannel(blockUserId, blockChannelId) async {
    loading = true;
    addremoveblockchannelModel =
        await ApiService().addremoveBlockChannel(blockUserId, blockChannelId);
    loading = false;
    notifyListeners();
  }

/* All Content By Channel  */

  Future<void> getSubscriberList(pageNo) async {
    subscriberLoading = true;
    subscriberlistModel = await ApiService().getSubcriberList(pageNo);
    if (subscriberlistModel.status == 200) {
      setSubscriberPaginationData(
          subscriberlistModel.totalRows,
          subscriberlistModel.totalPage,
          subscriberlistModel.currentPage,
          subscriberlistModel.morePage);
      if (subscriberlistModel.result != null &&
          (subscriberlistModel.result?.length ?? 0) > 0) {
        printLog(
            "followingModel length :==> ${(subscriberlistModel.result?.length ?? 0)}");
        printLog('Now on page ==========> $currentPage');
        if (subscriberlistModel.result != null &&
            (subscriberlistModel.result?.length ?? 0) > 0) {
          printLog(
              "followingModel length :==> ${(subscriberlistModel.result?.length ?? 0)}");
          for (var i = 0; i < (subscriberlistModel.result?.length ?? 0); i++) {
            subscriberList
                ?.add(subscriberlistModel.result?[i] ?? subscriber.Result());
          }
          final Map<int, subscriber.Result> postMap = {};
          subscriberList?.forEach((item) {
            postMap[item.id ?? 0] = item;
          });
          subscriberList = postMap.values.toList();
          printLog(
              "followFollowingList length :==> ${(subscriberList?.length ?? 0)}");
          setSubscriberLoadMore(false);
        }
      }
    } else {
      subscriberList = [];
    }
    subscriberLoading = false;
    notifyListeners();
  }

  setSubscriberPaginationData(
      int? totalRows, int? totalPage, int? currentPage, bool? morePage) {
    this.currentPage = currentPage;
    this.totalRows = totalRows;
    this.totalPage = totalPage;
    isMorePage = morePage;
    notifyListeners();
  }

  setSubscriberLoadMore(subscriberloadMore) {
    this.subscriberloadMore = subscriberloadMore;
    notifyListeners();
  }

/* Rent Video */

/* All Content By Channel  */

  Future<void> getcontentbyChannel(
      userid, chennelId, contenttype, pageNo) async {
    loading = true;
    getContentbyChannelModel = await ApiService()
        .contentbyChannel(userid, chennelId, contenttype, pageNo);
    if (getContentbyChannelModel.status == 200) {
      setPaginationData(
          getContentbyChannelModel.totalRows,
          getContentbyChannelModel.totalPage,
          getContentbyChannelModel.currentPage,
          getContentbyChannelModel.morePage);
      if (getContentbyChannelModel.result != null &&
          (getContentbyChannelModel.result?.length ?? 0) > 0) {
        printLog(
            "followingModel length :==> ${(getContentbyChannelModel.result?.length ?? 0)}");
        printLog('Now on page ==========> $currentPage');
        if (getContentbyChannelModel.result != null &&
            (getContentbyChannelModel.result?.length ?? 0) > 0) {
          printLog(
              "followingModel length :==> ${(getContentbyChannelModel.result?.length ?? 0)}");
          for (var i = 0;
              i < (getContentbyChannelModel.result?.length ?? 0);
              i++) {
            channelContentList?.add(
                getContentbyChannelModel.result?[i] ?? channelcontent.Result());
          }
          final Map<int, channelcontent.Result> postMap = {};
          channelContentList?.forEach((item) {
            postMap[item.id ?? 0] = item;
          });
          channelContentList = postMap.values.toList();
          printLog(
              "followFollowingList length :==> ${(channelContentList?.length ?? 0)}");
          setLoadMore(false);
        }
      }
    }
    loading = false;
    notifyListeners();
  }

  setPaginationData(
      int? totalRows, int? totalPage, int? currentPage, bool? morePage) {
    this.currentPage = currentPage;
    this.totalRows = totalRows;
    this.totalPage = totalPage;
    isMorePage = morePage;
    notifyListeners();
  }

/* Rent Video */

  Future<void> getUserbyRentContent(userId, pageNo) async {
    loading = true;
    getUserRentContentModel =
        await ApiService().rentContenetByUser(userId, pageNo);
    if (getUserRentContentModel.status == 200) {
      setRentPaginationData(
          getUserRentContentModel.totalRows,
          getUserRentContentModel.totalPage,
          getUserRentContentModel.currentPage,
          getUserRentContentModel.morePage);
      if (getUserRentContentModel.result != null &&
          (getUserRentContentModel.result?.length ?? 0) > 0) {
        printLog(
            "followingModel length :==> ${(getUserRentContentModel.result?.length ?? 0)}");
        printLog('Now on page ==========> $currentPage');
        if (getUserRentContentModel.result != null &&
            (getUserRentContentModel.result?.length ?? 0) > 0) {
          printLog(
              "followingModel length :==> ${(getUserRentContentModel.result?.length ?? 0)}");
          for (var i = 0;
              i < (getUserRentContentModel.result?.length ?? 0);
              i++) {
            rentContentList
                ?.add(getUserRentContentModel.result?[i] ?? rent.Result());
          }
          final Map<int, rent.Result> postMap = {};
          rentContentList?.forEach((item) {
            postMap[item.id ?? 0] = item;
          });
          rentContentList = postMap.values.toList();
          printLog(
              "followFollowingList length :==> ${(rentContentList?.length ?? 0)}");
          setLoadMore(false);
        }
      }
    }
    loading = false;
    notifyListeners();
  }

  setRentPaginationData(int? renttotalRows, int? renttotalPage,
      int? rentcurrentPage, bool? morePage) {
    this.rentcurrentPage = rentcurrentPage;
    this.renttotalRows = renttotalRows;
    this.renttotalPage = renttotalPage;
    rentisMorePage = rentisMorePage;
    notifyListeners();
  }

/* Load More ProgressBar */

  setLoadMore(loadMore) {
    this.loadMore = loadMore;
    notifyListeners();
  }

  Future<void> getUpdateDataForPayment(
      fullName, email, mobileNumber, countryCode, countryName) async {
    printLog("getUpdateDataForPayment fullname :==> $fullName");
    printLog("getUpdateDataForPayment email :=====> $email");
    printLog("getUpdateDataForPayment mobile :====> $mobileNumber");
    loadingUpdate = true;
    successModel = await ApiService().updateDataForPayment(
        fullName, email, mobileNumber, countryCode, countryName);
    printLog("getUpdateDataForPayment status :==> ${successModel.status}");
    printLog("getUpdateDataForPayment message :==> ${successModel.message}");
    loadingUpdate = false;
    notifyListeners();
  }

  setUpdateLoading(bool isLoading) {
    loadingUpdate = isLoading;
    notifyListeners();
  }

  changeTab(index) {
    position = index;
    notifyListeners();
  }

  clearListData() {
    channelContentList = [];
    channelContentList?.clear();
    getContentbyChannelModel = GetContentbyChannelModel();
  }

  clearProvider() {
    loading = false;
    position = 0;
    profileModel = ProfileModel();
    getContentbyChannelModel = GetContentbyChannelModel();
    channelContentList = [];
    channelContentList?.clear();
    loadMore = false;
    subscriberLoading = false;
    totalRows;
    totalPage;
    currentPage;
    isMorePage;
  }
}
