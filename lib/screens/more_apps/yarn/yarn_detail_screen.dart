import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/main.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/yarn/models/Topics/CommentDetails.dart';
import 'package:Slydo/screens/more_apps/yarn/models/Topics/yarn_model.dart';
import 'package:Slydo/screens/more_apps/yarn/tiles/yarn_list_tile.dart';
import 'package:Slydo/screens/more_apps/yarn/utils/utils.dart';
import 'package:Slydo/screens/more_apps/yarn/widgets/yarn_comment_textfield.dart';
import 'package:Slydo/screens/more_apps/yarn/widgets/yarn_shimmer.dart';
import 'package:Slydo/screens/more_apps/yarn/yarn_auth.dart';
import 'package:Slydo/screens/more_apps/yarn/yarn_comment_list.dart';
import 'package:Slydo/screens/more_apps/yarn/yarn_dashboard_bloc.dart';
import 'package:Slydo/utils/util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'models/share_as_yarn_model.dart';
import 'widgets/ask_mention_view.dart';

class YarnDetailScreen extends StatefulWidget {
  final Yarn yarn;
  String? yarnId;

  YarnDetailScreen({required this.yarn, this.yarnId});

  @override
  State<YarnDetailScreen> createState() => _YarnDetailScreenState();
}

class _YarnDetailScreenState extends State<YarnDetailScreen> {
  bool isLoading = false;
  bool isSingleYarnLoading = false;

  late UserBloc userBloc;
  final TextEditingController controller = TextEditingController();
  RefreshController _postRefreshController =
      RefreshController(initialRefresh: false);
  bool isAPILoading = false;
  ScrollController _commentScrollController = new ScrollController();
  ScrollController scrollController = new ScrollController();
  GlobalKey<ScaffoldState> yarnCommentScreenKey = GlobalKey<ScaffoldState>();
  bool? enableComment = true;
  bool? enablePayment = true;
  bool? viewerAdvice = false;
  bool? adultOnly = false;
  bool isMentionName = false;
  String? searchString;
  var ageRating;
  List<YarnMedia> selectedMedia = [];
  bool isScrolling = false;
  Yarn? finalYarn;
  GlobalKey<YarnCommentTextFieldState> yarnCommentTextFieldStateKey =
      GlobalKey<YarnCommentTextFieldState>();
  Product? productValue;
  Service? serviceValue;
  YarnDashboardBloc? yarnDashboardBloc;
  String? userName;

  @override
  void initState() {
    if (widget.yarnId != null) {
      getSingleYarn();
    } else {
      finalYarn = widget.yarn;
    }
    scrollController.addListener(() {
      setState(() => isScrolling = true);
    });

    super.initState();
  }

  Future getSingleYarn() async {
    isSingleYarnLoading = true;
    if (mounted) setState(() {});

    Map<String, dynamic>? result =
        await YarnAuth().getSingleTopics(yarnId: widget.yarnId!);
    if (result != null) {
      finalYarn = result['results'];
    }
    isSingleYarnLoading = false;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    yarnDashboardBloc = Provider.of<YarnDashboardBloc>(context);

    return ColorfulSafeArea(
      color: Colors.white,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(),
        body: _buildBody(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      title: Text(
        finalYarn != null
            ? !finalYarn!.isQuestion
                ? "Yarn"
                : "Question"
            : "",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: yarnBlack,
          height: 1.3,
        ),
      ),
      centerTitle: false,
      titleSpacing: 0,
      shadowColor: greySecondaryYarn,
      elevation: 0.5,
      actions: [
        Row(
          children: [
            _buildProfileImage(),
            SizedBox(
              width: 16,
            )
          ],
        ),
      ],
      leading: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(
          Icons.arrow_back_ios_rounded,
          color: yarnBlack,
          size: 14,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
        color: yarnBlack,
      ),
    );
  }

  Widget _buildProfileImage() {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, Routes.USER_PROFILE,
            arguments: {"searchedUserName": userBloc.user.userName});
      },
      child: Container(
        height: 35,
        width: 35,
        decoration: BoxDecoration(shape: BoxShape.circle),
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: userBloc.user.avatar!,
            fit: BoxFit.cover,
            errorWidget: imageErrorWidget,
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (isSingleYarnLoading) {
      return YarnShimmer();
    }

    return Column(
      // mainAxisAlignment: MainAxisAlignment.center,
      // mainAxisSize: MainAxisSize.max,
      children: [
        _buildPostAndCommentView(),
        if (isMentionName) ...[
          _buildUserNameContainer(),
        ],
        if (widget.yarn.enableCommenting ?? false) _buildTopicTextFiled(),
      ],
    );
  }

  Widget _buildPostAndCommentView() {
    return Expanded(
      child: SmartRefresher(
        enablePullDown: true,
        header: WaterDropHeader(
          complete: Container(),
          waterDropColor: yarnBlack,
        ),
        controller: _postRefreshController,
        onRefresh: _onPostRefresh,
        child: SingleChildScrollView(
          child: Column(children: <Widget>[
            if (isLoading) YarnShimmer(),
            if (!isLoading) _buildMain(),
          ]),
        ),
      ),
    );
  }

  Widget _buildMain() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: YarnTile(
            yarn: finalYarn!,
            onDeleteYarn: (Yarn yarn) {
              Navigator.of(context).pop();
            },
          ),
        ),
        YarnCommentList(
          key: yarnCommentScreenKey,
          yarn: finalYarn!,
          commentScrollController: _commentScrollController,
        ),
      ],
    );
  }

  Widget _buildUserNameContainer() {
    return AskMentionView(
      searchText: searchString,
      key: UniqueKey(),
      onTap: (String? tappedUser) {
        if (tappedUser != null) {
          controller.text = controller.text.replaceRange(
                (controller.text.length - (searchString?.length ?? 0)),
                controller.text.length,
                tappedUser,
              ) +
              " ";
          controller.selection = TextSelection.fromPosition(TextPosition(
            offset: controller.text.length,
          ));
          searchString = "";
          if (mounted) setState(() {});
        }
      },
    );
  }

  void onValueChange(String value) {
    List<String> listOfWords = value.split(" ");

    if (listOfWords.isNotEmpty) {
      if ((listOfWords.last.contains("@") &&
          !value.endsWith(" ") &&
          !value.endsWith("@"))) {
        isMentionName = true;
        List<String> mentionString = getAllMentions(value);

        if (mentionString.isNotEmpty) {
          searchString = mentionString.last.substring(1);
        }
      } else if (value.endsWith("@")) {
        isMentionName = true;

        searchString = "";
      } else {
        isMentionName = false;
      }
    }
    if (mounted) setState(() {});
  }

  Widget _buildTopicTextFiled() {
    userName = widget.yarn.author;
    return YarnCommentTextField(
      key: yarnCommentTextFieldStateKey,
      height: 50,
      controller: controller,
      hint: "Leave your thought",
      yarn: finalYarn,
      shareAsYarnModel: ShareAsYarnModel.shareAsYarnModel,
      userImage: userBloc.user.avatar,
      userName: widget.yarn.author,
      isLoading: isAPILoading,
      onChanged: onValueChange,
      enableComment: enableComment,
      enablePayment: enablePayment,
      enableAdult: adultOnly,
      viewerAdvice: viewerAdvice,
      isScrolling: isScrolling,
      resetScrollingValue: (p0) {
        setState(() => isScrolling = p0);
      },
      addedSelectedMedia: (value) {
        selectedMedia = value;
        setState(() {});
      },
      onTapEnableAdult: (value) {
        adultOnly = value;
        logger.d('adult $value');
        if (mounted) setState(() {});
      },
      onTapViewerAdvice: (value) {
        viewerAdvice = value;
        logger.d('adv $value');
        if (mounted) setState(() {});
      },
      onTapEnableComment: (value) {
        enableComment = value;
        logger.d('comment $enableComment');
        if (mounted) setState(() {});
      },
      onTapEnablePayment: (value) {
        enablePayment = value;
        logger.d('pay $enableComment');
        if (mounted) setState(() {});
      },
      onTapAgeRestriction: (value) {
        ageRating = value;
        logger.d('age $ageRating');
        setState(() {});
      },
      onPressed: () async {
        if (controller.text.isNotEmpty) {
          FocusScope.of(context).unfocus();
          isAPILoading = true;
          if (mounted) setState(() {});

          await addComment();
          isAPILoading = false;
          if (mounted) setState(() {});
        } else {
          showToast(message: 'Enter a valid comment');
        }
        enableComment = true;
        enablePayment = true;
        adultOnly = false;
        viewerAdvice = false;
        setState(() {});
      },
    );
  }

  Future addComment() async {
    Map<String, dynamic> data = {
      "comment": controller.text,
      "author_username": userName,
      "enable_payme": enablePayment,
      "enable_commenting": enableComment,
      "is_adult_content": adultOnly,
      "is_sensitive_content": viewerAdvice,
      "age_restriction": ageRating ?? 13,
      "media_count": selectedMedia,
    };

    if (yarnDashboardBloc!.productService != null) {
      data['attachment'] = yarnDashboardBloc!.productService;
    }

    try {
      YarnComment? commentDetails =
          await YarnAuth().addCommentToYarn(finalYarn!.id!, data);
      if (commentDetails != null) {
        setState(() {
          finalYarn!.numberOfComments = finalYarn!.numberOfComments! + 1;
        });
        // commentDetailsList.add(commentDetails);
        yarnCommentScreenKey = GlobalKey<ScaffoldState>();

        controller.clear();
        selectedMedia.clear();
        yarnCommentTextFieldStateKey.currentState?.onAPICall();
        //set product/service to null after comment is successful
        yarnDashboardBloc!.productService = null;

        if (mounted) setState(() {});
      }
    } catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  void _onPostRefresh() async {
    Connectivity().checkConnectivity().then((value) {
      var connectionResult = value;
      if (connectionResult == ConnectivityResult.wifi ||
          connectionResult == ConnectivityResult.mobile) {
        yarnCommentScreenKey = GlobalKey<ScaffoldState>();
        setState(() {
          _postRefreshController.refreshCompleted();
        });
      } else {
        showToast(
            message:
                AppLocalization.of(context)!.internetConnectionNotAvailable);
        setState(() {
          _postRefreshController.refreshCompleted();
        });
      }
    });
  }
}
