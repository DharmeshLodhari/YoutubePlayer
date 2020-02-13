import 'package:Slydo/screens/bank_accounts.dart';
import 'package:Slydo/screens/dashboard.dart';
import 'package:Slydo/screens/forms/add_bank_account.dart';
import 'package:Slydo/screens/forms/login.dart';
import 'package:Slydo/screens/forms/send_payment.dart';
import 'package:Slydo/screens/forms/signup.dart';
import 'package:Slydo/screens/home.dart';
import 'package:Slydo/screens/profile.dart';
import 'package:Slydo/screens/scan_qr_code.dart';
import 'package:Slydo/screens/settings.dart';
import 'package:Slydo/screens/transactions.dart';
import 'package:Slydo/splash.dart';
import 'package:Slydo/widget/passwordPopup.dart';
import 'package:flutter/material.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Getting arguments passed in while calling Navigator.pushNamed
    switch (settings.name) {
      case '/login':
        return MaterialPageRoute(builder: (_) => UserLogin());
      case '/splash':
        return MaterialPageRoute(builder: (_) => SplashScreen());
      case '/home':
        return MaterialPageRoute(builder: (_) => Home());
      case '/register':
        return MaterialPageRoute(builder: (_) => SignUp());
      case '/profile':
        return MaterialPageRoute(builder: (_) => Profile());

      // dashboard starts
      case '/dashboard':
        return MaterialPageRoute(
            builder: (_) => Dashboard(
                  arguments: settings.arguments,
                ));
      // dashboard ends

      case '/accounts':
        return MaterialPageRoute(builder: (_) => BankAccountList());
      case '/transactions':
        return MaterialPageRoute(builder: (_) => TransactionList());
      case '/settings':
        return MaterialPageRoute(builder: (_) => SettingsList());
      case '/add-account':
        return MaterialPageRoute(builder: (_) => AddAccount());
      case '/send-payment':
        return MaterialPageRoute(
            builder: (_) => SendPayment(
                  arguments: settings.arguments,
                ));
      case '/passwordPopup':
        return MaterialPageRoute(
            builder: (_) => PasswordPopup(
                  arguments: settings.arguments,
                ));
      case '/add-bank-account':
        return MaterialPageRoute(builder: (_) => AddAccount());
      case '/scan-qr':
        return MaterialPageRoute(builder: (_) => QRCodeView());

      default:
        // If there is no such named route in the switch statement, e.g. /third
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Error'),
        ),
        body: Center(
          child: Text('ERROR'),
        ),
      );
    });
  }
}
