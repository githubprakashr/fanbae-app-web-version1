import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fanbae/model/chathistorymodel.dart';
import 'package:fanbae/model/creatorlistmodel.dart' as creator;
import 'package:fanbae/utils/color.dart';
import 'package:fanbae/utils/utils.dart';
import 'package:fanbae/webservice/apiservice.dart';
import 'package:fanbae/widget/customappbar.dart';
import 'package:fanbae/widget/mynetworkimg.dart';
import 'package:fanbae/widget/mytext.dart';
import 'package:fanbae/widget/nodata.dart';
import '../utils/constant.dart';
import '../utils/responsive_helper.dart';
import '../widget/myimage.dart';
import 'chatpage.dart';

class ChatHistoryPage extends StatefulWidget {
  const ChatHistoryPage({super.key});

  @override
  State<ChatHistoryPage> createState() => _ChatHistoryPageState();
}

class _ChatHistoryPageState extends State<ChatHistoryPage> {
  List<Result> _chats = [];
  bool _isLoading = false;
  String _selectedFeed = 'chat';
  List<creator.Result> _creators = [];
  TextEditingController searchController = TextEditingController();
  bool isShowSearch = false;

  Result? _selectedChat;

  @override
  void initState() {
    super.initState();
    print(Constant.userID);
    if (Constant.userID != null) {
      _loadChatHistory();
    }
  }

  Future<void> _loadChatHistory() async {
    setState(() {
      _isLoading = true;
    });
    ChatHistoryData chats = await ApiService().chatHistory();
    setState(() {
      _isLoading = false;
    });
    if (chats.status == 200) {
      List<Result> allChats = [];
      allChats = chats.result;
      if (allChats.isNotEmpty && searchController.text.isNotEmpty) {
        _chats = allChats
            .where((item) => item.receiverName
                .toLowerCase()
                .contains(searchController.text.toLowerCase()))
            .toList();
      } else {
        _chats = allChats;
      }
    }
  }

  Future<void> _loadCreatorList() async {
    setState(() {
      _isLoading = true;
    });
    creator.CreatorListModel list = await ApiService().getCreatorList();
    setState(() {
      _isLoading = false;
    });
    if (list.status == 200) {
      List<creator.Result> allCreators = [];
      allCreators = list.result;
      if (allCreators.isNotEmpty && searchController.text.isNotEmpty) {
        _creators = allCreators
            .where((item) => item.name
                .toLowerCase()
                .contains(searchController.text.toLowerCase()))
            .toList();
      } else {
        _creators = allCreators;
      }
    }
  }

  buildChatHistory() {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _chats.isEmpty
            ? const NoData()
            : Column(
                children: [
                  const SizedBox(
                    height: 70,
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _chats.length,
                      itemBuilder: (context, index) {
                        final chat = _chats[index];
                        return Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: _selectedChat?.receiverId ==
                                          chat.receiverId
                                      ? Colors.blue
                                      : Colors.transparent,
                                  width: 3,
                                ),
                              ),
                              child: ListTile(
                                leading: Container(
                                  height: 40,
                                  width: 40,
                                  clipBehavior: Clip.antiAlias,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                  ),
                                  child: MyNetworkImage(
                                      imagePath: chat.receiverImage ?? '',
                                      fit: BoxFit.cover),
                                ),
                                title: MyText(
                                  text: chat.receiverName,
                                  color: white,
                                  multilanguage: false,
                                  fontwaight: FontWeight.w600,
                                  fontsizeNormal: 15.2,
                                ),
                                subtitle: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.75,
                                        child: MyText(
                                          text: chat.lastMessage,
                                          color: white,
                                          multilanguage: false,
                                          fontsizeNormal: 11.85,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    MyText(
                                      text: chat.timestamp ?? '',
                                      fontsizeNormal: 12,
                                      color: white,
                                      multilanguage: false,
                                    ),
                                    if (chat.unReadCount != 0) ...[
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: white),
                                        padding: const EdgeInsets.all(5),
                                        child: MyText(
                                            text: chat.unReadCount.toString(),
                                            color: black,
                                            multilanguage: false,
                                            fontsizeNormal: 9.5),
                                      )
                                    ]
                                  ],
                                ),
                                onTap: () async {
                                  setState(() {
                                    _loadChatHistory();
                                  });
                                  if (ResponsiveHelper.checkIsWeb(context)) {
                                    setState(() {
                                      _selectedChat = chat;
                                    });
                                  } else {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChatPage(
                                          otherUserId: chat.receiverId,
                                          otherUserName: chat.receiverName,
                                          otherUserPic:
                                              chat.receiverImage ?? '',
                                          creatorId: chat.creatorId.toString(),
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                            chat.creatorId == 1
                                ? Positioned(
                                    top: 17,
                                    left: 45,
                                    child: Align(
                                        alignment: Alignment.bottomRight,
                                        child: Container(
                                          width: 13,
                                          height: 13,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              gradient: Constant.gradientColor),
                                          child: MyImage(
                                              width: 50,
                                              height: 30,
                                              fit: BoxFit.cover,
                                              color: black,
                                              imagePath: "crown.png"),
                                        )),
                                  )
                                : const SizedBox.shrink(),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              );
  }

  buildCreatorList() {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _creators.isEmpty
            ? const NoData()
            : Column(
                children: [
                  const SizedBox(
                    height: 70,
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _creators.length,
                      itemBuilder: (context, index) {
                        final creator = _creators[index];
                        return Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: _selectedChat?.receiverId ==
                                          creator.id.toString()
                                      ? Colors.blue
                                      : Colors.transparent,
                                  width: 3,
                                ),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.only(
                                    bottom: 10, left: 15, right: 15, top: 5),
                                leading: Container(
                                  height: 40,
                                  width: 40,
                                  clipBehavior: Clip.antiAlias,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                  ),
                                  child: MyNetworkImage(
                                      imagePath: creator.image,
                                      fit: BoxFit.cover),
                                ),
                                title: MyText(
                                  text: creator.name,
                                  color: white,
                                  multilanguage: false,
                                ),
                                onTap: () {
                                  if (ResponsiveHelper.checkIsWeb(context)) {
                                    if (ResponsiveHelper.checkIsWeb(context)) {
                                      setState(() {
                                        _selectedChat = Result(
                                          receiverId: creator.id.toString(),
                                          receiverName: creator.name,
                                          receiverImage: creator.image,
                                          lastMessage: "",
                                          timestamp: "",
                                          chatId: '',
                                        );
                                      });
                                    }
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChatPage(
                                          otherUserId: creator.id.toString(),
                                          otherUserName: creator.name,
                                          otherUserPic: creator.image,
                                          creatorId:
                                              creator.creatorId.toString(),
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                            creator.creatorId == 1
                                ? Positioned(
                                    top: 17,
                                    left: 45,
                                    child: Align(
                                        alignment: Alignment.bottomRight,
                                        child: Container(
                                          width: 13,
                                          height: 13,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              gradient: Constant.gradientColor),
                                          child: MyImage(
                                              width: 50,
                                              height: 30,
                                              fit: BoxFit.cover,
                                              color: black,
                                              imagePath: "crown.png"),
                                        )),
                                  )
                                : const SizedBox.shrink(),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appbgcolor,
      appBar: ResponsiveHelper.checkIsWeb(context)
          ? Utils.webAppbarWithSidePanel(
              context: context, contentType: Constant.musicSearch)
          : const CustomAppBar(contentType: '1'),
      body: ResponsiveHelper.checkIsWeb(context)
          ? Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Utils.sidePanelWithBody(
                    myWidget: Stack(
                      children: [
                        _selectedFeed == "chat"
                            ? buildChatHistory()
                            : buildCreatorList(),
                        Padding(
                          padding: const EdgeInsets.only(
                              bottom: 12.0, left: 1, right: 1, top: 15),
                          child: isShowSearch
                              ? Container(
                                  height: 35,
                                  decoration: BoxDecoration(
                                    gradient: _selectedFeed == 'search'
                                        ? Constant.gradientColor
                                        : null,
                                    border: Border.all(
                                      color: _selectedFeed == 'search'
                                          ? transparent
                                          : textColor,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: TextFormField(
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                            color: white,
                                            fontWeight: FontWeight.w700),
                                    controller: searchController,
                                    decoration: InputDecoration(
                                        hintText: "Search",
                                        hintStyle: TextStyle(color: white),
                                        /*fillColor: white.withOpacity(0.42),
                                        filled: true,*/
                                        contentPadding: const EdgeInsets.only(
                                            top: 15, left: 10),
                                        enabledBorder: const OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.transparent)),
                                        focusedBorder: const OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.transparent)),
                                        suffixIcon: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              if (searchController
                                                  .text.isNotEmpty) {
                                                searchController.clear();
                                                if (_selectedFeed == "chat") {
                                                  _loadChatHistory();
                                                } else {
                                                  _loadCreatorList();
                                                }
                                              }
                                              isShowSearch = !isShowSearch;
                                            });
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(7.0),
                                            child: CircleAvatar(
                                              radius: 7,
                                              backgroundColor: white,
                                              child: Icon(
                                                Icons.close,
                                                color: black,
                                                size: 14,
                                              ),
                                            ),
                                          ),
                                        )),
                                    onChanged: (value) {
                                      setState(() {
                                        if (_selectedFeed == "chat") {
                                          _loadChatHistory();
                                        } else {
                                          _loadCreatorList();
                                        }
                                      });
                                    },
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Wrap(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _selectedFeed = "chat";
                                              _loadChatHistory();
                                            });
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 13, vertical: 4),
                                            decoration: BoxDecoration(
                                                gradient:
                                                    _selectedFeed == "chat"
                                                        ? Constant.gradientColor
                                                        : null,
                                                color: _selectedFeed != "chat"
                                                    ? white.withAlpha(185)
                                                    : null,
                                                borderRadius:
                                                    BorderRadius.circular(20)),
                                            child: Row(
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.all(5),
                                                  decoration: BoxDecoration(
                                                      color: buttonDisable
                                                          .withAlpha(135),
                                                      shape: BoxShape.circle),
                                                  child: Icon(
                                                    Icons.chat,
                                                    color: white,
                                                    size: 18,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                MyText(
                                                    text: "chats",
                                                    color:
                                                        /*_selectedFeed != "chat"
                                                            ? white
                                                            :*/
                                                        pureBlack,
                                                    fontwaight: FontWeight.w600,
                                                    fontsizeNormal: 13.2)
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _selectedFeed = "suggestion";
                                              _loadCreatorList();
                                            });
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 13, vertical: 4),
                                            decoration: BoxDecoration(
                                                gradient:
                                                    _selectedFeed != "chat"
                                                        ? Constant.gradientColor
                                                        : null,
                                                color: _selectedFeed == "chat"
                                                    ? white.withAlpha(185)
                                                    : null,
                                                borderRadius:
                                                    BorderRadius.circular(20)),
                                            child: Row(
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.all(5),
                                                  decoration: BoxDecoration(
                                                      color: buttonDisable
                                                          .withAlpha(135),
                                                      shape: BoxShape.circle),
                                                  child: Icon(
                                                    Icons.group,
                                                    color: white,
                                                    size: 18,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                MyText(
                                                    text: "suggestions",
                                                    fontwaight: FontWeight.w600,
                                                    color:
                                                        /* _selectedFeed == "chat"
                                                            ? white
                                                            :*/
                                                        pureBlack,
                                                    fontsizeNormal: 13.2)
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          isShowSearch = !isShowSearch;
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(9),
                                        decoration: BoxDecoration(
                                            gradient: Constant.gradientColor,
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        child: Icon(
                                          Icons.search,
                                          color: black,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                        )
                      ],
                    ),
                  ),
                ),
                ResponsiveHelper.checkIsWeb(context)
                    ? Expanded(
                        flex: 2,
                        child: Container(
                            decoration:
                                BoxDecoration(border: Border.all(color: black)),
                            child: (_selectedChat != null
                                ? ChatPage(
                                    key: ValueKey(_selectedChat!.receiverId),
                                    otherUserId: _selectedChat!.receiverId,
                                    otherUserName: _selectedChat!.receiverName,
                                    otherUserPic:
                                        _selectedChat!.receiverImage ?? '',
                                    creatorId:
                                        _selectedChat!.creatorId.toString(),
                                  )
                                : Utils().pageBg(
                                    context,
                                    child: Center(
                                      child: MyText(
                                        text: 'Start the conversation',
                                        color: white,
                                        multilanguage: false,
                                        fontsizeNormal: 16,
                                      ),
                                    ),
                                  ))),
                      )
                    : const SizedBox(),
              ],
            )
          : Utils().pageBg(
              context,
              child: Stack(
                children: [
                  _selectedFeed == "chat"
                      ? buildChatHistory()
                      : buildCreatorList(),
                  Container(
                    color: appBarColor,
                    padding: const EdgeInsets.only(
                        bottom: 12.0, left: 15, right: 15, top: 15),
                    child: isShowSearch
                        ? Container(
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: _selectedFeed == 'search'
                                  ? Constant.gradientColor
                                  : null,
                              border: Border.all(
                                color: _selectedFeed == 'search'
                                    ? transparent
                                    : textColor,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: TextFormField(
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                      color: white,
                                      fontWeight: FontWeight.w700),
                              controller: searchController,
                              decoration: InputDecoration(
                                  hintText: "Search",
                                  hintStyle: TextStyle(color: white),
                                  /* fillColor: white.withOpacity(0.42),
                                  filled: true,*/
                                  contentPadding:
                                      const EdgeInsets.only(top: 15, left: 10),
                                  enabledBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.transparent)),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Colors.transparent)),
                                  suffixIcon: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (searchController.text.isNotEmpty) {
                                          searchController.clear();
                                          if (_selectedFeed == "chat") {
                                            _loadChatHistory();
                                          } else {
                                            _loadCreatorList();
                                          }
                                        }
                                        isShowSearch = !isShowSearch;
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(7.0),
                                      child: CircleAvatar(
                                        radius: 7,
                                        backgroundColor: white,
                                        child: Icon(
                                          Icons.close,
                                          color: black,
                                          size: 14,
                                        ),
                                      ),
                                    ),
                                  )),
                              onChanged: (value) {
                                setState(() {
                                  if (_selectedFeed == "chat") {
                                    _loadChatHistory();
                                  } else {
                                    _loadCreatorList();
                                  }
                                });
                              },
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Wrap(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedFeed = "chat";
                                        _loadChatHistory();
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 13, vertical: 4),
                                      decoration: BoxDecoration(
                                          gradient: _selectedFeed == "chat"
                                              ? Constant.gradientColor
                                              : null,
                                          color: _selectedFeed != "chat"
                                              ? white.withAlpha(185)
                                              : null,
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                                color: buttonDisable
                                                    .withAlpha(135),
                                                shape: BoxShape.circle),
                                            child: const Icon(
                                              Icons.chat,
                                              color: pureWhite,
                                              size: 18,
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          MyText(
                                              text: "chats",
                                              fontwaight: FontWeight.w600,
                                              color: pureBlack,
                                              fontsizeNormal: 13.2)
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedFeed = "suggestion";
                                        _loadCreatorList();
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 13, vertical: 4),
                                      decoration: BoxDecoration(
                                          gradient: _selectedFeed != "chat"
                                              ? Constant.gradientColor
                                              : null,
                                          color: _selectedFeed == "chat"
                                              ? white.withAlpha(185)
                                              : null,
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                                color: buttonDisable
                                                    .withAlpha(135),
                                                shape: BoxShape.circle),
                                            child: const Icon(
                                              Icons.group,
                                              color: pureWhite,
                                              size: 18,
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          MyText(
                                              text: "suggestions",
                                              color: pureBlack,
                                              fontwaight: FontWeight.w600,
                                              fontsizeNormal: 13.2)
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isShowSearch = !isShowSearch;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(9),
                                  decoration: BoxDecoration(
                                      gradient: Constant.gradientColor,
                                      borderRadius: BorderRadius.circular(20)),
                                  child: const Icon(
                                    Icons.search,
                                    color: pureBlack,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                  )
                ],
              ),
            ),
    );
  }
}
