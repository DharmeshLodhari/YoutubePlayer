import 'package:Slydo/screens/more_apps/ask/models/ask_categories_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/state_notifier.dart';
import '../../../utils/colors.dart';
import '../../../utils/navigation_util.dart';
import '../../../utils/util.dart';
import 'add_topic_screen.dart';
import 'ask_auth.dart';
import 'ask_viewmodel.dart';
import 'components/topics_view.dart';
import 'components/question_view.dart';

class AskByCategoryScreen extends StatefulWidget {
  
  AskCategories? askCategories;
  AskByCategoryScreen({this.askCategories});
  
  @override
  State<AskByCategoryScreen> createState() => _AskByCategoryScreenState();
}

class _AskByCategoryScreenState extends State<AskByCategoryScreen> {
  late PageController _pageViewCtrl;
  UsersCategories? usersCategory;
  late UserBloc userBloc;
  late AskViewModel askViewModel;

  @override
  void initState() {
    _pageViewCtrl = PageController(initialPage: 0);
    getUserCategories();
    super.initState();
  }

  Future<UsersCategories?> getUserCategories() async {
    Map<String, dynamic>? result = await AskAuth().getUsersCategories();
    setState(() {
      usersCategory = result!['results'];
    });
    return usersCategory!;
  }

  Future<UsersCategories?> saveUserCategories(String categoryId) async {
    Map<String, dynamic>? result = await AskAuth().saveUsersSingleCategories(categoryId);
    setState(() {
      usersCategory = result!['results'];
    });
    return usersCategory!;
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    askViewModel = Provider.of<AskViewModel>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: _buildFloatingActionButton(),
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }
  
  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      backgroundColor: HexColor(widget.askCategories!.color!),
      child: Icon(
        Icons.add,
        color: Colors.white,
      ),
      onPressed: () {
        NavigationUtil.push(
          context,
          screen: AddTopicScreen(),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: Size.fromHeight(80.0),
      child: AppBar(
        backgroundColor: HexColor(widget.askCategories!.color!)
            .withOpacity(0.8),
        titleSpacing: 0,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.askCategories!.name!,
              overflow: TextOverflow.fade,
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w700,
                color: white,
              ),
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              Icon(
                Icons.search_rounded,
                color: white,
                size: 26,
              ),
              SizedBox(width: 10),
              !isAddCategory()! ? InkWell(
                onTap: () {
                  saveUserCategories(widget.askCategories!.id!);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: white,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    child: Text(
                      'Add',
                      style: TextStyle(
                        color: blackFont,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ) : Container(
                height: 24,
                width: 24,
                decoration: BoxDecoration(shape: BoxShape.circle),
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: userBloc.user.avatar!,
                    fit: BoxFit.cover,
                    errorWidget: imageErrorWidget,
                  ),
                ),
              ),
              SizedBox(width: 17),
            ],
          ),
        ],
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.keyboard_arrow_left,
            color: white,
            size: 26,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 6,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              SizedBox(height: 17),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  pageViewTabItem(
                      onPageTap: () {
                        askViewModel.updateCurrentAskTapOnHome(i: 0);
                        _pageViewCtrl.jumpToPage(0);
                      },
                      pageNum: 0,
                      title: 'Yarn',
                      currentTapIndex: askViewModel.currentAskTapOnHome),
                  pageViewTabItem(
                      onPageTap: () {
                        askViewModel.updateCurrentAskTapOnHome(i: 1);
                        _pageViewCtrl.jumpToPage(1);
                      },
                      pageNum: 1,
                      title: 'Questions',
                      currentTapIndex: askViewModel.currentAskTapOnHome),
                ],
              ),
              SizedBox(height: 7),
            ],
          ),
          Expanded(
            child: PageView(
              onPageChanged: (currentPage) {
                askViewModel.updateCurrentAskTapOnHome(i: currentPage);
              },
              controller: _pageViewCtrl,
              children: [
                TopicView(selectedCategory: widget.askCategories!.id!,),
                QuestionView(selectedCategory: widget.askCategories!.id!,),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget pageViewTabItem(
      {required int pageNum,
      required String title,
      int? currentTapIndex,
      Function? onPageTap}) {
    return InkWell(
      onTap: () => onPageTap!(),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          shape: BoxShape.rectangle,
          color: currentTapIndex == pageNum
              ? HexColor(widget.askCategories!.color!).withOpacity(0.1)
              : Colors.white,
        ),
        child: Text(
          title,
          style: TextStyle(
            color: currentTapIndex == pageNum ? HexColor(widget.askCategories!.color!) : blackFont,
            fontSize: 14,
            fontWeight:
                currentTapIndex == pageNum ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  bool? isAddCategory() {
    bool isAdded = false;
    if (usersCategory != null) {
      for (var usCate in usersCategory!.categories!) {
        if (widget.askCategories!.id == usCate.id) {
          isAdded = true;
          break;
        }
      }
    }
    return isAdded;
  }
}
