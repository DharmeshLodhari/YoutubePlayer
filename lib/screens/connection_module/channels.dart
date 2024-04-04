import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/connection_module/widget/custom_slydo_channel_card.dart';
import 'package:Slydo/screens/more_apps/messaging/message_auth.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../locale/app_localization.dart';
import '../../utils/slydo_app_icon_icons.dart';
import '../../widget/no_item_in_list.dart';
import '../moments/models/comment_model.dart';
import '../more_apps/messaging/chat/models/channel_model.dart';
import '../more_apps/yarn/utils/yarn_enum.dart';

class ChatChannels extends StatefulWidget {
  ChatChannels();
  @override
  State<ChatChannels> createState() => _ChatChannelsState();
}

class _ChatChannelsState extends State<ChatChannels> {
  String? nextPageUrl;
  bool _isLoading = false;
  bool isFirstTime = true;
  bool noItemInList = false;
  List<ChannelModel> channelModelList = [];
  final ScrollController _scrollCtrl = ScrollController();
  final RefreshController _refreshCtrl =
      RefreshController(initialRefresh: false);
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

    // searchTextCtrl.addListener(() {
    //   _onRefresh();
    //
    // });
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
        .getChannels(nextUrl: nextPageUrl, searchText: searchTextCtrl.text)
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

  void _onRefresh() {
    isFirstTime = true;
    channelModelList.clear();
    nextPageUrl = null;
    if (mounted) setState(() {});
    getListOfChannels();
    _refreshCtrl.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0.0),
      child: SmartRefresher(
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
            searchBox(),
            const SizedBox(height: 6),
            if (noItemInList)
              Expanded(
                  child: NoItemInList(
                      msg: AppLocalization.of(context)!.noChannels))
            else
              Expanded(
                child: ListView.builder(
                  physics: const ClampingScrollPhysics(),
                  controller: _scrollCtrl,
                  itemCount: channelModelList.length + 1,
                  itemBuilder: (BuildContext context, int index) {
                    if (index == channelModelList.length) {
                      return buildLoadingIndicator(isLoading: _isLoading);
                    } else {
                      return GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, Routes.USER_PROFILE,
                              arguments: {
                                "searchedUserName": channelModelList[index].id,
                                "channel": channelModelList[index].groupName,
                              });
                        },
                        child: CustomSlydoChannelCard(
                          channelModel: channelModelList[index],
                          tileRenderPlace: TileRenderPlace.Thiny,
                        ),
                      );
                    }
                  },
                ),
              ),
          ],
        ),
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
            // key: textFormField,
            controller: searchTextCtrl,
            style: TextStyle(
              fontSize: 16,
              color: blackFont,
              fontWeight: FontWeight.w600,
            ),
            cursorWidth: 1.5,
            cursorColor: navyBlue,
            onChanged: (value) {
              if (value.length >= 3) {
                _onRefresh();
              } else if (value.length == 0) {
                setState(() {
                  _onRefresh();
                });
              }
            },
            decoration: InputDecoration(
              hintText: 'Search...',
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
                _onRefresh();
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
          _onRefresh();
          FocusScope.of(context).unfocus();
        }
      },
    );
  }
}
