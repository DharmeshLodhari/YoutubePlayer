import 'package:Slydo/screens/dashboard.dart';
import 'package:Slydo/screens/explore.dart';
import 'package:Slydo/screens/home.dart';
import 'package:Slydo/screens/index.dart';
import 'package:Slydo/screens/more_apps.dart';
import 'package:Slydo/screens/more_apps/bus/bus_dashboard.dart';
import 'package:Slydo/screens/more_apps/bus/search_bus.dart';
import 'package:Slydo/screens/more_apps/bus/ticket_detail.dart';
import 'package:Slydo/screens/more_apps/business/forms/add_contract.dart';
import 'package:Slydo/screens/more_apps/business/forms/invoice/add_invoice.dart';
import 'package:Slydo/screens/more_apps/business/forms/invoice/add_invoice_item.dart';
import 'package:Slydo/screens/more_apps/business/forms/invoice/edit_invoice_item.dart';
import 'package:Slydo/screens/more_apps/business/screens/contract_detail.dart';
import 'package:Slydo/screens/more_apps/business/screens/contract_transaction_history.dart';
import 'package:Slydo/screens/more_apps/business/screens/invoice_detail.dart';
import 'package:Slydo/screens/more_apps/business/screens/my_contract_screen.dart';
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
import 'package:Slydo/screens/more_apps/payment_and_banking/screens/banking/topup_option_selection.dart';
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
import 'package:Slydo/screens/more_apps/shopping/screens/shopping/shopping_dashboard.dart';
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
import 'package:Slydo/screens/more_apps/user_profile/screens/subscriptions/choose_subscription.dart';
import 'package:Slydo/screens/more_apps/user_profile/screens/connection_module/connections_dashboard.dart';
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
import 'package:Slydo/screens/user_dashboard.dart';
import 'package:Slydo/splash.dart';
import 'package:Slydo/widget/photo_viewer.dart';
import 'package:Slydo/widget/video_recorder.dart';
import 'package:Slydo/widget/webview_slydo/custom_webview.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:Slydo/screens/blog/create_or_edit_post.dart';

import '../screens/more_apps/payment_and_banking/screens/banking/enter_address_or_pin_page.dart';
import '../screens/more_apps/payment_and_banking/screens/banking/user_kyc.dart';
import '../screens/more_apps/utility/select_provider_screen.dart';
import '../screens/more_apps/utility/utility_payment_screen.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Getting arguments passed in while calling Navigator.pushNamed
    switch (settings.name) {
      case '/login':
        return PageTransition(
          child: UserLogin(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case '/reset-device':
        return PageTransition(
          child: ResetDevice(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case '/splash':
        return PageTransition(
          child: SplashScreen(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case '/index':
        return PageTransition(
          child: Index(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case '/dashboard':
        return PageTransition(
          child: Dashboard(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case '/search-module':
        return PageTransition(
          child: SearchModule(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case '/new-registration':
        return PageTransition(
          child: Registration(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case '/verify-registration-otp':
        return PageTransition(
          child: VerifyRegistrationOTPScreen(arguments: settings.arguments),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case '/verify-reset-device-otp':
        return PageTransition(
          child: VerifyResetDeviceOTPScreen(arguments: settings.arguments),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case '/verify-reset-password-otp':
        return PageTransition(
          child: VerifyResetPasswordOTPScreen(arguments: settings.arguments),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case '/register':
        return PageTransition(
          child: SignUp(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case '/add-document':
        return PageTransition(
          child: AddDocument(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case '/home':
        return PageTransition(
          child: Home(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case '/accounts':
        return PageTransition(
          child: PaymentRequestList(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case '/transactions':
        return PageTransition(
          child: TransactionList(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case '/transaction-graph':
        return PageTransition(
          child: TransactionGraph(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case '/transaction-detail':
        return PageTransition(
          child: TransactionDetail(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case '/add-account':
        return PageTransition(
          child: AddAccount(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case '/send-payment':
        return PageTransition(
          child: SendPayment(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case '/request-payment':
        return PageTransition(
          child: RequestPayment(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case '/explore':
        return PageTransition(
          child: ExploreList(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case '/profile':
        return PageTransition(
          child: UserProfileScreen(arguments: settings.arguments),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case '/create-blog':
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

      case '/choose-subscriptions':
        return PageTransition(
          child: ChooseSubscription(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case '/user-product-and-service-search':
        return PageTransition(
          child: SearchUsersProductAndService(arguments: settings.arguments),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case '/product':
        return PageTransition(
          child: ProductDetailPage(arguments: settings.arguments),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case '/add-product':
        return PageTransition(
          child: AddProduct(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case '/edit-product':
        return PageTransition(
          child: EditProduct(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case '/service-detail':
        return PageTransition(
          child: ServiceDetailPage(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case '/add-service':
        return PageTransition(
          child: AddService(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case '/edit-service':
        return PageTransition(
          child: EditService(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case '/message-list':
        return PageTransition(
          child: MessageList(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case '/compose_message':
        return PageTransition(
          child: ComposeMessage(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case '/detail_message':
        return PageTransition(
          child: DetailedMessage(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case '/add-bvn-number':
        return PageTransition(
          child: AddBvnNumber(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case '/add-bank-account':
        return PageTransition(
          child: AddAccount(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case '/bank-account-list':
        return PageTransition(
          child: BankAccountList(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case '/scan-qr':
        return PageTransition(
          child: QRCodeView(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case '/payout':
        return PageTransition(
          child: PayoutScreen(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case '/payout-list':
        return PageTransition(
          child: PayoutTransactions(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case '/forgot-password':
        return PageTransition(
          child: ForgotPassword(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case '/reset-password':
        return PageTransition(
          child: ResetPassword(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case '/change-password':
        return PageTransition(
          child: ChangePassword(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case '/shopping-cart':
        return PageTransition(
          child: ShoppingCart(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case '/user-dashboard':
        return PageTransition(
          child: UserDashboard(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case '/orders-list':
        return PageTransition(
          child: OrdersList(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case '/order-detail-page':
        return PageTransition(
          child: OrderDetailPage(arguments: settings.arguments),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case '/card-payment-page':
        return PageTransition(
          child: CardPaymentPage(isWalletFunding: settings.arguments),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case '/user-address':
        return PageTransition(
          child: UserAddress(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case '/friends-dashboard':
        return PageTransition(
          child: ConnectionDashboard(arguments: settings.arguments),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case '/upgrade-user-profile':
        return PageTransition(
          child: UpgradeUserProfile(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case '/print-qr':
        return PageTransition(
          child: PrintQRCode(arguments: settings.arguments),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      /// Chat

      case '/chat-screen':
        return PageTransition(
          child: ChatScreenGroupMessage(arguments: settings.arguments),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case '/send-media-to-chat-message':
        return PageTransition(
          child: AddMediaToChatMessage(
              arguments: settings.arguments as Map<String, dynamic>?),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case '/view-chat-media':
        return PageTransition(
          child: ViewChatMedia(arguments: settings.arguments),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case '/select-user-for-group':
        return PageTransition(
          child: SelectUserForGroup(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case '/set-name-and-profile-for-group':
        return PageTransition(
          child: SetNameAndProfileOfGroup(arguments: settings.arguments),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case '/update-name-and-profile-for-group':
        return PageTransition(
          child: UpdateGroupNameAndProfile(arguments: settings.arguments),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case '/search-member-in-group':
        return PageTransition(
          child: SearchGroupMember(arguments: settings.arguments),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case '/send-envelope':
        return PageTransition(
          child: SendEnvelope(arguments: settings.arguments),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case '/envelope-detail':
        return PageTransition(
          child: EnvelopeDetailScreen(arguments: settings.arguments),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case '/put-money-in-envelope':
        return PageTransition(
          child: PutMoneyInEnvelope(arguments: settings.arguments),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case '/group-detail':
        return PageTransition(
          child: GroupDetailScreen(arguments: settings.arguments),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      /// Video Recorder

      case '/video-recorder':
        return PageTransition(
          child: VideoRecorder(arguments: settings.arguments),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      /// TopUp

      case '/credit-card-list':
        return PageTransition(
          child: CreditCardList(arguments: settings.arguments),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case '/credit-card-option-selection':
        return PageTransition(
          child: CreditCardOptionSelection(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case '/enter-pin':
        return PageTransition(
          child: EnterAddressOrPinPinPage(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case '/upgrade-account':
        return PageTransition(
          child: UpgradeAccount(),
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

      case '/add-money-to-slydo-one':
        return PageTransition(
          child: VirtualAccountDetail(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case '/add-money-to-slydo-two':
        return PageTransition(
          child: AddMoneyToSlydoTwo(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case '/already-have-reference':
        return PageTransition(
          child: AlreadyHaveReferenceScreen(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      /// Contracts & Invoice
      case '/contracts':
        return PageTransition(
          child: MyContractScreen(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case '/add-contract':
        return PageTransition(
          child: AddContract(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case '/contract-detail':
        return PageTransition(
          child: ContractDetail(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case '/contract-transactions':
        return PageTransition(
          child: ContractTransactionHistory(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case '/add-invoice':
        return PageTransition(
          child: AddInvoice(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case '/add-invoice-item':
        return PageTransition(
          child: AddInvoiceItem(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case '/edit-invoice-item':
        return PageTransition(
          child: EditInvoiceItem(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case '/invoice-detail':
        return PageTransition(
          child: InvoiceDetail(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      ///    Utility Route     ///

      case '/utility-dashboard':
        return PageTransition(
          child: UtilityDashboard(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case '/utility-history':
        return PageTransition(
          child: UtilityHistory(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case '/cable-provider':
        return PageTransition(
          child: SelectCableProvider(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case '/select-cable-plan-and-decoder-number':
        return PageTransition(
          child: SelectPlanAndDecoderNumber(
              arguments: settings.arguments as Map<String, dynamic>?),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case '/select-cable-plan':
        return PageTransition(
          child: SelectCablePlan(
              arguments: settings.arguments as Map<String, dynamic>?),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case '/cable-plan-detail':
        return PageTransition(
          child: CablePlanDetail(
              arguments: settings.arguments as Map<String, dynamic>?),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case '/cable-plan-payment-detail':
        return PageTransition(
          child: CablePlanPaymentDetail(
              arguments: settings.arguments as Map<String, dynamic>?),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      ///    More Apps Route     ///

      case '/more-apps':
        return PageTransition(
          child: MoreApps(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      /// Movie Route

      case "/taxi":
        return PageTransition(
          child: TaxiDashboard(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case "/select-destination-for-taxi-ride":
        return PageTransition(
          child: SelectAddressScreen(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case "/select-ride-type":
        var arguments = settings.arguments as Map<String, dynamic>;
        return PageTransition(
          child: RideOption(),
          childCurrent: arguments['currentChild'],
          type: PageTransitionType.rightToLeftJoined,
          curve: Curves.ease,
          settings: settings,
        );

      case "/search-driver":
        var arguments = settings.arguments as Map<String, dynamic>;
        return PageTransition(
          child: SearchingForRide(),
          childCurrent: arguments['currentChild'],
          type: PageTransitionType.rightToLeftJoined,
          curve: Curves.ease,
          settings: settings,
        );

      case "/driver-arriving":
        return PageTransition(
          child: ArrivingDriver(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case "/trip-ended":
        return PageTransition(
          child: TripEnded(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case "/payment-options":
        return PageTransition(
          child: PaymentOptions(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case "/no-vehicle-found":
        return PageTransition(
          child: NoVehicleFound(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case "/terms-and-condition":
        return PageTransition(
          child: TermsAndCondition(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case "/rate-and-tip-driver":
        return PageTransition(
          child: RateAndTipDriver(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case "/cancle-booking":
        return PageTransition(
          child: CancelBooking(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case "/contact-driver":
        return PageTransition(
          child: ContactDriver(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      /// Movie Route

      case "/movies":
        return PageTransition(
          child: MovieDashboard(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case "/movie-category":
        return PageTransition(
          child: SpecificCategoryMovieList(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case "/search-movie":
        return PageTransition(
          child: SearchMovie(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case "/movie-detail":
        return PageTransition(
          child: MovieDetailPage(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      /// Music

      case "/musics":
        return PageTransition(
          child: MusicDashboard(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case "/music-category":
        return PageTransition(
          child: SpecificCategoryMusicList(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case "/search-music":
        return PageTransition(
          child: SearchMusic(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case "/album-detail":
        return PageTransition(
          child: AlbumDetailPage(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case "/music-detail":
        return PageTransition(
          child: MusicDetailPage(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      /// Event Route

      case "/events":
        return PageTransition(
          child: EventDashboard(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case "/event-category":
        return PageTransition(
          child: SpecificCategoryEventList(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case "/search-event":
        return PageTransition(
          child: SearchEvent(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case "/event-detail":
        return PageTransition(
          child: EventDetailPage(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case "/event-ticket-detail":
        return PageTransition(
          child: EventTicketDetail(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      /// Hotel Route

      case "/hotels":
        return PageTransition(
          child: HotelDashboard(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case "/hotel-category":
        return PageTransition(
          child: SpecificCategoryHotelList(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case "/search-hotel":
        return PageTransition(
          child: SearchHotel(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case "/hotel-detail":
        return PageTransition(
          child: HotelDetailPage(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case "/hotel-ticket-detail":
        return PageTransition(
          child: EventTicketDetail(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case "/partner-detail":
        return PageTransition(
          child: PartnerDetailPage(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      /// Property Route

      case "/property":
        return PageTransition(
          child: PropertyDashboard(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case "/property-category":
        return PageTransition(
          child: SpecificCategoryPropertyList(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case "/search-property":
        return PageTransition(
          child: SearchProperty(arguments: settings.arguments),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case "/property-detail":
        return PageTransition(
          child: PropertyDetailPage(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case "/add-property":
        return PageTransition(
          child: AddProperty(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case "/edit-property":
        return PageTransition(
          child: EditProperty(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      /// News

      case "/news":
        return PageTransition(
          child: NewsDashboard(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case "/news-detail":
        return PageTransition(
          child: NewsDetailPage(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      /// Bus

      case "/bus":
        return PageTransition(
          child: BusDashboard(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case "/search-bus":
        return PageTransition(
          child: SearchBus(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case "/ticket-detail":
        return PageTransition(
          child: TicketDetail(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      /// Train

      case "/train":
        return PageTransition(
          child: TrainDashboard(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case "/search-train":
        return PageTransition(
          child: SearchTrain(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      /// Flight

      case "/flight":
        return PageTransition(
          child: FlightDashboard(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case "/search-flight":
        return PageTransition(
          child: SearchFlight(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      /// Shopping

      case "/shopping":
        return PageTransition(
          child: ShoppingDashboard(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case "/shopping-category":
        return PageTransition(
          child: SpecificCategoryProductList(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case "/search-product":
        return PageTransition(
          child: SearchProduct(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      /// Review

      case "/reviews":
        return PageTransition(
          child: MainReview(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case "/mix-cart-item":
        return PageTransition(
          child: MixCartItem(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case "/add-edit-user-bio":
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

      case "/general-setting":
        return PageTransition(
          child: GeneralSettingScreen(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case "/photo-viewer":
        return PageTransition(
          child: PhotoViewer(imageUrl: settings.arguments as String?),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case "/review-detail-screen":
        return PageTransition(
          child: ReviewDetailScreen(
              arguments: settings.arguments as Map<String, dynamic>),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      // case "/add-review":
      //   return PageTransition(
      //     child: AddReview(),
      //     type: PageTransitionType.bottomToTop,
      //     curve: Curves.ease,
      //     settings: settings,
      //   );

      case "/review-list-screen":
        return PageTransition(
          child: ReviewListScreen(
            arguments: settings.arguments as Map<String, dynamic>,
          ),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case "/add-review":
        return PageTransition(
          child: AddReview(
            arguments: settings.arguments as Map<String, dynamic>,
          ),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case "/edit-review":
        return PageTransition(
          child: EditUserReview(
              arguments: settings.arguments as Map<String, dynamic>),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case "/top-up-options":
        return PageTransition(
          child: TopUpOptionSelection(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      /// Custom Services
      case "/web-view":
        return PageTransition(
          child: CustomWebView(webUrl: settings.arguments as String),
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
          title: Text('Error'),
        ),
        body: Center(
          child: Text('ERROR'),
        ),
      );
    });
  }
}
