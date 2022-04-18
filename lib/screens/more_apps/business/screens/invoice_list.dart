import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/business/bloc/invoice_bloc.dart';
import 'package:Slydo/screens/more_apps/business/tiles/contract_tile.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/noItemInList.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

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
  late InvoiceBloc contractAndInvoiceBlocProvider;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();

    Provider.of<InvoiceBloc>(context, listen: false).getInvoiceList();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          _scrollController.position.pixels != 0) {
        Provider.of<InvoiceBloc>(context, listen: false).getInvoiceList();
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
        contractAndInvoiceBlocProvider.isRefreshing = true;
        contractAndInvoiceBlocProvider.getInvoiceList();
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
    contractAndInvoiceBlocProvider = Provider.of<InvoiceBloc>(context);

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
    return Consumer<InvoiceBloc>(
      builder: (context, invoiceBloc, _) {
        if (invoiceBloc.isLoading) {
          return Center(
            child: CircularLoadingIndicator(),
          );
        } else if (invoiceBloc.errorMessage.isNotEmpty) {
          return NoItemInList(
            msg: invoiceBloc.errorMessage,
          );
        } else if (invoiceBloc.invoiceList.isEmpty) {
          return NoItemInList(
            msg: AppLocalization.of(context)!.invoiceEmpty,
          );
        } else {
          if (contractAndInvoiceBlocProvider.endOfList) {
            if (_scrollController.position.pixels ==
                    _scrollController.position.maxScrollExtent &&
                _scrollController.position.pixels != 0) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                    AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
                duration: Duration(milliseconds: 500),
              ));
              contractAndInvoiceBlocProvider.endOfList = false;
            }
          }
          return invoiceListWidget(invoiceBloc);
        }
      },
    );
  }

  Widget invoiceListWidget(InvoiceBloc invoiceBloc) {
    return SmartRefresher(
      enablePullDown: true,
      header: WaterDropHeader(
        complete: Container(),
        waterDropColor: navyBlue,
      ),
      controller: _refreshController,
      onRefresh: _onRefresh,
      child: ListView.builder(
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
                Navigator.of(context).pushNamed("/invoice-detail",
                    arguments: {"id": invoice.id});
              },
            );
          }
        },
        controller: _scrollController,
      ),
    );
  }
}
