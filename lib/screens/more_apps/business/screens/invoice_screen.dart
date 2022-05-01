import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../../data/state_notifier.dart';
import '../../../../locale/app_localization.dart';
import '../../../../routes/route_constants.dart';
import '../../../../utils/enums.dart';
import '../../../../utils/slydo_app_icon_icons.dart';
import '../../../../utils/util.dart';
import '../../../../widget/customized_popup_menu.dart';
import '../../../../widget/noItemInList.dart';
import '../../../../widget/rounded_background_icon.dart';
import '../../../../widget/slide_action_button.dart';
import '../bloc/invoice_bloc.dart';
import '../business_auth.dart';
import '../models/Invoice.dart';
import '../tiles/contract_and_invoice_tile.dart';

class InvoiceScreen extends StatefulWidget {
  const InvoiceScreen({Key? key}) : super(key: key);

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  late UserBloc userBloc;
  bool isPopMenuOpen = false;
  late InvoiceBloc invoiceBloc;
  late CustomizedPopUpMenu menu;
  bool contractIsSwitched = true;
  int selectedMenuItemIndex = 0;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  GlobalKey _key = LabeledGlobalKey("myInvoiceList");

  SlidableController? _slideController;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    _slideController = SlidableController(
      onSlideAnimationChanged: handleSlideAnimationChanged,
      onSlideIsOpenChanged: handleSlideIsOpenChanged,
    );

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
        SizedBox(width: 10.0),
        addContractButton(),
        SizedBox(width: 10.0),
        popUpMenuButton(),
        SizedBox(width: 16)
      ],
    );
  }

  Widget appBarSwitch() {
    return Switch(
      activeThumbImage: AssetImage(
        'assets/images/outgoing_arrow.png',
      ),
      inactiveThumbImage: AssetImage('assets/images/incoming_arrow.png'),
      activeColor: Colors.black.withOpacity(0.8),
      thumbColor: MaterialStateColor.resolveWith((states) => blackFont),
      value: contractIsSwitched,
      onChanged: (value) {
        setState(() => contractIsSwitched = value);
        invoiceBloc.isRefreshing = true;
        invoiceBloc.invoiceIsSwitched = value;
        invoiceBloc.getInvoiceList();
        if (value == true) {
          showSnackbar(context,
              message: 'These are your outgoing invoice', duration: 1000);
        } else {
          showSnackbar(context,
              message: 'These are your incoming invoice', duration: 1000);
        }
      },
    );
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
        var invoiceAdded =
            await Navigator.of(context).pushNamed(Routes.ADD_INVOICE);
        print('INVOICE ADDED ::: $invoiceAdded');

        if (invoiceAdded == true) {
          invoiceBloc.isRefreshing = true;
          invoiceBloc.getInvoiceList();
        }
      },
      backgroundColor: iconBtnGrey,
      enableMargin: true,
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
        margin: EdgeInsets.symmetric(vertical: 10),
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

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    invoiceBloc = Provider.of<InvoiceBloc>(context);

    menu = CustomizedPopUpMenu(
      buttonKey: _key,
      context: context,
      children: [
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

    return WillPopScope(
      onWillPop: () async {
        return Future.value(true);
      },
      child: Scaffold(
        appBar: appBar() as PreferredSizeWidget?,
        backgroundColor: Colors.white,
        body: _scaffoldBody(),
      ),
    );
  }

  filterStatementForInvoicePage(String value) {
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
    Connectivity().checkConnectivity().then((value) {
      var connectionResult = value;
      if (connectionResult == ConnectivityResult.wifi ||
          connectionResult == ConnectivityResult.mobile) {
        invoiceBloc.isRefreshing = true;
        invoiceBloc.getInvoiceList();
        _refreshController.refreshCompleted();
      } else {
        showToast(
            message:
                AppLocalization.of(context)!.internetConnectionNotAvailable);

        _refreshController.refreshCompleted();
      }
    });
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
                duration: Duration(milliseconds: 500),
              ));
            },
          );
        }
      }
      return invoiceListWidget(invoiceBloc);
    }
  }

  Widget invoiceListWidget(InvoiceBloc invoiceBloc) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 4),
      itemCount: invoiceBloc.invoiceList.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == invoiceBloc.invoiceList.length) {
          return buildIndicator(isLoading: invoiceBloc.isLoading);
        } else {
          InvoiceModel invoice = invoiceBloc.invoiceList[index];

          bool canDeleteInvoice =
              invoice.fromCustomer == userBloc.user.userName &&
                  invoice.status != "Paid";

          bool canPay = invoice.fromCustomer != userBloc.user.userName &&
              invoice.status == "Unpaid";

          return Slidable(
            controller: _slideController,
            direction: Axis.horizontal,
            actionPane: SlidableBehindActionPane(),
            actionExtentRatio: 0.25,
            child: InvoiceTile(
              invoice: invoice,
              onTap: () {
                Navigator.of(context).pushNamed(
                  Routes.INVOICE_DETAIL,
                  arguments: {"id": invoice.id},
                );
              },
            ),
            actions: canDeleteInvoice
                ? [
                    SlideActionButton(
                        backgroundColor: mateRed,
                        icon: Icons.delete,
                        onTap: () => deleteInvoice(invoice),
                        title: 'Delete',
                        slideController: _slideController),
                  ]
                : null,
            secondaryActions: invoice.status != "Paid"
                ? [
                    SlideActionButton(
                        backgroundColor: getBgColor(invoice),
                        icon: getIcon(invoice),
                        onTap: () => canPay
                            ? _payInvoice(invoice)
                            : updateInvoiceStatus(
                                invoice, getUpdateAction(invoice)),
                        title: canPay ? 'Pay' : getSlidableTitle(invoice),
                        slideController: _slideController)
                  ]
                : null,
          );
        }
      },
      controller: _scrollController,
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
      BusinessAuth().markInvoiceAsPaid(invoiceId: invoice.id!).then((value) {
        // invoice.status = action;
        Provider.of<InvoiceBloc>(context, listen: false).isRefreshing = true;
        Provider.of<InvoiceBloc>(context, listen: false).getInvoiceList();
        showToast(message: "Status updated successfully");
      }).catchError((error) {
        showToast(message: "Status not updated");
      });
    }
    Map<String, String> data = {"status": action};

    BusinessAuth()
        .updateInvoice(id: invoice.id.toString(), data: data)
        .then((value) {
      // invoice.status = action;
      Provider.of<InvoiceBloc>(context, listen: false).isRefreshing = true;
      Provider.of<InvoiceBloc>(context, listen: false).getInvoiceList();
      showToast(message: "Status updated successfully");
    }).catchError((error) {
      showToast(message: "Status not updated");
    });
  }

  void handleSlideAnimationChanged(Animation<double>? slideAnimation) {}

  void handleSlideIsOpenChanged(bool? isOpen) {}

  void _payInvoice(InvoiceModel invoice) {
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
  }

  void deleteInvoice(InvoiceModel invoice) {
    BusinessAuth().deleteInvoice(invoiceId: invoice.id!).then((value) {
      // invoice.status = action;
      Provider.of<InvoiceBloc>(context, listen: false).getInvoiceList();
      showToast(message: "Invoice deleted");
    }).catchError((error) {
      showToast(message: "Something went wrong, please try again.");
    });
  }

  Color getBgColor(InvoiceModel invoice) {
    switch (invoice.status) {
      case "Unpaid":
        return Colors.green;

      default:
        return navyBlue;
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
