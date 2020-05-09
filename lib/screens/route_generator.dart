import 'package:Slydo/screens/bank_account_list.dart';
import 'package:Slydo/screens/dashboard.dart';
import 'package:Slydo/screens/explore.dart';
import 'package:Slydo/screens/forms/add_bank_account.dart';
import 'package:Slydo/screens/forms/add_document.dart';
import 'package:Slydo/screens/forms/add_product.dart';
import 'package:Slydo/screens/forms/add_service.dart';
import 'package:Slydo/screens/forms/compose_message.dart';
import 'package:Slydo/screens/forms/edit_product.dart';
import 'package:Slydo/screens/forms/edit_service.dart';
import 'package:Slydo/screens/forms/forgot_password.dart';
import 'package:Slydo/screens/forms/login.dart';
import 'package:Slydo/screens/forms/request_payment.dart';
import 'package:Slydo/screens/forms/reset_password.dart';
import 'package:Slydo/screens/forms/send_payment.dart';
import 'package:Slydo/screens/forms/signup.dart';
import 'package:Slydo/screens/order_detail_page.dart';
import 'package:Slydo/screens/orders_list.dart';
import 'package:Slydo/screens/payout_transactions.dart';
import 'package:Slydo/screens/product_detail_page.dart';
import 'package:Slydo/screens/profile.dart';
import 'package:Slydo/screens/request_payments_list.dart';
import 'package:Slydo/screens/scan_qr_code.dart';
import 'package:Slydo/screens/search_auto_complete.dart';
import 'package:Slydo/screens/search_backup.dart';
import 'package:Slydo/screens/service_detail_page.dart';
import 'package:Slydo/screens/settings.dart';
import 'package:Slydo/screens/transaction_detail_page.dart';
import 'package:Slydo/screens/transaction_graph.dart';
import 'package:Slydo/screens/transactions_list.dart';
import 'package:Slydo/screens/user_dashboard.dart';
import 'package:Slydo/splash.dart';
import 'package:Slydo/widget/resultReturningPasswordPopup.dart';
import 'package:flutter/material.dart';

import 'checkout_shopping_cart.dart';
import 'detailed_message.dart';
import 'forms/payout.dart';
import 'forms/registration.dart';
import 'home.dart';
import 'index.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Getting arguments passed in while calling Navigator.pushNamed
    switch (settings.name) {
      case '/login':
        return MaterialPageRoute(builder: (_) => UserLogin());
      case '/splash':
        return MaterialPageRoute(builder: (_) => SplashScreen());
      case '/index':
        return MaterialPageRoute(
            builder: (_) => Index(
                  arguments: settings.arguments,
                ));
      case '/dashboard':
        return MaterialPageRoute(
            builder: (_) => Dashboard(
                  arguments: settings.arguments,
                ));
      case '/new-registration':
        return MaterialPageRoute(builder: (_) => Registration());
      case '/register':
        return MaterialPageRoute(
            builder: (_) => SignUp(
                  arguments: settings.arguments,
                ));
      case '/add-document':
        return MaterialPageRoute(builder: (_) => AddDocument());
      case '/home':
        return MaterialPageRoute(builder: (_) => Home());
      case '/accounts':
        return MaterialPageRoute(builder: (_) => PaymentRequestList());
      case '/transactions':
        return MaterialPageRoute(builder: (_) => TransactionList());
      case '/transaction-graph':
        return MaterialPageRoute(builder: (_) => TransactionGraph());
      case '/transaction-detail':
        return MaterialPageRoute(
            builder: (_) => TransactionDetail(
                  arguments: settings.arguments,
                ));
      case '/settings':
        return MaterialPageRoute(builder: (_) => SettingsList());
      case '/add-account':
        return MaterialPageRoute(builder: (_) => AddAccount());
      case '/send-payment':
        return MaterialPageRoute(
            builder: (_) => SendPayment(
                  arguments: settings.arguments,
                ));
      case '/request-payment':
        return MaterialPageRoute(
            builder: (_) => RequestPayment(
                  arguments: settings.arguments,
                ));
      case '/explore':
        return MaterialPageRoute(builder: (_) => ExploreList());
      case '/search-user':
        return MaterialPageRoute(builder: (_) => SearchAll());
      case '/search-auto':
        return MaterialPageRoute(builder: (_) => SearchAutoComplete());
      case '/profile':
        return MaterialPageRoute(
            builder: (_) => Profile(arguments: settings.arguments));
      case '/product':
        return MaterialPageRoute(
            builder: (_) => ProductDetailPage(arguments: settings.arguments));
      case '/add-product':
        return MaterialPageRoute(
          builder: (_) => AddProduct(),
        );
      case '/edit-product':
        return MaterialPageRoute(
          builder: (_) => EditProduct(
            arguments: settings.arguments,
          ),
        );
      case '/search_user':
        return MaterialPageRoute(
          builder: (_) => SearchAll(),
        );
      case '/service-detail':
        return MaterialPageRoute(
          builder: (_) => ServiceDetailPage(
            arguments: settings.arguments,
          ),
        );
      case '/add-service':
        return MaterialPageRoute(
          builder: (_) => AddService(),
        );
      case '/edit-service':
        return MaterialPageRoute(
          builder: (_) => EditService(
            arguments: settings.arguments,
          ),
        );
      case '/compose_message':
        return MaterialPageRoute(
            builder: (_) => ComposeMessage(
                  arguments: settings.arguments,
                ));
      case '/detail_message':
        return MaterialPageRoute(
            builder: (_) => DetailedMessage(
                  arguments: settings.arguments,
                ));
      case '/resultPasswordPopup':
        return MaterialPageRoute(
            builder: (_) => ResultReturningPasswordPopup());
      case '/add-bank-account':
        return MaterialPageRoute(builder: (_) => AddAccount());
      case '/bank-account-list':
        return MaterialPageRoute(builder: (_) => BankAccountList());
      case '/scan-qr':
        return MaterialPageRoute(
            builder: (_) => QRCodeView(
                  arguments: settings.arguments,
                ));
      case '/payout':
        return MaterialPageRoute(builder: (context) => Payout());
      case '/payout-list':
        return MaterialPageRoute(builder: (context) => PayoutTransactions());
      case '/forgot-password':
        return MaterialPageRoute(builder: (context) => ForgotPassword());
      case '/reset-password':
        return MaterialPageRoute(
          builder: (context) => ResetPassword(
            arguments: settings.arguments,
          ),
        );
      case '/shopping-cart':
        return MaterialPageRoute(builder: (context) => ShoppingCart());
      case '/user-dashboard':
        return MaterialPageRoute(builder: (context) => UserDashboard());
      case '/orders-list':
        return MaterialPageRoute(builder: (context) => OrdersList());
      case '/order-detail-page':
        return MaterialPageRoute(
            builder: (context) =>
                OrderDetailPage(arguments: settings.arguments));

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
