import 'package:Slydo/screens/moments/widgets/moment_comment_textfield.dart';
import 'package:Slydo/utils/util.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../../../data/state_notifier.dart';
import '../../../../locale/app_localization.dart';
import '../../../more_apps/messaging/chat/models/gif_model/GIFModel.dart';
import '../../../more_apps/shopping/models/store.dart';
import '../../../more_apps/yarn/models/Topics/CommentDetails.dart';
import '../../../more_apps/yarn/models/Topics/yarn_model.dart';
import '../../../more_apps/yarn/models/share_as_yarn_model.dart';
import '../../../more_apps/yarn/widgets/yarn_shimmer.dart';
import '../../../more_apps/yarn/yarn_dashboard_bloc.dart';
import '../../models/moments_model.dart';
import '../../tiles/moment_comment_tile.dart';
import '../moments_service.dart';

// ignore: must_be_immutable
//reply to comment for moment, full screen
class MomentCommentScreen extends StatefulWidget {
  MomentCommentScreen(
      {Key? key, this.yarnComment, this.momentId,
        this.addedSelectedMedia, this.minusComment, this.onDeleteComment})
      : super(key: key);
  YarnComment? yarnComment;
  String? momentId;
  Function(List<MomentMedia>)? addedSelectedMedia;
  Function(bool)? minusComment;
  final Function(YarnComment)? onDeleteComment;


  @override
  State<MomentCommentScreen> createState() => _MomentCommentScreenState();
}

class _MomentCommentScreenState extends State<MomentCommentScreen> {
  String next = "", previous = "";
  int count = 0;
  bool isLoading = false;
  bool noList = false;

  List<YarnComment> yarnComments = [];

  String? videoPath;
  String? imagePath;
  bool isUrlPresent = false;
  String? linkToBePreview;
  bool isMediaPresent = false;
  bool isAttachmentPresent = false;

  late UserBloc userBloc;

  final TextEditingController controller = TextEditingController();
  final RefreshController _postRefreshController =
      RefreshController(initialRefresh: false);
  bool isAPILoading = false;
  GlobalKey<ScaffoldState> yarnCommentScreenKey = GlobalKey<ScaffoldState>();
  GlobalKey<MomentCommentTextFieldState> momentCommentTextFieldStateKey =
      GlobalKey<MomentCommentTextFieldState>();
  bool? enableComment = false, enablePayment = false;
  bool? enableAdult = false, viewerAdvice = false;
  var ageRating;

  ScrollController scrollController = ScrollController();
  List<YarnMedia> selectedMedia = [];
  bool isScrolling = false;
  Product? productValue;
  Service? serviceValue;
  YarnDashboardBloc? yarnDashboardBloc;
  String? userName;
  GIFModel? selectedGif;

  @override
  void initState() {
    scrollController.addListener(() {
      setState(() => isScrolling = true);
    });

    getAllComments();

    super.initState();
  }

  Widget commentListWidget(
      {avatar, username, comment, createAt, YarnComment? yarnComment}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCommentDescription(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // this is the main comment at the top of the comment detail screen
  Widget _buildCommentDescriptionMain() {

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: MomentCommentTile(
            yarnComment: widget.yarnComment!,
            momentId: widget.momentId,
            openReply: false,
            isCommentDetail: false,
            minusComment: (bool value){
              if(value == false){
                //if false add 1 to comment count
                widget.yarnComment!.replyCount! + 1;
                if(mounted)setState(() {});
              }else if(value == true){
                //if true subtract 1 to comment count
                widget.yarnComment!.replyCount != 0 ? widget.yarnComment!.replyCount! - 1 : 0;
                if(mounted)setState(() {});
              }
            },
            onDeleteComment: (YarnComment yarnCmt) {

              // widget.onDeleteComment!(yarnCmt);
              // Navigator.pop(context);
              // Navigator.pop(context);
              // if(mounted)setState(() {});
            },

          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Divider(
          height: 0,
          thickness: 0.5,
          color: greySecondaryYarn,
        ),
      ],
    );
  }

  //this is the list of replies in the comment detail screen
  Widget _buildCommentDescription() {
    return Column(
      children: [
        Column(
          children: yarnComments
              .map((yarnComment) => Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: MomentCommentTile(
                          yarnComment: yarnComment,
                          openReply: false,
                          isCommentDetail: false,
                          onDeleteComment: (YarnComment yarnCmt) {
                            //delete the comment from the list and reduce comment count at the top
                            yarnComments.removeWhere((comment) => comment.id == yarnCmt.id);

                            //this reduces the count on the 3/4 comment screen and the page is updated silently
                            widget.minusComment!(true);
                            if (mounted) setState(() {});
                          },
                          minusComment: (bool value){
                            if(value == false){
                              //if false add 1 to comment count
                              yarnComment.replyCount! + 1;
                              widget.minusComment!(false);
                              if(mounted)setState(() {});
                            }
                            else if(value == true){
                              //if true subtract 1 to comment count
                              yarnComment.replyCount != 0 ? yarnComment.replyCount! - 1 : 0;
                              widget.minusComment!(true);
                              if(mounted)setState(() {});
                            }
                          },
                          onCommentUpdate: (YarnComment yarnCmt, bool val) {
                            //this will update the list of comments and set the selected comment to pinned
                            final modelIndex = yarnComments.indexWhere((model) => model.id == yarnCmt.id);
                            if (modelIndex != -1) {
                              final model = yarnComments.removeAt(modelIndex);
                              model.pinned = val;
                              yarnComments.insert(0, model);
                              if (mounted) setState(() {});
                            }

                            // getAllComments();

                          },
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Divider(
                        height: 0,
                        thickness: 0.5,
                        color: greySecondaryYarn,
                      ),
                    ],
                  ))
              .toList(),
        ),
      ],
    );
  }

  void getAllComments() async {
    // if (!isLoading) {
    //   isLoading = true;

    if (!isLoading) {
      if (next != null && !isLoading) {
        isLoading = true;
        if (mounted) setState(() {});

        Map<String, dynamic>? result = await MomentsService().getAllComments(
          widget.yarnComment!.id!,
        );

        if (result == null) {
          noList = true;

          isLoading = false;
          if (mounted) {
            setState(() {});
          }
          return;
        }

        count = result['count'];
        next = result['next'] != null ? result['next'] : "";
        previous = result['previous'] != null ? result['previous'] : "";
        var tempList = result['results'];

        yarnComments = [];
        if (mounted) {
          setState(() {
            noList = false;
            isLoading = false;
            yarnComments.addAll(tempList);
          });
        }
      }
      if (yarnComments.isEmpty) {
        if (mounted) {
          setState(() {
            noList = true;
          });
        }
      }
    }
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
          body: _buildBody()),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      title: Text(
        "Replies ${widget.yarnComment?.replyCount}",
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

  Widget _buildBody() {
    return Column(
      children: [
        _buildCommentDetailView(),
        _buildTopicTextField(),
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
        _buildCommentDescriptionMain(),
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              commentListWidget(),
            ],
          ),
        )
      ],
    );
  }

  Future addReplyComment() async {
    Map<String, dynamic> data = {
      "comment": controller.text,
      "author_username": getLoggedInUserName(context),
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

    //create multipart request for POST or PATCH method
    try {
      YarnComment? yarnComment = await MomentsService()
          .addReplyToComment(widget.yarnComment!.id!, data);
      if (yarnComment != null) {
        //update the comment count from previous page
        widget.yarnComment!.replyCount = widget.yarnComment!.replyCount! + 1;

        //clear all data used to addReplyComment
        yarnDashboardBloc!.productService = null;
        controller.clear();
        selectedMedia.clear();
        momentCommentTextFieldStateKey.currentState?.onAPICall();

        //update this current list
        yarnComments.add(yarnComment);

        if (mounted) setState(() {});
      }
    } catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  Widget _buildTopicTextField() {
    return MomentCommentTextField(
      key: momentCommentTextFieldStateKey,
      height: 50,
      controller: controller,
      scrollController: scrollController,
      hint: "Add a public comment...",
      userImage: userBloc.user.avatar,
      userName: widget.yarnComment!.authorUsername,
      shareAsYarnModel: ShareAsYarnModel.shareAsYarnModel,
      isLoading: isAPILoading,
      enableComment: enableComment,
      isScrolling: isScrolling,
      resetScrollingValue: (p0) {
        setState(() => isScrolling = p0);
      },
      addedSelectedMedia: (value) {
        selectedMedia = value;
        setState(() {});
      },
      addedSelectedGif: (value){
        //retrieve the selected gif
        selectedGif = value;
        debugPrint('Fola gif full view:::: ${selectedGif!.images!.original!.url}');

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
          userName = widget.yarnComment!.authorUsername;
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
