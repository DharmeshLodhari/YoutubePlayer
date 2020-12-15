import 'package:Slydo/services/auth.dart';
import 'package:mockito/mockito.dart';

import '../../unit/mock_user.dart';

class AuthServiceMock extends Mock implements AuthService {
  @override
  Future<MockUser> authenticate(String phoneNumber, String password) async {
    return MockUser();
  }
}
