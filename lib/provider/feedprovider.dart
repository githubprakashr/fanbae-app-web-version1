import 'package:flutter/material.dart';
import 'package:fanbae/model/addcommentmodel.dart';
import 'package:fanbae/model/addcontentreportmodel.dart';
import 'package:fanbae/model/addremovelikedislikemodel.dart';
import 'package:fanbae/model/addremovesubscribemodel.dart';
import 'package:fanbae/model/getpostcommentmodel.dart' as comment;
import 'package:fanbae/model/getpostcommentmodel.dart' as replaycomment;
import 'package:fanbae/model/getreportreasonmodel.dart' as report;
import 'package:fanbae/model/postmodel.dart' as feedpost;
import 'package:fanbae/model/categorymodel.dart' as category;
import 'package:fanbae/model/successmodel.dart';
import 'package:fanbae/utils/utils.dart';
import 'package:fanbae/webservice/apiservice.dart';
import 'package:fanbae/model/feedslistmodel.dart' as feed;

import '../model/addremovewatchlatermodel.dart';

class FeedProvider extends ChangeNotifier {
  /* Get All Feed  */
  feedpost.PostModel postModel = feedpost.PostModel();
  feed.FeedsListModel feedModel = feed.FeedsListModel();
  int? totalRows, totalPage, currentPage;
  bool? isMorePage;
  List<feedpost.Result>? feedPostList = [];
  List<feed.Result>? feeds = [];
  List filters = [
    "All",
    "Video",
    "Live",
    "Post",
  ];
  String selectedFilter = "All";
  bool isShowFilter = false;
  bool loading = false, loadMore = false;
  TextEditingController searchController = TextEditingController();
  bool isShowSearch = false;
  AddremoveWatchlaterModel addremoveWatchlaterModel =
      AddremoveWatchlaterModel();

  /* Add Remove Subscriber */
  AddremoveSubscribeModel addremoveSubscribeModel = AddremoveSubscribeModel();

  /* Add Remove Like Dislike */
  AddRemoveLikeDislikeModel addRemoveLikeDislikeModel =
      AddRemoveLikeDislikeModel();

  /* AddPostComment Model */
  AddCommentModel addPostCommentModel = AddCommentModel();

  bool addCommentLoading = false;
  String? postId, commentId;

  /* Get PostComment */
  comment.GetPostCommentModel getPostCommentModel =
      comment.GetPostCommentModel();

  int? commenttotalRows, commenttotalPage, commentcurrentPage;
  bool? commentisMorePage;
  List<comment.Result>? commentList = [];
  bool commentloading = false, commentloadMore = false;

  /* Get Post ReplayComment */
  replaycomment.GetPostCommentModel getPostReplayCommentModel =
      replaycomment.GetPostCommentModel();
  int? replayCommenttotalRows, replayCommenttotalPage, replayCommentcurrentPage;
  bool? replayCommentisMorePage;

  // List<replaycomment.Result>? replayCommentList = [];
  final Map<String, List<replaycomment.Result>> replaycommentList = {};
  bool replayCommentloading = false, replayCommentloadMore = false;

  /* Delete Post Comment */
  SuccessModel successModel = SuccessModel();

  /* Report Reason List Field */
  report.GetRepostReasonModel getRepostReasonModel =
      report.GetRepostReasonModel();
  int? reporttotalRows, reporttotalPage, reportcurrentPage;
  bool? reportmorePage;
  List<report.Result>? reportReasonList = [];
  bool getcontentreportloading = false, getcontentreportloadmore = false;
  String? reason;
  int? reportPosition = 0;

  /* Add Report Reason */
  AddContentReportModel addContentReportModel = AddContentReportModel();

  /* Category List */
  category.CategoryModel categorymodel = category.CategoryModel();
  List<category.Result>? categorydataList = [];
  bool categoryloadMore = false, categoryloading = false;
  int? categorytotalRows, categorytotalPage, categorycurrentPage;
  bool? categoryisMorePage;
  bool uploadLoading = false;
  int catindex = 0;
  String? categoryId;
  String? replyingToCommentId;
  Set<String> expandedReplies = {};

  storeReplayCommentId(iscommentId) async {
    replyingToCommentId = iscommentId;
    notifyListeners();
  }

  List<replaycomment.Result> getReplies(String commentId) {
    return replaycommentList[commentId] ?? [];
  }

  void deleteReply(String commentId, int replyId) {
    replaycommentList[commentId]?.removeWhere((item) => item.id == replyId);
    notifyListeners();
  }

  void toggleReplies(String commentId) {
    if (expandedReplies.contains(commentId)) {
      expandedReplies.remove(commentId);
    } else {
      expandedReplies.add(commentId);
      // fetch replies only if not already fetched
      getPostReplayComment(commentId, (0) + 1);
      setReplayCommentLoadMore(false);
    }
    notifyListeners();
  }

  bool isRepliesExpanded(String commentId) {
    return expandedReplies.contains(commentId);
  }

  void clearReply() {
    replyingToCommentId = null;
    notifyListeners();
  }

  setLoading(bool isLoading) {
    categoryloading = isLoading;
    loading = isLoading;
    notifyListeners();
  }

  /* ================================== Get All Feeds Start ================================== */
  addremoveWatchLater(contenttype, contentid, episodeid, type) async {
    addremoveWatchlaterModel = await ApiService()
        .addremoveWatchLater(contenttype, contentid, episodeid, type);
    notifyListeners();
  }

  Future<void> getAllFeed(pageNo) async {
    loading = true;
    postModel = await ApiService().getFeedPost(pageNo);
    if (postModel.status == 200) {
      setPaginationData(postModel.totalRows, postModel.totalPage,
          postModel.currentPage, postModel.morePage);
      if (postModel.result != null && (postModel.result?.length ?? 0) > 0) {
        printLog("FeedModel length :==> ${(postModel.result?.length ?? 0)}");
        if (postModel.result != null && (postModel.result?.length ?? 0) > 0) {
          printLog("FeedModel length :==> ${(postModel.result?.length ?? 0)}");
          for (var i = 0; i < (postModel.result?.length ?? 0); i++) {
            feedPostList?.add(postModel.result?[i] ?? feedpost.Result());
          }
          final Map<int, feedpost.Result> postMap = {};
          feedPostList?.forEach((item) {
            postMap[item.id ?? 0] = item;
          });
          feedPostList = postMap.values.toList();
          printLog("FeedList length :==> ${(feedPostList?.length ?? 0)}");
          setLoadMore(false);
        }
      }
    }
    loading = false;
    notifyListeners();
  }

  Future<void> getFeeds(viewType) async {
    loading = true;
    notifyListeners();

    feedModel = await ApiService().getFeedList(viewType);
    print('feeds : ${feedModel.status}');

    if (feedModel.status == 200) {
      if (feedModel.result != null && feedModel.result!.isNotEmpty) {
        List<feed.Result>? filtered = [];
        if (selectedFilter == "All") {
          filtered = feedModel.result;
        } else if (selectedFilter == "Video") {
          filtered = feedModel.result!
              .where((item) => item.feedType?.toLowerCase() == 'video')
              .toList();
        } else if (selectedFilter == "Music") {
          filtered = feedModel.result!
              .where((item) => item.feedType?.toLowerCase() == 'music')
              .toList();
        } else if (selectedFilter == "Podcast") {
          filtered = feedModel.result!
              .where((item) => item.feedType?.toLowerCase() == 'podcasts')
              .toList();
        } else if (selectedFilter == "Post") {
          filtered = feedModel.result!
              .where((item) => item.feedType?.toLowerCase() == 'post')
              .toList();
        } else {
          filtered = feedModel.result!
              .where((item) => item.feedType?.toLowerCase() == 'live')
              .toList();
        }
        if (searchController.text.isNotEmpty) {
          filtered = filtered
              ?.where((item) =>
                  item.title
                      ?.toLowerCase()
                      .contains(searchController.text.toLowerCase()) ??
                  false)
              .toList();
        }

        feeds = filtered;
      } else {
        feeds = []; // Clear if no results
      }
    } else {
      feeds = [];
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

  clearAllPost() {
    postModel = feedpost.PostModel();
    totalRows;
    totalPage;
    currentPage;
    isMorePage;
    feedPostList = [];
    feedPostList?.clear();
    loading = false;
    loadMore = false;
  }

  /* ================================== Get All Feeds End ================================== */

  /* ================================== Add Remove Subscriber's ================================== */

  addRemoveSubscriber(index, touserid, type) {
    if ((feeds?[index].isSubscriber ?? 0) == 0) {
      feeds?[index].isSubscriber = 1;
    } else {
      feeds?[index].isSubscriber = 0;
    }
    notifyListeners();
    getaddremoveSubscribe(touserid, type);
  }

  Future<void> getaddremoveSubscribe(touserid, type) async {
    addremoveSubscribeModel =
        await ApiService().addremoveSubscribe(touserid, type);
  }

  profileAddRemoveSubscription(touserid, type) async {
    for (var i = 0; i < (feedPostList?.length ?? 0); i++) {
      if (feedPostList?[i].userId.toString() == touserid.toString()) {
        if ((feedPostList?[i].isSubscriber ?? 0) == 0) {
          feedPostList?[i].isSubscriber = 1;
        } else {
          feedPostList?[i].isSubscriber = 0;
        }
      }
    }

    notifyListeners();
    await getaddremoveSubscribe(touserid, type);
  }

  /* ================================== Add Remove Subscriber's ================================== */

  /* ==================================== Like Post Start ======================================== */

  like(postIndex, postId) {
    if ((feeds?[postIndex].isLike ?? 0) == 0) {
      feeds?[postIndex].isLike = 1;
      feeds?[postIndex].totalLike = (feeds?[postIndex].totalLike ?? 0) + 1;
    } else {
      feeds?[postIndex].isLike = 0;
      if ((feeds?[postIndex].totalLike ?? 0) > 0) {
        feeds?[postIndex].totalLike = (feeds?[postIndex].totalLike ?? 0) - 1;
      }
    }
    notifyListeners();
    addlikeUnlike(postId);
  }

  Future<void> addlikeUnlike(postId) async {
    addRemoveLikeDislikeModel = await ApiService().likeUnlikePost(postId);
    printLog("addLikeDislike status :==> ${addRemoveLikeDislikeModel.status}");
    printLog(
        "addLikeDislike message :==> ${addRemoveLikeDislikeModel.message}");
  }

  /* ================================== Like Post End ================================== */

  /* ================================== Add Comment Post Start ================================== */

  addPostComment(position, postid, comment, int commentid) async {
    setSendingComment(true);
    addPostCommentModel =
        await ApiService().addPostComment(postid, comment, commentid);
    setSendingComment(true);
    feeds?[position].totalComment = (feeds?[position].totalComment ?? 0) + 1;
    notifyListeners();
  }

  setSendingComment(isSending) {
    addCommentLoading = isSending;
    notifyListeners();
  }

  storeCommentId(postid, commentid) {
    postId = postid;
    commentId = commentid;
    notifyListeners();
  }

  /* ================================== Add Comment Post End ==================================== */

  /* ================================== Get Comment Post Start ==================================== */

  Future<void> getPostComment(postId, pageNo) async {
    commentloading = true;
    getPostCommentModel = await ApiService().getPostComment(postId, pageNo);
    if (getPostCommentModel.status == 200) {
      setCommentPaginationData(
          getPostCommentModel.totalRows,
          getPostCommentModel.totalPage,
          getPostCommentModel.currentPage,
          getPostCommentModel.morePage);
      if (getPostCommentModel.result != null &&
          (getPostCommentModel.result?.length ?? 0) > 0) {
        printLog(
            "CommentModel length :==> ${(getPostCommentModel.result?.length ?? 0)}");
        if (getPostCommentModel.result != null &&
            (getPostCommentModel.result?.length ?? 0) > 0) {
          printLog(
              "CommentModel length :==> ${(getPostCommentModel.result?.length ?? 0)}");
          for (var i = 0; i < (getPostCommentModel.result?.length ?? 0); i++) {
            commentList
                ?.add(getPostCommentModel.result?[i] ?? comment.Result());
          }
          final Map<int, comment.Result> postMap = {};
          commentList?.forEach((item) {
            postMap[item.id ?? 0] = item;
          });
          commentList = postMap.values.toList();
          printLog("CommentList length :==> ${(commentList?.length ?? 0)}");
          setLoadMore(false);
        }
      }
    }
    commentloading = false;
    notifyListeners();
  }

  setCommentPaginationData(int? commenttotalRows, int? commenttotalPage,
      int? commentcurrentPage, bool? commentmorePage) {
    this.commentcurrentPage = commentcurrentPage;
    this.commenttotalRows = commenttotalRows;
    this.commenttotalPage = commenttotalPage;
    commentmorePage = commentmorePage;
    notifyListeners();
  }

  setCommentLoadMore(commentloadMore) {
    this.commentloadMore = commentloadMore;
    notifyListeners();
  }

  clearComment() {
    /* Get PostComment */
    getPostCommentModel = comment.GetPostCommentModel();
    commenttotalRows;
    commenttotalPage;
    commentcurrentPage;
    commentisMorePage;
    commentList = [];
    commentList?.clear();
    commentloading = false;
    commentloadMore = false;
    addCommentLoading = false;
  }

  /* ================================== Get Comment Post End ==================================== */

  /* ================================== Get ReplayComment Post Start ==================================== */

  Future<void> getPostReplayComment(commentId, pageNo) async {
    replayCommentloading = true;
    getPostReplayCommentModel =
        await ApiService().getPostReplayComment(commentId, pageNo);

    if (getPostReplayCommentModel.status == 200) {
      setReplayCommentPaginationData(
        getPostReplayCommentModel.totalRows,
        getPostReplayCommentModel.totalPage,
        getPostReplayCommentModel.currentPage,
        getPostReplayCommentModel.morePage,
      );

      final results = getPostReplayCommentModel.result ?? [];

      if (results.isNotEmpty) {
        printLog("ReplayCommentModel length :==> ${results.length}");

        // Ensure a list exists for this commentId
        replaycommentList[commentId.toString()] ??= [];

        // Add new replies into the list
        replaycommentList[commentId.toString()]!.addAll(results);

        // Deduplicate replies by id inside this commentId list
        final Map<int, replaycomment.Result> uniqueMap = {};
        for (var item in replaycommentList[commentId.toString()]!) {
          if (item.id != null) {
            uniqueMap[item.id!] = item;
          }
        }

        replaycommentList[commentId.toString()] = uniqueMap.values.toList();

        printLog(
            "Replies for commentId $commentId length :==> ${replaycommentList[commentId.toString()]?.length}");
        setReplayCommentLoadMore(false);
      }
    }

    replayCommentloading = false;
    notifyListeners();
  }

  setReplayCommentPaginationData(
      int? replayCommenttotalRows,
      int? replayCommenttotalPage,
      int? replayCommentcurrentPage,
      bool? replayCommentisMorePage) {
    this.replayCommentcurrentPage = replayCommentcurrentPage;
    this.replayCommenttotalRows = replayCommenttotalRows;
    this.replayCommenttotalPage = replayCommenttotalPage;
    replayCommentisMorePage = replayCommentisMorePage;
    notifyListeners();
  }

  setReplayCommentLoadMore(replayCommentloadMore) {
    this.replayCommentloadMore = replayCommentloadMore;
    notifyListeners();
  }

  clearReplayComment() {
    getPostReplayCommentModel = replaycomment.GetPostCommentModel();
    replayCommenttotalRows;
    replayCommenttotalPage;
    replayCommentcurrentPage;
    replayCommentisMorePage;
    /* replayCommentList = [];
    replayCommentList?.clear();*/
    replayCommentloading = false;
    replayCommentloadMore = false;
    addCommentLoading = false;
  }

  /* ================================== Get ReplayComment Post End ==================================== */

  /* ================================== Delete Comment Start ==================================== */

  postDeleteComment(position, commentId) async {
    successModel = await ApiService().postDeleteComment(commentId);
    if ((feeds?[position].totalComment ?? 0) > 0) {
      feeds?[position].totalComment = (feeds?[position].totalComment ?? 0) - 1;
    }
    notifyListeners();
  }

  /* ================================== Delete Comment End ==================================== */

  /* ================================== Report Reason List ================================== */

  Future<void> getReportReason(type, pageNo) async {
    getcontentreportloading = true;
    getRepostReasonModel = await ApiService().reportReason(type, pageNo);
    printLog("getPostList status :===> ${getRepostReasonModel.status}");
    printLog("getPostList message :==> ${getRepostReasonModel.message}");
    if (getRepostReasonModel.status == 200) {
      setReportReasonPaginationData(
          getRepostReasonModel.totalRows,
          getRepostReasonModel.totalPage,
          getRepostReasonModel.currentPage,
          getRepostReasonModel.morePage);
      if (getRepostReasonModel.result != null &&
          (getRepostReasonModel.result?.length ?? 0) > 0) {
        printLog(
            "postModel length first:==> ${(getRepostReasonModel.result?.length ?? 0)}");

        printLog(
            "postModel length :==> ${(getRepostReasonModel.result?.length ?? 0)}");

        for (var i = 0; i < (getRepostReasonModel.result?.length ?? 0); i++) {
          reportReasonList
              ?.add(getRepostReasonModel.result?[i] ?? report.Result());
        }
        final Map<int, report.Result> postMap = {};
        reportReasonList?.forEach((item) {
          postMap[item.id ?? 0] = item;
        });
        reportReasonList = postMap.values.toList();
        printLog(
            "Report Reason length :==> ${(reportReasonList?.length ?? 0)}");
        setReportReasonLoadMore(false);
      }
    } else {
      printLog("else Api");
    }
    getcontentreportloading = false;
    notifyListeners();
  }

  setReportReasonPaginationData(int? reporttotalRows, int? reporttotalPage,
      int? reportcurrentPage, bool? reportmorePage) {
    this.reportcurrentPage = reportcurrentPage;
    this.reporttotalRows = reporttotalRows;
    this.reporttotalPage = reporttotalPage;
    reportmorePage = reportmorePage;
    notifyListeners();
  }

  setReportReasonLoadMore(getcontentreportloadmore) {
    this.getcontentreportloadmore = getcontentreportloadmore;
    notifyListeners();
  }

  selectReportReason(int index, reasonMessage) {
    reportPosition = index;
    reason = reasonMessage;
    notifyListeners();
  }

  clearReportReason() {
    getRepostReasonModel = report.GetRepostReasonModel();
    reporttotalRows;
    reporttotalPage;
    reportcurrentPage;
    reportmorePage;
    reportReasonList = [];
    reportReasonList?.clear();
    getcontentreportloading = false;
    getcontentreportloadmore = false;
    reason;
    reportPosition = 0;
  }

  Future<void> addPostReason(postId, reason) async {
    addContentReportModel = await ApiService().addPostReport(postId, reason);
    loading = false;
  }

  /* ================================== Report Reason ================================== */
  /* ================================== Category ================================== */

  /* CategoryList Api Start */

  Future<void> getCategory(pageNo) async {
    categoryloading = true;
    categorymodel = await ApiService().videoCategory(pageNo);
    if (categorymodel.status == 200) {
      setCategoryPaginationData(
          categorymodel.totalRows,
          categorymodel.totalPage,
          categorymodel.currentPage,
          categorymodel.morePage);
      if (categorymodel.result != null &&
          (categorymodel.result?.length ?? 0) > 0) {
        printLog(
            "CategoryModel length :==> ${(categorymodel.result?.length ?? 0)}");
        printLog('Now on page ==========> $categorycurrentPage');
        if (categorymodel.result != null &&
            (categorymodel.result?.length ?? 0) > 0) {
          printLog(
              "CategoryModel length :==> ${(categorymodel.result?.length ?? 0)}");
          for (var i = 0; i < (categorymodel.result?.length ?? 0); i++) {
            categorydataList?.add(category.Result(id: 0, name: "Home"));
            categorydataList
                ?.add(categorymodel.result?[i] ?? category.Result());
          }
          final Map<int, category.Result> postMap = {};
          categorydataList?.forEach((item) {
            postMap[item.id ?? 0] = item;
          });
          categorydataList = postMap.values.toList();
          printLog(
              "CategoryList length :==> ${(categorydataList?.length ?? 0)}");
          setCategoryLoadMore(false);
        }
      }
    }
    categoryloading = false;
    notifyListeners();
  }

  setCategoryPaginationData(int? categorytotalRows, int? categorytotalPage,
      int? categorycurrentPage, bool? videolistisMorePage) {
    this.categorycurrentPage = categorycurrentPage;
    this.categorytotalRows = categorytotalRows;
    this.categorytotalPage = categorytotalPage;
    categoryisMorePage = categoryisMorePage;
    notifyListeners();
  }

  setCategoryLoadMore(categoryloadMore) {
    this.categoryloadMore = categoryloadMore;
    notifyListeners();
  }

  selectCategory(int index, catid) {
    catindex = index;
    categoryId = catid;
    notifyListeners();
  }

/* CategoryList Api End */

  /* ================================== Category ================================== */

  clearProvider() {
    /* Get All Feed  */
    postModel = feedpost.PostModel();
    addremoveWatchlaterModel = AddremoveWatchlaterModel();
    totalRows;
    totalPage;
    currentPage;
    isMorePage;
    feedPostList = [];
    feedPostList?.clear();
    loading = false;
    loadMore = false;
    selectedFilter = "All";
    searchController.clear();
    isShowSearch = false;
    isShowFilter = false;
    /* Add Remove Subscriber */
    addremoveSubscribeModel = AddremoveSubscribeModel();
    /* Add Remove Like Dislike */
    addRemoveLikeDislikeModel = AddRemoveLikeDislikeModel();
    /* AddPostComment Model */
    addPostCommentModel = AddCommentModel();
    addCommentLoading = false;
    postId;
    /* Get PostComment */
    getPostCommentModel = comment.GetPostCommentModel();
    commenttotalRows;
    commenttotalPage;
    commentcurrentPage;
    commentisMorePage;
    commentList = [];
    commentList?.clear();
    commentloading = false;
    commentloadMore = false;

    getPostReplayCommentModel = replaycomment.GetPostCommentModel();
    replayCommenttotalRows;
    replayCommenttotalPage;
    replayCommentcurrentPage;
    replayCommentisMorePage;
    /*replayCommentList = [];
    replayCommentList?.clear();*/
    replayCommentloading = false;
    replayCommentloadMore = false;

    /* Delete Post Comment */
    successModel = SuccessModel();

    /* Report Reason List Field */
    getRepostReasonModel = report.GetRepostReasonModel();
    reporttotalRows;
    reporttotalPage;
    reportcurrentPage;
    reportmorePage;
    reportReasonList = [];
    reportReasonList?.clear();
    getcontentreportloading = false;
    getcontentreportloadmore = false;
    reason;
    reportPosition = 0;

    /* Add Report Reason */
    addContentReportModel = AddContentReportModel();

    /* Category List */
    categorymodel = category.CategoryModel();
    categorydataList = [];
    categorydataList?.clear();
    categoryloadMore = false;
    categoryloading = false;
    categorytotalRows;
    categorytotalPage;
    categorycurrentPage;
    categoryisMorePage;
    uploadLoading = false;
    catindex = 0;
    categoryId;
  }
}
