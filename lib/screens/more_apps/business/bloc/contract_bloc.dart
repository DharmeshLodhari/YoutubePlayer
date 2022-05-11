import 'package:Slydo/screens/more_apps/business/business_auth.dart';
import 'package:flutter/material.dart';

import '../../../../utils/enums.dart';
import '../models/Contract.dart';
import '../models/Invoice.dart';

class ContractBloc extends ChangeNotifier {
  bool endOfList = false;
  bool _isLoading = false;
  bool noItemInList = false;
  bool isContractor = true;
  bool get isLoading => _isLoading;
  BusinessAuth businessAuth = BusinessAuth();

  int? count = 0;
  String? next = "";
  bool isFirstTime = true;
  String errorMessage = "";
  bool isRefreshing = false;
  List<ContractModel> contractList = [];

  Future<List<ContractModel>?> getContractList(
      {ContractStatus? contractStatus}) async {
    if (isRefreshing) {
      count = 0;
      next = "";
      endOfList = false;
      contractList = [];
      isFirstTime = true;
      noItemInList = false;
    }
    isRefreshing = false;

    if (!isLoading) {
      if (next != null && !isLoading) {
        _isLoading = true;
        notifyListeners();

        debugPrint('IS CONTRACTOR ::: $isContractor');
        Map<String, dynamic>? result = await businessAuth.getContractList(
          next,
          isContractor: isContractor,
          contractStatus: contractStatus,
        );

        if (result!.containsKey('detail')) {
          errorMessage = result['detail'];
          notifyListeners();
          return null;
        }

        next = result['next'];
        count = result['count'];
        var tempList = result['results'];

        _isLoading = false;
        contractList.addAll(tempList);
        notifyListeners();

        print('CONTRACT LENGTH :: ${contractList.length}');

        if (isFirstTime && next != null && next != "") {
          print('NEXT :::: $next');
          isFirstTime = false;
          getContractList(contractStatus: contractStatus);
        }
      }

      if (contractList.isEmpty) {
        noItemInList = true;

        notifyListeners();
      } else if (next == null) {
        endOfList = true;
        notifyListeners();
      }
    }
    return contractList;
  }
}
