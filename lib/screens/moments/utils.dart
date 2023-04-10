import 'package:Slydo/utils/util.dart';

class MomentsUtils {
  String? getGetMomentDetailDateTime(String dateTime) {
    // return toTimeAgoLabel(dateTime: DateTime.parse(dateTime));
    return elapsedTime(dateTime: DateTime.parse(dateTime));
  }
}
