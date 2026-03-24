import 'dart:developer';
import 'package:fanbae/model/addcommentmodel.dart';
import 'package:fanbae/model/addcontenttohistorymodel.dart';
import 'package:fanbae/model/addremovelikedislikemodel.dart';
import 'package:fanbae/model/addremovesubscribemodel.dart';
import 'package:fanbae/model/addviewmodel.dart';
import 'package:fanbae/model/commentmodel.dart';
import 'package:fanbae/model/deletecommentmodel.dart';
import 'package:fanbae/model/download_item.dart';
import 'package:fanbae/model/profilemodel.dart';
import 'package:fanbae/model/relatedvideomodel.dart' as related;
import 'package:fanbae/model/relatedvideomodel.dart';
import 'package:fanbae/model/removecontenttohistorymodel.dart';
import 'package:fanbae/model/replaycommentmodel.dart' as replaycomment;
import 'package:fanbae/model/replaycommentmodel.dart';
import 'package:fanbae/utils/constant.dart';
import 'package:fanbae/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:fanbae/model/commentmodel.dart' as comment;
import 'package:fanbae/model/successmodel.dart';
import 'package:fanbae/model/detailmodel.dart';
import 'package:fanbae/webservice/apiservice.dart';
import 'package:hive/hive.dart';

class DetailsProvider extends ChangeNotifier {
  DetailsModel detailsModel = DetailsModel();
  ProfileModel profileModel = ProfileModel();
  AddCommentModel addCommentModel = AddCommentModel();
  SuccessModel likedislikemodel = SuccessModel();
  CommentModel getcommentModel = CommentModel();
  ReplayCommentModel replayCommentModel = ReplayCommentModel();
  AddViewModel addViewModel = AddViewModel();
  AddRemoveLikeDislikeModel addRemoveLikeDislikeModel =
      AddRemoveLikeDislikeModel();
  AddcontenttoHistoryModel addcontenttoHistoryModel =
      AddcontenttoHistoryModel();
  RemoveContentHistoryModel removeContentHistoryModel =
      RemoveContentHistoryModel();
  RelatedVideoModel relatedVideoModel = RelatedVideoModel();

  AddremoveSubscribeModel addremoveSubscribeModel = AddremoveSubscribeModel();
  DeleteCommentModel deleteCommentModel = DeleteCommentModel();
  bool loading = false;
  String commentId = "";
  bool deletecommentLoading = false;

  // Comment List Field Pagination
  int? totalRowsComment, totalPageComment, currentPageComment;
  bool? morePageComment;
  List<comment.Result>? commentList = [];
  bool commentloadmore = false, commentloading = false;

  // Add Comment & Add Replay Comment
  bool addcommentloading = false, addreplaycommentloading = false;

  // ReplayComment With Pagination
  int? totalRowsReplayComment, totalPageReplayComment, currentPageReplayComment;
  bool? morePageReplayComment;
  final Map<String, List<replaycomment.Result>> replaycommentList = {};
  Set<String> expandedReplies = {};
  bool replayCommentloadmore = false, replaycommentloding = false;

  /* RelatedVideo Field */
  List<related.Result>? relatedVideoList = [];
  bool relatedVideoLoadMore = false;
  int? relatedVideototalRows, relatedVideototalPage, relatedVideocurrentPage;
  bool? relatedVideoisMorePage;
  String? replyingToCommentId;

  String videoId = "";

  /* Store Video Id Using in Flutter Web */

  setLoading(loading) {
    this.loading = loading;
    notifyListeners();
  }

  storeVideoId(id) {
    videoId = id;
  }

  void clearReply() {
    replyingToCommentId = null;
    notifyListeners();
  }

  getvideodetails(contentid, contenttype, {bool? isLoad}) async {
    if (isLoad != false) {
      loading = true;
    }
    detailsModel = await ApiService().videodetails(contentid, contenttype);
    if (isLoad != false) {
      loading = false;
    }
    notifyListeners();
  }

  void toggleReplies(String commentId) {
    if (expandedReplies.contains(commentId)) {
      expandedReplies.remove(commentId);
    } else {
      expandedReplies.add(commentId);
      // fetch replies only if not already fetched
      getReplayComment(commentId, (0) + 1);
      setReplayCommentLoadMore(false);
    }
    notifyListeners();
  }

  bool isRepliesExpanded(String commentId) {
    return expandedReplies.contains(commentId);
  }

  getAddComment(contenttype, contentid, episodeid, comment, commentid) async {
    setSendingComment(true);
    addCommentModel = await ApiService()
        .addcomment(contenttype, contentid, episodeid, comment, commentid);
    setSendingComment(false);
    notifyListeners();
  }

  setSendingComment(isSending) {
    printLog("isSending ==> $isSending");
    addcommentloading = isSending;
    notifyListeners();
  }

  getaddReplayComment(
      contenttype, contentid, episodeid, comment, commentid) async {
    setSendingReplayComment(true);
    addCommentModel = await ApiService()
        .addcomment(contenttype, contentid, episodeid, comment, commentid);
    await getReplayComment(commentid, "0");
    setSendingReplayComment(false);
  }

  setSendingReplayComment(isSending) {
    printLog("isSending ==> $isSending");
    addreplaycommentloading = isSending;
    notifyListeners();
  }

/*  Comment Pagination Start */
  setCommentLoading(bool isLoading) {
    commentloading = isLoading;
    notifyListeners();
  }

  Future<void> getComment(contenttype, videoid, pageNo) async {
    printLog("getPostList pageNo :==> $pageNo");
    commentloading = true;
    getcommentModel =
        await ApiService().getcomment(contenttype, videoid, pageNo);
    printLog("getPostList status :===> ${getcommentModel.status}");
    printLog("getPostList message :==> ${getcommentModel.message}");
    if (getcommentModel.status == 200) {
      setCommentPaginationData(
          getcommentModel.totalRows,
          getcommentModel.totalPage,
          getcommentModel.currentPage,
          getcommentModel.morePage);
      if (getcommentModel.result != null &&
          (getcommentModel.result?.length ?? 0) > 0) {
        printLog(
            "postModel length :==> ${(getcommentModel.result?.length ?? 0)}");

        for (var i = 0; i < (getcommentModel.result?.length ?? 0); i++) {
          commentList?.add(getcommentModel.result?[i] ?? comment.Result());
        }
        final Map<int, comment.Result> postMap = {};
        commentList?.forEach((item) {
          postMap[item.id ?? 0] = item;
        });
        commentList = postMap.values.toList();
        printLog("shortVideoList length :==> ${(commentList?.length ?? 0)}");
        setCommentLoadMore(false);
      }
    }
    commentloading = false;
    notifyListeners();
  }

  setCommentPaginationData(int? totalRowsComment, int? totalPageComment,
      int? currentPageComment, bool? morePageComment) {
    this.currentPageComment = currentPageComment;
    this.totalRowsComment = totalRowsComment;
    this.totalPageComment = totalPageComment;
    morePageComment = morePageComment;
    notifyListeners();
  }

  setCommentLoadMore(commentloadmore) {
    this.commentloadmore = commentloadmore;
    notifyListeners();
  }

  clearComment() {
    getcommentModel = CommentModel();
    totalRowsComment;
    totalPageComment;
    currentPageComment;
    morePageComment;
    commentList = [];
    commentList?.clear();
    commentloadmore = false;
    commentloading = false;
    addreplaycommentloading = false;
  }

/*  Comment Pagination End */

/* Delete Comment And Replay Comment Both OF Delete */
  getDeleteComment(commentId) async {
    setDeletePlaylistLoading(true);
    deleteCommentModel = await ApiService().deleteComment(commentId);
    setDeletePlaylistLoading(false);
  }

  setDeletePlaylistLoading(isSending) {
    printLog("isSending ==> $isSending");
    deletecommentLoading = isSending;
    notifyListeners();
  }

/* Replay Comment Pagination Start */

  Future<void> getReplayComment(commentId, pageNo) async {
    replaycommentloding = true;
    notifyListeners();

    final replayCommentModel =
        await ApiService().replayComment(commentId, pageNo);

    if (replayCommentModel.status == 200) {
      if (replayCommentModel.result != null &&
          (replayCommentModel.result?.isNotEmpty ?? false)) {
        // Deduplicate replies by ID
        final Map<int, replaycomment.Result> postMap = {};
        for (var reply in replayCommentModel.result!) {
          postMap[reply.id ?? 0] = reply;
        }

        // Save under the correct parent comment
        replaycommentList[commentId] = postMap.values.toList();
      }
    }

    replaycommentloding = false;
    notifyListeners();
  }

  setReplayCommentPaginationData(
      int? totalRowsReplayComment,
      int? totalPageReplayComment,
      int? currentPageReplayComment,
      bool? morePageReplayComment) {
    this.currentPageReplayComment = currentPageReplayComment;
    this.totalRowsReplayComment = totalRowsReplayComment;
    this.totalPageReplayComment = totalPageReplayComment;
    morePageReplayComment = morePageReplayComment;
    notifyListeners();
  }

  setReplayCommentLoadMore(replayCommentloadmore) {
    this.replayCommentloadmore = replayCommentloadmore;
    notifyListeners();
  }

  clearReplayComment() {
    replayCommentModel = ReplayCommentModel();
    totalRowsReplayComment;
    totalPageReplayComment;
    currentPageReplayComment;
    morePageReplayComment;
    /* replaycommentList = [];*/
    replaycommentList.clear();
    replayCommentloadmore = false;
    replaycommentloding = false;
  }

  List<replaycomment.Result> getReplies(String commentId) {
    return replaycommentList[commentId] ?? [];
  }

  void deleteReply(String commentId, int replyId) {
    replaycommentList[commentId]?.removeWhere((item) => item.id == replyId);
    notifyListeners();
  }

/* Replay Comment Pagination End */

  addremoveSubscribe(touserid, type) {
    if ((detailsModel.result?[0].isSubscribe ?? 0) == 0) {
      detailsModel.result?[0].isSubscribe = 1;
      detailsModel.result?[0].totalSubscriber =
          (detailsModel.result?[0].totalSubscriber ?? 0) + 1;
    } else {
      detailsModel.result?[0].isSubscribe = 0;
      if ((detailsModel.result?[0].totalSubscriber ?? 0) > 0) {
        detailsModel.result?[0].totalSubscriber =
            (detailsModel.result?[0].totalSubscriber ?? 0) - 1;
      }
    }
    notifyListeners();
    getaddremoveSubscribe(touserid, type);
  }

  Future<void> getaddremoveSubscribe(touserid, type) async {
    addremoveSubscribeModel =
        await ApiService().addremoveSubscribe(touserid, type);
  }

  Future<void> addVideoView(contenttype, contentid) async {
    printLog("addPostView postId :==> $contentid");
    loading = true;
    addViewModel = await ApiService().addView(contenttype, contentid);
    printLog("addPostView status :==> ${addViewModel.status}");
    printLog("addPostView message :==> ${addViewModel.message}");
    loading = false;
  }

  like(contenttype, contentid, status, episodeId) {
    if ((detailsModel.result?[0].isUserLikeDislike ?? 0) == 0) {
      detailsModel.result?[0].isUserLikeDislike = 1;
      detailsModel.result?[0].totalLike =
          (detailsModel.result?[0].totalLike ?? 0) + 1;
    } else if ((detailsModel.result?[0].isUserLikeDislike ?? 0) == 2) {
      detailsModel.result?[0].isUserLikeDislike = 1;
      detailsModel.result?[0].totalLike =
          (detailsModel.result?[0].totalLike ?? 0) + 1;
      if ((detailsModel.result?[0].totalDislike ?? 0) > 0) {
        detailsModel.result?[0].totalDislike =
            (detailsModel.result?[0].totalDislike ?? 0) - 1;
      }
    } else {
      detailsModel.result?[0].isUserLikeDislike = 0;
      if ((detailsModel.result?[0].totalLike ?? 0) > 0) {
        detailsModel.result?[0].totalLike =
            (detailsModel.result?[0].totalLike ?? 0) - 1;
      }
    }
    notifyListeners();
    addLikeDislike(contenttype, contentid, status, episodeId);
  }

  dislike(contenttype, contentid, status, episodeId) {
    if ((detailsModel.result?[0].isUserLikeDislike ?? 0) == 0) {
      detailsModel.result?[0].isUserLikeDislike = 2;
      detailsModel.result?[0].totalDislike =
          (detailsModel.result?[0].totalDislike ?? 0) + 1;
    } else if ((detailsModel.result?[0].isUserLikeDislike ?? 0) == 1) {
      detailsModel.result?[0].isUserLikeDislike = 2;
      detailsModel.result?[0].totalDislike =
          (detailsModel.result?[0].totalDislike ?? 0) + 1;
      if ((detailsModel.result?[0].totalLike ?? 0) > 0) {
        detailsModel.result?[0].totalLike =
            (detailsModel.result?[0].totalLike ?? 0) - 1;
      }
    } else {
      detailsModel.result?[0].isUserLikeDislike = 0;
      if ((detailsModel.result?[0].totalDislike ?? 0) > 0) {
        detailsModel.result?[0].totalDislike =
            (detailsModel.result?[0].totalDislike ?? 0) - 1;
      }
    }
    notifyListeners();
    addLikeDislike(contenttype, contentid, status, episodeId);
  }

  Future<void> addLikeDislike(contenttype, contentid, status, episodeId) async {
    printLog("addLikeDislike postId :==> $contentid");
    addRemoveLikeDislikeModel = await ApiService()
        .addRemoveLikeDislike(contenttype, contentid, status, episodeId);
    printLog("addLikeDislike status :==> ${addRemoveLikeDislikeModel.status}");
    printLog(
        "addLikeDislike message :==> ${addRemoveLikeDislikeModel.message}");
  }

  Future<void> addContentHistory(
      contenttype, contentid, stoptime, episodeid) async {
    loading = true;
    addcontenttoHistoryModel = await ApiService()
        .addContentToHistory(contenttype, contentid, stoptime, episodeid);
    loading = false;
  }

  Future<void> removeContentHistory(contenttype, contentid, episodeid) async {
    loading = true;
    removeContentHistoryModel = await ApiService()
        .removeContentToHistory(contenttype, contentid, episodeid);
    loading = false;
  }

  storeReplayCommentId(iscommentId) async {
    commentId = iscommentId;
    replyingToCommentId = iscommentId;
    log("Comment ID ==> $commentId");
    notifyListeners();
  }

/* Related Videos Start */

  Future<void> getRelatedVideo(contentId, pageNo) async {
    loading = true;
    relatedVideoList = [];
    relatedVideoModel = await ApiService().relatedVideo(contentId, pageNo);
    if (relatedVideoModel.status == 200) {
      setRelatedPaginationData(
          relatedVideoModel.totalRows,
          relatedVideoModel.totalPage,
          relatedVideoModel.currentPage,
          relatedVideoModel.morePage);
      if (relatedVideoModel.result != null &&
          (relatedVideoModel.result?.length ?? 0) > 0) {
        printLog(
            "RelatedVideo Model length :==> ${(relatedVideoModel.result?.length ?? 0)}");
        if (relatedVideoModel.result != null &&
            (relatedVideoModel.result?.length ?? 0) > 0) {
          printLog(
              "RelatedVideo Model length :==> ${(relatedVideoModel.result?.length ?? 0)}");
          for (var i = 0; i < (relatedVideoModel.result?.length ?? 0); i++) {
            relatedVideoList
                ?.add(relatedVideoModel.result?[i] ?? related.Result());
          }
          final Map<int, related.Result> postMap = {};
          relatedVideoList?.forEach((item) {
            postMap[item.id ?? 0] = item;
          });
          relatedVideoList = postMap.values.toList();
          setRelatedLoadMore(false);
        }
      }
    }
    loading = false;
    notifyListeners();
  }

  setRelatedPaginationData(
      int? relatedVideototalRows,
      int? relatedVideototalPage,
      int? relatedVideocurrentPage,
      bool? relatedVideoisMorePage) {
    this.relatedVideocurrentPage = relatedVideocurrentPage;
    this.relatedVideototalRows = relatedVideototalRows;
    this.relatedVideototalPage = relatedVideototalPage;
    relatedVideoisMorePage = relatedVideoisMorePage;
    notifyListeners();
  }

  setRelatedLoadMore(relatedVideoLoadMore) {
    this.relatedVideoLoadMore = relatedVideoLoadMore;
    notifyListeners();
  }

/* Related Videos End */

/* Web Uses */
/* Open Replay Comment textField */
  int? commentIndex;
  bool isCommentReplay = false;
  openReplayCommentTextField(index, isClick) {
    commentIndex = index;
    isCommentReplay = isClick;
    notifyListeners();
  }

/* Open Replaycomment Section For Perticuler Comment */
  int? commentPosition;
  bool isShowReplaycomment = false;
  showReplaycomment(position, isShow) {
    commentPosition = position;
    isShowReplaycomment = isShow;
    notifyListeners();
  }

  Future<void> addRemoveDownload(BuildContext context, videoId) async {
    printLog("addRemoveDownload videoId :=======> $videoId");
    /* Remove from Hive */
    late Box<DownloadItem> downloadBox;
    if (Constant.userID != null) {
      downloadBox = Hive.box<DownloadItem>(
          '${Constant.hiveDownloadBox}_${Constant.userID}');
    } else {
      downloadBox = Hive.box<DownloadItem>(Constant.hiveDownloadBox);
    }
    printLog(
        "downloadBox length :========> ${downloadBox.values.toList().length}");
    if (downloadBox.values.toList().isNotEmpty) {
      printLog(
          "downloadBox indexWhere =====> ${downloadBox.values.toList().indexWhere((downloadItem) => (downloadItem.id == videoId))}");
      await downloadBox
          .delete(downloadBox.values.toList().indexWhere((downloadItem) {
        printLog("downloadBox videoId :=======> ${downloadItem.id}");
        return (downloadItem.id == videoId);
      }));
      if (downloadBox.values.toList().isEmpty) {
        downloadBox.clear();
      }
    } else {
      downloadBox.clear();
    }
    if (context.mounted) {
      Utils().showSnackBar(context, "download_remove_success", true);
    }
    notifyListeners();
    /* Remove from Hive */
  }

  clearProvider() {
    detailsModel = DetailsModel();
    addCommentModel = AddCommentModel();
    addcontenttoHistoryModel = AddcontenttoHistoryModel();
    likedislikemodel = SuccessModel();
    addremoveSubscribeModel = AddremoveSubscribeModel();
    getcommentModel = CommentModel();
    replayCommentModel = ReplayCommentModel();
    totalRowsComment;
    totalPageComment;
    currentPageComment;
    morePageComment;
    commentList = [];
    commentList?.clear();
    addcommentloading = false;
    commentloadmore = false;
    addreplaycommentloading = false;
    loading = false;
    deletecommentLoading = false;
    videoId = "";
    commentIndex;
    isCommentReplay = false;
    commentPosition;
    isShowReplaycomment = false;
  }
}
