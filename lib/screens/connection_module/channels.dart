import 'package:Slydo/screens/connection_module/widget/custom_slydo_channel_card.dart';
import 'package:Slydo/screens/more_apps/messaging/message_auth.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../locale/app_localization.dart';
import '../../utils/slydo_app_icon_icons.dart';
import '../../widget/noItemInList.dart';
import '../moments/models/comment_model.dart';
import '../more_apps/messaging/chat/models/channel_model.dart';

class ChatChannels extends StatefulWidget {
  String? ownerName;
  ChatChannels({this.ownerName});
  @override
  State<ChatChannels> createState() => _ChatChannelsState();
}

class _ChatChannelsState extends State<ChatChannels> {
  String? nextPageUrl;
  bool _isLoading = false;
  bool isFirstTime = true;
  bool noItemInList = false;
  List<ChannelModel> channelModelList = [];
  ScrollController _scrollCtrl = ScrollController();
  RefreshController _refreshCtrl = RefreshController(initialRefresh: false);
  BasePaginationModel<List<ChannelModel>>? basePaginationModel;
  TextEditingController searchTextCtrl = TextEditingController();

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

    searchTextCtrl.addListener(() {
      _onRefresh();
      // if (channelModelList.isNotEmpty || searchTextCtrl.text.length != 0) {
      //   if (mounted) {
      //     setState(() {
      //       noItemInList = false;
      //     });
      //   }
      // } else {
      //   if (mounted) {
      //     setState(() {
      //       noItemInList = true;
      //     });
      //   }
      // }
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
        .getChannels(nextUrl: nextPageUrl, searchText: searchTextCtrl.text, ownerName: widget.ownerName)
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
        searchTextCtrl.text = '';
        _onRefresh();
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: CustomizedTextFormField(
              hasBorder: true,
              hintText: 'Search by name',
              controller: searchTextCtrl,
              suffixIcon: IconButton(
                icon: Icon(
                  SlydoAppIcon.search,
                  color: darkGrey,
                  size: 16,
                ),
                onPressed: () {
                  _onRefresh();
                  FocusScope.of(context).unfocus();
                },
              ),
            ),
          ),
          SizedBox(height: 6),
          noItemInList
              ? Expanded(
                  child: NoItemInList(
                      msg: AppLocalization.of(context)!.noChannels))
              : Expanded(
                  child: ListView.builder(
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
