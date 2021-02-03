import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:Slydo/data/socket_provider.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/helpers/chat_user_manager.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/tiles/product_and_service_tile_for_chat.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/tiles/product_and_service_tile_for_search.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/tiles/transaction_tile_for_chat.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/utils.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/widgets/chat_audio_player.dart';
import 'package:Slydo/screens/more_apps/messaging/message_auth.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/shopping/shopping_auth.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/screens/more_apps/user_profile/user_auth.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/bottom_sheet_item.dart';
import 'package:Slydo/widget/customized_popup_menu.dart';
import 'package:Slydo/widget/noItemInList.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:toast/toast.dart';
import 'package:uuid/uuid.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class ChatScreen extends StatefulWidget {
  final arguments;

  ChatScreen({this.arguments});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  /// Text message controller
  TextEditingController messageController;
  FocusNode messageFocus;

  /// Current chat users
  UserBloc userBloc;
  CustomerProfile recipientUser;
  bool isRecipientLoading = false;

  /// Socket
  MainSocketProvider mainSocketProvider;
  StreamSubscription streamSubscription;

  /// Messages list variables
  List<String> messageList = [];
  // For storing messages when user is in background
  List<String> temporaryMessages = [];
  bool isLoading = false;
  int count = 0;
  String next = "";
  String previous = "";

  /// Message scrolling variables
  ScrollController messageScrollController;
  bool fabIsVisible = false;

  /// User typing state variables
  Timer _timerForUserTypingState;
  Duration userMessageTypingStateUpdateTime = Duration(seconds: 2);
  bool isRecipientTyping = false;

  /// Music Player
  AssetsAudioPlayer _audioPlayer = AssetsAudioPlayer();
  bool isAudioPlaying = false;

  /// User status
  String userStatus = "";

  /// allowed message types
  List<String> imageExtensions = ["jpg", "jpeg", "png", "gif", "webp"];
  List<String> videoExtensions = [
    "mp4",
    "mov",
    "wmv",
    "flv",
    "avi",
    "webm",
    "mkv"
  ];
  List<String> audioExtensions = ["m4a", "flac", "mp3", "wav", "wma", "aac"];

  /// variables for product or service search
  bool isProductSearch = true;
  bool isServiceSearch = false;
  bool isCurrentUsersProductOrService = false;
  bool isProductAndServiceLoading = false;
  List searchedProductAndService = [];
  StateSetter bottomSheetStateSetterGlobal;
  bool bottomSheetMounted = false;

  bool isProductOrServiceLoading = false;
  int productOrServiceCount = 0;
  String productOrServiceNext = "";
  String productOrServicePrevious = "";
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  ScrollController _scrollController = new ScrollController();

  TextEditingController searchItemTextController;
  GlobalKey _key = LabeledGlobalKey("itemSearchTypeSelectionKey");
  CustomizedPopUpMenu itemSearchTypeSelectionMenu;
  int selectedMenuItemIndex = 0;
  bool isPopMenuOpen = false;
  GlobalKey searchItemTextFormField = GlobalKey();
  int bottomSheetSearchIndex = 0;
  bool noSearchedItem = false;

  /// variables for  text message and audio message btn switcher
  bool messageIsText = false;

  /// variable for audioREcording
  FlutterSoundRecorder audioRecorder = FlutterSoundRecorder();
  bool isAudioRecorderInitialized = false;
  String audioUuid;
  String audioPath;
  Duration audioRecordingDuration = Duration.zero;
  bool isAudioRecording = false;
  bool isAudioPermissionAccepted = false;

  BasketBloc basketBloc;

  StreamSubscription<ConnectivityResult> networkConnectionSubscription;

  ///variable for message actions
  bool showMoreAction = false;

  /// variables for listening socket connection
  bool _isNetworkConnectionIsOn;

  @override
  void initState() {
    messageController = TextEditingController();
    searchItemTextController = TextEditingController();
    messageFocus = FocusNode();
    recipientUser = widget.arguments["searchedUser"];

    setupScrollController();

    messageController.addListener(sendUserTypingState);

    // searchItemTextController.addListener(searchProductOrService);

    WidgetsFlutterBinding.ensureInitialized();

    fetchRecipientUserIfNotAvailable();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          _scrollController.position.pixels != 0) {
        getProductOrServiceList();
      }
    });

    super.initState();

    /// add the observer
    WidgetsBinding.instance.addObserver(this);
  }

  void fetchRecipientUserIfNotAvailable() async {
    String recipientUserName = widget.arguments["recipientUserName"] ?? "";

    if (recipientUserName != "") {
      isRecipientLoading = true;
      if (mounted) setState(() {});

      recipientUser = await UserAuth()
          .fetchContactProfile(widget.arguments["recipientUserName"]);

      isRecipientLoading = false;
      if (mounted) setState(() {});
    }

    getPreviousMessages();
    getUserStatus();
    initializeSocket();
    setUpAudioRecorder();
    setupNetworkConnectionListener();

    ChatUserManager().clearChatUserMessageCount(
        conversationId: recipientUser.conversationId);
  }

  void setupNetworkConnectionListener() {
    networkConnectionSubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) async {
      if (result == ConnectivityResult.none) {
        _isNetworkConnectionIsOn = false;
      } else {
        _isNetworkConnectionIsOn = true;
        // if (_isFirstTime) {
        //   _isFirstTime = false;
        // } else {
        messageList.clear();
        next = "";
        previous = "";
        count = 0;
        getPreviousMessages();
        // }
      }
      debugPrint(
          "_isNetworkConnectionIsOn FROM CHAT SCREEN:- $_isNetworkConnectionIsOn");
    })
          ..onError((error) {
            debugPrint("ERROR:- while closing network status stream $error");
          });
  }

  void setUpAudioRecorder() {
    audioRecorder.openAudioSession().then((value) {
      setState(() {
        isAudioRecorderInitialized = true;
      });
    });

    audioRecorder.onProgress.listen((RecordingDisposition event) {
      audioRecordingDuration = event.duration;
      setState(() {});
    });

    getAudioPermission();
  }

  void disposeAudioPlayers() {
    messageList.forEach((element) {
      Map<String, dynamic> messageData = jsonDecode(element);

      AssetsAudioPlayer.allPlayers().forEach((key, value) {
        if (value.id == messageData["id"]) {
          value.dispose();
        }
      });
    });
  }

  @override
  void dispose() {
    /// remove the observer
    WidgetsBinding.instance.removeObserver(this);

    _timerForUserTypingState?.cancel();

    _audioPlayer?.stop();
    _audioPlayer?.dispose();

    debugPrint("Subscription Removed ${streamSubscription?.toString()}");
    streamSubscription?.cancel();
    networkConnectionSubscription?.cancel();

    audioRecorder?.closeAudioSession();
    audioRecorder = null;

    messageController.removeListener(sendUserTypingState);

    // searchItemTextController.removeListener(searchProductOrService);

    messageController.dispose();

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // These are the callbacks
    switch (state) {
      case AppLifecycleState.resumed:
        debugPrint("Chat is resumed");
        mainSocketProvider.isChatOnScreen = true;
        acknowledgeThatMessageAreRead();
        break;
      case AppLifecycleState.inactive:
        debugPrint("Chat is inactive");
        mainSocketProvider.isChatOnScreen = false;
        break;
      case AppLifecycleState.paused:
        debugPrint("Chat is paused");
        break;
      case AppLifecycleState.detached:
        debugPrint("Chat is detached");
        break;
    }
  }

  void acknowledgeThatMessageAreRead() {
    if (mainSocketProvider.isChatOnScreen) {
      if (temporaryMessages.isNotEmpty) {
        temporaryMessages.forEach((element) {
          messageReadByRecipient(jsonDecode(element));
        });

        debugPrint("Clearing temporary Message");
        temporaryMessages.clear();
      }
    }
  }

  void storeMessagesTemporary({String message}) {
    temporaryMessages.add(message);
    debugPrint("Storing temporary Message:- ${temporaryMessages.length}");
  }

  void initializeSocket() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      mainSocketProvider =
          Provider.of<MainSocketProvider>(context, listen: false);
      try {
        mainSocketProvider.currentConversationId = recipientUser.conversationId;
        mainSocketProvider.isChatOnScreen = true;
      } catch (e) {
        debugPrint("Hello error:- $e");
      }
    });
  }

  void initializeListener() {
    streamSubscription?.cancel();
    streamSubscription = mainSocketProvider.socketStream.listen((event) {
      determineMessageType(event);
    });
  }

  void sendUserTypingState() {
    if (_timerForUserTypingState?.isActive ?? true) {
      userTyping();
    }
    if (messageController.text != "") {
      if (_timerForUserTypingState?.isActive ?? false) {
        _timerForUserTypingState.cancel();
      }

      _timerForUserTypingState = Timer(userMessageTypingStateUpdateTime, () {
        // userTyping();
        sendUserTypingState();
      });
    }
  }

  void setupScrollController() {
    messageScrollController = ScrollController();

    messageScrollController.addListener(() {
      /// for floating button to show scroll to bottom

      fabIsVisible = messageScrollController.position.userScrollDirection ==
          ScrollDirection.reverse;
      if (messageScrollController.position.pixels ==
          messageScrollController.position.minScrollExtent) {
        fabIsVisible = false;
      }

      if (mounted) setState(() {});
    });
  }

  void getPreviousMessages({bool showLoading = true}) async {
    debugPrint("Fetching previous messages !!");
    if (!isLoading) {
      if (next != null && !isLoading) {
        bool isFirstTime;
        if (mounted) {
          if (showLoading) {
            isLoading = true;
            setState(() {});
          }
        }

        if (messageList.isEmpty) {
          isFirstTime = true;
        } else {
          isFirstTime = false;
        }
        debugPrint(
            "recipient conversationID:- ${recipientUser.conversationId}");
        Map<String, dynamic> result = await MessageAuth().getChatMessages(
            next, previous,
            conversionId: recipientUser.conversationId);
        count = result['count'];
        next = result['next'];
        previous = result['previous'];
        List<String> tempList = result['results'];

        isLoading = false;
        if (mounted) setState(() {});

        messageList.addAll(tempList);

        if (mounted) setState(() {});

        checkMessageForRead();

        if (isFirstTime && MediaQuery.of(context).size.height > 704) {
          debugPrint(
              "height:- " + MediaQuery.of(context).size.height.toString());
          getPreviousMessages();
        }
      }
      if (messageList.isEmpty) {
        if (mounted) {
          /// set flag if chat is empty
          setState(() {});
        }
      }
    }
  }

  void determineMessageType(String message) async {
    Map<String, dynamic> messageData = jsonDecode(message);

    if (mounted) setState(() {});
    // getUserStatus();

    switch (messageData['type']) {
      case "chatroom_message":
        checkMessageToAdd(message: message);
        break;

      case "read_by_recipient":
        updateMessageReadMark(message: message);
        break;

      case "user_typing_message":
        if (messageData['username'] != userBloc.user.userName) {
          isRecipientTyping = true;
          if (mounted) setState(() {});

          Future.delayed(Duration(seconds: 1)).then((value) {
            isRecipientTyping = false;
            if (mounted) setState(() {});
          });
        }
        break;
      case "pong":
        break;

      case "image":
        Future.delayed(Duration(microseconds: 300))
            .then((value) => scrollToBottom());
        break;

      case "transaction":
        Future.delayed(Duration(microseconds: 300))
            .then((value) => scrollToBottom());
        break;

      case "payment-request":
        Future.delayed(Duration(microseconds: 300))
            .then((value) => scrollToBottom());
        break;

      default:
        debugPrint("Message type:- ${messageData['type'] ?? messageData}");
    }
  }

  void checkMessageToAdd({String message}) {
    Map<String, dynamic> newMessage = jsonDecode(message);

    if (messageList.length > 0) {
      bool isMatchFound = false;
      for (int i = 0; i < messageList.length; i++) {
        Map<String, dynamic> previousMessage = jsonDecode(messageList[i]);
        if (newMessage['check_id'] == previousMessage['check_id'] &&
            newMessage["text"] == previousMessage["text"]) {
          newMessage["delivered"] = true;
          messageList[i] = jsonEncode(newMessage);
          if (mounted) setState(() {});
          isMatchFound = true;
        }
      }

      if (isMatchFound == false) {
        addMessageToChat(message: message);
      }
    } else {
      addMessageToChat(message: message);
    }
  }

  void addMessageToChat({String message}) {
    messageList.insert(0, message);

    if (mounted) setState(() {});

    if (mainSocketProvider.isChatOnScreen) {
      /// Update message to server when user have read the message
      if (mounted) messageReadByRecipient(jsonDecode(message));
    } else {
      debugPrint("Got Message:- $message");
      storeMessagesTemporary(message: message);
    }
  }

  void updateMessageReadMark({String message}) {
    Map<String, dynamic> messageData = jsonDecode(message);

    for (int i = 0; i < messageList.length; i++) {
      Map<String, dynamic> decodeListMessage = jsonDecode(messageList[i]);
      if (decodeListMessage["check_id"] == messageData["check_id"]) {
        decodeListMessage["read_by_recipient"] = true;
        messageList[i] = jsonEncode(decodeListMessage);
        return;
      }
    }
    if (mounted) setState(() {});
  }

  void userTyping() async {
    var data = {
      "message": "typing",
      "type": "user_typing_message",
      "conversation_id": recipientUser.conversationId,
    };

    await mainSocketProvider.add(data);
  }

  void messageReadByRecipient(Map<String, dynamic> message) async {
    if (message["author"] != userBloc.user.userName) {
      // debugPrint("is Chat on Screen :- ${mainSocketProvider.isChatOnScreen}");
      if (mainSocketProvider.isChatOnScreen) {
        var data = {
          "check_id": message["check_id"],
          "type": "read_by_recipient",
          "conversation_id": recipientUser.conversationId,
        };

        // debugPrint("data:- $message");
        // debugPrint("MEssage REad By Recipient:- $data");

        await mainSocketProvider.add(data);
      }
    }
  }

  void scrollToBottom() {
    debugPrint("Scrolling to Bottom");
    messageScrollController.animateTo(
        messageScrollController.position.minScrollExtent,
        duration: Duration(microseconds: 100),
        curve: Curves.easeOut);
  }

  void scrollToTopWithTopSpace() {
    messageScrollController.animateTo(
        messageScrollController.position.minScrollExtent + 10,
        duration: Duration(microseconds: 100),
        curve: Curves.easeOut);
  }

  void menuItemSelectionChange(String value, int index) {
    selectedMenuItemIndex = index;

    if (value == "Products") {
      isProductSearch = true;
      isServiceSearch = false;
    } else if (value == "Services") {
      isServiceSearch = true;
      isProductSearch = false;
    }

    clearSearchedListItems();
    if (mounted) setState(() {});
  }

  void menuStateChange(bool isOpen) {
    isPopMenuOpen = isOpen;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (itemSearchTypeSelectionMenu == null) {
      itemSearchTypeSelectionMenu = CustomizedPopUpMenu(
          buttonKey: _key,
          context: context,
          hasIcon: true,
          children: [
            CustomizedPopUpMenuItemWithIcon(
                title: "Product",
                value: "Products",
                icon: SlydoAppIcon.product),
            CustomizedPopUpMenuItemWithIcon(
                title: "Service", value: "Services", icon: SlydoAppIcon.note_2),
          ],
          selectedIndex: selectedMenuItemIndex,
          left: 16,
          arrowPosition: Alignment.topLeft,
          arrowLeftPadding: 16,
          top: 14);
      itemSearchTypeSelectionMenu.onChange = menuItemSelectionChange;
      itemSearchTypeSelectionMenu.menuState = menuStateChange;
    }

    userBloc = Provider.of<UserBloc>(context);
    basketBloc = Provider.of<BasketBloc>(context);
    mainSocketProvider = Provider.of<MainSocketProvider>(context);

    initializeListener();

    if (MediaQuery.of(context).viewInsets.bottom != 0) {
      showMoreAction = false;
      if (mounted) setState(() {});
    }

    return WillPopScope(
      onWillPop: () async {
        disposeAudioPlayers();
        mainSocketProvider.removeStreamSubscription(streamSubscription);
        mainSocketProvider.currentConversationId = null;
        mainSocketProvider.isChatOnScreen = false;

        return Future.value(true);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: appBar(),
        body: scaffoldBody(),
        floatingActionButton: Padding(
          padding: EdgeInsets.only(bottom: 48),
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: 100),
            child: fabIsVisible
                ? FloatingActionButton(
                    mini: true,
                    backgroundColor: dividerColor,
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 28,
                      color: blackFont,
                    ),
                    tooltip: "Increment",
                    onPressed: scrollToBottom,
                  )
                : Container(
                    height: 0,
                    width: 0,
                  ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  Widget appBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      titleSpacing: 0,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: Icon(
          Icons.keyboard_arrow_left,
          color: navyBlue,
          size: 28,
        ),
        onPressed: () {
          disposeAudioPlayers();
          mainSocketProvider.removeStreamSubscription(streamSubscription);
          mainSocketProvider.currentConversationId = null;
          mainSocketProvider.isChatOnScreen = false;
          Navigator.pop(context);
        },
      ),
      leadingWidth: 40,

      title: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, '/profile',
              arguments: {"searchedUser": recipientUser});
        },
        child: Row(
          children: [
            getUserIcon(),
            SizedBox(
              width: 12,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipientUser != null ? recipientUser.fullName : "",
                  style: TextStyle(
                    color: blackFont,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  maxLines: 1,
                ),
                Text(
                  recipientUser != null
                      ? isRecipientTyping
                          ? "Typing.."
                          : userStatus
                      : "", //"Online",
                  style: TextStyle(
                      color: isRecipientTyping ? naturalGreen : darkGrey,
                      fontSize: 10,
                      fontWeight: FontWeight.w400),
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  maxLines: 1,
                ),
              ],
            ),
          ],
        ),
      ),
      // actions: [
      //   userProfileIcon(),
      //   SizedBox(
      //     width: 16,
      //   )
      // ],
    );
  }

  void getUserStatus() async {
    var data = await MessageAuth().getChatUserStatus(recipientUser.userName);

    print("userdata:$data");

    if (data["status"] == "Online") {
      userStatus = "Online";
    } else {
      DateTime now = new DateTime.now();
      DateTime today = new DateTime(now.year, now.month, now.day);
      DateTime yesterday = now.subtract(Duration(days: 1));

      DateTime lastSeenDateTime = DateTime.parse(data["last_seen"]).toLocal();
      DateTime lastSeenDate = new DateTime(
          lastSeenDateTime.year, lastSeenDateTime.month, lastSeenDateTime.day);

      String lastSeenDateString =
          DateFormat("dd/MM/yyyy").format(lastSeenDateTime);
      String lastSeenTime = DateFormat("hh:mm a").format(lastSeenDateTime);

      if (today == lastSeenDate) {
        userStatus = 'last seen today at ' + lastSeenTime;
        return;
      }

      if (yesterday == lastSeenDate) {
        userStatus = 'last seen yesterday at ' + lastSeenTime;
        return;
      }
      //Todo: Add within last 7 day (last seen Monday at 1.30 AM)

      userStatus = 'last seen ' + lastSeenDateString + ' at ' + lastSeenTime;
    }
    if (mounted) setState(() {});
  }

  Widget getUserIcon() => Container(
        height: 36,
        width: 36,
        child: isRecipientLoading
            ? CircularLoadingIndicator()
            : ClipOval(
                child: CachedNetworkImage(
                  imageUrl: recipientUser != null
                      ? recipientUser.avatar ??
                          "https://slydo-assets.s3.amazonaws.com/static/images/User_Avatar.png"
                      : "https://slydo-assets.s3.amazonaws.com/static/images/User_Avatar.png",
                  colorBlendMode: BlendMode.darken,
                  fit: BoxFit.fill,
                  filterQuality: FilterQuality.high,
                  errorWidget: imageErrorWidget,
                ),
              ),
      );

  Widget userProfileIcon() {
    return RoundedBackgroundIcon(
      height: 34,
      width: 34,
      icon: Icon(
        SlydoAppIcon.circle_user,
        size: 16,
        color: blackFont,
      ),
      onTap: () {},
      backgroundColor: iconBtnGrey,
      enableMargin: true,
    );
  }

  Widget messageActionBar() {
    return Card(
      elevation: 10,
      margin: EdgeInsets.zero,
      shadowColor: boxShadowTwo,
      child: getSearchBarLayout(),
    );
  }

  Widget getSearchBarLayout() {
    // if (isProductSearch || isServiceSearch) {
    //   return Column(
    //     children: [
    //       Card(
    //         elevation: 10,
    //         margin: EdgeInsets.zero,
    //         shadowColor: lightGrey,
    //         shape: RoundedRectangleBorder(
    //             borderRadius: BorderRadius.only(
    //                 topLeft: Radius.circular(15),
    //                 topRight: Radius.circular(15))),
    //         child: ClipRRect(
    //           borderRadius: BorderRadius.only(
    //             topLeft: Radius.circular(15),
    //             topRight: Radius.circular(15),
    //           ),
    //           child: Container(
    //             height: MediaQuery.of(context).size.height / 3,
    //             width: MediaQuery.of(context).size.width,
    //             color: Colors.white,
    //             child: Column(
    //               children: [
    //                 Container(
    //                     padding: EdgeInsets.symmetric(vertical: 4),
    //                     child: Text(
    //                       isProductSearch ? "Products" : "Services",
    //                       style: TextStyle(),
    //                     )),
    //                 searchedProductAndService.isEmpty
    //                     ? Expanded(
    //                         child: Center(
    //                           child: isProductAndServiceLoading
    //                               ? CircularLoadingIndicator()
    //                               : Text(
    //                                   "No Result",
    //                                   style: TextStyle(
    //                                       color: darkGrey, fontSize: 16),
    //                                 ),
    //                         ),
    //                       )
    //                     : Expanded(
    //                         child: ListView(
    //                           children: searchedProductAndService
    //                               .map((item) => InkWell(
    //                                   onTap: () {
    //                                     addProductOrServiceToChat(item);
    //                                   },
    //                                   child: getResultTile(item)))
    //                               .toList(),
    //                         ),
    //                       ),
    //               ],
    //             ),
    //           ),
    //         ),
    //       ),
    //       Card(
    //         margin: EdgeInsets.zero,
    //         child: Container(
    //           height: 58,
    //           width: MediaQuery.of(context).size.width,
    //           padding: EdgeInsets.only(
    //             left: 16,
    //           ),
    //           child: Row(
    //             children: <Widget>[
    //               closeSearchModuleBtn(),
    //               Expanded(
    //                 child: isProductSearch
    //                     ? searchProductTextField()
    //                     : searchServiceTextField(),
    //               ),
    //               searchProductOrServiceBtn(),
    //             ],
    //           ),
    //         ),
    //       ),
    //     ],
    //   );
    // }

    return Column(
      children: [
        Container(
          height: 54,
          child: Row(
            children: <Widget>[
              moreActionBtn(),
              Expanded(
                child: textMessageField(),
              ),
              sendMessageBtn(),
            ],
          ),
        ),
        showMoreAction ? moreActionsBtn() : Container()
      ],
    );
  }

  Widget moreActionBtn() {
    return IconButton(
        icon: Icon(
          showMoreAction ? SlydoAppIcon.close_2 : SlydoAppIcon.add,
          color: navyBlue,
          size: showMoreAction ? 22 : 20,
        ),
        onPressed: () async {
          if (FocusScope.of(context).hasFocus) {
            FocusScope.of(context).unfocus();
            Future.delayed(Duration(milliseconds: 100)).then((value) {
              showMoreAction = !showMoreAction;
              if (mounted) setState(() {});
            });
          } else {
            showMoreAction = !showMoreAction;
            if (mounted) setState(() {});
          }
        });
  }

  Widget moreActionsBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 28),
      child: Column(
        children: [
          Row(
            children: <Widget>[
              assignTitleToAction(text: "Request", child: requestMoneyBtn()),
              flexibleSpace(),
              assignTitleToAction(text: "Send", child: sendMoneyBtn()),
              flexibleSpace(),
              assignTitleToAction(text: "Image", child: addMediaButton()),
              flexibleSpace(),
              assignTitleToAction(text: "Voice", child: addVoiceBtn()),
            ],
          ),
          SizedBox(
            height: 16,
          ),
          Row(
            children: <Widget>[
              assignTitleToAction(
                  text: "Product/ Service",
                  child: searchProductAndServiceBtn()),
              flexibleSpace(),
            ],
          ),
        ],
      ),
    );
  }

  // Widget getSearchBarLayout() {
  //   if (isProductSearch || isServiceSearch) {
  //     return Column(
  //       children: [
  //         Card(
  //           elevation: 10,
  //           margin: EdgeInsets.zero,
  //           shadowColor: lightGrey,
  //           shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.only(
  //                   topLeft: Radius.circular(15),
  //                   topRight: Radius.circular(15))),
  //           child: ClipRRect(
  //             borderRadius: BorderRadius.only(
  //               topLeft: Radius.circular(15),
  //               topRight: Radius.circular(15),
  //             ),
  //             child: Container(
  //               height: MediaQuery.of(context).size.height / 3,
  //               width: MediaQuery.of(context).size.width,
  //               color: Colors.white,
  //               child: Column(
  //                 children: [
  //                   Container(
  //                       padding: EdgeInsets.symmetric(vertical: 4),
  //                       child: Text(
  //                         isProductSearch ? "Products" : "Services",
  //                         style: TextStyle(),
  //                       )),
  //                   searchedProductAndService.isEmpty
  //                       ? Expanded(
  //                           child: Center(
  //                             child: isProductAndServiceLoading
  //                                 ? CircularLoadingIndicator()
  //                                 : Text(
  //                                     "No Result",
  //                                     style: TextStyle(
  //                                         color: darkGrey, fontSize: 16),
  //                                   ),
  //                           ),
  //                         )
  //                       : Expanded(
  //                           child: ListView(
  //                             children: searchedProductAndService
  //                                 .map((item) => InkWell(
  //                                     onTap: () {
  //                                       addProductOrServiceToChat(item);
  //                                     },
  //                                     child: getResultTile(item)))
  //                                 .toList(),
  //                           ),
  //                         ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         ),
  //         Card(
  //           margin: EdgeInsets.zero,
  //           child: Container(
  //             height: 58,
  //             width: MediaQuery.of(context).size.width,
  //             padding: EdgeInsets.only(
  //               left: 16,
  //             ),
  //             child: Row(
  //               children: <Widget>[
  //                 closeSearchModuleBtn(),
  //                 Expanded(
  //                   child: isProductSearch
  //                       ? searchProductTextField()
  //                       : searchServiceTextField(),
  //                 ),
  //                 searchProductOrServiceBtn(),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ],
  //     );
  //   }
  //
  //   return Container(
  //     height: 58,
  //     padding: EdgeInsets.only(
  //       left: 16,
  //     ),
  //     child: Row(
  //       children: <Widget>[
  //         MediaQuery.of(context).viewInsets.bottom != 0
  //             ? addMediaButton()
  //             : Row(
  //                 children: [
  //                   requestMoneyBtn(),
  //                   SizedBox(
  //                     width: 8,
  //                   ),
  //                   sendMoneyBtn(),
  //                   SizedBox(
  //                     width: 8,
  //                   ),
  //                 ],
  //               ),
  //         Expanded(
  //           child: textMessageField(),
  //         ),
  //         sendAudioOrMessageBtn(),
  //       ],
  //     ),
  //   );
  // }

  Widget assignTitleToAction({String text, Widget child}) {
    return Container(
      constraints: BoxConstraints(maxWidth: 60),
      child: Column(
        children: [
          child,
          SizedBox(height: 10),
          Center(
            child: Text(text,
                style: TextStyle(
                    color: blackFont,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          )
        ],
      ),
    );
  }

  Widget requestMoneyBtn() {
    return RoundedBackgroundIcon(
      borderRadius: 20,
      height: 50,
      width: 50,
      icon: Icon(
        SlydoAppIcon.receive,
        color: navyBlue,
        size: 22,
      ),
      backgroundColor: navyBlue.withOpacity(0.08),
      onTap: () async {
        showMoreAction = false;
        if (mounted) setState(() {});

        var customerProfileBloc =
            Provider.of<CustomerProfileBloc>(context, listen: false);
        customerProfileBloc.customer =
            await UserAuth().fetchCustomerProfile(recipientUser.userName);
        Navigator.of(context).pushNamed(
          '/request-payment',
          arguments: <String, bool>{
            'isFromProfile': false,
            'isFromChat': true,
          },
        );
      },
    );
  }

  Widget sendMoneyBtn() {
    return RoundedBackgroundIcon(
      borderRadius: 20,
      height: 50,
      width: 50,
      icon: Icon(
        SlydoAppIcon.send,
        color: naturalGreen,
        size: 22,
      ),
      backgroundColor: navyBlue.withOpacity(0.08),
      onTap: () async {
        showMoreAction = false;
        if (mounted) setState(() {});
        var customerProfileBloc =
            Provider.of<CustomerProfileBloc>(context, listen: false);
        customerProfileBloc.customer =
            await UserAuth().fetchCustomerProfile(recipientUser.userName);
        Navigator.of(context).pushNamed(
          '/send-payment',
          arguments: <String, bool>{
            'isFromProfile': false,
            'isFromChat': true,
          },
        );
      },
    );
  }

  Widget addMediaButton() {
    return RoundedBackgroundIcon(
      borderRadius: 20,
      height: 50,
      width: 50,
      icon: Icon(
        SlydoAppIcon.image,
        color: blackFont,
        size: 18,
      ),
      backgroundColor: navyBlue.withOpacity(0.08),
      onTap: addMediaToMessage,
    );
  }

  Widget addVoiceBtn() {
    return RoundedBackgroundIcon(
      borderRadius: 20,
      height: 50,
      width: 50,
      icon: Icon(
        SlydoAppIcon.mic,
        color: blackFont,
        size: 18,
      ),
      backgroundColor: navyBlue.withOpacity(0.08),
      onTap: () async {
        await getAudioPermission();

        if (isAudioRecording) {
          debugPrint("Recording Stop ");
          isAudioRecording = false;
          setState(() {});
          await stopRecorder();
          setState(() {});
        } else if (!isAudioRecording && isAudioPermissionAccepted) {
          debugPrint("Starting Recording ");
          isAudioRecording = true;
          setState(() {});
          await recordAudio();
          setState(() {});
        } else {
          await getAudioPermission();
        }
      },
    );
  }

  Widget searchProductAndServiceBtn() {
    return RoundedBackgroundIcon(
      borderRadius: 20,
      height: 50,
      width: 50,
      icon: Icon(
        SlydoAppIcon.search,
        color: blackFont,
        size: 18,
      ),
      backgroundColor: navyBlue.withOpacity(0.08),
      onTap: () {
        showMoreAction = false;
        if (mounted) setState(() {});
        showSearchProductAndServiceBottomSheet();
      },
    );
  }

  // Widget textMessageField() {
  //   return Stack(
  //     alignment: Alignment.centerRight,
  //     children: [
  //       TextFormField(
  //         controller: messageController,
  //         textInputAction: TextInputAction.send,
  //         focusNode: messageFocus,
  //         onFieldSubmitted: (value) {
  //           sendTextMessage();
  //         },
  //         cursorColor: blackFont,
  //         cursorWidth: 1,
  //         cursorHeight: 20,
  //         cursorRadius: Radius.circular(16),
  //         decoration: InputDecoration(
  //           hintText: "Type message",
  //           hintStyle: TextStyle(
  //             color: darkGrey.withOpacity(0.5),
  //             fontSize: 16,
  //             fontWeight: FontWeight.w500,
  //           ),
  //           prefix: Padding(
  //             padding: EdgeInsets.only(left: 12),
  //           ),
  //           // suffixIcon: captureImageOrVideo(),
  //           contentPadding: EdgeInsets.symmetric(vertical: 10),
  //           isDense: true,
  //           enabledBorder: OutlineInputBorder(
  //             borderRadius: BorderRadius.circular(10),
  //             borderSide: BorderSide(
  //               color: greyBorderColor,
  //               width: 1.0,
  //             ),
  //           ),
  //           disabledBorder: OutlineInputBorder(
  //             borderRadius: BorderRadius.circular(10),
  //             borderSide: BorderSide(
  //               color: greyBorderColor,
  //               width: 1.0,
  //             ),
  //           ),
  //           focusedBorder: OutlineInputBorder(
  //             borderRadius: BorderRadius.circular(10),
  //             borderSide: BorderSide(
  //               color: navyBlue,
  //               width: 1.0,
  //             ),
  //           ),
  //           errorBorder: OutlineInputBorder(
  //             borderRadius: BorderRadius.circular(10),
  //             borderSide: BorderSide(
  //               color: greyBorderColor,
  //               width: 1.0,
  //             ),
  //           ),
  //           focusedErrorBorder: OutlineInputBorder(
  //             borderRadius: BorderRadius.circular(10),
  //             borderSide: BorderSide(
  //               color: greyBorderColor,
  //               width: 1.0,
  //             ),
  //           ),
  //         ),
  //       ),
  //       Positioned(
  //         child: captureImageOrVideoBtn(),
  //         right: 8,
  //       )
  //     ],
  //   );
  // }

  Widget textMessageField() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: Container(
        color: chatBackgroundColor,
        child: Stack(
          alignment: Alignment.centerRight,
          children: [
            TextFormField(
              controller: messageController,
              textInputAction: TextInputAction.send,
              focusNode: messageFocus,
              onFieldSubmitted: (value) {
                sendTextMessage();
              },
              cursorColor: blackFont,
              cursorWidth: 1,
              cursorHeight: 20,
              cursorRadius: Radius.circular(16),
              decoration: InputDecoration(
                hintText: "Type a message",
                hintStyle: TextStyle(
                  color: darkGrey,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                prefix: Padding(
                  padding: EdgeInsets.only(left: 16),
                ),
                suffix: Padding(
                  padding: EdgeInsets.only(right: 36),
                ),
                // suffixIcon: captureImageOrVideo(),
                contentPadding: EdgeInsets.symmetric(vertical: 10),
                isDense: true,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(3),
                  borderSide: BorderSide(
                    color: chatBackgroundColor,
                    width: 1.0,
                  ),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(3),
                  borderSide: BorderSide(
                    color: chatBackgroundColor,
                    width: 1.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(3),
                  borderSide: BorderSide(
                    color: chatBackgroundColor,
                    width: 1.0,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(3),
                  borderSide: BorderSide(
                    color: chatBackgroundColor,
                    width: 1.0,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(3),
                  borderSide: BorderSide(
                    color: chatBackgroundColor,
                    width: 1.0,
                  ),
                ),
              ),
            ),
            Positioned(
              child: captureImageOrVideoBtn(),
              right: 8,
            )
          ],
        ),
      ),
    );
  }

  void addProductOrServiceToChat(var item) async {
    String url = secureBaseUrl +
        "/api/v1/${item is Product ? "products" : "services"}/" +
        item.id +
        "/";

    Map<String, dynamic> itemData =
        await ShoppingAuthService().getProductOrService(url);

    Map<String, dynamic> data = {
      "meta_data": jsonEncode(itemData),
      "check_id": Uuid().v4(),
      "conversation_id": recipientUser.conversationId,
      "author": userBloc.user.userName,
      "message": url,
      "kind": item is Product ? "product" : "service",
      "created_at": DateTime.now().toUtc().toString(),
      "type": "chatroom_message",
    };

    bool result = await sendDataToSocket(data);
    if (result) {
      clearSearchedListItems();
      setState(() {});
    }
  }

  void addMediaToMessage() async {
    showMoreAction = false;
    if (mounted) setState(() {});

    List<String> allowedExtensions =
        imageExtensions + videoExtensions + audioExtensions;

    FilePickerResult pickedMedia = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: allowedExtensions);

    if (pickedMedia != null) {
      File file = File(pickedMedia.files.single.path);
      String mediaType = getFileType(pickedMedia);

      if (mediaType == "") {
        return;
      }

      var result = await Navigator.of(context).pushNamed(
        "/send-media-to-chat-message",
        arguments: {
          "data": {
            "conversation": recipientUser.conversationId,
            "author": userBloc.user.userName,
          },
          "media": file,
          "message": messageController.text.trim(),
          "mediaType": mediaType
        },
      ).catchError((error) {
        debugPrint("Error: = = = = $error");
      });

      if (result == null) return;

      messageController.text = "";
      debugPrint("Result:- $result");
    }
  }

  String getFileType(FilePickerResult pickedMedia) {
    String extension = pickedMedia.files.single.extension;

    if (imageExtensions.contains(extension)) return "image";
    if (videoExtensions.contains(extension)) return "video";
    if (audioExtensions.contains(extension)) return "audio";
    return "";
  }

  Future<String> selectMediaType() async {
    if (FocusScope.of(context).hasFocus) {
      FocusScope.of(context).unfocus();
    }

    var source = await showModalBottomSheet<String>(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (BuildContext context) {
          return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20)),
              ),
              color: Colors.white,
              margin: EdgeInsets.zero,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    bottomSheetItem(
                      title: "Image",
                      icon: Icons.image_rounded,
                      iconSize: 18,
                      onTap: () {
                        Navigator.pop(context, "image");
                      },
                    ),
                    bottomSheetItem(
                      title: "Video",
                      icon: Icons.video_call_rounded,
                      iconSize: 20,
                      isLast: true,
                      onTap: () {
                        Navigator.pop(context, "video");
                      },
                    ),
                  ],
                ),
              ));
        });
    return source;
  }

  Widget captureImageOrVideoBtn() {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 100),
      child: messageIsText
          ? Container(
              height: 0,
              width: 0,
            )
          : cameraIconBtn(),
    );
  }

  Widget cameraIconBtn() {
    return InkWell(
      child: ClipOval(
          child: Container(
        child: Icon(
          Icons.camera_alt_outlined,
          color: navyBlue,
          size: 22,
        ),
      )),
      onTap: captureImageOrVideo,
    );
  }

  void captureImageOrVideo() async {
    String mediaType = await selectMediaType();
    if (mediaType == null) return;

    String capturedMediaPath;

    if (mediaType == "image") {
      capturedMediaPath = await captureImage();
    } else if (mediaType == "video") {
      capturedMediaPath = await captureVideo();
    } else {
      return;
    }

    if (capturedMediaPath != null) {
      var result = await Navigator.of(context).pushNamed(
        "/send-media-to-chat-message",
        arguments: {
          "data": {
            "conversation": recipientUser.conversationId,
            "author": userBloc.user.userName,
          },
          "media": File(capturedMediaPath),
          "message": messageController.text.trim(),
          "mediaType": mediaType
        },
      ).catchError((error) {
        debugPrint("Error: = = = = $error");
      });

      if (result == null) return;

      messageController.text = "";
      debugPrint("Result:- $result");
    }
  }

  Future<String> captureImage() async {
    PickedFile media = await ImagePicker().getImage(source: ImageSource.camera);

    if (media == null) return null;

    return media.path;
  }

  Future<String> captureVideo() async {
    var path = await Navigator.of(context).pushNamed("/video-recorder",
        arguments: {"duration": Duration(seconds: 5)});

    if (path == null) return null;

    return path;
  }

  // Widget sendAudioOrMessageBtn() {
  //   return AnimatedSwitcher(
  //     duration: Duration(milliseconds: 100),
  //     child: messageIsText ? sendMessageBtn() : recordAndSendAudioBtn(),
  //   );
  // }

  Widget sendMessageBtn() {
    return InkWell(
      onTap: sendTextMessage,
      child: Container(
        padding: EdgeInsets.all(2),
        child: Row(
          children: [
            SizedBox(
              width: 10,
            ),
            Icon(
              SlydoAppIcon.send_message_2,
              color: navyBlue,
              size: 22,
            ),
            SizedBox(
              width: 12,
            ),
          ],
        ),
      ),
    );
  }

  Widget recordAndSendAudioBtn() {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 50,
        height: 50,
        child: InkWell(
          onTap: () async {
            await getAudioPermission();

            if (isAudioRecording) {
              debugPrint("Recording Stop ");
              isAudioRecording = false;
              setState(() {});
              await stopRecorder();
              setState(() {});
            } else if (!isAudioRecording && isAudioPermissionAccepted) {
              debugPrint("Starting Recording ");
              isAudioRecording = true;
              setState(() {});
              await recordAudio();
              setState(() {});
            } else {
              await getAudioPermission();
            }
          },
          splashColor: navyBlue.withOpacity(0.2),
          borderRadius: BorderRadius.circular(50),
          child: Icon(
            Icons.mic,
            color: navyBlue,
            size: 30,
          ),
        ),
      ),
    );
  }

  Future<bool> getAudioPermission() async {
    var status = await Permission.microphone.status;

    if (!status.isGranted) {
      var permission = await Permission.microphone.request();
      if (permission.isGranted) {
        isAudioPermissionAccepted = true;
        return true;
      }
      return false;
    }
    isAudioPermissionAccepted = true;
    return true;
  }

  Future<void> recordAudio() async {
    Directory tempDirectory = await getTemporaryDirectory();
    audioUuid = Uuid().v4();
    String filePath = '${tempDirectory.path}/$audioUuid.mp3';

    audioPath = filePath;

    Codec codec = Codec.defaultCodec;

    if (await audioRecorder.isEncoderSupported(codec)) {
      await audioRecorder
          .startRecorder(
        toFile: filePath,
        codec: codec,
      )
          .catchError((error) {
        debugPrint("Error:- while Recording Audio $error");
      });
      debugPrint("Audio Storing At $filePath");
    } else {
      Toast.show("Not Supported:- $codec", context);
    }
  }

  Future<void> stopRecorder() async {
    audioRecorder.stopRecorder().then((value) {
      debugPrint("Audio Stored");
      audioRecordingDuration = Duration.zero;
      sendAudioToServer();
    });
  }

  void sendAudioToServer() async {
    File mediaFile = File(audioPath);
    Map<String, dynamic> _data = {};
    _data['text'] = "";
    _data['check_id'] = audioUuid;
    _data['kind'] = "audio";
    _data['read_by_author'] = true;
    _data['read_by_recipient'] = false;
    _data["delivered"] = false;
    _data['created_at'] = DateTime.now().toUtc().toString();
    _data['type'] = "chatroom_message";
    _data["conversation"] = recipientUser.conversationId;
    _data["author"] = userBloc.user.userName;

    showDialog(
        context: context,
        builder: (context) => Center(
              child: CircularLoadingIndicator(),
            ));

    MessageAuth().sendSocketMessage(_data, mediaFile).then((value) {
      Navigator.pop(context);
      audioUuid = null;
      audioPath = null;
    }).catchError((error) {
      Navigator.pop(context);
      debugPrint("Error:- while uploading audio $error");
      audioUuid = null;
      audioPath = null;
    });
  }

  Widget renderDataAccordingType(String message) {
    // int randomInt = Random().nextInt(5);

    Map<String, dynamic> messageData = jsonDecode(message);

    String messageType = messageData["kind"];
    switch (messageType) {
      case "text":
        Widget getMessageUi = renderMessage(message: messageData);
        return getMessageUi;
        break;

      case "image":
        Widget getMessageUi = renderImageMedia(message: messageData);
        return getMessageUi;
        break;

      case "video":
        Widget getMessageUi = renderVideoMedia(message: messageData);
        return getMessageUi;
        break;

      case "audio":
        Widget getMessageUi = renderAudioMedia(message: messageData);
        return getMessageUi;
        break;

      case "transaction":
        Widget getPaymentUI = renderSendPayment(message: messageData);
        return getPaymentUI;

        break;
      case "payment-request":
        Widget getPaymentUI = renderPaymentRequest(message: messageData);
        return getPaymentUI;
        break;
      case "product":
        Widget getProductUI = renderProduct(item: messageData);
        return getProductUI;
        break;
      case "service":
        Widget getServiceUI = renderService(item: messageData);
        return getServiceUI;
        break;

      default:
        Widget getTypingUI = renderTypingMsg();
        return getTypingUI;
    }
  }

  void sendTextMessage() async {
    String message = messageController.text.trim();

    if (message.isEmpty) {
      return;
    }

    showMoreAction = false;
    if (mounted) setState(() {});

    Map<String, dynamic> data = {
      "check_id": Uuid().v4(),
      "conversation_id": recipientUser.conversationId,
      "author": userBloc.user.userName,
      "message": message,
      "kind": "text",
      "read_by_author": true,
      "read_by_recipient": false,
      "delivered": false,
      "created_at": DateTime.now().toUtc().toString(),
      "type": "chatroom_message",
    };

    String payload = convertServerPayload(data);

    addMessageToChat(message: payload);

    bool result = await sendDataToSocket(data);
    if (result) {
      messageController.text = "";
      setState(() {});
    }
  }

  String convertServerPayload(Map<String, dynamic> data) {
    Map<String, dynamic> newData = {};
    newData["check_id"] = data["check_id"];
    newData["conversation"] = data["conversation_id"];
    newData["author"] = data["author"];
    newData["text"] = data["message"];
    newData["kind"] = data["kind"];
    newData["read_by_author"] = data["read_by_author"];
    newData["read_by_recipient"] = data["read_by_recipient"];
    newData["delivered"] = data["delivered"];
    newData["created_at"] = data["created_at"];
    newData["updated_at"] = data["updated_at"];
    newData["type"] = data["type"];
    newData["was_edited"] = false;
    newData["deleted_for_recipient"] = false;
    newData["deleted_for_author"] = false;
    newData["meta_data"] = {};

    return jsonEncode(newData);
  }

  Future<bool> sendDataToSocket(Map<String, dynamic> data) async {
    /// this is a second level of protection to ensure the connection
    /// this code of bloc is replicated in userTyping()

    await mainSocketProvider.add(data);
    // bool isDataAdded = await mainSocketProvider.add(data);
    // if (!isDataAdded) {
    //   debugPrint("Error:- while adding Data");
    //   return await sendDataToSocket(data);
    // }

    return true;
  }

  Widget scaffoldBody() {
    return Container(
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                isRecipientLoading
                    ? Center(child: CircularLoadingIndicator())
                    : Theme(
                        data: ThemeData(highlightColor: navyBlue),
                        child: Scrollbar(
                          controller: messageScrollController,
                          radius: Radius.circular(10),
                          thickness: 3,
                          child: messageListBuilder(),
                        ),
                      ),
                isAudioRecording ? getAudioRecordingWidget() : Container(),
              ],
            ),
          ),
          messageActionBar()
        ],
      ),
    );
  }

  // isAudioRecording ? getAudioRecordingWidget() : Container(),

  Widget getAudioRecordingWidget() {
    return Container(
      color: Colors.black87,
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 200,
            height: 200,
            child: FlareActor(
              "assets/images/flare/voice_record_active.flr",
              animation: "record",
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            "${formatDurationInSeconds(duration: audioRecordingDuration)}",
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget messageListBuilder() {
    return LazyLoadScrollView(
      isLoading: isLoading,
      onEndOfPage: getPreviousMessages,
      child: ListView.builder(
        reverse: true,
        controller: messageScrollController,
        padding: EdgeInsets.symmetric(vertical: 4),
        //+1 for progressbar
        itemCount: messageList.length + 1,
        itemBuilder: (BuildContext context, int index) {
          if (index == messageList.length) {
            return _buildIndicator();
          }
          return Container(
            child: renderDataAccordingType(messageList[index]),
            padding: EdgeInsets.only(bottom: 4),
          );
        },
      ),
    );
  }

  Widget _buildIndicator() {
    return isLoading
        ? Padding(
            padding: const EdgeInsets.all(8.0),
            child: new Center(
              child: new Opacity(
                opacity: isLoading ? 1.0 : 00,
                child: CircularLoadingIndicator(),
              ),
            ),
          )
        : Container();
  }

  String messageDecoderWithEmoji(String text) {
    try {
      List<int> bytes = text.toString().codeUnits;
      return utf8.decode(bytes);
    } catch (error) {
      return text;
    }
  }

  Widget renderMessage({Map<String, dynamic> message}) {
    bool isSend = message["author"] == userBloc.user.userName;
    return GestureDetector(
      onLongPress: () {
        Clipboard.setData(
            new ClipboardData(text: messageDecoderWithEmoji(message['text'])));
        Toast.show("Text copied !!", context,
            gravity: Toast.BOTTOM,
            duration: Toast.LENGTH_LONG,
            backgroundColor: navyBlue,
            textColor: Colors.white);
      },
      child: Row(
        mainAxisAlignment:
            isSend ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment:
                isSend ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  isSend
                      ? Container()
                      : Container(
                          width: 20,
                        ),
                  Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.8,
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSend ? navyBlue : chatBackgroundColor,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(!isSend ? 0 : 10),
                          bottomRight: Radius.circular(isSend ? 0 : 10),
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              messageDecoderWithEmoji(message['text']),
                              style: TextStyle(
                                color: isSend ? Colors.white : blackFont,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      )),
                  isSend
                      ? Container(
                          width: 20,
                          child: isSend
                              ? Center(
                                  child: getMessageTick(message: message),
                                )
                              : Container(),
                        )
                      : Container(),
                ],
              ),
              SizedBox(
                height: 1,
              ),
              Row(
                children: [
                  isSend
                      ? Container()
                      : SizedBox(
                          width: 20,
                        ),
                  Text(
                    formatTime(message['created_at']),
                    style: TextStyle(
                        color: darkGrey,
                        fontSize: 10,
                        fontWeight: FontWeight.w500),
                  ),
                  isSend
                      ? SizedBox(
                          width: 20,
                        )
                      : Container(),
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  String getDateTime(String dateAndTime) {
    DateTime requestTime = DateTime.parse(dateAndTime);
    String date = DateFormat("dd/MM/yyyy").format(requestTime);
    String time = DateFormat("hh:mm a").format(requestTime);
    return "$date • $time";
  }

  Widget renderImageMedia({Map<String, dynamic> message}) {
    bool isSend = message["author"] == userBloc.user.userName;
    String messageText = message['text'] ?? "";
    bool isMessageEmpty = messageText == "";

    return Column(
      children: [
        Row(
          mainAxisAlignment:
              isSend ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            isSend
                ? Container()
                : Container(
                    width: 20,
                  ),
            GestureDetector(
              onTap: () {
                var result = Navigator.of(context).pushNamed(
                  "/view-chat-media",
                  arguments: {
                    "type": "image",
                    "file": message['media'],
                    "message": message['text'],
                    "poster": message["poster"] ?? null
                  },
                );

                debugPrint("Result:- $result");
              },
              onLongPress: () {
                Clipboard.setData(new ClipboardData(
                    text: message['text'] ?? message['media']));
                Toast.show("Text copied !!", context,
                    gravity: Toast.BOTTOM,
                    duration: Toast.LENGTH_LONG,
                    backgroundColor: navyBlue,
                    textColor: Colors.white);
              },
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width / 1.30,
                  minWidth: MediaQuery.of(context).size.width / 1.30,
                ),
                decoration: BoxDecoration(
                  color: isMessageEmpty
                      ? Colors.transparent
                      : isSend
                          ? navyBlue
                          : chatBackgroundColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(!isSend ? 0 : 10),
                    bottomRight: Radius.circular(isSend ? 0 : 10),
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                padding: EdgeInsets.only(
                    top: isMessageEmpty ? 0 : 8,
                    bottom: isMessageEmpty ? 0 : 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    isMessageEmpty
                        ? Container()
                        : Container(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    messageText,
                                    style: TextStyle(
                                        color:
                                            isSend ? Colors.white : blackFont,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ),
                              ],
                            ),
                          ),
                    isMessageEmpty
                        ? Container()
                        : SizedBox(
                            height: 8,
                          ),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: isMessageEmpty ? 0 : 8),
                      child: ClipRRect(
                        child: CachedNetworkImage(
                          height: MediaQuery.of(context).size.width / 2.2,
                          width: MediaQuery.of(context).size.width / 1.30,
                          imageUrl: message['media'],
                          fit: BoxFit.cover,
                          progressIndicatorBuilder:
                              (context, url, downloadProgress) => Center(
                            child: CircularProgressIndicator(
                              value: downloadProgress.progress,
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation(
                                  isSend ? Colors.white : navyBlue),
                              backgroundColor: Colors.transparent,
                            ),
                          ),
                          errorWidget: imageErrorWidget,
                        ),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            isSend
                ? Container(
                    width: 20,
                    child: isSend
                        ? Center(
                            child: getMessageTick(message: message),
                          )
                        : Container(),
                  )
                : Container(),
          ],
        ),
        SizedBox(
          height: 1,
        ),
        Row(
          mainAxisAlignment:
              isSend ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            isSend
                ? Container()
                : SizedBox(
                    width: 20,
                  ),
            Text(
              formatTime(message['created_at']),
              style: TextStyle(
                  color: darkGrey, fontSize: 10, fontWeight: FontWeight.w500),
            ),
            isSend
                ? SizedBox(
                    width: 20,
                  )
                : Container(),
          ],
        )
      ],
    );
  }

  Widget renderAudioMedia({Map<String, dynamic> message}) {
    return new ChatAudioPlayer(message: message);
  }

  Future<Uint8List> getVideoThumbnail(String url) async {
    Uint8List uInt8list = await VideoThumbnail.thumbnailData(
      video: url,
      imageFormat: ImageFormat.JPEG,
      maxWidth:
          512, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
      quality: 25,
    );

    return uInt8list;
  }

  Widget renderVideoMedia({Map<String, dynamic> message}) {
    bool isSend = message["author"] == userBloc.user.userName;
    String messageText = message['text'] ?? "";
    bool isMessageEmpty = messageText == "";

    return Column(
      children: [
        Row(
          mainAxisAlignment:
              isSend ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            isSend
                ? Container()
                : Container(
                    width: 20,
                  ),
            GestureDetector(
              onTap: () {
                var result = Navigator.of(context).pushNamed(
                  "/view-chat-media",
                  arguments: {
                    "type": "video",
                    "file": message["media"],
                    "message": message['text']
                  },
                );
                debugPrint("Result:- $result");
              },
              onLongPress: () {
                Clipboard.setData(new ClipboardData(
                    text: message['text'] ?? message['media']));
                Toast.show("Text copied !!", context,
                    gravity: Toast.BOTTOM,
                    duration: Toast.LENGTH_LONG,
                    backgroundColor: navyBlue,
                    textColor: Colors.white);
              },
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width / 1.30,
                  minWidth: MediaQuery.of(context).size.width / 1.30,
                ),
                decoration: BoxDecoration(
                  color: isMessageEmpty
                      ? Colors.transparent
                      : isSend
                          ? navyBlue
                          : chatBackgroundColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(!isSend ? 0 : 10),
                    bottomRight: Radius.circular(isSend ? 0 : 10),
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                padding: EdgeInsets.only(
                    top: isMessageEmpty ? 0 : 8,
                    bottom: isMessageEmpty ? 0 : 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    isMessageEmpty
                        ? Container()
                        : Container(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    messageText,
                                    style: TextStyle(
                                        color:
                                            isSend ? Colors.white : blackFont,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ),
                              ],
                            ),
                          ),
                    isMessageEmpty
                        ? Container()
                        : SizedBox(
                            height: 8,
                          ),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: isMessageEmpty ? 0 : 8),
                      child: Stack(
                        children: [
                          ClipRRect(
                            child: CachedNetworkImage(
                              height: MediaQuery.of(context).size.width / 2.2,
                              width: MediaQuery.of(context).size.width / 1.30,
                              imageUrl: message["poster"] ??
                                  "https://c1.iggcdn.com/indiegogo-media-prod-cld/image/upload/c_fill,f_auto,h_630,w_1200/v1506734779/wcsmythcukjuuglotjvb.jpg",
                              fit: BoxFit.cover,
                              color: Colors.black38,
                              colorBlendMode: BlendMode.darken,
                              progressIndicatorBuilder:
                                  (context, url, downloadProgress) => Center(
                                child: CircularProgressIndicator(
                                  value: downloadProgress.progress,
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation(
                                      isSend ? Colors.white : navyBlue),
                                  backgroundColor: Colors.transparent,
                                ),
                              ),
                              errorWidget: imageErrorWidget,
                            ),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          Container(
                            height: MediaQuery.of(context).size.width / 2.2,
                            width: MediaQuery.of(context).size.width / 1.30,
                            child: Center(
                              child: ClipOval(
                                child: Container(
                                  height: 60,
                                  width: 60,
                                  color: Colors.white.withOpacity(0.2),
                                  child: Center(
                                    child: Icon(
                                      Icons.play_arrow_rounded,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            isSend
                ? Container(
                    width: 20,
                    child: isSend
                        ? Center(
                            child: getMessageTick(message: message),
                          )
                        : Container(),
                  )
                : Container(),
          ],
        ),
        SizedBox(
          height: 1,
        ),
        Row(
          mainAxisAlignment:
              isSend ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            isSend
                ? Container()
                : SizedBox(
                    width: 20,
                  ),
            Text(
              formatTime(message['created_at']),
              style: TextStyle(
                  color: darkGrey, fontSize: 10, fontWeight: FontWeight.w500),
            ),
            isSend
                ? SizedBox(
                    width: 20,
                  )
                : Container(),
          ],
        )
      ],
    );
  }

  Widget renderPaymentRequest({Map<String, dynamic> message}) {
    // bool isSent = message["author"] == userBloc.user.userName;
    // bool isSent = false;

    // PaymentRequest paymentRequest = PaymentRequest.fromJson(
    //     jsonDecode(message['text']),
    //     currentUser: userBloc.user);

    // PaymentRequest paymentRequest = PaymentRequest(
    //     description: "Shopping", amount: 100, payee: "black", currency: "NGN");

    // message["text"] = message['text'] = jsonEncode({
    //   "description": "Shopping",
    //   "amount": 100,
    //   "payee": "black",
    //   "currency": "NGN",
    //   "status": "Paid",
    //   "is_credit": true
    // });

    return PaymentRequestTileForChat(message: message, userBloc: userBloc);

    // return GestureDetector(
    //   onLongPress: () {
    //     if (paymentRequest.description.isNotEmpty) {
    //       Clipboard.setData(
    //           new ClipboardData(text: paymentRequest.description));
    //       Toast.show("Text copied !!", context,
    //           gravity: Toast.BOTTOM,
    //           duration: Toast.LENGTH_LONG,
    //           backgroundColor: navyBlue,
    //           textColor: Colors.white);
    //     }
    //   },
    //   child: Row(
    //     mainAxisAlignment:
    //         isSent ? MainAxisAlignment.end : MainAxisAlignment.start,
    //     children: [
    //       Container(
    //         decoration: BoxDecoration(
    //           color: chatBackgroundColor,
    //           border: Border.all(color: chatBackgroundColor),
    //           borderRadius: BorderRadius.only(
    //             bottomLeft: Radius.circular(!isSent ? 0 : 10),
    //             bottomRight: Radius.circular(isSent ? 0 : 10),
    //             topLeft: Radius.circular(10),
    //             topRight: Radius.circular(10),
    //           ),
    //         ),
    //         padding: EdgeInsets.all(8),
    //         width: MediaQuery.of(context).size.width / 1.8,
    //         child: Column(
    //           crossAxisAlignment: CrossAxisAlignment.center,
    //           mainAxisSize: MainAxisSize.min,
    //           children: [
    //             Row(
    //               children: [
    //                 Padding(
    //                   padding: const EdgeInsets.only(top: 4.0),
    //                   child: Icon(
    //                     SlydoAppIcon.naira,
    //                     color: blackFont,
    //                     size: 16,
    //                   ),
    //                 ),
    //                 SizedBox(
    //                   width: 2,
    //                 ),
    //                 Text(
    //                   paymentRequest.amount.toString(),
    //                   style: TextStyle(
    //                       fontSize: 32,
    //                       fontWeight: FontWeight.w600,
    //                       color: blackFont),
    //                 ),
    //               ],
    //             ),
    //             SizedBox(
    //               height: 4,
    //             ),
    //             Align(
    //               alignment: Alignment.centerLeft,
    //               child: Text(
    //                 paymentRequest.description,
    //                 style: TextStyle(
    //                     fontSize: 14,
    //                     fontWeight: FontWeight.w400,
    //                     color: blackFont),
    //               ),
    //             ),
    //             SizedBox(
    //               height: 6,
    //             ),
    //             Container(
    //               child: isSent
    //                   ? Row(
    //                       children: <Widget>[
    //                         Expanded(
    //                           child: Container(),
    //                         ),
    //                         SizedBox(
    //                           width: 8,
    //                         ),
    //                         Expanded(
    //                           child: CurvedButton(
    //                             text: "Cancel",
    //                             height: 36,
    //                             backgroundColor: navyBlue,
    //                             textColor: Colors.white,
    //                             onPressed: () {},
    //                           ),
    //                         ),
    //                       ],
    //                     )
    //                   : Row(
    //                       children: <Widget>[
    //                         Expanded(
    //                           child: CurvedButton(
    //                             text: "Pay",
    //                             height: 36,
    //                             backgroundColor: navyBlue,
    //                             textColor: Colors.white,
    //                             onPressed: () async {
    //                               var response = await PaymentAndBankingAuth()
    //                                   .acceptPaymentRequests(paymentRequest,
    //                                       messageId: message["message_id"]);
    //                             },
    //                           ),
    //                         ),
    //                         SizedBox(
    //                           width: 8,
    //                         ),
    //                         Expanded(
    //                           child: CurvedButton(
    //                             height: 36,
    //                             text: "Reject",
    //                             backgroundColor: navyBlue,
    //                             textColor: Colors.white,
    //                             onPressed: () async {
    //                               var result = await PaymentAndBankingAuth()
    //                                   .rejectPaymentRequests(paymentRequest,
    //                                       messageId: message["message_id"]);
    //                             },
    //                           ),
    //                         ),
    //                       ],
    //                     ),
    //             ),
    //           ],
    //         ),
    //       ),
    //     ],
    //   ),
    // );
  }

  Widget renderSendPayment({Map<String, dynamic> message}) {
    bool isSent = message["author"] == userBloc.user.userName;

    // bool isSent = false;

    // PaymentRequest paymentRequest = PaymentRequest.fromJson(
    //     jsonDecode(message['text']),
    //     currentUser: userBloc.user);

    // Transaction transaction = Transaction.fromJson(jsonDecode(message['text']));
    // Transaction transaction = Transaction(
    //     description: "Shopping",
    //     amount: 100,
    //     payee: "black",
    //     currency: "NGN",
    //     status: "Paid");

    // message['text'] = jsonEncode({
    //   "description": "Shopping",
    //   "amount": 100,
    //   "payee": "black",
    //   "currency": "NGN",
    //   "status": "Paid",
    //   "is_credit": true
    // });
    return TransactionTileForChat(message: message, userBloc: userBloc);

    // return GestureDetector(
    //   onLongPress: () {
    //     if (transaction.description.isNotEmpty) {
    //       Clipboard.setData(new ClipboardData(text: transaction.description));
    //       Toast.show("Text copied !!", context,
    //           gravity: Toast.BOTTOM,
    //           duration: Toast.LENGTH_LONG,
    //           backgroundColor: navyBlue,
    //           textColor: Colors.white);
    //     }
    //   },
    //   child: Row(
    //     mainAxisAlignment:
    //         isSent ? MainAxisAlignment.end : MainAxisAlignment.start,
    //     children: [
    //       Container(
    //         decoration: BoxDecoration(
    //           color: chatBackgroundColor,
    //           border: Border.all(color: chatBackgroundColor),
    //           borderRadius: BorderRadius.only(
    //             bottomLeft: Radius.circular(!isSent ? 0 : 10),
    //             bottomRight: Radius.circular(isSent ? 0 : 10),
    //             topLeft: Radius.circular(10),
    //             topRight: Radius.circular(10),
    //           ),
    //         ),
    //         padding: EdgeInsets.all(8),
    //         width: MediaQuery.of(context).size.width / 1.8,
    //         child: Column(
    //           crossAxisAlignment: CrossAxisAlignment.center,
    //           mainAxisSize: MainAxisSize.min,
    //           children: [
    //             Row(
    //               children: [
    //                 Padding(
    //                   padding: const EdgeInsets.only(top: 4.0),
    //                   child: Icon(
    //                     SlydoAppIcon.naira,
    //                     color: blackFont,
    //                     size: 14,
    //                   ),
    //                 ),
    //                 SizedBox(
    //                   width: 2,
    //                 ),
    //                 Text(
    //                   transaction.amount.toString(),
    //                   style: TextStyle(
    //                       fontSize: 32,
    //                       fontWeight: FontWeight.w600,
    //                       color: blackFont),
    //                 ),
    //               ],
    //             ),
    //             SizedBox(
    //               height: 4,
    //             ),
    //             Align(
    //               alignment: Alignment.centerLeft,
    //               child: Text(
    //                 transaction.description,
    //                 style: TextStyle(
    //                     fontSize: 14,
    //                     fontWeight: FontWeight.w400,
    //                     color: blackFont),
    //               ),
    //             ),
    //             SizedBox(
    //               height: 6,
    //             ),
    //             Container(
    //               child: Row(
    //                 children: [
    //                   Icon(
    //                     SlydoAppIcon.true_icon,
    //                     size: 12,
    //                     color: naturalGreen,
    //                   ),
    //                   SizedBox(
    //                     width: 4,
    //                   ),
    //                   Text(
    //                     isSent
    //                         ? "You paid • ${getDateTime(transaction.createdAt)}"
    //                         : "You were paid • 10:13 AM",
    //                     style: TextStyle(color: blackFont, fontSize: 12),
    //                   )
    //                 ],
    //               ),
    //             ),
    //           ],
    //         ),
    //       ),
    //     ],
    //   ),
    // );
  }

  Widget renderProduct({Map<String, dynamic> item}) {
    return ProductTileForChatMessage(item: item);

    // Product product;
    // try {
    //   product = Product.fromJson(jsonDecode(item["meta_data"]));
    // } catch (e) {
    //   product = Product.fromJson(item["meta_data"]);
    // }
    //
    // bool isSend = item["author"] == userBloc.user.userName;
    // return GestureDetector(
    //   onTap: () {
    //     Navigator.of(context)
    //         .pushNamed("/product", arguments: {"product": product});
    //   },
    //   child: Row(
    //     mainAxisAlignment:
    //         isSend ? MainAxisAlignment.end : MainAxisAlignment.start,
    //     children: [
    //       Container(
    //         constraints: BoxConstraints(
    //           maxWidth: MediaQuery.of(context).size.width / 1.35,
    //           minWidth: MediaQuery.of(context).size.width / 1.35,
    //           maxHeight: MediaQuery.of(context).size.width / 1.35,
    //         ),
    //         decoration: BoxDecoration(
    //             color: Colors.white,
    //             border: Border.all(color: dividerColor),
    //             borderRadius: BorderRadius.circular(12)),
    //         padding: EdgeInsets.all(8),
    //         child: Column(
    //           mainAxisSize: MainAxisSize.min,
    //           children: [
    //             Expanded(
    //               child: CachedNetworkImage(
    //                 width: MediaQuery.of(context).size.width / 1.35 - 16,
    //                 imageUrl: product.cover,
    //                 fit: BoxFit.cover,
    //               ),
    //             ),
    //             SizedBox(
    //               height: 8,
    //             ),
    //             Text(
    //               product.name,
    //               style: TextStyle(
    //                 fontSize: 16,
    //               ),
    //               maxLines: 2,
    //               overflow: TextOverflow.ellipsis,
    //               textAlign: TextAlign.start,
    //             ),
    //             SizedBox(
    //               height: 8,
    //             ),
    //             Row(
    //               mainAxisAlignment: MainAxisAlignment.center,
    //               children: [
    //                 Icon(
    //                   SlydoAppIcon.naira,
    //                   color: blackFont,
    //                   size: 12,
    //                 ),
    //                 SizedBox(
    //                   width: 6,
    //                 ),
    //                 Text(
    //                   product.price.toString(),
    //                   style: TextStyle(
    //                       fontSize: 28,
    //                       fontWeight: FontWeight.w600,
    //                       color: blackFont),
    //                 ),
    //               ],
    //             ),
    //             product.seller == userBloc.user.userName
    //                 ? Container()
    //                 : Column(
    //                     children: [
    //                       SizedBox(
    //                         height: 8,
    //                       ),
    //                       Row(
    //                         children: [
    //                           Expanded(
    //                             child: CurvedButton(
    //                               height: 36,
    //                               textColor: Colors.white,
    //                               backgroundColor: navyBlue,
    //                               text: "Buy",
    //                               onPressed: () async {
    //                                 CustomerProfileBloc customerProfileBloc =
    //                                     Provider.of<CustomerProfileBloc>(
    //                                         context,
    //                                         listen: false);
    //                                 customerProfileBloc.customer =
    //                                     await UserAuth().fetchCustomerProfile(
    //                                         product.seller);
    //
    //                                 Navigator.of(context).pushNamed(
    //                                   '/send-payment',
    //                                   arguments: {
    //                                     'isFromProfile': false,
    //                                     'product': product
    //                                   },
    //                                 );
    //                               },
    //                             ),
    //                           ),
    //                           SizedBox(
    //                             width: 8,
    //                           ),
    //                           addToCartWidget(item: product),
    //                         ],
    //                       ),
    //                     ],
    //                   )
    //           ],
    //         ),
    //       ),
    //     ],
    //   ),
    // );
  }

  Widget addToCartWidget({var item}) {
    return RoundedBackgroundIcon(
      borderRadius: 16,
      height: 38,
      width: 38,
      icon: Icon(
        SlydoAppIcon.add_cart,
        color: navyBlue,
        size: 20,
      ),
      backgroundColor: navyBlue.withOpacity(0.08),
      onTap: () async {
        String type = item is Product ? "product" : "service";
        debugPrint("item $item type:- $type");
        basketBloc.addItemToCart(item: item, type: type);
        var mapData;
        basketBloc.items.forEach((element) {
          if (element["item"].id == item.id) {
            mapData = element;
            return;
          }
        });
        Map data = {
          "type": type,
          "id": mapData["item"].id,
          "qty": mapData["qty"],
        };
        debugPrint("Data From Product Page : $data");
        Toast.show("Item added to the cart !!", context);
        await ShoppingAuthService().addItemToShoppingCart(data);
      },
    );
  }

  Widget renderService({Map<String, dynamic> item}) {
    return ServiceTileChatMessage(item: item);

    // Service service;
    // try {
    //   service = Service.fromJson(jsonDecode(item["meta_data"]));
    // } catch (e) {
    //   service = Service.fromJson(item["meta_data"]);
    // }
    // bool isSend = widget.item["author"] == userBloc.user.userName;

    // return GestureDetector(
    //   onTap: () {
    //     Navigator.of(context)
    //         .pushNamed("/service-detail", arguments: {"service": service});
    //   },
    //   child: Row(
    //     mainAxisAlignment:
    //         isSend ? MainAxisAlignment.end : MainAxisAlignment.start,
    //     children: [
    //       Container(
    //         constraints: BoxConstraints(
    //           maxWidth: MediaQuery.of(context).size.width / 1.35,
    //           minWidth: MediaQuery.of(context).size.width / 1.35,
    //           maxHeight: MediaQuery.of(context).size.width / 1.35,
    //         ),
    //         decoration: BoxDecoration(
    //             color: Colors.white,
    //             border: Border.all(color: dividerColor),
    //             borderRadius: BorderRadius.circular(12)),
    //         padding: EdgeInsets.all(8),
    //         child: Column(
    //           mainAxisSize: MainAxisSize.min,
    //           children: [
    //             Expanded(
    //               child: CachedNetworkImage(
    //                 width: MediaQuery.of(context).size.width / 1.35 - 16,
    //                 imageUrl: service.cover,
    //                 fit: BoxFit.cover,
    //               ),
    //             ),
    //             SizedBox(
    //               height: 8,
    //             ),
    //             Text(
    //               service.name,
    //               style: TextStyle(
    //                 fontSize: 16,
    //               ),
    //               maxLines: 2,
    //               overflow: TextOverflow.ellipsis,
    //               textAlign: TextAlign.start,
    //             ),
    //             SizedBox(
    //               height: 8,
    //             ),
    //             Row(
    //               mainAxisAlignment: MainAxisAlignment.center,
    //               children: [
    //                 Icon(
    //                   SlydoAppIcon.naira,
    //                   color: blackFont,
    //                   size: 12,
    //                 ),
    //                 SizedBox(
    //                   width: 6,
    //                 ),
    //                 Text(
    //                   service.price.toString(),
    //                   style: TextStyle(
    //                       fontSize: 28,
    //                       fontWeight: FontWeight.w600,
    //                       color: blackFont),
    //                 ),
    //               ],
    //             ),
    //             service.provider == userBloc.user.userName
    //                 ? Container()
    //                 : Column(
    //                     children: [
    //                       SizedBox(
    //                         height: 8,
    //                       ),
    //                       Row(
    //                         children: [
    //                           Expanded(
    //                             child: CurvedButton(
    //                               height: 36,
    //                               textColor: Colors.white,
    //                               backgroundColor: navyBlue,
    //                               text: "Buy",
    //                               onPressed: () async {
    //                                 CustomerProfileBloc customerProfileBloc =
    //                                     Provider.of<CustomerProfileBloc>(
    //                                         context,
    //                                         listen: false);
    //                                 customerProfileBloc.customer =
    //                                     await UserAuth().fetchCustomerProfile(
    //                                         service.provider);
    //
    //                                 Navigator.of(context).pushNamed(
    //                                   '/send-payment',
    //                                   arguments: {
    //                                     'isFromProfile': false,
    //                                     'service': service
    //                                   },
    //                                 );
    //                               },
    //                             ),
    //                           ),
    //                           SizedBox(
    //                             width: 8,
    //                           ),
    //                           addToCartWidget(item: service),
    //                         ],
    //                       ),
    //                     ],
    //                   ),
    //           ],
    //         ),
    //       ),
    //     ],
    //   ),
    // );
  }

  Widget renderTypingMsg() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [Text("Typing...")],
    );
  }

  void checkMessageForRead() {
    messageList.forEach((element) {
      ///{id: e2230d61-c7e6-4825-a7c2-318a47671ff0,
      /// check_id: 1eb55ef5-87c3-4d85-9bd5-6f277a52b4f8,
      /// conversation: 3fe1e3b6-5802-4ade-b4f3-8f21d7b8ebd7,
      /// author: black, text: 5, read_by_author: true,
      /// read_by_recipient: true, was_edited: false,
      /// media: null, poster: null,
      /// updated_at: 2021-01-20T08:17:17.812159+01:00,
      /// created_at: 2021-01-20T08:17:17.812186+01:00,
      /// kind: text, deleted_for_recipient: false,
      /// deleted_for_author: false, delivered: true,
      /// meta_data: {}}
      Map<String, dynamic> messageData = jsonDecode(element);

      if (messageData["author"] != userBloc.user.userName) {
        if (messageData["read_by_recipient"] == false) {
          storeMessagesTemporary(message: element);
        }
      }
    });

    acknowledgeThatMessageAreRead();
  }

  void showSearchProductAndServiceBottomSheet() async {
    var result = await showModalBottomSheet<String>(
        backgroundColor: Colors.transparent,
        context: context,
        useRootNavigator: true,
        barrierColor: Colors.black54,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (context, StateSetter bottomSheetStateSetter) {
            bottomSheetStateSetterGlobal = bottomSheetStateSetter;
            bottomSheetMounted = true;
            return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20)),
                ),
                color: Colors.white,
                margin: EdgeInsets.zero,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.88,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: searchBox()),
                      SizedBox(
                        height: 8,
                      ),
                      Expanded(child: bottomSheetTabBar())
                    ],
                  ),
                ));
          });
        });
    bottomSheetMounted = false;
    if (result == null) {
      if (itemSearchTypeSelectionMenu.isMenuOpen) {
        itemSearchTypeSelectionMenu.closeMenu();
      }
    }
  }

  Widget searchBox() {
    return Container(
      child: Theme(
        data: Theme.of(context).copyWith(
          textSelectionHandleColor: navyBlue,
        ),
        child: TextFormField(
          key: searchItemTextFormField,
          controller: searchItemTextController,
          style: TextStyle(
            fontSize: 16,
            color: blackFont,
            fontWeight: FontWeight.w600,
          ),
          cursorWidth: 1.5,
          cursorColor: navyBlue,
          decoration: InputDecoration(
            hintText: "Search here",
            fillColor: Colors.white,
            filled: true,
            contentPadding: EdgeInsets.symmetric(vertical: 10),
            prefixIcon: searchTypeSelection(),
            prefix: Padding(
              padding: EdgeInsets.only(left: 12),
            ),
            suffixIcon: searchIcon(),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: dividerColor,
                width: 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: navyBlue,
                width: 1.0,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: dividerColor,
                width: 1.0,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: dividerColor,
                width: 1.0,
              ),
            ),
          ),
          onFieldSubmitted: (val) {
            if (mounted) {
              FocusScope.of(context).unfocus();
              searchProductOrService();
            }
          },
        ),
      ),
    );
  }

  Widget searchIcon() {
    return IconButton(
      icon: Icon(
        SlydoAppIcon.search,
        color: darkGrey,
        size: 16,
      ),
      onPressed: () {
        FocusScope.of(context).unfocus();
        searchProductOrService();
      },
    );
  }

  void searchProductOrService() {
    clearSearchedListItems();
    getProductOrServiceList();
    // if (isProductSearch) {
    //   searchProduct();
    // } else if (isServiceSearch) {
    //   searchService();
    // }
  }

  void clearSearchedListItems() {
    // searchItemTextController.text = "";
    searchedProductAndService.clear();
    productOrServiceCount = 0;
    productOrServiceNext = "";
    productOrServicePrevious = "";
    if (bottomSheetStateSetterGlobal != null) if (bottomSheetMounted)
      bottomSheetStateSetterGlobal(() {});
  }

  void searchProduct() async {
    if (searchItemTextController.text.length > 3) {
      String url = getSearchUrl() + searchItemTextController.text;

      searchedProductAndService.clear();
      isProductAndServiceLoading = true;
      noSearchedItem = false;
      if (mounted) setState(() {});
      if (bottomSheetStateSetterGlobal != null) if (bottomSheetMounted)
        bottomSheetStateSetterGlobal(() {});

      Map<String, dynamic> result =
          await MessageAuth().searchProductAndServiceOfUser(url, "", "");

      List tempList = result['results'];

      tempList.forEach((result) {
        debugPrint("product:- $result");
        searchedProductAndService.add(Product.fromJson(result));
      });

      isProductAndServiceLoading = false;
      if (searchedProductAndService.length == 0) noSearchedItem = true;
      if (mounted) setState(() {});
      if (bottomSheetStateSetterGlobal != null) {
        if (bottomSheetMounted) bottomSheetStateSetterGlobal(() {});
      }
    }
  }

  void searchService() async {
    if (searchItemTextController.text.length > 3) {
      String url = getSearchUrl() + searchItemTextController.text;

      searchedProductAndService.clear();
      isProductAndServiceLoading = true;
      noSearchedItem = false;
      if (mounted) setState(() {});
      if (bottomSheetStateSetterGlobal != null) if (bottomSheetMounted)
        bottomSheetStateSetterGlobal(() {});

      Map<String, dynamic> result =
          await MessageAuth().searchProductAndServiceOfUser(url, "", "");

      List tempList = result['results'];

      tempList.forEach((result) {
        searchedProductAndService.add(Service.fromJson(result));
      });

      isProductAndServiceLoading = false;
      if (searchedProductAndService.length == 0) noSearchedItem = true;
      if (mounted) setState(() {});
      if (bottomSheetStateSetterGlobal != null) if (bottomSheetMounted)
        bottomSheetStateSetterGlobal(() {});
    }
  }

  void getProductOrServiceList() async {
    String url = getSearchUrl() + searchItemTextController.text;

    if (!isProductOrServiceLoading) {
      if (productOrServiceNext != null && !isProductOrServiceLoading) {
        isProductOrServiceLoading = true;
        if (bottomSheetStateSetterGlobal != null) if (bottomSheetMounted)
          bottomSheetStateSetterGlobal(() {});

        Map<String, dynamic> result = await MessageAuth()
            .searchProductAndServiceOfUser(
                url, productOrServiceNext, productOrServicePrevious);
        productOrServiceCount = result['count'];
        productOrServiceNext = result['next'];
        productOrServicePrevious = result['previous'];
        List tempList = result['results'];

        isProductOrServiceLoading = false;

        tempList.forEach((item) {
          if (isProductSearch) {
            searchedProductAndService.add(Product.fromJson(item));
          } else if (isServiceSearch) {
            searchedProductAndService.add(Service.fromJson(item));
          }
        });

        if (bottomSheetStateSetterGlobal != null) if (bottomSheetMounted)
          bottomSheetStateSetterGlobal(() {});
      }
      if (searchedProductAndService.isEmpty) {
        noSearchedItem = true;
        if (bottomSheetStateSetterGlobal != null) if (bottomSheetMounted)
          bottomSheetStateSetterGlobal(() {});
      }
    }
  }

  String getSearchUrl() {
    if (isProductSearch) {
      return baseUrl + "/api/v1/search/products/?search=";
    }
    if (isServiceSearch) {
      return baseUrl + "/api/v1/search/services/?search=";
    }
    return "";
  }

  // ignore: missing_return
  Widget getResultTile(var result) {
    if (isProductSearch) {
      if (result is Product) {
        return SearchProductTile(
          product: result,
        );
      }
      return Container();
    }
    if (isServiceSearch) {
      if (result is Service) {
        return SearchServiceTile(
          service: result,
        );
      }
      return Container();
    }
    return Container();
  }

  Widget searchTypeSelection() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)),
        color: navyBlue,
      ),
      child: IconButton(
        key: _key,
        icon: Icon(
          getSearchTypeIcon(),
          color: Colors.white,
          size: 16,
        ),
        onPressed: () {
          if (itemSearchTypeSelectionMenu.isMenuOpen) {
            itemSearchTypeSelectionMenu.closeMenu();
          } else {
            itemSearchTypeSelectionMenu.openMenu();
          }
        },
      ),
    );
  }

  IconData getSearchTypeIcon() {
    if (selectedMenuItemIndex == 1) {
      return SlydoAppIcon.note_2;
    } else if (selectedMenuItemIndex == 0) {
      return SlydoAppIcon.product;
    }
  }

  Widget bottomSheetTabBar() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: bottomSheetTabBars()),
          SizedBox(
            height: 8,
          ),
          Expanded(child: bottomSheetTabViews())
        ],
      ),
    );
  }

  Widget bottomSheetTabBars() {
    return PreferredSize(
      preferredSize: Size.fromHeight(50.0),
      child: TabBar(
        labelPadding: EdgeInsets.zero,
        indicator: BoxDecoration(),
        onTap: (int index) {
          bottomSheetSearchIndex = index;
          setState(() {});
          clearSearchedListItems();
          if (bottomSheetStateSetterGlobal != null) if (bottomSheetMounted)
            bottomSheetStateSetterGlobal(() {});
          searchProductOrService();
        },
        tabs: [
          Tab(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                shape: BoxShape.rectangle,
                color: bottomSheetSearchIndex == 0
                    ? navyBlue.withOpacity(0.1)
                    : Colors.white,
              ),
              child: Text(
                "From partner",
                style: TextStyle(
                  color: bottomSheetSearchIndex == 0 ? navyBlue : blackFont,
                  fontSize: 14,
                  fontWeight: bottomSheetSearchIndex == 0
                      ? FontWeight.w600
                      : FontWeight.w400,
                ),
              ),
            ),
          ),
          Tab(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                shape: BoxShape.rectangle,
                color: bottomSheetSearchIndex == 1
                    ? navyBlue.withOpacity(0.1)
                    : Colors.white,
              ),
              child: Text(
                "From Mine",
                style: TextStyle(
                  color: bottomSheetSearchIndex == 1 ? navyBlue : blackFont,
                  fontSize: 14,
                  fontWeight: bottomSheetSearchIndex == 1
                      ? FontWeight.w600
                      : FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget bottomSheetTabViews() {
    return searchedItemsListView();
  }

  Widget searchedItemsListView() {
    return pullToRefresh();
  }
  // Widget searchedItemsListView() {
  //   return isProductAndServiceLoading
  //       ? Center(
  //           child: CircularLoadingIndicator(),
  //         )
  //       : searchItemTextController.text.isEmpty
  //           ? NoItemInList(
  //               msg: AppLocalization.of(context).pleaseTypeSomethingToGetResult,
  //               isResult: false,
  //             )
  //           : noSearchedItem
  //               ? NoItemInList(
  //                   msg: AppLocalization.of(context).noResultFound,
  //                   isResult: true,
  //                 )
  //               : ListView(
  //                   scrollDirection: Axis.vertical,
  //                   children: searchedProductAndService
  //                       .map((item) => GestureDetector(
  //                           onTap: () {
  //                             addProductOrServiceToChat(item);
  //                             Navigator.pop(context);
  //                           },
  //                           child: getResultTile(item)))
  //                       .toList(),
  //                 );
  // }

  void _onRefresh() async {
    Connectivity().checkConnectivity().then((value) {
      var connectionResult = value;
      if (connectionResult == ConnectivityResult.wifi ||
          connectionResult == ConnectivityResult.mobile) {
        productOrServiceCount = 0;
        productOrServiceNext = "";
        productOrServicePrevious = "";
        searchedProductAndService = [];
        noSearchedItem = false;
        getProductOrServiceList();
        _refreshController.refreshCompleted();
      } else {
        Toast.show(
            AppLocalization.of(context).internetConnectionNotAvailable, context,
            gravity: Toast.BOTTOM, backgroundColor: darkBlue());
        _refreshController.refreshCompleted();
      }
    });
  }

  Widget pullToRefresh() {
    return SmartRefresher(
      enablePullDown: true,
      header: WaterDropHeader(
        complete: Container(),
        waterDropColor: navyBlue,
      ),
      controller: _refreshController,
      onRefresh: _onRefresh,
      child: isProductAndServiceLoading
          ? _buildIndicatorForProductAndService()
          : buildProductOrServiceList(),
    );
  }

  Widget buildProductOrServiceList() {
    return noSearchedItem
        ? NoItemInList(
            msg: AppLocalization.of(context).noResultFound,
          )
        : ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 4),
            //+1 for progressbar
            itemCount: searchedProductAndService.length + 1,
            itemBuilder: (BuildContext context, int index) {
              if (index == searchedProductAndService.length) {
                return _buildIndicatorForProductAndService();
              } else {
                return GestureDetector(
                    onTap: () {
                      addProductOrServiceToChat(
                          searchedProductAndService[index]);
                      Navigator.pop(context);
                    },
                    child: getResultTile(searchedProductAndService[index]));
              }
            },
            controller: _scrollController,
          );
  }

  Widget _buildIndicatorForProductAndService() {
    return isProductAndServiceLoading
        ? Center(child: CircularLoadingIndicator())
        : Container();
  }
}
