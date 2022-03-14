import 'dart:convert';

import 'package:Slydo/screens/more_apps/news/news_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:share/share.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';

import '../data/state_notifier.dart';
import '../locale/app_localization.dart';
import '../utils/enums.dart';
import '../utils/slydo_app_icon_icons.dart';
import '../utils/util.dart';
import '../utils/video_player_controller/chewie_player.dart';
import '../utils/video_player_controller/chewie_progress_colors.dart';
import '../widget/LoadingIndicator.dart';
import '../widget/bottom_sheet_item.dart';
import '../widget/dialog.dart';
import '../widget/noItemInList.dart';
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
import 'package:flutter_quill/flutter_quill.dart' as flutterQuill;

class PostDetailPage extends StatefulWidget {
  final String? postId;
  final PostType postType;

  const PostDetailPage({
    Key? key,
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
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  bool isVideoPlaying = false;

  NewsDetailItem newsDetailItem = NewsDetailItem();
  VideoPlayerController? _mainVideoController;

  ChewieController? _chewieMainController;

  dynamic blogBodyTextJson;
  late flutterQuill.QuillController _quillController;

  UserPost? userPost;
  late Future<UserPost> getPostFuture;

  @override
  void initState() {
    super.initState();
    getPostFuture = UserPostAuth().getPost(postID: widget.postId!);
    // if (widget.postType == PostType.blog) {
    // } else {
    //   getNewsResultAndInitializeVideoController();
    // }
  }

  getBlogDetailsAndInitializeVideoController({required UserPost userPost}) {
    if (userPost.video != null) {
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
      blogBodyTextJson = jsonDecode(userPost.text!);
      _quillController = flutterQuill.QuillController(
          document: flutterQuill.Document.fromJson(blogBodyTextJson),
          selection: TextSelection.collapsed(offset: -1));
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

    if (newsDetailItem.video != null) {
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

  void onRefresh() async {
    Connectivity().checkConnectivity().then((value) {
      var connectionResult = value;
      if (connectionResult == ConnectivityResult.wifi ||
          connectionResult == ConnectivityResult.mobile) {
        if (widget.postType == PostType.news) {
          getNewsResultAndInitializeVideoController();
        }
        _refreshController.refreshCompleted();
      } else {
        showToast(
            message:
                AppLocalization.of(context)!.internetConnectionNotAvailable);
        _refreshController.refreshCompleted();
      }
    });
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
      getPostFuture = UserPostAuth().getPost(postID: widget.postId!);
    });
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: appBar() as PreferredSizeWidget?,
      body: scaffoldBody(),
    );
  }

  Widget scaffoldBody() {
    return FutureBuilder(
      future: getPostFuture,
      builder: (context, AsyncSnapshot<UserPost> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            userPost = snapshot.data!;
            if (widget.postType == PostType.blog) {
              getBlogDetailsAndInitializeVideoController(userPost: userPost!);
            }
            return PostDetailPageScaffoldBody(
              postID: widget.postType == PostType.blog ? userPost!.id! : '',
              postType: widget.postType,
              authorUserName: userPost!.authorUsername,
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
              onRefresh: onRefresh,
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
                  ? userPost!.image == null
                      ? ''
                      : userPost!.image!
                  : newsDetailItem.poster!,
              shortDescription: widget.postType == PostType.blog
                  ? userPost!.tagLine == null
                      ? ''
                      : messageDecoderWithEmoji(userPost!.tagLine)!
                  : newsDetailItem.shortDescription!,
              refreshController: _refreshController,
              postFullDescription: getPostFullText(),
              chewieMainController: _chewieMainController,
              newsListRelatedPostItems: newsDetailItem.newsListItems,
            );
          } else {
            return Center(child: Text('There is no data at the moment.'));
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
        newsDetailItem.description!,
        style: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 14,
          color: blackFont,
        ),
        textAlign: TextAlign.justify,
      );
    }
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
          icon: SlydoAppIcon.share,
          onTap: () {
            Navigator.pop(context);
            var shareBody =
                "https://merchant.slydo.co/${userPost!.authorUsername}/blog/${userPost!.id}";
            Share.share(shareBody, subject: "${userPost!.authorName}");
          },
        ),
      );
    }

    if (userPost != null) {
      list.add(
        bottomSheetItem(
          title: "Share in Chat",
          icon: SlydoAppIcon.text_message,
          onTap: () async {
            Navigator.pop(context);
            sendPostToUserInChat();
          },
        ),
      );
    }

    if (userPost != null) {
      list.add(
        bottomSheetItem(
          title: AppLocalization.of(context)!.editPost,
          icon: SlydoAppIcon.edit,
          onTap: () async {
            Navigator.pop(context);
            final isBlogUpdated = await Navigator.pushNamed(
                context, '/create-blog',
                arguments: userPost);
            if (isBlogUpdated == true) {
              reloadPage();
            }
          },
        ),
      );
    }

    if (userPost != null) {
      list.add(
        bottomSheetItem(
          title: AppLocalization.of(context)!.deletePost,
          icon: SlydoAppIcon.delete,
          onTap: () {
            Navigator.pop(context);
            showDialogBox(
              context: context,
              actionOneTextColor: white,
              actionOneBgColor: mateRed,
              actionTwoTextColor: blackFont,
              actionTwoBgColor: greyBorderColor,
              title: AppLocalization.of(context)!.delete,
              actionTwoText: AppLocalization.of(context)!.cancel,
              actionOneText: AppLocalization.of(context)!.delete,
              description: 'Are you sure you want to delete this blog post?',
              roundedBackgroundIcon: RoundedBackgroundIcon(
                enableMargin: false,
                width: 90,
                height: 90,
                image: Image.asset('assets/images/delete_dialog_icon.png'),
              ),
              leftButtonOnPressed: () {
                _deleteBlogPost(blogId: userPost!.id!);
              },
            );
          },
        ),
      );
    }

    return list;
  }

  sendPostToUserInChat() async {
    List<ChatConversation?> listOfRecipient =
        await ShareInChat().selectShareCustomer(context);
    debugPrint("Selected users = ${listOfRecipient.length}");

    UserPost itemData = userPost!;

    listOfRecipient.forEach((recipient) {
      addUserPostToChat(itemData: itemData, recipientUser: recipient!);
    });
  }

  addUserPostToChat({
    required UserPost itemData,
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

  void _deleteBlogPost({required String blogId}) {
    showDialog(
        context: context,
        builder: (dialogLoadingContext) => LoadingIndicator());

    UserPostAuth().deleteBlog(blogId: blogId).then(
      (deleted) {
        Navigator.pop(context); // Dismiss loading indicator

        if (deleted) {
          Navigator.pop(context); // Dismiss user post detail page
          showToast(message: 'Post Deleted');
        } else {
          showToast(message: 'Something went wrong, please try again');
        }
      },
    ).catchError((e) {
      print('DELETE BLOG POST CATCH ERROR: $e');
    });
  }
}

class PostDetailPageScaffoldBody extends StatefulWidget {
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
  final Function()? onRefresh;
  final String? authorUserName;
  final String shortDescription;
  final Widget postFullDescription;
  final RefreshController refreshController;
  final ChewieController? chewieMainController;
  final List<NewsListItem>? newsListRelatedPostItems;
  const PostDetailPageScaffoldBody({
    Key? key,
    required this.tags,
    required this.postID,
    required this.postType,
    required this.subTitle,
    required this.readTime,
    required this.isLoading,
    required this.postTitle,
    required this.createdAt,
    required this.onRefresh,
    required this.authorName,
    required this.postImageUrl,
    required this.authorUserName,
    required this.posterImageUrl,
    this.newsListRelatedPostItems,
    required this.shortDescription,
    required this.refreshController,
    required this.postFullDescription,
    required this.chewieMainController,
  }) : super(key: key);

  @override
  State<PostDetailPageScaffoldBody> createState() =>
      _PostDetailPageScaffoldBodyState();
}

class _PostDetailPageScaffoldBodyState
    extends State<PostDetailPageScaffoldBody> {
  @override
  Widget build(BuildContext context) {
    return widget.isLoading
        ? Center(
            child: CircularLoadingIndicator(),
          )
        : SmartRefresher(
            enablePullDown: true,
            header: WaterDropHeader(
              complete: Container(),
              waterDropColor: navyBlue,
            ),
            controller: widget.refreshController,
            onRefresh: widget.onRefresh,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: 6,
                  ),
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
                        SizedBox(
                          height: 20,
                        ),
                        // newsSubTitle(),
                        // SizedBox(
                        //   height: 20,
                        // ),
                        newsFullDescription(),
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
            ),
          );
  }

  Widget postImage() {
    return Container(
      child: CachedNetworkImage(
        imageUrl: widget.postImageUrl ?? "",
        fit: BoxFit.fill,
        width: double.infinity,
        height: 220,
      ),
    );
  }

  Widget videoPlayer() {
    if (widget.chewieMainController != null) {
      return Chewie(
        titleName: widget.postTitle,
        posterUrl: widget.posterImageUrl,
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
          Navigator.pushNamed(context, '/profile',
              arguments: {"searchedUserName": widget.authorUserName});
        },
        child: SizedBox(
          width: 40,
          height: 40,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: CachedNetworkImage(
              fit: BoxFit.cover,
              imageUrl: widget.posterImageUrl,
              errorWidget: imageErrorWidget,
            ),
          ),
        ),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/profile',
                      arguments: {"searchedUserName": widget.authorUserName});
                },
                child: Text(
                  widget.authorName.length <= 7
                      ? "${widget.authorName} • "
                      : "${widget.authorName.substring(0, 8).replaceAll(' ', '')} • ",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: blackFont,
                  ),
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
          widget.shortDescription,
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
      widget.subTitle,
      style: TextStyle(
        fontSize: 16,
        color: blackFont,
      ),
      textAlign: TextAlign.justify,
    );
  }

  Widget newsFullDescription() {
    return widget.postFullDescription;
  }

  Widget newsChips() {
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
