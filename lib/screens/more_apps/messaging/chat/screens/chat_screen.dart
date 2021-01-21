import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:Slydo/data/socket_provider.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/tiles/product_and_service_tile_for_chat.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/utils.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/widgets/chat_audio_player.dart';
import 'package:Slydo/screens/more_apps/messaging/message_auth.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/models/transactions.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/payment_and_banking_auth.dart';
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
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
  TextEditingController searchProductController;
  TextEditingController searchServiceController;
  FocusNode messageFocus;

  /// Current chat users
  UserBloc userBloc;
  CustomerProfile recipientUser;

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
  bool isProductSearch = false;
  bool isServiceSearch = false;
  bool isCurrentUsersProductOrService = false;
  bool isProductAndServiceLoading = false;
  List searchedProductAndService = [];

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

  @override
  void initState() {
    messageController = TextEditingController();
    searchProductController = TextEditingController();
    searchServiceController = TextEditingController();
    messageFocus = FocusNode();
    recipientUser = widget.arguments["searchedUser"];

    setupScrollController();

    initializeSocket();

    getUserStatus();

    messageController.addListener(sendUserTypingState);
    messageController.addListener(changeSearchType);
    messageController.addListener(changeAudioOrTextMessageBtn);

    searchProductController.addListener(searchProduct);
    searchServiceController.addListener(searchService);

    getPreviousMessages();

    audioRecorder.openAudioSession().then((value) {
      setState(() {
        isAudioRecorderInitialized = true;
      });
    });

    audioRecorder.onProgress.listen((RecordingDisposition event) {
      audioRecordingDuration = event.duration;
      setState(() {});
    });

    super.initState();

    /// add the observer
    WidgetsBinding.instance.addObserver(this);
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

    audioRecorder?.closeAudioSession();
    audioRecorder = null;

    messageController.removeListener(sendUserTypingState);
    messageController.removeListener(changeSearchType);
    messageController.removeListener(changeAudioOrTextMessageBtn);

    searchProductController.removeListener(searchProduct);
    searchServiceController.removeListener(searchService);

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

      streamSubscription = mainSocketProvider.listen((event) {
        // debugPrint("event e:- $event");
        determineMessageType(event);
      });
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

  /// /p /s  {recipient product}
  /// //p //s {own items}
  void changeSearchType() {
    if (messageController.text.isNotEmpty) {
      if (messageController.text.toString() == "/p" ||
          messageController.text.toString() == "/s") {
        isCurrentUsersProductOrService = true;

        if (messageController.text.toString() == "/p") {
          isProductSearch = true;
        }
        if (messageController.text.toString() == "/s") {
          isServiceSearch = true;
        }
        messageController.text = "";
      }
      if (messageController.text.toString() == "//p" ||
          messageController.text.toString() == "//s") {
        isCurrentUsersProductOrService = false;

        if (messageController.text.toString() == "//p") {
          isProductSearch = true;
        }
        if (messageController.text.toString() == "//s") {
          isServiceSearch = true;
        }
        messageController.text = "";
      }
    }
  }

  void changeAudioOrTextMessageBtn() {
    if (messageController.text.isNotEmpty) {
      messageIsText = true;
      if (mounted) setState(() {});
    } else {
      messageIsText = false;
      if (mounted) setState(() {});
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
    if (messageList.length > 0) {
      Map<String, dynamic> newMessage = jsonDecode(message);
      Map<String, dynamic> previousMessage = jsonDecode(messageList.first);

      if (newMessage['check_id'] == previousMessage['check_id'] &&
          newMessage["text"] == previousMessage["text"]) {
        /// Update message when it came from the socket

        newMessage["delivered"] = true;
        messageList.first = jsonEncode(newMessage);
        debugPrint("Message Updated !!!");

        if (mounted) setState(() {});
      } else {
        addMessageToChat(message: message);
      }
    } else {
      addMessageToChat(message: message);
    }
  }

  void addMessageToChat({String message}) {
    /// TODO: when we are adding audio at 0 position the other audio player are breaking up
    /// it is working fine when we add audio at last

    Map<String, dynamic> messageData = jsonDecode(message);

    messageList.insert(0, message);

    // List<String> temporaryList = [];
    //
    // temporaryList.addAll(messageList);
    //
    // debugPrint("temporaryList 1 $temporaryList");
    // AssetsAudioPlayer.allPlayers().forEach((key, player) async {
    //   debugPrint("ausio playter $key");
    //   await player.dispose();
    // });
    // messageList.clear();

    // temporaryList.insert(0, message);
    //
    // debugPrint(" temporaryList 2 $temporaryList");
    // messageList.clear();
    // messageList = temporaryList;
    // debugPrint(" messageList $messageList");

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
    // bool isDataAdded = await mainSocketProvider.add(data);
    // if (!isDataAdded) {
    //   debugPrint("Data not added");
    //   userTyping();
    // }
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
        // bool isDataAdded = await mainSocketProvider.add(data);
        // if (!isDataAdded) {
        //   debugPrint("Data not added");
        //   messageReadByRecipient(message);
        // }
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

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);

    return WillPopScope(
      onWillPop: () async {
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
          child: AnimatedOpacity(
            child: FloatingActionButton(
              mini: true,
              backgroundColor: dividerColor,
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 28,
                color: blackFont,
              ),
              tooltip: "Increment",
              onPressed: scrollToBottom,
            ),
            duration: Duration(milliseconds: 100),
            opacity: fabIsVisible ? 1 : 0,
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
          size: 24,
        ),
        onPressed: () {
          mainSocketProvider.removeStreamSubscription(streamSubscription);
          mainSocketProvider.currentConversationId = null;
          mainSocketProvider.isChatOnScreen = false;
          Navigator.pop(context);
        },
      ),
      title: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, '/profile',
              arguments: {"searchedUser": recipientUser});
        },
        child: Row(
          children: [
            getUserIcon(),
            SizedBox(
              width: 8,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipientUser.fullName,
                  style: TextStyle(
                    color: blackFont,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  maxLines: 1,
                ),
                Text(
                  isRecipientTyping ? "Typing.." : userStatus, //"Online",
                  style: TextStyle(
                    color: darkGrey,
                    fontSize: 12,
                  ),
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

      DateTime lastSeenDateTime = DateTime.parse(data["last_seen"]);
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
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: recipientUser.avatar == ""
                ? "https://slydo-assets.s3.amazonaws.com/static/images/User_Avatar.png"
                : recipientUser.avatar,
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
    if (isProductSearch || isServiceSearch) {
      return Column(
        children: [
          Card(
            elevation: 10,
            margin: EdgeInsets.zero,
            shadowColor: lightGrey,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15))),
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
              child: Container(
                height: MediaQuery.of(context).size.height / 3,
                width: MediaQuery.of(context).size.width,
                color: Colors.white,
                child: Column(
                  children: [
                    Container(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          isProductSearch ? "Products" : "Services",
                          style: TextStyle(),
                        )),
                    searchedProductAndService.isEmpty
                        ? Expanded(
                            child: Center(
                              child: isProductAndServiceLoading
                                  ? CircularLoadingIndicator()
                                  : Text(
                                      "No Result",
                                      style: TextStyle(
                                          color: darkGrey, fontSize: 16),
                                    ),
                            ),
                          )
                        : Expanded(
                            child: ListView(
                              children: searchedProductAndService
                                  .map((item) => InkWell(
                                      onTap: () {
                                        addProductOrServiceToChat(item);
                                      },
                                      child: getResultTile(item)))
                                  .toList(),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
          Card(
            margin: EdgeInsets.zero,
            child: Container(
              height: 58,
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.only(
                left: 16,
              ),
              child: Row(
                children: <Widget>[
                  closeSearchModuleBtn(),
                  Expanded(
                    child: isProductSearch
                        ? searchProductTextField()
                        : searchServiceTextField(),
                  ),
                  searchProductOrServiceBtn(),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Container(
      height: 58,
      padding: EdgeInsets.only(
        left: 16,
      ),
      child: Row(
        children: <Widget>[
          MediaQuery.of(context).viewInsets.bottom != 0
              ? addMediaButton()
              : Row(
                  children: [
                    requestMoneyBtn(),
                    SizedBox(
                      width: 8,
                    ),
                    sendMoneyBtn(),
                    SizedBox(
                      width: 8,
                    ),
                  ],
                ),
          Expanded(
            child: textMessageField(),
          ),
          sendAudioOrMessageBtn(),
        ],
      ),
    );
  }

  Widget requestMoneyBtn() {
    return RoundedBackgroundIcon(
      borderRadius: 16,
      height: 44,
      width: 44,
      icon: Icon(
        SlydoAppIcon.receive,
        color: navyBlue,
        size: 22,
      ),
      backgroundColor: navyBlue.withOpacity(0.08),
      onTap: () async {
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
      borderRadius: 16,
      height: 44,
      width: 44,
      icon: Icon(
        SlydoAppIcon.send,
        color: naturalGreen,
        size: 22,
      ),
      backgroundColor: navyBlue.withOpacity(0.08),
      onTap: () async {
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

  Widget searchProductTextField() {
    return TextFormField(
      controller: searchProductController,
      textInputAction: TextInputAction.send,
      cursorColor: blackFont,
      cursorWidth: 1,
      cursorHeight: 20,
      autofocus: true,
      cursorRadius: Radius.circular(16),
      decoration: InputDecoration(
        hintText: "Search product",
        hintStyle: TextStyle(
          color: darkGrey.withOpacity(0.5),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        prefix: Padding(
          padding: EdgeInsets.only(left: 12),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 10),
        isDense: true,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: greyBorderColor,
            width: 1.0,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: greyBorderColor,
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
            color: greyBorderColor,
            width: 1.0,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: greyBorderColor,
            width: 1.0,
          ),
        ),
      ),
    );
  }

  Widget searchServiceTextField() {
    return TextFormField(
      controller: searchServiceController,
      textInputAction: TextInputAction.search,
      cursorColor: blackFont,
      cursorWidth: 1,
      cursorHeight: 20,
      autofocus: true,
      cursorRadius: Radius.circular(16),
      decoration: InputDecoration(
        hintText: "Search service",
        hintStyle: TextStyle(
          color: darkGrey.withOpacity(0.5),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        prefix: Padding(
          padding: EdgeInsets.only(left: 12),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 10),
        isDense: true,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: greyBorderColor,
            width: 1.0,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: greyBorderColor,
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
            color: greyBorderColor,
            width: 1.0,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: greyBorderColor,
            width: 1.0,
          ),
        ),
      ),
    );
  }

  Widget textMessageField() {
    return Stack(
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
            hintText: "Type message",
            hintStyle: TextStyle(
              color: darkGrey.withOpacity(0.5),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            prefix: Padding(
              padding: EdgeInsets.only(left: 12),
            ),
            // suffixIcon: captureImageOrVideo(),
            contentPadding: EdgeInsets.symmetric(vertical: 10),
            isDense: true,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: greyBorderColor,
                width: 1.0,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: greyBorderColor,
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
                color: greyBorderColor,
                width: 1.0,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: greyBorderColor,
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
    );
  }

  Widget addMediaButton() {
    return InkWell(
      onTap: addMediaToMessage,
      child: Container(
        padding: EdgeInsets.all(2),
        child: Row(
          children: [
            Icon(
              SlydoAppIcon.add_image,
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

  Widget closeSearchModuleBtn() {
    return InkWell(
      onTap: closeSearchModule,
      child: Container(
        padding: EdgeInsets.all(2),
        child: Row(
          children: [
            Icon(
              Icons.close_rounded,
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

  void closeSearchModule() {
    isProductSearch = false;
    isServiceSearch = false;
    searchProductController.text = "";
    searchServiceController.text = "";
    searchedProductAndService.clear();
    setState(() {});
  }

  void addProductOrServiceToChat(var item) async {
    String url = secureBaseUrl +
        "/api/v1/${item is Product ? "products" : "services"}/" +
        item.id +
        "/";

    var itemData = await ShoppingAuthService().getProductOrService(url);

    Map<String, dynamic> data = {
      "meta_data": itemData,
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
      closeSearchModule();
      setState(() {});
    }
  }

  void addMediaToMessage() async {
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

  Widget sendAudioOrMessageBtn() {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 100),
      child: messageIsText ? sendMessageBtn() : recordAndSendAudioBtn(),
    );
  }

  Widget sendMessageBtn() {
    return InkWell(
      onTap: sendTextMessage,
      child: Container(
        padding: EdgeInsets.all(2),
        child: Row(
          children: [
            SizedBox(
              width: 12,
            ),
            Icon(
              SlydoAppIcon.send_message,
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
          },
          splashColor: navyBlue.withOpacity(0.2),
          borderRadius: BorderRadius.circular(50),
          child: GestureDetector(
            onLongPressStart: (event) async {
              if (isAudioRecording) {
                debugPrint("Recording Stop ");
                isAudioRecording = false;
                setState(() {});
                await stopRecorder();
                setState(() {});
              } else {
                if (isAudioPermissionAccepted) {
                  if (!isAudioRecording) {
                    debugPrint("Starting Recording ");
                    isAudioRecording = true;
                    setState(() {});
                    await recordAudio();
                    setState(() {});
                  }
                } else {
                  if (await getAudioPermission()) {
                    if (!isAudioRecording) {
                      debugPrint("Starting Recording ");
                      isAudioRecording = true;
                      setState(() {});
                      await recordAudio();
                      setState(() {});
                    }
                  }
                }
              }
            },
            onLongPressEnd: (event) async {
              if (isAudioRecording) {
                debugPrint("Recording Stop ");
                isAudioRecording = false;
                setState(() {});
                await stopRecorder();
                setState(() {});
              }
            },
            child: Icon(
              Icons.mic,
              color: navyBlue,
              size: 30,
            ),
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

  Widget searchProductOrServiceBtn() {
    return InkWell(
      onTap: searchProductOrService,
      child: Container(
        padding: EdgeInsets.all(2),
        child: Row(
          children: [
            SizedBox(
              width: 12,
            ),
            Icon(
              SlydoAppIcon.search,
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

  void searchProductOrService() {
    if (isProductSearch || isServiceSearch) {
      if (isProductSearch) {
        searchProduct();
      }
      if (isServiceSearch) {
        searchService();
      }
    }
  }

  void searchProduct() async {
    if (searchProductController.text.length > 3) {
      String url = getSearchUrl() + searchProductController.text;

      searchedProductAndService.clear();
      isProductAndServiceLoading = true;
      if (mounted) setState(() {});

      Map<String, dynamic> result =
          await MessageAuth().searchProductAndServiceOfUser(url, "", "");

      List tempList = result['results'];

      tempList.forEach((result) {
        debugPrint("product:- $result");
        searchedProductAndService.add(Product.fromJson(result));
      });

      isProductAndServiceLoading = false;
      if (mounted) setState(() {});
    }
  }

  void searchService() async {
    if (searchServiceController.text.length > 3) {
      String url = getSearchUrl() + searchServiceController.text;

      searchedProductAndService.clear();
      isProductAndServiceLoading = true;
      if (mounted) setState(() {});

      Map<String, dynamic> result =
          await MessageAuth().searchProductAndServiceOfUser(url, "", "");

      List tempList = result['results'];

      tempList.forEach((result) {
        searchedProductAndService.add(Service.fromJson(result));
      });

      isProductAndServiceLoading = false;
      if (mounted) setState(() {});
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
      return SearchProductChatTile(result);
    }
    if (isServiceSearch) {
      return SearchServiceChatTile(result);
    }
    return Container();
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
    // if (MediaQuery.of(context).viewInsets.bottom != 0) {
    //   scrollToBottom();
    // }
    return Container(
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Image.asset(
                        "assets/images/index_screen.png",
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  ],
                ),
                Theme(
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
            padding: EdgeInsets.only(left: 8, right: 8, bottom: 8),
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
          Padding(
            padding:
                EdgeInsets.only(left: isSend ? 10 : 0, right: !isSend ? 10 : 0),
            child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.8,
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSend ? navyBlue : chatBackgroundColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(!isSend ? 0 : 10),
                    bottomRight: Radius.circular(isSend ? 0 : 10),
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                child: Stack(
                  overflow: Overflow.visible,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                messageDecoderWithEmoji(message['text']),
                                style: TextStyle(
                                    color: isSend ? Colors.white : blackFont,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 2,
                          width: 45,
                        )
                      ],
                    ),
                    Positioned(
                      right: -10,
                      bottom: -10,
                      child: Row(
                        children: [
                          Text(
                            formatTime(message['created_at']),
                            style: TextStyle(
                                color: isSend ? Colors.white : Colors.black38,
                                fontSize: 10,
                                fontWeight: FontWeight.w500),
                          ),
                          isSend
                              ? Row(
                                  children: [
                                    SizedBox(
                                      width: 2,
                                    ),
                                    Icon(
                                      Icons.check_circle_rounded,
                                      size: 10,
                                      color:
                                          getMessageTickColor(message: message),
                                    )
                                  ],
                                )
                              : Container(),
                        ],
                      ),
                    ),
                  ],
                )),
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

    return GestureDetector(
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
        Clipboard.setData(
            new ClipboardData(text: message['text'] ?? message['media']));
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
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width / 1.35,
              minWidth: MediaQuery.of(context).size.width / 1.35,
            ),
            decoration: BoxDecoration(
              color: isSend ? navyBlue : chatBackgroundColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(!isSend ? 0 : 6),
                bottomRight: Radius.circular(isSend ? 0 : 6),
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
            ),
            padding: EdgeInsets.only(left: 4, right: 4, top: 4, bottom: 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  child: CachedNetworkImage(
                    height: MediaQuery.of(context).size.width / 1.35,
                    width: MediaQuery.of(context).size.width / 1.35,
                    imageUrl: message['media'],
                    fit: BoxFit.cover,
                    progressIndicatorBuilder:
                        (context, url, downloadProgress) => Center(
                      child: CircularProgressIndicator(
                        value: downloadProgress.progress,
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation(navyBlue),
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                    errorWidget: imageErrorWidget,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                SizedBox(
                  height: isMessageEmpty ? 2 : 2,
                ),
                Stack(
                  overflow: Overflow.visible,
                  children: [
                    Column(
                      children: [
                        isMessageEmpty
                            ? Container()
                            : Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      messageText,
                                      style: TextStyle(
                                          color:
                                              isSend ? Colors.white : blackFont,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ],
                              ),
                        SizedBox(
                          height: isMessageEmpty ? 8 : 2,
                          width: 45,
                        )
                      ],
                    ),
                    Positioned(
                      right: !isSend ? 0 : -2,
                      bottom: isMessageEmpty ? -2 : -6,
                      child: Row(
                        children: [
                          Text(
                            formatTime(message['created_at']),
                            style: TextStyle(
                                color: isSend ? Colors.white : Colors.black38,
                                fontSize: 10,
                                fontWeight: FontWeight.w500),
                          ),
                          isSend
                              ? Row(
                                  children: [
                                    SizedBox(
                                      width: 2,
                                    ),
                                    Icon(
                                      Icons.check_circle_rounded,
                                      size: 10,
                                      color:
                                          getMessageTickColor(message: message),
                                    )
                                  ],
                                )
                              : Container(),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: isMessageEmpty ? 2 : 6,
                )
              ],
            ),
          )
        ],
      ),
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

    return GestureDetector(
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
        Clipboard.setData(
            new ClipboardData(text: message['text'] ?? message['media']));
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
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width / 1.35,
              minWidth: MediaQuery.of(context).size.width / 1.35,
            ),
            decoration: BoxDecoration(
              color: isSend ? navyBlue : chatBackgroundColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(!isSend ? 0 : 6),
                bottomRight: Radius.circular(isSend ? 0 : 6),
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
            ),
            padding: EdgeInsets.only(left: 4, right: 4, top: 4, bottom: 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  child: ClipRRect(
                    child: Stack(
                      children: [
                        CachedNetworkImage(
                          height: MediaQuery.of(context).size.width / 1.35,
                          width: MediaQuery.of(context).size.width / 1.35,
                          imageUrl: message["poster"] ??
                              "https://c1.iggcdn.com/indiegogo-media-prod-cld/image/upload/c_fill,f_auto,h_630,w_1200/v1506734779/wcsmythcukjuuglotjvb.jpg",
                          fit: BoxFit.cover,
                          progressIndicatorBuilder:
                              (context, url, downloadProgress) => Center(
                            child: CircularProgressIndicator(
                              value: downloadProgress.progress,
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation(navyBlue),
                              backgroundColor: Colors.transparent,
                            ),
                          ),
                          errorWidget: imageErrorWidget,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width / 1.35,
                          height: MediaQuery.of(context).size.width / 1.35,
                          child: Center(
                            child: ClipOval(
                              child: Container(
                                height: 55,
                                width: 55,
                                color: Colors.white60,
                                child: Center(
                                  child: Icon(
                                    Icons.play_arrow_rounded,
                                    color: blackFont,
                                    size: 28,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(
                  height: isMessageEmpty ? 2 : 2,
                ),
                Stack(
                  overflow: Overflow.visible,
                  children: [
                    Column(
                      children: [
                        isMessageEmpty
                            ? Container()
                            : Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      messageText,
                                      style: TextStyle(
                                          color:
                                              isSend ? Colors.white : blackFont,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ],
                              ),
                        SizedBox(
                          height: isMessageEmpty ? 8 : 2,
                          width: 45,
                        )
                      ],
                    ),
                    Positioned(
                      right: !isSend ? 0 : -2,
                      bottom: isMessageEmpty ? -2 : -6,
                      child: Row(
                        children: [
                          Text(
                            formatTime(message['created_at']),
                            style: TextStyle(
                                color: isSend ? Colors.white : Colors.black38,
                                fontSize: 10,
                                fontWeight: FontWeight.w500),
                          ),
                          isSend
                              ? Row(
                                  children: [
                                    SizedBox(
                                      width: 2,
                                    ),
                                    Icon(
                                      Icons.check_circle_rounded,
                                      size: 10,
                                      color:
                                          getMessageTickColor(message: message),
                                    )
                                  ],
                                )
                              : Container(),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: isMessageEmpty ? 2 : 6,
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget renderPaymentRequest({Map<String, dynamic> message}) {
    bool isSent = message["author"] == userBloc.user.userName;
    // bool isSent = false;

    PaymentRequest paymentRequest = PaymentRequest.fromJson(
        jsonDecode(message['text']),
        currentUser: userBloc.user);

    // PaymentRequest paymentRequest = PaymentRequest(
    //     description: "Shopping", amount: 100, payee: "black", currency: "NGN");

    return GestureDetector(
      onLongPress: () {
        if (paymentRequest.description.isNotEmpty) {
          Clipboard.setData(
              new ClipboardData(text: paymentRequest.description));
          Toast.show("Text copied !!", context,
              gravity: Toast.BOTTOM,
              duration: Toast.LENGTH_LONG,
              backgroundColor: navyBlue,
              textColor: Colors.white);
        }
      },
      child: Row(
        mainAxisAlignment:
            isSent ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: chatBackgroundColor,
              border: Border.all(color: chatBackgroundColor),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(!isSent ? 0 : 10),
                bottomRight: Radius.circular(isSent ? 0 : 10),
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            padding: EdgeInsets.all(8),
            width: MediaQuery.of(context).size.width / 1.8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Icon(
                        SlydoAppIcon.naira,
                        color: blackFont,
                        size: 16,
                      ),
                    ),
                    SizedBox(
                      width: 2,
                    ),
                    Text(
                      paymentRequest.amount.toString(),
                      style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                          color: blackFont),
                    ),
                  ],
                ),
                SizedBox(
                  height: 4,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    paymentRequest.description,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: blackFont),
                  ),
                ),
                SizedBox(
                  height: 6,
                ),
                Container(
                  child: isSent
                      ? Row(
                          children: <Widget>[
                            Expanded(
                              child: Container(),
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            Expanded(
                              child: CurvedButton(
                                text: "Cancel",
                                height: 36,
                                backgroundColor: navyBlue,
                                textColor: Colors.white,
                                onPressed: () {},
                              ),
                            ),
                          ],
                        )
                      : Row(
                          children: <Widget>[
                            Expanded(
                              child: CurvedButton(
                                text: "Pay",
                                height: 36,
                                backgroundColor: navyBlue,
                                textColor: Colors.white,
                                onPressed: () async {
                                  var response = await PaymentAndBankingAuth()
                                      .acceptPaymentRequests(paymentRequest,
                                          messageId: message["message_id"]);
                                },
                              ),
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            Expanded(
                              child: CurvedButton(
                                height: 36,
                                text: "Reject",
                                backgroundColor: navyBlue,
                                textColor: Colors.white,
                                onPressed: () async {
                                  var result = await PaymentAndBankingAuth()
                                      .rejectPaymentRequests(paymentRequest,
                                          messageId: message["message_id"]);
                                },
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget renderSendPayment({Map<String, dynamic> message}) {
    bool isSent = message["author"] == userBloc.user.userName;

    // bool isSent = false;

    // PaymentRequest paymentRequest = PaymentRequest.fromJson(
    //     jsonDecode(message['text']),
    //     currentUser: userBloc.user);

    Transaction transaction = Transaction.fromJson(jsonDecode(message['text']));
    // Transaction transaction = Transaction(
    //     description: "Shopping",
    //     amount: 100,
    //     payee: "black",
    //     currency: "NGN",
    //     status: "Paid");

    return GestureDetector(
      onLongPress: () {
        if (transaction.description.isNotEmpty) {
          Clipboard.setData(new ClipboardData(text: transaction.description));
          Toast.show("Text copied !!", context,
              gravity: Toast.BOTTOM,
              duration: Toast.LENGTH_LONG,
              backgroundColor: navyBlue,
              textColor: Colors.white);
        }
      },
      child: Row(
        mainAxisAlignment:
            isSent ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: chatBackgroundColor,
              border: Border.all(color: chatBackgroundColor),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(!isSent ? 0 : 10),
                bottomRight: Radius.circular(isSent ? 0 : 10),
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            padding: EdgeInsets.all(8),
            width: MediaQuery.of(context).size.width / 1.8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Icon(
                        SlydoAppIcon.naira,
                        color: blackFont,
                        size: 14,
                      ),
                    ),
                    SizedBox(
                      width: 2,
                    ),
                    Text(
                      transaction.amount.toString(),
                      style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                          color: blackFont),
                    ),
                  ],
                ),
                SizedBox(
                  height: 4,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    transaction.description,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: blackFont),
                  ),
                ),
                SizedBox(
                  height: 6,
                ),
                Container(
                  child: Row(
                    children: [
                      Icon(
                        SlydoAppIcon.true_icon,
                        size: 12,
                        color: naturalGreen,
                      ),
                      SizedBox(
                        width: 4,
                      ),
                      Text(
                        isSent
                            ? "You paid • ${getDateTime(transaction.createdAt)}"
                            : "You were paid • 10:13 AM",
                        style: TextStyle(color: blackFont, fontSize: 12),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget renderProduct({Map<String, dynamic> item}) {
    Product product;
    try {
      product = Product.fromJson(jsonDecode(item["meta_data"]));
    } catch (e) {
      product = Product.fromJson(item["meta_data"]);
    }

    bool isSend = item["author"] == userBloc.user.userName;

    return Row(
      mainAxisAlignment:
          isSend ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width / 1.35,
            minWidth: MediaQuery.of(context).size.width / 1.35,
            maxHeight: MediaQuery.of(context).size.width / 1.35,
          ),
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: dividerColor),
              borderRadius: BorderRadius.circular(12)),
          padding: EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: CachedNetworkImage(
                  width: MediaQuery.of(context).size.width / 1.35 - 16,
                  imageUrl: product.cover,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(
                height: 8,
              ),
              Text(
                product.name,
                style: TextStyle(
                  fontSize: 16,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.start,
              ),
              SizedBox(
                height: 8,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    SlydoAppIcon.naira,
                    color: blackFont,
                    size: 12,
                  ),
                  SizedBox(
                    width: 6,
                  ),
                  Text(
                    product.price.toString(),
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: blackFont),
                  ),
                ],
              ),
              !isSend
                  ? Column(
                      children: [
                        SizedBox(
                          height: 8,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: CurvedButton(
                                height: 36,
                                textColor: Colors.white,
                                backgroundColor: navyBlue,
                                text: "Buy",
                                onPressed: () {},
                              ),
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            addToCartWidget(),
                          ],
                        ),
                      ],
                    )
                  : product.seller == userBloc.user.userName
                      ? Container()
                      : Column(
                          children: [
                            SizedBox(
                              height: 8,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: CurvedButton(
                                    height: 36,
                                    textColor: Colors.white,
                                    backgroundColor: navyBlue,
                                    text: "Buy",
                                    onPressed: () {},
                                  ),
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                addToCartWidget(),
                              ],
                            ),
                          ],
                        ),
            ],
          ),
        ),
      ],
    );
  }

  Widget addToCartWidget() {
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
      onTap: () async {},
    );
  }

  Widget renderService({Map<String, dynamic> item}) {
    Service service;
    try {
      service = Service.fromJson(jsonDecode(item["meta_data"]));
    } catch (e) {
      service = Service.fromJson(item["meta_data"]);
    }

    bool isSend = item["author"] == userBloc.user.userName;

    return Row(
      mainAxisAlignment:
          isSend ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width / 1.35,
            minWidth: MediaQuery.of(context).size.width / 1.35,
            maxHeight: MediaQuery.of(context).size.width / 1.35,
          ),
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: dividerColor),
              borderRadius: BorderRadius.circular(12)),
          padding: EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: CachedNetworkImage(
                  width: MediaQuery.of(context).size.width / 1.35 - 16,
                  imageUrl: service.cover,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(
                height: 8,
              ),
              Text(
                service.name,
                style: TextStyle(
                  fontSize: 16,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.start,
              ),
              SizedBox(
                height: 8,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    SlydoAppIcon.naira,
                    color: blackFont,
                    size: 12,
                  ),
                  SizedBox(
                    width: 6,
                  ),
                  Text(
                    service.price.toString(),
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: blackFont),
                  ),
                ],
              ),
              !isSend
                  ? Column(
                      children: [
                        SizedBox(
                          height: 8,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: CurvedButton(
                                height: 36,
                                textColor: Colors.white,
                                backgroundColor: navyBlue,
                                text: "Buy",
                                onPressed: () {},
                              ),
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            addToCartWidget(),
                          ],
                        ),
                      ],
                    )
                  : service.provider == userBloc.user.userName
                      ? Container()
                      : Column(
                          children: [
                            SizedBox(
                              height: 8,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: CurvedButton(
                                    height: 36,
                                    textColor: Colors.white,
                                    backgroundColor: navyBlue,
                                    text: "Buy",
                                    onPressed: () {},
                                  ),
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                addToCartWidget(),
                              ],
                            ),
                          ],
                        ),
            ],
          ),
        ),
      ],
    );
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
}
