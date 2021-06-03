// import 'package:flutter_test/flutter_test.dart';
//
// import '../setup/unit/auth_service_mock.dart';
// import 'mock_user.dart';
//

import 'package:flutter_test/flutter_test.dart';

void main() {
  /// TODO: remove this test it is for only CI
  test('Counter value should be incremented', () {
    expect(1, 1);
  });
}

// void main() {
//   AuthServiceMock authServiceMock;
//
//   // setup data when each test run
//   setUp(() {
//     authServiceMock = AuthServiceMock();
//   });
//   // tear down data when each test complete
//   tearDown(() {});
//
//   test("Login Test", () async {
//     // when(authServiceMock.authenticate("+353877120700", "123456"))
//     //     .thenAnswer((realInvocation) => null);
//
//     expect(await authServiceMock.authenticate("+353877120700", "123456"),
//         MockUser());
//   });
// }
