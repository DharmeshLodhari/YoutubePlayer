import 'package:Slydo/screens/bank_account_list.dart';
import 'package:Slydo/screens/card_payment_page.dart';
import 'package:Slydo/screens/connection_module/connections_dashboard.dart';
import 'package:Slydo/screens/dashboard.dart';
import 'package:Slydo/screens/explore.dart';
import 'package:Slydo/screens/forms/add_bank_account.dart';
import 'package:Slydo/screens/forms/add_document.dart';
import 'package:Slydo/screens/forms/add_product.dart';
import 'package:Slydo/screens/forms/add_service.dart';
import 'package:Slydo/screens/forms/bvn_verification_page.dart';
import 'package:Slydo/screens/forms/compose_message.dart';
import 'package:Slydo/screens/forms/edit_product.dart';
import 'package:Slydo/screens/forms/edit_service.dart';
import 'package:Slydo/screens/forms/forgot_password.dart';
import 'package:Slydo/screens/forms/login.dart';
import 'package:Slydo/screens/forms/request_payment.dart';
import 'package:Slydo/screens/forms/reset_password.dart';
import 'package:Slydo/screens/forms/send_payment.dart';
import 'package:Slydo/screens/forms/signup.dart';
import 'package:Slydo/screens/forms/upgrade_user_profile.dart';
import 'package:Slydo/screens/forms/user_address.dart';
import 'package:Slydo/screens/messagelist.dart';
import 'package:Slydo/screens/order_detail_page.dart';
import 'package:Slydo/screens/orders_list.dart';
import 'package:Slydo/screens/payout_transactions.dart';
import 'package:Slydo/screens/product_detail_page.dart';
import 'package:Slydo/screens/request_payments_list.dart';
import 'package:Slydo/screens/scan_qr_code.dart';
import 'package:Slydo/screens/search_auto_complete.dart';
import 'package:Slydo/screens/service_detail_page.dart';
import 'package:Slydo/screens/settings.dart';
import 'package:Slydo/screens/transaction_detail_page.dart';
import 'package:Slydo/screens/transaction_graph.dart';
import 'package:Slydo/screens/transactions_list.dart';
import 'package:Slydo/screens/user_dashboard.dart';
import 'package:Slydo/screens/user_profile.dart';
import 'package:Slydo/screens/verify_OTP.dart';
import 'package:Slydo/splash.dart';
import 'package:Slydo/widget/resultReturningPasswordPopup.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

import '../screens/checkout_shopping_cart.dart';
import '../screens/detailed_message.dart';
import '../screens/forms/payout.dart';
import '../screens/forms/registration.dart';
import '../screens/home.dart';
import '../screens/index.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Getting arguments passed in while calling Navigator.pushNamed
    switch (settings.name) {
      case '/login':
        return PageTransition(
          child: UserLogin(),
          type: PageTransitionType.downToUp,
          curve: Curves.ease,
          settings: settings,
        );
      case '/splash':
        return PageTransition(
          child: SplashScreen(),
          type: PageTransitionType.downToUp,
          curve: Curves.ease,
          settings: settings,
        );
      case '/index':
        return PageTransition(
          child: Index(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.downToUp,
          curve: Curves.ease,
          settings: settings,
        );
      case '/dashboard':
        return PageTransition(
          child: Dashboard(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.downToUp,
          curve: Curves.ease,
          settings: settings,
        );
      case '/new-registration':
        return PageTransition(
          child: Registration(),
          type: PageTransitionType.downToUp,
          curve: Curves.ease,
          settings: settings,
        );
      case '/verify-registration-otp':
        return PageTransition(
          child: VerifyOTPScreen(arguments: settings.arguments),
          type: PageTransitionType.downToUp,
          curve: Curves.ease,
          settings: settings,
        );
      case '/register':
        return PageTransition(
          child: SignUp(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.downToUp,
          curve: Curves.ease,
          settings: settings,
        );
      case '/add-document':
        return PageTransition(
          child: AddDocument(),
          type: PageTransitionType.downToUp,
          curve: Curves.ease,
          settings: settings,
        );
      case '/home':
        return PageTransition(
          child: Home(),
          type: PageTransitionType.downToUp,
          curve: Curves.ease,
          settings: settings,
        );
      case '/accounts':
        return PageTransition(
          child: PaymentRequestList(),
          type: PageTransitionType.downToUp,
          curve: Curves.ease,
          settings: settings,
        );
      case '/transactions':
        return PageTransition(
          child: TransactionList(),
          type: PageTransitionType.downToUp,
          curve: Curves.ease,
          settings: settings,
        );
      case '/transaction-graph':
        return PageTransition(
          child: TransactionGraph(),
          type: PageTransitionType.downToUp,
          curve: Curves.ease,
          settings: settings,
        );
      case '/transaction-detail':
        return PageTransition(
          child: TransactionDetail(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.downToUp,
          curve: Curves.ease,
          settings: settings,
        );
      case '/settings':
        return PageTransition(
          child: SettingsList(),
          type: PageTransitionType.downToUp,
          curve: Curves.ease,
          settings: settings,
        );
      case '/add-account':
        return PageTransition(
          child: AddAccount(),
          type: PageTransitionType.downToUp,
          curve: Curves.ease,
          settings: settings,
        );
      case '/send-payment':
        return PageTransition(
          child: SendPayment(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.downToUp,
          curve: Curves.ease,
          settings: settings,
        );
      case '/request-payment':
        return PageTransition(
          child: RequestPayment(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.downToUp,
          curve: Curves.ease,
          settings: settings,
        );
      case '/explore':
        return PageTransition(
          child: ExploreList(),
          type: PageTransitionType.downToUp,
          curve: Curves.ease,
          settings: settings,
        );
      case '/search-auto':
        return PageTransition(
          child: SearchAutoComplete(),
          type: PageTransitionType.downToUp,
          curve: Curves.ease,
          settings: settings,
        );
      case '/profile':
        return PageTransition(
          child: UserProfile(arguments: settings.arguments),
          type: PageTransitionType.downToUp,
          curve: Curves.ease,
          settings: settings,
        );
      case '/product':
        return PageTransition(
          child: ProductDetailPage(arguments: settings.arguments),
          type: PageTransitionType.downToUp,
          curve: Curves.ease,
          settings: settings,
        );
      case '/add-product':
        return PageTransition(
          child: AddProduct(),
          type: PageTransitionType.downToUp,
          curve: Curves.ease,
          settings: settings,
        );
      case '/edit-product':
        return PageTransition(
          child: EditProduct(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.downToUp,
          curve: Curves.ease,
          settings: settings,
        );
      case '/service-detail':
        return PageTransition(
          child: ServiceDetailPage(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.downToUp,
          curve: Curves.ease,
          settings: settings,
        );
      case '/add-service':
        return PageTransition(
          child: AddService(),
          type: PageTransitionType.downToUp,
          curve: Curves.ease,
          settings: settings,
        );
      case '/edit-service':
        return PageTransition(
          child: EditService(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.downToUp,
          curve: Curves.ease,
          settings: settings,
        );
      case '/message-list':
        return PageTransition(
          child: MessageList(),
          type: PageTransitionType.downToUp,
          curve: Curves.ease,
          settings: settings,
        );
      case '/compose_message':
        return PageTransition(
          child: ComposeMessage(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.downToUp,
          curve: Curves.ease,
          settings: settings,
        );
      case '/detail_message':
        return PageTransition(
          child: DetailedMessage(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.downToUp,
          curve: Curves.ease,
          settings: settings,
        );
      case '/resultPasswordPopup':
        return PageTransition(
          child: ResultReturningPasswordPopup(),
          type: PageTransitionType.downToUp,
          curve: Curves.ease,
          settings: settings,
        );
      case '/add-bank-account':
        return PageTransition(
          child: AddAccount(),
          type: PageTransitionType.downToUp,
          curve: Curves.ease,
          settings: settings,
        );
      case '/bank-account-list':
        return PageTransition(
          child: BankAccountList(),
          type: PageTransitionType.downToUp,
          curve: Curves.ease,
          settings: settings,
        );
      case '/scan-qr':
        return PageTransition(
          child: QRCodeView(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.downToUp,
          curve: Curves.ease,
          settings: settings,
        );
      case '/payout':
        return PageTransition(
          child: Payout(),
          type: PageTransitionType.downToUp,
          curve: Curves.ease,
          settings: settings,
        );
      case '/payout-list':
        return PageTransition(
          child: PayoutTransactions(),
          type: PageTransitionType.downToUp,
          curve: Curves.ease,
          settings: settings,
        );
      case '/forgot-password':
        return PageTransition(
          child: ForgotPassword(),
          type: PageTransitionType.downToUp,
          curve: Curves.ease,
          settings: settings,
        );
      case '/reset-password':
        return PageTransition(
          child: ResetPassword(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.downToUp,
          curve: Curves.ease,
          settings: settings,
        );
      case '/shopping-cart':
        return PageTransition(
          child: ShoppingCart(),
          type: PageTransitionType.downToUp,
          curve: Curves.ease,
          settings: settings,
        );
      case '/user-dashboard':
        return PageTransition(
          child: UserDashboard(arguments: settings.arguments),
          type: PageTransitionType.downToUp,
          curve: Curves.ease,
          settings: settings,
        );
      case '/orders-list':
        return PageTransition(
          child: OrdersList(),
          type: PageTransitionType.downToUp,
          curve: Curves.ease,
          settings: settings,
        );
      case '/order-detail-page':
        return PageTransition(
          child: OrderDetailPage(arguments: settings.arguments),
          type: PageTransitionType.downToUp,
          curve: Curves.ease,
          settings: settings,
        );
      case '/bvn-verification':
        return PageTransition(
          child: BvnVerificationPage(),
          type: PageTransitionType.downToUp,
          curve: Curves.ease,
          settings: settings,
        );
      case '/card-payment-page':
        return PageTransition(
          child: CardPaymentPage(),
          type: PageTransitionType.downToUp,
          curve: Curves.ease,
          settings: settings,
        );
      case '/user-address':
        return PageTransition(
          child: UserAddress(),
          type: PageTransitionType.downToUp,
          curve: Curves.ease,
          settings: settings,
        );
      case '/friends-dashboard':
        return PageTransition(
          child: ConnectionDashboard(),
          type: PageTransitionType.downToUp,
          curve: Curves.ease,
          settings: settings,
        );
      case '/upgrade-user-profile':
        return PageTransition(
          child: UpgradeUserProfile(),
          type: PageTransitionType.downToUp,
          curve: Curves.ease,
          settings: settings,
        );

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
