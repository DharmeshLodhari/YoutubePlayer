import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/screens/more_apps/user_profile/user_auth.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../locale/app_localization.dart';
import '../../utils/colors.dart';
import '../../utils/util.dart';
import '../../widget/custom_slydo_usercard.dart';
import '../../widget/noItemInList.dart';
import '../moments/models/comment_model.dart';

class SuggestionsTab extends StatefulWidget {
  const SuggestionsTab({Key? key}) : super(key: key);

  @override
  _SuggestionsTabState createState() => _SuggestionsTabState();
}

class _SuggestionsTabState extends State<SuggestionsTab> {
  String? nextPageUrl;
  bool _isLoading = false;
  bool isFirstTime = true;
  bool noItemInList = false;
  List<CustomerProfile> suggestionsList = [];
  ScrollController _scrollCtrl = ScrollController();
  RefreshController _refreshCtrl = RefreshController(initialRefresh: false);
  BasePaginationModel<List<CustomerProfile>>? basePaginationModel;

  @override
  void initState() {
    super.initState();
    getListOfSuggestions();

    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels == _scrollCtrl.position.maxScrollExtent &&
          _scrollCtrl.position.pixels != 0) {
        getListOfSuggestions();
      }
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void getListOfSuggestions() {
    if (isFirstTime == false) {
      if (nextPageUrl == null || nextPageUrl!.isEmpty) return;
    }
    if (mounted) setState(() => _isLoading = true);

    UserAuth().getListOfSuggestions(nextUrl: nextPageUrl).then((value) {
      if (mounted) setState(() => _isLoading = false);

      basePaginationModel = value;
      suggestionsList.addAll(value.result);
      nextPageUrl = basePaginationModel!.next;
      isFirstTime = false;
      debugPrint('NEXT PAGE URL -> ${basePaginationModel!.next}');

      if (suggestionsList.isEmpty) {
        if (mounted) setState(() => noItemInList = true);
      }
    }).catchError((e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          noItemInList = true;
        });
      }
      isFirstTime = false;

      // showToast(message: e.toString());
      // Navigator.pop(context);
    });
  }

  void _onRefresh() {
    isFirstTime = true;
    suggestionsList.clear();
    nextPageUrl = null;
    getListOfSuggestions();
    _refreshCtrl.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      enablePullDown: true,
      header: WaterDropHeader(
        complete: Container(),
        waterDropColor: navyBlue,
      ),
      controller: _refreshCtrl,
      onRefresh: _onRefresh,
      child: noItemInList
          ? NoItemInList(msg: AppLocalization.of(context)!.noSuggestions)
          : ListView.builder(
              physics: ClampingScrollPhysics(),
              controller: _scrollCtrl,
              itemCount: suggestionsList.length + 1,
              itemBuilder: (BuildContext context, int index) {
                if (index == suggestionsList.length) {
                  return buildLoadingIndicator(isLoading: _isLoading);
                } else {
                  return CustomSlydoUserCard(user: suggestionsList[index]);
                }
              },
            ),
    );
  }
}
