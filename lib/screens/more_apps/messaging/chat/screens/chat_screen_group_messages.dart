import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:Slydo/data/environment.dart';
import 'package:Slydo/data/socket_provider.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/helpers/chat_group_action_manager.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/helpers/chat_message_action_handler.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/helpers/chat_message_handler.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/helpers/chat_message_synchronizer.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/helpers/chat_shake_detection.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/helpers/chat_user_manager.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/helpers/connection_list_synchronizer.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/helpers/db_socket_message_handler.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/helpers/message_sound_player.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/ChatConversation.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/ChatMessageAction.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/GroupDetailModel.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/Participant.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/gif_model/GIFModel.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/models_for_db/ChatMessage.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/models_for_db/ChatMessagePagination.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/models_for_db/SocketQueueChatMessage.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/tiles/EditOrReplyMessageUI.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/tiles/audio_tile_for_chat.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/tiles/envelope_tile_for_chat.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/tiles/gif_image_tile_chat.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/tiles/image_tile_for_chat.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/tiles/location_tile_for_chat.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/tiles/product_and_service_tile_for_chat.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/tiles/product_and_service_tile_for_search.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/tiles/text_message_render_for_chat_screen.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/tiles/transaction_tile_for_chat.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/tiles/user_profile_tile_for_chat.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/tiles/video_tile_for_chat.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/utils.dart';
import 'package:Slydo/screens/more_apps/messaging/message_auth.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/models/Envelope.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/shopping/shopping_auth.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/screens/more_apps/user_profile/tiles/user_tile.dart';
import 'package:Slydo/screens/more_apps/user_profile/user_auth.dart';
import 'package:Slydo/services/location_service.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/global_key.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/bottom_sheet_item.dart';
import 'package:Slydo/widget/customized_popup_menu.dart';
import 'package:Slydo/widget/dialog.dart';
import 'package:Slydo/widget/noItemInList.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:Slydo/widget/sticky_grouped_list/src/item_positions_listener.dart';
import 'package:Slydo/widget/sticky_grouped_list/sticky_grouped_list.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:connectivity/connectivity.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:giphy_picker/giphy_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:toast/toast.dart';
import 'package:uuid/uuid.dart';

class ChatScreenGroupMessage extends StatefulWidget {
  final arguments;

  ChatScreenGroupMessage({this.arguments});

  @override
  _ChatScreenGroupMessageState createState() => _ChatScreenGroupMessageState();
}

class _ChatScreenGroupMessageState extends State<ChatScreenGroupMessage>
    with WidgetsBindingObserver {
  /// Text message controller
  TextEditingController messageController;
  FocusNode messageFocus;

  /// Current chat users
  UserBloc userBloc;
  ChatConversation chatConversation;
  bool isChatConversationLoading = false;

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
  bool fabIsVisible = false;

  /// User typing state variables
  Timer _timerForUserTypingState;
  Duration userMessageTypingStateUpdateTime = Duration(seconds: 2);
  bool isRecipientTyping = false;
  String typingMessage = "";

  /// User online offline status
  Timer _timerForUserStatus;
  Duration userStatusCheckTimeDuration = Duration(seconds: 2);

  /// User Audio Recording state variables
  Timer _timerForCheckingAudioRecording;
  Duration userAudioRecordingCheckDuration = Duration(seconds: 2);

  /// Music Player
  AssetsAudioPlayer _audioPlayer = AssetsAudioPlayer();
  bool isAudioPlaying = false;

  /// User status
  String userStatus = "";

  /// variables for product or service search
  bool isProductSearch = true;
  bool isServiceSearch = false;
  bool isCurrentUsersProductOrService = false;
  List searchedProductAndService = [];
  StateSetter bottomSheetStateSetterGlobal;
  bool bottomSheetMounted = false;

  bool isItemLoading = false;
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

  /// variable for audio Recording
  FlutterSoundRecorder audioRecorder = FlutterSoundRecorder();
  bool isAudioRecorderInitialized = false;
  String audioUuid;
  String audioPath;
  Duration audioRecordingDuration = Duration.zero;
  bool isAudioRecording = false;
  bool isAudioPermissionAccepted = false;
  bool isOtherUserRecordingAudio = false;

  bool isAudioMessage = false;

  BasketBloc basketBloc;

  StreamSubscription<ConnectivityResult> networkConnectionSubscription;

  ///variable for message actions
  bool showMoreAction = false;

  /// variables for listening socket connection
  bool _isNetworkConnectionIsOn = false;

  /// variables for shaking detection and nudge
  ChatShakeDetection chatShakeDetection;

  /// chat Screen ScaffoldKey
  GlobalKey<ScaffoldState> chatScreenKey = GlobalKey<ScaffoldState>();

  /// variables for editing message
  bool isEditingMessage = false;
  String editingMessage;

  /// variables for replying message
  bool isReplyingMessage = false;
  String replayingMessage;

  /// variables for recipient has removed you info dialogue
  bool isRecipientRemovedDialogueIsOpen = false;

  /// variables for group chat message
  GroupDetailModel groupDetail;
  bool isUserMuted = false;
  bool isUserBlocked = false;

  /// variables for GIF Message
  List<GIFModel> _gifs = [];
  bool _isMessageIsGIFOrSticker = false;
  bool _isMessageIsSticker = false;
  bool _isGIFLoading = false;
  TextEditingController _gifController = TextEditingController();

  GroupedItemScrollController messageListController;
  ItemPositionsListener messageListPositionListener;
  bool isUserNudging = false;

  @override
  void initState() {
    messageListController = GroupedItemScrollController();
    messageListPositionListener = ItemPositionsListener.create();

    messageController = TextEditingController();
    searchItemTextController = TextEditingController();
    messageFocus = FocusNode();

    chatConversation = widget.arguments["searchedUser"];

    setupScrollController();

    messageController.addListener(sendUserTypingState);

    // searchItemTextController.addListener(searchProductOrService);

    WidgetsFlutterBinding.ensureInitialized();

    _gifController.addListener(searchGiFListener);

    checkNetworkConnectivity();

    fetchRecipientUserIfNotAvailable();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          _scrollController.position.pixels != 0) {
        getProductOrServiceList();
      }
    });

    super.initState();

    /// by adding observer in this screen we can listen the app life cycle state
    /// on this screen by this method
    // lib/screens/more_apps/messaging/chat/screens/chat_screen.dart:294
    WidgetsBinding.instance.addObserver(this);
  }

  void checkNetworkConnectivity() async {
    debugPrint("Network Connectivity called !!");
    await Connectivity().checkConnectivity().then((value) {
      if (value == ConnectivityResult.none) {
        _isNetworkConnectionIsOn = false;
        debugPrint(
            "_isNetworkConnectionIsOn FROM CHAT SCREEN:- $_isNetworkConnectionIsOn");
      } else {
        _isNetworkConnectionIsOn = true;
        debugPrint(
            "_isNetworkConnectionIsOn FROM CHAT SCREEN:- $_isNetworkConnectionIsOn");
      }
    });
  }

  void fetchRecipientUserIfNotAvailable() async {
    String recipientUserName = widget.arguments["recipientUserName"] ?? "";

    if (recipientUserName != "") {
      isChatConversationLoading = true;
      if (mounted) setState(() {});

      chatConversation =
          await UserAuth().fetchContactProfile(recipientUserName);

      isChatConversationLoading = false;
      if (mounted) setState(() {});
    }

    getDBMessage();

    getUserStatus();
    setUserStatusTimer();
    initializeSocket();
    setUpAudioRecorder();
    chatShakeDetection = Provider.of<ChatShakeDetection>(
        myGlobals.scaffoldKey.currentContext,
        listen: false);
    setupShakeDetector();
    determineIfConversationIsGroup();
    // await setupNetworkConnectionListener();

    ChatUserManager().clearChatUserMessageCount(
        conversationId: chatConversation.conversationId);
  }

  void setUserStatusTimer() {
    if (!chatConversation.isGroupConversation) {
      if (_timerForUserStatus?.isActive ?? false) {
        _timerForUserStatus.cancel();
      }

      _timerForUserStatus =
          Timer.periodic(userStatusCheckTimeDuration, (timer) {
        if (mounted) getUserStatus();
      });
    }
  }

  void getDBMessage() async {
    List<ChatMessage> messages = await ChatMessageHandler()
        .getChatMessages(chatConversation: chatConversation);

    if (messages.isEmpty) {
      ChatMessagePagination chatMessagePagination = ChatMessagePagination(
          conversationId: chatConversation.conversationId,
          count: count,
          next: next,
          previous: previous);
      await ChatMessageHandler().saveChatMessagePagination(
          chatMessagePagination: chatMessagePagination);
      getPreviousMessages();
    } else {
      ChatMessagePagination chatMessagePagination = await ChatMessageHandler()
          .getChatMessagePagination(
              conversationId: chatConversation.conversationId);

      count = chatMessagePagination.count;
      next = chatMessagePagination.next;
      previous = chatMessagePagination.previous;

      messages
          .map((element) => jsonEncode(element.toJson()))
          .toList()
          .forEach((element) {
        messageList.add(element);
      });

      isLoading = false;

      if (mounted) setState(() {});

      checkMessageForRead();
    }
  }

  void getMissedMessageFromDB() async {
    debugPrint("Get missed messages Called !!");
    List<ChatMessage> messages = await ChatMessageHandler()
        .getChatMessages(chatConversation: chatConversation);

    messages.forEach((message) {
      bool isPresent = false;
      for (int i = 0; i < messageList.length; i++) {
        Map<String, dynamic> decodePresentMessage = jsonDecode(messageList[i]);
        ChatMessage decodedMessage = ChatMessage.fromJson(decodePresentMessage);

        if (message.checkId == decodedMessage.checkId &&
            message.conversationId == decodedMessage.conversationId) {
          isPresent = true;
          messageList[i] = jsonEncode(message.toJson());
        }
      }

      if (!isPresent) {
        debugPrint("MESSAGE ADDED:--- ${message.text}");
        String encodedMessage = jsonEncode(message.toJson());
        messageList.add(encodedMessage);
        storeMessagesTemporary(message: encodedMessage);
      }
    });

    if (mounted) setState(() {});

    acknowledgeThatMessageAreRead();

    ChatUserManager().clearChatUserMessageCount(
        conversationId: chatConversation.conversationId);
  }

  void determineIfConversationIsGroup() {
    if (chatConversation.isGroupConversation) {
      stopShakeDetector();
      debugPrint("===> Conversation is Group Conversation !!!");
      getGroupDetail();
    }
  }

  void getGroupDetail() {
    groupDetail = GroupDetailModel.fromChatConversation(chatConversation);
    if (mounted) setState(() {});

    getGroupDetailFromServer();
  }

  void getGroupDetailFromServer() async {
    await MessageAuth()
        .getGroupConversationDetail(chatConversation.conversationId)
        .then((value) {
      groupDetail = value;
      if (mounted) setState(() {});
    }).catchError((error) {
      debugPrint("ERROR:- $error");
      if (mounted) setState(() {});
    });
  }

  void setupShakeDetector() {
    if (!chatConversation.isGroupConversation) {
      chatShakeDetection.setupShakeDetector(recipientUser: chatConversation);
    }
  }

  void stopShakeDetector() {
    if (!chatConversation.isGroupConversation) {
      chatShakeDetection?.stopShakeDetector();
    }
  }

  Future<void> setupNetworkConnectionListener() async {
    networkConnectionSubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) async {
      if (result == ConnectivityResult.none) {
        _isNetworkConnectionIsOn = false;
        debugPrint(
            "_isNetworkConnectionIsOn FROM CHAT SCREEN:- $_isNetworkConnectionIsOn");
      } else if ((result == ConnectivityResult.mobile ||
              result == ConnectivityResult.wifi) &&
          _isNetworkConnectionIsOn == false) {
        _isNetworkConnectionIsOn = true;

        messageList.clear();
        next = "";
        previous = "";
        count = 0;
        getPreviousMessages();

        debugPrint(
            "_isNetworkConnectionIsOn FROM CHAT SCREEN:- $_isNetworkConnectionIsOn");
      }
    })
          ..onError((error) {
            debugPrint("ERROR:- while closing network status stream $error");
          });
  }

  void setUpAudioRecorder() async {
    audioRecorder.openAudioSession().then((value) {
      setState(() {
        isAudioRecorderInitialized = true;
      });
    });

    audioRecorder.onProgress.listen((RecordingDisposition event) {
      audioRecordingDuration = event.duration;
      setState(() {});
    });

    await getAudioPermission();
  }

  void setUpAudioRecordingListener() {
    _timerForCheckingAudioRecording =
        Timer.periodic(userAudioRecordingCheckDuration, (timer) {
      if (isAudioRecording) {
        userRecordingAudio();
      }
    });
  }

  void disposeAudioRecordingListener() {
    if (_timerForCheckingAudioRecording?.isActive ?? false) {
      _timerForCheckingAudioRecording?.cancel();
    }
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

    chatShakeDetection?.stopShakeDetector();

    _timerForUserStatus?.cancel();

    messageController?.removeListener(sendUserTypingState);

    _gifController?.removeListener(searchGiFListener);

    // searchItemTextController.removeListener(searchProductOrService);

    messageController?.dispose();
    messageFocus?.dispose();

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
        temporaryMessages.forEach((element) async {
          await messageReadByRecipient(jsonDecode(element));
        });

        debugPrint("Clearing temporary Message");
        temporaryMessages.clear();
      }
    }
  }

  void storeMessagesTemporary({String message}) {
    bool isPresentInTemporaryMessage = false;
    for (int i = 0; i < temporaryMessages.length; i++) {
      if (message == temporaryMessages[i]) {
        isPresentInTemporaryMessage = true;
        break;
      }
    }
    if (!isPresentInTemporaryMessage) {
      temporaryMessages.add(message);
      debugPrint("Storing temporary Message:- ${temporaryMessages.length}");
    }
  }

  void initializeSocket() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      mainSocketProvider =
          Provider.of<MainSocketProvider>(context, listen: false);
      try {
        mainSocketProvider.currentConversationId =
            chatConversation.conversationId;
        mainSocketProvider.isChatOnScreen = true;
      } catch (e) {
        debugPrint("Error:- $e");
      }
    });
  }

  void initializeListener() {
    streamSubscription?.cancel();
    streamSubscription = mainSocketProvider?.socketStream?.listen((event) {
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
        sendUserTypingState();
      });
    }
  }

  void searchGiFListener() {
    if (_gifController.text != "") {
      getGIFs();
    }
  }

  void setupScrollController() {
    messageListPositionListener.itemPositions.addListener(() {
      try {
        if (messageList.length > 0) {
          // print('test' +
          //     messageListPositionListener.itemPositions.value.last.itemTrailingEdge
          //         .toString());
          // if (messageListPositionListener
          //         .itemPositions.value.last.itemTrailingEdge <
          //     1) {
          //   print("bottom?" +
          //       messageListPositionListener
          //           .itemPositions.value.last.itemTrailingEdge
          //           .toString() +
          //       '    ---- > ' +
          //       messageListPositionListener.itemPositions.value.last.index
          //           .toString());
          //   if (messageListPositionListener.itemPositions.value.last.index > 1) {
          //     print('fetch ');
          //   }
          // }

          // ignore: null_aware_before_operator
          if (messageListPositionListener
                  ?.itemPositions?.value?.first?.itemTrailingEdge <
              1) {
            // print("top?" +
            //     messageListPositionListener
            //         .itemPositions.value.first.itemTrailingEdge
            //         .toString() +
            //     '    ---- > ' +
            //     messageListPositionListener.itemPositions.value.first.index
            //         .toString());
            if (messageListPositionListener.itemPositions.value.first.index ==
                0) {
              if (fabIsVisible) {
                // debugPrint(
                //     'fetch first ${messageListPositionListener.itemPositions.value.last.index}');
                fabIsVisible = false;
                if (mounted) setState(() {});
              }
            } else {
              if (fabIsVisible != true &&
                  !isReplyingMessage &&
                  !isEditingMessage) {
                fabIsVisible = true;
                // debugPrint(
                //     "fetch last ${messageListPositionListener.itemPositions.value.last.index}");
                if (mounted) setState(() {});
              }
            }
          }
        }
      } catch (error) {
        debugPrint(
            "ERROR:- $error\nmessageList.length => ${messageList.length}\nmessageListPositionListener => $messageListPositionListener\nmessageListPositionListener.itemPositions => ${messageListPositionListener.itemPositions}\nmessageListPositionListener.itemPositions.value => ${messageListPositionListener.itemPositions.value}");
      }
    });
  }

  void getPreviousMessages({bool showLoading = true}) async {
    debugPrint("Fetching previous messages !!");

    ChatMessagePagination chatMessagePagination = await ChatMessageHandler()
        .getChatMessagePagination(
            conversationId: chatConversation.conversationId);

    count = chatMessagePagination.count;
    next = chatMessagePagination.next;
    previous = chatMessagePagination.previous;

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
            "recipient conversationID:- ${chatConversation.conversationId}");

        Map<String, dynamic> result = await MessageAuth()
            .getChatMessages(next, previous,
                conversionId: chatConversation.conversationId)
            .catchError((error) {
          isLoading = false;
          if (mounted) setState(() {});
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            if (mounted) {
              debugPrint("ERROR:- $error");
            }
          });
        });
        if (isLoading == false) {
          return;
        }

        List<String> tempList = result['results'];

        List<ChatMessage> messages =
            await ChatMessageHandler().saveChatMessages(messages: tempList);

        chatMessagePagination.count = result['count'];
        chatMessagePagination.next = result['next'];
        chatMessagePagination.previous = result['previous'];

        await ChatMessageHandler().updateChatMessagePagination(
            chatMessagePagination: chatMessagePagination);

        messageList.addAll(
            messages.map((element) => jsonEncode(element.toJson())).toList());

        isLoading = false;

        if (mounted) setState(() {});

        checkMessageForRead();

        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          if (isFirstTime &&
              MediaQuery.of(myGlobals.scaffoldKey.currentContext).size.height >
                  704) {
            debugPrint("height:- " +
                MediaQuery.of(myGlobals.scaffoldKey.currentContext)
                    .size
                    .height
                    .toString());
            getPreviousMessages();
          }
        });
      }
      if (messageList.isEmpty) {
        if (mounted) {
          /// set flag if chat is empty
          setState(() {});
        }
      }
    }
  }

  bool checkIsMessageIsForCurrentChat(Map<String, dynamic> messageData) {
    if (messageData["conversation_id"] == chatConversation.conversationId ||
        messageData["conversation"] == chatConversation.conversationId) {
      return true;
    } else {
      debugPrint("Message For Someone else >>>>>> $messageData");
      return false;
    }
  }

  void determineMessageType(String message) async {
    Map<String, dynamic> messageData = jsonDecode(message);

    if (mounted) setState(() {});

    switch (messageData['type']) {
      case "chatroom_message":
        if (checkIsMessageIsForCurrentChat(messageData)) {
          checkMessageToAdd(message: message);
        }

        break;

      case "read_by_recipient":
        if (checkIsMessageIsForCurrentChat(messageData)) {
          updateMessageReadMark(message: message);
        }
        break;

      case "user_typing_message":
        if (checkIsMessageIsForCurrentChat(messageData)) {
          if (messageData['username'] != userBloc.user.userName) {
            isRecipientTyping = true;
            typingMessage = messageData["message"];
            if (mounted) setState(() {});

            Future.delayed(Duration(seconds: 1)).then((value) {
              isRecipientTyping = false;
              typingMessage = "";
              if (mounted) setState(() {});
            });
          }
        }

        break;
      case "user_recording_audio_message":
        if (checkIsMessageIsForCurrentChat(messageData)) {
          if (messageData['username'] != userBloc.user.userName) {
            isOtherUserRecordingAudio = true;
            if (mounted) setState(() {});

            Future.delayed(Duration(seconds: 1)).then((value) {
              isOtherUserRecordingAudio = false;
              if (mounted) setState(() {});
            });
          }
        }

        break;
      case "pong":
        break;

      case "delete_message":
        deleteMessageFromMessageList(message: messageData);
        break;

      case "edit_message":
        updateEditedMessageInMessageList(message: messageData);
        break;

      case "nudge_user":
        isUserNudging = true;
        if (mounted) setState(() {});

        Future.delayed(Duration(seconds: 11)).then((value) {
          isUserNudging = false;
          if (mounted) setState(() {});
        });

        break;

      case "stop_nudging":
        isUserNudging = false;
        if (mounted) setState(() {});

        break;

      case "group_conversation_admin_actions":
        handleGroupConversationAdminActions(messageData: messageData);

        break;

      case "conversation_actions":
        handleConversationAction(messageData: messageData);

        break;

      case "acknowledge_message":
        handleAcknowledgementMessage(messageData: messageData);
        break;

      default:
        debugPrint("Message type:- ${messageData['type'] ?? messageData}");
    }
  }

  void handleGroupConversationAdminActions({Map<String, dynamic> messageData}) {
    if (messageData['meta_data']['conversation_id'] ==
        chatConversation.conversationId) {
      if (messageData['meta_data']['action'] == "delete_group") {
        Toast.show(
            "${messageData['meta_data']['author']} has deleted this group !!",
            context,
            textColor: Colors.white,
            backgroundColor: Colors.black,
            duration: Toast.LENGTH_LONG);

        Navigator.popUntil(context, ModalRoute.withName("/friends-dashboard"));
        return;
      } else if (messageData['meta_data']['action'] == "remove_user") {
        List users = messageData['meta_data']['users'];
        if (users.isEmpty) return;

        if (users.first == null || users.first == "") return;
        String user = users.first.toString();

        if (user == userBloc.user.userName) {
          Toast.show(
              "${messageData['meta_data']['author']} has removed you from group !!",
              context,
              textColor: Colors.white,
              backgroundColor: Colors.black,
              duration: Toast.LENGTH_LONG);

          Navigator.popUntil(
              context, ModalRoute.withName("/friends-dashboard"));
          return;
        }
      }
    }

    var result = ChatGroupActionManagerForLiveConversation(message: messageData)
        .handleMessageAction(chatConversation: chatConversation);

    if (result != null) {
      if (result is ChatConversation) {
        chatConversation = result;
        if (chatConversation.isGroupConversation)
          groupDetail = GroupDetailModel.fromChatConversation(chatConversation);

        updateParticipantRights();
        if (mounted) setState(() {});
      }
    }
  }

  void handleConversationAction({Map<String, dynamic> messageData}) {
    Map<String, dynamic> metaData;

    if (messageData['meta_data'] is String) {
      metaData = jsonDecode(messageData['meta_data']);
    } else {
      metaData = messageData['meta_data'];
    }

    if (!messageData.containsKey("meta_data")) {
      metaData = messageData;
    }
    String action = metaData['action'];

    switch (action) {
      case "delete_conversation":
        String conversationId = metaData['conversation_id'];
        if (chatConversation.conversationId == conversationId) {
          if (!isRecipientRemovedDialogueIsOpen) {
            showRecipientHasRemovedYouDialogue();
          }
        }
        break;
    }
  }

  void handleAcknowledgementMessage({Map<String, dynamic> messageData}) {
    if (messageList.length > 0) {
      for (int i = 0; i < messageList.length; i++) {
        Map<String, dynamic> previousMessage = jsonDecode(messageList[i]);

        String conversationId =
            messageData['conversation_id'] ?? messageData['conversation'];

        if (messageData['check_id'] == previousMessage['check_id'] &&
            conversationId == previousMessage['conversation_id']) {
          previousMessage["delivered"] = true;
          messageList[i] = jsonEncode(previousMessage);
          if (mounted) setState(() {});

          ///PlaySoundAccordingToMessageType
          // MessageSoundPlayer(message: jsonEncode(previousMessage)).playSound();
          break;
        }
      }
    }
  }

  void showRecipientHasRemovedYouDialogue() async {
    isRecipientRemovedDialogueIsOpen = true;
    await showDialogBoxWithImageWithOneAction(
      context: context,
      actionOneBgColor: greyBorderColor,
      actionOneTextColor: blackFont,
      title: "Connection Removed",
      description: "${chatConversation.fullName} has removed you from Contact.",
      image: chatConversation.avatar,
      actionOne: "Ok",
    );
    Navigator.pop(context);
  }

  void updateParticipantRights() {
    if (!chatConversation.mutedParticipants.contains(userBloc.user.userName)) {
      isUserMuted = false;
    }
    if (!chatConversation.blockedParticipants
        .contains(userBloc.user.userName)) {
      isUserBlocked = false;
    }
  }

  void checkMessageToAdd({String message}) {
    Map<String, dynamic> newMessage = jsonDecode(message);

    if (messageList.length > 0) {
      bool isMatchFound = false;
      for (int i = 0; i < messageList.length; i++) {
        Map<String, dynamic> previousMessage = jsonDecode(messageList[i]);

        String newMessageText = newMessage["text"] is String
            ? newMessage["text"]
            : jsonEncode(newMessage["text"]);

        String previousMessageText = previousMessage["text"] is String
            ? previousMessage["text"]
            : jsonEncode(previousMessage["text"]);

        if (newMessage['check_id'] == previousMessage['check_id'] &&
            newMessageText.replaceAll(RegExp(r"\s+"), "") ==
                previousMessageText.replaceAll(RegExp(r"\s+"), "")) {
          messageList[i] = jsonEncode(newMessage);
          if (mounted) setState(() {});
          isMatchFound = true;

          ///PlaySoundAccordingToMessageType
          MessageSoundPlayer(message: jsonEncode(newMessage)).playSound();
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

    ///PlaySoundAccordingToMessageType
    MessageSoundPlayer(message: message).playSound();

    if (mounted) setState(() {});

    if (mainSocketProvider.isChatOnScreen) {
      /// Update message to server when user have read the message
      if (mounted) messageReadByRecipient(jsonDecode(message));
    } else {
      debugPrint("Got Message:- $message");
      storeMessagesTemporary(message: message);
    }
  }

  void updateMessageReadMark({String message}) async {
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
      "full_name": chatConversation.fullName,
      "conversation_id": chatConversation.conversationId,
    };

    await mainSocketProvider.add(data);
  }

  void userRecordingAudio() async {
    var data = {
      "message": "recording audio",
      "type": "user_recording_audio_message",
      "full_name": chatConversation.fullName,
      "conversation_id": chatConversation.conversationId,
    };

    await mainSocketProvider.add(data);
  }

  Future<void> messageReadByRecipient(Map<String, dynamic> message) async {
    if (message["author"] != userBloc.user.userName) {
      if (mainSocketProvider.isChatOnScreen) {
        Map<String, dynamic> data = {
          "check_id": message["check_id"],
          "type": "read_by_recipient",
          "conversation_id": chatConversation.conversationId,
        };

        await sendReadByRecipientMessageThroughHttp(data: data);
      }
    }
  }

  Future<void> sendReadByRecipientMessageThroughHttp(
      {Map<String, dynamic> data}) async {
    Map<String, dynamic> dataToBeSent = {};
    data.forEach((key, value) {
      if (key != "type") {
        dataToBeSent[key] = value;
      }
    });

    await MessageAuth()
        .readByRecipientToServer(dataToBeSent: dataToBeSent)
        .then((value) {
      debugPrint("===> value");
    }).catchError((error) async {
      await mainSocketProvider.add(data);
    });
  }

  void scrollToBottom() {
    debugPrint("Scrolling to Bottom");
    fabIsVisible = false;
    if (mounted) setState(() {});

    if (messageList.isNotEmpty) {
      messageListController.scrollToBottom(
          index: 0,
          duration: Duration(milliseconds: 500),
          curve: Curves.fastLinearToSlowEaseIn);
    } else {
      debugPrint("ERROR:- ===> scroll to bottom called when list is empty");
    }
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
    if (bottomSheetStateSetterGlobal != null) if (bottomSheetMounted)
      bottomSheetStateSetterGlobal(() {});
    if (mounted) setState(() {});
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

    return ColorfulSafeArea(
      bottom: Platform.isAndroid ? false : true,
      top: false,
      color: Colors.white,
      left: false,
      right: false,
      child: WillPopScope(
        onWillPop: () async {
          disposeAudioPlayers();
          mainSocketProvider.removeStreamSubscription(streamSubscription);
          mainSocketProvider.currentConversationId = null;
          mainSocketProvider.isChatOnScreen = false;

          return Future.value(true);
        },
        child: Scaffold(
          key: chatScreenKey,
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
        onTap: () async {
          stopShakeDetector();
          if (chatConversation.isGroupConversation) {
            navigateToGroupDetailScreen();
          } else {
            await Navigator.pushNamed(context, '/profile',
                arguments: {"searchedUserName": chatConversation.userName});
          }
          setupShakeDetector();
        },
        child: Row(
          children: [
            StreamBuilder<Object>(
                initialData: false,
                stream: ChatMessageSynchronizer().getChatMessageStream,
                builder: (context, snapshot) {
                  if (snapshot.data == true) {
                    ChatMessageSynchronizer().setStreamFalse();
                    getMissedMessageFromDB();
                  }
                  return getUserIcon();
                }),
            SizedBox(
              width: 12,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chatConversation != null ? chatConversation.fullName : "",
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
                  chatConversation != null
                      ? isRecipientTyping
                          ? typingMessage
                          : isOtherUserRecordingAudio
                              ? "recording audio"
                              : userStatus
                      : "", //"Online",
                  style: TextStyle(
                      color: isRecipientTyping || isOtherUserRecordingAudio
                          ? naturalGreen
                          : darkGrey,
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
      actions: [
        // synchronizeContactBtn(),
        // SizedBox(width: 8),
        // getNudgeUserBtn(),
        // SizedBox(width: 16)
      ],
    );
  }

  Widget synchronizeContactBtn() {
    return RoundedBackgroundIcon(
      height: 34,
      width: 34,
      icon: Icon(
        Icons.sync,
        size: 24,
        color: blackFont,
      ),
      onTap: () async {
        await ConnectionSynchronizer().update();
        await ChatMessageSynchronizer().syncMessages(fetchFresh: true);
      },
      backgroundColor: lightGrey,
      enableMargin: true,
    );
  }

  Widget getNudgeUserBtn() {
    if (chatConversation.isGroupConversation) {
      return Container();
    }

    return isUserNudging
        ? Container(
            margin: EdgeInsets.only(top: 8, bottom: 8),
            child: Center(child: CircularLoadingIndicator()))
        : IconButton(
            icon: Icon(Icons.vibration_outlined),
            color: navyBlue,
            onPressed: () {
              isUserNudging = true;
              if (mounted) setState(() {});
              Map<String, dynamic> data = {
                "check_id": Uuid().v4(),
                "conversation_id": chatConversation.conversationId,
                "author": userBloc.user.userName,
                "author_avatar": userBloc.user.avatar,
                "recipient": chatConversation.userName,
                "created_at": DateTime.now().toUtc().toIso8601String(),
                "type": "nudge_user",
              };
              sendDataToSocket(data);
            },
          );
  }

  void navigateToGroupDetailScreen() async {
    var result = await Navigator.of(context)
        .pushNamed('/group-detail', arguments: {"groupDetail": groupDetail});

    if (result != null) {
      if (result is GroupDetailModel) {
        chatConversation = ChatConversation.fromGroupDetailModel(result);
        groupDetail = result;

        if (mounted) setState(() {});
        ConnectionListBloc connectionListBloc =
            Provider.of<ConnectionListBloc>(context, listen: false);

        connectionListBloc.updateChatConversation(
            chatConversation: chatConversation);
      }
    }
  }

  void getUserStatus() async {
    if (chatConversation != null) {
      if (chatConversation.isGroupConversation) {
        userStatus = "${chatConversation.participants.length} Members";
        if (mounted) setState(() {});
        return;
      }

      var data = await MessageAuth()
          .getChatUserStatus(chatConversation.userName)
          .catchError((error) {
        debugPrint("ERROR:- $error");
      });

      if (data == null) {
        userStatus = "";
        return;
      }

      if (data["status"] == "Online") {
        userStatus = "Online";
        if (mounted) setState(() {});
        return;
      } else {
        DateTime now = new DateTime.now();
        DateTime today = new DateTime(now.year, now.month, now.day);
        DateTime yesterday = now.subtract(Duration(days: 1));

        DateTime lastSeenDateTime = DateTime.parse(data["last_seen"]).toLocal();
        DateTime lastSeenDate = new DateTime(lastSeenDateTime.year,
            lastSeenDateTime.month, lastSeenDateTime.day);

        String lastSeenDateString =
            DateFormat("dd/MM/yyyy").format(lastSeenDateTime);
        String lastSeenTime = DateFormat("hh:mm a").format(lastSeenDateTime);

        if (today == lastSeenDate) {
          if (lastSeenDateTime.difference(now).inMinutes.abs() < 59) {
            Duration minuteDifference = lastSeenDateTime.difference(now);

            if (minuteDifference.inMinutes.abs() == 0) {
              userStatus = 'last seen today at ' + lastSeenTime;
              if (mounted) setState(() {});
              return;
            }

            userStatus =
                'last seen ${minuteDifference.inMinutes.abs()} minutes ago';
            if (mounted) setState(() {});
            return;
          }

          userStatus = 'last seen today at ' + lastSeenTime;
          if (mounted) setState(() {});
          return;
        }

        if (yesterday == lastSeenDate) {
          userStatus = 'last seen yesterday at ' + lastSeenTime;
          if (mounted) setState(() {});
          return;
        }

        if (lastSeenDateTime.difference(now).inDays.abs() < 7) {
          int weekDay = lastSeenDateTime.weekday;
          String dayName = getDayName(day: weekDay);
          userStatus = 'last seen ' + dayName + ' at ' + lastSeenTime;
          if (mounted) setState(() {});
          return;
        }
        userStatus = 'last seen ' + lastSeenDateString + ' at ' + lastSeenTime;
      }
      if (mounted) setState(() {});
    }
  }

  Widget getUserIcon() {
    if (isChatConversationLoading) {
      return Container();
    }
    Color borderColor = getUserTypeColorByType(type: chatConversation.type);

    return Container(
      height: 36,
      width: 36,
      child: Container(
        height: 36,
        width: 36,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              25,
            ),
            border: Border.all(color: borderColor, width: 2)),
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed("/photo-viewer",
                arguments: chatConversation != null
                    ? chatConversation.avatar ??
                        "https://slydo-assets.s3.amazonaws.com/static/images/User_Avatar.png"
                    : "https://slydo-assets.s3.amazonaws.com/static/images/User_Avatar.png");
          },
          child: ClipOval(
            child: CachedNetworkImage(
              imageUrl: chatConversation != null
                  ? chatConversation.avatar ??
                      "https://slydo-assets.s3.amazonaws.com/static/images/User_Avatar.png"
                  : "https://slydo-assets.s3.amazonaws.com/static/images/User_Avatar.png",
              colorBlendMode: BlendMode.darken,
              fit: BoxFit.fill,
              filterQuality: FilterQuality.high,
              errorWidget: imageErrorWidget,
            ),
          ),
        ),
      ),
    );
  }

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
      child: checkIfParticipantIsMutedOrBlocked()
          ? getMutedOrBlockedParticipantMessage()
          : getSearchBarLayout(),
    );
  }

  bool checkIfParticipantIsMutedOrBlocked() {
    if (isChatConversationLoading) {
      return false;
    }

    if (!chatConversation.isGroupConversation) {
      return false;
    }

    if (chatConversation.mutedParticipants.contains(userBloc.user.userName)) {
      isUserMuted = true;
    }
    if (chatConversation.blockedParticipants.contains(userBloc.user.userName)) {
      isUserBlocked = true;
    }

    if (isUserMuted || isUserBlocked) {
      return true;
    } else {
      return false;
    }
  }

  Widget getSearchBarLayout() {
    // return Column(
    //   children: [
    //     Container(
    //       constraints: BoxConstraints(minHeight: 54, maxHeight: 100),
    //       child: Row(
    //         children: <Widget>[
    //           isAudioMessage ? getAudioCancelBtn() : moreActionBtn(),
    //           Expanded(
    //             child:
    //                 isAudioMessage ? getAudioRecordingUi() : textMessageField(),
    //           ),
    //           sendMessageBtn(),
    //         ],
    //       ),
    //     ),
    //     showMoreAction ? moreActionsBtn() : Container(),
    //   ],
    // );
    return Column(
      children: getSearchBarItems(),
    );
  }

  List<Widget> getSearchBarItems() {
    List<Widget> items = [];

    if (_isMessageIsGIFOrSticker) {
      items.add(Container(
        constraints: BoxConstraints(minHeight: 54, maxHeight: 100),
        child: Row(
          children: <Widget>[
            getSearchGIFCancelBtn(),
            Expanded(
              child: searchGIFTextField(),
            ),
            searchGIFBtn(),
          ],
        ),
      ));
      items.add(gifPreviewList());
      return items;
    }

    items.add(Container(
      constraints: BoxConstraints(minHeight: 54, maxHeight: 100),
      child: Row(
        children: <Widget>[
          isAudioMessage ? getAudioCancelBtn() : moreActionBtn(),
          Expanded(
            child: isAudioMessage ? getAudioRecordingUi() : textMessageField(),
          ),
          sendMessageBtn(),
        ],
      ),
    ));

    if (showMoreAction) {
      items.add(moreActionsBtn());
    }

    return items;
  }

  Widget gifPreviewList() {
    return Container(
      height: MediaQuery.of(context).size.height / 3,
      child: _isGIFLoading
          ? Center(child: CircularLoadingIndicator())
          : GridView.builder(
              padding: EdgeInsets.symmetric(horizontal: 4),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
              ),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    sendGIFToSocket(urlOfGIF: _gifs[index].images.original.url);
                    _isMessageIsGIFOrSticker = !_isMessageIsGIFOrSticker;
                    _isMessageIsSticker = false;
                    _gifController.clear();
                    if (mounted) setState(() {});
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: CachedNetworkImage(
                      width: MediaQuery.of(context).size.width / 2,
                      imageUrl: _gifs[index].images.previewGif.url,
                      fit: BoxFit.fill,
                      placeholder: (context, url) => Container(
                          width: MediaQuery.of(context).size.width / 2,
                          child: Center(child: CircularLoadingIndicator())),
                    ),
                  ),
                );
              },
              itemCount: _gifs.length,
            ),
    );
  }

  Widget getMutedOrBlockedParticipantMessage() {
    return Container(
        color: isUserMuted ? lightGrey : mateRed.withOpacity(0.1),
        constraints: BoxConstraints(minHeight: 54),
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Center(
          child: Text(
              isUserMuted
                  ? "You are muted by the admin, Please contact admin to continue conversation in this group."
                  : "You are blocked by the admin, Please contact admin to continue conversation in this group.",
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isUserMuted ? blackFont : mateRed),
              textAlign: TextAlign.center),
        ));
  }

  Widget getAudioCancelBtn() {
    return IconButton(
        icon: Icon(
          SlydoAppIcon.delete,
          color: blackFont,
          size: 20,
        ),
        onPressed: () async {
          if (isAudioRecording) {
            debugPrint("Recording Stop ");
            isAudioRecording = false;
            isAudioMessage = false;
            disposeAudioRecordingListener();
            if (mounted) setState(() {});
            await stopRecorder(sendToServer: false);
            if (mounted) setState(() {});
          }
        });
  }

  Widget getSearchGIFCancelBtn() {
    return IconButton(
        icon: Icon(
          SlydoAppIcon.close_2,
          color: navyBlue,
          size: 20,
        ),
        onPressed: () async {
          _gifController.clear();
          _isMessageIsGIFOrSticker = !_isMessageIsGIFOrSticker;
          _isMessageIsSticker = false;
          if (mounted) setState(() {});
        });
  }

  Widget getAudioRecordingUi() {
    return Container(
      height: 46,
      margin: EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: navyBlue,
        borderRadius: BorderRadius.circular(3),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 50,
            height: 50,
            child: FlareActor(
              "assets/images/flare/voice_record_active.flr",
              animation: "record",
            ),
          ),
          SizedBox(
            width: 4,
          ),
          Expanded(
            child: Image.asset(
              "assets/images/sound.gif",
              width: double.infinity,
              color: navyBlue,
              colorBlendMode: BlendMode.darken,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(
            width: 8,
          ),
          Text(
            "${formatDurationInSeconds(duration: audioRecordingDuration)}",
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(
            width: 10,
          ),
        ],
      ),
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
              assignTitleToAction(text: "Media", child: addMediaButton()),
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
              assignTitleToAction(
                  text: "Magic\nEnvelope", child: sendEnvelopeButton()),
              flexibleSpace(),
              assignTitleToAction(
                  text: "Empty\nEnvelope", child: sendEmptyEnvelopeButton()),
              flexibleSpace(),
              assignTitleToAction(
                  text: "Location\n", child: sendUserLocation()),
            ],
          ),
          SizedBox(
            height: 16,
          ),
          Row(
            children: <Widget>[
              assignTitleToAction(text: "GIF", child: sendGIFButton()),
              flexibleSpace(),
              assignTitleToAction(text: "Sticker", child: sendStickersButton()),
              flexibleSpace(),
              Container(
                constraints: BoxConstraints(maxWidth: 60),
              ),
              flexibleSpace(),
              Container(
                constraints: BoxConstraints(maxWidth: 60),
              ),
            ],
          ),
        ],
      ),
    );
  }

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
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center),
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
      onTap: requestMoneyBtnPressed,
    );
  }

  void requestMoneyBtnPressed() async {
    showMoreAction = false;
    if (mounted) setState(() {});

    String selectedUser;

    if (chatConversation.isGroupConversation) {
      if (groupDetail.participants.isEmpty) {
        getGroupDetailFromServer();
      }

      CustomerProfile user = await selectRecipientForAction();
      selectedUser = user.userName;
    } else {
      selectedUser = chatConversation.userName;
    }

    if (selectedUser != null) {
      var customerProfileBloc =
          Provider.of<CustomerProfileBloc>(context, listen: false);
      customerProfileBloc.customer =
          await UserAuth().fetchCustomerProfile(selectedUser);

      stopShakeDetector();
      await Navigator.of(context).pushNamed(
        '/request-payment',
        arguments: <String, dynamic>{
          'isFromProfile': false,
          'isFromChat': true,
          'conversationId': chatConversation.conversationId
        },
      );
      setupShakeDetector();
    }
  }

  Future<CustomerProfile> selectRecipientForAction() async {
    return await showModalBottomSheet<CustomerProfile>(
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
                padding: EdgeInsets.only(bottom: 18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 8,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Center(
                            child: Text(
                              "Select Recipient",
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: blackFont,
                                  fontSize: 18),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Expanded(child: getGroupUserList())
                  ],
                ),
              ));
        });
  }

  Widget getGroupUserList() {
    List<Participant> participantList = [];

    groupDetail.participants.forEach((element) {
      if (element.userName != userBloc.user.userName) {
        participantList.add(element);
      }
    });

    return ListView.builder(
      itemBuilder: (context, index) {
        CustomerProfile user =
            CustomerProfile.fromGroupParticipant(participantList[index]);

        return GestureDetector(
          onTap: () {
            Navigator.pop(context, user);
          },
          child: UserTile(user: user),
        );
      },
      itemCount: participantList.length,
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
      onTap: sendMoneyBtnPressed,
    );
  }

  void sendMoneyBtnPressed() async {
    showMoreAction = false;
    if (mounted) setState(() {});

    String selectedUser;

    if (chatConversation.isGroupConversation) {
      if (groupDetail.participants.isEmpty) {
        getGroupDetailFromServer();
      }

      CustomerProfile user = await selectRecipientForAction();
      selectedUser = user.userName;
    } else {
      selectedUser = chatConversation.userName;
    }

    if (selectedUser != null) {
      var customerProfileBloc =
          Provider.of<CustomerProfileBloc>(context, listen: false);
      customerProfileBloc.customer =
          await UserAuth().fetchCustomerProfile(selectedUser);

      stopShakeDetector();
      await Navigator.of(context).pushNamed(
        '/send-payment',
        arguments: <String, dynamic>{
          'isFromProfile': false,
          'isFromChat': true,
          'conversationId': chatConversation.conversationId
        },
      );
      setupShakeDetector();
    }
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
          isAudioMessage = false;
          if (mounted) setState(() {});
          await stopRecorder();
          if (mounted) setState(() {});
        } else if (!isAudioRecording && isAudioPermissionAccepted) {
          debugPrint("Starting Recording ");
          isAudioRecording = true;
          showMoreAction = false;
          isAudioMessage = true;
          setUpAudioRecordingListener();
          if (mounted) setState(() {});
          await recordAudio();
          if (mounted) setState(() {});
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

  Widget sendUserLocation() {
    return RoundedBackgroundIcon(
      borderRadius: 20,
      height: 50,
      width: 50,
      icon: Icon(
        SlydoAppIcon.location,
        color: blackFont,
        size: 18,
      ),
      backgroundColor: navyBlue.withOpacity(0.08),
      onTap: () {
        showMoreAction = false;
        if (mounted) setState(() {});
        sendUserLocationToSocket();
      },
    );
  }

  Widget sendGIFButton() {
    return RoundedBackgroundIcon(
      borderRadius: 20,
      height: 50,
      width: 50,
      icon: Icon(
        Icons.gif_rounded,
        color: blackFont,
        size: 38,
      ),
      backgroundColor: navyBlue.withOpacity(0.08),
      onTap: () {
        showMoreAction = false;
        _isMessageIsGIFOrSticker = !_isMessageIsGIFOrSticker;
        getGIFs(isRandom: true);
        if (mounted) setState(() {});
        // pickGIF();
      },
    );
  }

  Widget sendStickersButton() {
    return RoundedBackgroundIcon(
      borderRadius: 20,
      height: 50,
      width: 50,
      icon: Icon(
        Icons.photo_filter_rounded,
        color: blackFont,
        size: 20,
      ),
      backgroundColor: navyBlue.withOpacity(0.08),
      onTap: () {
        showMoreAction = false;
        _isMessageIsGIFOrSticker = !_isMessageIsGIFOrSticker;
        _isMessageIsSticker = !_isMessageIsSticker;
        getGIFs(isRandom: true);
        if (mounted) setState(() {});
        // pickSticker();
      },
    );
  }

  void pickGIF() async {
    stopShakeDetector();
    GiphyGif gif = await GiphyPicker.pickGif(
        context: context,
        apiKey: AppConfig.gifApiKey,
        showPreviewPage: false,
        sticker: false,
        decorator: GiphyDecorator(
          showAppBar: false,
          searchElevation: 4,
          giphyTheme: ThemeData.light().copyWith(
            inputDecorationTheme: InputDecorationTheme(
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            cursorColor: navyBlue,
          ),
        ),
        onError: (error) {
          debugPrint("ERROR IN GIPHY PICKER:- $error");
        },
        title: Text(
          "Slydo GIPHY",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ));

    setupShakeDetector();
    if (gif != null) {
      sendGIFToSocket(urlOfGIF: gif.images.original.url);
    }
  }

  void pickSticker() async {
    stopShakeDetector();
    GiphyGif gif = await GiphyPicker.pickGif(
        context: context,
        apiKey: AppConfig.gifApiKey,
        showPreviewPage: false,
        onError: (error) {
          debugPrint("ERROR IN GIPHY PICKER:- $error");
        },
        decorator: GiphyDecorator(
          showAppBar: false,
          searchElevation: 4,
          giphyTheme: ThemeData.light().copyWith(
            inputDecorationTheme: InputDecorationTheme(
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            cursorColor: navyBlue,
          ),
        ),
        sticker: true,
        searchText: "Search Sticker",
        title: Text(
          "Slydo Sticker",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ));
    setupShakeDetector();
    if (gif != null) {
      sendGIFToSocket(urlOfGIF: gif.images.original.url);
    }
  }

  Widget sendEnvelopeButton() {
    return RoundedBackgroundIcon(
      borderRadius: 20,
      height: 50,
      width: 50,
      icon: Container(
        margin: EdgeInsets.symmetric(vertical: 14),
        child: Image.asset(
          "assets/images/envelope/envelope_blue.png",
        ),
      ),
      backgroundColor: navyBlue.withOpacity(0.08),
      onTap: () async {
        showMoreAction = false;

        if (mounted) setState(() {});

        CustomerProfile user;

        if (chatConversation.isGroupConversation) {
          if (groupDetail.participants.isEmpty) {
            getGroupDetailFromServer();
          }

          user = await selectRecipientForAction();
        } else {
          user = CustomerProfile.fromChatConversation(chatConversation);
        }

        if (user != null) {
          sendEnvelope(recipient: user);
        }
      },
    );
  }

  Widget sendEmptyEnvelopeButton() {
    return RoundedBackgroundIcon(
      borderRadius: 20,
      height: 50,
      width: 50,
      icon: Container(
        margin: EdgeInsets.symmetric(vertical: 14),
        child: Image.asset(
          "assets/images/envelope/envelope_blue_empty.png",
        ),
      ),
      backgroundColor: navyBlue.withOpacity(0.08),
      onTap: () async {
        showMoreAction = false;

        if (mounted) setState(() {});

        CustomerProfile user;

        if (chatConversation.isGroupConversation) {
          if (groupDetail.participants.isEmpty) {
            getGroupDetailFromServer();
          }

          user = await selectRecipientForAction();
        } else {
          user = CustomerProfile.fromChatConversation(chatConversation);
        }

        if (user != null) {
          sendEnvelope(recipient: user, isEmpty: true);
        }
      },
    );
  }

  void sendEnvelope({bool isEmpty = false, CustomerProfile recipient}) async {
    Map<String, dynamic> arguments = {};

    arguments['isEmptyEnvelope'] = isEmpty;

    ChatConversation _chatConversation =
        ChatConversation.fromChatConversation(chatConversation);

    if (chatConversation.isGroupConversation) {
      _chatConversation.userName = recipient.userName;
      _chatConversation.fullName = recipient.fullName;
      _chatConversation.avatar = recipient.avatar;
      _chatConversation.qrCode = recipient.qrCode;
    }

    arguments['chatConversation'] = _chatConversation;

    stopShakeDetector();
    var result = await Navigator.of(context)
        .pushNamed("/send-envelope", arguments: arguments);

    setupShakeDetector();
    debugPrint("Result From send Envelope :- $result");
  }

  Widget textMessageField() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: Container(
        color: chatBackgroundColor,
        child: Stack(
          alignment: Alignment.centerRight,
          children: [
            Theme(
                data: ThemeData(highlightColor: navyBlue.withOpacity(0.3)),
                child: Scrollbar(
                  radius: Radius.circular(12),
                  thickness: 2.5,
                  child: TextFormField(
                    controller: messageController,
                    textInputAction: TextInputAction.newline,
                    keyboardType: TextInputType.multiline,
                    focusNode: messageFocus,
                    onFieldSubmitted: (value) {
                      getSendMessageAction();
                    },
                    cursorColor: blackFont,
                    cursorWidth: 1,
                    cursorHeight: 20,
                    maxLines: null,
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
                )),
            Positioned(
              child: captureImageOrVideoBtn(),
              right: 8,
            )
          ],
        ),
      ),
    );
  }

  Widget searchGIFTextField() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: Container(
        color: chatBackgroundColor,
        child: Theme(
            data: ThemeData(highlightColor: navyBlue.withOpacity(0.3)),
            child: Scrollbar(
              radius: Radius.circular(12),
              thickness: 2.5,
              child: TextFormField(
                controller: _gifController,
                textInputAction: TextInputAction.search,
                keyboardType: TextInputType.multiline,
                onFieldSubmitted: (value) {
                  getGIFs();
                },
                cursorColor: blackFont,
                cursorWidth: 1,
                cursorHeight: 20,
                maxLines: null,
                cursorRadius: Radius.circular(16),
                decoration: InputDecoration(
                  hintText: "Search ${_isMessageIsSticker ? "Sticker" : "GIF"}",
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
                ),
              ),
            )),
      ),
    );
  }

  void getGIFs({bool isRandom = false}) async {
    _isGIFLoading = true;
    if (mounted) setState(() {});

    List<GIFModel> results;
    if (isRandom) {
      results = await MessageAuth()
          .searchGIF(isRandom: true, isSticker: _isMessageIsSticker)
          .catchError((error) {
        debugPrint("ERROR:- $error");
      });
    } else {
      results = await MessageAuth()
          .searchGIF(
              query: _gifController.text.trim(), isSticker: _isMessageIsSticker)
          .catchError((error) {
        debugPrint("ERROR:- $error");
      });
    }

    _isGIFLoading = false;
    if (mounted) setState(() {});

    if (results != null) {
      if (results.isEmpty) {
      } else {
        _gifs.clear();
        _gifs = results;
        if (mounted) setState(() {});
      }
    }
  }

  void addProductOrServiceToChat(var item) async {
    String url = AppConfig.baseUrl +
        "/api/v1/${item is Product ? "products" : "services"}/" +
        item.id +
        "/";

    Map<String, dynamic> itemData =
        await ShoppingAuthService().getProductOrService(url);

    Map<String, dynamic> data = {
      "meta_data": jsonEncode(itemData),
      "check_id": Uuid().v4(),
      "conversation_id": chatConversation.conversationId,
      "author": userBloc.user.userName,
      "message": url,
      "kind": item is Product ? "product" : "service",
      "created_at": DateTime.now().toUtc().toIso8601String(),
      "type": "chatroom_message",
    };

    updateConnectionList(
        messageData: data, conversationId: chatConversation.conversationId);
    bool result = await sendDataToSocket(data);
    if (result) {
      clearSearchedListItems();
      setState(() {});
    }
  }

  void addMediaToMessage() async {
    stopShakeDetector();
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
        setupShakeDetector();
        return;
      }

      var result = await Navigator.of(context).pushNamed(
        "/send-media-to-chat-message",
        arguments: {
          "data": {
            "conversation": chatConversation.conversationId,
            "author": userBloc.user.userName,
          },
          "media": file,
          "message": messageController.text.trim(),
          "mediaType": mediaType
        },
      ).catchError((error) {
        debugPrint("Error: = = = = $error");
      });
      setupShakeDetector();

      if (result == null) return;

      messageController.text = "";
      debugPrint("Result:- $result");
    }
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
    stopShakeDetector();
    String mediaType = await selectMediaType();
    if (mediaType == null) {
      setupShakeDetector();
      return;
    }

    String capturedMediaPath;

    if (mediaType == "image") {
      capturedMediaPath = await captureImage();
    } else if (mediaType == "video") {
      capturedMediaPath = await captureVideo();
    } else {
      setupShakeDetector();
      return;
    }

    if (capturedMediaPath != null) {
      stopShakeDetector();
      var result = await Navigator.of(context).pushNamed(
        "/send-media-to-chat-message",
        arguments: {
          "data": {
            "conversation": chatConversation.conversationId,
            "author": userBloc.user.userName,
          },
          "media": File(capturedMediaPath),
          "message": messageController.text.trim(),
          "mediaType": mediaType
        },
      ).catchError((error) {
        debugPrint("Error: = = = = $error");
      });
      setupShakeDetector();
      if (result == null) return;

      messageController.text = "";
      debugPrint("Result:- $result");
    }
  }

  Future<String> captureImage() async {
    debugPrint("=======>   <=======");
    PickedFile media = await ImagePicker()
        .getImage(source: ImageSource.camera, imageQuality: 85);

    if (media == null) return null;

    // String croppedImage = await ImageCrop().cropImage(media.path);
    // if (croppedImage == null) {
    //   return null;
    // }

    return media.path;
  }

  Future<String> captureVideo() async {
    PickedFile media = await ImagePicker().getVideo(
        source: ImageSource.camera, maxDuration: Duration(seconds: 5));

    // var path = await Navigator.of(context).pushNamed("/video-recorder",
    //     arguments: {"duration": Duration(seconds: 5)});
    //
    // if (path == null) return null;

    return media.path;
  }

  void getSendMessageAction() async {
    if (isReplyingMessage) {
      sendReplyChatMessage();
      return;
    }
    if (isEditingMessage) {
      editTextMessage();
      return;
    }
    if (isAudioMessage) {
      if (isAudioRecording) {
        debugPrint("Recording Stop ");
        isAudioRecording = false;
        isAudioMessage = false;
        disposeAudioRecordingListener();
        if (mounted) setState(() {});
        await stopRecorder();
        if (mounted) setState(() {});
      } else {
        await getAudioPermission();
      }
      return;
    }

    sendTextMessage();
  }

  Widget sendMessageBtn() {
    return InkWell(
      onTap: getSendMessageAction,
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

  Widget searchGIFBtn() {
    return InkWell(
      onTap: getGIFs,
      child: Container(
        padding: EdgeInsets.all(2),
        child: Row(
          children: [
            SizedBox(
              width: 10,
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
          .startRecorder(toFile: filePath, codec: codec)
          .catchError((error) {
        debugPrint("Error:- while Recording Audio $error");
      });
      debugPrint("Audio Storing At $filePath");
    } else {
      Toast.show("Not Supported:- $codec", context);
    }
  }

  Future<void> stopRecorder({bool sendToServer = true}) async {
    audioRecorder.stopRecorder().then((value) {
      debugPrint("Audio Stored");
      audioRecordingDuration = Duration.zero;
      if (mounted) setState(() {});
      if (sendToServer) {
        sendAudioToServer();
      }
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
    _data['created_at'] = DateTime.now().toUtc().toIso8601String();
    _data['type'] = "chatroom_message";
    _data["conversation"] = chatConversation.conversationId;
    _data["author"] = userBloc.user.userName;
    _data["author_name"] = userBloc.user.fullName;
    _data["author_avatar"] = userBloc.user.avatar;

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
    Map<String, dynamic> messageData = jsonDecode(message);

    String messageType = messageData["kind"];

    Widget finalUI;

    switch (messageType) {
      case "text":
        finalUI = renderMessage(
            message: messageData, chatConversation: chatConversation);
        break;

      case "image":
        finalUI = renderImageMedia(
            message: messageData, chatConversation: chatConversation);

        break;

      case "video":
        finalUI = renderVideoMedia(
            message: messageData, chatConversation: chatConversation);

        break;

      case "audio":
        finalUI = renderAudioMedia(
            message: messageData, chatConversation: chatConversation);

        break;

      case "transaction":
        finalUI = renderSendPayment(
            message: messageData, chatConversation: chatConversation);

        break;
      case "payment-request":
        finalUI = renderPaymentRequest(
            message: messageData, chatConversation: chatConversation);

        break;
      case "product":
        finalUI = renderProduct(
            item: messageData, chatConversation: chatConversation);

        break;
      case "service":
        finalUI = renderService(
            item: messageData, chatConversation: chatConversation);

        break;
      case "user-profile":
        finalUI = renderUserProfile(
            message: messageData, chatConversation: chatConversation);

        break;

      case "user_location":
        finalUI = renderUserLocation(
            message: messageData, chatConversation: chatConversation);

        break;
      case "gif_image":
        finalUI = renderGIFImage(
            message: messageData, chatConversation: chatConversation);

        break;

      case "envelope":
        finalUI = renderEnvelopeUI(
            message: messageData, chatConversation: chatConversation);
        break;

      default:
        debugPrint("Unknown Message Kind 1: $messageType Message:- $message");
        Widget getErrorRenderTypeUI = unKnownMessageType();
        return getErrorRenderTypeUI;
    }
    return getReplyOnSwipe(ui: finalUI, message: message);
  }

  Widget getReplyOnSwipe({Widget ui, String message}) {
    Map<String, dynamic> messageData = jsonDecode(message);

    bool isSend = userBloc.user.userName == messageData["author"];

    return SwipeTo(
      child: ui,
      animationDuration: Duration(milliseconds: 200),
      offsetDx: 0.1,
      onLeftSwipe: isSend
          ? () {
              debugPrint("left Swipe");
              replyChatMessage(message: message);
            }
          : null,
      onRightSwipe: isSend
          ? null
          : () {
              debugPrint("Right Swipe");
              replyChatMessage(message: message);
            },
    );
  }

  void sendGIFToSocket({@required String urlOfGIF}) async {
    // isUserSearchingGIF = false;
    // if (mounted) setState(() {});

    if (urlOfGIF == null || urlOfGIF == "") {
      return;
    }

    Map<String, dynamic> data = {
      "check_id": Uuid().v4(),
      "conversation_id": chatConversation.conversationId,
      "author": userBloc.user.userName,
      "author_full_name": userBloc.user.fullName,
      "author_avatar": userBloc.user.avatar,
      "message": urlOfGIF,
      "kind": "gif_image",
      "read_by_author": true,
      "read_by_recipient": false,
      "delivered": false,
      "created_at": DateTime.now().toUtc().toIso8601String(),
      "type": "chatroom_message",
    };

    debugPrint(
        "recipientUser = $chatConversation  recipientUser.conversationId = ${chatConversation.conversationId}");
    if (chatConversation != null && chatConversation.conversationId != null) {
      DBSocketMessageHandler()
          .saveMessageToDb(message: SocketQueueChatMessage.fromJson(data));

      String payload = convertServerPayload(data);

      addMessageToChat(message: payload);

      if (mounted) setState(() {});

      ChatMessage chatMessage = convertToChatMessage(data);

      await ChatMessageHandler().addChatMessage(chatMessage: chatMessage);

      scrollToBottom();

      updateConnectionList(
          messageData: data, conversationId: chatConversation.conversationId);
      await sendDataToSocket(data);
    } else {
      Toast.show("Please check your connection !!", context,
          textColor: Colors.white);
    }
  }

  Future<Map<String, dynamic>> getUserLocation() async {
    bool isLocationPermissionGranted = await Permission.location.isGranted;
    bool isLocationPermissionUnknown = await Permission.location.isUndetermined;

    if (!isLocationPermissionGranted || isLocationPermissionUnknown) {
      bool result = await showInAppLocationAlertPopUp(context: context);
      if (result == null) return null;
      if (result == false) return null;

      PermissionStatus permissionStatus = await Permission.location.request();
      if (permissionStatus != PermissionStatus.granted) {
        return null;
      }
    }

    final locationService = LocationService();
    UserLocation userLocation =
        await locationService.getLocation().catchError((error) {
      Toast.show("$error", context,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          duration: Toast.LENGTH_LONG);
    });

    if (userLocation == null) {
      return null;
    }

    Map<String, double> locationCoordinate = {
      "latitude": userLocation.latitude,
      "longitude": userLocation.longitude,
    };

    return locationCoordinate;
  }

  void sendUserLocationToSocket() async {
    showMoreAction = false;
    if (mounted) setState(() {});

    Map<String, double> locationCoordinate = await getUserLocation();

    if (locationCoordinate == null) return;

    Map<String, dynamic> data = {
      "check_id": Uuid().v4(),
      "conversation_id": chatConversation.conversationId,
      "author": userBloc.user.userName,
      "author_full_name": userBloc.user.fullName,
      "author_avatar": userBloc.user.avatar,
      "message": jsonEncode(locationCoordinate),
      "kind": "user_location",
      "read_by_author": true,
      "read_by_recipient": false,
      "delivered": false,
      "created_at": DateTime.now().toUtc().toIso8601String(),
      "type": "chatroom_message",
    };

    debugPrint(
        "recipientUser = $chatConversation  recipientUser.conversationId = ${chatConversation.conversationId}");
    if (chatConversation != null && chatConversation.conversationId != null) {
      DBSocketMessageHandler()
          .saveMessageToDb(message: SocketQueueChatMessage.fromJson(data));

      String payload = convertServerPayload(data);

      addMessageToChat(message: payload);

      if (mounted) setState(() {});

      ChatMessage chatMessage = convertToChatMessage(data);

      await ChatMessageHandler().addChatMessage(chatMessage: chatMessage);

      scrollToBottom();

      updateConnectionList(
          messageData: data, conversationId: chatConversation.conversationId);
      await sendDataToSocket(data);
    } else {
      Toast.show("Please check your connection !!", context,
          textColor: Colors.white);
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
      "conversation_id": chatConversation.conversationId,
      "author": userBloc.user.userName,
      "author_full_name": userBloc.user.fullName,
      "author_avatar": userBloc.user.avatar,
      "message": message,
      "kind": "text",
      "read_by_author": true,
      "read_by_recipient": false,
      "delivered": false,
      "created_at": DateTime.now().toUtc().toIso8601String(),
      "type": "chatroom_message",
    };

    debugPrint(
        "recipientUser = $chatConversation  recipientUser.conversationId = ${chatConversation.conversationId}");
    if (chatConversation != null && chatConversation.conversationId != null) {
      DBSocketMessageHandler()
          .saveMessageToDb(message: SocketQueueChatMessage.fromJson(data));

      String payload = convertServerPayload(data);

      addMessageToChat(message: payload);

      messageController.text = "";
      if (mounted) setState(() {});

      ChatMessage chatMessage = convertToChatMessage(data);

      await ChatMessageHandler().addChatMessage(chatMessage: chatMessage);

      scrollToBottom();

      updateConnectionList(
          messageData: data, conversationId: chatConversation.conversationId);
      await sendDataToSocket(data);
    } else {
      Toast.show("Please check your connection !!", context,
          textColor: Colors.white);
    }
  }

  String convertServerPayload(Map<String, dynamic> data) {
    Map<String, dynamic> newData = {};
    newData["check_id"] = data["check_id"];
    newData["conversation"] = data["conversation_id"];
    newData["author"] = data["author"];
    newData["author_full_name"] = data["author_full_name"];
    newData["author_avatar"] = data["author_avatar"];
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
    newData["replied_to"] = data["replied_to"] ?? {};

    return jsonEncode(newData);
  }

  ChatMessage convertToChatMessage(Map<String, dynamic> data) {
    Map<String, dynamic> newData = {};
    newData["check_id"] = data["check_id"];
    newData["conversation"] = data["conversation_id"];
    newData["author"] = data["author"];
    newData["author_full_name"] = data["author_full_name"];
    newData["author_avatar"] = data["author_avatar"];
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
    newData["replied_to"] = data["replied_to"] ?? {};

    return ChatMessage.fromJson(newData);
  }

  Widget scaffoldBody() {
    return Container(
      child: Column(
        children: [
          Expanded(
            child: isChatConversationLoading
                ? Center(child: CircularLoadingIndicator())
                : messageListBuilder(),
          ),
          isEditingMessage ? getEditingMessageWidget() : Container(),
          isReplyingMessage ? getReplyingMessageWidget() : Container(),
          messageActionBar()
        ],
      ),
    );
  }

  Widget getEditingMessageWidget() {
    Map<String, dynamic> messageData = jsonDecode(editingMessage);

    return Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            Divider(
              height: 0,
              thickness: 1,
              color: dividerColor,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                    icon: Icon(
                      SlydoAppIcon.close_2,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () {}),
                Expanded(
                  child: EditOrReplyMessageUI(
                      messageData: messageData,
                      chatConversation: chatConversation),
                ),
                IconButton(
                    icon: Icon(
                      SlydoAppIcon.close_2,
                      color: Colors.white,
                      size: 22,
                    ),
                    onPressed: () async {
                      isEditingMessage = false;
                      editingMessage = null;
                      if (mounted) setState(() {});
                    })
              ],
            ),
          ],
        ));
  }

  Widget getReplyingMessageWidget() {
    Map<String, dynamic> messageData = jsonDecode(replayingMessage);

    return Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            Divider(
              height: 0,
              thickness: 1,
              color: dividerColor,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                    icon: Icon(
                      SlydoAppIcon.close_2,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () {}),
                Expanded(
                  child: EditOrReplyMessageUI(
                    messageData: messageData,
                    chatConversation: chatConversation,
                  ),
                ),
                Container(
                  width: 48,
                  padding: EdgeInsets.only(top: 4),
                  child: GestureDetector(
                      child: Icon(
                        Icons.close_rounded,
                        color: darkGrey,
                        size: 18,
                      ),
                      onTap: () async {
                        isReplyingMessage = false;
                        replayingMessage = null;
                        if (mounted) setState(() {});
                      }),
                ),
              ],
            ),
          ],
        ));
  }

  Widget messageListBuilder() {
    try {
      return isLoading && messageList.isEmpty
          ? Center(
              child: CircularLoadingIndicator(),
            )
          : Container(
              child: LazyLoadScrollView(
                isLoading: isLoading,
                onEndOfPage: getPreviousMessages,
                child: getGroupMessage(),
              ),
            );
    } catch (error) {
      debugPrint("ERROR ====>1:- $error");
      return Container(
        color: Colors.white,
      );
    }
  }

  Widget getGroupMessage() {
    try {
      return StickyGroupedListView<String, DateTime>(
        itemPositionsListener: messageListPositionListener,
        elements: messageList,
        groupBy: (String element) {
          Map<String, dynamic> message = jsonDecode(element);
          DateTime dateTime = DateTime.parse(message['created_at']).toLocal();
          DateTime date = DateTime(dateTime.year, dateTime.month, dateTime.day);
          return date;
        },
        stickyHeaderBackgroundColor: Colors.transparent,
        groupSeparatorBuilder: (String element) {
          Map<String, dynamic> message = jsonDecode(element);

          DateTime dateTime = DateTime.parse(message['created_at']).toLocal();

          String formattedDate = formatDateInTwoDigit(dateTime);

          DateTime presentDate = DateTime.now().toLocal();

          /// checking if git is today's Date
          if (DateTime(presentDate.year, presentDate.month, presentDate.day)
                  .compareTo(
                      DateTime(dateTime.year, dateTime.month, dateTime.day)) ==
              0) {
            formattedDate = "Today";
          }

          return Container(
            padding: EdgeInsets.only(top: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.only(bottom: 4),
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: navyBlue.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(25)),
                  child: Text(
                    isLoading ? "Loading ..." : "$formattedDate",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        itemBuilder: (context, String element) => Container(
          padding: EdgeInsets.only(bottom: 4),
          child: GestureDetector(
            onLongPress: () {
              showChatMessageAction(message: element);
            },
            child: renderDataAccordingType(element),
          ),
        ),
        itemComparator: (element1, element2) {
          Map<String, dynamic> message1 = jsonDecode(element1);
          Map<String, dynamic> message2 = jsonDecode(element2);
          DateTime messageOneDateTime =
              DateTime.parse(message1['created_at']).toLocal();
          DateTime messageTwoDateTime =
              DateTime.parse(message2['created_at']).toLocal();

          return messageOneDateTime.compareTo(messageTwoDateTime);
        },
        // optional
        itemScrollController: messageListController,
        // optional

        groupComparator: (dateTime1, dateTime2) {
          DateTime groupOneDate =
              DateTime(dateTime1.year, dateTime1.month, dateTime1.day);
          DateTime groupTwoDate =
              DateTime(dateTime2.year, dateTime2.month, dateTime2.day);
          return groupOneDate.compareTo(groupTwoDate);
        },
        order: StickyGroupedListOrder.DESC,
        reverse: true,
      );
    } catch (error) {
      debugPrint("ERROR ====>2:- $error");
      return Container(
        color: Colors.white,
      );
    }
  }

  // Widget _buildIndicator() {
  //   return isLoading
  //       ? Padding(
  //           padding: const EdgeInsets.all(8.0),
  //           child: new Center(
  //             child: new Opacity(
  //               opacity: isLoading ? 1.0 : 00,
  //               child: CircularLoadingIndicator(),
  //             ),
  //           ),
  //         )
  //       : Container();
  // }

  Widget renderMessage(
      {Map<String, dynamic> message, ChatConversation chatConversation}) {
    bool isReplyMessage = false;

    Map<String, dynamic> isReplyTo = message["replied_to"] is String
        ? jsonDecode(message["replied_to"])
        : message["replied_to"] ?? {};

    if (isReplyTo.isNotEmpty) {
      isReplyMessage = true;
    }

    return TextMessageRendererForChat(
        message: message,
        chatConversation: chatConversation,
        onReplyMessageTap: isReplyMessage
            ? () {
                replyMessageTapped(repliedTo: isReplyTo);
              }
            : null);
  }

  void replyMessageTapped({Map<String, dynamic> repliedTo}) {
    if (repliedTo.isNotEmpty) {
      int messageListLength = messageList.length;

      int index;
      for (int i = 0; i < messageList.length; i++) {
        Map<String, dynamic> messageData = jsonDecode(messageList[i]);

        if (repliedTo['id'] == messageData['id'] ||
            repliedTo['check_id'] == messageData['check_id']) {
          debugPrint(
              "==> ${repliedTo['id']} == ${messageData['id']} =>  ${repliedTo['id'] == messageData['id']}");
          debugPrint(
              "==> ${repliedTo['check_id']} == ${messageData['check_id']} =>  ${repliedTo['check_id'] == messageData['check_id']}");
          index = i;
          break;
        }
      }

      if (index != null) {
        if (mounted) setState(() {});

        messageListController.scrollTo(
            index: (messageListLength - index - 4) > 0
                ? messageListLength - index - 4
                : 0,
            duration: Duration(milliseconds: 500));
      }
    }
  }

  Widget renderImageMedia(
      {Map<String, dynamic> message, ChatConversation chatConversation}) {
    return ImageTileForChat(
        message: message, chatConversation: chatConversation);
  }

  Widget renderAudioMedia(
      {Map<String, dynamic> message, ChatConversation chatConversation}) {
    return AudioTileForChat(
        message: message, chatConversation: chatConversation);
  }

  Widget renderVideoMedia(
      {Map<String, dynamic> message, ChatConversation chatConversation}) {
    return VideoTileForChat(
        message: message, chatConversation: chatConversation);
  }

  Widget renderPaymentRequest(
      {Map<String, dynamic> message, ChatConversation chatConversation}) {
    return PaymentRequestTileForChat(
        message: message,
        userBloc: userBloc,
        chatConversation: chatConversation);
  }

  Widget renderUserProfile(
      {Map<String, dynamic> message, ChatConversation chatConversation}) {
    return UserProfileTileForChat(
        message: message, chatConversation: chatConversation);
  }

  Widget renderSendPayment(
      {Map<String, dynamic> message, ChatConversation chatConversation}) {
    return TransactionTileForChat(
        message: message,
        userBloc: userBloc,
        chatConversation: chatConversation);
  }

  Widget renderProduct(
      {Map<String, dynamic> item, ChatConversation chatConversation}) {
    return ProductTileForChatMessage(
        message: item, chatConversation: chatConversation);
  }

  Widget renderService(
      {Map<String, dynamic> item, ChatConversation chatConversation}) {
    return ServiceTileChatMessage(
        message: item, chatConversation: chatConversation);
  }

  Widget renderUserLocation(
      {Map<String, dynamic> message, ChatConversation chatConversation}) {
    return LocationTileForChatMessage(
        message: message, chatConversation: chatConversation);
  }

  Widget renderGIFImage(
      {Map<String, dynamic> message, ChatConversation chatConversation}) {
    return GIFImageForChatMessage(
        message: message, chatConversation: chatConversation);
  }

  Widget renderEnvelopeUI(
      {Map<String, dynamic> message, ChatConversation chatConversation}) {
    return EnvelopeTileForChat(
        message: message, chatConversation: chatConversation);
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
          if (element["item"].messageId == item.messageId) {
            mapData = element;
            return;
          }
        });
        Map data = {
          "type": type,
          "id": mapData["item"].messageId,
          "qty": mapData["qty"],
        };
        debugPrint("Data From Product Page : $data");
        Toast.show("Item added to the cart !!", context);
        await ShoppingAuthService().addItemToShoppingCart(data);
      },
    );
  }

  Widget unKnownMessageType() {
    return Container();
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
    stopShakeDetector();
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
    setupShakeDetector();
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
  }

  void clearSearchedListItems() {
    searchedProductAndService.clear();
    productOrServiceCount = 0;
    productOrServiceNext = "";
    productOrServicePrevious = "";
    if (bottomSheetStateSetterGlobal != null) if (bottomSheetMounted)
      bottomSheetStateSetterGlobal(() {});
    if (mounted) setState(() {});
  }

  void getProductOrServiceList() async {
    // String url = getFinalUrlWithUser();
    String url = getSearchUrl();

    if (!isItemLoading) {
      if (productOrServiceNext != null && !isItemLoading) {
        isItemLoading = true;

        if (bottomSheetStateSetterGlobal != null) if (bottomSheetMounted)
          bottomSheetStateSetterGlobal(() {});
        if (mounted) setState(() {});

        Map<String, dynamic> result = await MessageAuth()
            .searchProductAndServiceOfUser(
                url, productOrServiceNext, productOrServicePrevious);
        productOrServiceCount = result['count'];
        productOrServiceNext = result['next'];
        productOrServicePrevious = result['previous'];
        List tempList = result['results'];

        isItemLoading = false;
        if (bottomSheetStateSetterGlobal != null) if (bottomSheetMounted)
          bottomSheetStateSetterGlobal(() {});
        if (mounted) setState(() {});

        tempList.forEach((item) {
          if (isProductSearch) {
            searchedProductAndService.add(Product.fromJson(item));
          } else if (isServiceSearch) {
            searchedProductAndService.add(Service.fromJson(item));
          }
        });

        if (bottomSheetStateSetterGlobal != null) if (bottomSheetMounted)
          bottomSheetStateSetterGlobal(() {});
        if (mounted) setState(() {});
      }
      if (searchedProductAndService.isEmpty) {
        noSearchedItem = true;
        if (bottomSheetStateSetterGlobal != null) if (bottomSheetMounted)
          bottomSheetStateSetterGlobal(() {});
        if (mounted) setState(() {});
      }
    }
  }

  String getSearchUrl() {
    if (isProductSearch) {
      return AppConfig.baseUrl +
          "/api/v1/search/products/?search=name__wildcard|*" +
          searchItemTextController.text +
          "*";
    }
    if (isServiceSearch) {
      return AppConfig.baseUrl +
          "/api/v1/search/services/?search=name__wildcard|*" +
          searchItemTextController.text +
          "*";
    }
    return "";
  }

  String getFinalUrlWithUser() {
    String url = getSearchUrl();

    if (bottomSheetSearchIndex == 0 && isProductSearch) {
      url += "&search=seller:" + chatConversation.userName;
      return url;
    } else if (bottomSheetSearchIndex == 1 && isProductSearch) {
      url += "&search=seller:" + userBloc.user.userName;
      return url;
    } else if (bottomSheetSearchIndex == 0 && isServiceSearch) {
      url += "&search=provider:" + chatConversation.userName;
      return url;
    } else if (bottomSheetSearchIndex == 1 && isServiceSearch) {
      url += "&search=provider:" + userBloc.user.userName;
      return url;
    }
    return url;
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

  // ignore: missing_return
  IconData getSearchTypeIcon() {
    if (selectedMenuItemIndex == 1) {
      return SlydoAppIcon.note_2;
    } else if (selectedMenuItemIndex == 0) {
      return SlydoAppIcon.product;
    }
  }

  Widget bottomSheetTabBar() {
    return Column(
      children: [
        // Container(
        //     padding: EdgeInsets.symmetric(horizontal: 20),
        //     child: bottomSheetTabBars()),
        SizedBox(
          height: 8,
        ),
        Expanded(child: bottomSheetTabViews())
      ],
    );
  }

  Widget bottomSheetTabBars() {
    return PreferredSize(
        preferredSize: Size.fromHeight(50.0),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                bottomSheetSearchIndex = 0;
                clearSearchedListItems();
                bottomSheetStateSetterGlobal(() {});
                setState(() {});
                searchProductOrService();
              },
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
            GestureDetector(
              onTap: () {
                bottomSheetSearchIndex = 1;
                clearSearchedListItems();
                bottomSheetStateSetterGlobal(() {});
                setState(() {});
                searchProductOrService();
              },
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
        ));
  }

  Widget bottomSheetTabViews() {
    return pullToRefresh();
  }

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
          AppLocalization.of(context).internetConnectionNotAvailable,
          context,
          gravity: Toast.BOTTOM,
          backgroundColor: Colors.black,
          textColor: Colors.white,
        );
        _refreshController.refreshCompleted();
      }
    });
  }

  Widget pullToRefresh() {
    return searchItemTextController.text.isEmpty
        ? NoItemInList(
            msg: AppLocalization.of(context).pleaseTypeSomethingToGetResult,
            isResult: false,
          )
        : SmartRefresher(
            enablePullDown: true,
            header: WaterDropHeader(
              complete: Container(),
              waterDropColor: navyBlue,
            ),
            controller: _refreshController,
            onRefresh: _onRefresh,
            child: buildProductOrServiceList(),
          );
  }

  Widget buildProductOrServiceList() {
    return noSearchedItem
        ? NoItemInList(
            msg: AppLocalization.of(context).noResultFound,
            isResult: true,
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
    return Center(
      child: isItemLoading
          ? CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation(navyBlue),
              backgroundColor: Colors.transparent,
            )
          : Container(),
    );
  }

  void showChatMessageAction({@required String message}) {
    debugPrint("Showing actions");
    selectChatMessageAction(message: message);
  }

  void selectChatMessageAction({@required String message}) {
    showModalBottomSheet<String>(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (context) => Card(
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
                  children: getChatMessageActionTiles(message: message),
                ),
              ),
            ));
  }

  List<Widget> getChatMessageActionTiles({@required String message}) {
    bool isEditable = false;
    bool isDeletable = false;
    ChatMessageAction chatMessageAction = GetChatMessageActions()
        .getActions(message: message, userBloc: userBloc);

    List<Widget> elements = [];

    Map<String, dynamic> messageData = jsonDecode(message);

    DateTime messageCreatedTime =
        DateTime.parse(messageData["created_at"]).toLocal();

    DateTime currentTime = DateTime.now();

    if (currentTime.difference(messageCreatedTime) < Duration(minutes: 1)) {
      isEditable = true;
    }
    if (currentTime.difference(messageCreatedTime) < Duration(minutes: 2)) {
      isDeletable = true;
    }

    if (chatMessageAction.isCopyable) {
      elements.add(bottomSheetItem(
        title: "Copy message",
        icon: SlydoAppIcon.copy,
        onTap: () {
          copyChatMessage(message: message);

          Navigator.pop(context);
        },
      ));
    }
    if (isEditable) {
      if (chatMessageAction.isEditable) {
        elements.add(bottomSheetItem(
          title: "Edit message",
          icon: SlydoAppIcon.edit,
          onTap: () {
            editChatMessage(message: message);

            Navigator.pop(context);
          },
        ));
      }
    }
    if (isDeletable) {
      if (chatMessageAction.isDeletable) {
        elements.add(bottomSheetItem(
          title: messageData['kind'] == "envelope" ? "Cancel" : "Delete",
          icon: messageData['kind'] == "envelope"
              ? SlydoAppIcon.remove
              : SlydoAppIcon.delete,
          onTap: () {
            Navigator.pop(context);
            deleteChatMessage(message: message);
          },
        ));
      }
    }

    if (chatMessageAction.isReplyable) {
      elements.add(bottomSheetItem(
        title: "Reply",
        icon: SlydoAppIcon.reply,
        onTap: () {
          replyChatMessage(message: message);
          Navigator.pop(context);
        },
      ));
    }

    return elements;
  }

  void deleteChatMessage({String message}) async {
    Map<String, dynamic> messageData = jsonDecode(message);

    if (messageData['kind'] == "envelope") {
      cancelEnvelope(messageData);
      return;
    }

    String messageId = messageData["check_id"];

    if (chatConversation != null && chatConversation.conversationId != null) {
      // addMessageToChat(message: payload);

      Map<String, dynamic> data = Map<String, dynamic>();

      data["check_id"] = messageId;
      data["conversation_id"] =
          messageData["conversation_id"] ?? messageData["conversation"];
      data["type"] = "delete_message";
      data["text"] = "delete_message";

      deleteMessageFromMessageList(message: data);

      FocusScope.of(context).unfocus();
      if (mounted) setState(() {});

      await sendDataToSocket(data);
    } else {
      Toast.show("Please check your connection !!", context,
          textColor: Colors.white);
    }
  }

  void copyChatMessage({String message}) {
    String textToBeCopy;

    Map<String, dynamic> messageData = jsonDecode(message);

    String messageType = messageData["kind"];
    switch (messageType) {
      case "text":
        textToBeCopy = messageData["text"] ?? null;
        break;

      case "image":
        textToBeCopy = messageData["text"] == "" || messageData["text"] == null
            ? messageData["media"]
            : messageData["text"];
        break;

      case "video":
        textToBeCopy = messageData["text"] == "" || messageData["text"] == null
            ? messageData["media"]
            : messageData["text"];
        break;

      case "audio":
        textToBeCopy = messageData["text"] == "" || messageData["text"] == null
            ? messageData["media"]
            : messageData["text"];
        break;

      default:
        debugPrint(
            "Not implemented Coping Message Kind: $messageType Message:- $message");
    }

    if (textToBeCopy != null) {
      Clipboard.setData(new ClipboardData(
          text: messageDecoderWithEmoji(textToBeCopy.toString())));
      Toast.show("Message copied !!", context,
          gravity: Toast.BOTTOM,
          duration: Toast.LENGTH_LONG,
          backgroundColor: Colors.black,
          textColor: Colors.white);
    }
  }

  void editChatMessage({String message}) {
    Map<String, dynamic> messageData = jsonDecode(message);

    String messageType = messageData["kind"];
    switch (messageType) {
      case "text":
        updateChatTextMessage(message: message);
        break;

      default:
        debugPrint(
            "Not implemented Editing Message Kind: $messageType Message:- $message");
    }
  }

  void updateChatTextMessage({String message}) {
    Map<String, dynamic> messageData = jsonDecode(message);
    messageController.text = messageData["text"];

    // if (!messageFocus.hasFocus) {
    //   messageFocus.requestFocus();

    editingMessage = message;
    isEditingMessage = true;
    fabIsVisible = false;
    if (mounted) setState(() {});
    // }
  }

  void editTextMessage() async {
    String message = messageController.text.trim();

    if (message.isEmpty) {
      return;
    }

    showMoreAction = false;
    if (mounted) setState(() {});

    debugPrint(
        "recipientUser = $chatConversation  recipientUser.conversationId = ${chatConversation.conversationId}");
    if (chatConversation != null && chatConversation.conversationId != null) {
      // addMessageToChat(message: payload);

      Map<String, dynamic> data = new Map<String, dynamic>();

      Map<String, dynamic> oldMessageData = jsonDecode(editingMessage);
      debugPrint("old Data :- $oldMessageData");
      data["text"] = message;
      data["check_id"] = oldMessageData["check_id"];
      data["conversation_id"] = oldMessageData["conversation_id"];
      data["type"] = "edit_message";

      messageController.text = "";
      if (mounted) setState(() {});

      updateEditedMessageInMessageList(message: data);

      isEditingMessage = false;
      editingMessage = null;
      if (mounted) setState(() {});

      await sendDataToSocket(data);
    } else {
      Toast.show("Please check your connection !!", context,
          textColor: Colors.white);
    }
  }

  void deleteMessageFromMessageList({Map<String, dynamic> message}) {
    ///{"check_id": "926f06cb-f3f9-40a5-93d5-06acc8e8f76e",
    /// "type": "delete_message",
    /// "conversation_id": "9ae68069-b342-4e04-b568-602bde6fe901"}

    if (chatConversation.conversationId == message["conversation_id"]) {
      for (int i = 0; i < messageList.length; i++) {
        Map<String, dynamic> decodedMessage = jsonDecode(messageList[i]);

        if (message["check_id"] == decodedMessage["check_id"]) {
          messageList.removeAt(i);

          if (mounted) setState(() {});
        }
      }
    }
  }

  void updateEditedMessageInMessageList({Map<String, dynamic> message}) {
    ///{"check_id": "bda45320-45fe-4071-a242-b9491dff6223",
    /// "type": "edit_message",
    /// "kind": "text",
    /// "conversation_id": "9ae68069-b342-4e04-b568-602bde6fe901",
    /// "was_edited": false}

    if (chatConversation.conversationId == message["conversation_id"]) {
      for (int i = 0; i < messageList.length; i++) {
        Map<String, dynamic> decodedMessage = jsonDecode(messageList[i]);

        if (message["check_id"] == decodedMessage["check_id"]) {
          decodedMessage["was_edited"] = message["was_edited"];
          decodedMessage["text"] = message["text"];

          String encodedMessage = jsonEncode(decodedMessage);
          messageList[i] = encodedMessage;

          if (mounted) setState(() {});
        }
      }
    }
  }

  void replyChatMessage({String message}) {
    isReplyingMessage = false;
    replayingMessage = null;

    messageFocus.unfocus();

    messageFocus.requestFocus();

    replayingMessage = message;
    isReplyingMessage = true;
    fabIsVisible = false;
    if (mounted) setState(() {});
  }

  void sendReplyChatMessage() async {
    String message = messageController.text.trim();

    if (message.isEmpty) {
      return;
    }

    showMoreAction = false;
    if (mounted) setState(() {});

    Map<String, dynamic> data = {
      "check_id": Uuid().v4(),
      "conversation_id": chatConversation.conversationId,
      "author": userBloc.user.userName,
      "author_full_name": userBloc.user.fullName,
      "author_avatar": userBloc.user.avatar,
      "message": message,
      "kind": "text",
      "read_by_author": true,
      "read_by_recipient": false,
      "delivered": false,
      "created_at": DateTime.now().toUtc().toIso8601String(),
      "type": "reply_message",
      "replied_to": replayingMessage
    };

    debugPrint(
        "recipientUser = $chatConversation  recipientUser.conversationId = ${chatConversation.conversationId}");
    if (chatConversation != null && chatConversation.conversationId != null) {
      DBSocketMessageHandler()
          .saveMessageToDb(message: SocketQueueChatMessage.fromJson(data));

      String payload = convertServerPayload(data);

      addMessageToChat(message: payload);

      messageController.text = "";
      if (mounted) setState(() {});

      replayingMessage = null;
      isReplyingMessage = false;
      if (mounted) setState(() {});

      ChatMessage chatMessage = convertToChatMessage(data);

      await ChatMessageHandler().addChatMessage(chatMessage: chatMessage);
      scrollToBottom();

      updateConnectionList(
          messageData: data, conversationId: chatConversation.conversationId);
      await sendDataToSocket(data);
    }
  }

  void updateConnectionList(
      {Map<String, dynamic> messageData, String conversationId}) {
    if (messageData.containsKey("created_at")) {
      DateTime dateTime = DateTime.parse(messageData["created_at"]).toLocal();
      int time = dateTime.millisecondsSinceEpoch;

      debugPrint("Last message Time => $time");

      ConnectionListBloc connectionListBloc = Provider.of<ConnectionListBloc>(
          myGlobals.scaffoldKey.currentContext,
          listen: false);
      connectionListBloc.updateLastMessageTime(
          conversationId: conversationId, time: time);
    }
  }

  void cancelEnvelope(Map<String, dynamic> message) async {
    Map<String, dynamic> data;

    if (message['meta_data'] is String) {
      data = jsonDecode(message['meta_data']);
    } else if (message['meta_data'] is Map) {
      data = message['meta_data'];
    }

    Envelope envelope = Envelope.fromJson(data);

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularLoadingIndicator()));

    var result = await MessageAuth()
        .cancelEnvelope(envelope: envelope, data: message)
        .catchError((error) {
      Navigator.pop(context);
      Toast.show("ERROR:- $error", context, duration: 2);
    });

    if (result != null) {
      if (result == true) {
        Navigator.pop(context);
        return;
      } else {
        Navigator.pop(context);
        Toast.show("Failed to cancel Envelope", context, duration: 2);
      }
    }
  }
}
