import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/business/tiles/contract_tile.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../business_auth.dart';
import '../models/Invoice.dart';

class InvoiceList extends StatefulWidget {
  @override
  _InvoiceListState createState() => _InvoiceListState();
}

class _InvoiceListState extends State<InvoiceList> {
  List<Invoice> invoiceList = [];

  bool isLoading = false;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    getResult("Invoice List");
    super.initState();
  }

  void getResult(String item) async {
    isLoading = true;
    invoiceList.clear();
    if (mounted) {
      setState(() {});
    }

    invoiceList = await BusinessAuth().getInvoiceList();

    isLoading = false;
    if (mounted) {
      setState(() {});
    }
  }

  void _onRefresh() async {
    Connectivity().checkConnectivity().then((value) {
      var connectionResult = value;
      if (connectionResult == ConnectivityResult.wifi ||
          connectionResult == ConnectivityResult.mobile) {
        getResult("");
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
    return WillPopScope(
      onWillPop: () async {
        return Future.value(true);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: isLoading
            ? Center(
                child: CircularLoadingIndicator(),
              )
            : SmartRefresher(
                enablePullDown: true,
                header: WaterDropHeader(
                  complete: Container(),
                  waterDropColor: navyBlue,
                ),
                controller: _refreshController,
                onRefresh: _onRefresh,
                child: SingleChildScrollView(
                  child: Column(
                    children: invoiceList
                        .map(
                          (element) => GestureDetector(
                            child: InvoiceTile(
                              invoice: element,
                              onTap: () {
                                Navigator.of(context).pushNamed(
                                    "/invoice-detail",
                                    arguments: {"id": element.id});
                              },
                            ),
                            onTap: () {
                              Navigator.of(context).pushNamed("/invoice-detail",
                                  arguments: {"id": element.id});
                            },
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
      ),
    );
  }
}
