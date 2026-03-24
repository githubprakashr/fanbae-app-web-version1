import 'package:fanbae/model/adspackagetransectionmodel.dart' as adspackagelist;
import 'package:fanbae/model/adspackagetransectionmodel.dart';
import 'package:fanbae/model/usagehistorymodel.dart' as usagehistory;
import 'package:fanbae/model/usagehistorymodel.dart';
import 'package:fanbae/model/withdrawalrequestmodel.dart' as withdrawal;
import 'package:fanbae/model/withdrawalrequestmodel.dart';
import 'package:flutter/material.dart';
import 'package:fanbae/model/profilemodel.dart';
import 'package:fanbae/webservice/apiservice.dart';
import 'package:fanbae/utils/utils.dart';

class WalletProvider extends ChangeNotifier {
  ProfileModel profileModel = ProfileModel();
  UsageHistoryModel usageHistoryModel = UsageHistoryModel();
  AdspackageTransectionModel adspackageTransectionModel =
      AdspackageTransectionModel();
  WithdrawalrequestModel withdrawalrequestModel = WithdrawalrequestModel();
  bool loading = false;
  int position = 0;

/* Ads Package Transection Api Field */
  List<adspackagelist.Result>? adsPackageTransectionList = [];
  bool adsPackageloading = false;
  bool loadMore = false;
  int? totalRows, totalPage, currentPage;
  bool? isMorePage;
  /* Withdrawal Request Transection Api Field */
  List<withdrawal.Result>? withdrawalTransectionList = [];
  bool withdrawalloading = false;
  bool withdrawalloadMore = false;
  int? withdrawaltotalRows, withdrawaltotalPage, withdrawalcurrentPage;
  bool? withdrawalisMorePage;

/* UsageHistory Transection Api Field */
  List<usagehistory.Result>? usageHistoryList = [];
  bool usageHistoryloading = false;
  bool usageHistoryloadMore = false;
  int? usageHistorytotalRows, usageHistorytotalPage, usageHistorycurrentPage;
  bool? usageHistoryisMorePage;

/* Profile Api With Related Method  */
  getprofile(BuildContext context, touserid) async {
    loading = true;
    profileModel = await ApiService().profile(touserid);
    loading = false;
    notifyListeners();
  }

  changeTab(index) {
    position = index;
    notifyListeners();
  }

/* UsageHistory Transection Api Start */

  Future<void> getUsageHistory(pageNo) async {
    usageHistoryloading = true;
    usageHistoryModel = await ApiService().usageHistory(pageNo);
    if (usageHistoryModel.status == 200) {
      setUsageHistoryPaginationData(
          usageHistoryModel.totalRows,
          usageHistoryModel.totalPage,
          usageHistoryModel.currentPage,
          usageHistoryModel.morePage);
      if (usageHistoryModel.result != null &&
          (usageHistoryModel.result?.length ?? 0) > 0) {
        printLog(
            "usageHistoryList length :==> ${(usageHistoryModel.result?.length ?? 0)}");
        if (usageHistoryModel.result != null &&
            (usageHistoryModel.result?.length ?? 0) > 0) {
          printLog(
              "usageHistoryList length :==> ${(usageHistoryModel.result?.length ?? 0)}");
          for (var i = 0; i < (usageHistoryModel.result?.length ?? 0); i++) {
            usageHistoryList
                ?.add(usageHistoryModel.result?[i] ?? usagehistory.Result());
          }
          final Map<int, usagehistory.Result> postMap = {};
          usageHistoryList?.forEach((item) {
            postMap[item.adsId ?? 0] = item;
          });
          usageHistoryList = postMap.values.toList();
          printLog(
              "usageHistoryList length :==> ${(usageHistoryList?.length ?? 0)}");
          setUsageHistoryLoadMore(false);
        }
      }
    }
    usageHistoryloading = false;
    notifyListeners();
  }

  setUsageHistoryPaginationData(
      int? usageHistorytotalRows,
      int? usageHistorytotalPage,
      int? usageHistorycurrentPage,
      bool? usageHistorymorePage) {
    this.usageHistorycurrentPage = usageHistorycurrentPage;
    this.usageHistorytotalRows = usageHistorytotalRows;
    this.usageHistorytotalPage = usageHistorytotalPage;
    usageHistorymorePage = usageHistorymorePage;
    notifyListeners();
  }

  setUsageHistoryLoadMore(usageHistoryloadMore) {
    this.usageHistoryloadMore = usageHistoryloadMore;
    notifyListeners();
  }

/* UsageHistory Transection Api End*/

/* Ads Package Transection Api Start */

  Future<void> getAdsPackageTransection(pageNo) async {
    adsPackageloading = true;
    adspackageTransectionModel =
        await ApiService().adsPackageTransection(pageNo);
    if (adspackageTransectionModel.status == 200) {
      setPaginationData(
          adspackageTransectionModel.totalRows,
          adspackageTransectionModel.totalPage,
          adspackageTransectionModel.currentPage,
          adspackageTransectionModel.morePage);
      if (adspackageTransectionModel.result != null &&
          (adspackageTransectionModel.result?.length ?? 0) > 0) {
        printLog(
            "adsPackageTransectionList length :==> ${(adspackageTransectionModel.result?.length ?? 0)}");
        printLog('Now on page ==========> $currentPage');
        if (adspackageTransectionModel.result != null &&
            (adspackageTransectionModel.result?.length ?? 0) > 0) {
          printLog(
              "adsPackageTransectionList length :==> ${(adspackageTransectionModel.result?.length ?? 0)}");
          for (var i = 0;
              i < (adspackageTransectionModel.result?.length ?? 0);
              i++) {
            adsPackageTransectionList?.add(
                adspackageTransectionModel.result?[i] ??
                    adspackagelist.Result());
          }
          final Map<int, adspackagelist.Result> postMap = {};
          adsPackageTransectionList?.forEach((item) {
            postMap[item.id ?? 0] = item;
          });
          adsPackageTransectionList = postMap.values.toList();
          printLog(
              "adsPackageTransectionList length :==> ${(adsPackageTransectionList?.length ?? 0)}");
          setLoadMore(false);
        }
      }
    }
    adsPackageloading = false;
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

  setLoadMore(loadMore) {
    this.loadMore = loadMore;
    notifyListeners();
  }

/* Ads Package Transection Api End*/

/* Ads Package Transection Api Start */

  Future<void> getWithdrawalTransection(pageNo) async {
    withdrawalloading = true;
    withdrawalrequestModel = await ApiService().withdrawalRequestList(pageNo);
    if (withdrawalrequestModel.status == 200) {
      setWithdrawalPaginationData(
          withdrawalrequestModel.totalRows,
          withdrawalrequestModel.totalPage,
          withdrawalrequestModel.currentPage,
          withdrawalrequestModel.morePage);
      if (withdrawalrequestModel.result != null &&
          (withdrawalrequestModel.result?.length ?? 0) > 0) {
        printLog(
            "withdrawalTransectionList length :==> ${(withdrawalrequestModel.result?.length ?? 0)}");
        printLog('Now on page ==========> $currentPage');
        if (withdrawalrequestModel.result != null &&
            (withdrawalrequestModel.result?.length ?? 0) > 0) {
          printLog(
              "withdrawalTransectionList length :==> ${(withdrawalrequestModel.result?.length ?? 0)}");
          for (var i = 0;
              i < (withdrawalrequestModel.result?.length ?? 0);
              i++) {
            withdrawalTransectionList
                ?.add(withdrawalrequestModel.result?[i] ?? withdrawal.Result());
          }
          final Map<int, withdrawal.Result> postMap = {};
          withdrawalTransectionList?.forEach((item) {
            postMap[item.id ?? 0] = item;
          });
          withdrawalTransectionList = postMap.values.toList();
          printLog(
              "withdrawalTransectionList length :==> ${(withdrawalTransectionList?.length ?? 0)}");
          setWithdrawalLoadMore(false);
        }
      }
    }
    withdrawalloading = false;
    notifyListeners();
  }

  setWithdrawalPaginationData(
      int? withdrawaltotalRows,
      int? withdrawaltotalPage,
      int? withdrawalcurrentPage,
      bool? withdrawalmorePage) {
    this.withdrawalcurrentPage = withdrawalcurrentPage;
    this.withdrawaltotalRows = withdrawaltotalRows;
    this.withdrawaltotalPage = withdrawaltotalPage;
    isMorePage = withdrawalmorePage;
    notifyListeners();
  }

  setWithdrawalLoadMore(withdrawalloadMore) {
    this.withdrawalloadMore = withdrawalloadMore;
    notifyListeners();
  }

/* Ads Package Transection Api End*/

/* UsageHistory Transection Api Field */
  clearUsageHistory() {
    usageHistoryList = [];
    usageHistoryList?.clear();
    usageHistoryloading = false;
    usageHistoryloadMore = false;
    usageHistorytotalRows;
    usageHistorytotalPage;
    usageHistorycurrentPage;
    usageHistoryisMorePage;
  }

/* Clear Ads Package Request Field */
  clearAdsPackage() {
    adsPackageTransectionList = [];
    adsPackageTransectionList?.clear();
    loadMore = false;
    totalRows;
    totalPage;
    currentPage;
    isMorePage;
    isMorePage;
  }

/* Clear Withdrawal Request Field */
  clearWithdrawal() {
    withdrawalTransectionList = [];
    withdrawalTransectionList?.clear();
    withdrawalloadMore = false;
    withdrawaltotalRows;
    withdrawaltotalPage;
    withdrawalcurrentPage;
    withdrawalisMorePage;
    withdrawalisMorePage;
  }

/* Clear All Field */
  clearProvider() {
    profileModel = ProfileModel();
    adspackageTransectionModel = AdspackageTransectionModel();
    withdrawalrequestModel = WithdrawalrequestModel();
    loading = false;
    position = 0;
    /* UsageHistory Transection Api Field */
    usageHistoryList = [];
    usageHistoryList?.clear();
    usageHistoryloading = false;
    usageHistoryloadMore = false;
    usageHistorytotalRows;
    usageHistorytotalPage;
    usageHistorycurrentPage;
    usageHistoryisMorePage;
    /* Ads Package Transection Api Field */
    adsPackageTransectionList = [];
    adsPackageTransectionList?.clear();
    loadMore = false;
    totalRows;
    totalPage;
    currentPage;
    isMorePage;
    /* Withdrawal Request Field*/
    withdrawalTransectionList = [];
    withdrawalTransectionList?.clear();
    withdrawalloadMore = false;
    withdrawaltotalRows;
    withdrawaltotalPage;
    withdrawalcurrentPage;
    withdrawalisMorePage;
  }
}
