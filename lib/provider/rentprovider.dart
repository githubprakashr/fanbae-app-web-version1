import 'package:fanbae/model/rentsectionmodel.dart';
import 'package:fanbae/model/successmodel.dart';
import 'package:fanbae/webservice/apiservice.dart';
import 'package:flutter/material.dart';
import 'package:fanbae/utils/utils.dart';

class RentProvider extends ChangeNotifier {
  RentSectionModel rentSectionModel = RentSectionModel();
  SuccessModel rentTransectionModel = SuccessModel();
  bool loading = false;
  bool payLoading = false;

  List<Result>? rentsectionList = [];
  bool rentloading = false, rentLoadMore = false;
  int? renttotalRows, renttotalPage, rentcurrentPage;
  bool? rentisMorePage;

/* Rent SectionList Api Start */
  Future<void> getRentSeactionList(pageNo) async {
    rentloading = true;
    rentSectionModel = await ApiService().rentSection(pageNo);
    if (rentSectionModel.status == 200) {
      setRentSectionPaginationData(
          rentSectionModel.totalRows,
          rentSectionModel.totalPage,
          rentSectionModel.currentPage,
          rentSectionModel.morePage);
      if (rentSectionModel.result != null &&
          (rentSectionModel.result?.length ?? 0) > 0) {
        printLog(
            "followingModel length :==> ${(rentSectionModel.result?.length ?? 0)}");
        printLog('Now on page ==========> $rentcurrentPage');
        if (rentSectionModel.result != null &&
            (rentSectionModel.result?.length ?? 0) > 0) {
          printLog(
              "followingModel length :==> ${(rentSectionModel.result?.length ?? 0)}");
          for (var i = 0; i < (rentSectionModel.result?.length ?? 0); i++) {
            rentsectionList?.add(rentSectionModel.result?[i] ?? Result());
          }
          final Map<int, Result> postMap = {};
          rentsectionList?.forEach((item) {
            postMap[item.id ?? 0] = item;
          });
          rentsectionList = postMap.values.toList();
          printLog(
              "followFollowingList length :==> ${(rentsectionList?.length ?? 0)}");
          setRentSectionLoadMore(false);
        }
      }
    }
    rentloading = false;
    notifyListeners();
  }

  setRentSectionPaginationData(int? renttotalRows, int? renttotalPage,
      int? rentcurrentPage, bool? rentisMorePage) {
    this.rentcurrentPage = rentcurrentPage;
    this.renttotalRows = renttotalRows;
    this.renttotalPage = renttotalPage;
    rentisMorePage = rentisMorePage;
    notifyListeners();
  }

  setRentSectionLoadMore(rentLoadMore) {
    this.rentLoadMore = rentLoadMore;
    notifyListeners();
  }

  /* Transections APi Start */
  Future<void> getRentTransaction(sectionIndex, videoIndex, contentId, price,
      discription, transectionId) async {
    payLoading = true;
    rentTransectionModel = await ApiService()
        .rentTransection(contentId, price, discription, transectionId);
    payLoading = false;
    getChangeIsRent(sectionIndex, videoIndex);
    notifyListeners();
  }

  getChangeIsRent(sectionIndex, videoIndex) {
    if ((rentsectionList?[sectionIndex].data?[videoIndex].isRentBuy ?? 0) ==
        0) {
      rentsectionList?[sectionIndex].data?[videoIndex].isRentBuy = 1;
    }
  }

  clearProvider() {
    rentSectionModel = RentSectionModel();
    rentTransectionModel = SuccessModel();
    loading = false;
    rentsectionList = [];
    rentsectionList?.clear();
    rentloading = false;
    rentLoadMore = false;
    payLoading = false;
    renttotalRows;
    renttotalPage;
    rentcurrentPage;
    rentisMorePage;
  }
}
