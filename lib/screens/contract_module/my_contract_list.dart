import 'dart:math';

import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/models/contract_and_invoice/Contract.dart';
import 'package:Slydo/screens/tiles/contract_tile.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/slide_action_button.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:toast/toast.dart';

class MyContractList extends StatefulWidget {
  @override
  _MyContractListState createState() => _MyContractListState();
}

class _MyContractListState extends State<MyContractList> {
  List<Contract> contracts = [];
  bool isLoading = false;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  //slidable tile
  SlidableController _slideController;
  @override
  void initState() {
    getResult();
    _slideController = SlidableController(
      onSlideAnimationChanged: handleSlideAnimationChanged,
      onSlideIsOpenChanged: handleSlideIsOpenChanged,
    );
    super.initState();
  }

  void getResult() async {
    isLoading = true;
    contracts.clear();
    if (mounted) setState(() {});

    contracts = await AuthService().getContractList();

    isLoading = false;
    if (mounted) setState(() {});
  }

  void _onRefresh() async {
    Connectivity().checkConnectivity().then((value) {
      var connectionResult = value;
      if (connectionResult == ConnectivityResult.wifi ||
          connectionResult == ConnectivityResult.mobile) {
        getResult();
        _refreshController.refreshCompleted();
      } else {
        Toast.show(
            AppLocalization.of(context).internetConnectionNotAvailable, context,
            gravity: Toast.BOTTOM, backgroundColor: navyBlue);
        _refreshController.refreshCompleted();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return Future.value(true);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SmartRefresher(
          enablePullDown: true,
          header: WaterDropHeader(
            complete: Container(),
            waterDropColor: navyBlue,
          ),
          controller: _refreshController,
          onRefresh: _onRefresh,
          child: isLoading
              ? Center(
                  child: CircularLoadingIndicator(),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: contracts
                        .map(
                          (element) => _getSlidableWithLists(
                              context,
                              ContractTile(
                                contract: element,
                              )),
                        )
                        .toList(),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _getSlidableWithLists(
    BuildContext context,
    Widget contractTile,
  ) {
    return Slidable(
      controller: _slideController,
      direction: Axis.horizontal,
      actionPane: SlidableBehindActionPane(),
      actionExtentRatio: 0.25,
      child: VerticalListItem(contractTile),
      actions: listActionSlideActions(),
      secondaryActions: listSecondaryActions(),
    );
  }

  List<Widget> listSecondaryActions() {
    bool isPause = Random().nextBool();

    return [
      SlideActionButton(
          backgroundColor: isPause ? starYellow : naturalGreen,
          icon: isPause ? Icons.pause : Icons.play_arrow_rounded,
          onTap: () {
            _slideController.activeState.close();
          },
          title: isPause ? "Pause" : "Resume",
          slideController: _slideController),
    ];
  }

  List<Widget> listActionSlideActions() {
    return [
      SlideActionButton(
          backgroundColor: mateRed,
          icon: Icons.stop_circle_outlined,
          onTap: () {
            _slideController.activeState.close();
          },
          title: "Stop",
          slideController: _slideController),
    ];
  }

  void handleSlideAnimationChanged(Animation<double> slideAnimation) {}

  void handleSlideIsOpenChanged(bool isOpen) {}
}

class VerticalListItem extends StatelessWidget {
  VerticalListItem(this.child);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          Slidable.of(context)?.renderingMode == SlidableRenderingMode.none
              ? Slidable.of(context)?.open()
              : Slidable.of(context)?.close(),
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 2),
        child: child,
      ),
    );
  }
}
