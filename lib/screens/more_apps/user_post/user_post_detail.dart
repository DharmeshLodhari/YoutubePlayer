import 'dart:convert';
import 'dart:developer';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/news/CustomChip.dart';
import 'package:Slydo/screens/more_apps/user_post/models/user_post.dart';
import 'package:Slydo/screens/more_apps/user_post/user_post_auth.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_quill/flutter_quill.dart' as flutterQuill;

class UserPostDetailPage extends StatefulWidget {
  UserPostDetailPage({required this.arguments});

  Map<String, dynamic> arguments;
  @override
  _UserPostDetailPageState createState() => _UserPostDetailPageState();
}

class _UserPostDetailPageState extends State<UserPostDetailPage> {
  bool isLoading = false;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  UserPost? userPost;
  CustomerProfile? postOfUser;
  UserBloc? userBloc;
  bool isAuthor = false;
  dynamic blogBodyTextJson;
  late flutterQuill.QuillController _quillController;

  @override
  void initState() {
    userPost = widget.arguments["post"];
    log("User Post ==> ${userPost?.toJson()}");
    postOfUser = widget.arguments["postOfUser"];

    // Try if blog text is decodable, if it isn't the try blog won't run.
    try {
      blogBodyTextJson = jsonDecode(userPost!.text!);
      _quillController = flutterQuill.QuillController(
          document: flutterQuill.Document.fromJson(blogBodyTextJson),
          selection: TextSelection.collapsed(offset: -1));
    } catch (e) {}

    super.initState();
    getResult();
  }

  void getResult() async {
    isLoading = true;
    if (mounted) {
      setState(() {});
    }

    // newsDetailItem = await NewsAuthService().getNewsDetail();

    isLoading = false;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    if (userBloc!.user.userName == userPost?.authorUsername) {
      isAuthor = true;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: appBar() as PreferredSizeWidget?,
      body: scaffoldBody(),
    );
  }

  Widget appBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      titleSpacing: 0,
      automaticallyImplyLeading: false,
      title: Text(
        "Blog",
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      leading: IconButton(
        icon: Icon(
          Icons.keyboard_arrow_left,
          color: navyBlue,
          size: 24,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      actions: <Widget>[
        shareBtn(),
        SizedBox(
          width: 16,
        ),
      ],
    );
  }

  Widget shareBtn() {
    return RoundedBackgroundIcon(
      height: 34,
      width: 34,
      icon: Icon(
        SlydoAppIcon.share,
        size: 16,
        color: blackFont,
      ),
      onTap: () {},
      backgroundColor: iconBtnGrey,
      enableMargin: true,
    );
  }

  Widget scaffoldBody() {
    return isLoading
        ? Center(
            child: CircularLoadingIndicator(),
          )
        : SingleChildScrollView(
            child: Column(
              children: [
                postImage(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      newsTitle(),
                      SizedBox(
                        height: 20,
                      ),
                      bloggerDetail(),
                      SizedBox(
                        height: 20,
                      ),
                      newsSubTitle(),
                      SizedBox(
                        height: 20,
                      ),
                      newsFullDescription(),
                      SizedBox(
                        height: 20,
                      ),
                      _buildLikeUnLikeReportTile(),
                      SizedBox(
                        height: 20,
                      ),
                      Divider(
                        thickness: 1,
                        color: dividerColor,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      newsChips(),
                      SizedBox(
                        height: 50,
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
  }

  Widget postImage() {
    return Container(
      child: CachedNetworkImage(
        imageUrl: userPost?.authorAvatar ?? "",
        fit: BoxFit.fill,
        width: double.infinity,
        height: 250,
      ),
    );
  }

  Widget newsTitle() {
    return Text(
      messageDecoderWithEmoji(userPost?.title ?? "")!,
      style: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 18,
        color: blackFont,
      ),
    );
  }

  Widget bloggerDetail() {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        height: 32,
        width: 32,
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: userPost?.authorAvatar ?? "",
            errorWidget: imageErrorWidget,
            fit: BoxFit.fill,
          ),
        ),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                "${userPost?.authorUsername ?? ""} • ",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: blackFont,
                ),
              ),
              Text(
                "${(userPost?.createdAt ?? null) != null ? formatDate(userPost!.createdAt!) : ""} ",
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: darkGrey,
                ),
              ),
            ],
          ),
          CustomChip(
            text: "5 min read",
          )
        ],
      ),
    );
  }

  Widget newsSubTitle() {
    return Text(
      messageDecoderWithEmoji(userPost?.tagLine ?? "")!,
      style: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 16,
        color: blackFont,
      ),
      textAlign: TextAlign.justify,
    );
  }

  Widget newsFullDescription() {
    return blogBodyTextJson != null
        ? flutterQuill.QuillEditor.basic(
            controller: _quillController,
            readOnly: true,
          )
        : Text(
            messageDecoderWithEmoji(userPost?.text) ?? "",
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: blackFont,
            ),
            textAlign: TextAlign.justify,
          );
  }

  Widget newsChips() {
    return Wrap(
        spacing: 8, runSpacing: 8, children: [CustomChip(text: "Post")]);
  }

  String formatDate(DateTime dateTime) {
    DateFormat dateFormat = DateFormat("MMM dd");
    return dateFormat.format(dateTime);
  }

  Widget _buildLikeUnLikeReportTile() {
    return Row(
      children: [
        _buildReviewLike(),
        SizedBox(
          width: 16,
        ),
        _buildPostUnLike(),
      ],
    );
  }

  Widget _buildReviewLike() {
    return GestureDetector(
      onTap: isAuthor ? null : likeUnlikePost,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.black12,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.thumb_up_alt_outlined,
              size: 16,
            ),
            SizedBox(
              width: 4,
            ),
            Text(
              userPost?.likes.toString() ?? "",
              style: TextStyle(
                color: blackFont,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void likeUnlikePost() async {
    await UserPostAuth().likeUserPost(userPost!).then((value) {
      userPost = value;
      if (mounted) setState(() {});
    }).catchError((error) {
      debugPrint("Error:- $error");
      showToast(message: "$error");
    });
    // await UserReviewAuth()
    //     .unlikeUserReview(widget.review!)
    //     .then((value) {})
    //     .catchError((error) {
    //   debugPrint("Error:- $error");
    //   showToast(message: "$error");
    // });
  }

  void dislikeUnlikePost() async {
    await UserPostAuth().dislikeUserPost(userPost!).then((value) {
      userPost = value;
      if (mounted) setState(() {});
    }).catchError((error) {
      debugPrint("Error:- $error");
      showToast(message: "$error");
    });
    // await UserReviewAuth()
    //     .unlikeUserReview(widget.review!)
    //     .then((value) {})
    //     .catchError((error) {
    //   debugPrint("Error:- $error");
    //   showToast(message: "$error");
    // });
  }

  Widget _buildPostUnLike() {
    return GestureDetector(
      onTap: isAuthor ? null : dislikeUnlikePost,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.black12,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.thumb_down_alt_outlined,
              size: 16,
            ),
            SizedBox(
              width: 4,
            ),
            Text(
              userPost?.dislikes.toString() ?? "",
              style: TextStyle(
                color: blackFont,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
