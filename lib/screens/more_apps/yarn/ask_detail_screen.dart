import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/yarn/models/Topics/YarnTopic.dart';
import 'package:Slydo/utils/util.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../locale/app_localization.dart';
import 'ask_auth.dart';
import 'models/Topics/CommentDetails.dart';
import 'widgets/ask_loader.dart';
import 'widgets/ask_posts_view.dart';
import 'widgets/topic_text_field.dart';

class AskDetailScreen extends StatefulWidget {
  YarnTopic? yarnTopic;

  AskDetailScreen({@required this.yarnTopic});

  @override
  State<AskDetailScreen> createState() => _AskDetailScreenState();
}

class _AskDetailScreenState extends State<AskDetailScreen> {
  bool isLoading = false;
  String? next = "", previous = "";
  List<CommentDetails> commentDetailsList = [];
  int count = 0;
  bool noList = false;
  late UserBloc userBloc;
  final TextEditingController controller = TextEditingController();
  RefreshController _postRefreshController =
      RefreshController(initialRefresh: false);
  bool isAPILoading = false;
  ScrollController _commentScrollController = new ScrollController();

  @override
  void initState() {
    getAllComments();
    _commentScrollController.addListener(() {
      if (_commentScrollController.position.pixels ==
              _commentScrollController.position.maxScrollExtent &&
          _commentScrollController.position.pixels != 0) {
        getAllComments();
      }
    });
    super.initState();
  }

  void getAllComments() async {
    if (!isLoading) {
      if (next != null && !isLoading) {
        isLoading = true;
        if (mounted) setState(() {});

        Map<String, dynamic>? result = await AskAuth()
            .getAllComments(next, previous ?? '', widget.yarnTopic!.id!);

        if (result == null) {
          noList = true;

          isLoading = false;
          if (mounted) {
            setState(() {});
          }
          return;
        }

        count = result['count'];
        next = result['next'];
        previous = result['previous'];
        var tempList = result['results'];
        //commentDetailsList = [];
        if (mounted) {
          setState(() {
            noList = false;
            isLoading = false;
            commentDetailsList.addAll(tempList);
          });
        }
        debugPrint("YARN TOPICS:- $commentDetailsList");
      }
    }
    if (commentDetailsList.isEmpty) {
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

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(),
        body: _buildBody());
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      title: Text(
        !widget.yarnTopic!.isQuestion! ? "Yarn" : "Question",
        style: TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.w700,
          color: blackFont,
        ),
      ),
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(
          Icons.keyboard_arrow_left,
          color: navyBlue,
          size: 26,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        _buildPostAndCommentView(),
        _buildTopicTextFiled(),
        SizedBox(height: 20)
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
          padding: EdgeInsets.all(10),
          child: !isLoading
              ? AskPosts(
                  openComments: commentDetailsList.isNotEmpty ? true : false,
                  commentDetailsList: commentDetailsList,
                  yarnTopic: widget.yarnTopic,
                  isImages: widget.yarnTopic!.media != null &&
                          widget.yarnTopic!.media!.isNotEmpty
                      ? true
                      : false,
                )
              : AskLoader(),
        ),
      ),
    );
  }

  Widget _buildTopicTextFiled() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: TopicTextField(
        height: 50,
        controller: controller,
        hint: "Leave your thought",
        yarn: widget.yarnTopic,
        userImage: userBloc.user.avatar,
        isLoading: isAPILoading,
        onPressed: () async {
          FocusScope.of(context).unfocus();
          isAPILoading = true;
          if (mounted) setState(() {});
          await addComment();
          isAPILoading = false;
          if (mounted) setState(() {});
        },
      ),
    );
  }

  Future addComment() async {
    Map<String, dynamic> data = {
      "comment": controller.text,
      "author_username": userBloc.user.userName
    };
    try {
      CommentDetails? commentDetails =
          await AskAuth().addCommentToYarn(widget.yarnTopic!.id!, data);
      if (commentDetails != null) {
        setState(() {
          widget.yarnTopic!.numberOfComments =
              widget.yarnTopic!.numberOfComments! + 1;
        });
        commentDetailsList.add(commentDetails);
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
        count = 0;
        next = "";
        previous = "";
        commentDetailsList = [];
        if (mounted) setState(() {});

        getAllComments();
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
