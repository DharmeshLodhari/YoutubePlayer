import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/blog/create_or_edit_post.dart';
import 'package:Slydo/screens/blog/super_blog/super_blog.dart';
import 'package:Slydo/screens/blog/user_post/models/user_post.dart';
import 'package:Slydo/screens/business/forms/add_contract.dart';
import 'package:Slydo/screens/business/forms/invoice/add_invoice.dart';
import 'package:Slydo/screens/business/forms/invoice/add_or_update_invoice_item.dart';
import 'package:Slydo/screens/business/forms/invoice/edit_invoice_item.dart';
import 'package:Slydo/screens/business/screens/contract_detail.dart';
import 'package:Slydo/screens/business/screens/contract_transaction_history.dart';
import 'package:Slydo/screens/business/screens/invoice_detail.dart';
import 'package:Slydo/screens/business/screens/invoice_screen.dart';
import 'package:Slydo/screens/connection_module/connections_dashboard.dart';
import 'package:Slydo/screens/dashboard.dart';
import 'package:Slydo/screens/explore.dart';
import 'package:Slydo/screens/home.dart';
import 'package:Slydo/screens/messaging/chat/forms/add_media_to_chat_message.dart';
import 'package:Slydo/screens/messaging/chat/forms/group/set_name_and_profile_for_group.dart';
import 'package:Slydo/screens/messaging/chat/forms/group/update_group_name_and_profile.dart';
import 'package:Slydo/screens/messaging/chat/forms/put_money_in_envelope.dart';
import 'package:Slydo/screens/messaging/chat/forms/send_envelope.dart';
import 'package:Slydo/screens/messaging/chat/screens/add_chat_group/select_user_for_group.dart';
import 'package:Slydo/screens/messaging/chat/screens/chat_screen_group_messages.dart';
import 'package:Slydo/screens/messaging/chat/screens/envelope_detail_screen.dart';
import 'package:Slydo/screens/messaging/chat/screens/group_detail_screen.dart';
import 'package:Slydo/screens/messaging/chat/screens/search_group_member.dart';
import 'package:Slydo/screens/messaging/chat/screens/view_chat_media.dart';
import 'package:Slydo/screens/messaging/detailed_message.dart';
import 'package:Slydo/screens/messaging/forms/compose_message.dart';
import 'package:Slydo/screens/messaging/message_list.dart';
import 'package:Slydo/screens/more_apps.dart';
import 'package:Slydo/screens/more_apps/bus/bus_dashboard.dart';
import 'package:Slydo/screens/more_apps/bus/search_bus.dart';
import 'package:Slydo/screens/more_apps/bus/ticket_detail.dart';
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
import 'package:Slydo/screens/more_apps/property/forms/add_property.dart';
import 'package:Slydo/screens/more_apps/property/forms/edit_property.dart';
import 'package:Slydo/screens/more_apps/property/property_dashboard.dart';
import 'package:Slydo/screens/more_apps/property/property_detail_page.dart';
import 'package:Slydo/screens/more_apps/property/search_property.dart';
import 'package:Slydo/screens/more_apps/property/specific_category_property_list.dart';
import 'package:Slydo/screens/more_apps/shopping/forms/add_product.dart';
import 'package:Slydo/screens/more_apps/shopping/forms/add_service.dart';
import 'package:Slydo/screens/more_apps/shopping/forms/add_tags.dart';
import 'package:Slydo/screens/more_apps/shopping/forms/edit_product.dart';
import 'package:Slydo/screens/more_apps/shopping/forms/edit_service.dart';
import 'package:Slydo/screens/more_apps/shopping/screens/mix_cart_item.dart';
import 'package:Slydo/screens/more_apps/shopping/screens/order/order_detail_page.dart';
import 'package:Slydo/screens/more_apps/shopping/screens/order/order_list.dart';
import 'package:Slydo/screens/more_apps/shopping/screens/order/order_preview.dart';
import 'package:Slydo/screens/more_apps/shopping/screens/order/order_status_updated.dart';
import 'package:Slydo/screens/more_apps/shopping/screens/order/track_order.dart';
import 'package:Slydo/screens/more_apps/shopping/screens/order/write_review_page.dart';
import 'package:Slydo/screens/more_apps/shopping/screens/print_qrcode.dart';
import 'package:Slydo/screens/more_apps/shopping/screens/product_and_service/product_detail_page.dart';
import 'package:Slydo/screens/more_apps/shopping/screens/product_and_service/service_detail_page.dart';
import 'package:Slydo/screens/more_apps/shopping/screens/product_and_service/social_media.dart';
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
import 'package:Slydo/screens/payment_and_banking/forms/banking/add_bank_account.dart';
import 'package:Slydo/screens/payment_and_banking/forms/banking/add_bvn_number.dart';
import 'package:Slydo/screens/payment_and_banking/forms/banking/already_have_reference.dart';
import 'package:Slydo/screens/payment_and_banking/forms/banking/payout_screen.dart';
import 'package:Slydo/screens/payment_and_banking/forms/banking/verify_reference.dart';
import 'package:Slydo/screens/payment_and_banking/forms/payment/request_payment.dart';
import 'package:Slydo/screens/payment_and_banking/forms/payment/send_payment.dart';
import 'package:Slydo/screens/payment_and_banking/screens/banking/bank_account_list.dart';
import 'package:Slydo/screens/payment_and_banking/screens/banking/card_payment_page.dart';
import 'package:Slydo/screens/payment_and_banking/screens/banking/credit_card_list.dart';
import 'package:Slydo/screens/payment_and_banking/screens/banking/credit_card_option_selection.dart';
import 'package:Slydo/screens/payment_and_banking/screens/banking/payout_transactions.dart';
import 'package:Slydo/screens/payment_and_banking/screens/banking/upgrade_account.dart';
import 'package:Slydo/screens/payment_and_banking/screens/banking/virtual_account_detail.dart';
import 'package:Slydo/screens/payment_and_banking/screens/payment/payment_request_detail_page.dart';
import 'package:Slydo/screens/payment_and_banking/screens/payment/request_payments_list.dart';
import 'package:Slydo/screens/payment_and_banking/screens/payment/transaction_detail_page.dart';
import 'package:Slydo/screens/payment_and_banking/screens/payment/transaction_graph.dart';
import 'package:Slydo/screens/payment_and_banking/screens/payment/transactions_list.dart';
import 'package:Slydo/screens/payment_link/payment_link.dart';
import 'package:Slydo/screens/review/forms/add_user_review.dart';
import 'package:Slydo/screens/review/forms/edit_user_review.dart';
import 'package:Slydo/screens/review/main_review.dart';
import 'package:Slydo/screens/review/screen/review_detail_screen.dart';
import 'package:Slydo/screens/review/screen/review_list_screen.dart';
import 'package:Slydo/screens/rider_delivery/dispatch/screens/cancellation_screen.dart';
import 'package:Slydo/screens/rider_delivery/dispatch/screens/your_trip_end_screen.dart';
import 'package:Slydo/screens/rider_delivery/screens/delivery_completed.dart';
import 'package:Slydo/screens/rider_delivery/screens/delivery_details.dart';
import 'package:Slydo/screens/rider_delivery/screens/delivery_history.dart';
import 'package:Slydo/screens/rider_delivery/screens/earning_list.dart';
import 'package:Slydo/screens/rider_delivery/screens/preview_delivery_proof_screen.dart';
import 'package:Slydo/screens/rider_delivery/screens/response_received.dart';
import 'package:Slydo/screens/rider_delivery/screens/rider_dashboard.dart';
import 'package:Slydo/screens/rider_delivery/screens/rider_earning_weekly_list.dart';
import 'package:Slydo/screens/rider_delivery/screens/rider_map_status.dart';
import 'package:Slydo/screens/rider_delivery/screens/share_experience.dart';
import 'package:Slydo/screens/rider_delivery/screens/take_delivery_proof.dart';
import 'package:Slydo/screens/rider_delivery/screens/view_completed_delivery.dart';
import 'package:Slydo/screens/rider_registration/screens/completed_upload_photo.dart';
import 'package:Slydo/screens/rider_registration/screens/preview_screen.dart';
import 'package:Slydo/screens/rider_registration/screens/require_steps.dart';
import 'package:Slydo/screens/rider_registration/screens/ride_type.dart';
import 'package:Slydo/screens/rider_registration/screens/riders_update.dart';
import 'package:Slydo/screens/rider_registration/screens/steps_info.dart';
import 'package:Slydo/screens/rider_registration/screens/take_proof_photo.dart';
import 'package:Slydo/screens/scan_product_qr.dart';
import 'package:Slydo/screens/scan_qr_code.dart';
import 'package:Slydo/screens/search_module.dart';
import 'package:Slydo/screens/service_hub/screens/contractor_payment_screen.dart';
import 'package:Slydo/screens/settings/general_setting.dart';
import 'package:Slydo/screens/shipping_process/screens/checkout_shopping_cart.dart';
import 'package:Slydo/screens/shipping_process/screens/normal_cart/confirm_order.dart';
import 'package:Slydo/screens/shipping_process/screens/normal_cart/delivery_option.dart';
import 'package:Slydo/screens/shipping_process/screens/normal_cart/shipping_option.dart';
import 'package:Slydo/screens/shipping_process/screens/normal_cart/successful_order.dart';
import 'package:Slydo/screens/shipping_process/screens/shared_cart/share_cart_details.dart';
import 'package:Slydo/screens/shipping_process/screens/shared_cart/shared_cart_members.dart';
import 'package:Slydo/screens/shipping_process/screens/shared_cart/shared_cart_payment.dart';
import 'package:Slydo/screens/startup_screen.dart';
import 'package:Slydo/screens/user_profile/forms/account_type.dart';
import 'package:Slydo/screens/user_profile/forms/add_document.dart';
import 'package:Slydo/screens/user_profile/forms/add_or_edit_user_bio.dart';
import 'package:Slydo/screens/user_profile/forms/change_password.dart';
import 'package:Slydo/screens/user_profile/forms/forgot_password.dart';
import 'package:Slydo/screens/user_profile/forms/login.dart';
import 'package:Slydo/screens/user_profile/forms/registration.dart';
import 'package:Slydo/screens/user_profile/forms/reset_device.dart';
import 'package:Slydo/screens/user_profile/forms/reset_password.dart';
import 'package:Slydo/screens/user_profile/forms/signup.dart';
import 'package:Slydo/screens/user_profile/forms/upgrade_user_profile.dart';
import 'package:Slydo/screens/user_profile/forms/user_address.dart';
import 'package:Slydo/screens/user_profile/forms/verify_registration_otp.dart';
import 'package:Slydo/screens/user_profile/forms/verify_reset_device_otp.dart';
import 'package:Slydo/screens/user_profile/forms/verify_reset_password_otp.dart';
import 'package:Slydo/screens/user_profile/screens/currency/currency_list.dart';
import 'package:Slydo/screens/user_profile/screens/custom_category/custom_category_list.dart';
import 'package:Slydo/screens/user_profile/screens/discount/discount_list.dart';
import 'package:Slydo/screens/user_profile/screens/dispatch_address/dispatch_address.dart';
import 'package:Slydo/screens/user_profile/screens/flash_tags/flash_tag_list.dart';
import 'package:Slydo/screens/user_profile/screens/shipping_options/add_shipping_options.dart';
import 'package:Slydo/screens/user_profile/screens/shipping_options/edit_shipping_options.dart';
import 'package:Slydo/screens/user_profile/screens/shipping_options/shipping_options_list.dart';
import 'package:Slydo/screens/user_profile/screens/subscriptions/choose_subscription.dart';
import 'package:Slydo/screens/user_profile/screens/user_profile_module_new/search_discount_product_and_service.dart';
import 'package:Slydo/screens/user_profile/screens/user_profile_module_new/search_users_product_and_service.dart';
import 'package:Slydo/screens/user_profile/screens/user_profile_module_new/user_profile_screen.dart';
import 'package:Slydo/screens/utility/cable/forms/select_plan_and_decoder_number.dart';
import 'package:Slydo/screens/utility/cable/screens/cable_plan_detail_page.dart';
import 'package:Slydo/screens/utility/cable/screens/cable_plan_payment_detail.dart';
import 'package:Slydo/screens/utility/cable/screens/select_cabel_plan.dart';
import 'package:Slydo/screens/utility/cable/screens/select_cabel_provider.dart';
import 'package:Slydo/screens/utility/utility_dashboard.dart';
import 'package:Slydo/screens/utility/utility_history.dart';
import 'package:Slydo/splash.dart';
import 'package:Slydo/widget/photo_viewer.dart';
import 'package:Slydo/widget/video_recorder.dart';
import 'package:Slydo/widget/webview_slydo/custom_webview.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

import '../screens/business/screens/contract_screen.dart';
import '../screens/credit_card/add_virtual_card.dart';
import '../screens/credit_card/design_virtual_card.dart';
import '../screens/credit_card/fund_virtual_card.dart';
import '../screens/credit_card/generate_debit_card.dart';
import '../screens/credit_card/search_transaction_card.dart';
import '../screens/credit_card/virtual_card_home.dart';
import '../screens/credit_card/withdraw_virtual_card.dart';
import '../screens/home_quick_view.dart';
import '../screens/more_apps/shopping/forms/product_add_on/add_on_option_list.dart';
import '../screens/more_apps/shopping/forms/product_add_on/create_add_on.dart';
import '../screens/more_apps/shopping/forms/product_add_on/product_add_on_list.dart';
import '../screens/more_apps/shopping/forms/product_add_on/product_add_on_option_create.dart';
import '../screens/more_apps/shopping/forms/product_add_on/product_add_on_option_update.dart';
import '../screens/more_apps/shopping/forms/product_add_on/update_add_on.dart';
import '../screens/more_apps/shopping/forms/product_variant/add_product_variant.dart';
import '../screens/more_apps/shopping/forms/product_variant/edit_product_variant.dart';
import '../screens/more_apps/shopping/forms/product_variant/product_variant_list.dart';
import '../screens/payment_and_banking/screens/banking/enter_address_or_pin_page.dart';
import '../screens/payment_and_banking/screens/banking/payout_transaction_detail.dart';
import '../screens/service_hub/models/active_job_listing.dart';
import '../screens/service_hub/models/jobs.dart';
import '../screens/service_hub/screens/applicant_list.dart';
import '../screens/service_hub/screens/categories_list.dart';
import '../screens/service_hub/screens/category_jobs_list.dart';
import '../screens/service_hub/screens/create_jobs.dart';
import '../screens/service_hub/screens/edit_job.dart';
import '../screens/service_hub/screens/job_detail.dart';
import '../screens/service_hub/screens/job_search.dart';
import '../screens/service_hub/screens/my_job_details.dart';
import '../screens/service_hub/screens/my_jobs_list.dart';
import '../screens/service_hub/screens/preview_job_detail.dart';
import '../screens/service_hub/screens/search_filter.dart';
import '../screens/service_hub/screens/search_my_job.dart';
import '../screens/service_hub/screens/search_services.dart';
import '../screens/service_hub/service_hub_dashboard.dart';
import '../screens/super_store/near_by_list_screen.dart';
import '../screens/super_store/search_nearby_business.dart';
import '../screens/super_store/super_store.dart';
import '../screens/user_profile/screens/customize_profile/customize_profile.dart';
import '../screens/user_profile/screens/subscriptions/pre_account_upgrade.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Getting arguments passed in while calling Navigator.pushNamed
    switch (settings.name) {
      case Routes.LOGIN:
        return PageTransition(
          child: UserLogin(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.RESET_DEVICE:
        return PageTransition(
          child: const ResetDevice(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.SPLASH:
        return PageTransition(
          child: const SplashScreen(),
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
          child: const Registration(),
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
          child: const AddDocument(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.HOME:
        return PageTransition(
          child: const Home(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.ACCOUNTS:
        return PageTransition(
          child: const PaymentRequestList(),
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
          child: const TransactionGraph(),
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
      case Routes.PAYMENT_REQUEST_DETAIL:
        return PageTransition(
          child: PaymentRequestDetail(
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
          child: const AddAccount(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.CONTRACTOR_SCREEN:
        return PageTransition(
          child: ContractorPaymentScreen(
            arguments: settings.arguments,
          ),
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
      case Routes.PAYMENT_LINK:
        return PageTransition(
          child: PaymentLink(),
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
          child: const ExploreList(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.USER_PROFILE:
        return PageTransition(
          child: UserProfileScreen(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.SUPER_BLOG:
        return PageTransition(
          child: const SuperBlog(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.CREATE_BLOG:
        // final args = settings.arguments as Map<String, dynamic>;

        return PageTransition(
          child: CreateOrEditPostScreen(
            userPost: settings.arguments != null
                ? settings.arguments as UserPost
                : null,
            // channel: args['channel'],
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
          child: SearchUsersProductAndService(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.PRODUCT:
        return PageTransition(
          child: ProductDetailPage(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.ADD_PRODUCT:
        return PageTransition(
          child: AddProduct(
            arguments: settings.arguments,
          ),
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
          child: const AddService(),
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
          child: const MessageList(),
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
          child: const AddAccount(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.BANK_ACCOUNT_LIST:
        return PageTransition(
          child: const BankAccountList(),
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
      case Routes.SCAN_PRODUCT_QR:
        return PageTransition(
          child: const ScanProductQr(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.PAYOUT:
        return PageTransition(
          child: const PayoutScreen(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.PAYOUT_LIST:
        return PageTransition(
          child: const PayoutTransactions(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.FORGOT_PASSWORD:
        return PageTransition(
          child: const ForgotPassword(),
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
          child: const ChangePassword(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.SHOPPING_CART:
        return PageTransition(
          child: const ShoppingCart(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.ORDER_LIST:
        return PageTransition(
          child: const OrderList(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.ORDER_UPDATED:
        return PageTransition(
          child: OrderStatusUpdated(arguments: settings.arguments),
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
      case Routes.TRACK_ORDER:
        return PageTransition(
          child: TrackOrder(arguments: settings.arguments),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.WRITE_REVIEW_PAGE:
        return PageTransition(
          child: WriteReviewPage(arguments: settings.arguments),
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
          child: const UserAddress(),
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
          child: const UpgradeUserProfile(),
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
          child: const CreditCardOptionSelection(),
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
          child: const VirtualAccountDetail(),
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
          child: const AlreadyHaveReferenceScreen(),
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

      case Routes.ADD_CONTRACT:
        return PageTransition(
          child: const AddContract(),
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
          child: const ContractTransactionHistory(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.ADD_INVOICE:
        return PageTransition(
          child: const AddInvoice(),
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
          child: const UtilityDashboard(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.UTILITY_HISTORY:
        return PageTransition(
          child: const UtilityHistory(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.CABLE_PROVIDER:
        return PageTransition(
          child: const SelectCableProvider(),
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
          child: const MoreApps(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      /// Services Route ///

      case Routes.SUPER_HUB:
        return PageTransition(
          child: ServiceHubDashboard(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.SEARCH_MY_JOBS:
        return PageTransition(
            child: const SearchMyJobs(),
            type: PageTransitionType.bottomToTop,
            curve: Curves.ease,
            settings: settings);

      case Routes.SEARCH_SERVICES:
        return PageTransition(
            child: const SearchServices(),
            type: PageTransitionType.bottomToTop,
            curve: Curves.ease,
            settings: settings);

      /// Movie Route

      case Routes.TAXI:
        return PageTransition(
          child: const TaxiDashboard(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.SELECT_DESTINATION_FOR_TAXI_RIDE:
        return PageTransition(
          child: const SelectAddressScreen(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.SELECT_RIDE_TYPE:
        final arguments = settings.arguments as Map<String, dynamic>;
        return PageTransition(
          child: const RideOption(),
          childCurrent: arguments['currentChild'],
          type: PageTransitionType.rightToLeftJoined,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.SEARCH_DRIVER:
        final arguments = settings.arguments as Map<String, dynamic>;
        return PageTransition(
          child: const SearchingForRide(),
          childCurrent: arguments['currentChild'],
          type: PageTransitionType.rightToLeftJoined,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.DRIVER_ARRIVING:
        return PageTransition(
          child: const ArrivingDriver(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.TRIP_ENDED:
        return PageTransition(
          child: const TripEnded(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.PAYMENT_OPTIONS:
        return PageTransition(
          child: const PaymentOptions(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.NO_VEHICLE_FOUND:
        return PageTransition(
          child: const NoVehicleFound(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.TERMS_AND_CONDITION:
        return PageTransition(
          child: const TermsAndCondition(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.RATE_AND_TIP_DRIVER:
        return PageTransition(
          child: const RateAndTipDriver(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.CANCEL_BOOKING:
        return PageTransition(
          child: const CancelBooking(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.CONTACT_DRIVER:
        return PageTransition(
          child: const ContactDriver(),
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
            child: const JobsCreateJobs(),
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
            child: JobsSearch(
                filterMap: settings.arguments as Map<String, dynamic>?),
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
          child: const MovieDashboard(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.MOVIE_CATEGORY:
        return PageTransition(
          child: const SpecificCategoryMovieList(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.SEARCH_MOVIE:
        return PageTransition(
          child: const SearchMovie(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.MOVIE_DETAIL:
        return PageTransition(
          child: const MovieDetailPage(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      /// Music

      case Routes.MUSICS:
        return PageTransition(
          child: const MusicDashboard(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.MUSIC_CATEGORY:
        return PageTransition(
          child: const SpecificCategoryMusicList(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.SEARCH_MUSIC:
        return PageTransition(
          child: const SearchMusic(),
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
          child: const EventDashboard(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.EVENT_CATEGORY:
        return PageTransition(
          child: const SpecificCategoryEventList(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.SEARCH_EVENT:
        return PageTransition(
          child: const SearchEvent(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.EVENT_DETAIL:
        return PageTransition(
          child: const EventDetailPage(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.EVENT_TICKET_DETAIL:
        return PageTransition(
          child: const EventTicketDetail(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      /// Hotel Route

      case Routes.HOTELS:
        return PageTransition(
          child: const HotelDashboard(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.HOTEL_CATEGORY:
        return PageTransition(
          child: const SpecificCategoryHotelList(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.SEARCH_HOTEL:
        return PageTransition(
          child: const SearchHotel(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.HOTEL_DETAIL:
        return PageTransition(
          child: const HotelDetailPage(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.HOTEL_TICKET_DETAIL:
        return PageTransition(
          child: const EventTicketDetail(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.PARTNER_DETAIL:
        return PageTransition(
          child: const PartnerDetailPage(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      /// Property Route

      case Routes.PROPERTY:
        return PageTransition(
          child: const PropertyDashboard(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.PROPERTY_CATEGORY:
        return PageTransition(
          child: const SpecificCategoryPropertyList(),
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
          child: const PropertyDetailPage(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.ADD_PROPERTY:
        return PageTransition(
          child: const AddProperty(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.EDIT_PROPERTY:
        return PageTransition(
          child: const EditProperty(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      /// News

      case Routes.NEWS:
        return PageTransition(
          child: const NewsDashboard(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.NEWS_DETAIL:
        return PageTransition(
          child: const NewsDetailPage(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      /// Bus

      case Routes.BUS:
        return PageTransition(
          child: const BusDashboard(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.SEARCH_BUS:
        return PageTransition(
          child: const SearchBus(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.TICKET_DETAIL:
        return PageTransition(
          child: const TicketDetail(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      /// Train

      case Routes.TRAIN:
        return PageTransition(
          child: const TrainDashboard(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.SEARCH_TRAIN:
        return PageTransition(
          child: const SearchTrain(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      /// Flight

      case Routes.FLIGHT:
        return PageTransition(
          child: const FlightDashboard(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.SEARCH_FLIGHT:
        return PageTransition(
          child: const SearchFlight(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      /// Shopping

      case Routes.SUPER_STORE:
        return PageTransition(
          child: SuperStore(arguments: settings.arguments),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.SHOPPING_CATEGORY:
        return PageTransition(
          child: const SpecificCategoryProductList(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.SEARCH_PRODUCT:
        return PageTransition(
          child: SearchProduct(arguments: settings.arguments),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.SEARCH_NEAR_BY_BUSINESS:
        return PageTransition(
          child: const SearchNearByBusiness(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      /// Review

      case Routes.REVIEWS:
        return PageTransition(
          child: const MainReview(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.MIX_CART_ITEM:
        return PageTransition(
          child: const MixCartItem(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.ADD_EDIT_USER_BIO:
        return PageTransition(
          child: const AddOrEditUserBioScreen(),
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
          child: const GeneralSettingScreen(),
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
          child: const ShippingOptionsList(),
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
          child: AddProductVariant(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.PRODUCT_VARIANT_UPDATE:
        return PageTransition(
          child: EditProductVariant(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.VIRTUAL_CARD_HOME:
        return PageTransition(
          child: const VirtualCardHome(),
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

      case Routes.CUSTOMIZE_PROFILE:
        return PageTransition(
          child: CustomizeProfileScreen(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.HOME_QUICK_VIEW:
        return PageTransition(
          child: HomeQuickView(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.PRE_ACCOUNT_UPGRADE:
        return PageTransition(
          child: const PreAccountUpgrade(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.PRODUCT_ADD_ON_LIST:
        return PageTransition(
          child: ProductAddOnList(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.ADD_ON_OPTION_LIST:
        return PageTransition(
          child: AddOnOptionList(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.PRODUCT_ADD_ON_OPTION_CREATE:
        return PageTransition(
          child: ProductAddOnOptionCreate(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.PRODUCT_ADD_ON_OPTION_UPDATE:
        return PageTransition(
          child: ProductAddOnOptionUpdate(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.NEW_ADD_ON:
        return PageTransition(
          child: CreateAddOn(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      case Routes.UPDATE_ADD_ON:
        return PageTransition(
          child: UpdateAddOn(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      /// Discount
      case Routes.DISCOUNT_LIST:
        return PageTransition(
          child: const DiscountList(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      /// Discount
      case Routes.DISPATCH_ADDRESS:
        return PageTransition(
          child: DispatchAddress(arguments: settings.arguments),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      /// Custom Category
      case Routes.CUSTOM_CATEGORY:
        return PageTransition(
          child: CustomCategoryList(arguments: settings.arguments),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      /// FLASH tags
      case Routes.FLASH_TAG_LIST:
        return PageTransition(
          child: FlashTagList(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      /// Rider Dileviry
      case Routes.RIDER_JOB_DETAILS:
        return PageTransition(
          child: DeliveryDetails(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.TAKE_DELIVERY_PROOF:
        return PageTransition(
          child: const TakeDeliveryProof(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.PREVIEW_DELIVERY_PROOF_SCREEN:
        return PageTransition(
          child: PreviewDeliveryProofScreen(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      // case Routes.TAKE_PICTURE:
      //   return PageTransition(
      //     child: TakePicture(),
      //     type: PageTransitionType.bottomToTop,
      //     curve: Curves.ease,
      //     settings: settings,
      //   );

      /// Shipping Process
      case Routes.CONFIRM_ORDER:
        return PageTransition(
          child: ConfirmOrder(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.DELIVERY_OPTION:
        return PageTransition(
          child: const DeliveryOption(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.SHIPPING_OPTION:
        return PageTransition(
          child: const ShippingOption(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.SUCCESSFUL_ORDER:
        return PageTransition(
          child: const SuccessfulOrder(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );

      ///Rider Registration
      case Routes.RIDE_TYPE:
        return PageTransition(
          child: const RideType(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.REQUIRE_STEPS:
        return PageTransition(
          child: const RequireSteps(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.STEPS_INFO:
        return PageTransition(
          child: const StepsInfo(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.TAKE_PROOF_PHOTO:
        return PageTransition(
          child: const TakeProofPhoto(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.PREVIEW_SCREEN:
        return PageTransition(
          child: const PreviewScreen(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.COMPLETED_UPLOAD_PHOTO:
        return PageTransition(
          child: const CompletedUploadPhoto(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.VIEW_COMPLETED_DELIVERY:
        return PageTransition(
          child: ViewCompletedDelivery(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.DELIVERY_COMPLETED:
        return PageTransition(
          child: DeliveryCompleted(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.RESPONSE_RECEIVED:
        return PageTransition(
          child: const ResponseReceived(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.SHARE_EXPERIENCE:
        return PageTransition(
          child: const ShareExperience(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.RIDER_DASHBOARD:
        return PageTransition(
          child: const RiderDashboard(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.RIDER_EARNING_WEEKLY_LIST:
        return PageTransition(
          child: const RiderEarningWeeklyList(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.EARNING_LIST:
        return PageTransition(
          child: const EarningList(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.DELIVERY_HISTORY:
        return PageTransition(
          child: const DeliveryHistory(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.RIDERS_UPDATE:
        return PageTransition(
          child: const RidersUpdate(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.ADD_TAGS:
        return PageTransition(
          child: AddTags(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.SHARED_CARD_DETAILS:
        return PageTransition(
          child: const SharedCartDetails(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.SHARED_CART_MEMBERS:
        return PageTransition(
          child: const SharedCartMembers(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.SHARED_CART_PAYMENT:
        return PageTransition(
          child: const SharedCartPayment(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.RIDER_MAP_STATUS:
        return PageTransition(
          child: RiderMapStatus(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.CANCELLATION:
        return PageTransition(
          child: const CancellationScreen(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.YOU_TRIP_END:
        return PageTransition(
          child: const YourTripEndScreen(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.DISCOUNT_PRODUCT_AND_SERVICE_SEARCH:
        return PageTransition(
          child: SearchDiscountProductAndService(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      // Order Preview
      case Routes.ORDER_PREVIEW:
        return PageTransition(
          child: OrderPreview(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.PRODUCT_AND_SERVICE_SOCIAL_MEDIA:
        return PageTransition(
          child: SocialMedia(
            arguments: settings.arguments,
          ),
          type: PageTransitionType.bottomToTop,
          curve: Curves.ease,
          settings: settings,
        );
      case Routes.CURRENCY_LIST:
        return PageTransition(
          child: const CurrencyList(),
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
