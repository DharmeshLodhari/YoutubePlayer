import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/screens/more_apps/user_profile/tiles/user_tile.dart';
import 'package:Slydo/screens/more_apps/user_profile/user_auth.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/noItemInList.dart';
import 'package:Slydo/widget/search_text_field.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class SelectUserForGroup extends StatefulWidget {
  var arguments;

  SelectUserForGroup({this.arguments});

  @override
  _SelectUserForGroupState createState() => _SelectUserForGroupState();
}

class _SelectUserForGroupState extends State<SelectUserForGroup> {
  final GlobalKey<ScaffoldState> _scaffoldSelectUserForGroupKey =
      new GlobalKey<ScaffoldState>();

  int count = 0;
  String next = "";
  String previous = "";
  List<CustomerProfile> connectionList = [];
  List<CustomerProfile> selectedConnectionList = [];
  ScrollController _scrollController = new ScrollController();

  TextEditingController searchUserController;

  bool isLoading = false;
  bool isSearchIsEmpty = false;
  bool noItemInList = false;

  ///For checking if this page is oprn to add user is existingGroup or not
  bool isForAddingUserInGroup = false;

  @protected
  void initState() {
    isForAddingUserInGroup = widget.arguments != null
        ? widget.arguments["isForAddingUserInGroup"] ?? false
        : false;

    searchUserController = TextEditingController();
    this.getList();

    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          _scrollController.position.pixels != 0) {
        getList();
      }
    });

    searchUserController.addListener(() {
      if (searchUserController.text.length >= 5) {
        setState(() {
          count = 0;
          next = "";
          previous = "";
          connectionList.clear();
          noItemInList = false;
          getList();
        });
      }
      if (connectionList.isNotEmpty || searchUserController.text.length != 0) {
        if (mounted) {
          setState(() {
            isSearchIsEmpty = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            isSearchIsEmpty = true;
          });
        }
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldSelectUserForGroupKey,
      backgroundColor: Colors.white,
      appBar: getAppBar(),
      body: getScaffoldBody(),
      floatingActionButton: getFloatingActionBtn(),
    );
  }

  Widget getFloatingActionBtn() {
    return selectedConnectionList.isEmpty
        ? null
        : FloatingActionButton(
            backgroundColor: navyBlue,
            onPressed: btnPressed,
            child: Icon(
              Icons.arrow_forward_rounded,
              size: 28,
            ),
          );
  }

  void btnPressed() {
    if (isForAddingUserInGroup) {
      Navigator.of(context).pop(selectedConnectionList);
    } else {
      Navigator.of(context).pushNamed("/set-name-and-profile-for-group",
          arguments: {"users": selectedConnectionList});
    }
  }

  Widget getAppBar() {
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
      title: getSearchTextField(),
    );
  }

  Widget getSearchTextField() {
    return Container(
      padding: EdgeInsets.only(right: 16),
      child: SearchTextField(
        hintText: "Search...",
        onSubmit: () {
          debugPrint("Serached Text:- ${searchUserController.text}");
        },
        textEditingController: searchUserController,
      ),
    );
  }

  Widget getScaffoldBody() {
    return Container(
      child: Column(
        children: [
          getSelectedUserList(),
          Expanded(child: _buildConnectionsList()),
        ],
      ),
    );
  }

  Widget getSelectedUserList() {
    return selectedConnectionList.isNotEmpty
        ? Container(
            child: Container(
              height: 80,
              padding: EdgeInsets.only(top: 10, right: 10, left: 16),
              child: ListView.builder(
                itemBuilder: (context, index) =>
                    getSelectedUserUI(index: index),
                itemCount: selectedConnectionList.length,
                scrollDirection: Axis.horizontal,
              ),
            ),
          )
        : Container();
  }

  Widget getSelectedUserUI({int index}) {
    return Container(
      padding: EdgeInsets.only(right: 8),
      child: Stack(
        overflow: Overflow.visible,
        children: [
          ClipOval(
            child: Container(
              height: 64,
              width: 64,
              child: CachedNetworkImage(
                imageUrl: selectedConnectionList[index].avatar,
                fit: BoxFit.fill,
              ),
            ),
          ),
          Positioned(
            top: 2,
            right: 2,
            child: GestureDetector(
              onTap: () {
                selectedConnectionList.removeAt(index);
                setState(() {});
              },
              child: Icon(
                SlydoAppIcon.close_2,
                color: blackFont,
                size: 18,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildConnectionsList() {
    return isSearchIsEmpty
        ? NoItemInList(
            msg: AppLocalization.of(context).pleaseTypeSomethingToGetResult,
            isResult: false,
          )
        : noItemInList
            ? NoItemInList(
                msg: AppLocalization.of(context).noResultFound,
              )
            : ListView.builder(
                padding: EdgeInsets.symmetric(
                  vertical: 4,
                ),
                //+1 for progressbar
                itemCount: connectionList.length + 1,
                itemBuilder: (BuildContext context, int index) {
                  if (index == connectionList.length) {
                    return _buildIndicator();
                  } else {
                    return getUserTile(user: connectionList[index]);
                  }
                },
                controller: _scrollController,
              );
  }

  Widget _buildIndicator() {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Center(
        child: new Opacity(
            opacity: isLoading ? 1.0 : 00,
            child: isLoading ? CircularLoadingIndicator() : Container()),
      ),
    );
  }

  Future<void> getList() async {
    if (!isLoading) {
      if (next != null && !isLoading) {
        if (mounted) {
          setState(() {
            isLoading = true;
          });
        }
        Map<String, dynamic> result = await UserAuth().searchUserInContact(
            next, previous,
            query: searchUserController.text.trim());
        count = result['count'];
        next = result['next'];
        previous = result['previous'];

        List tempList = result['results'];

        List<CustomerProfile> users = List<CustomerProfile>();

        tempList
            .forEach((element) => users.add(CustomerProfile.fromJson(element)));

        isLoading = false;
        if (mounted) setState(() {});

        connectionList.addAll(users);
        if (mounted) setState(() {});
      }
      if (connectionList.isEmpty) {
        noItemInList = true;
        if (mounted) setState(() {});
      } else if (next == null && connectionList.length > 6) {
        _scaffoldSelectUserForGroupKey.currentState.showSnackBar(SnackBar(
          content:
              Text(AppLocalization.of(context).youHaveReachedBottomOfTheList),
          duration: Duration(milliseconds: 500),
        ));
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget getUserTile({CustomerProfile user}) {
    return GestureDetector(
      onTap: () async {
        bool isPresent = false;
        for (int i = 0; i < selectedConnectionList.length; i++) {
          if (user.userName == selectedConnectionList[i].userName) {
            isPresent = true;
            break;
          }
        }

        if (!isPresent) {
          selectedConnectionList.add(user);
          setState(() {});
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 2),
        child: UserTile(user: user),
      ),
    );
  }
}
