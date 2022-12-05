import 'dart:typed_data';
import 'package:Slydo/screens/more_apps/ask/utils/utils.dart';
import 'package:Slydo/screens/more_apps/ask/widgets/rich_text.dart';
import 'package:Slydo/screens/more_apps/ask/widgets/topic_actions.dart';
import 'package:Slydo/screens/more_apps/ask/widgets/viewer_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../routes/route_constants.dart';
import '../../../../utils/navigation_util.dart';
import '../../../../utils/util.dart';
import '../../../../widget/customized_popup_menu.dart';
import '../../messaging/chat/utils.dart';
import '../ask_auth.dart';
import '../ask_comment_detail_screen.dart';
import '../models/Topics/CommentDetails.dart';
import '../models/Topics/YarnTopic.dart';
import 'ask_comment_view.dart';
import 'ask_media_render.dart';
import 'ask_options.dart';

class AskPosts extends StatefulWidget {
  bool? openComments;
  List<CommentDetails>? commentDetailsList = [];
  GestureTapCallback? onOptionsAction;

  bool? isImages = false;
  YarnTopic? yarnTopic;
  Color? backGroundColor;

  AskPosts({
    this.openComments = false,
    this.commentDetailsList,
    this.onOptionsAction,
    this.isImages,
    this.yarnTopic,
    this.backGroundColor,
  });

  @override
  State<AskPosts> createState() => _AskPostsState();
}

class _AskPostsState extends State<AskPosts> {
  late CustomizedPopUpMenu menu;

  int selectedMenuItemIndex = 0;

  GlobalKey _key = LabeledGlobalKey("messageListPopUpMenu");

  String? filterValue;

  bool isPopMenuOpen = false;

  bool isLoading = false;
  String next = "", previous = "";
  int count = 0;
  bool noList = false;

  void getAllComments() async {
    String selectFilter;
    if (filterValue == null || filterValue == '-created_at') {
      selectFilter = '-created_at';
    } else {
      selectFilter = 'created_at';
    }
    if (!isLoading) {
      if (next != null && !isLoading) {
        isLoading = true;
        if (mounted) setState(() {});

        Map<String, dynamic>? result = await AskAuth()
            .getAllComments(next, previous, widget.yarnTopic!.id!, sortBy: selectFilter);

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
        widget.commentDetailsList = [];
        if (mounted) {
          setState(() {
            noList = false;
            isLoading = false;
            widget.commentDetailsList!.addAll(tempList);
          });
        }
        debugPrint("YARN TOPICS:- $widget.commentDetailsList");
      }
      if (widget.commentDetailsList!.isEmpty) {
        if (mounted) {
          setState(() {
            noList = true;
          });
        }
      }
      // else if (categoriesNext == null && askCategoriesList.length > 6) {
      //   _askCategoriesScaffoldMessengerKey.currentState!.showSnackBar(SnackBar(
      //     content:
      //     Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
      //     duration: Duration(milliseconds: 500),
      //   ));
      // }
    }
  }

  @override
  Widget build(BuildContext context) {
    menu = CustomizedPopUpMenu(
      buttonKey: _key,
      context: context,
      children: [
        CustomizedPopUpMenuItem(title: "Latest", value: "-created_at"),
        CustomizedPopUpMenuItem(title: "Older", value: "created_at"),
      ],
      selectedIndex: selectedMenuItemIndex,
      right: 16,
    );
    menu.isTitleShow = true;
    menu.onChange = menuItemSelectionChange;
    menu.menuState = menuStateChange;
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 12),
        decoration: BoxDecoration(
          color: HexColor("#FBFBFF"),
          borderRadius: BorderRadius.circular(10),
        ),
        child: _buildPostCard(context: context));
  }

  Widget _buildPostCard({required BuildContext context}) {
    if (widget.isImages!) {
      return _buildWithImagesPostCard(context: context);
    }
    return _buildWithOutImagesPostCard(context: context);
  }

  Widget _buildWithImagesPostCard({required BuildContext context}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildUserInfoRow(context: context),
        SizedBox(
          height: 10,
        ),
        if (widget.yarnTopic!.isQuestion!) ...[
          _buildPostTitle(),
          SizedBox(height: 10),
        ],
        _buildPostDescription(),
        SizedBox(
          height: 10,
        ),
        _buildTagsAndViewerRow(),
        SizedBox(
          height: 15,
        ),
        _buildImagesRow(context: context),
        SizedBox(
          height: 20,
        ),
        _buildTopActions(context: context),
        _buildCommentView(context: context),
      ],
    );
  }

  Widget _buildWithOutImagesPostCard({required BuildContext context}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildUserInfoRow(context: context),
        SizedBox(
          height: 10,
        ),
        if (widget.yarnTopic!.isQuestion!) ...[
          _buildPostTitle(),
          SizedBox(height: 10),
        ],
        _buildPostDescription(),
        SizedBox(
          height: 10,
        ),
        _buildTagsAndViewerRow(),
        SizedBox(
          height: 15,
        ),
        _buildTopActions(context: context),
        _buildCommentView(context: context),
      ],
    );
  }

  Widget _buildUserInfoRow({required BuildContext context}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            Navigator.of(context).pushNamed(Routes.PHOTO_VIEWER,
                arguments: widget.yarnTopic!.authorAvatar!);
          },
          child: Container(
            height: 24,
            width: 24,
            decoration: BoxDecoration(shape: BoxShape.circle),
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: widget.yarnTopic!.authorAvatar!,
                fit: BoxFit.cover,
                errorWidget: imageErrorWidget,
              ),
            ),
          ),
        ),
        SizedBox(
          width: 10,
        ),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, Routes.USER_PROFILE,
                      arguments: {
                        "searchedUserName": widget.yarnTopic!.author
                      });
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  userNameWithVerifiedIcon(
                      name: widget.yarnTopic!.authorName!, isVerified: widget.yarnTopic!.authorIsVerified ?? false),
                  Text(
                    "@${widget.yarnTopic!.author!}",
                    style: TextStyle(
                      fontSize: 10,
                      color: HexColor("#3F61DB")
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 5,
            ),
              Expanded(
                child: Text(
                  '${getGetYarnQuestionDateTime(widget.yarnTopic!.createdAt!)}',
                  overflow: TextOverflow.fade,
                  style: TextStyle(
                    color: blackFont,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
              ],
            )
        ),
        InkWell(
          onTap: () {
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
                  child: AskOptions(yarnTopic: widget.yarnTopic!,),
                );
              },
            );
          },
          child: Icon(
            Icons.more_horiz_rounded,
            color: Color(0xFF4B545A),
          ),
        )
      ],
    );
  }

  Widget _buildPostTitle() {
    return RichTextForTitle(description: messageDecoderWithEmoji(widget.yarnTopic!.title ?? '') ?? '',);
    // return Text(
    //   messageDecoderWithEmoji(widget.yarnTopic!.title!)!,
    //   maxLines: 30,
    //   style: TextStyle(
    //     color: blackFont,
    //     fontSize: 16,
    //     fontWeight: FontWeight.bold,
    //   ),
    // );
  }

  Widget _buildPostDescription() {
    return RichTextForTitle(description: messageDecoderWithEmoji(widget.yarnTopic!.body ?? '') ?? '',);
    // return Text(
    //   messageDecoderWithEmoji(widget.yarnTopic!.body!)!,
    //   maxLines: 30,
    //   style: TextStyle(
    //     color: blackFont,
    //     fontSize: 14,
    //     fontWeight: FontWeight.w400,
    //   ),
    // );
  }

  Widget _buildTagsAndViewerRow() {
    List<String> selectedImages = [];
    if (widget.yarnTopic!.viewersAvatars != null) {
      for (ViewersAvatars avatars in widget.yarnTopic!.viewersAvatars!) {
        selectedImages.add(avatars.avatar!);
      }
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Wrap(
            runSpacing: 5,
            spacing: 2,
            children: widget.yarnTopic!.tags!
                .map((e) => Text(
                  "#$e",
                  style: TextStyle(
                    fontSize: 12,
                    color: HexColor("#3F61DB"),
                  ),
                ))
                .toList(),
          ),
        ),
        SizedBox(
            width: 70, child: ViewerArranger(selectedImages: selectedImages)),
      ],
    );
  }

  Widget _buildTopActions({required BuildContext context}) {
    return TopicActions(
      yarnTopic: widget.yarnTopic!,
    );
  }

  Widget _buildImagesRow({required BuildContext context}) {
    return AskMediaRender(yarnTopic: widget.yarnTopic,);
  }

  Widget _buildCommentView({required BuildContext context}) {
    if (widget.openComments! && widget.commentDetailsList!.isNotEmpty && widget.commentDetailsList != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildTopActionButton(),
          Divider(
            thickness: 1,
            color: HexColor("#BEC2F4"),
          ),
          Column(
            children: widget.commentDetailsList!
                .map((e) => InkWell(
              onTap: () async {
                await NavigationUtil.push(
                  context,
                  screen: AskCommentDetailScreen(yarnTopic: widget.yarnTopic, commentDetail: e,),
                );
                if (mounted) setState(() {});
              },
              child: AskCommentView(
                yarnTopic: widget.yarnTopic,
                commentDetail: e,
                openReply: false,
              ),
            )).toList(),
          ),
        ],
      );
    }
    return SizedBox();
  }

  Widget _buildTopActionButton() {
    return SizedBox(
      key: _key,
      //height: 34,
      width: 108,
      child: Card(
        // color: isPopMenuOpen ? navyBlue : iconBtnGrey,
        elevation: 0,
        margin: EdgeInsets.only(left: 5, right: 5, top: 5),
        child: InkWell(
          onTap: () {
            if (menu.isMenuOpen) {
              menu.closeMenu();
            } else {
              menu.openMenu();
            }
          },
          child: Row(
            children: [
              Text(
                "Top Comments",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(
                Icons.arrow_drop_down_outlined,
              )
            ],
          ),
        ),
      ),
    );
  }

  void menuItemSelectionChange(String value, int index) {
    selectedMenuItemIndex = index;
    filterValue = value;
    getAllComments();
    setState(() {});
    // _onRefresh();
  }

  void menuStateChange(bool isOpen) {
    isPopMenuOpen = isOpen;
    setState(() {});
  }

}
