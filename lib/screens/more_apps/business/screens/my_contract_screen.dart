import 'package:Slydo/screens/more_apps/business/bloc/invoice_bloc.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/enums.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/widget/customized_popup_menu.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../bloc/contract_bloc.dart';
import 'invoice_list.dart';
import 'my_contract_list.dart';

class MyContractScreen extends StatefulWidget {
  @override
  _MyContractScreenState createState() => _MyContractScreenState();
}

class _MyContractScreenState extends State<MyContractScreen> {
  int currentIndex = 0;

  GlobalKey _key = LabeledGlobalKey("myInvoiceList");
  late CustomizedPopUpMenu menu;
  int selectedMenuItemIndex = 0;
  bool isPopMenuOpen = false;

  late InvoiceBloc invoiceBloc;
  late ContractBloc contractBloc;

  void menuItemSelectionChange(String value, int index) {
    selectedMenuItemIndex = index;
    setState(() {});

    if (currentIndex == 0) {
      switchStatementForContractPage(value);
    } else {
      switchStatementForInvoicePage(value);
    }
  }

  switchStatementForInvoicePage(String value) {
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
      case "Pending":
        invoiceBloc.getInvoiceList(invoiceStatus: InvoiceStatus.Pending);
        break;

      default:
        invoiceBloc.getInvoiceList();
    }
  }

  switchStatementForContractPage(String value) {
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
      case "Stopped":
        contractBloc.getContractList(contractStatus: ContractStatus.Stopped);
        break;

      default:
        contractBloc.getContractList();
    }
  }

  void menuStateChange(bool isOpen) {
    isPopMenuOpen = isOpen;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    invoiceBloc = Provider.of<InvoiceBloc>(context, listen: false);
    contractBloc = Provider.of<ContractBloc>(context, listen: false);
    menu = CustomizedPopUpMenu(
      buttonKey: _key,
      context: context,
      children: currentIndex == 0
          ? [
              CustomizedPopUpMenuItem(title: "Ended", value: "Ended"),
              CustomizedPopUpMenuItem(title: "Active", value: "Active"),
              CustomizedPopUpMenuItem(title: "Paused", value: "Paused"),
              CustomizedPopUpMenuItem(title: "Stopped", value: "Stopped"),
            ]
          : [
              CustomizedPopUpMenuItem(title: "All", value: "All"),
              CustomizedPopUpMenuItem(title: "Paid", value: "Paid"),
              CustomizedPopUpMenuItem(title: "Drafts", value: "Draft"),
              CustomizedPopUpMenuItem(title: "Unpaid", value: "Unpaid"),
              CustomizedPopUpMenuItem(title: "Pending", value: "Pending"),
            ],
      selectedIndex: selectedMenuItemIndex,
      right: 16,
    );
    menu.onChange = menuItemSelectionChange;
    menu.menuState = menuStateChange;
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: appBar() as PreferredSizeWidget?,
          body: tabViews(),
        ),
      ),
    );
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
        "My contracts",
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
        overflow: TextOverflow.fade,
        softWrap: false,
        maxLines: 1,
      ),
      bottom: tabBar() as PreferredSizeWidget?,
      actions: [
        addContractAndInvoiceButton(),
        SizedBox(width: 10.0),
        popUpMenuButton(),
        SizedBox(width: 16)
      ],
    );
  }

  Widget addContractAndInvoiceButton() {
    return RoundedBackgroundIcon(
      height: 34,
      width: 34,
      icon: Icon(
        SlydoAppIcon.add,
        size: 16,
        color: blackFont,
      ),
      onTap: () {
        if (currentIndex == 0) {
          Navigator.of(context).pushNamed("/add-contract");
        } else if (currentIndex == 1) {
          Navigator.of(context).pushNamed("/add-invoice");
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

  Widget tabBar() {
    return PreferredSize(
      preferredSize: Size.fromHeight(50.0),
      child: TabBar(
        labelPadding: EdgeInsets.zero,
        indicator: BoxDecoration(),
        onTap: (int index) {
          currentIndex = index;
          setState(() {});
        },
        tabs: [
          Tab(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                shape: BoxShape.rectangle,
                color: currentIndex == 0
                    ? navyBlue.withOpacity(0.1)
                    : Colors.white,
              ),
              child: Text(
                "My Contracts",
                style: TextStyle(
                  color: currentIndex == 0 ? navyBlue : blackFont,
                  fontSize: 14,
                  fontWeight:
                      currentIndex == 0 ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ),
          Tab(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                shape: BoxShape.rectangle,
                color: currentIndex == 1
                    ? navyBlue.withOpacity(0.1)
                    : Colors.white,
              ),
              child: Text(
                "Invoices",
                style: TextStyle(
                  color: currentIndex == 1 ? navyBlue : blackFont,
                  fontSize: 14,
                  fontWeight:
                      currentIndex == 1 ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget tabViews() {
    return IndexedStack(
      index: currentIndex,
      children: [
        MyContractList(),
        InvoiceList(),
      ],
    );
  }
}
