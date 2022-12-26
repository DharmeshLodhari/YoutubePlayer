import 'package:Slydo/screens/moments/models/comment_model.dart';
import 'package:Slydo/screens/moments/moments_bloc.dart';
import 'package:Slydo/screens/moments/screens/moments_service.dart';
import 'package:Slydo/screens/moments/utils.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CommentListWidget extends StatefulWidget {
  final int
      index; // This is the index of the moment in the (horizontal) moment list.
  final String momentID;
  const CommentListWidget(
      {Key? key, required this.index, required this.momentID})
      : super(key: key);

  @override
  _CommentListWidgetState createState() => _CommentListWidgetState();
}

class _CommentListWidgetState extends State<CommentListWidget> {
  String? nextUrl;
  bool addingComment = false;
  BasePaginationModel<List<CommentModel>>? basePaginationModel;
  List<CommentModel> comments = [];
  List<CommentModel> tempComments = [];

  bool isCommentsLoading = false;
  TextEditingController commentCtrl = TextEditingController();
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    getListOfComments();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          _scrollController.position.pixels != 0) {
        getListOfComments();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  getListOfComments() {
    if (mounted) {
      setState(() {
        isCommentsLoading = true;
      });
    }

    MomentsService()
        .getMomentComments(nextUrl: nextUrl, momentID: widget.momentID)
        .then((value) {
      tempComments.addAll(value.result);

      tempComments.forEach((element) {
        if (!(comments.contains(element))) {
          comments.add(element);
        }
      });

      basePaginationModel = value;
      nextUrl = basePaginationModel!.next;
      print("INDEX:- ${widget.index}");
      Provider.of<MomentsBloc>(context, listen: false)
          .numberOfComments[widget.index] = basePaginationModel!.count;

      Provider.of<MomentsBloc>(context, listen: false).numberOfComments =
          Provider.of<MomentsBloc>(context, listen: false).numberOfComments;

      if (mounted) {
        setState(() {
          isCommentsLoading = false;
        });
      }
    }).catchError((e) {
      basePaginationModel = BasePaginationModel(
        count: 0,
        next: '',
        result: [],
        previous: '',
      );
      if (mounted) {
        setState(() {
          isCommentsLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      bottomSheet: isCommentsLoading
          ? SizedBox.shrink()
          : Container(
              height: 100,
              color: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: CustomizedTextFormField(
                        controller: commentCtrl,
                        hintText: 'Comment...',
                        maxLength: 250,
                      ),
                    ),
                    SizedBox(width: 5),
                    InkWell(
                      onTap: addingComment
                          ? null
                          : () {
                              setState(() => addingComment = true);
                              MomentsService().addCommentToMoment(
                                  momentID: widget.momentID,
                                  data: {
                                    'comment': commentCtrl.text,
                                    'author_username':
                                        getLoggedInUserName(context),
                                  }).then((value) {
                                commentCtrl.clear();
                                comments.clear();
                                nextUrl = null;
                                getListOfComments();
                                setState(() => addingComment = false);
                              }).catchError((e) {
                                showToast(message: 'Something went wrong');
                              });
                            },
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Icon(
                          SlydoAppIcon.send_message_2,
                          color: addingComment ? greyBorderColor : navyBlue,
                          size: 26,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          isCommentsLoading
              ? SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Text(
                        "Comments",
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        '${basePaginationModel!.count}',
                        style: TextStyle(
                          color: Color(0xff75818F),
                        ),
                      ),
                    ],
                  ),
                ),
          Expanded(
            flex: 6,
            child: ListView.builder(
              shrinkWrap: true,
              controller: _scrollController,
              itemCount: comments.length + 1,
              itemBuilder: (context, index) {
                if (index == comments.length) {
                  return buildLoadingIndicator(isLoading: isCommentsLoading);
                } else {
                  return singleCommentWidget(comments[index]);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget singleCommentWidget(CommentModel commentModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Divider(
          color: Color(0xffEBEDFC),
          thickness: 1,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              getCircularUserAvatar(commentModel.authorAvatar!),
              SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          truncateString(
                              lengthToTruncateAt: 13,
                              str: messageDecoderWithEmoji(
                                  commentModel.authorUsername!)!,
                              showEllipsis: false),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(' • '),
                        Text(
                            MomentsUtils(). getGetMomentDetailDateTime(commentModel.createdAt!),
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      messageDecoderWithEmoji(commentModel.comment!)!,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void showCommentTextFieldBottomSheet() {
    showBottomSheet(
        context: context,
        constraints: BoxConstraints.loose(Size(
            MediaQuery.of(context).size.width,
            MediaQuery.of(context).size.height * 0.45)),
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.only(right: 16.0, left: 16.0, bottom: 10),
            child: Container(
              color: Colors.red,
              child: Row(
                children: [
                  Expanded(
                    child: CustomizedTextFormField(
                      autoFocus: true,
                      hintText: 'Comment...',
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      // MomentsService().addCommentToMoment(
                      //     momentID: widget.momentID,
                      //     data: {
                      //       'comment': commentCtrl.text,
                      //       'author_username': getUserName(context),
                      //     }).then((value) {
                      //   commentCtrl.clear();
                      //
                      //   getListOfComments();
                      // }).catchError((e) {
                      //   showToast(message: 'Something went wrong');
                      // });
                    },
                    child: Icon(
                      SlydoAppIcon.send_message_2,
                      color: navyBlue,
                      size: 26,
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
