import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/no_item_in_list.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:Slydo/widget/slide_action_button.dart';
import 'package:Slydo/widget/vertical_list_item.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../../../data/currency.dart';
import '../../../../../routes/route_constants.dart';
import '../../../../../widget/dialog.dart';
import '../../../payment_and_banking/payment_and_banking_auth.dart';
import '../../models/shipping_option_list_model.dart';

class ShippingOptionsList extends StatefulWidget {
  @override
  _ShippingOptionsListState createState() => _ShippingOptionsListState();
}

class _ShippingOptionsListState extends State<ShippingOptionsList>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  final _auth = PaymentAndBankingAuth();
  late UserBloc userBloc;
  int? count = 0;
  String? next = "";
  String? previous = "";
  List shippingOptionsList = [];
  final ScrollController _scrollController = ScrollController();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  bool isLoading = false;
  bool noItemInList = false;

  late final SlidableController _slideController = SlidableController(this);

  @override
  void initState() {
    this.getList();

    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          _scrollController.position.pixels != 0) {
        getList();
      }
    });
  }

  // refresh the list when lifecycle called onResume method

  void _onRefresh() async {
    //check network connectivity and if true then refresh the list
    Connectivity().checkConnectivity().then((value) {
      final connectionResult = value;
      if (connectionResult == ConnectivityResult.wifi ||
          connectionResult == ConnectivityResult.mobile) {
        count = 0;
        next = "";
        previous = "";
        shippingOptionsList = [];
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

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);

    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: ScaffoldMessenger(
        key: _scaffoldMessengerKey,
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.white,
          appBar: appBar() as PreferredSizeWidget?,
          body: SmartRefresher(
              enablePullDown: true,
              header: WaterDropHeader(
                complete: Container(),
                waterDropColor: navyBlue,
              ),
              controller: _refreshController,
              onRefresh: _onRefresh,
              child: _buildShippingOptionsList()),
        ),
      ),
    );
  }

  Widget appBar() {
    return AppBar(
      elevation: 0,
      titleSpacing: 0,
      backgroundColor: Colors.white,
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
      centerTitle: false,
      title: Text(
        AppLocalization.of(context)!.shippingOptions,
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      actions: <Widget>[
        addShippingOptionBtn(),
        const SizedBox(
          width: 16,
        ),
      ],
    );
  }

  Widget addShippingOptionBtn() {
    return RoundedBackgroundIcon(
      height: 34,
      width: 34,
      icon: Icon(
        SlydoAppIcon.add,
        size: 16,
        color: blackFont,
      ),
      onTap: () {
        Navigator.of(context).pushNamed(
          Routes.ADD_SHIPPING_OPTIONS,
          arguments: <String, dynamic>{
            'callback': onCallback,
          },
        );
      },
      backgroundColor: iconBtnGrey,
      enableMargin: true,
    );
  }

  Widget _buildShippingOptionsList() {
    return noItemInList
        ? NoItemInList(
            msg: AppLocalization.of(context)!
                .youDontHaveAnyShippingOptionPleaseAddOne,
          )
        : isLoading && shippingOptionsList.isEmpty
            ? buildLoadingIndicator(isLoading: isLoading)
            : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 16),
                //+1 for progressbar
                itemCount: shippingOptionsList.length + 1,
                itemBuilder: (BuildContext context, int index) {
                  if (index == shippingOptionsList.length) {
                    return buildJumpingLoadingIndicator(isLoading: isLoading);
                  } else {
                    return _getSlidableWithLists(
                        context,
                        bankAccountTile(
                          shippingModel: shippingOptionsList[index],
                        ),
                        shippingOptionsList[index]);
                  }
                },
                controller: _scrollController,
              );
  }

  void getList() async {
    if (!isLoading) {
      if (next != null && !isLoading) {
        if (mounted) {
          setState(() {
            isLoading = true;
          });
        }
        final Map<String, dynamic>? result =
            await _auth.getShippingOptions(next, previous);
        if (result == null) {
          isLoading = false;
          return;
        }
        count = result['count'];
        next = result['next'];
        previous = result['previous'];
        final tempList = result['results'];
        if (mounted) {
          setState(() {
            isLoading = false;
            shippingOptionsList.addAll(tempList);
          });
        }
      }
      if (shippingOptionsList.isEmpty) {
        if (mounted) {
          setState(() {
            noItemInList = true;
          });
        }
      } else if (next == null && shippingOptionsList.length > 6) {
        _scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
          content:
              Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
          duration: const Duration(milliseconds: 500),
        ));
      }
    }
  }

  Widget bankAccountTile({required ShippingOptionsListModel shippingModel}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      shadowColor: boxShadowTwo,
      elevation: 0,
      child: Container(
        decoration: decorateBox(),
        child: ListTile(
          dense: true,
          contentPadding: const EdgeInsets.only(
              top: 15.0, bottom: 15.0, left: 10.0, right: 10.0),
          trailing: getAmount(shippingModel: shippingModel),
          leading: getShippingOptionName(shippingModel: shippingModel),
        ),
      ),
    );
  }

  Widget getAmount({required ShippingOptionsListModel shippingModel}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          "${worldCurrencies[userBloc.user.currency]}",
          style: TextStyle(
              fontFamily: "Inter",
              color: navyBlue,
              fontWeight: FontWeight.bold,
              fontSize: 14),
        ),
        Text(
          moneyDisplayNormalizer(shippingModel.price),
          style: TextStyle(
              color: navyBlue, fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }

  Widget getShippingOptionName(
      {required ShippingOptionsListModel shippingModel}) {
    return Text(
      appendStringDot(shippingModel.name!, 30),
      maxLines: 1,
      style: TextStyle(
          color: blackFont, fontWeight: FontWeight.bold, fontSize: 15),
    );
  }

  Widget _getSlidableWithLists(BuildContext context, Widget bankAccountTile,
      ShippingOptionsListModel shippingModel) {
    return Slidable(
      controller: _slideController,
      direction: Axis.horizontal,
      startActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.25,
        children: listActionSlideActions(shippingModel: shippingModel),
      ),
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.25,
        children: listSecondaryActions(shippingModel: shippingModel),
      ),
      child: VerticalListItem(bankAccountTile),
    );
  }

  List<Widget> listSecondaryActions(
      {required ShippingOptionsListModel shippingModel}) {
    return [
      SlideActionButton(
          backgroundColor: starYellow,
          icon: Icons.edit,
          onTap: () {
            Navigator.of(context).pushNamed(
              Routes.EDIT_SHIPPING_OPTIONS,
              arguments: <String, dynamic>{
                'price': shippingModel.price,
                'name': shippingModel.name,
                'id': shippingModel.id,
                'currency': shippingModel.currency,
                'callback': onCallback,
              },
            );
          },
          title: AppLocalization.of(context)!.edit,
          slideController: _slideController),
    ];
  }

  List<Widget> listActionSlideActions(
      {ShippingOptionsListModel? shippingModel}) {
    return [
      SlideActionButton(
          backgroundColor: mateRed,
          icon: SlydoAppIcon.remove,
          onTap: () {
            showDeleteShippingOptionDialog(shippingModel);
          },
          title: AppLocalization.of(context)!.delete,
          slideController: _slideController),
    ];
  }

  // callback function with a bool parameter for adding shipping option
  void onCallback(bool value) {
    // Handle the callback value
    // getList();
    _onRefresh();
    if (mounted) setState(() {});
  }

  void showDeleteShippingOptionDialog(ShippingOptionsListModel? shippingModel) {
    showDialogBox(
      context: context,
      actionOneTextColor: blackFont,
      actionOneBgColor: greyBorderColor,
      actionTwoTextColor: white,
      actionTwoBgColor: mateRed,
      title: 'Delete Shipping Option',
      actionOneText: AppLocalization.of(context)!.discard,
      actionTwoText: AppLocalization.of(context)!.continueMsg,
      description: 'Are you sure you want to delete this shipping option?',
      roundedBackgroundIcon: RoundedBackgroundIcon(
        enableMargin: false,
        width: 90,
        height: 90,
        image: Image.asset('assets/images/delete_dialog_icon.png'),
      ),
      rightButtonOnPressed: () async {
        deleteShippingOption(shippingModel);
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  void deleteShippingOption(ShippingOptionsListModel? shippingModel) async {
    final bool? data = await _auth.deleteShippingOption(shippingModel!.id!);
    if (data != null && data) {
      showToast(message: "Shipping Option Deleted Successfully");
      //refresh list
      _onRefresh();
    } else {
      showToast(message: "Unable to Deleted Shipping Option");
    }
  }
}
