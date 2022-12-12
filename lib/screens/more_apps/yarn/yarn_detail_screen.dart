import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/yarn/models/Topics/CommentDetails.dart';
import 'package:Slydo/screens/more_apps/yarn/models/Topics/YarnTopic.dart';
import 'package:Slydo/screens/more_apps/yarn/tiles/yarn_list_tile.dart';
import 'package:Slydo/screens/more_apps/yarn/widgets/yarn_comment_textfield.dart';
import 'package:Slydo/screens/more_apps/yarn/widgets/yarn_shimmer.dart';
import 'package:Slydo/screens/more_apps/yarn/yarn_auth.dart';
import 'package:Slydo/screens/more_apps/yarn/yarn_comment_list.dart';
import 'package:Slydo/utils/util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

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
  GlobalKey<ScaffoldState> yarnCommentScreenKey = GlobalKey<ScaffoldState>();
  bool? enableComment = false, enablePayment = false;

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
          waterDropColor: navyBlue,
        ),
        controller: _postRefreshController,
        onRefresh: _onPostRefresh,
        child: SingleChildScrollView(
          controller: _commentScrollController,
          child: !isLoading ? _buildMain() : YarnShimmer(),
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

  Widget _buildTopicTextFiled() {
    return YarnCommentTextField(
      height: 50,
      controller: controller,
      hint: "Leave your thought",
      yarn: widget.yarn,
      userImage: userBloc.user.avatar,
      isLoading: isAPILoading,
      enableComment: enableComment,
      onTapEnableComment: (value) {
        enableComment = value;
        if (mounted) setState(() {});
      },
      enablePayment: enablePayment,
      onTapEnablePayment: (value) {
        enablePayment = value;
        if (mounted) setState(() {});
      },
      onPressed: () async {
        FocusScope.of(context).unfocus();
        isAPILoading = true;
        if (mounted) setState(() {});
        await addComment();
        isAPILoading = false;
        if (mounted) setState(() {});
      },
    );
  }

  Future addComment() async {
    Map<String, dynamic> data = {
      "comment": controller.text,
      "author_username": userBloc.user.userName
    };
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
