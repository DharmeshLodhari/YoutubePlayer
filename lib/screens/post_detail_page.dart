import 'dart:convert';

import 'package:Slydo/screens/blog/quill/custom_quill_embed.dart';
import 'package:Slydo/screens/more_apps/news/news_auth.dart';
import 'package:Slydo/screens/more_apps/user_post/user_post_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart' as flutterQuill;
// import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';

import '../data/state_notifier.dart';
import '../locale/app_localization.dart';
import '../routes/route_constants.dart';
import '../utils/enums.dart';
import '../utils/navigation_util.dart';
import '../utils/slydo_app_icon_icons.dart';
import '../utils/slydo_app_icon_new_icons.dart';
import '../utils/util.dart';
import '../utils/video_player_controller/chewie_player.dart';
import '../utils/video_player_controller/chewie_progress_colors.dart';
import '../widget/bottom_sheet_item.dart';
import '../widget/dialog.dart';
import '../widget/loading_indicator.dart';
import '../widget/rounded_background_icon.dart';
import 'more_apps/messaging/chat/models/ChatConversation.dart';
import 'more_apps/messaging/chat/share_in_chat/ShareInChat.dart';
import 'more_apps/news/CustomChip.dart';
import 'more_apps/news/models/NewsDetailItem.dart';
import 'more_apps/news/models/NewsListItem.dart';
import 'more_apps/news/news_tile.dart';
import 'more_apps/user_post/models/user_post.dart';
import 'more_apps/user_post/tile/user_post_tile.dart';
import 'more_apps/user_post/user_post_auth.dart';
import 'more_apps/user_profile/models/user.dart';
import 'more_apps/yarn/models/share_as_yarn_model.dart';
import 'more_apps/yarn/share_as_a_yarn_screen.dart';
import 'more_apps/yarn/yarn_auth.dart';
import 'more_apps/yarn/yarn_dashboard_bloc.dart';

class PostDetailPage extends StatefulWidget {
  final String? postId;
  final PostType postType;
  final Function? onDeleteBlog;

  const PostDetailPage({
    Key? key,
    this.onDeleteBlog,
    required this.postId,
    required this.postType,
  }) : super(key: key);

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  // UserPost? userPost;
  late UserBloc userBloc;
  bool isLoading = false;

  bool isVideoPlaying = false;

  NewsDetailItem newsDetailItem = NewsDetailItem();
  VideoPlayerController? _mainVideoController;

  ChewieController? _chewieMainController;

  dynamic blogBodyTextJson;
  late flutterQuill.QuillController _quillController;

  UserPost? userPost;
  late Future<UserPost?> getPostFuture;
  late YarnDashboardBloc yarnDashboardBloc;

  @override
  void initState() {
    super.initState();
    debugPrint('POST ID ---> ${widget.postId}');
    getPostFuture = UserPostAuth().getSinglePost(postID: widget.postId!);
    Future.delayed(Duration(seconds: 3), () {
      UserPostAuth().updateBlogView(postId: widget.postId!);
    });
  }

  getBlogDetailsAndInitializeVideoController({required UserPost userPost}) {
    if (userPost.video != null && userPost.video!.isNotEmpty) {
      _mainVideoController = VideoPlayerController.network(userPost.video!);

      _chewieMainController = ChewieController(
        videoPlayerController: _mainVideoController!,
        aspectRatio: 16 / 9,
        allowedScreenSleep: false,
        allowFullScreen: true,
        deviceOrientationsAfterFullScreen: [
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ],
        systemOverlaysAfterFullScreen: SystemUiOverlay.values,
        materialProgressColors: ChewieProgressColors(
          playedColor: navyBlue,
          handleColor: Colors.white,
          backgroundColor: dividerColor,
          bufferedColor: Colors.white30,
        ),
        autoInitialize: true,
      );
    }

    // Try if blog text is decodable, if it isn't the try blog won't run.

    try {
      blogBodyTextJson = jsonDecode(messageDecoderWithEmoji(userPost.text!)!);

      // debugPrint('USER POST :: ${userPost.text}');
      // debugPrint('USER POST 0000 :: ${blogBodyTextJson}');
      // debugPrint('USER POST :: ${userPost.text.runtimeType}');

      // Extract the word after "insert"
      // RegExp regex = RegExp(r'"insert":"([^"]+)"');
      // Match? match = regex.firstMatch(userPost.text!);
      // String? wordAfterInsert = match?.group(1);

      // // Recreate the string by replacing the string after "insert"
      // String reformattedWord = messageDecoderWithEmoji(wordAfterInsert)!;
      // String recreatedString =
      //     userPost.text!.replaceAll(regex, '"insert": $reformattedWord');

      // debugPrint('USER POST 111:: ${recreatedString}');

      // blogBodyTextJson = jsonDecode(reformattedWord);

      _quillController = flutterQuill.QuillController(
        document: flutterQuill.Document.fromJson(blogBodyTextJson),
        selection: TextSelection.collapsed(offset: -1),
      );
    } catch (e) {
      print('CANNOT DECODE BLOG TEXT: ${e.toString()}');
    }
  }

  Future getNewsResultAndInitializeVideoController() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    newsDetailItem = await NewsAuthService().getNewsDetail();

    if (newsDetailItem.video != null && newsDetailItem.video!.isNotEmpty) {
      _mainVideoController =
          VideoPlayerController.network(newsDetailItem.video!);
      _chewieMainController = ChewieController(
        videoPlayerController: _mainVideoController!,
        aspectRatio: 16 / 9,
        allowedScreenSleep: false,
        allowFullScreen: true,
        deviceOrientationsAfterFullScreen: [
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ],
        systemOverlaysAfterFullScreen: SystemUiOverlay.values,
        materialProgressColors: ChewieProgressColors(
          playedColor: navyBlue,
          handleColor: Colors.white,
          backgroundColor: dividerColor,
          bufferedColor: Colors.white30,
        ),
        autoInitialize: true,
      );
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _mainVideoController?.dispose();

    _chewieMainController?.dispose();

    SystemChrome.setPreferredOrientations(
      [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ],
    );

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }

  reloadPage() {
    setState(() {
      getPostFuture = UserPostAuth().getSinglePost(postID: widget.postId!);
    });
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    yarnDashboardBloc = Provider.of<YarnDashboardBloc>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: appBar(),
      body: scaffoldBody(),
    );
  }

  Widget scaffoldBody() {
    // debugPrint('USER POST :: ${userPost!.image}');
    return FutureBuilder(
      future: getPostFuture,
      builder: (context, AsyncSnapshot<UserPost?> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            userPost = snapshot.data!;
            if (widget.postType == PostType.blog) {
              debugPrint('TEXT -> ${userPost!.text!}');
              debugPrint('TEXT ID -> ${userPost!.id!}');

              getBlogDetailsAndInitializeVideoController(userPost: userPost!);
            }

            return PostDetailPageScaffoldBody(
              userPost: userPost!,
              views: userPost?.views,
              postID: widget.postType == PostType.blog ? userPost!.id! : '',
              postType: widget.postType,
              authorUsername: userPost!.authorUsername,
              tags: widget.postType == PostType.blog
                  ? userPost!.tags == null
                      ? []
                      : List<String>.from(userPost!.tags!)
                  : newsDetailItem.tags!,
              subTitle: widget.postType == PostType.blog
                  ? userPost!.tagLine == null
                      ? ''
                      : messageDecoderWithEmoji(userPost!.tagLine)!
                  : newsDetailItem.subHeader!,
              readTime: widget.postType == PostType.blog
                  ? userPost!.readTime == null
                      ? 0
                      : userPost!.readTime!
                  : newsDetailItem.readTime == null
                      ? 1
                      : newsDetailItem.readTime!,
              isLoading: isLoading,
              postTitle: widget.postType == PostType.blog
                  ? userPost!.title == null
                      ? ''
                      : userPost!.title!
                  : newsDetailItem.title!,
              createdAt: widget.postType == PostType.blog
                  ? userPost!.createdAt == null
                      ? ''
                      : formatDate(userPost!.createdAt!)
                  : newsDetailItem.uploadTime!,
              authorName: widget.postType == PostType.blog
                  ? userPost!.authorName == null
                      ? ''
                      : userPost!.authorName!
                  : newsDetailItem.author!,
              postImageUrl: widget.postType == PostType.blog
                  ? userPost!.image == null
                      ? ''
                      : userPost!.image!
                  : newsDetailItem.image,
              posterImageUrl: widget.postType == PostType.blog
                  ? userPost!.authorAvatar == null
                      ? ''
                      : userPost!.authorAvatar!
                  : newsDetailItem.poster!,
              shortDescription: widget.postType == PostType.blog
                  ? userPost!.tagLine == null
                      ? ''
                      : messageDecoderWithEmoji(userPost!.tagLine)!
                  : newsDetailItem.shortDescription!,
              postFullDescription: getPostFullText(),
              chewieMainController: _chewieMainController,
              newsListRelatedPostItems: newsDetailItem.newsListItems,
            );
          } else {
            Navigator.pop(context);
            showToast(message: 'Blog post no longer exist');
            return Container(color: Colors.white);
          }
        } else {
          return Center(child: CircularLoadingIndicator());
        }
      },
    );
  }

  Widget getPostFullText() {
    if (widget.postType == PostType.blog) {
      if (blogBodyTextJson != null) {
        return flutterQuill.QuillEditor.basic(
          controller: _quillController,
          embedBuilders: CustomQuillEmbed.builders(),
          readOnly: true,
        );
      } else {
        return Text(
          messageDecoderWithEmoji(userPost?.text) ?? "",
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 14,
            color: blackFont,
          ),
          textAlign: TextAlign.justify,
        );
      }
    } else {
      return Text(
        messageDecoderWithEmoji(newsDetailItem.description!) ?? "",
        // newsDetailItem.description!,
        style: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 14,
          color: blackFont,
        ),
        textAlign: TextAlign.justify,
      );
    }
  }

  AppBar appBar() {
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
          Navigator.pop(context);
        },
      ),
      title: widget.postType == PostType.blog
          ? Text(
              "Blog",
              style: TextStyle(
                  color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
            )
          : SizedBox.shrink(),
      actions: <Widget>[
        widget.postType == PostType.blog ? menuIcon() : shareBtn(),
        SizedBox(
          width: 16,
        ),
      ],
    );
  }

  Widget menuIcon() {
    return RoundedBackgroundIcon(
      height: 34,
      width: 34,
      icon: Icon(
        SlydoAppIcon.menu,
        size: 16,
        color: blackFont,
      ),
      backgroundColor: iconBtnGrey,
      onTap: () {
        userProfileActionsSheet();
      },
      enableMargin: true,
    );
  }

  void userProfileActionsSheet() {
    showModalBottomSheet<void>(
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
                  children: generateBottomSheetItem(),
                ),
              ));
        });
  }

  List<Widget> generateBottomSheetItem() {
    List<Widget> list = [];

    if (userPost != null) {
      list.add(
        bottomSheetItem(
          title: AppLocalization.of(context)!.share,
          iconData: SlydoAppIcon.share,
          onTap: () {
            Navigator.pop(context);
            var shareBody =
                "https://slydo.co/store/${userPost!.authorUsername}/blogs/${userPost!.id}";
            Share.share(shareBody, subject: "${userPost!.authorName}");
          },
        ),
      );
    }

    if (userPost != null) {
      list.add(
        bottomSheetItem(
          title: "Share in Chat",
          iconData: SlydoAppIcon.text_message,
          onTap: () async {
            Navigator.pop(context);
            sendPostToUserInChat();
          },
        ),
      );
    }

    if (userPost != null &&
        userBloc.user.userName == userPost!.authorUsername!) {
      list.add(
        bottomSheetItem(
          title: AppLocalization.of(context)!.editPost,
          iconData: SlydoAppIcon.edit,
          onTap: () async {
            Navigator.pop(context);
            final isBlogUpdated = await Navigator.pushNamed(
                context, Routes.CREATE_BLOG,
                arguments: userPost);
            if (isBlogUpdated == true) {
              reloadPage();
            }
          },
        ),
      );
    }

    if (userPost != null &&
        userBloc.user.userName == userPost!.authorUsername!) {
      list.add(
        bottomSheetItem(
          title: AppLocalization.of(context)!.deletePost,
          iconData: SlydoAppIcon.delete,
          onTap: () {
            Navigator.pop(context);
            showDialogBox(
              context: context,
              actionOneTextColor: blackFont,
              actionOneBgColor: greyBorderColor,
              actionTwoTextColor: white,
              actionTwoBgColor: mateRed,
              title: 'Delete Blog Post',
              actionOneText: AppLocalization.of(context)!.discard,
              actionTwoText: AppLocalization.of(context)!.continueMsg,
              description: 'Are you sure you want to delete this blog post?',
              roundedBackgroundIcon: RoundedBackgroundIcon(
                enableMargin: false,
                width: 90,
                height: 90,
                image: Image.asset('assets/images/delete_dialog_icon.png'),
              ),
              rightButtonOnPressed: () {
                UserPostUtils.deleteBlogPost(
                    onDeleteBlog: () {
                      Navigator.pop(context);
                      widget.onDeleteBlog!();
                    },
                    blogId: userPost!.id!,
                    context: context);
              },
            );
          },
        ),
      );
    }

    list.add(
      bottomSheetItem(
        isLast: true,
        title: "Share As A Yarn",
        iconData: SlydoAppIconNew.dashboard_yarn,
        onTap: () async {
          Navigator.pop(context);
          shareAsYarn();
        },
      ),
    );

    return list;
  }

  Future shareAsYarn() async {
    NavigationUtil.push(context,
        screen: ShareAsAyarnScreen(
            askCategories: yarnDashboardBloc.yarnCategories,
            shareAsYarnModel: ShareAsYarnModel.shareAsYarnModel,
            blogPost: userPost,
            callback: (yarn) async {
              yarn
                ..attachment = {
                  "blog": userPost?.toJson().cast<String, dynamic>() ?? {}
                };
              bool data = await YarnAuth().addYarnAndQuestion(yarn, '', '');
              if (data) {
                showToast(message: "Shared in Yarn successfully");
              }
            }));
  }

  sendPostToUserInChat() async {
    List<ChatConversation?> listOfRecipient =
        await ShareInChat().selectShareCustomer(context);
    debugPrint("Selected users = ${listOfRecipient.length}");

    listOfRecipient.forEach((recipient) {
      addUserPostToChat(recipientUser: recipient!);
    });
  }

  addUserPostToChat({
    required ChatConversation recipientUser,
    String? url,
  }) async {
    Map<String, dynamic> data = {
      "meta_data": jsonEncode({
        "id": userPost!.id,
        "title": userPost!.title,
        "image": userPost!.image,
        "video": userPost!.video,
        "author_avatar": userPost!.authorAvatar,
        "author_username": userPost!.authorUsername,
      }),
      "check_id": Uuid().v4(),
      "conversation_id": recipientUser.conversationId,
      "author": userBloc.user.userName,
      "message": 'blog_post',
      "kind": "blog_post",
      "created_at": DateTime.now().toUtc().toString(),
      "type": "chatroom_message",
    };
    await sendDataToSocket(data);
    showToast(message: 'Post Shared');
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
}

class PostDetailPageScaffoldBody extends StatefulWidget {
  final int? views;
  UserPost userPost;
  final int readTime;
  final String postID;
  final bool isLoading;
  final String subTitle;
  final String postTitle;
  final String createdAt;
  final String authorName;
  final List<String> tags;
  final PostType postType;
  final String? postImageUrl;
  final String posterImageUrl;
  final String? authorUsername;
  final String shortDescription;
  final Widget postFullDescription;
  final ChewieController? chewieMainController;
  final List<NewsListItem>? newsListRelatedPostItems;
  PostDetailPageScaffoldBody({
    Key? key,
    required this.tags,
    required this.views,
    required this.postID,
    required this.userPost,
    required this.postType,
    required this.subTitle,
    required this.readTime,
    required this.isLoading,
    required this.postTitle,
    required this.createdAt,
    required this.authorName,
    required this.postImageUrl,
    required this.authorUsername,
    required this.posterImageUrl,
    this.newsListRelatedPostItems,
    required this.shortDescription,
    required this.postFullDescription,
    required this.chewieMainController,
  }) : super(key: key);

  @override
  State<PostDetailPageScaffoldBody> createState() =>
      _PostDetailPageScaffoldBodyState();
}

class _PostDetailPageScaffoldBodyState
    extends State<PostDetailPageScaffoldBody> {
  late User user;
  bool showTag = false;
  @override
  Widget build(BuildContext context) {
    debugPrint('WIDGET POST --> ${widget.userPost.toJson()}');
    user = Provider.of<UserBloc>(context).user;

    if (widget.tags is List<String>) {
      print('myVariable is of type List<String>');
      for (String item in widget.tags) {
        if (hasAlphabeticCharacters(item)) {
          showTag = true;
          break;
        }
      }
    } else if (widget.tags is List<List<String>>) {
      List<List<String>> myList = widget.tags.cast<List<String>>();
      print('myVariable is of type List<List<String>>');
      for (List<String> innerList in myList) {
        for (String item in innerList) {
          if (hasAlphabeticCharacters(item)) {
            showTag = true;
            break;
          }
        }
      }
    } else {
      print('myVariable is not of the expected types');
    }

    return widget.isLoading
        ? Center(
            child: CircularLoadingIndicator(),
          )
        : SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 6),
                widget.chewieMainController != null
                    ? videoPlayer()
                    : postImage(),
                SizedBox(
                  height: 20,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      newsTitle(),
                      SizedBox(
                        height: 20,
                      ),
                      bloggerDetail(),
                      widget.postType == PostType.blog
                          ? SizedBox.shrink()
                          : newsShortDescription(),
                      SizedBox(height: 20),
                      newsFullDescription(),
                      SizedBox(height: 20),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.visibility_rounded,
                            size: 16,
                            color: blackFont.withOpacity(0.8),
                          ),
                          SizedBox(width: 4),
                          Text(
                            getFormattedViewCount(
                              noOfViews:
                                  widget.views != null ? widget.views! : 1,
                              addViewText: false,
                            ),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: blackFont.withOpacity(0.8),
                            ),
                          ),
                          _buildLikeUnLikeReportTile(),
                          SizedBox(width: 16),
                          _commentWidget(),
                        ],
                      ),
                      SizedBox(height: 20),
                      Divider(
                        thickness: 1,
                        color: dividerColor,
                      ),
                      if (showTag == true) ...[
                        SizedBox(
                          height: 20,
                        ),
                        blogChips(),
                      ],
                      SizedBox(
                        height: 20,
                      ),
                      relatedPost(),
                      SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
  }

  bool hasAlphabeticCharacters(String item) {
    RegExp regex = RegExp(r'[a-zA-Z]');
    return regex.hasMatch(item);
  }

  _commentWidget() {
    if (!widget.userPost.enableCommenting!) {
      return SizedBox.shrink();
    }
    return Row(
      children: [
        Icon(
          Icons.chat,
          size: 16,
          color: blackFont.withOpacity(0.8),
        ),
        SizedBox(width: 4),
        Text(
          getFormattedViewCount(
            noOfViews: widget.views != null ? widget.views! : 1,
            addViewText: false,
          ),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: blackFont.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildLikeUnLikeReportTile() {
    if (!widget.userPost.enableLike!) {
      return SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(width: 16),
        Row(
          children: [
            _buildReviewLike(),
            SizedBox(width: 16),
            _buildPostUnLike(),
          ],
        ),

        // Expanded(child: Container())

        // _buildReviewReport(),
      ],
    );
  }

  Widget _buildReviewLike() {
    return GestureDetector(
      onTap: user.userName == widget.userPost.authorUsername
          ? () => showToast(message: 'You cannot like your post')
          : likeUnlikePost,
      child: Container(
        child: Row(
          children: [
            Icon(
              widget.userPost.userLiked == true
                  ? Icons.thumb_up_alt_rounded
                  : Icons.thumb_up_alt_outlined,
              size: 16,
              color: widget.userPost.userLiked == true ? navyBlue : blackFont,
            ),
            SizedBox(width: 4),
            Text(
              widget.userPost.likes != null
                  ? widget.userPost.likes!.toString()
                  : '0',
              style: TextStyle(
                color: blackFont,
                fontWeight: FontWeight.w400,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostUnLike() {
    return GestureDetector(
      onTap: user.userName == widget.userPost.authorUsername
          ? () => showToast(message: 'You cannot dislike your post')
          : dislikeUnlikePost,
      child: Container(
        child: Row(
          children: [
            Icon(
              widget.userPost.userDisLiked == true
                  ? Icons.thumb_down_alt_rounded
                  : Icons.thumb_down_alt_outlined,
              size: 16,
              color:
                  widget.userPost.userDisLiked! == true ? mateRed : blackFont,
            ),
            SizedBox(width: 4),
            Text(
              widget.userPost.dislikes != null
                  ? widget.userPost.dislikes!.toString()
                  : '0',
              style: TextStyle(
                color: blackFont,
                fontWeight: FontWeight.w400,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void likeUnlikePost() async {
    await UserPostAuth().likeUserPost(widget.userPost).then((value) {
      widget.userPost = value;
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
    await UserPostAuth().dislikeUserPost(widget.userPost).then((value) {
      widget.userPost = value;
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

  Widget postImage() {
    return InkWell(
      onTap: () {
        Navigator.of(context)
            .pushNamed(Routes.PHOTO_VIEWER, arguments: widget.postImageUrl);
      },
      child: Container(
        child: CachedNetworkImage(
          imageUrl: widget.postImageUrl ?? "",
          fit: BoxFit.cover,
          width: double.infinity,
          height: 220,
          errorWidget: imageErrorWidget,
        ),
      ),
    );
  }

  Widget videoPlayer() {
    if (widget.chewieMainController != null) {
      return Chewie(
        titleName: widget.postTitle,
        posterUrl: widget.postImageUrl,
        controller: widget.chewieMainController!,
      );
    } else {
      return SizedBox.shrink();
    }
  }

  Widget newsTitle() {
    return Text(
      messageDecoderWithEmoji(widget.postTitle) ?? "",
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
      leading: InkWell(
        onTap: () {
          Navigator.pushNamed(context, Routes.USER_PROFILE,
              arguments: {"searchedUserName": widget.authorUsername});
        },
        child: SizedBox(
          width: 40,
          height: 40,
          child: userImageUserInitialsPic(
              widget.posterImageUrl, widget.authorName, 20, 40),
        ),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, Routes.USER_PROFILE,
                      arguments: {"searchedUserName": widget.authorUsername});
                },
                child: Row(
                  children: [
                    userNameWithVerifiedIcon(
                      name: widget.authorName,
                      isVerified: false,
                      lengthToTruncateAt: 20,
                      textStyle: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: blackFont,
                      ),
                    ),
                    Text(
                      " • ",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: blackFont,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                "${widget.createdAt} ",
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: darkGrey,
                ),
              ),
            ],
          ),
          widget.readTime == 0
              ? CustomChip(
                  text: '1 min read',
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                )
              : CustomChip(
                  text: '${widget.readTime} min read',
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                )
        ],
      ),
    );
  }

  Widget newsShortDescription() {
    return Column(
      children: [
        SizedBox(
          height: 20,
        ),
        Text(
          messageDecoderWithEmoji(widget.shortDescription) ?? "",
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 14,
            color: blackFont,
          ),
          textAlign: TextAlign.justify,
        ),
      ],
    );
  }

  Widget newsSubTitle() {
    return Text(
      messageDecoderWithEmoji(widget.subTitle) ?? "",
      style: TextStyle(
        fontSize: 16,
        color: blackFont,
      ),
      textAlign: TextAlign.justify,
    );
  }

  // Widget newsFullDescription2() {
  //   return Text(
  //     messageDecoderWithEmoji(widget.postFullDescription)! ?? "",
  //   );
  // }

  Widget newsFullDescription() {
    return widget.postFullDescription;
  }

  Widget blogChips() {
    return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: widget.tags.map((e) => CustomChip(text: e)).toList());
  }

  Widget relatedPost() {
    return widget.postType == PostType.news
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              relatedPostTitle(),
              SizedBox(height: 10),
              Column(
                  children: widget.newsListRelatedPostItems!
                      .map((news) => Container(
                            child: Column(
                              children: [
                                NewsTile(
                                  newsListItem: news,
                                ),
                                SizedBox(
                                  height: 16,
                                )
                              ],
                            ),
                          ))
                      .toList()),
            ],
          )
        : SimilarPostsForBlog(postID: widget.postID);
  }

  Widget relatedPostTitle() {
    return Text(
      "RELATED POST",
      style: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 18,
        color: blackFont,
      ),
      textAlign: TextAlign.justify,
    );
  }
}

String formatDate(DateTime dateTime) {
  DateFormat dateFormat = DateFormat("MMM dd");
  return dateFormat.format(dateTime);
}

class SimilarPostsForBlog extends StatefulWidget {
  final String postID;
  final CustomerProfile? postOfUser;
  const SimilarPostsForBlog({Key? key, required this.postID, this.postOfUser})
      : super(key: key);

  @override
  _SimilarPostsForBlogState createState() => _SimilarPostsForBlogState();
}

class _SimilarPostsForBlogState extends State<SimilarPostsForBlog> {
  Future<List<UserPost>>? getSimilarPostFuture;

  @override
  void initState() {
    super.initState();
    getSimilarPostFuture = getSimilarPosts();
  }

  Future<List<UserPost>>? getSimilarPosts() async {
    return UserPostAuth().getSimilarPosts(postID: widget.postID);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<UserPost>>(
      future: getSimilarPostFuture,
      builder: (context, AsyncSnapshot<List<UserPost>> snapShot) {
        if (snapShot.connectionState == ConnectionState.done) {
          if (snapShot.hasError) {
            return Text('Something went wrong');
          }
          if (snapShot.hasData && snapShot.data!.isNotEmpty) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "RELATED POST",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: blackFont,
                  ),
                  textAlign: TextAlign.justify,
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(vertical: 32),
                  itemCount: snapShot.data!.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: PostTile(
                        onDeleteBlog: () {},
                        post: snapShot.data!.reversed.toList()[index],
                      ),
                    );
                  },
                ),
              ],
            );
          } else {
            return SizedBox.shrink();
          }
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}
