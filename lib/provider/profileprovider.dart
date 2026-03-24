import 'package:fanbae/model/addremoveblockchannelmodel.dart';
import 'package:fanbae/model/addremovesubscribemodel.dart';
import 'package:fanbae/model/getchannelfeedmodel.dart' as post;
import 'package:fanbae/model/getcontentbychannelmodel.dart' as channelcontent;
import 'package:fanbae/model/getcontentbychannelmodel.dart';
import 'package:fanbae/model/getuserbyrentcontentmodel.dart' as rent;
import 'package:fanbae/model/getuserbyrentcontentmodel.dart';
import 'package:fanbae/model/successmodel.dart';
import 'package:fanbae/utils/constant.dart';
import 'package:fanbae/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:fanbae/model/profilemodel.dart';
import 'package:fanbae/webservice/apiservice.dart';
import 'package:universal_html/js.dart';

class ProfileProvider extends ChangeNotifier {
  ProfileModel profileModel = ProfileModel();
  ProfileModel profileModelReel = ProfileModel();
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

  /* Channel Feed Content */
  post.GetChannelFeedModel getChannelFeedModel = post.GetChannelFeedModel();
  List<post.Result>? channelFeedList = [];
  bool channelloadMore = false;
  int? channeltotalRows, channeltotalPage, channelcurrentPage;
  bool? channelisMorePage;

  /* Add Remove Subscriber */
  AddremoveSubscribeModel addremoveSubscribeModel = AddremoveSubscribeModel();

  Future<void> getprofile(BuildContext context, toUserId) async {
    printLog("getProfile userID :==> ${Constant.userID}");
    profileloading = true;
    profileModel = await ApiService().profile(toUserId);
    printLog("get_profile status :==> ${profileModel.status}");
    printLog("get_profile message :==> ${profileModel.message}");
    if (profileModel.status == 200 && profileModel.result != null) {
      if ((profileModel.result?.length ?? 0) > 0) {
        if (context.mounted) {
          if (toUserId == Constant.userID) {
            Utils.saveUserCreds(
                userID: profileModel.result?[0].id.toString(),
                channeId: profileModel.result?[0].channelId.toString(),
                channelName: profileModel.result?[0].channelName.toString(),
                fullName: profileModel.result?[0].fullName.toString(),
                email: profileModel.result?[0].email.toString(),
                mobileNumber: profileModel.result?[0].mobileNumber.toString(),
                countrycode: profileModel.result?[0].countryCode.toString(),
                countryname: profileModel.result?[0].countryName.toString(),
                image: profileModel.result?[0].image.toString(),
                coverImg: profileModel.result?[0].coverImg.toString(),
                deviceType: profileModel.result?[0].deviceType.toString(),
                deviceToken: profileModel.result?[0].deviceToken.toString(),
                userIsBuy: profileModel.result?[0].isBuy.toString(),
                isAdsFree: profileModel.result?[0].adsFree.toString(),
                isCreator: profileModel.result?[0].isCreator.toString(),
                walletBalance: profileModel.result?[0].walletBalance.toString(),
                isDownload: profileModel.result?[0].isDownload.toString());
          }
          Utils.loadAds(context);
        }
      }
    }
    profileloading = false;
    notifyListeners();
  }

  Future<void> getProfileReel(BuildContext context, toUserId) async {
    printLog("getProfile userID :==> ${Constant.userID}");
    profileloading = true;
    profileModelReel = await ApiService().profile(toUserId);
    printLog("profileModelReel status :==> ${profileModelReel.status}");
    printLog("profileModelReel message :==> ${profileModelReel.message}");
    if (profileModelReel.status == 200 && profileModelReel.result != null) {}
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

  fetchMyProfile(context) async {
    loading = true;
    await getprofile(context, Constant.userID);
    loading = true;
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

  addRemoveSubscriber(index, touserid, type) async {
    if ((profileModel.result?[index].isSubscribe ?? 0) == 0) {
      profileModel.result?[index].isSubscribe = 1;
    } else {
      profileModel.result?[index].isSubscribe = 0;
    }
    notifyListeners();
    addremoveSubscribeModel =
        await ApiService().addremoveSubscribe(touserid, type);
  }

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

  /* Channel Feed Content */

  Future<void> getChannelFeed(userId, channelId, pageNo) async {
    loading = true;
    channelFeedList = [];
    getChannelFeedModel =
        await ApiService().getChennalFeed(userId, channelId, pageNo);
    if (getChannelFeedModel.status == 200) {
      setChannelFeedPaginationData(
          getChannelFeedModel.totalRows,
          getChannelFeedModel.totalPage,
          getChannelFeedModel.currentPage,
          getChannelFeedModel.morePage);
      if (getChannelFeedModel.result != null &&
          (getChannelFeedModel.result?.length ?? 0) > 0) {
        printLog(
            "UserPost length :==> ${(getChannelFeedModel.result?.length ?? 0)}");
        printLog('Now on page ==========> $currentPage');
        if (getChannelFeedModel.result != null &&
            (getChannelFeedModel.result?.length ?? 0) > 0) {
          printLog(
              "UserPost length :==> ${(getChannelFeedModel.result?.length ?? 0)}");
          for (var i = 0; i < (getChannelFeedModel.result?.length ?? 0); i++) {
            channelFeedList
                ?.add(getChannelFeedModel.result?[i] ?? post.Result());
          }
          printLog("UserPost length :==> ${(channelFeedList?.length ?? 0)}");
          final Map<int, post.Result> postMap = {};
          channelFeedList?.forEach((item) {
            postMap[item.id ?? 0] = item;
          });
          channelFeedList = postMap.values.toList();
          printLog(
              "UserPostList  length :==> ${(channelFeedList?.length ?? 0)}");
          setLoadMore(false);
        }
      }
    }
    loading = false;
    notifyListeners();
  }

  setChannelFeedPaginationData(int? channeltotalRows, int? channeltotalPage,
      int? channelcurrentPage, bool? channelisMorePage) {
    this.channelcurrentPage = channelcurrentPage;
    this.channeltotalRows = channeltotalRows;
    this.channeltotalPage = channeltotalPage;
    channelisMorePage = channelisMorePage;
    notifyListeners();
  }

  deletePost(postId, channelid) async {
    successModel = await ApiService().deletePost(postId, channelid);
    notifyListeners();
  }

  clearChannelFeed() {
    getChannelFeedModel = post.GetChannelFeedModel();
    channelFeedList = [];
    channelloadMore = false;
    channeltotalRows;
    channeltotalPage;
    channelcurrentPage;
    channelisMorePage;
  }

  /* Channel Media Content */

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
    profileModelReel = ProfileModel();
    successModel = SuccessModel();
    getUserRentContentModel = GetUserRentContentModel();
    addremoveblockchannelModel = AddremoveblockchannelModel();
    getContentbyChannelModel = GetContentbyChannelModel();
    channelContentList = [];
    channelContentList?.clear();
    loadMore = false;
    totalRows;
    totalPage;
    currentPage;
    isMorePage;
  }
}
