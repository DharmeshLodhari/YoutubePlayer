import 'dart:math';

import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/business/models/Contract.dart';
import 'package:Slydo/screens/more_apps/business/tiles/contract_tile.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/slide_action_button.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:toast/toast.dart';

import '../business_auth.dart';

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

    contracts = await BusinessAuth().getContractList();

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
                        .asMap()
                        .map(
                          (index, element) => MapEntry(
                            index,
                            _getSlidableWithLists(
                                context,
                                ContractTile(
                                  contract: element,
                                ),
                                index),
                          ),
                        )
                        .values
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
    int index,
  ) {
    return Slidable(
      controller: _slideController,
      direction: Axis.horizontal,
      actionPane: SlidableBehindActionPane(),
      actionExtentRatio: 0.25,
      child: VerticalListItem(contractTile, contracts[index]),
      actions: listActionSlideActions(index),
      secondaryActions: listSecondaryActions(index),
    );
  }

  List<Widget> listSecondaryActions(int index) {
    bool isPause = Random().nextBool();

    // STOPPED = ("Stopped", _("Stopped"))
    // ENDED = ("Ended", _("Ended"))
    // ACTIVE = ("Active", _("Active"))
    // PAUSED = ("Paused", _("Paused"))

    return [
      SlideActionButton(
          backgroundColor: getSecondaryActionIconColor(index),
          icon: getSecondaryActionIcon(index),
          onTap: () {
            // _slideController.activeState.close();
            updateContractStatus(index, getUpdateAction(index));
          },
          title: getSecondaryActionTitle(index),
          slideController: _slideController),
    ];
  }

  Color getSecondaryActionIconColor(int index) {
    Contract contract = contracts[index];
    switch (contract.status) {
      case "Paused":
        return naturalGreen;
        break;
      case "Active":
        return starYellow;
        break;
      case "Stopped":
        return naturalGreen;
        break;
      case "Ended":
        return starYellow;
        break;
      default:
        return navyBlue;
    }
  }

  IconData getSecondaryActionIcon(int index) {
    Contract contract = contracts[index];
    switch (contract.status) {
      case "Paused":
        return Icons.play_arrow_rounded;
        break;
      case "Active":
        return Icons.pause;
        break;
      case "Stopped":
        return Icons.play_arrow_rounded;
        break;
      case "Ended":
        return Icons.pause;
        break;
      default:
        return Icons.ac_unit;
    }
  }

  String getSecondaryActionTitle(int index) {
    Contract contract = contracts[index];
    switch (contract.status) {
      case "Paused":
        return "Resume";
        break;
      case "Active":
        return "Pause";
        break;
      case "Stopped":
        return "Resume";
        break;
      case "Ended":
        return "Pause";
        break;
      default:
        return "";
    }
  }

  String getUpdateAction(int index) {
    Contract contract = contracts[index];
    switch (contract.status) {
      case "Paused":
        return "Active";
        break;
      case "Active":
        return "Paused";
        break;
      case "Stopped":
        return "Ended";
        break;
      case "Ended":
        return "Stopped";
        break;
      default:
        return "";
    }
  }

  void updateContractStatus(int index, String action) {
    Contract contract = contracts[index];
    Map<String, String> data = {"status": action};

    BusinessAuth()
        .updateContract(id: contract.id.toString(), data: data)
        .then((value) {
      contracts[index].status = action;
      setState(() {});
      Toast.show(
        "Status updated successfully",
        context,
        backgroundColor: blackFont,
        textColor: Colors.white,
      );
    }).catchError((error) {
      Toast.show(
        "Status updated unsuccessfully",
        context,
        backgroundColor: mateRed,
        textColor: Colors.white,
      );
    });
  }

  List<Widget> listActionSlideActions(int index) {
    return [
      SlideActionButton(
          backgroundColor: mateRed,
          icon: Icons.stop_circle_outlined,
          onTap: () {
            updateContractStatus(index, getUpdateAction(index));
          },
          title: "Stop",
          slideController: _slideController),
    ];
  }

  void handleSlideAnimationChanged(Animation<double> slideAnimation) {}

  void handleSlideIsOpenChanged(bool isOpen) {}
}

class VerticalListItem extends StatelessWidget {
  VerticalListItem(this.child, this.contract);

  final Widget child;
  final Contract contract;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .pushNamed("/contract-detail", arguments: {"id": contract.id});
      },
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 2),
        child: child,
      ),
    );
  }
}
