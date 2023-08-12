import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/blog/create_or_edit_post.dart';
import 'package:Slydo/screens/connection_module/connections_dashboard.dart';
import 'package:Slydo/screens/dashboard.dart';
import 'package:Slydo/screens/explore.dart';
import 'package:Slydo/screens/home.dart';
import 'package:Slydo/screens/more_apps.dart';
import 'package:Slydo/screens/more_apps/bus/bus_dashboard.dart';
import 'package:Slydo/screens/more_apps/bus/search_bus.dart';
import 'package:Slydo/screens/more_apps/bus/ticket_detail.dart';
import 'package:Slydo/screens/more_apps/business/forms/add_contract.dart';
import 'package:Slydo/screens/more_apps/business/forms/invoice/add_invoice.dart';
import 'package:Slydo/screens/more_apps/business/forms/invoice/add_or_update_invoice_item.dart';
import 'package:Slydo/screens/more_apps/business/forms/invoice/edit_invoice_item.dart';
import 'package:Slydo/screens/more_apps/business/screens/contract_detail.dart';
import 'package:Slydo/screens/more_apps/business/screens/contract_transaction_history.dart';
import 'package:Slydo/screens/more_apps/business/screens/invoice_detail.dart';
import 'package:Slydo/screens/more_apps/business/screens/invoice_screen.dart';
import 'package:Slydo/screens/more_apps/events/event_dashboard.dart';
import 'package:Slydo/screens/more_apps/events/event_detail_page.dart';
import 'package:Slydo/screens/more_apps/events/event_ticket_detail.dart';
import 'package:Slydo/screens/more_apps/events/search_event.dart';
import 'package:Slydo/screens/more_apps/events/specific_category_event_list.dart';
import 'package:Slydo/screens/more_apps/flight/flight_dashboard.dart';
import 'package:Slydo/screens/more_apps/flight/search_flight.dart';
import 'package:Slydo/screens/more_apps/hotels/hotel_dashboard.dart';
import 'package:Slydo/screens/more_apps/hotels/hotel_detail_page.dart';
import 'package:Slydo/screens/more_apps/hotels/partner_detail_page.dart';
import 'package:Slydo/screens/more_apps/hotels/search_hotel.dart';
import 'package:Slydo/screens/more_apps/hotels/specific_category_hotel_list.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/forms/add_media_to_chat_message.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/forms/group/set_name_and_profile_for_group.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/forms/group/update_group_name_and_profile.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/forms/put_money_in_envelope.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/forms/send_envelope.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/screens/add_chat_group/select_user_for_group.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/screens/chat_screen_group_messages.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/screens/envelope_detail_screen.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/screens/group_detail_screen.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/screens/search_group_member.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/screens/view_chat_media.dart';
import 'package:Slydo/screens/more_apps/messaging/detailed_message.dart';
import 'package:Slydo/screens/more_apps/messaging/forms/compose_message.dart';
import 'package:Slydo/screens/more_apps/messaging/message_list.dart';
import 'package:Slydo/screens/more_apps/movies/movie_dashboard.dart';
import 'package:Slydo/screens/more_apps/movies/movie_detail_page.dart';
import 'package:Slydo/screens/more_apps/movies/search_movie.dart';
import 'package:Slydo/screens/more_apps/movies/specific_category_movie_list.dart';
import 'package:Slydo/screens/more_apps/music/album_detail_page.dart';
import 'package:Slydo/screens/more_apps/music/music_dashboard.dart';
import 'package:Slydo/screens/more_apps/music/music_detail_page.dart';
import 'package:Slydo/screens/more_apps/music/search_music.dart';
import 'package:Slydo/screens/more_apps/music/specific_category_music_list.dart';
import 'package:Slydo/screens/more_apps/news/news_dashboard.dart';
import 'package:Slydo/screens/more_apps/news/news_detail_page.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/forms/banking/add_bank_account.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/forms/banking/add_bvn_number.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/forms/banking/already_have_reference.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/forms/banking/payout_screen.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/forms/banking/verify_reference.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/forms/payment/request_payment.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/forms/payment/send_payment.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/screens/banking/bank_account_list.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/screens/banking/card_payment_page.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/screens/banking/credit_card_list.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/screens/banking/credit_card_option_selection.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/screens/banking/payout_transactions.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/screens/banking/upgrade_account.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/screens/banking/virtual_account_detail.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/screens/payment/request_payments_list.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/screens/payment/transaction_detail_page.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/screens/payment/transaction_graph.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/screens/payment/transactions_list.dart';
import 'package:Slydo/screens/more_apps/property/forms/add_property.dart';
import 'package:Slydo/screens/more_apps/property/forms/edit_property.dart';
import 'package:Slydo/screens/more_apps/property/property_dashboard.dart';
import 'package:Slydo/screens/more_apps/property/property_detail_page.dart';
import 'package:Slydo/screens/more_apps/property/search_property.dart';
import 'package:Slydo/screens/more_apps/property/specific_category_property_list.dart';
import 'package:Slydo/screens/more_apps/review/forms/add_user_review.dart';
import 'package:Slydo/screens/more_apps/review/forms/edit_user_review.dart';
import 'package:Slydo/screens/more_apps/review/main_review.dart';
import 'package:Slydo/screens/more_apps/review/screen/review_detail_screen.dart';
import 'package:Slydo/screens/more_apps/review/screen/review_list_screen.dart';
import 'package:Slydo/screens/more_apps/settings/general_setting.dart';
import 'package:Slydo/screens/more_apps/shopping/forms/add_product.dart';
import 'package:Slydo/screens/more_apps/shopping/forms/add_service.dart';
import 'package:Slydo/screens/more_apps/shopping/forms/edit_product.dart';
import 'package:Slydo/screens/more_apps/shopping/forms/edit_service.dart';
import 'package:Slydo/screens/more_apps/shopping/screens/checkout_shopping_cart.dart';
import 'package:Slydo/screens/more_apps/shopping/screens/mix_cart_item.dart';
import 'package:Slydo/screens/more_apps/shopping/screens/order/order_detail_page.dart';
import 'package:Slydo/screens/more_apps/shopping/screens/order/orders_list.dart';
import 'package:Slydo/screens/more_apps/shopping/screens/print_qrcode.dart';
import 'package:Slydo/screens/more_apps/shopping/screens/product_and_service/product_detail_page.dart';
import 'package:Slydo/screens/more_apps/shopping/screens/product_and_service/service_detail_page.dart';
import 'package:Slydo/screens/more_apps/shopping/screens/shopping/search_product.dart';
import 'package:Slydo/screens/more_apps/shopping/screens/shopping/specific_category_product_list.dart';
import 'package:Slydo/screens/more_apps/taxi/arriving_driver.dart';
import 'package:Slydo/screens/more_apps/taxi/cancle_booking.dart';
import 'package:Slydo/screens/more_apps/taxi/contact_driver.dart';
import 'package:Slydo/screens/more_apps/taxi/no_vehicale_found.dart';
import 'package:Slydo/screens/more_apps/taxi/payment_options.dart';
import 'package:Slydo/screens/more_apps/taxi/rate_and_tip_driver.dart';
import 'package:Slydo/screens/more_apps/taxi/ride_option.dart';
import 'package:Slydo/screens/more_apps/taxi/searching_for_driver.dart';
import 'package:Slydo/screens/more_apps/taxi/select_address_screen.dart';
import 'package:Slydo/screens/more_apps/taxi/taxi_dashboard.dart';
import 'package:Slydo/screens/more_apps/taxi/terms_and_condition.dart';
import 'package:Slydo/screens/more_apps/taxi/trip_ended.dart';
import 'package:Slydo/screens/more_apps/train/search_train.dart';
import 'package:Slydo/screens/more_apps/train/train_dashboard.dart';
import 'package:Slydo/screens/more_apps/user_post/models/user_post.dart';
import 'package:Slydo/screens/more_apps/user_profile/forms/account_type.dart';
import 'package:Slydo/screens/more_apps/user_profile/forms/add_document.dart';
import 'package:Slydo/screens/more_apps/user_profile/forms/add_or_edit_user_bio.dart';
import 'package:Slydo/screens/more_apps/user_profile/forms/change_password.dart';
import 'package:Slydo/screens/more_apps/user_profile/forms/forgot_password.dart';
import 'package:Slydo/screens/more_apps/user_profile/forms/login.dart';
import 'package:Slydo/screens/more_apps/user_profile/forms/registration.dart';
import 'package:Slydo/screens/more_apps/user_profile/forms/reset_device.dart';
import 'package:Slydo/screens/more_apps/user_profile/forms/reset_password.dart';
import 'package:Slydo/screens/more_apps/user_profile/forms/signup.dart';
import 'package:Slydo/screens/more_apps/user_profile/forms/upgrade_user_profile.dart';
import 'package:Slydo/screens/more_apps/user_profile/forms/user_address.dart';
import 'package:Slydo/screens/more_apps/user_profile/forms/verify_registration_OTP.dart';
import 'package:Slydo/screens/more_apps/user_profile/forms/verify_reset_device_OTP.dart';
import 'package:Slydo/screens/more_apps/user_profile/forms/verify_reset_password_OTP.dart';
import 'package:Slydo/screens/more_apps/user_profile/screens/shipping_options/add_shipping_options.dart';
import 'package:Slydo/screens/more_apps/user_profile/screens/shipping_options/edit_shipping_options.dart';
import 'package:Slydo/screens/more_apps/user_profile/screens/shipping_options/shipping_options_list.dart';
import 'package:Slydo/screens/more_apps/user_profile/screens/subscriptions/choose_subscription.dart';
import 'package:Slydo/screens/more_apps/user_profile/screens/user_profile_module_new/search_users_product_and_service.dart';
import 'package:Slydo/screens/more_apps/user_profile/screens/user_profile_module_new/user_profile_screen.dart';
import 'package:Slydo/screens/more_apps/utility/cable/forms/select_plan_and_decoder_number.dart';
import 'package:Slydo/screens/more_apps/utility/cable/screens/cable_plan_detail_page.dart';
import 'package:Slydo/screens/more_apps/utility/cable/screens/cable_plan_payment_detail.dart';
import 'package:Slydo/screens/more_apps/utility/cable/screens/select_cabel_plan.dart';
import 'package:Slydo/screens/more_apps/utility/cable/screens/select_cabel_provider.dart';
import 'package:Slydo/screens/more_apps/utility/utility_dashboard.dart';
import 'package:Slydo/screens/more_apps/utility/utility_history.dart';
import 'package:Slydo/screens/scan_qr_code.dart';
import 'package:Slydo/screens/search_module.dart';
import 'package:Slydo/screens/startup_screen.dart';
import 'package:Slydo/splash.dart';
import 'package:Slydo/widget/photo_viewer.dart';
import 'package:Slydo/widget/video_recorder.dart';
import 'package:Slydo/widget/webview_slydo/custom_webview.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

import '../screens/more_apps/business/screens/contract_screen.dart';
import '../screens/more_apps/credit_card/add_virtual_card.dart';
import '../screens/more_apps/credit_card/design_virtual_card.dart';
import '../screens/more_apps/credit_card/generate_debit_card.dart';
import '../screens/more_apps/credit_card/fund_virtual_card.dart';
import '../screens/more_apps/credit_card/search_transaction_card.dart';
import '../screens/more_apps/credit_card/virtual_card_home.dart';
import '../screens/more_apps/credit_card/withdraw_virtual_card.dart';
import '../screens/more_apps/payment_and_banking/screens/banking/enter_address_or_pin_page.dart';
import '../screens/more_apps/payment_and_banking/screens/banking/payout_transaction_detail.dart';
import '../screens/more_apps/service_hub/models/active_job_listing.dart';
import '../screens/more_apps/service_hub/models/jobs.dart';
import '../screens/more_apps/service_hub/screens/applicant_list.dart';
import '../screens/more_apps/service_hub/screens/categories_list.dart';
import '../screens/more_apps/service_hub/screens/category_jobs_list.dart';
import '../screens/more_apps/service_hub/screens/create_jobs.dart';
import '../screens/more_apps/service_hub/screens/edit_job.dart';
import '../screens/more_apps/service_hub/screens/job_detail.dart';
import '../screens/more_apps/service_hub/screens/job_search.dart';
import '../screens/more_apps/service_hub/screens/my_job_details.dart';
import '../screens/more_apps/service_hub/screens/my_jobs_list.dart';
import '../screens/more_apps/service_hub/screens/preview_job_detail.dart';
import '../screens/more_apps/service_hub/screens/search_filter.dart';
import '../screens/more_apps/service_hub/screens/search_my_job.dart';
import '../screens/more_apps/service_hub/screens/search_services.dart';
import '../screens/more_apps/service_hub/service_hub_dashboard.dart';
import '../screens/more_apps/shopping/forms/product/product_add_new_option.dart';
import '../screens/more_apps/shopping/forms/product/product_variant_list.dart';
import '../screens/more_apps/shopping/forms/product/product_variant_update.dart';
import '../screens/super_store/near_by_list_screen.dart';
import '../screens/super_store/search_nearby_business.dart';
import '../screens/super_store/super_store.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Getting arguments passed in while calling Navigator.pushNamed
    switch (settings.name) {
      case Routes.LOGIN:
        return PageTransition(
          child: UserLogin(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.RESET_DEVICE:
        return PageTransition(
          child: ResetDevice(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.SPLASH:
        return PageTransition(
          child: SplashScreen(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.INDEX:
        return PageTransition(
          child: StartupScreen(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.DASHBOARD:
        return PageTransition(
          child: Dashboard(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.SEARCH_MODULE:
        return PageTransition(
          child: SearchModule(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.REGISTRATION:
        return PageTransition(
          child: Registration(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.VERIFY_REGISTRATION_OTP:
        return PageTransition(
          child: VerifyRegistrationOTPScreen(arguments: settings.arguments),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.VERIFY_RESET_DEVICE_OTP:
        return PageTransition(
          child: VerifyResetDeviceOTPScreen(arguments: settings.arguments),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.VERIFY_RESET_PASSWORD_OTP:
        return PageTransition(
          child: VerifyResetPasswordOTPScreen(arguments: settings.arguments),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.ACCOUNT_TYPE:
        return PageTransition(
          child: AccountType(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.SIGN_UP:
        return PageTransition(
          child: SignUp(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.ADD_DOCUMENT:
        return PageTransition(
          child: AddDocument(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.HOME:
        return PageTransition(
          child: Home(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.ACCOUNTS:
        return PageTransition(
          child: PaymentRequestList(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.TRANSACTIONS:
        return PageTransition(
          child: TransactionList(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.TRANSACTION_GRAPH:
        return PageTransition(
          child: TransactionGraph(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.TRANSACTION_DETAIL:
        return PageTransition(
          child: TransactionDetail(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.PAYOUT_TRANSACTION_DETAIL:
        return PageTransition(
          child: PayoutTransactionDetail(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.ADD_ACCOUNT:
        return PageTransition(
          child: AddAccount(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.SEND_PAYMENT:
        final args = settings.arguments as Map<String, dynamic>;

        return PageTransition(
          child: SendPayment(
            callback: args['callback'],
            arguments: settings.arguments,
          ),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.REQUEST_PAYMENT:
        return PageTransition(
          child: RequestPayment(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.EXPLORE:
        return PageTransition(
          child: ExploreList(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.USER_PROFILE:
        return PageTransition(
          child: UserProfileScreen(arguments: settings.arguments),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.CREATE_BLOG:
        return PageTransition(
          child: CreateorEditPostScreen(
            userPost: settings.arguments != null
                ? settings.arguments as UserPost
                : null,
          ),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.CHOOSE_SUBSCRIPTIONS:
        return PageTransition(
          child: const ChooseSubscription(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.USER_PRODUCT_AND_SERVICE_SEARCH:
        return PageTransition(
          child: SearchUsersProductAndService(arguments: settings.arguments),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.PRODUCT:
        return PageTransition(
          child: ProductDetailPage(arguments: settings.arguments),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.ADD_PRODUCT:
        return PageTransition(
          child: AddProduct(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.EDIT_PRODUCT:
        return PageTransition(
          child: EditProduct(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.SERVICE_DETAIL:
        return PageTransition(
          child: ServiceDetailPage(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.ADD_SERVICE:
        return PageTransition(
          child: AddService(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.EDIT_SERVICE:
        return PageTransition(
          child: EditService(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.MESSAGE_LIST:
        return PageTransition(
          child: MessageList(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.COMPOSE_MESSAGE:
        return PageTransition(
          child: ComposeMessage(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.DETAIL_MESSAGE:
        return PageTransition(
          child: DetailedMessage(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.ADD_BVN_NUMBER:
        return PageTransition(
          child: AddBvnNumber(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.ADD_BANK_ACCOUNT:
        return PageTransition(
          child: AddAccount(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.BANK_ACCOUNT_LIST:
        return PageTransition(
          child: BankAccountList(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.SCAN_QR:
        return PageTransition(
          child: QRCodeView(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.PAYOUT:
        return PageTransition(
          child: PayoutScreen(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.PAYOUT_LIST:
        return PageTransition(
          child: PayoutTransactions(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.FORGOT_PASSWORD:
        return PageTransition(
          child: ForgotPassword(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.RESET_PASSWORD:
        return PageTransition(
          child: ResetPassword(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.CHANGE_PASSWORD:
        return PageTransition(
          child: ChangePassword(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.SHOPPING_CART:
        return PageTransition(
          child: ShoppingCart(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.ORDERS_LIST:
        return PageTransition(
          child: OrdersList(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.ORDER_DETAIL_PAGE:
        return PageTransition(
          child: OrderDetailPage(arguments: settings.arguments),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.CARD_PAYMENT_PAGE:
        return PageTransition(
          child: CardPaymentPage(isWalletFunding: settings.arguments),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.USER_ADDRESS:
        return PageTransition(
          child: UserAddress(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.FRIENDS_DASHBOARD:
        return PageTransition(
          child: ConnectionDashboard(arguments: settings.arguments),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.UPGRADE_USER_PROFILE:
        return PageTransition(
          child: UpgradeUserProfile(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.PRINT_QR:
        return PageTransition(
          child: PrintQRCode(arguments: settings.arguments),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      /// Chat
      case Routes.CHAT_SCREEN:
        return PageTransition(
          child: ChatScreenGroupMessage(arguments: settings.arguments),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.SEND_MEDIA_TO_CHAT_MESSAGE:
        return PageTransition(
          child: AddMediaToChatMessage(
              arguments: settings.arguments as Map<String, dynamic>?),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.VIEW_CHAT_MEDIA:
        return PageTransition(
          child: ViewChatMedia(arguments: settings.arguments),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.SELECT_USER_FOR_GROUP:
        return PageTransition(
          child: SelectUserForGroup(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.SET_NAME_AND_PROFILE_FOR_GROUP:
        return PageTransition(
          child: SetNameAndProfileOfGroup(arguments: settings.arguments),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.UPDATE_NAME_AND_PROFILE_FOR_GROUP:
        return PageTransition(
          child: UpdateGroupNameAndProfile(arguments: settings.arguments),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.SEARCH_MEMBER_IN_GROUP:
        return PageTransition(
          child: SearchGroupMember(arguments: settings.arguments),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.SEND_ENVELOPE:
        return PageTransition(
          child: SendEnvelope(arguments: settings.arguments),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.ENVELOPE_DETAIL:
        return PageTransition(
          child: EnvelopeDetailScreen(arguments: settings.arguments),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.PUT_MONEY_IN_ENVELOPE:
        return PageTransition(
          child: PutMoneyInEnvelope(arguments: settings.arguments),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.GROUP_DETAIL:
        return PageTransition(
          child: GroupDetailScreen(arguments: settings.arguments),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      /// Video Recorder

      case Routes.VIDEO_RECORDER:
        return PageTransition(
          child: VideoRecorder(arguments: settings.arguments),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      /// TopUp

      case Routes.CREDIT_CARD_LIST:
        return PageTransition(
          child: CreditCardList(arguments: settings.arguments),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.CREDIT_CARD_OPTION_SELECTION:
        return PageTransition(
          child: CreditCardOptionSelection(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.ENTER_PIN:
        return PageTransition(
          child: EnterAddressOrPinPinPage(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.UPGRADE_ACCOUNT:
        return PageTransition(
          child: const UpgradeAccount(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      // case '/user-kyc':
      //   return PageTransition(
      //     child: UserKyc(),
      //     type: PageTransitionType.bottomToTop,
      //     curve: Curves.ease,
      //     settings: settings,
      //   );

      case Routes.ADD_MONEY_TO_SLYDO_ONE:
        return PageTransition(
          child: VirtualAccountDetail(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.ADD_MONEY_TO_SLYDO_TWO:
        return PageTransition(
          child: AddMoneyToSlydoTwo(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.ALREADY_HAVE_REFERENCE:
        return PageTransition(
          child: AlreadyHaveReferenceScreen(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      /// Contracts & Invoice
      case Routes.CONTRACT_SCREEN:
        return PageTransition(
          child: const ContractScreen(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.INVOICE_SCREEN:
        return PageTransition(
          child: const InvoiceScreen(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.CONTRACT_SCREEN:
        return PageTransition(
          child: const ContractScreen(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.ADD_CONTRACT:
        return PageTransition(
          child: AddContract(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.CONTRACT_DETAIL:
        return PageTransition(
          child: ContractDetail(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.CONTRACT_TRANSACTIONS:
        return PageTransition(
          child: ContractTransactionHistory(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.ADD_INVOICE:
        return PageTransition(
          child: AddInvoice(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.ADD_INVOICE_ITEM:
        return PageTransition(
          child: AddOrUpdateInvoiceItem(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.EDIT_INVOICE_ITEM:
        return PageTransition(
          child: EditInvoiceItem(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.INVOICE_DETAIL:
        return PageTransition(
          child: InvoiceDetail(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      ///    Utility Route     ///

      case Routes.UTILITY_DASHBOARD:
        return PageTransition(
          child: UtilityDashboard(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.UTILITY_HISTORY:
        return PageTransition(
          child: UtilityHistory(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.CABLE_PROVIDER:
        return PageTransition(
          child: SelectCableProvider(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.SELECT_CABLE_PLAN_AND_DECODER_NUMBER:
        return PageTransition(
          child: SelectPlanAndDecoderNumber(
              arguments: settings.arguments as Map<String, dynamic>?),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.SELECT_CABLE_PLAN:
        return PageTransition(
          child: SelectCablePlan(
              arguments: settings.arguments as Map<String, dynamic>?),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.CABLE_PLAN_DETAIL:
        return PageTransition(
          child: CablePlanDetail(
              arguments: settings.arguments as Map<String, dynamic>?),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.CABLE_PLAN_PAYMENT_DETAIL:
        return PageTransition(
          child: CablePlanPaymentDetail(
              arguments: settings.arguments as Map<String, dynamic>?),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      ///    More Apps Route     ///
      case Routes.MORE_APPS:
        return PageTransition(
          child: MoreApps(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      /// Services Route ///

      case Routes.SUPER_HUB:
        return PageTransition(
            child: const ServiceHubDashboard(),
            type: PageTransitionType.bottomToTop,
            curve: Curves.ease,
            settings: settings);

      case Routes.SEARCH_MY_JOBS:
        return PageTransition(
            child:  SearchMyJobs(),
            type: PageTransitionType.bottomToTop,
            curve: Curves.ease,
            settings: settings);

      case Routes.SEARCH_SERVICES:
        return PageTransition(
            child:  SearchServices(),
            type: PageTransitionType.bottomToTop,
            curve: Curves.ease,
            settings: settings);

      /// Movie Route

      case Routes.TAXI:
        return PageTransition(
          child: TaxiDashboard(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.SELECT_DESTINATION_FOR_TAXI_RIDE:
        return PageTransition(
          child: SelectAddressScreen(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.SELECT_RIDE_TYPE:
        var arguments = settings.arguments as Map<String, dynamic>;
        return PageTransition(
          child: RideOption(),
          childCurrent: arguments['currentChild'],
          type: PageTransitionType.rightToLeftJoined,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.SEARCH_DRIVER:
        var arguments = settings.arguments as Map<String, dynamic>;
        return PageTransition(
          child: SearchingForRide(),
          childCurrent: arguments['currentChild'],
          type: PageTransitionType.rightToLeftJoined,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.DRIVER_ARRIVING:
        return PageTransition(
          child: ArrivingDriver(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.TRIP_ENDED:
        return PageTransition(
          child: TripEnded(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.PAYMENT_OPTIONS:
        return PageTransition(
          child: PaymentOptions(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.NO_VEHICLE_FOUND:
        return PageTransition(
          child: NoVehicleFound(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.TERMS_AND_CONDITION:
        return PageTransition(
          child: TermsAndCondition(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.RATE_AND_TIP_DRIVER:
        return PageTransition(
          child: RateAndTipDriver(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.CANCLE_BOOKING:
        return PageTransition(
          child: CancelBooking(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.CONTACT_DRIVER:
        return PageTransition(
          child: ContactDriver(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

    // Find jobs
      case Routes.CATEGORY_JOBS:
        return PageTransition(
            child: JobsCategoryJobsList(
              categoryId: settings.arguments as String,
            ),
            type: PageTransitionType.bottomToTop,
            curve: Curves.ease,
            settings: settings);

      case Routes.CATEGORIES_LIST:
        return PageTransition(
            child: const CategoriesList(),
            type: PageTransitionType.bottomToTop,
            curve: Curves.ease,
            settings: settings);

      case Routes.JOB_DETAILS:
        return PageTransition(
            child: JobsJobDetail(
              activeListingData: settings.arguments as ActiveListingData,
            ),
            type: PageTransitionType.bottomToTop,
            curve: Curves.ease,
            settings: settings);

      case Routes.MY_JOB_DETAILS:
        return PageTransition(
            child: MyJobsDetails(
              jobDetails: settings.arguments as Map,
            ),
            type: PageTransitionType.bottomToTop,
            curve: Curves.ease,
            settings: settings);

      case Routes.JOB_SEARCH_FILTER:
        return PageTransition(
            child: const JobsSearchFilter(),
            type: PageTransitionType.bottomToTop,
            curve: Curves.ease,
            settings: settings);

      case Routes.JOBS_CREATE:
        return PageTransition(
            child: JobsCreateJobs(),
            type: PageTransitionType.bottomToTop,
            curve: Curves.ease,
            settings: settings);

      case Routes.JOBS_PREVIEW_DETAIL:
        return PageTransition(
            child: JobsPreviewJobDetail(
              jobDetails: settings.arguments as Map,
            ),
            type: PageTransitionType.bottomToTop,
            curve: Curves.ease,
            settings: settings);

      case Routes.MY_JOBS:
        return PageTransition(
            child: const JobsMyJobsList(),
            type: PageTransitionType.bottomToTop,
            curve: Curves.ease,
            settings: settings);

      case Routes.JOBS_SEARCH:
        return PageTransition(
            child:  JobsSearch(filterMap:settings.arguments as Map<String, dynamic>?),
            type: PageTransitionType.bottomToTop,
            curve: Curves.ease,
            settings: settings);

      case Routes.JOBS_APPLICANT_LIST:
        return PageTransition(
            child: ApplicantList(
              job: settings.arguments as JobModel?,
            ),
            type: PageTransitionType.bottomToTop,
            curve: Curves.ease,
            settings: settings);

      case Routes.EDIT_JOB:
        return PageTransition(
            child: EditJob(
              job: settings.arguments as JobModel?,
            ),
            type: PageTransitionType.bottomToTop,
            curve: Curves.ease,
            settings: settings);

    /// Movie Route

      case Routes.MOVIES:
        return PageTransition(
          child: MovieDashboard(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.MOVIE_CATEGORY:
        return PageTransition(
          child: SpecificCategoryMovieList(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.SEARCH_MOVIE:
        return PageTransition(
          child: SearchMovie(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.MOVIE_DETAIL:
        return PageTransition(
          child: MovieDetailPage(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      /// Music

      case Routes.MUSICS:
        return PageTransition(
          child: MusicDashboard(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.MUSIC_CATEGORY:
        return PageTransition(
          child: SpecificCategoryMusicList(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.SEARCH_MUSIC:
        return PageTransition(
          child: SearchMusic(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.ALBUM_DETAIL:
        return PageTransition(
          child: AlbumDetailPage(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.MUSIC_DETAIL:
        return PageTransition(
          child: MusicDetailPage(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      /// Event Route

      case Routes.EVENTS:
        return PageTransition(
          child: EventDashboard(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.EVENT_CATEGORY:
        return PageTransition(
          child: SpecificCategoryEventList(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.SEARCH_EVENT:
        return PageTransition(
          child: SearchEvent(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.EVENT_DETAIL:
        return PageTransition(
          child: EventDetailPage(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.EVENT_TICKET_DETAIL:
        return PageTransition(
          child: EventTicketDetail(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      /// Hotel Route

      case Routes.HOTELS:
        return PageTransition(
          child: HotelDashboard(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.HOTEL_CATEGORY:
        return PageTransition(
          child: SpecificCategoryHotelList(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.SEARCH_HOTEL:
        return PageTransition(
          child: SearchHotel(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.HOTEL_DETAIL:
        return PageTransition(
          child: HotelDetailPage(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.HOTEL_TICKET_DETAIL:
        return PageTransition(
          child: EventTicketDetail(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.PARTNER_DETAIL:
        return PageTransition(
          child: PartnerDetailPage(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      /// Property Route

      case Routes.PROPERTY:
        return PageTransition(
          child: PropertyDashboard(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.PROPERTY_CATEGORY:
        return PageTransition(
          child: SpecificCategoryPropertyList(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.SEARCH_PROPERTY:
        return PageTransition(
          child: SearchProperty(arguments: settings.arguments),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.PROPERTY_DETAIL:
        return PageTransition(
          child: PropertyDetailPage(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.ADD_PROPERTY:
        return PageTransition(
          child: AddProperty(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.EDIT_PROPERTY:
        return PageTransition(
          child: EditProperty(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      /// News

      case Routes.NEWS:
        return PageTransition(
          child: NewsDashboard(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.NEWS_DETAIL:
        return PageTransition(
          child: NewsDetailPage(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      /// Bus

      case Routes.BUS:
        return PageTransition(
          child: BusDashboard(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.SEARCH_BUS:
        return PageTransition(
          child: SearchBus(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.TICKET_DETAIL:
        return PageTransition(
          child: TicketDetail(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      /// Train

      case Routes.TRAIN:
        return PageTransition(
          child: TrainDashboard(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.SEARCH_TRAIN:
        return PageTransition(
          child: SearchTrain(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      /// Flight

      case Routes.FLIGHT:
        return PageTransition(
          child: FlightDashboard(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.SEARCH_FLIGHT:
        return PageTransition(
          child: SearchFlight(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      /// Shopping

      case Routes.SUPER_STORE:
        return PageTransition(
          child: const SuperStore(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.SHOPPING_CATEGORY:
        return PageTransition(
          child: SpecificCategoryProductList(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.SEARCH_PRODUCT:
        return PageTransition(
          child: SearchProduct(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.SEARCH_NEAR_BY_BUSINESS:
        return PageTransition(
          child: SearchNearByBusiness(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      /// Review

      case Routes.REVIEWS:
        return PageTransition(
          child: MainReview(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.MIX_CART_ITEM:
        return PageTransition(
          child: MixCartItem(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.ADD_EDIT_USER_BIO:
        return PageTransition(
          child: AddOrEditUserBioScreen(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      // case "/nfc-reader":
      //   return PageTransition(
      //     child: NfcWriter(),
      //     type: PageTransitionType.bottomToTop,
      //     curve: Curves.ease,
      //     settings: settings,
      //   );

      case Routes.GENERAL_SETTING:
        return PageTransition(
          child: GeneralSettingScreen(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.PHOTO_VIEWER:
        return PageTransition(
          child: PhotoViewer(imageUrl: settings.arguments as String?),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.REVIEW_DETAIL_SCREEN:
        return PageTransition(
          child: ReviewDetailScreen(
              arguments: settings.arguments as Map<String, dynamic>),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.SHIPPING_OPTIONS:
        return PageTransition(
          child: ShippingOptionsList(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.ADD_SHIPPING_OPTIONS:
        final args = settings.arguments as Map<String, dynamic>;

        return PageTransition(
          child: AddShippingOptions(
            callback: args['callback'],
          ),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.EDIT_SHIPPING_OPTIONS:
        final args = settings.arguments as Map<String, dynamic>;

        return PageTransition(
          child: EditShippingOptions(
            callback: args['callback'],
            arguments: settings.arguments,
          ),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.REVIEW_LIST_SCREEN:
        return PageTransition(
          child: ReviewListScreen(
            arguments: settings.arguments as Map<String, dynamic>,
          ),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.ADD_REVIEW:
        return PageTransition(
          child: AddReview(
            arguments: settings.arguments as Map<String, dynamic>,
          ),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.EDIT_REVIEW:
        return PageTransition(
          child: EditUserReview(
              arguments: settings.arguments as Map<String, dynamic>),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      /// Custom Services
      case Routes.WEB_VIEW:
        return PageTransition(
          child: CustomWebView(webUrl: settings.arguments as String),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.NEAR_BY_LIST_SCREEN:
        return PageTransition(
          child: NearByListScreen(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.PRODUCT_VARIANT_LIST:
        return PageTransition(
          child: ProductVariantList(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.PRODUCT_NEW_OPTION:
        return PageTransition(
          child: ProductAddNewOption(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.PRODUCT_VARIANT_UPDATE:
        return PageTransition(
          child: ProductVariantUpdate(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.VIRTUAL_CARD_HOME:
        return PageTransition(
          child: VirtualCardHome(
          ),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.ADD_VIRTUAL_CARD:
        return PageTransition(
          child: const AddVirtualCard(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.DESIGN_VIRTUAL_CARD:
        return PageTransition(
          child: DesignVirtualCard(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.GENERATE_VIRTUAL_CARD:
        return PageTransition(
          child: GenerateDebitCard(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.FUND_VIRTUAL_CARD:
        return PageTransition(
          child: FundVirtualCard(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.WITHDRAW_VIRTUAL_CARD:
        return PageTransition(
          child: WithdrawVirtualCard(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.SEARCH_TRANSACTION_CARD:
        return PageTransition(
          child: SearchTransactionCard(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.bottomToTop,
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
          title: const Text('Error'),
        ),
        body: const Center(
          child: Text('ERROR'),
        ),
      );
    });
  }
}
