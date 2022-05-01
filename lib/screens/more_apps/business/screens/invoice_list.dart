import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/business/bloc/invoice_bloc.dart';
import 'package:Slydo/screens/more_apps/business/tiles/contract_and_invoice_tile.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/noItemInList.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../../data/state_notifier.dart';
import '../../../../routes/route_constants.dart';
import '../../../../widget/slide_action_button.dart';
import '../business_auth.dart';
import '../models/Invoice.dart';

/// You can delete this file.
class InvoiceList extends StatefulWidget {
  InvoiceList();
  @override
  _InvoiceListState createState() => _InvoiceListState();
}

class _InvoiceListState extends State<InvoiceList> {
  late UserBloc userBloc;
  ScrollController _scrollController = ScrollController();
  late InvoiceBloc invoiceBloc;
  SlidableController? _slideController;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    _slideController = SlidableController(
      onSlideAnimationChanged: handleSlideAnimationChanged,
      onSlideIsOpenChanged: handleSlideIsOpenChanged,
    );

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

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    invoiceBloc = Provider.of<InvoiceBloc>(context);

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
    print('INVOICE ::: ${invoice.status}');
    print('ACTION :: $action');
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
