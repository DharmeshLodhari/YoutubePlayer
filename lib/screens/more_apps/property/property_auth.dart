import 'package:Slydo/services/auth.dart';

class PropertyAuthService extends AuthService {
  Future<List<String>> getLocation() async {
    List<String> list = ["Lagos", "Kano", "Ibadan", "Benin City", "Abuja"];
    return list;
  }
}
