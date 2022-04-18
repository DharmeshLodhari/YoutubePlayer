import 'package:Slydo/screens/more_apps/business/business_auth.dart';
import 'package:flutter/material.dart';

import '../../../../utils/enums.dart';
import '../models/Invoice.dart';

class InvoiceBloc extends ChangeNotifier {
  bool endOfList = false;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  BusinessAuth businessAuth = BusinessAuth();

  int? count = 0;
  String? next = "";
  String? previous = "";
  bool isFirstTime = true;
  List<Invoice> invoiceList = [];
  bool isRefreshing = false;
  String errorMessage = "";

  Future<List<Invoice>?> getInvoiceList({InvoiceStatus? invoiceStatus}) async {
    if (isRefreshing) {
      count = 0;
      next = "";
      previous = "";
      invoiceList = [];
      isFirstTime = true;
      _isLoading = false;
    }

    if (!isLoading) {
      if (next != null && !isLoading) {
        _isLoading = true;
        notifyListeners();

        Map<String, dynamic>? result = await businessAuth
            .getInvoiceList(next, previous, invoiceStatus: invoiceStatus);

        if (result!.containsKey('detail')) {
          errorMessage = result['detail'];
          notifyListeners();
          return null;
        }
        next = result['next'];
        count = result['count'];
        previous = result['previous'];
        var tempList = result['results'];

        _isLoading = false;
        invoiceList.addAll(tempList);
        notifyListeners();

        if (isFirstTime && next != null && next != "") {
          isFirstTime = false;
          getInvoiceList(invoiceStatus: invoiceStatus);
        }
      }
      if (invoiceList.isEmpty) {
        notifyListeners();
      } else if (next == null && invoiceList.length > 6) {
        endOfList = true;
        notifyListeners();
      }
    }
    return invoiceList;
  }

  // void getList() async {
  //   if (!isLoading) {
  //     if (next != null && !isLoading) {
  //       if (mounted) {
  //         setState(() {
  //           isLoading = true;
  //         });
  //       }
  //       Map<String, dynamic>? result =
  //       await _auth.getTransactions(next, previous, moneyIn, moneyOut);
  //       if (result == null) {
  //         isLoading = false;
  //         return;
  //       }
  //       count = result['count'];
  //       next = result['next'];
  //       previous = result['previous'];
  //       var tempList = result['results'];
  //
  //       isLoading = false;
  //       transactionList.addAll(tempList);
  //
  //       if (mounted) setState(() {});
  //
  //       if (isFirstTime && next != null && next != "") {
  //         isFirstTime = false;
  //         getList();
  //       }
  //     }
  //     if (transactionList.isEmpty) {
  //       noItemInList = true;
  //
  //       if (mounted) setState(() {});
  //     } else if (next == null && transactionList.length > 6) {
  //       showReachedToBottomSnackBar();
  //     }
  //   }
  // }

}
