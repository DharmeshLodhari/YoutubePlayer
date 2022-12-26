import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/main.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/yarn/models/Topics/CommentDetails.dart';
import 'package:Slydo/screens/more_apps/yarn/models/Topics/YarnTopic.dart';
import 'package:Slydo/screens/more_apps/yarn/tiles/yarn_list_tile.dart';
import 'package:Slydo/screens/more_apps/yarn/utils/utils.dart';
import 'package:Slydo/screens/more_apps/yarn/widgets/yarn_comment_textfield.dart';
import 'package:Slydo/screens/more_apps/yarn/widgets/yarn_shimmer.dart';
import 'package:Slydo/screens/more_apps/yarn/yarn_auth.dart';
import 'package:Slydo/screens/more_apps/yarn/yarn_comment_list.dart';
import 'package:Slydo/utils/util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'models/share_as_yarn_model.dart';
import 'widgets/ask_mention_view.dart';

class YarnDetailScreen extends StatefulWidget {
  final Yarn yarn;

  YarnDetailScreen({required this.yarn});

  @override
  State<YarnDetailScreen> createState() => _YarnDetailScreenState();
}

class _YarnDetailScreenState extends State<YarnDetailScreen> {
  bool isLoading = false;

  late UserBloc userBloc;
  final TextEditingController controller = TextEditingController();
  RefreshController _postRefreshController =
      RefreshController(initialRefresh: false);
  bool isAPILoading = false;
  ScrollController _commentScrollController = new ScrollController();
  ScrollController scrollController = new ScrollController();
  GlobalKey<ScaffoldState> yarnCommentScreenKey = GlobalKey<ScaffoldState>();
  bool? enableComment = false, enablePayment = false;
  bool? viewerAdvice = false, adultOnly = false;
  bool isMentionName = false;
  String? searchString;
  var ageRating;
  List<AddMediaForYarn> selectedMedia = [];
  bool isScrolling = false;

  @override
  void initState() {
     scrollController.addListener(() {
        setState(() => isScrolling = true);
      });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
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
        !widget.yarn.isQuestion ? "Yarn" : "Question",
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
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
    return Column(
      children: [
        _buildPostAndCommentView(),
        if (isMentionName) ...[
          _buildUserNameContainer(),
        ],
        _buildTopicTextFiled(),
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
        child: ListView(
          controller: scrollController,
          children: [
            if (isLoading) YarnShimmer(),
            if (!isLoading) _buildMain(),
          ],
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
            yarn: widget.yarn,
            onDeleteYarn: (Yarn yarn) {
              Navigator.of(context).pop();
            },
          ),
        ),
        YarnCommentList(
          key: yarnCommentScreenKey,
          yarn: widget.yarn,
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
    return YarnCommentTextField(
      height: 50,
      controller: controller,
      hint: "Leave your thought",
      yarn: widget.yarn,
      // scrollController: scrollController,
      shareAsYarnModel: ShareAsYarnModel.shareAsYarnModel,
      userImage: userBloc.user.avatar,
      isLoading: isAPILoading,
      onChanged: onValueChange,
      // unFocus: unFocusValue,
      enableComment: enableComment,
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
      enablePayment: enablePayment,
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
      },
    );
  }

  Future addComment() async {
    Map<String, dynamic> data = {
      "comment": controller.text,
      "author_username": userBloc.user.userName,
      "enable_payme": enablePayment,
      "enable_commenting": enableComment,
      "is_adult_content": adultOnly,
      "is_sensitive_content": viewerAdvice,
      "age_restriction": ageRating ?? 13,
      "media_count": selectedMedia,
    };

    logger.d(data);

    try {
      YarnComment? commentDetails =
          await YarnAuth().addCommentToYarn(widget.yarn.id!, data);
      if (commentDetails != null) {
        setState(() {
          widget.yarn.numberOfComments = widget.yarn.numberOfComments! + 1;
        });
        // commentDetailsList.add(commentDetails);
        yarnCommentScreenKey = GlobalKey<ScaffoldState>();

        controller.clear();

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
