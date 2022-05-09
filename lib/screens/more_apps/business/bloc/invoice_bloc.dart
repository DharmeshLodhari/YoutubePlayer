import 'package:Slydo/screens/more_apps/business/business_auth.dart';
import 'package:flutter/material.dart';

import '../../../../utils/enums.dart';
import '../models/Invoice.dart';

class InvoiceBloc extends ChangeNotifier {
  bool endOfList = false;
  bool _isLoading = false;
  bool noItemInList = false;
  bool invoiceIsSwitched = true;
  bool get isLoading => _isLoading;
  BusinessAuth businessAuth = BusinessAuth();

  int? count = 0;
  String? next = "";
  String? previous = "";
  bool isFirstTime = true;
  String errorMessage = "";
  bool isRefreshing = false;
  List<InvoiceModel> invoiceList = [];

  Future<List<InvoiceModel>?> getInvoiceList(
      {InvoiceStatus? invoiceStatus}) async {
    if (isRefreshing) {
      count = 0;
      next = "";
      invoiceList = [];
      endOfList = false;
      isFirstTime = true;
      noItemInList = false;
    }
    isRefreshing = false;

    if (!isLoading) {
      if (next != null && !isLoading) {
        _isLoading = true;
        notifyListeners();
        print('GET INVOICE LIST');

        Map<String, dynamic>? result = await businessAuth.getInvoiceList(
          next,
          previous,
          isSender: invoiceIsSwitched,
          invoiceStatus: invoiceStatus,
        );

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
        noItemInList = true;
        notifyListeners();
      } else if (next == null) {
        endOfList = true;
        notifyListeners();
      }
    }
    return invoiceList;
  }
}
