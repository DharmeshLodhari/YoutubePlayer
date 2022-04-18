import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/business/models/Contract.dart';
import 'package:Slydo/screens/more_apps/business/tiles/contract_tile.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/slide_action_button.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../../widget/noItemInList.dart';
import '../bloc/contract_bloc.dart';
import '../business_auth.dart';

class MyContractList extends StatefulWidget {
  @override
  _MyContractListState createState() => _MyContractListState();
}

class _MyContractListState extends State<MyContractList> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  ScrollController _scrollController = ScrollController();
  late ContractBloc contractBlocProvider;

  //slidable tile
  SlidableController? _slideController;
  @override
  void initState() {
    super.initState();

    _slideController = SlidableController(
      onSlideAnimationChanged: handleSlideAnimationChanged,
      onSlideIsOpenChanged: handleSlideIsOpenChanged,
    );

    Provider.of<ContractBloc>(context, listen: false).getContractList();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          _scrollController.position.pixels != 0) {
        // contractBlocProvider.getContractList();
      }
    });
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onRefresh() async {
    Connectivity().checkConnectivity().then((value) {
      var connectionResult = value;
      if (connectionResult == ConnectivityResult.wifi ||
          connectionResult == ConnectivityResult.mobile) {
        contractBlocProvider.isRefreshing = true;
        contractBlocProvider.getContractList();
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
    contractBlocProvider = Provider.of<ContractBloc>(context);

    return WillPopScope(
      onWillPop: () async {
        return Future.value(true);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: _scaffoldBody(),
      ),
    );
  }

  Widget _scaffoldBody() {
    return Consumer<ContractBloc>(
      builder: (context, contractBloc, _) {
        if (contractBloc.errorMessage.isNotEmpty) {
          return NoItemInList(
            msg: contractBloc.errorMessage,
          );
        } else if (contractBloc.noItemInList) {
          return NoItemInList(
            msg: AppLocalization.of(context)!.contractEmpty,
          );
        } else {
          if (contractBlocProvider.endOfList) {
            if (_scrollController.positions.isNotEmpty &&
                _scrollController.position.pixels ==
                    _scrollController.position.maxScrollExtent &&
                _scrollController.position.pixels != 0) {
              // Future.delayed(Duration.zero, () async {
              //   ScaffoldMessenger.of(context).showSnackBar(
              //     SnackBar(
              //       content: Text(AppLocalization.of(context)!
              //           .youHaveReachedBottomOfTheList),
              //       duration: Duration(milliseconds: 500),
              //     ),
              //   );
              // });
            }
          }
          return contractListWidget(contractBloc);
        }
      },
    );
  }

  Widget contractListWidget(ContractBloc contractBloc) {
    return SmartRefresher(
      enablePullDown: true,
      header: WaterDropHeader(complete: Container(), waterDropColor: navyBlue),
      controller: _refreshController,
      onRefresh: _onRefresh,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 4),
        itemCount: contractBloc.contractList.length + 1,
        itemBuilder: (BuildContext context, int index) {
          if (index == contractBloc.contractList.length) {
            return buildIndicator(isLoading: contractBloc.isLoading);
          } else {
            Contract contract = contractBloc.contractList[index];
            return _getSlidableWithLists(
                context, ContractTile(contract: contract), index,
                contract: contract);
          }
        },
        controller: _scrollController,
      ),
    );
  }

  Widget _getSlidableWithLists(
      BuildContext context, Widget contractTile, int index,
      {required Contract contract}) {
    return Slidable(
      controller: _slideController,
      direction: Axis.horizontal,
      actionPane: SlidableBehindActionPane(),
      actionExtentRatio: 0.25,
      child: VerticalListItem(contractTile, contract),
      actions: listActionSlideActions(contract),
      secondaryActions: listSecondaryActions(index, contract),
    );
  }

  List<Widget> listSecondaryActions(int index, Contract contract) {
    // STOPPED = ("Stopped", _("Stopped"))
    // ENDED = ("Ended", _("Ended"))
    // ACTIVE = ("Active", _("Active"))
    // PAUSED = ("Paused", _("Paused"))

    return [
      SlideActionButton(
          backgroundColor: getSecondaryActionIconColor(contract),
          icon: getSecondaryActionIcon(contract),
          onTap: () {
            // _slideController.activeState.close();
            updateContractStatus(contract, getUpdateAction(contract));
          },
          title: getSecondaryActionTitle(contract),
          slideController: _slideController),
    ];
  }

  Color getSecondaryActionIconColor(Contract contract) {
    switch (contract.status) {
      case "Paused":
        return naturalGreen;
      case "Active":
        return starYellow;
      case "Stopped":
        return naturalGreen;
      case "Ended":
        return starYellow;
      default:
        return navyBlue;
    }
  }

  IconData getSecondaryActionIcon(Contract contract) {
    switch (contract.status) {
      case "Paused":
        return Icons.play_arrow_rounded;
      case "Active":
        return Icons.pause;
      case "Stopped":
        return Icons.play_arrow_rounded;
      case "Ended":
        return Icons.pause;
      default:
        return Icons.ac_unit;
    }
  }

  String getSecondaryActionTitle(Contract contract) {
    switch (contract.status) {
      case "Paused":
        return "Resume";
      case "Active":
        return "Pause";
      case "Stopped":
        return "Resume";
      case "Ended":
        return "Pause";
      default:
        return "";
    }
  }

  String getUpdateAction(Contract contract) {
    // Contract contract = contracts[index];
    switch (contract.status) {
      case "Paused":
        return "Active";

      case "Active":
        return "Paused";

      case "Stopped":
        return "Ended";

      case "Ended":
        return "Stopped";

      default:
        return "";
    }
  }

  void updateContractStatus(Contract contract, String action) {
    // Contract contract = contracts[index];
    Map<String, String> data = {"status": action};

    BusinessAuth()
        .updateContract(id: contract.id.toString(), data: data)
        .then((value) {
      contract.status = action;
      // contracts[index].status = action;
      contractBlocProvider.getContractList();
      showToast(message: "Status updated successfully");
    }).catchError((error) {
      showToast(message: "Status updated unsuccessfully");
    });
  }

  List<Widget> listActionSlideActions(Contract contract) {
    return [
      SlideActionButton(
          backgroundColor: mateRed,
          icon: Icons.stop_circle_outlined,
          onTap: () {
            updateContractStatus(contract, getUpdateAction(contract));
          },
          title: "Stop",
          slideController: _slideController),
    ];
  }

  void handleSlideAnimationChanged(Animation<double>? slideAnimation) {}

  void handleSlideIsOpenChanged(bool? isOpen) {}
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
