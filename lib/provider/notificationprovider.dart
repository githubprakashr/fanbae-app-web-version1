import 'package:fanbae/model/getnotificationmodel.dart';
import 'package:fanbae/model/successmodel.dart';
import 'package:fanbae/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:fanbae/webservice/apiservice.dart';

class NotificationProvider extends ChangeNotifier {
  GetNotificationModel getNotificationModel = GetNotificationModel();
  SuccessModel successModel = SuccessModel();
  int position = 0;
  bool isNotification = false;
  bool readnotificationloading = false;

  List<Result>? notificationList = [];
  bool loadmore = false, loading = false;
  int? totalRows, totalPage, currentPage;
  bool? isMorePage;

  // ⏱️ Rate limiting - prevent API spam
  DateTime? _lastNotificationRequestTime;
  static const Duration _minRequestInterval = Duration(seconds: 2);

  Future<void> getNotification(pageNo) async {
    // ⏱️ Prevent multiple simultaneous requests
    if (loading) {
      printLog(
          '⚠️ Notification request already in progress, skipping duplicate');
      return;
    }

    // ⏱️ Throttle requests - minimum 2 seconds between calls
    if (_lastNotificationRequestTime != null) {
      final timeSinceLastRequest =
          DateTime.now().difference(_lastNotificationRequestTime!);
      if (timeSinceLastRequest < _minRequestInterval) {
        printLog(
            '⏱️ Rate limited: Only ${timeSinceLastRequest.inMilliseconds}ms since last request');
        return;
      }
    }

    try {
      loading = true;
      notifyListeners();
      _lastNotificationRequestTime = DateTime.now();

      getNotificationModel = await ApiService().notification(pageNo);
      if (getNotificationModel.status == 200) {
        setPaginationData(
            getNotificationModel.totalRows,
            getNotificationModel.totalPage,
            getNotificationModel.currentPage,
            getNotificationModel.morePage);
        if (getNotificationModel.result != null &&
            (getNotificationModel.result?.length ?? 0) > 0) {
          printLog(
              "followingModel length :==> ${(getNotificationModel.result?.length ?? 0)}");
          printLog('Now on page ==========> $currentPage');
          if (getNotificationModel.result != null &&
              (getNotificationModel.result?.length ?? 0) > 0) {
            printLog(
                "followingModel length :==> ${(getNotificationModel.result?.length ?? 0)}");
            for (var i = 0;
                i < (getNotificationModel.result?.length ?? 0);
                i++) {
              notificationList
                  ?.add(getNotificationModel.result?[i] ?? Result());
            }
            final Map<int, Result> postMap = {};
            notificationList?.forEach((item) {
              postMap[item.id ?? 0] = item;
            });
            notificationList = postMap.values.toList();
            printLog(
                "followFollowingList length :==> ${(notificationList?.length ?? 0)}");
            setLoadMore(false);
          }
        }
      }
    } catch (e) {
      printLog('❌ Error fetching notifications: $e');
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  setPaginationData(
      int? totalRows, int? totalPage, int? currentPage, bool? morePage) {
    this.currentPage = currentPage;
    this.totalRows = totalRows;
    this.totalPage = totalPage;
    isMorePage = morePage;
    notifyListeners();
  }

  setLoadMore(loadmore) {
    this.loadmore = loadmore;
    notifyListeners();
  }

  getReadNotification(index, notificationId, isNotification) async {
    position = index;
    isNotification = isNotification;
    setReadNotificationLoading(true);
    successModel = await ApiService().readNotification(notificationId);
    setReadNotificationLoading(false);
    notificationList?.removeAt(index);
  }

  setReadNotificationLoading(isSending) {
    printLog("isSending ==> $isSending");
    readnotificationloading = isSending;
    notifyListeners();
  }

  clearProvider() {
    getNotificationModel = GetNotificationModel();
    loading = false;
    position = 0;
    notificationList = [];
    notificationList?.clear();
    loadmore = false;
    totalRows;
    totalPage;
    currentPage;
    isMorePage;
  }
}
