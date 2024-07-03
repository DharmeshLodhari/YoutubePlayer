import 'package:Slydo/data/state_notifiers/user_bloc.dart';
import 'package:Slydo/main.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/yarn/models/Topics/yarn_model.dart';
import 'package:Slydo/screens/more_apps/yarn/tiles/yarn_comment_tile.dart';
import 'package:Slydo/screens/more_apps/yarn/utils/utils.dart';
import 'package:Slydo/screens/more_apps/yarn/yarn_comment_reply_list.dart';
import 'package:Slydo/screens/more_apps/yarn/yarn_dashboard_bloc.dart';
import 'package:Slydo/utils/util.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'models/Topics/comment_details.dart';
import 'models/share_as_yarn_model.dart';
import 'widgets/yarn_comment_textfield.dart';
import 'widgets/yarn_shimmer.dart';
import 'yarn_auth.dart';

class YarnCommentDetailScreen extends StatefulWidget {
  final Yarn yarn;
  final YarnComment yarnComment;

  const YarnCommentDetailScreen(
      {super.key, required this.yarn, required this.yarnComment});

  @override
  State<YarnCommentDetailScreen> createState() =>
      _YarnCommentDetailScreenState();
}

class _YarnCommentDetailScreenState extends State<YarnCommentDetailScreen> {
  late UserBloc userBloc;
  bool isLoading = false;

  final TextEditingController controller = TextEditingController();
  final RefreshController _postRefreshController =
      RefreshController(initialRefresh: false);
  bool isAPILoading = false;
  final ScrollController _commentScrollController = ScrollController();
  GlobalKey<ScaffoldState> yarnCommentScreenKey = GlobalKey<ScaffoldState>();
  bool? enableComment = false, enablePayment = false;
  bool? enableAdult = false, viewerAdvice = false;
  String? ageRating;

  ScrollController scrollController = ScrollController();
  List<YarnMedia> selectedMedia = [];
  bool isScrolling = false;
  Product? productValue;
  Service? serviceValue;
  YarnDashboardBloc? yarnDashboardBloc;
  String? userName;
  int count = 0;

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
    yarnDashboardBloc = Provider.of<YarnDashboardBloc>(context);

    return ColorfulSafeArea(
      color: Colors.white,
      child: Scaffold(
          backgroundColor: lightGrey,
          appBar: _buildAppBar(),
          body: _buildBody()),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      surfaceTintColor: Colors.transparent,
      backgroundColor: Colors.white,
      title: Text(
        "Comments",
        // "Thread",
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
            const SizedBox(
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
      child: getUserProfilePic(userBloc.user.avatar!, userBloc.user.fullName!),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        _buildCommentDetailView(),
        if (widget.yarn.enableCommenting ?? false) _buildTopicTextField(),
      ],
    );
  }

  Widget _buildCommentDetailView() {
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
            if (isLoading) const YarnShimmer(),
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
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: YarnCommentTile(
                yarn: widget.yarn,
                yarnComment: widget.yarnComment,
                isCommentDetail: true,
                yarnCommentReply: widget.yarnComment,
                minusComment: count == 0 ? false : true,
                commentType: 'comment')),
        YarnCommentReplyList(
          key: yarnCommentScreenKey,
          yarn: widget.yarn,
          yarnComment: widget.yarnComment,
          commentScrollController: _commentScrollController,
          onCountChanged: (int val) {
            setState(() => count = val);
          },
        ),
      ],
    );
  }

  Widget _buildTopicTextField() {
    return YarnCommentTextField(
      height: 50,
      controller: controller,
      scrollController: scrollController,
      hint: "Leave your thought",
      yarn: widget.yarn,
      userImage: userBloc.user.avatar,
      userName: widget.yarnComment.authorUsername,
      shareAsYarnModel: ShareAsYarnModel.shareAsYarnModel,
      isLoading: isAPILoading,
      enableComment: enableComment,
      isScrolling: isScrolling,
      resetScrollingValue: (p0) {
        setState(() => isScrolling = p0);
      },
      addedSelectedMedia: (value) {
        selectedMedia = value;
        logger.d(selectedMedia);
        setState(() {});
      },
      onTapEnableComment: (value) {
        enableComment = value;
        if (mounted) setState(() {});
      },
      enablePayment: enablePayment,
      onTapEnablePayment: (value) {
        enablePayment = value;
        if (mounted) setState(() {});
      },
      onTapEnableAdult: (value) {
        enableAdult = value;
        if (mounted) setState(() {});
      },
      onTapViewerAdvice: (value) {
        viewerAdvice = value;
        if (mounted) setState(() {});
      },
      onPressed: () async {
        if (controller.text.isNotEmpty) {
          FocusScope.of(context).unfocus();
          isAPILoading = true;
          if (mounted) setState(() {});
          userName = widget.yarnComment.authorUsername;
          await addReplyComment();
          isAPILoading = false;
          if (mounted) setState(() {});
        } else {
          showToast(message: 'Enter a valid comment');
        }
      },
      onTapAgeRestriction: (value) {},
    );
  }

  Future addReplyComment() async {
    final Map<String, dynamic> data = {
      "comment": controller.text,
      "author_username": userName,
      "is_reply": true,
      "enable_payme": enablePayment,
      "enable_commenting": enableComment,
      "is_adult_content": enableAdult,
      "is_sensitive_content": viewerAdvice,
      "age_restriction": ageRating ?? 13,
      "media_count": selectedMedia,
    };

    if (yarnDashboardBloc!.productService != null) {
      data['attachment'] = yarnDashboardBloc!.productService;
    }

    // debugPrint('Comment detail Fol::; ${data}');

    //create multipart request for POST or PATCH method
    try {
      final YarnComment? commentDetail =
          await YarnAuth().addReplyToComment(widget.yarnComment.id!, data);
      if (commentDetail != null) {
        widget.yarnComment.replyCount = widget.yarnComment.replyCount! + 1;
        // replyCommentDetailsList.add(commentDetail);
        controller.clear();
        yarnCommentScreenKey = GlobalKey<ScaffoldState>();

        yarnDashboardBloc!.productService = null;

        if (mounted) setState(() {});
      }
    } catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  void _onPostRefresh() async {
    if (await checkConnection(context)) {
      yarnCommentScreenKey = GlobalKey<ScaffoldState>();
      setState(() {
        _postRefreshController.refreshCompleted();
      });
    } else {
      setState(() {
        _postRefreshController.refreshCompleted();
      });
    }
  }
}
