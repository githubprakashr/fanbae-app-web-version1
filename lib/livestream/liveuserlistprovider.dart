import 'package:fanbae/livestream/liveuserlistmodel.dart';
import 'package:fanbae/utils/constant.dart';
import 'package:fanbae/utils/utils.dart';
import 'package:fanbae/webservice/apiservice.dart';
import 'package:flutter/material.dart';

class LiveUserListProvider extends ChangeNotifier {
  LiveUserListModel liveUserListModel = LiveUserListModel();
  List<Result>? liveUserList = [];
  bool loadMore = false, loading = false;
  int? totalRows, totalPage, currentPage;
  bool? isMorePage;
  TextEditingController searchController = TextEditingController();
  bool isShowSearch = false;

  Future<void> getLiveUserList(pageNo, type) async {
    loading = true;
    if (pageNo == 1) {
      liveUserList?.clear();
    }
    liveUserListModel = type == "following"
        ? await ApiService().listOfSubscribedLiveUsers(pageNo)
        : await ApiService().listOfLiveUsers(pageNo);
    if (liveUserListModel.status == 200) {
      setPaginationData(
          liveUserListModel.totalRows,
          liveUserListModel.totalPage,
          liveUserListModel.currentPage,
          liveUserListModel.morePage);

      printLog(
          "LiveUserModel length :==> ${(liveUserListModel.result?.length ?? 0)}");
      addFakeData();
      if (liveUserListModel.result != null &&
          (liveUserListModel.result?.length ?? 0) > 0) {
        for (var i = 0; i < (liveUserListModel.result?.length ?? 0); i++) {
          liveUserList?.add(liveUserListModel.result?[i] ?? Result());
        }
        if (searchController.text.isNotEmpty) {
          liveUserList = liveUserList
              ?.where((item) =>
                  (item.channelName
                          ?.toLowerCase()
                          .contains(searchController.text.toLowerCase()) ??
                      false) ||
                  (item.fullName
                          ?.toLowerCase()
                          .contains(searchController.text.toLowerCase()) ??
                      false))
              .toList();
        }
        printLog("LiveUserList length :==> ${(liveUserList?.length ?? 0)}");
        final Map<int, Result> postMap = {};
        liveUserList?.forEach((item) {
          postMap[item.id ?? 0] = item;
        });
        liveUserList = postMap.values.toList();
        printLog("LiveUserList length :==> ${(liveUserList?.length ?? 0)}");
        setLoadMore(false);
      } else {
        liveUserList = [];
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

  addFakeData() {
    if (Constant.isFake == "1") {
      liveUserList?.addAll([
        Result(
          id: 1,
          roomId: "Room1",
          userId: 101,
          totalView: 1000,
          status: 1,
          createdAt: "2024-11-18T10:00:00.000Z",
          updatedAt: "2024-11-18T11:00:00.000Z",
          channelId: "CH101",
          channelName: "Channel One",
          fullName: "John Doe",
          email: "john.doe@example.com",
          countryCode: "+1",
          mobileNumber: "1234567890",
          countryName: "USA",
          image:
              "https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?q=80&w=1887&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
          isFake: 1,
          isBuy: 0,
        ),
        Result(
          id: 2,
          roomId: "Room2",
          userId: 102,
          totalView: 2000,
          status: 1,
          createdAt: "2024-11-18T12:00:00.000Z",
          updatedAt: "2024-11-18T13:00:00.000Z",
          channelId: "CH102",
          channelName: "Channel Two",
          fullName: "Jane Smith",
          email: "jane.smith@example.com",
          countryCode: "+44",
          mobileNumber: "9876543210",
          countryName: "UK",
          image:
              "https://images.unsplash.com/photo-1513207565459-d7f36bfa1222?q=80&w=1889&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
          isFake: 1,
          isBuy: 1,
        ),
        Result(
          id: 3,
          roomId: "Room3",
          userId: 103,
          totalView: 1500,
          status: 1,
          createdAt: "2024-11-18T14:00:00.000Z",
          updatedAt: "2024-11-18T15:00:00.000Z",
          channelId: "CH103",
          channelName: "Channel Three",
          fullName: "Alice Johnson",
          email: "alice.johnson@example.com",
          countryCode: "+91",
          mobileNumber: "1122334455",
          countryName: "India",
          image:
              "https://images.unsplash.com/photo-1533435137002-455932c8538f?q=80&w=1887&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
          isFake: 1,
          isBuy: 0,
        ),
        Result(
          id: 4,
          roomId: "Room4",
          userId: 104,
          totalView: 80000,
          status: 1,
          createdAt: "2024-11-18T16:00:00.000Z",
          updatedAt: "2024-11-18T17:00:00.000Z",
          channelId: "CH104",
          channelName: "Channel Four",
          fullName: "Bob Brown",
          email: "bob.brown@example.com",
          countryCode: "+81",
          mobileNumber: "5566778899",
          countryName: "Japan",
          image:
              "https://plus.unsplash.com/premium_photo-1682614334089-da623bdcaf2d?q=80&w=1887&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
          isFake: 1,
          isBuy: 1,
        ),
      ]);
    }
  }

  clearProvider() {
    liveUserListModel = LiveUserListModel();
    liveUserList = [];
    liveUserList?.clear();
    loadMore = false;
    loading = false;
    totalRows;
    totalPage;
    currentPage;
    isMorePage;
    isShowSearch = false;
    searchController.clear();
  }
}
