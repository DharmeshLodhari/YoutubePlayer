import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../locale/app_localization.dart';
import '../screens/moments/models/comment_model.dart';
import '../utils/util.dart';
import 'no_item_in_list.dart';

class GlobalListViewWidget extends StatefulWidget {
  final Widget Function(dynamic) customWidget;
  final Future<BasePaginationModel<List>> apiFunc;
  const GlobalListViewWidget(
      {Key? key, required this.customWidget, required this.apiFunc})
      : super(key: key);

  @override
  _GlobalListViewWidgetState createState() => _GlobalListViewWidgetState();
}

class _GlobalListViewWidgetState extends State<GlobalListViewWidget> {
  String? nextPageUrl;
  bool _isLoading = false;
  bool noItemInList = false;
  List list = [];
  ScrollController _scrollCtrl = ScrollController();
  RefreshController _refreshCtrl = RefreshController(initialRefresh: false);
  BasePaginationModel<List>? basePaginationModel;

  @override
  void initState() {
    super.initState();
    getList();

    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels == _scrollCtrl.position.maxScrollExtent &&
          _scrollCtrl.position.pixels != 0) {
        getList();
      }
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void getList() async {
    if (mounted) setState(() => _isLoading = true);

    try {
      BasePaginationModel<List> basePaginationValue = await widget.apiFunc;

      if (mounted) setState(() => _isLoading = false);

      basePaginationModel = basePaginationValue;
      list.addAll(basePaginationModel!.result);
      nextPageUrl = basePaginationModel!.next;

      if (list.isEmpty) {
        if (mounted) setState(() => noItemInList = true);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);

      showToast(message: e.toString());
      Navigator.pop(context);
    }
  }

  void _onRefresh() {
    list.clear();
    nextPageUrl = null;
    getList();
    if (mounted) setState(() {});
    _refreshCtrl.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return noItemInList
        ? NoItemInList(msg: AppLocalization.of(context)!.noFollowingUsers)
        : _isLoading && list.isEmpty
            ? buildLoadingIndicator(isLoading: _isLoading)
            : SmartRefresher(
                enablePullDown: true,
                header: WaterDropHeader(
                  complete: Container(),
                  waterDropColor: navyBlue,
                ),
                controller: _refreshCtrl,
                onRefresh: _onRefresh,
                child: ListView.builder(
                  physics: ClampingScrollPhysics(),
                  controller: _scrollCtrl,
                  itemCount: list.length + 1,
                  itemBuilder: (BuildContext context, int index) {
                    if (index == list.length) {
                      return buildJumpingLoadingIndicator(
                          isLoading: _isLoading);
                    } else {
                      return widget.customWidget(list[index]);
                    }
                  },
                ),
              );
  }
}
