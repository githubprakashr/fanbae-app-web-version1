import 'package:fanbae/model/withdrawalrequestmodel.dart';
import 'package:fanbae/webservice/apiservice.dart';
import 'package:flutter/material.dart';
import 'package:fanbae/utils/utils.dart';

class WithdrawalRequestProvider extends ChangeNotifier {
  WithdrawalrequestModel withdrawalrequestModel = WithdrawalrequestModel();
  bool loading = false;

  /* Ads Package Transection Api Field */
  List<Result>? withdrawalRequestList = [];
  bool loadMore = false;
  int? totalRows, totalPage, currentPage;
  bool? isMorePage;

/* Ads Package Transection Api Start */

  Future<void> getWalletRequestList(pageNo) async {
    loading = true;
    withdrawalrequestModel = await ApiService().withdrawalRequestList(pageNo);
    if (withdrawalrequestModel.status == 200) {
      setPaginationData(
          withdrawalrequestModel.totalRows,
          withdrawalrequestModel.totalPage,
          withdrawalrequestModel.currentPage,
          withdrawalrequestModel.morePage);
      if (withdrawalrequestModel.result != null &&
          (withdrawalrequestModel.result?.length ?? 0) > 0) {
        printLog(
            "adsPackageTransectionList length :==> ${(withdrawalrequestModel.result?.length ?? 0)}");
        printLog('Now on page ==========> $currentPage');
        if (withdrawalrequestModel.result != null &&
            (withdrawalrequestModel.result?.length ?? 0) > 0) {
          printLog(
              "adsPackageTransectionList length :==> ${(withdrawalrequestModel.result?.length ?? 0)}");
          for (var i = 0;
              i < (withdrawalrequestModel.result?.length ?? 0);
              i++) {
            withdrawalRequestList
                ?.add(withdrawalrequestModel.result?[i] ?? Result());
          }
          final Map<int, Result> postMap = {};
          withdrawalRequestList?.forEach((item) {
            postMap[item.id ?? 0] = item;
          });
          withdrawalRequestList = postMap.values.toList();
          printLog(
              "adsPackageTransectionList length :==> ${(withdrawalRequestList?.length ?? 0)}");
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

  setLoadMore(loadMore) {
    this.loadMore = loadMore;
    notifyListeners();
  }

/* Ads Package Transection Api Start*/

  clearProvider() {
    withdrawalrequestModel = WithdrawalrequestModel();
    loading = false;
    withdrawalRequestList = [];
    withdrawalRequestList?.clear();
    loadMore = false;
    totalRows;
    totalPage;
    currentPage;
    isMorePage;
  }
}
