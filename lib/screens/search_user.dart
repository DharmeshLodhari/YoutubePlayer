import 'package:Slydo/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/environment.dart';
import '../data/state_notifier.dart';
import '../locale/app_localization.dart';
import '../routes/route_constants.dart';
import '../utils/slydo_app_icon_icons.dart';
import '../utils/util.dart';
import '../widget/no_item_in_list.dart';
import 'more_apps/user_profile/models/user.dart';
import 'more_apps/user_profile/screens/user_profile_module_new/profile_template/utils.dart';

class SearchUser extends StatefulWidget {
  const SearchUser({Key? key}) : super(key: key);

  @override
  State<SearchUser> createState() => _SearchUserState();
}

class _SearchUserState extends State<SearchUser> {
  int? count = 0;
  String? next = "";
  String? previous = "";
  bool isLoading = false;
  List<Widget> results = [];
  bool noItemInList = false;
  bool isSearchIsEmpty = true;
  AuthService _auth = AuthService();
  String autoCompleteSearchText = "";

  ScrollController _scrollController = ScrollController();
  TextEditingController searchItemTextController = TextEditingController();

  void getList() async {
    if (!isLoading) {
      if (next != null && !isLoading) {
        if (mounted) {
          isLoading = true;
          setState(() {});
        }
        final Map<String, dynamic>? result = await _auth
            .searchEndpointPagination(
                getSearchUrl(searchItemTextController.text), next, previous)
            .catchError((error) {
          debugPrint("ERROR:- $error");
        });
        if (result == null) {
          isLoading = false;
          if (mounted) setState(() {});
          return;
        }

        count = result['count'];
        next = result['next'];
        previous = result['previous'];
        final List? tempList = result['results'];
        if (mounted) {
          isLoading = false;
          results.clear();

          try {
            tempList!.forEach((result) {
              results.add(getUserTile(result));
            });
          } catch (e) {
            debugPrint(
                'ERROR ADDING SEARCH RESULT TO LIST ::: ${e.toString()}');
          }
          setState(() {});
        }
      }

      if (results.isNotEmpty) {
        noItemInList = false;
        setState(() {});
      } else if (results.isEmpty) {
        if (mounted) {
          noItemInList = true;
          setState(() {});
        }
      } else if (next == null && results.length > 6) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
          duration: const Duration(milliseconds: 500),
        ));
      }
    }
  }

  Widget getUserTile(var object) {
    debugPrint('object::::$object');
    final CustomerProfile user = CustomerProfile.fromJson(object);

    if (user.userName.toString().toLowerCase() == "slydo" ||
        user.userName.toString().toLowerCase() == "slydo_envelope") {
      return Container();
    }

    return userCard(user);
  }

  Widget userCard(CustomerProfile user) {
    final UserBloc userBloc = Provider.of<UserBloc>(context, listen: false);
    return InkWell(
      onTap: () {
        if (userBloc.user.userName == user.userName) {
          showToast(message: 'You cannot search for yourself');
        } else {
          Navigator.pop(context, user);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: EdgeInsets.zero,
          shadowColor: boxShadowTwo,
          elevation: 0,
          child: Container(
            decoration: decorateBox(),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    dense: true,
                    title: Text(
                      user.displayName()!.length <= 35
                          ? user.displayName()!
                          : '${user.displayName()!.substring(0, 36)}...',
                      maxLines: 1,
                      style: TextStyle(
                          color: blackFont,
                          fontWeight: FontWeight.w600,
                          fontSize: 14),
                    ),
                    subtitle: Text(
                      user.userName!,
                      maxLines: 1,
                      style: TextStyle(color: darkGrey, fontSize: 12),
                    ),
                    leading: getUserLeading(user),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget getUserLeading(CustomerProfile user) {
    final Color borderColor = getUserTypeColor(user: user);

    return GestureDetector(
      onTap: () {
        String? image = '';
        if (user.avatar! == "" ||
            user.avatar! ==
                "https://slydo-assets.s3.amazonaws.com/static/images/User_Avatar.png") {
          image = getInitials(user.fullName!).toUpperCase();
        } else {
          image = user.avatar!;
        }

        Navigator.of(context).pushNamed(Routes.PHOTO_VIEWER, arguments: image);
      },
      child: userImageUserInitialsPic(user.avatar!, user.fullName!, 25, 48),
    );
  }

  String getSearchUrl(String searchedText) {
    return AppConfig.baseUrl + "/api/v1/search/users/?search=" + searchedText;
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          _scrollController.position.pixels != 0) {
        if (next != null) {
          getList();
        }
      }
    });

    searchItemTextController.addListener(() {
      autoCompleteSearchText = searchItemTextController.text;

      setState(() => _isRefreshing());

      if (results.isNotEmpty || searchItemTextController.text.length != 0) {
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
  }

  _isRefreshing() {
    count = 0;
    next = "";
    previous = "";
    results.clear();
    isLoading = false;
    noItemInList = false;
    getList();
  }

  @override
  void dispose() {
    searchItemTextController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: appBar() as PreferredSizeWidget?,
      body: Column(
        children: [
          const SizedBox(height: 6),
          searchBox(),
          const SizedBox(height: 16),
          Expanded(
            child: _buildResultList(),
          ),
        ],
      ),
    );
  }

  Widget _buildResultList() {
    return isSearchIsEmpty
        ? NoItemInList(
            msg: '',
            isResult: false,
          )
        : noItemInList
            ? NoItemInList(
                msg: AppLocalization.of(context)!.noResultFound,
              )
            : isLoading && results.isEmpty
                ? buildLoadingIndicator(isLoading: isLoading)
                : Container(
                    child: ListView.builder(
                      //+1 for progressbar
                      itemCount: results.length + 1,
                      itemBuilder: (BuildContext context, int index) {
                        if (index == results.length) {
                          return buildJumpingLoadingIndicator(
                              isLoading: isLoading);
                        } else {
                          return results[index];
                        }
                      },
                      controller: _scrollController,
                    ),
                  );
  }

  Widget searchBox() {
    try {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Theme(
          data: Theme.of(context).copyWith(
            textSelectionTheme: TextSelectionThemeData(
              selectionHandleColor: navyBlue,
            ),
          ),
          child: TextFormField(
            autofocus: true,
            controller: searchItemTextController,
            style: TextStyle(
              fontSize: 16,
              color: blackFont,
              fontWeight: FontWeight.w600,
            ),
            cursorWidth: 1.5,
            cursorColor: navyBlue,
            decoration: InputDecoration(
              hintText: AppLocalization.of(context)!.searchPageTextFieldHint,
              fillColor: Colors.white,
              filled: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              prefix: const Padding(
                padding: EdgeInsets.only(left: 12),
              ),
              suffixIcon: searchIcon(),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: dividerColor,
                  width: 1.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: navyBlue,
                  width: 1.0,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: dividerColor,
                  width: 1.0,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: dividerColor,
                  width: 1.0,
                ),
              ),
            ),
            onFieldSubmitted: (val) {
              if (mounted) {
                setState(() => _isRefreshing());

                FocusScope.of(context).unfocus();
              }
            },
          ),
        ),
      );
    } catch (e) {
      return Container();
    }
  }

  Widget searchIcon() {
    return IconButton(
      icon: Icon(
        SlydoAppIcon.search,
        color: darkGrey,
        size: 16,
      ),
      onPressed: () {
        if (mounted) {
          setState(() => _isRefreshing());

          FocusScope.of(context).unfocus();
        }
      },
    );
  }

  Widget appBar() {
    return AppBar(
      elevation: 0,
      titleSpacing: 16,
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
      centerTitle: false,
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
        "Search User",
        style: TextStyle(
            color: blackFont, fontSize: 20, fontWeight: FontWeight.w700),
      ),
    );
  }
}
