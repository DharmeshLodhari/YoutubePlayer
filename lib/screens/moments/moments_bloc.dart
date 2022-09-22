import 'package:flutter/foundation.dart';

class MomentsBloc extends ChangeNotifier {
  List<int> _numberOfComments = [];
  List<int> get numberOfComments => _numberOfComments;

  set numberOfComments(List<int> commentsNum) {
    _numberOfComments = commentsNum;
    notifyListeners();
  }
}
