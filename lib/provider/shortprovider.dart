import 'package:fanbae/model/addcommentmodel.dart';
import 'package:fanbae/model/addcontentreportmodel.dart';
import 'package:fanbae/model/addremovecontenttoplaylistmodel.dart';
import 'package:fanbae/model/addremovelikedislikemodel.dart';
import 'package:fanbae/model/addremovesubscribemodel.dart';
import 'package:fanbae/model/addremovewatchlatermodel.dart';
import 'package:fanbae/model/commentmodel.dart' as comment;
import 'package:fanbae/model/commentmodel.dart';
import 'package:fanbae/model/deletecommentmodel.dart';
import 'package:fanbae/model/getcontentbychannelmodel.dart' as usercontent;
import 'package:fanbae/model/getcontentbychannelmodel.dart';
import 'package:fanbae/model/getreportreasonmodel.dart' as report;
import 'package:fanbae/model/getreportreasonmodel.dart';
import 'package:fanbae/model/replaycommentmodel.dart' as replaycomment;
import 'package:fanbae/model/replaycommentmodel.dart';
import 'package:fanbae/model/shortmodel.dart' as shortlist;
import 'package:fanbae/model/watchlatermodel.dart' as watchlatershort;
import 'package:fanbae/model/watchlatermodel.dart';
import 'package:fanbae/utils/utils.dart';
import 'package:fanbae/webservice/apiservice.dart';
import 'package:flutter/material.dart';
import '../model/shortmodel.dart';

class ShortProvider extends ChangeNotifier {
  ShortModel shortModel = ShortModel();
  CommentModel getcommentModel = CommentModel();
  AddCommentModel addCommentModel = AddCommentModel();
  AddRemoveLikeDislikeModel addRemoveLikeDislikeModel =
      AddRemoveLikeDislikeModel();
  DeleteCommentModel deleteCommentModel = DeleteCommentModel();
  AddremoveSubscribeModel addremoveSubscribeModel = AddremoveSubscribeModel();
  GetWatchlaterModel watchlaterModel = GetWatchlaterModel();

  bool loading = false;
  int catindex = 0;
  int position = 0;

  /* All Short Field */
  List<shortlist.Result>? shortVideoList = [];

  int? totalRows, totalPage, currentPage;
  bool? morePage;

  /* Perticular User Short Field */
  List<usercontent.Result>? profileShortList = [];
  Set<String> expandedReplies = {};

  int? profileShorttotalRows, profileShorttotalPage, profileShortcurrentPage;
  bool? userShortmorePage;

  /* WatchLater Short Field */
  List<watchlatershort.Result>? watchlaterShortList = [];
  int? watchlaterShorttotalRows,
      watchlaterShorttotalPage,
      watchlaterShortcurrentPage;
  bool? watchlaterShortmorePage;

  /* Get Comment Field */
  int? totalRowsComment, totalPageComment, currentPageComment;
  bool? morePageComment;
  List<comment.Result>? commentList = [];
  bool commentloading = false, commentLoadmore = false;
  bool addreplaycommentloading = false;
  bool addcommentloading = false;
  int deleteItemIndex = 0;
  bool deletecommentLoading = false;
  TextEditingController searchController = TextEditingController();
  bool isShowSearch = false;

  /* Report Reason Field */
  int? reporttotalRows, reporttotalPage, reportcurrentPage;
  bool? reportmorePage;
  List<report.Result>? reportReasonList = [];
  bool getcontentreportloading = false, getcontentreportloadmore = false;
  int? reportposition = 0;
  bool isSelectReason = false;
  String reasonId = "";

  GetRepostReasonModel getRepostReasonModel = GetRepostReasonModel();
  AddContentReportModel addContentReportModel = AddContentReportModel();
  bool addcontentreortloading = false;

  ReplayCommentModel replayCommentModel = ReplayCommentModel();

  AddremoveContentToPlaylistModel addremoveContentToPlaylistModel =
      AddremoveContentToPlaylistModel();
  GetContentbyChannelModel getContentbyChannelModel =
      GetContentbyChannelModel();
  bool addremovecontentplaylistloading = false,
      getcontentbyChannelloading = false;
  int selectPlaylistindex = 0;
  bool isselectplaylist = false;

  AddremoveWatchlaterModel addremoveWatchlaterModel =
      AddremoveWatchlaterModel();
  bool addwatchlaterloading = false;

  // ReplayComment With Pagination
  int? totalRowsReplayComment, totalPageReplayComment, currentPageReplayComment;
  bool? morePageReplayComment;
  final Map<String, List<replaycomment.Result>> replaycommentList = {};

  //List<replaycomment.Result>? replaycommentList = [];
  bool replayCommentloadmore = false, replaycommentloding = false;
  String replayCommentId = "";
  String commentId = "";
  String? replyingToCommentId;

  void clearReply() {
    replyingToCommentId = null;
    notifyListeners();
  }

/* Bottom Navigation All Short Api Start */
  Future<void> getShortList(pageNo, viewType) async {
    printLog("getPostList pageNo :==> $pageNo");
    loading = true;
    if (pageNo == 1) {
      shortVideoList?.clear();
    }
    shortModel = await ApiService().shrotslist(pageNo, viewType);
    printLog("getPostList status :===> ${shortModel.status}");
    printLog("getPostList message :==> ${shortModel.message}");
    if (shortModel.status == 200) {
      setPaginationData(shortModel.totalRows, shortModel.totalPage,
          shortModel.currentPage, shortModel.morePage);
      if (shortModel.result != null && (shortModel.result?.length ?? 0) > 0) {
        printLog("postModel length :==> ${(shortModel.result?.length ?? 0)}");
        int lastPosition = 0;
        if ((shortVideoList?.length ?? 0) == 0) {
          lastPosition = 0;
        } else {
          lastPosition = (shortVideoList?.length ?? 0);
        }
        printLog("lastPosition :============> $lastPosition");
        for (var i = 0; i < (shortModel.result?.length ?? 0); i++) {
          shortVideoList?.add(shortModel.result?[i] ?? shortlist.Result());
        }
        if (searchController.text.isNotEmpty) {
          shortVideoList = shortVideoList
              ?.where((item) =>
                  item.title
                      ?.toLowerCase()
                      .contains(searchController.text.toLowerCase()) ??
                  false)
              .toList();
        }
        final Map<int, shortlist.Result> postMap = {};
        shortVideoList?.forEach((item) {
          postMap[item.id ?? 0] = item;
        });
        shortVideoList = postMap.values.toList();
        printLog("shortVideoList length :==> ${(shortVideoList?.length ?? 0)}");
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
    this.morePage = morePage;
    notifyListeners();
  }
/* Bottom Navigation All Short Api End*/

/* Profile Page Perticular User Short Api Start */
  Future<void> getcontentbyChannelShort(
      userid, chennelId, contenttype, pageNo) async {
    loading = true;
    getContentbyChannelModel = await ApiService()
        .contentbyChannel(userid, chennelId, contenttype, pageNo);
    if (getContentbyChannelModel.status == 200) {
      setUserShortPaginationData(
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
            profileShortList?.add(
                getContentbyChannelModel.result?[i] ?? usercontent.Result());
          }
          final Map<int, usercontent.Result> postMap = {};
          profileShortList?.forEach((item) {
            postMap[item.id ?? 0] = item;
          });
          profileShortList = postMap.values.toList();
          printLog(
              "followFollowingList length :==> ${(profileShortList?.length ?? 0)}");
          // setLoadMore(false);
        }
      }
    }
    loading = false;
    notifyListeners();
  }

  setUserShortPaginationData(
      int? profileShorttotalRows,
      int? profileShorttotalPage,
      int? profileShortcurrentPage,
      bool? profileShortmorePage) {
    this.profileShortcurrentPage = profileShortcurrentPage;
    this.profileShorttotalRows = profileShorttotalRows;
    this.profileShorttotalPage = profileShorttotalPage;
    profileShortmorePage = profileShortmorePage;
    notifyListeners();
  }
/* Profile Page Perticular User Short Api End */

/* Get Content By WatchLater Section Start*/
  Future<void> getContentByWatchLater(contentType, pageNo) async {
    loading = true;
    watchlaterModel = await ApiService().watchLaterList(contentType, pageNo);
    if (watchlaterModel.status == 200) {
      setWatchLaterShortPaginationData(
          watchlaterModel.totalRows,
          watchlaterModel.totalPage,
          watchlaterModel.currentPage,
          watchlaterModel.morePage);
      if (watchlaterModel.result != null &&
          (watchlaterModel.result?.length ?? 0) > 0) {
        printLog(
            "followingModel length :==> ${(watchlaterModel.result?.length ?? 0)}");
        printLog('Now on page ==========> $currentPage');
        if (watchlaterModel.result != null &&
            (watchlaterModel.result?.length ?? 0) > 0) {
          printLog(
              "followingModel length :==> ${(watchlaterModel.result?.length ?? 0)}");
          for (var i = 0; i < (watchlaterModel.result?.length ?? 0); i++) {
            watchlaterShortList
                ?.add(watchlaterModel.result?[i] ?? watchlatershort.Result());
          }
          final Map<int, watchlatershort.Result> postMap = {};
          watchlaterShortList?.forEach((item) {
            postMap[item.id ?? 0] = item;
          });
          watchlaterShortList = postMap.values.toList();
          printLog(
              "followFollowingList length :==> ${(watchlaterShortList?.length ?? 0)}");
          // setLoadMore(false);
        }
      }
    }
    loading = false;
    notifyListeners();
  }

  setWatchLaterShortPaginationData(
      int? watchlaterShorttotalRows,
      int? watchlaterShorttotalPage,
      int? watchlaterShortcurrentPage,
      bool? watchlaterShortmorePage) {
    this.watchlaterShortcurrentPage = watchlaterShortcurrentPage;
    this.watchlaterShorttotalRows = watchlaterShorttotalRows;
    this.watchlaterShorttotalPage = watchlaterShorttotalPage;
    watchlaterShortmorePage = watchlaterShortmorePage;
    notifyListeners();
  }

/* Get Content By WatchLater Section End */
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

  setCommentLoadMore(commentLoadmore) {
    this.commentLoadmore = commentLoadmore;
    notifyListeners();
  }

/* Add Comment And Add Replay Comment Short */
  getaddcomment(position, contenttype, contentid, episodeid, comment, commentid,
      isShortPage) {
    if (isShortPage == "profile") {
      profileShortList?[position].totalComment =
          (profileShortList?[position].totalComment ?? 0) + 1;
    } else if (isShortPage == "watchlater") {
      watchlaterShortList?[position].totalComment =
          (watchlaterShortList?[position].totalComment ?? 0) + 1;
    } else {
      shortVideoList?[position].totalComment =
          (shortVideoList?[position].totalComment ?? 0) + 1;
    }
    notifyListeners();
    addcomment(contenttype, contentid, episodeid, comment, commentid);
  }

  getaddReplayComment(
      contenttype, contentid, episodeid, comment, commentid) async {
    setSendingReplayComment(true);

    try {
      addCommentModel = await ApiService()
          .addcomment(contenttype, contentid, episodeid, comment, commentid);

      if (addCommentModel.result != null &&
          addCommentModel.result!.isNotEmpty) {
        final newReply = addCommentModel.result!.first;
        print("✅ addcomment API returned new reply: ${newReply.id}");

        // 🔹 Insert reply locally so UI updates instantly
        replaycommentList.putIfAbsent(commentid, () => []);
        replaycommentList[commentid]!.insert(0, newReply);

        // 🔹 Expand replies automatically (Set only supports .add)
        expandedReplies.add(commentid);

        notifyListeners();

        // 🔄 Sync with server
        await getReplayComment(commentid, 0, reply: newReply);
      } else {
        print("⚠️ addcomment API did not return any result");
      }
    } catch (e, stack) {
      print("❌ getaddReplayComment error: $e");
      print(stack);
    }

    setSendingReplayComment(false);
  }

  /// Fetch replies for a comment
  Future<void> getReplayComment(String commentId, int pageNo,
      {bool reset = false, reply}) async {
    printLog("getReplayComment pageNo :==> $pageNo");
    replaycommentloding = true;

    try {
      // Call API
      replayCommentModel =
          await ApiService().replayComment(commentId, pageNo.toString());

      printLog("getReplayComment status :===> ${replayCommentModel.status}");
      printLog("getReplayComment message :==> ${replayCommentModel.message}");

      if (replayCommentModel.status == 200) {
        // Pagination setup
        setReplayCommentPaginationData(
          replayCommentModel.totalRows,
          replayCommentModel.totalPage,
          replayCommentModel.currentPage,
          replayCommentModel.morePage,
        );

        // Ensure key exists
        if (!replaycommentList.containsKey(commentId) || reset) {
          replaycommentList[commentId] = [];
        }

        final replies = replaycommentList[commentId] ?? [];

        // 🔹 Add replies from API (no duplicates)
        for (var r in replayCommentModel.result ?? []) {
          if (!replies.any((existing) => existing.id == r.id)) {
            replies.add(r);
          }
        }

        // 🔹 Insert newly added reply at the top if provided
        if (reply != null) {
          replies.insert(0, reply);
        }

        replaycommentList[commentId] = replies;

        printLog(
            "Stored replies for $commentId : ${replaycommentList[commentId]?.length}");
        setReplayCommentLoadMore(false);
      }
    } catch (e, stack) {
      printLog("❌ getReplayComment error: $e");
      print(stack);
    }

    replaycommentloding = false;
    notifyListeners();
  }

  /// Expand/Collapse replies
  void toggleReplies(String commentId) {
    if (expandedReplies.contains(commentId)) {
      // collapse
      expandedReplies.remove(commentId);
    } else {
      // expand
      expandedReplies.add(commentId);

      // fetch only if no replies cached
      if (!(replaycommentList.containsKey(commentId) &&
          replaycommentList[commentId]!.isNotEmpty)) {
        getReplayComment(commentId, 0, reset: true);
      }

      setReplayCommentLoadMore(false);
    }
    notifyListeners();
  }

  setSendingReplayComment(isSending) {
    printLog("isSending ==> $isSending");
    addreplaycommentloading = isSending;
    notifyListeners();
  }

  addcomment(contenttype, contentid, episodeid, comment, commentid) async {
    setSendingComment(true);
    addCommentModel = await ApiService()
        .addcomment(contenttype, contentid, episodeid, comment, commentid);
    await getComment(contenttype, contentid, "0");
    setSendingComment(false);
  }

  setSendingComment(isSending) {
    printLog("isSending ==> $isSending");
    addcommentloading = isSending;
    notifyListeners();
  }

/* Delete Comment And Delete Replay Comment */

  getDeleteComment(commentid, isComment, index, isShortPage) async {
    deleteItemIndex = index;
    if (isComment == true) {
      if (isShortPage == "profile") {
        profileShortList?[index].totalComment =
            (profileShortList?[index].totalComment ?? 0) - 1;
      } else if (isShortPage == "watchlater") {
        watchlaterShortList?[index].totalComment =
            (watchlaterShortList?[index].totalComment ?? 0) - 1;
      } else {
        shortVideoList?[index].totalComment =
            (shortVideoList?[index].totalComment ?? 0) - 1;
      }
    }
    setDeletePlaylistLoading(true);
    deleteCommentModel = await ApiService().deleteComment(commentid);
    setDeletePlaylistLoading(false);
    if (isComment == true) {
      commentList?.removeAt(index);
      printLog("remove Comment Item");
    } else {
      replaycommentList.removeWhere(index);
      printLog("remove ReplayComment Item");
    }
  }

  setDeletePlaylistLoading(isSending) {
    printLog("isSending ==> $isSending");
    deletecommentLoading = isSending;
    notifyListeners();
  }

  /* void toggleReplies(String commentId) {
    if (expandedReplies.contains(commentId)) {
      expandedReplies.remove(commentId);
    } else {
      expandedReplies.add(commentId);
      // fetch replies only if not already fetched
      getReplayComment(commentId, (0) + 1,);
      setReplayCommentLoadMore(false);
    }
    notifyListeners();
  }*/

  bool isRepliesExpanded(String commentId) {
    return expandedReplies.contains(commentId);
  }

/* Simple Short Like And Dislike */
  shortLike(position, contenttype, contentid, status, episodeId) {
    if ((shortVideoList?[position].isUserLikeDislike ?? 0) == 0) {
      shortVideoList?[position].isUserLikeDislike = 1;
      shortVideoList?[position].totalLike =
          (shortVideoList?[position].totalLike ?? 0) + 1;
    } else if ((shortVideoList?[position].isUserLikeDislike ?? 0) == 2) {
      shortVideoList?[position].isUserLikeDislike = 1;
      shortVideoList?[position].totalLike =
          (shortVideoList?[position].totalLike ?? 0) + 1;
      if ((shortVideoList?[position].totalDislike ?? 0) > 0) {
        shortVideoList?[position].totalDislike =
            (shortVideoList?[position].totalDislike ?? 0) - 1;
      }
    } else {
      shortVideoList?[position].isUserLikeDislike = 0;
      if ((shortVideoList?[position].totalLike ?? 0) > 0) {
        shortVideoList?[position].totalLike =
            (shortVideoList?[position].totalLike ?? 0) - 1;
      }
    }
    notifyListeners();
    addLikeDislike(contenttype, contentid, status, episodeId);
  }

  shortDislike(position, contenttype, contentid, status, episodeId) {
    if ((shortVideoList?[position].isUserLikeDislike ?? 0) == 0) {
      shortVideoList?[position].isUserLikeDislike = 2;
      shortVideoList?[position].totalDislike =
          (shortVideoList?[position].totalDislike ?? 0) + 1;
    } else if ((shortVideoList?[position].isUserLikeDislike ?? 0) == 1) {
      shortVideoList?[position].isUserLikeDislike = 2;
      shortVideoList?[position].totalDislike =
          (shortVideoList?[position].totalDislike ?? 0) + 1;
      if ((shortVideoList?[position].totalLike ?? 0) > 0) {
        shortVideoList?[position].totalLike =
            (shortVideoList?[position].totalLike ?? 0) - 1;
      }
    } else {
      shortVideoList?[position].isUserLikeDislike = 0;
      if ((shortVideoList?[position].totalDislike ?? 0) > 0) {
        shortVideoList?[position].totalDislike =
            (shortVideoList?[position].totalDislike ?? 0) - 1;
      }
    }
    notifyListeners();
    addLikeDislike(contenttype, contentid, status, episodeId);
  }

/* Profile Short Like And Dislike */
  profileShortLike(position, contenttype, contentid, status, episodeId) {
    if ((profileShortList?[position].isUserLikeDislike ?? 0) == 0) {
      profileShortList?[position].isUserLikeDislike = 1;
      profileShortList?[position].totalLike =
          (profileShortList?[position].totalLike ?? 0) + 1;
    } else if ((profileShortList?[position].isUserLikeDislike ?? 0) == 2) {
      profileShortList?[position].isUserLikeDislike = 1;
      profileShortList?[position].totalLike =
          (profileShortList?[position].totalLike ?? 0) + 1;
      if ((profileShortList?[position].totalDislike ?? 0) > 0) {
        profileShortList?[position].totalDislike =
            (profileShortList?[position].totalDislike ?? 0) - 1;
      }
    } else {
      profileShortList?[position].isUserLikeDislike = 0;
      if ((profileShortList?[position].totalLike ?? 0) > 0) {
        profileShortList?[position].totalLike =
            (profileShortList?[position].totalLike ?? 0) - 1;
      }
    }
    notifyListeners();
    addLikeDislike(contenttype, contentid, status, episodeId);
  }

  profileShortDislike(position, contenttype, contentid, status, episodeId) {
    if ((profileShortList?[position].isUserLikeDislike ?? 0) == 0) {
      profileShortList?[position].isUserLikeDislike = 2;
      profileShortList?[position].totalDislike =
          (profileShortList?[position].totalDislike ?? 0) + 1;
    } else if ((profileShortList?[position].isUserLikeDislike ?? 0) == 1) {
      profileShortList?[position].isUserLikeDislike = 2;
      profileShortList?[position].totalDislike =
          (profileShortList?[position].totalDislike ?? 0) + 1;
      if ((profileShortList?[position].totalLike ?? 0) > 0) {
        profileShortList?[position].totalLike =
            (profileShortList?[position].totalLike ?? 0) - 1;
      }
    } else {
      profileShortList?[position].isUserLikeDislike = 0;
      if ((profileShortList?[position].totalDislike ?? 0) > 0) {
        profileShortList?[position].totalDislike =
            (profileShortList?[position].totalDislike ?? 0) - 1;
      }
    }
    notifyListeners();
    addLikeDislike(contenttype, contentid, status, episodeId);
  }

/* WatchLater Short Like And Dislike */
  watchLaterShortLike(position, contenttype, contentid, status, episodeId) {
    if ((watchlaterShortList?[position].isUserLikeDislike ?? 0) == 0) {
      watchlaterShortList?[position].isUserLikeDislike = 1;
      watchlaterShortList?[position].totalLike =
          (watchlaterShortList?[position].totalLike ?? 0) + 1;
    } else if ((watchlaterShortList?[position].isUserLikeDislike ?? 0) == 2) {
      watchlaterShortList?[position].isUserLikeDislike = 1;
      watchlaterShortList?[position].totalLike =
          (watchlaterShortList?[position].totalLike ?? 0) + 1;
      if ((watchlaterShortList?[position].totalDislike ?? 0) > 0) {
        watchlaterShortList?[position].totalDislike =
            (watchlaterShortList?[position].totalDislike ?? 0) - 1;
      }
    } else {
      watchlaterShortList?[position].isUserLikeDislike = 0;
      if ((watchlaterShortList?[position].totalLike ?? 0) > 0) {
        watchlaterShortList?[position].totalLike =
            (watchlaterShortList?[position].totalLike ?? 0) - 1;
      }
    }
    notifyListeners();
    addLikeDislike(contenttype, contentid, status, episodeId);
  }

  watchLaterShortDislike(position, contenttype, contentid, status, episodeId) {
    if ((watchlaterShortList?[position].isUserLikeDislike ?? 0) == 0) {
      watchlaterShortList?[position].isUserLikeDislike = 2;
      watchlaterShortList?[position].totalDislike =
          (watchlaterShortList?[position].totalDislike ?? 0) + 1;
    } else if ((watchlaterShortList?[position].isUserLikeDislike ?? 0) == 1) {
      watchlaterShortList?[position].isUserLikeDislike = 2;
      watchlaterShortList?[position].totalDislike =
          (watchlaterShortList?[position].totalDislike ?? 0) + 1;
      if ((watchlaterShortList?[position].totalLike ?? 0) > 0) {
        watchlaterShortList?[position].totalLike =
            (watchlaterShortList?[position].totalLike ?? 0) - 1;
      }
    } else {
      watchlaterShortList?[position].isUserLikeDislike = 0;
      if ((watchlaterShortList?[position].totalDislike ?? 0) > 0) {
        watchlaterShortList?[position].totalDislike =
            (watchlaterShortList?[position].totalDislike ?? 0) - 1;
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

/* Get Report Reason List With Pagination */
  Future<void> getReportReason(type, pageNo) async {
    printLog("getPostList pageNo :==> $pageNo");
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

/* Add Report By Perticular Content */
  addContentReport(reportUserid, contentid, message, contenttype) async {
    addcontentreortloading = true;
    addContentReportModel = await ApiService()
        .addContentReport(reportUserid, contentid, message, contenttype);
    addcontentreortloading = false;
    notifyListeners();
  }

/* Add Remove To Playlist */
  addremoveContentToPlaylist(
      chennelId, playlistId, contenttype, contentid, episodeid, type) async {
    addremovecontentplaylistloading = true;
    addremoveContentToPlaylistModel = await ApiService()
        .addremoveContenttoPlaylist(
            chennelId, playlistId, contenttype, contentid, episodeid, type);
    addremovecontentplaylistloading = false;
    notifyListeners();
  }

/* Get All Playlist For Perticular User */
  getcontentbyChannel(userid, chennelId, contenttype, pageNo) async {
    getcontentbyChannelloading = true;
    getContentbyChannelModel = await ApiService()
        .contentbyChannel(userid, chennelId, contenttype, pageNo);
    getcontentbyChannelloading = false;
    notifyListeners();
  }

/* Replay Comment Pagination Start */

  /*Future<void> getReplayComment(commentId, pageNo, {reply}) async {
    printLog("getReplayComment pageNo :==> $pageNo");
    replaycommentloding = true;

    // Call API
    replayCommentModel = await ApiService().replayComment(commentId, pageNo);

    printLog("getReplayComment status :===> ${replayCommentModel.status}");
    printLog("getReplayComment message :==> ${replayCommentModel.message}");

    if (replayCommentModel.status == 200) {
      setReplayCommentPaginationData(
        replayCommentModel.totalRows,
        replayCommentModel.totalPage,
        replayCommentModel.currentPage,
        replayCommentModel.morePage,
      );

      if (replayCommentModel.result != null &&
          (replayCommentModel.result?.length ?? 0) > 0) {
        printLog(
            "reply list length from API :==> ${(replayCommentModel.result?.length ?? 0)}");

        if (!replaycommentList.containsKey(commentId)) {
          replaycommentList[commentId] = [];
        }

        final replies = replaycommentList[commentId] ?? [];

        // Avoid duplicates
        for (var r in replayCommentModel.result!) {
          if (!replies.any((existing) => existing.id == r.id)) {
            replies.add(r);
          }
        }

        // 🔥 Insert newly added reply immediately (without waiting refresh)
        if (reply != null) {
          replies.insert(0, reply);
        }

        replaycommentList[commentId] = replies;

        printLog("Stored replies for $commentId : ${replaycommentList[commentId]?.length}");
        setReplayCommentLoadMore(false);
      }
    }

    replaycommentloding = false;
    notifyListeners();
  }*/

  List<replaycomment.Result> getReplies(String commentId) {
    return replaycommentList[commentId] ?? [];
  }

  void deleteReply(String commentId, int replyId) {
    replaycommentList[commentId]?.removeWhere((item) => item.id == replyId);
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

/* Replay Comment Pagination End */

/* Add Remove Subscribe For Any Channel */
  addremoveSubscribe(index, touserid, type, isShortPage) {
    if (isShortPage == "profile") {
      if ((profileShortList?[index].isSubscribe ?? 0) == 0) {
        profileShortList?[index].isSubscribe = 1;
      } else {
        profileShortList?[index].isSubscribe = 0;
      }
    } else if (isShortPage == "watchlater") {
      if ((watchlaterShortList?[index].isSubscribe ?? 0) == 0) {
        watchlaterShortList?[index].isSubscribe = 1;
      } else {
        watchlaterShortList?[index].isSubscribe = 0;
      }
    } else {
      if ((shortVideoList?[index].isSubscribe ?? 0) == 0) {
        shortVideoList?[index].isSubscribe = 1;
      } else {
        shortVideoList?[index].isSubscribe = 0;
      }
    }
    notifyListeners();
    getaddremoveSubscribe(touserid, type);
  }

  Future<void> getaddremoveSubscribe(touserid, type) async {
    addremoveSubscribeModel =
        await ApiService().addremoveSubscribe(touserid, type);
  }

/* Add Remove Watch Later For Short */
  addremoveWatchLater(contenttype, contentid, episodeid, type) async {
    addwatchlaterloading = true;
    addremoveWatchlaterModel = await ApiService()
        .addremoveWatchLater(contenttype, contentid, episodeid, type);
    addwatchlaterloading = false;
    notifyListeners();
  }

/* Some Helper Method Start */
  selectReportReason(int index, selectReason, isReasonId) {
    reportposition = index;
    isSelectReason = selectReason;
    reasonId = isReasonId;
    printLog("reasonId===> $reasonId");
    notifyListeners();
  }

  selectPlaylist(int index, bool chack) {
    selectPlaylistindex = index;
    isselectplaylist = chack;
    notifyListeners();
  }
/* Some Helper Method End */

  storeReplayCommentId(isReplayCommentId) async {
    replayCommentId = isReplayCommentId;
    replyingToCommentId = isReplayCommentId;

    notifyListeners();
  }

  storeContentId(isContentId) async {
    commentId = isContentId;
    notifyListeners();
  }

  changePageViewIndex(int index) {
    position = index;
    notifyListeners();
  }

/* Clear Provider And Perticular Array */
  clearProvider() {
    shortModel = ShortModel();
    getcommentModel = CommentModel();
    addCommentModel = AddCommentModel();
    addRemoveLikeDislikeModel = AddRemoveLikeDislikeModel();
    deleteCommentModel = DeleteCommentModel();
    addremoveSubscribeModel = AddremoveSubscribeModel();
    watchlaterModel = GetWatchlaterModel();
    loading = false;
    catindex = 0;
    reporttotalRows;
    reporttotalPage;
    reportcurrentPage;
    reportmorePage;
    reportReasonList = [];
    isSelectReason = false;
    getcontentreportloading = false;
    getcontentreportloadmore = false;
    isShowSearch = false;
    searchController.clear();
    /* All Short Field */
    shortVideoList = [];
    shortVideoList?.clear();
    totalRows;
    totalPage;
    currentPage;
    morePage;
    /* Perticular User Short Field */
    profileShortList = [];
    profileShortList?.clear();
    profileShorttotalRows;
    profileShorttotalPage;
    profileShortcurrentPage;
    userShortmorePage;
    /* WatchLater Short Field */
    watchlaterShortList = [];
    watchlaterShortList?.clear();
    watchlaterShorttotalRows;
    watchlaterShorttotalPage;
    watchlaterShortcurrentPage;
    watchlaterShortmorePage;
    /* Get Comment Field */
    totalRowsComment;
    totalPageComment;
    currentPageComment;
    morePageComment;
    commentList = [];
    commentList?.clear();
    commentloading = false;
    addreplaycommentloading = false;
    getRepostReasonModel = GetRepostReasonModel();
    addContentReportModel = AddContentReportModel();
    getcontentreportloading = false;
    addcontentreortloading = false;
    reportposition = 0;
    reasonId = "";
    replayCommentModel = ReplayCommentModel();
    addremoveContentToPlaylistModel = AddremoveContentToPlaylistModel();
    getContentbyChannelModel = GetContentbyChannelModel();
    addremovecontentplaylistloading = false;
    getcontentbyChannelloading = false;
    selectPlaylistindex = 0;
    isselectplaylist = false;
    addremoveWatchlaterModel = AddremoveWatchlaterModel();
    addwatchlaterloading = false;
  }

  clearComment() {
    /* Get Comment Field */
    getcommentModel = CommentModel();
    totalRowsComment;
    totalPageComment;
    currentPageComment;
    morePageComment;
    commentList = [];
    commentloading = false;
    addreplaycommentloading = false;
    addcommentloading = false;
    deleteItemIndex = 0;
    deletecommentLoading = false;
  }

  clearReplayComment() {
    totalRowsReplayComment;
    totalPageReplayComment;
    currentPageReplayComment;
    morePageReplayComment;
    // replaycommentList = [];
    replayCommentloadmore = false;
    replaycommentloding = false;
    replayCommentId = "";
  }

  clearSelectReportReason() {
    reporttotalRows;
    reporttotalPage;
    reportcurrentPage;
    reportmorePage;
    reportReasonList = [];
    getcontentreportloading = false;
    getcontentreportloadmore = false;
    reportposition = 0;
    isSelectReason = false;
    reasonId = "";
  }
}
