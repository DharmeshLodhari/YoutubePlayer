import 'package:Slydo/data/state_notifiers/user_bloc.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/locator.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/business/bloc/invoice_bloc.dart';
import 'package:Slydo/screens/more_apps/business/business_auth.dart';
import 'package:Slydo/screens/more_apps/business/models/Invoice.dart';
import 'package:Slydo/screens/more_apps/business/tiles/contract_and_invoice_tile.dart';
import 'package:Slydo/services/app_config_bloc.dart';
import 'package:Slydo/utils/enums.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/customized_popup_menu.dart';
import 'package:Slydo/widget/no_item_in_list.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:Slydo/widget/slide_action_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class InvoiceScreen extends StatefulWidget {
  const InvoiceScreen({super.key});

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen>
    with SingleTickerProviderStateMixin {
  bool isSender = true;
  late UserBloc userBloc;
  bool isPopMenuOpen = false;
  late InvoiceBloc invoiceBloc;
  late CustomizedPopUpMenu menu;
  int selectedMenuItemIndex = 0;

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final GlobalKey _key = LabeledGlobalKey("myInvoiceList");

  final ScrollController _scrollController = ScrollController();
  AppConfigurationModel? appConfigurationModel;

  @override
  void initState() {
    appConfigurationModel = getIt<AppConfigurationBloc>().appConfigurationModel;

    Provider.of<InvoiceBloc>(context, listen: false).isSender = true;
    Provider.of<InvoiceBloc>(context, listen: false).isRefreshing = true;
    Provider.of<InvoiceBloc>(context, listen: false).getInvoiceList();

    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          _scrollController.position.pixels != 0) {
        invoiceBloc.getInvoiceList();
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
        "Invoice",
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
      activeThumbImage:
          const AssetImage('assets/images/invoice_outgoing_arrow.png'),
      inactiveThumbImage:
          const AssetImage('assets/images/invoice_incoming_arrow.png'),
      activeColor: Colors.grey.withOpacity(0.9),
      value: isSender,
      onChanged: (value) {
        if (!invoiceBloc.isLoading) {
          setState(() => isSender = value);
          selectedMenuItemIndex = 0;
          if (mounted) setState(() {});
          invoiceBloc.isRefreshing = true;
          invoiceBloc.isSender = value;
          invoiceBloc.getInvoiceList();
          if (value == true) {
            showSnackbar(context,
                message: 'These are your outgoing invoice', duration: 1000);
          } else {
            showSnackbar(context,
                message: 'These are your incoming invoice', duration: 1000);
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

    filterStatementForInvoicePage(value);
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
        final invoiceAdded =
            await Navigator.of(context).pushNamed(Routes.ADD_INVOICE);
        debugPrint('INVOICE ADDED ::: $invoiceAdded');

        if (invoiceAdded == true) {
          invoiceBloc.isRefreshing = true;
          invoiceBloc.getInvoiceList();
        }
      },
      backgroundColor: iconBtnGrey,
      enableMargin: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    invoiceBloc = Provider.of<InvoiceBloc>(context);

    menu = CustomizedPopUpMenu(
      buttonKey: _key,
      context: context,
      childList: [
        CustomizedPopUpMenuItem(title: "All", value: "All"),
        CustomizedPopUpMenuItem(title: "Paid", value: "Paid"),
        CustomizedPopUpMenuItem(title: "Drafts", value: "Draft"),
        CustomizedPopUpMenuItem(title: "Unpaid", value: "Unpaid"),
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

  void filterStatementForInvoicePage(String value) {
    invoiceBloc.noItemInList = false;
    invoiceBloc.isRefreshing = true;

    switch (value) {
      case "Draft":
        invoiceBloc.getInvoiceList(invoiceStatus: InvoiceStatus.Draft);
        break;

      case "Paid":
        invoiceBloc.getInvoiceList(invoiceStatus: InvoiceStatus.Paid);
        break;

      case "Unpaid":
        invoiceBloc.getInvoiceList(invoiceStatus: InvoiceStatus.Unpaid);
        break;

      default:
        invoiceBloc.getInvoiceList();
    }
  }

  Widget _scaffoldBody() {
    return Consumer<InvoiceBloc>(builder: (context, invoiceBloc, _) {
      return SmartRefresher(
        enablePullDown: true,
        header: WaterDropHeader(
          complete: Container(),
          waterDropColor: navyBlue,
        ),
        controller: _refreshController,
        onRefresh: _onRefresh,
        child: getConsumerChildWidget(invoiceBloc),
      );
    });
  }

  void _onRefresh() async {
    if (await checkConnection(context)) {
      invoiceBloc.isRefreshing = true;
      invoiceBloc.getInvoiceList();
      _refreshController.refreshCompleted();
    } else {
      _refreshController.refreshCompleted();
    }
  }

  Widget getConsumerChildWidget(InvoiceBloc invoiceBloc) {
    if (invoiceBloc.errorMessage.isNotEmpty) {
      return NoItemInList(
        msg: invoiceBloc.errorMessage,
      );
    } else if (invoiceBloc.noItemInList) {
      return NoItemInList(
        msg: AppLocalization.of(context)!.invoiceEmpty,
      );
    } else {
      if (invoiceBloc.endOfList && _scrollController.positions.isNotEmpty) {
        if (_scrollController.position.pixels ==
                _scrollController.position.maxScrollExtent &&
            _scrollController.position.pixels != 0) {
          Future.delayed(
            Duration.zero,
            () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                    AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
                duration: const Duration(milliseconds: 500),
              ));
            },
          );
        }
      }
      return invoiceListWidget(invoiceBloc);
    }
  }

  Widget invoiceListWidget(InvoiceBloc invoiceBloc) {
    return invoiceBloc.isLoading && invoiceBloc.invoiceList.isEmpty
        ? buildLoadingIndicator(isLoading: invoiceBloc.isLoading)
        : SlidableAutoCloseBehavior(
            closeWhenOpened: true,
            child: ListView.builder(
              padding: const EdgeInsets.all(4),
              itemCount: invoiceBloc.invoiceList.length + 1,
              itemBuilder: (BuildContext context, int index) {
                if (index == invoiceBloc.invoiceList.length) {
                  return buildJumpingLoadingIndicator(
                      isLoading: invoiceBloc.isLoading);
                } else {
                  final InvoiceModel invoice = invoiceBloc.invoiceList[index];

                  final bool canDeleteInvoice =
                      invoice.fromCustomer == userBloc.user.userName &&
                          invoice.status == "Draft";

                  final bool canPay =
                      invoice.fromCustomer != userBloc.user.userName &&
                          invoice.status == "Unpaid";

                  return Slidable(
                    startActionPane: canDeleteInvoice
                        ? ActionPane(
                            motion: const BehindMotion(),
                            extentRatio: 0.25,
                            children: [
                                SlideActionButton(
                                  borderRadius: BorderRadius.circular(5),
                                  backgroundColor: mateRed,
                                  icon: Icons.delete,
                                  onPressed: (con) => deleteInvoice(invoice),
                                  label: 'Delete',
                                ),
                              ])
                        : null,
                    endActionPane: invoice.status != "Paid" &&
                            invoice.amount! > 0
                        ? ActionPane(
                            motion: const BehindMotion(),
                            extentRatio: 0.25,
                            children: [
                                SlideActionButton(
                                  borderRadius: BorderRadius.circular(5),
                                  backgroundColor: getBgColor(invoice),
                                  icon: getIcon(invoice),
                                  onPressed: (con) => canPay
                                      ? _payInvoice(invoice)
                                      : updateInvoiceStatus(
                                          invoice, getUpdateAction(invoice)),
                                  label: canPay
                                      ? 'Pay'
                                      : getSlidableTitle(invoice),
                                )
                              ])
                        : null,
                    child: InvoiceTile(
                      invoice: invoice,
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          Routes.INVOICE_DETAIL,
                          arguments: {"id": invoice.id},
                        );
                      },
                    ),
                  );
                }
              },
              controller: _scrollController,
            ),
          );
  }

  String getSlidableTitle(InvoiceModel invoice) {
    switch (invoice.status) {
      case "Draft":
        return "Send";
      case "Unpaid":
        return "Mark as paid";
      default:
        return "";
    }
  }

  String getUpdateAction(InvoiceModel invoice) {
    switch (invoice.status) {
      case "Draft":
        return "Unpaid";

      case "Unpaid":
        return "Paid";

      default:
        return "";
    }
  }

  void updateInvoiceStatus(InvoiceModel invoice, String action) {
    if (invoice.status == "Unpaid") {
      // Current status of the invoice.
      BusinessAuth().markInvoiceAsPaid(invoiceId: invoice.id!).then((value) {
        // invoice.status = action;
        Provider.of<InvoiceBloc>(context, listen: false).isRefreshing = true;
        Provider.of<InvoiceBloc>(context, listen: false).getInvoiceList();
        showToast(message: "Status updated successfully");
      }).catchError((error) {
        showToast(message: "Status not updated");
      });
    } else {
      final Map<String, String> data = {"status": action};

      BusinessAuth()
          .updateInvoice(invoiceId: invoice.id.toString(), data: data)
          .then((value) {
        // invoice.status = action;
        Provider.of<InvoiceBloc>(context, listen: false).isRefreshing = true;
        Provider.of<InvoiceBloc>(context, listen: false).getInvoiceList();
        showToast(message: "Status updated successfully");
      }).catchError((error) {
        showToast(message: "Status not updated");
      });
    }
  }

  void _payInvoice(InvoiceModel invoice) {
    if (appConfigurationModel?.enablePayment == true) {
      BusinessAuth().payInvoice(invoiceId: invoice.id!).then(
        (value) {
          showToast(message: "Invoice Paid");
          Provider.of<InvoiceBloc>(context).getInvoiceList();
        },
      ).catchError(
        (e) {
          showToast(message: "Something went wrong, please try again.");
        },
      );
    } else {
      showToast(message: 'Payment not available at the moment');
    }
  }

  void deleteInvoice(InvoiceModel invoice) {
    BusinessAuth().deleteInvoice(invoiceId: invoice.id!).then((value) {
      // invoice.status = action;
      Provider.of<InvoiceBloc>(context, listen: false).isSender = true;
      Provider.of<InvoiceBloc>(context, listen: false).isRefreshing = true;
      Provider.of<InvoiceBloc>(context, listen: false).getInvoiceList();
      showToast(message: "Invoice deleted");
    }).catchError((error) {
      showToast(message: "Something went wrong, please try again.");
    });
  }

  Color getBgColor(InvoiceModel invoice) {
    switch (invoice.status) {
      case "Unpaid":
        return navyBlue;

      default:
        return Colors.green;
    }
  }

  IconData getIcon(InvoiceModel invoice) {
    switch (invoice.status) {
      case "Unpaid":
        return Icons.done;

      default:
        return Icons.send;
    }
  }
}
