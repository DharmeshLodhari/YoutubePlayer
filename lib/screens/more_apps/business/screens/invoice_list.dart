import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/business/bloc/invoice_bloc.dart';
import 'package:Slydo/screens/more_apps/business/tiles/contract_and_invoice_tile.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/noItemInList.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../../routes/route_constants.dart';
import '../../../../utils/enums.dart';
import '../business_auth.dart';
import '../models/Invoice.dart';

class InvoiceList extends StatefulWidget {
  InvoiceList();
  @override
  _InvoiceListState createState() => _InvoiceListState();
}

class _InvoiceListState extends State<InvoiceList> {
  ScrollController _scrollController = ScrollController();
  late InvoiceBloc invoiceBloc;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
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
          Invoice invoice = invoiceBloc.invoiceList[index];
          return InvoiceTile(
            invoice: invoice,
            onTap: () {
              Navigator.of(context).pushNamed(Routes.INVOICE_DETAIL,
                  arguments: {"id": invoice.id});
            },
          );
        }
      },
      controller: _scrollController,
    );
  }
}
