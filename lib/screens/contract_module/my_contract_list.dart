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
                              ),
                              element),
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
    Contract contract,
  ) {
    return Slidable(
      controller: _slideController,
      direction: Axis.horizontal,
      actionPane: SlidableBehindActionPane(),
      actionExtentRatio: 0.25,
      child: VerticalListItem(contractTile),
      actions: listActionSlideActions(contract),
      secondaryActions: listSecondaryActions(contract),
    );
  }

  List<Widget> listSecondaryActions(Contract contract) {
    bool isPause = Random().nextBool();

    // STOPPED = ("Stopped", _("Stopped"))
    // ENDED = ("Ended", _("Ended"))
    // ACTIVE = ("Active", _("Active"))
    // PAUSED = ("Paused", _("Paused"))

    return [
      SlideActionButton(
          backgroundColor: getActionIconColor(contract),
          icon: getActionIcon(contract),
          onTap: () {
            // _slideController.activeState.close();
            updateContractStatus(contract, getUpdateAction(contract));
          },
          title: getActionTitle(contract),
          slideController: _slideController),
    ];
  }

  Color getActionIconColor(Contract contract) {
    switch (contract.status) {
      case "Paused":
        return starYellow;
        break;
      case "Active":
        return naturalGreen;
        break;
      default:
        return navyBlue;
    }
  }

  IconData getActionIcon(Contract contract) {
    switch (contract.status) {
      case "Paused":
        return Icons.play_arrow_rounded;
        break;
      case "Active":
        return Icons.pause;
        break;
      default:
        return Icons.ac_unit;
    }
  }

  String getActionTitle(Contract contract) {
    switch (contract.status) {
      case "Paused":
        return "Resume";
        break;
      case "Active":
        return "Pause";
        break;
      default:
        return "";
    }
  }

  String getUpdateAction(Contract contract) {
    switch (contract.status) {
      case "Paused":
        return "Active";
        break;
      case "Active":
        return "Paused";
        break;
      default:
        return "";
    }
  }

  void updateContractStatus(Contract contract, String action) {
    Map<String, String> data = {"status": action};

    AuthService()
        .updateContract(id: contract.id.toString(), data: data)
        .then((value) {});
  }

  List<Widget> listActionSlideActions(Contract contract) {
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
