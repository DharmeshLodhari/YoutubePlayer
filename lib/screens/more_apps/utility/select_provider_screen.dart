import 'package:Slydo/screens/more_apps/utility/utility_provider_tile.dart';
import 'package:Slydo/utils/enums.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../locale/app_localization.dart';
import '../../../utils/util.dart';
import '../../../widget/no_item_in_list.dart';
import 'models/provider_model.dart';
import 'utility_auth.dart';

class SelectProviderScreen extends StatefulWidget {
  final String nameOfProvider;
  final UtilitiesProvidersEnum providerEnum;
  const SelectProviderScreen(
      {Key? key, required this.providerEnum, required this.nameOfProvider})
      : super(key: key);

  @override
  State<SelectProviderScreen> createState() => _SelectProviderScreenState();
}

class _SelectProviderScreenState extends State<SelectProviderScreen> {
  int? count = 0;
  String? next = "";
  String? previous = "";
  List providerList = [];
  List providerListCopy = [];
  bool isFirstTime = true;
  bool noItemInList = false;
  final ScrollController _scrollController = ScrollController();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  bool isLoading = false;
  late Future<List<ProviderModel>> providerListFuture;
  @override
  void initState() {
    super.initState();

    getList();

    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          _scrollController.position.pixels != 0) {
        getList();
      }
    });
  }

  void getList() async {
    if (!isLoading) {
      if (next != null && !isLoading) {
        if (mounted) {
          setState(() {
            isLoading = true;
          });
        }
        final Map<String, dynamic>? result = await UtilityAuth()
            .getUtilityProviderList(next, previous,
                providerEnum: widget.providerEnum);
        if (result == null) {
          isLoading = false;
          return;
        }
        next = result['next'];
        count = result['count'];
        previous = result['previous'];
        final tempList = result['results'];

        isLoading = false;
        providerList.addAll(tempList);
        providerListCopy.addAll(tempList);

        if (mounted) setState(() {});

        if (isFirstTime && next != null && next != "") {
          isFirstTime = false;
          getList();
        }
      }
      if (providerList.isEmpty) {
        noItemInList = true;

        if (mounted) setState(() {});
      } else if (next == null && providerList.length > 6) {
        showReachedToBottomSnackBar();
      }
    }
  }

  AppBar appBar() {
    return AppBar(
      elevation: 0,
      titleSpacing: 0,
      backgroundColor: Colors.transparent,
      leading: IconButton(
        icon: Icon(
          Icons.keyboard_arrow_left,
          size: 24,
          color: navyBlue,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: Text(
        widget.nameOfProvider,
        style: TextStyle(
          color: blackFont,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SmartRefresher(
            enablePullDown: true,
            header: WaterDropHeader(
              complete: Container(),
              waterDropColor: navyBlue,
            ),
            controller: _refreshController,
            onRefresh: _onRefresh,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                selectProviderText(),
                const SizedBox(height: 8),
                // CustomizedTextFormField(
                //   onChanged: (value){
                //     if(providerList.contains(value)){
                //       setState(() {
                //         providerListCopy.addAll(iterable);
                //       });
                //     }
                //   },
                // ),
                Expanded(child: _buildProviderList()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onRefresh() async {
    //check network connectivity and if true then refresh the list
    Connectivity().checkConnectivity().then((value) {
      final connectionResult = value;
      if (connectionResult == ConnectivityResult.wifi ||
          connectionResult == ConnectivityResult.mobile) {
        count = 0;
        next = "";
        previous = "";
        providerList = [];
        noItemInList = false;
        isFirstTime = true;
        if (mounted) setState(() {});
        isLoading = false;
        getList();
        _refreshController.refreshCompleted();
      } else {
        showToast(
            message:
                AppLocalization.of(context)!.internetConnectionNotAvailable);
        _refreshController.refreshCompleted();
      }
    });
  }

  Widget _buildProviderList() {
    return noItemInList
        ? NoItemInList(
            msg: AppLocalization.of(context)!.providerListEmpty,
          )
        : ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 4),
            itemCount: providerList.length + 1,
            itemBuilder: (BuildContext context, int index) {
              if (index == providerList.length) {
                return _buildIndicator();
              } else {
                return UtilityProviderTile(providerModel: providerList[index]);
              }
            },
            controller: _scrollController,
          );
  }

  Widget _buildIndicator() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Opacity(
          opacity: isLoading ? 1.0 : 0.0,
          child: CircularLoadingIndicator(),
        ),
      ),
    );
  }

  void showReachedToBottomSnackBar() {
    if (mounted) {
      if (next == null &&
          _scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          _scrollController.position.pixels != 0) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
          duration: const Duration(milliseconds: 500),
        ));
      }
    }
  }

  Widget selectProviderText() {
    return Text(
      "Select a provider",
      style:
          TextStyle(color: darkGrey, fontSize: 14, fontWeight: FontWeight.w400),
    );
  }
}
