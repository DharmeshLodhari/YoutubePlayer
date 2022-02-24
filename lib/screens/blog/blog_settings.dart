import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/user_post/models/user_post.dart';
import 'package:Slydo/screens/more_apps/user_post/user_post_auth.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../locale/app_localization.dart';
import '../../utils/colors.dart';
import '../../widget/LoadingIndicator.dart';
import '../more_apps/news/CustomChip.dart';

class BlogSettings extends StatefulWidget {
  final UserPost userPost;
  const BlogSettings({Key? key, required this.userPost}) : super(key: key);

  @override
  State<BlogSettings> createState() => _BlogSettingsState();
}

class _BlogSettingsState extends State<BlogSettings> {
  DateTime? filterDate;
  bool isPublic = false;
  bool isPublished = false;
  bool enableLikes = false;
  bool enableCommenting = false;
  DateFormat dateFormat = DateFormat('yyyy-MM-dd');
  TextEditingController _tagController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tagController =
        TextEditingController(text: widget.userPost.tags!.join(', '));
    isPublic = widget.userPost.publicRead!;
    enableLikes = widget.userPost.enableLike!;
    isPublished = widget.userPost.isPublished!;
    enableCommenting = widget.userPost.enableCommenting!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar() as PreferredSizeWidget?,
      body: _scaffoldBody(),
    );
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
      title: Text(
        AppLocalization.of(context)!.settings,
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _scaffoldBody() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BlogSettingsTitles(
              title: 'Make Public',
              description:
                  'Your post will become public to your friends and everyone',
              isSwitched: isPublic,
              icon: Icon(Icons.public_outlined, color: blackFont),
              onChanged: (makePostPublic) {
                _updateBlogSettings(
                    onUpdated: () {
                      setState(() => isPublic = makePostPublic);
                      Navigator.pushNamed(
                        context,
                        '/profile',
                      );
                    },
                    blogId: widget.userPost.id!,
                    isPublic: makePostPublic);
              },
            ),
            BlogSettingsTitles(
              title: 'Publish',
              description: 'Your post will be published',
              isSwitched: isPublished,
              icon: Icon(
                Icons.published_with_changes_outlined,
                color: blackFont,
              ),
              onChanged: (publishPost) {
                _updateBlogSettings(
                    onUpdated: () {
                      setState(() => isPublished = publishPost);
                    },
                    blogId: widget.userPost.id!,
                    isPublished: publishPost);
              },
            ),
            BlogSettingsTitles(
              title: 'Enable Comments',
              description: 'Everyone will be able to comment on your post',
              isSwitched: enableCommenting,
              icon: Icon(Icons.message_rounded, color: blackFont),
              onChanged: (commentingEnabled) {
                _updateBlogSettings(
                    onUpdated: () {
                      setState(() => enableCommenting = commentingEnabled);
                    },
                    blogId: widget.userPost.id!,
                    enableCommenting: enableCommenting);
              },
            ),
            BlogSettingsTitles(
              title: 'Enable Likes',
              description: 'Everyone will be able to like your post',
              isSwitched: enableLikes,
              icon: Icon(Icons.thumb_up, color: blackFont),
              onChanged: (likeEnabled) {
                _updateBlogSettings(
                  blogId: widget.userPost.id!,
                  enableLikes: likeEnabled,
                  onUpdated: () {
                    setState(() => enableLikes = likeEnabled);
                  },
                );
              },
            ),
            BlogSettingsTitles(
              hasSwitch: false,
              onTap: () async {
                filterDate = await showDatePicker(
                    builder: customThemeBuilder,
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.parse("2022-03-22"));
                String formattedDate = dateFormat.format(filterDate!);
                print('FILTER DATE ----> $formattedDate');

                _updateBlogSettings(
                  blogId: widget.userPost.id!,
                  publishedDate: '2022-02-28T13:35:43.590377+01:00',
                  onUpdated: () {},
                );
                // setState(() {});
                // _onRefresh();
              },
              title: 'Published Date',
              description: 'Pick a date to publish your post',
              icon: Icon(Icons.event_outlined, color: blackFont),
              trailingWidget:
                  Text(dateFormat.format(widget.userPost.publishedDate!)),
            ),
            SizedBox(height: 10),
            CustomizedTextFormField(
              controller: _tagController,
              textInputAction: TextInputAction.go,
              hintText: 'Add your tags separated by commas.',
              onFieldSubmitted: (value) {
                if (_tagController.text.isNotEmpty) {
                  _updateBlogSettings(
                    blogId: widget.userPost.id!,
                    tags: value!,
                    onUpdated: () {
                      print('UPDATED');
                    },
                  );
                } else {
                  showToast(message: 'Enter a tag to send');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _updateBlogSettings(
      {required String blogId,
      bool isPublished = false,
      bool enableLikes = false,
      bool enableCommenting = false,
      bool isPublic = false,
      String? tags,
      String? publishedDate,
      required Function() onUpdated}) {
    showDialog(
        context: context,
        builder: (dialogLoadingContext) => LoadingIndicator());

    UserPostAuth()
        .updateBlogSettings(
            blogId: blogId,
            isPublished: isPublished,
            enableLikes: enableLikes,
            enableCommenting: enableCommenting,
            isPublic: isPublic,
            tags: tags,
            publishedDate: publishedDate)
        .then(
      (updated) {
        if (updated) {
          Navigator.pop(context);
          onUpdated();
        } else {
          Navigator.pop(context);
          showToast(message: 'Something went wrong, please try again');
        }
      },
    ).catchError(
      (e) {
        print('Update blog settings catch error ---> $e');
      },
    );
  }
}

class BlogSettingsTitles extends StatefulWidget {
  final Function()? onTap;
  bool? isSwitched;
  final Widget icon;
  final String title;
  final bool hasSwitch;
  final String description;
  final Widget? trailingWidget;
  final Function(bool isSwitched)? onChanged;
  BlogSettingsTitles(
      {required this.icon,
      required this.title,
      this.onChanged,
      this.onTap,
      this.isSwitched,
      required this.description,
      this.hasSwitch = true,
      this.trailingWidget,
      Key? key})
      : super(key: key);

  @override
  State<BlogSettingsTitles> createState() => _BlogSettingsTitlesState();
}

class _BlogSettingsTitlesState extends State<BlogSettingsTitles> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        onTap: widget.onTap,
        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        leading: CircleAvatar(
          backgroundColor: lightGrey,
          child: widget.icon,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: TextStyle(
                color: blackFont,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              overflow: TextOverflow.fade,
              softWrap: false,
            ),
            Text(
              widget.description,
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: widget.hasSwitch
            ? Switch(
                activeColor: navyBlue,
                value: widget.isSwitched!,
                onChanged: widget.onChanged,
                activeTrackColor: navyBlueLight,
                inactiveTrackColor: navyBlueLight,
              )
            : widget.trailingWidget ?? SizedBox.shrink(),
      ),
    );
  }
}
