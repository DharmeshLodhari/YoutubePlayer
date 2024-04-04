import 'package:Slydo/screens/moments/screens/moments_service.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../data/state_notifier.dart';
import '../../../more_apps/messaging/chat/models/gif_model/GIFModel.dart';
import '../../../more_apps/shopping/models/store.dart';
import '../../../more_apps/yarn/models/Topics/CommentDetails.dart';
import '../../../more_apps/yarn/models/Topics/yarn_model.dart';
import '../../../more_apps/yarn/models/share_as_yarn_model.dart';
import '../../../more_apps/yarn/yarn_dashboard_bloc.dart';
import '../../models/moments_model.dart';
import '../../tiles/moment_comment_tile.dart';
import '../../widgets/moment_comment_textfield.dart';

//comment for moment, 3/4 of the screen
class CommentListWidget extends StatefulWidget {
  final int
      index; // This is the index of the moment in the (horizontal) moment list.
  final String momentID;
  final String username;
  final MomentsModel? moment;
  final Function(bool, int)? callbackUpdateCommentCount;

  const CommentListWidget(
      {Key? key,
      required this.index,
      required this.momentID,
      required this.username,
      this.callbackUpdateCommentCount,
      this.moment})
      : super(key: key);

  @override
  _CommentListWidgetState createState() => _CommentListWidgetState();
}

class _CommentListWidgetState extends State<CommentListWidget> {
  String? nextUrl;
  bool addingComment = false;
  List<YarnComment> yarnComments = [];

  bool isCommentsLoading = false;

  String? videoPath;
  String? imagePath;
  bool isUrlPresent = false;
  String? linkToBePreview;
  bool isMediaPresent = false;
  bool isAttachmentPresent = false;

  late UserBloc userBloc;

  final TextEditingController controller = TextEditingController();

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
  int count = 0;
  bool noList = false;
  GIFModel? selectedGif;

  @override
  void initState() {
    super.initState();
    getListOfComments();

    scrollController.addListener(() {
      setState(() => isScrolling = true);
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  Future<void> getListOfComments() async {
    if (mounted) {
      setState(() {
        isCommentsLoading = true;
      });
    }

    final Map<String, dynamic>? result =
        await MomentsService().getMomentComments(nextUrl, widget.momentID);

    if (result == null) {
      noList = true;

      isCommentsLoading = false;
      if (mounted) {
        setState(() {});
      }
      return;
    }

    count = result['count'] ?? 0;
    nextUrl = result['next'] ?? "";
    final tempList = result['results'];
    yarnComments = [];
    if (mounted) {
      setState(() {
        noList = false;
        isCommentsLoading = false;
        yarnComments.addAll(tempList);
      });
    }

    if (yarnComments.isEmpty) {
      if (mounted) {
        setState(() {
          noList = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    yarnDashboardBloc = Provider.of<YarnDashboardBloc>(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        _buildCommentDetailView(),
        _buildTopicTextField(),
        const SizedBox(
          height: 10,
        )
      ],
    );
  }

  Widget _buildCommentDetailView() {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          isCommentsLoading
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      const Text(
                        "Comments",
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        '$count',
                        style: const TextStyle(
                          color: Color(0xff75818F),
                        ),
                      ),
                    ],
                  ),
                ),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              controller: scrollController,
              itemCount: yarnComments.length + 1,
              itemBuilder: (context, index) {
                if (index == yarnComments.length) {
                  return buildLoadingIndicator(isLoading: isCommentsLoading);
                } else {
                  return singleCommentWidget(yarnComments[index], index);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget singleCommentWidget(YarnComment yarnComment, index) {
    return SingleChildScrollView(
        child: _buildCommentDescriptionMain(yarnComment));
  }

  Widget _buildCommentDescriptionMain(YarnComment yarnComment) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: MomentCommentTile(
            yarnComment: yarnComment,
            momentUsername: widget.moment?.ownerName,
            moment: widget.moment,
            openReply: false,
            isCommentDetail: true,
            minusComment: (bool value) {
              if (value == false) {
                //if false add 1 to comment count, comment added to reply
                for (var user in yarnComments) {
                  if (user.id == yarnComment.id) {
                    user.replyCount = user.replyCount! + 1; // Modify the count
                    // // update comment count by add +1
                    // widget.callbackUpdateCommentCount!(true);
                    if (mounted) setState(() {});
                  }
                }
              } else if (value == true) {
                //if true subtract 1 to comment count, comment deleted from reply
                for (var user in yarnComments) {
                  if (user.id == yarnComment.id) {
                    user.replyCount = user.replyCount! != 0
                        ? user.replyCount! - 1
                        : 0; // Modify the count
                    if (mounted) setState(() {});
                  }
                }
              }
            },
            onDeleteComment: (YarnComment yarnCmt) {
              //delete the comment from the list and reduce comment count at the top
              yarnComments.removeWhere((comment) => comment.id == yarnCmt.id);

              yarnComment.replyCount != 0 ? yarnComment.replyCount! - 1 : 0;

              // update comment count by subtracting -1
              widget.callbackUpdateCommentCount!(
                  false, yarnComment.replyCount!.toInt());
              if (mounted) setState(() {});
            },
            onCommentUpdate: (YarnComment yarnCmt, bool val) {
              //this will update the list of comments and set the selected comment to pinned
              final modelIndex =
                  yarnComments.indexWhere((model) => model.id == yarnCmt.id);
              if (modelIndex != -1) {
                final model = yarnComments.removeAt(modelIndex);
                model.pinned = val;
                yarnComments.insert(0, model);

                Navigator.pop(context);
                if (mounted) setState(() {});
              }
            },
            callbackUpdateCommentCount: (value) {
              if (value == true) {
                //increase the count by for the single moment detail + 1
                widget.callbackUpdateCommentCount!(true, 1);
              }
            },
          ),
        ),
        const SizedBox(
          height: 12,
        ),
        Divider(
          height: 0,
          thickness: 0.5,
          color: greySecondaryYarn,
        ),
      ],
    );
  }

  Widget _buildTopicTextField() {
    return MomentCommentTextField(
      key: momentCommentTextFieldStateKey,
      height: 50,
      controller: controller,
      scrollController: scrollController,
      hint: "Add a public comment...",
      userImage: userBloc.user.avatar,
      userName: widget.username,
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
      addedSelectedGif: (value) {
        //retrieve the selected gif
        selectedGif = value;
        debugPrint('Fola gif:::: ${selectedGif!.images!.original!.url}');

        //mimic image selected for the gif and send as comment
        final String? mediaType = 'gif';

        // selectedMedia.add(YarnMedia(mediaFile: File(selectedGif!.images!.original!.url!), mediaType: mediaType));
        // isAPILoading = true;
        if (mounted) setState(() {});

        // addComment();
      },
      onPressed: () async {
        if (controller.text.isNotEmpty) {
          FocusScope.of(context).unfocus();
          isAPILoading = true;
          if (mounted) setState(() {});

          addComment();
        } else {
          showToast(message: 'Enter a valid comment');
        }
      },
      onTapAgeRestriction: (value) {},
    );
  }

  Future addComment() async {
    final Map<String, dynamic> data = {
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
      final YarnComment? yarnComment =
          await MomentsService().addCommentToMoment(widget.momentID, data);
      if (yarnComment != null) {
        //increase count for comment
        count = count + 1;

        isAPILoading = false;
        if (mounted) setState(() {});

        //clear all data used to add comment
        yarnDashboardBloc!.productService = null;
        controller.clear();
        selectedMedia.clear();
        momentCommentTextFieldStateKey.currentState?.onAPICall();

        //update the comment list
        yarnComments.add(yarnComment);
        // update comment count by adding +1
        widget.callbackUpdateCommentCount!(true, 1);

        if (mounted) setState(() {});
      }
    } catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }
}
