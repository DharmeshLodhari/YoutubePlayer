import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/business/models/Contract.dart';
import 'package:Slydo/screens/more_apps/business/tiles/contract_and_invoice_tile.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:Slydo/widget/slide_action_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../../data/state_notifier.dart';
import '../../../../routes/route_constants.dart';
import '../../../../utils/enums.dart';
import '../../../../utils/slydo_app_icon_icons.dart';
import '../../../../widget/customized_popup_menu.dart';
import '../../../../widget/dialog.dart';
import '../../../../widget/no_item_in_list.dart';
import '../../../../widget/rounded_background_icon.dart';
import '../bloc/contract_bloc.dart';
import '../business_auth.dart';

class ContractScreen extends StatefulWidget {
  const ContractScreen({super.key});

  @override
  State<ContractScreen> createState() => _ContractScreenState();
}

class _ContractScreenState extends State<ContractScreen>
    with SingleTickerProviderStateMixin {
  late UserBloc userBloc;
  bool isContractor = true;
  bool isPopMenuOpen = false;
  int selectedMenuItemIndex = 0;
  late CustomizedPopUpMenu menu;
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final GlobalKey _key = LabeledGlobalKey("myContractList");

  final ScrollController _scrollController = ScrollController();

  late ContractBloc contractBloc;

  @override
  void initState() {
    super.initState();

    Provider.of<ContractBloc>(context, listen: false).isRefreshing = true;
    Provider.of<ContractBloc>(context, listen: false).isContractor = true;
    Provider.of<ContractBloc>(context, listen: false).getContractList();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          _scrollController.position.pixels != 0) {
        contractBloc.getContractList();
      }
    });
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  Widget appBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      titleSpacing: 0,
      automaticallyImplyLeading: false,
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
      title: Text(
        "Contracts",
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
        overflow: TextOverflow.fade,
        softWrap: false,
        maxLines: 1,
      ),
      actions: [
        appBarSwitch(),
        const SizedBox(width: 10.0),
        popUpMenuButton(),
        const SizedBox(width: 10.0),
        addContractButton(),
        const SizedBox(width: 16)
      ],
    );
  }

  Widget appBarSwitch() {
    return Switch(
      activeThumbImage: const AssetImage('assets/images/incoming_arrow.png'),
      inactiveThumbImage: const AssetImage('assets/images/outgoing_arrow.png'),
      activeColor: Colors.grey.withOpacity(0.9),
      value: isContractor,
      onChanged: (value) {
        if (!contractBloc.isLoading) {
          setState(() => isContractor = value);
          selectedMenuItemIndex = 0;
          if (mounted) setState(() {});
          contractBloc.isRefreshing = true;
          contractBloc.isContractor = value;
          contractBloc.getContractList();
          if (value == true) {
            showSnackbar(context,
                message: 'These are your incoming contracts', duration: 3000);
          } else {
            showSnackbar(context,
                message: 'These are your outgoing contracts', duration: 3000);
          }
        }
      },
    );
  }

  Widget popUpMenuButton() {
    return SizedBox(
      key: _key,
      height: 34,
      width: 34,
      child: Card(
        color: isPopMenuOpen ? navyBlue : iconBtnGrey,
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: IconButton(
          icon: Icon(
            Icons.filter_alt_rounded,
            color: isPopMenuOpen ? Colors.white : Colors.black,
            size: 20,
          ),
          onPressed: () {
            if (menu.isMenuOpen) {
              menu.closeMenu();
            } else {
              menu.openMenu();
            }
          },
        ),
      ),
    );
  }

  void menuItemSelectionChange(String value, int index) {
    selectedMenuItemIndex = index;
    setState(() {});
    filterSwitchStatementForContractPage(value);
  }

  void menuStateChange(bool isOpen) {
    isPopMenuOpen = isOpen;
    setState(() {});
  }

  Widget addContractButton() {
    return RoundedBackgroundIcon(
      height: 34,
      width: 34,
      icon: Icon(
        SlydoAppIcon.add,
        size: 16,
        color: blackFont,
      ),
      onTap: () async {
        final contractAdded =
            await Navigator.of(context).pushNamed(Routes.ADD_CONTRACT);

        if (contractAdded == true) {
          contractBloc.isRefreshing = true;
          contractBloc.getContractList();
        }
      },
      backgroundColor: iconBtnGrey,
      enableMargin: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    contractBloc = Provider.of<ContractBloc>(context);

    menu = CustomizedPopUpMenu(
      buttonKey: _key,
      context: context,
      childList: [
        CustomizedPopUpMenuItem(title: "All", value: "All"),
        CustomizedPopUpMenuItem(title: "Ended", value: "Ended"),
        CustomizedPopUpMenuItem(title: "Active", value: "Active"),
        CustomizedPopUpMenuItem(title: "Paused", value: "Paused"),
      ],
      right: 16,
      selectedIndex: selectedMenuItemIndex,
    );
    menu.onChange = menuItemSelectionChange;
    menu.menuState = menuStateChange;

    return PopScope(
      onPopInvoked: (didPop) async {
        if (didPop) {
          return;
        }
      },
      child: Scaffold(
        appBar: appBar() as PreferredSizeWidget?,
        backgroundColor: Colors.white,
        body: _scaffoldBody(),
      ),
    );
  }

  void filterSwitchStatementForContractPage(String value) {
    contractBloc.noItemInList = false;
    contractBloc.isRefreshing = true;

    switch (value) {
      case "Ended":
        contractBloc.getContractList(contractStatus: ContractStatus.Ended);
        break;

      case "Active":
        contractBloc.getContractList(contractStatus: ContractStatus.Active);
        break;

      case "Paused":
        contractBloc.getContractList(contractStatus: ContractStatus.Paused);
        break;

      case "All":
        contractBloc.getContractList();
        break;

      default:
        contractBloc.getContractList();
    }
  }

  void _onRefresh() async {
    if (await checkConnection(context)) {
      contractBloc.isRefreshing = true;
      contractBloc.getContractList();
      _refreshController.refreshCompleted();
    } else {
      _refreshController.refreshCompleted();
    }
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
          if (contractBloc.endOfList &&
              _scrollController.positions.isNotEmpty) {
            if (_scrollController.position.pixels ==
                    _scrollController.position.maxScrollExtent &&
                _scrollController.position.pixels != 0) {
              Future.delayed(
                Duration.zero,
                () {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(AppLocalization.of(context)!
                        .youHaveReachedBottomOfTheList),
                    duration: const Duration(milliseconds: 500),
                  ));
                },
              );
            }
          }
          return contractListWidget(contractBloc);
        }
      },
    );
  }

  Widget contractListWidget(ContractBloc contractBloc) {
    return contractBloc.isLoading && contractBloc.contractList.isEmpty
        ? buildLoadingIndicator(isLoading: contractBloc.isLoading)
        : SmartRefresher(
            enablePullDown: true,
            header: WaterDropHeader(
                complete: Container(), waterDropColor: navyBlue),
            controller: _refreshController,
            onRefresh: _onRefresh,
            child: SlidableAutoCloseBehavior(
              closeWhenOpened: true,
              child: ListView.builder(
                padding: const EdgeInsets.all(4),
                itemCount: contractBloc.contractList.length + 1,
                itemBuilder: (BuildContext context, int index) {
                  if (index == contractBloc.contractList.length) {
                    return buildJumpingLoadingIndicator(
                        isLoading: contractBloc.isLoading);
                  } else {
                    final ContractModel contract =
                        contractBloc.contractList[index];
                    final bool userIsContractor =
                        userBloc.user.userName == contract.contractor;

                    final bool isNotSlidable = contract.status == "Ended" ||
                        contract.status == "Stopped" ||
                        (!contract.isAccepted && !userIsContractor);

                    if (!contract.isAccepted) {
                      final String actionText =
                          userIsContractor ? ' Reject' : 'Cancel';
                      return Slidable(
                        startActionPane: ActionPane(
                          motion: const BehindMotion(),
                          extentRatio: 0.25,
                          children: [
                            SlideActionButton(
                              borderRadius: BorderRadius.circular(5),
                              backgroundColor: mateRed,
                              icon: Icons.stop_circle_outlined,
                              onPressed: (con) {
                                showDialogBox(
                                  context: context,
                                  actionOneTextColor: blackFont,
                                  actionOneBgColor: greyBorderColor,
                                  actionTwoTextColor: white,
                                  actionTwoBgColor: mateRed,
                                  title: '$actionText contract',
                                  actionTwoText:
                                      AppLocalization.of(context)!.yes,
                                  actionOneText:
                                      AppLocalization.of(context)!.no,
                                  description:
                                      'Are you sure you want to ${actionText.toLowerCase()} this contract?',
                                  roundedBackgroundIcon: RoundedBackgroundIcon(
                                    enableMargin: false,
                                    width: 90,
                                    height: 90,
                                    image: const Icon(SlydoAppIcon.remove),
                                  ),
                                  rightButtonOnPressed: () {
                                    cancelOrRejectContract(id: contract.id!);
                                  },
                                );
                              },
                              label: userIsContractor ? 'Reject' : "Cancel",
                            ),
                          ],
                        ),
                        endActionPane: userIsContractor
                            ? ActionPane(
                                motion: const BehindMotion(),
                                extentRatio: 0.25,
                                children: [
                                  SlideActionButton(
                                    borderRadius: BorderRadius.circular(5),
                                    backgroundColor: naturalGreen,
                                    icon: Icons.stop_circle_outlined,
                                    onPressed: (con) {
                                      showDialogBox(
                                        context: context,
                                        actionOneTextColor: blackFont,
                                        actionTwoBgColor: naturalGreen,
                                        actionTwoTextColor: Colors.white,
                                        actionOneBgColor: greyBorderColor,
                                        title: 'Accept contract',
                                        actionTwoText:
                                            AppLocalization.of(context)!.accept,
                                        actionOneText:
                                            AppLocalization.of(context)!.no,
                                        description:
                                            'Are you sure you want to accept this contract?',
                                        roundedBackgroundIcon:
                                            RoundedBackgroundIcon(
                                          enableMargin: false,
                                          width: 90,
                                          height: 90,
                                          image:
                                              const Icon(SlydoAppIcon.remove),
                                        ),
                                        rightButtonOnPressed: () {
                                          acceptContract(id: contract.id!);
                                        },
                                      );
                                    },
                                    label: "Accept",
                                  ),
                                ],
                              )
                            : null,
                        child: ContractTile(contract: contract),
                      );
                    } else if (isNotSlidable) {
                      return ContractTile(contract: contract);
                    }
                    return _getSlidableWithLists(
                        context, ContractTile(contract: contract), index,
                        contract: contract);
                  }
                },
                controller: _scrollController,
              ),
            ),
          );
  }

  Widget _getSlidableWithLists(
      BuildContext context, Widget contractTile, int index,
      {required ContractModel contract}) {
    return Slidable(
      startActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.25,
        children: listActionSlideActions(contract),
      ),
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.25,
        children: listSecondaryActions(index, contract),
      ),
      child: VerticalListItem(contractTile, contract),
    );
  }

  List<Widget> listSecondaryActions(int index, ContractModel contract) {
    return [
      SlideActionButton(
        borderRadius: BorderRadius.circular(5),
        backgroundColor: getSecondaryActionIconColor(contract),
        icon: getSecondaryActionIcon(contract),
        onPressed: (con) {
          updateContractStatus(contract, getUpdateAction(contract));
        },
        label: getSecondaryActionTitle(contract),
      ),
    ];
  }

  Color getSecondaryActionIconColor(ContractModel contract) {
    switch (contract.status) {
      case "Paused":
        return naturalGreen;
      case "Active":
        return starYellow;

      case "Ended":
        return starYellow;
      default:
        return navyBlue;
    }
  }

  IconData getSecondaryActionIcon(ContractModel contract) {
    switch (contract.status) {
      case "Paused":
        return Icons.play_arrow_rounded;
      case "Active":
        return Icons.pause;

      case "Ended":
        return Icons.pause;
      default:
        return Icons.ac_unit;
    }
  }

  String getSecondaryActionTitle(ContractModel contract) {
    switch (contract.status) {
      case "Paused":
        return "Resume";
      case "Active":
        return "Pause";
      default:
        return "Active";
    }
  }

  String getUpdateAction(ContractModel contract) {
    switch (contract.status) {
      case "Paused":
        return "Active";

      case "Active":
        return "Paused";

      default:
        return "Active";
    }
  }

  void updateContractStatus(ContractModel contract, String action) {
    final Map<String, String> data = {"status": action};

    BusinessAuth()
        .updateContract(id: contract.id.toString(), data: data)
        .then((value) {
      contract.status = action;
      contractBloc.getContractList();
      showToast(message: "Status updated successfully");
    }).catchError((error) {
      showToast(message: "Status updated unsuccessfully");
    });
  }

  List<Widget> listActionSlideActions(ContractModel contract) {
    return [
      SlideActionButton(
        borderRadius: BorderRadius.circular(5),
        backgroundColor: mateRed,
        icon: Icons.stop_circle_outlined,
        onPressed: (con) {
          showDialogBox(
            context: context,
            actionOneBgColor: greyBorderColor,
            actionOneTextColor: blackFont,
            actionTwoBgColor: naturalGreen,
            actionTwoTextColor: Colors.white,
            title: 'End contract',
            actionTwoText: AppLocalization.of(context)!.yes,
            actionOneText: AppLocalization.of(context)!.no,
            description: 'Are you sure you want to end this contract?',
            roundedBackgroundIcon: RoundedBackgroundIcon(
              enableMargin: false,
              width: 90,
              height: 90,
              image: const Icon(SlydoAppIcon.remove),
            ),
            rightButtonOnPressed: () {
              updateContractStatus(contract, 'Ended');
            },
          );
        },
        label: "End",
      ),
    ];
  }

  void acceptContract({required int id}) async {
    showDialog(
        context: context,
        builder: (dialogLoadingContext) => LoadingIndicator());
    final bool accepted = await BusinessAuth().acceptContract(contractId: id);
    Navigator.pop(context);
    if (accepted) {
      contractBloc.getContractList();
    } else {
      showToast(message: 'Something went wrong, please try again.');
    }
  }

  void cancelOrRejectContract({required int id}) async {
    showDialog(
        context: context,
        builder: (dialogLoadingContext) => LoadingIndicator());
    final bool accepted =
        await BusinessAuth().cancelOrRejectContract(contractId: id);
    Navigator.pop(context);
    if (accepted) {
      contractBloc.isRefreshing = true;

      contractBloc.getContractList();
    } else {
      showToast(message: 'Something went wrong, please try again.');
    }
  }
}

class VerticalListItem extends StatelessWidget {
  const VerticalListItem(this.child, this.contract, {super.key});

  final Widget child;
  final ContractModel contract;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .pushNamed(Routes.CONTRACT_DETAIL, arguments: {"id": contract.id});
      },
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: child,
      ),
    );
  }
}
