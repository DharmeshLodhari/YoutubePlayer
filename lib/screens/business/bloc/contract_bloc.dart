import 'package:Slydo/screens/business/business_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../../utils/enums.dart';
import '../models/contract_model.dart';

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

        final Map<String, dynamic>? result = await businessAuth.getContractList(
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
        final tempList = result['results'];

        _isLoading = false;
        contractList.addAll(tempList);
        notifyListeners();

        // debugPrint('CONTRACT LENGTH :: ${contractList.length}');

        if (isFirstTime && next != null && next != "") {
          // debugPrint('NEXT :::: $next');
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
