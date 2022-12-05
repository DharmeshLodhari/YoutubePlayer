import 'package:Slydo/screens/connection_module/widget/custom_slydo_channel_card.dart';
import 'package:Slydo/screens/more_apps/messaging/message_auth.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../../../locale/app_localization.dart';
import '../../../../../widget/noItemInList.dart';
import '../../../../moments/models/comment_model.dart';
import '../../../messaging/chat/models/channel_model.dart';

class UserChannelsList extends StatefulWidget {
  String? ownerName;
  bool? isSearch;
  UserChannelsList({this.ownerName, this.isSearch});
  @override
  State<UserChannelsList> createState() => _UserChannelsListState();
}

class _UserChannelsListState extends State<UserChannelsList> {
  String? nextPageUrl;
  bool _isLoading = false;
  bool isFirstTime = true;
  bool noItemInList = false;
  List<ChannelModel> channelModelList = [];
  ScrollController _scrollCtrl = ScrollController();
  RefreshController _refreshCtrl = RefreshController(initialRefresh: false);
  BasePaginationModel<List<ChannelModel>>? basePaginationModel;

  @override
  void initState() {
    super.initState();
    getListOfChannels();

    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels == _scrollCtrl.position.maxScrollExtent &&
          _scrollCtrl.position.pixels != 0) {
        getListOfChannels();
      }
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void getListOfChannels() {
    if (isFirstTime == false) {
      if (nextPageUrl == null || nextPageUrl!.isEmpty) return;
    }
    if (mounted) setState(() => _isLoading = true);

    MessageAuth()
        .getChannels(nextUrl: nextPageUrl, ownerName: widget.ownerName)
        .then((value) {
      if (mounted) setState(() => _isLoading = false);

      basePaginationModel = value;
      // channelModelList.clear();
      channelModelList.addAll(value.result);
      nextPageUrl = basePaginationModel!.next;
      isFirstTime = false;

      if (channelModelList.isEmpty) {
        if (mounted) setState(() => noItemInList = true);
      } else {
        if (mounted) setState(() => noItemInList = false);
      }
    }).catchError((e) {
      if (mounted) setState(() => _isLoading = false);
      isFirstTime = false;

      showToast(message: 'Something went wrong');
    });
  }

  _onRefresh() {
    isFirstTime = true;
    channelModelList.clear();
    nextPageUrl = null;
    if (mounted) setState(() {});
    getListOfChannels();
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
      onRefresh: () {
        _onRefresh();
      },
      child: Column(
        children: [
          noItemInList
              ? Expanded(
              child: NoItemInList(
                  msg: AppLocalization.of(context)!.noChannels))
              : Expanded(
            child: ListView.builder(
              padding: EdgeInsets.only(top: 5),
              physics: ClampingScrollPhysics(),
              controller: _scrollCtrl,
              itemCount: channelModelList.length + 1,
              itemBuilder: (BuildContext context, int index) {
                if (index == channelModelList.length) {
                  return buildLoadingIndicator(isLoading: _isLoading);
                } else {
                  return CustomSlydoChannelCard(
                      channelModel: channelModelList[index]);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
