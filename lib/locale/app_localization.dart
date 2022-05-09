import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/messages_all.dart';

class AppLocalization {
  static Future<AppLocalization> load(Locale locale) {
    final String name =
        locale.countryCode!.isEmpty ? locale.languageCode : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      return AppLocalization();
    });
  }

  static AppLocalization? of(BuildContext context) {
    return Localizations.of<AppLocalization>(context, AppLocalization);
  }

  //FORMS
  //add_bank_account
  String get addBankAccountMsg {
    return Intl.message(
      'Add A Bank Account',
      name: 'addBankAccountMsg',
    );
  }

  String get setDefaultAccountMsg {
    return Intl.message(
      'Set as default account',
      name: 'setDefaultAccountMsg',
    );
  }

  String get accountNameHint {
    return Intl.message(
      'Account Name',
      name: 'accountNameHint',
    );
  }

  String get validationTextMessage {
    return Intl.message(
      "Enter a valid name matching account number.",
      name: "validationTextMessage",
    );
  }

  String get accountNumber {
    return Intl.message(
      "Account Number",
      name: "accountNumber",
    );
  }

  String get validationTextMessage1 {
    return Intl.message(
      "Enter a valid account number.",
      name: "validationTextMessage1",
    );
  }

  String get errorMsg1 {
    return Intl.message(
      "An error has occured please try again",
      name: "errorMsg1",
    );
  }

  String get errorMsg2 {
    return Intl.message(
      "Invalid Bank Details !!",
      name: "errorMsg2",
    );
  }

  String get submit {
    return Intl.message(
      "Submit",
      name: "submit",
    );
  }

  //add_document

  String get verifyYourSelfMsg {
    return Intl.message(
      "Verify Yourself",
      name: "verifyYourSelfMsg",
    );
  }

  String get passportMsg {
    return Intl.message(
      "Passport",
      name: "passportMsg",
    );
  }

  String get facePhotoPage {
    return Intl.message(
      "Face photo page",
      name: "facePhotoPage",
    );
  }

  String get driverLicence {
    return Intl.message(
      "Driver's License",
      name: "driverLicence",
    );
  }

  String get frontAndBack {
    return Intl.message(
      "Front and Back",
      name: "frontAndBack",
    );
  }

  String get identityCard {
    return Intl.message(
      "Identical Card",
      name: "identityCard",
    );
  }

  String get verifyYourIdentity {
    return Intl.message(
      "Verify Your Identity",
      name: "verifyYourIdentity",
    );
  }

  String get selectTypeOfDocument {
    return Intl.message(
      "select the type of document you want to upload",
      name: "selectTypeOfDocument",
    );
  }

  String get passportPhotoPage {
    return Intl.message(
      "Passport Photo page",
      name: "passportPhotoPage",
    );
  }

  String get needToUseYourMobileToTake {
    return Intl.message(
      "Need to use your mobile to take photos?",
      name: "needToUseYourMobileToTake",
    );
  }

  String get tapHereToContinue {
    return Intl.message(
      "Tap hear to continue",
      name: "tapHereToContinue",
    );
  }

  String get uploadPhotoFromDevice {
    return Intl.message(
      "Upload photo from your device",
      name: "uploadPhotoFromDevice",
    );
  }

  String get next {
    return Intl.message(
      "Next",
      name: "next",
    );
  }

  String get userPhotoPage {
    return Intl.message(
      "User Photo page",
      name: "userPhotoPage",
    );
  }

  String get previous {
    return Intl.message(
      "Previous",
      name: "previous",
    );
  }

  String get finish {
    return Intl.message(
      "Finish",
      name: "finish",
    );
  }

  //compose_message.dart
  String get composeMessage {
    return Intl.message(
      "Compose Message",
      name: "composeMessage",
    );
  }

  String get invalidRecipient {
    return Intl.message(
      "Invalid recipient",
      name: "invalidRecipient",
    );
  }

  String get addItems {
    return Intl.message(
      "Add Items",
      name: "addItems",
    );
  }

  String get selectPaymentDuration {
    return Intl.message(
      "Please select a payment duration",
      name: "selectPaymentDuration",
    );
  }

  String get recipient {
    return Intl.message(
      "Recipient",
      name: "recipient",
    );
  }

  String get subject {
    return Intl.message(
      "Subject",
      name: "subject",
    );
  }

  String get typeYourMsgHere {
    return Intl.message(
      "Type your message here....",
      name: "typeYourMsgHere",
    );
  }

  //forgot_password
  String get forgotPassword {
    return Intl.message(
      "Forgot Password",
      name: "forgotPassword",
    );
  }

  String get enterYourPhoneNumber {
    return Intl.message(
      "Enter Your Phone Number",
      name: "enterYourPhoneNumber",
    );
  }

  String get invalidPhoneNumber {
    return Intl.message(
      "Invalid phone number",
      name: "invalidPhoneNumber",
    );
  }

  String get enterYourOtpHere {
    return Intl.message(
      "Enter Your OTP Here",
      name: "enterYourOtpHere",
    );
  }

  String get pleaseEnterOtp {
    return Intl.message(
      "Please Enter OTP",
      name: "pleaseEnterOtp",
    );
  }

  String get invalidOtp {
    return Intl.message(
      "Invalid OTP",
      name: "invalidOtp",
    );
  }

  String get verifyOtp {
    return Intl.message(
      "Verify OTP",
      name: "verifyOtp",
    );
  }

  String get continueMsg {
    return Intl.message(
      "Continue",
      name: "continueMsg",
    );
  }

  //login
  String get login {
    return Intl.message(
      "Login",
      name: "login",
    );
  }

  String get phoneNumber {
    return Intl.message(
      "Phone Number",
      name: "phoneNumber",
    );
  }

  String get searchPageTextFieldHint {
    return Intl.message(
      "Username, phone number, nickname",
      name: "searchPageTextFieldHint",
    );
  }

  String get password {
    return Intl.message(
      "Password",
      name: "password",
    );
  }

  String get invalidPassword {
    return Intl.message(
      "Invalid Password",
      name: "invalidPassword",
    );
  }

  String get rememberMe {
    return Intl.message(
      "Remember Me",
      name: "rememberMe",
    );
  }

  String get userIsNotRegistered {
    return Intl.message(
      "User is Not Registerd !!",
      name: "userIsNotRegistered",
    );
  }

  String get userIsNotSaved {
    return Intl.message(
      "User Not Saved !!!",
      name: "userIsNotSaved",
    );
  }

  String get navigate {
    return Intl.message(
      "NAVIGATE",
      name: "navigate",
    );
  }

  String get cancel {
    return Intl.message(
      "CANCEL",
      name: "cancel",
    );
  }

  //payout
  String get payout {
    return Intl.message(
      "Payout",
      name: "payout",
    );
  }

  String get enterAmount {
    return Intl.message(
      "Enter Amount",
      name: "enterAmount",
    );
  }

  String get invalidAmount {
    return Intl.message(
      "Invalid Amount",
      name: "invalidAmount",
    );
  }

  String get invalidFormat {
    return Intl.message(
      "Invalid Format",
      name: "invalidFormat",
    );
  }

  String get invalidDate {
    return Intl.message(
      "Invalid Date",
      name: "invalidDate",
    );
  }

  String get serverError {
    return Intl.message(
      "Server Error Please try again after some time !",
      name: "serverError",
    );
  }

  String get somethingWentWrong {
    return Intl.message(
      "Something went Wrong !!",
      name: "somethingWentWrong",
    );
  }

  String get noteForUser {
    return Intl.message(
      "you are about to transfer money into your bank account",
      name: "noteForUser",
    );
  }

  // registration
  String get signUp {
    return Intl.message(
      "Sign Up",
      name: "signUp",
    );
  }

  String get selectYourCountry {
    return Intl.message(
      "Select your Country",
      name: "selectYourCountry",
    );
  }

  String get search {
    return Intl.message(
      "Search",
      name: "search",
    );
  }

  String get chat {
    return Intl.message(
      "Chat",
      name: "chat",
    );
  }

  String get kycDetails {
    return Intl.message(
      "KYC Details",
      name: "kycDetails",
    );
  }

  String get bvnStatus {
    return Intl.message(
      "BVN Status",
      name: "bvnStatus",
    );
  }

  String get documentResult {
    return Intl.message(
      "Document result",
      name: "documentResult",
    );
  }

  String get remark {
    return Intl.message(
      "Remark",
      name: "remark",
    );
  }

  String get selectYourPhoneCode {
    return Intl.message(
      "Select your phone code",
      name: "selectYourPhoneCode",
    );
  }

  //request_payment
  String get requestPayment {
    return Intl.message(
      "Request Payment",
      name: "requestPayment",
    );
  }

  String get reference {
    return Intl.message(
      "Reference",
      name: "reference",
    );
  }

  String get requestNotSend {
    return Intl.message(
      "Request not send",
      name: "requestNotSend",
    );
  }

  // reset_password
  String get resetPassword {
    return Intl.message(
      "Reset Password",
      name: "resetPassword",
    );
  }

  String get newPassword {
    return Intl.message(
      "New Password",
      name: "newPassword",
    );
  }

  String get passwordShouldNotEmpty {
    return Intl.message(
      "Password Should Not Empty",
      name: "passwordShouldNotEmpty",
    );
  }

  String get passwordMustBeOfFourDigit {
    return Intl.message(
      "Password Must Be Of 4 Digit",
      name: "passwordMustBeOfFourDigit",
    );
  }

  String get confirmPassword {
    return Intl.message(
      "Confirm Password",
      name: "confirmPassword",
    );
  }

  String get passwordMismatch {
    return Intl.message(
      "Password Mismatch",
      name: "passwordMismatch",
    );
  }

  String get sendPayment {
    return Intl.message(
      "Send Payment",
      name: "sendPayment",
    );
  }

  String get makePayment {
    return Intl.message(
      "Make Payment",
      name: "makePayment",
    );
  }

  String get paySomeone {
    return Intl.message(
      "Pay someone",
      name: "paySomeone",
    );
  }

  String get useFourDigitNumber {
    return Intl.message(
      "Use 4 Digit Number",
      name: "useFourDigitNumber",
    );
  }

  String get termsAndCondition {
    return Intl.message(
      "By clicking Register you are agreeing to the Terms and Conditions.",
      name: "termsAndCondition",
    );
  }

  String get fullName {
    return Intl.message(
      "Full Name",
      name: "fullName",
    );
  }

  String get enterValidNameMatchingAccountNumber {
    return Intl.message(
      "Enter a valid name matching account number.",
      name: "enterValidNameMatchingAccountNumber",
    );
  }

  String get register {
    return Intl.message(
      "Register",
      name: "register",
    );
  }

  String get invalidDetails {
    return Intl.message(
      "Invalid Details !!",
      name: "invalidDetails",
    );
  }

  //TILES
  //bank account
  String get accountBalance {
    return Intl.message(
      "Account Balance",
      name: "accountBalance",
    );
  }

  String get wrongPassword {
    return Intl.message(
      "Wrong Password !!",
      name: "wrongPassword",
    );
  }

  //message
  String get star {
    return Intl.message(
      "star",
      name: "star",
    );
  }

  String get unstar {
    return Intl.message(
      "unstar",
      name: "unstar",
    );
  }

  //payout_tile
  String get date {
    return Intl.message(
      "Date",
      name: "date",
    );
  }

  String get time {
    return Intl.message(
      "Time",
      name: "time",
    );
  }

  //SCREENS
  // bank_account_list
  String get internetConnectionNotAvailable {
    return Intl.message(
      "Internet Connection is not available",
      name: "internetConnectionNotAvailable",
    );
  }

  String get bankAccount {
    return Intl.message(
      "Bank Account",
      name: "bankAccount",
    );
  }

  String get cards {
    return Intl.message(
      "Cards",
      name: "cards",
    );
  }

  String get creditCards {
    return Intl.message(
      "Credit Cards",
      name: "creditCards",
    );
  }

  String get cashOut {
    return Intl.message(
      "Cashout",
      name: "cashOut",
    );
  }

  String get myCreditAndDebitCards {
    return Intl.message(
      "My Credit/Debit Cards",
      name: "myCreditAndDebitCards",
    );
  }

  String get addPaymentCard {
    return Intl.message(
      "Add Payment Card",
      name: "addPaymentCard",
    );
  }

  String get wallet {
    return Intl.message(
      "Wallet",
      name: "wallet",
    );
  }

  String get walletFunding {
    return Intl.message(
      "Wallet Funding",
      name: "walletFunding",
    );
  }

  String get youWillGetAmount {
    return Intl.message(
      "You will get following amount in your card",
      name: "youWillGetAmount",
    );
  }

  String get youCanAddMaximumTwoAccount {
    return Intl.message(
      "You can add maximum two bank account",
      name: "youCanAddMaximumTwoAccount",
    );
  }

  String get youCanAddMaximumTwoCreditCards {
    return Intl.message(
      "You can add maximum two credit cards",
      name: "youCanAddMaximumTwoCreditCards",
    );
  }

  String get youDontHaveAnyAccountPleaseAddOne {
    return Intl.message(
      "You Don't have any Bank Account Please Add one",
      name: "youDontHaveAnyAccountPleaseAddOne",
    );
  }

  String get youDontHaveAnyCreditCardPleaseAddOne {
    return Intl.message(
      "You don't have any credit card. Please Add one.",
      name: "youDontHaveAnyCreditCardPleaseAddOne",
    );
  }

  String get youHaveReachedBottomOfTheList {
    return Intl.message(
      "Your have reached the end of the list",
      name: "youHaveReachedBottomOfTheList",
    );
  }

  String get defaultMsg {
    return Intl.message(
      "Default",
      name: "defaultMsg",
    );
  }

  String get delete {
    return Intl.message(
      "Delete",
      name: "delete",
    );
  }

  String get youCanNotDeleteOnlyBankAccount {
    return Intl.message(
      "You can not delete your only bank account",
      name: "youCanNotDeleteOnlyBankAccount",
    );
  }

  String get youCanNotDeleteOnlyCreditAccount {
    return Intl.message(
      "You can not delete your only credit card",
      name: "youCanNotDeleteOnlyCreditAccount",
    );
  }

  String get accountDeletedSuccessfully {
    return Intl.message(
      "Account Deleted Successfully",
      name: "accountDeletedSuccessfully",
    );
  }

  String get cardDeletedSuccessfully {
    return Intl.message(
      "Credit Card Deleted Successfully",
      name: "cardDeletedSuccessfully",
    );
  }

  String get accountIsNotDeleted {
    return Intl.message(
      "Account is not deleted !!",
      name: "accountIsNotDeleted",
    );
  }

  String get cardIsNotDeleted {
    return Intl.message(
      "Credit Card not deleted !!",
      name: "cardIsNotDeleted",
    );
  }

  String get makeDefault {
    return Intl.message(
      "Make default",
      name: "makeDefault",
    );
  }

  String get thisAccountIsAlreadyDefaultAccount {
    return Intl.message(
      "This Account is already the default Account",
      name: "thisAccountIsAlreadyDefaultAccount",
    );
  }

  String get thisCardIsAlreadyDefaultCard {
    return Intl.message(
      "This credit card is already the default card",
      name: "thisCardIsAlreadyDefaultCard",
    );
  }

  String get accountUpdatedSuccessfully {
    return Intl.message(
      "Account updated successfully !!",
      name: "accountUpdatedSuccessfully",
    );
  }

  String get creditCardUpdatedSuccessfully {
    return Intl.message(
      "Credit Card updated successfully !!",
      name: "creditCardUpdatedSuccessfully",
    );
  }

  String get accountIsNotUpdated {
    return Intl.message(
      "Account is not updated !!",
      name: "accountIsNotUpdated",
    );
  }

  String get cardNotUpdated {
    return Intl.message(
      "Credit Card not updated !!",
      name: "cardNotUpdated",
    );
  }

  //dashboard
  String get home {
    return Intl.message(
      "Home",
      name: "home",
    );
  }

  String get requests {
    return Intl.message(
      "Requests",
      name: "requests",
    );
  }

  String get qrCode {
    return Intl.message(
      "QR Code",
      name: "qrCode",
    );
  }

  String get transactions {
    return Intl.message(
      "Transactions",
      name: "transactions",
    );
  }

  String get messages {
    return Intl.message(
      "Messages",
      name: "messages",
    );
  }

  String get settings {
    return Intl.message(
      "Settings",
      name: "settings",
    );
  }

  //detailed_message
  String get message {
    return Intl.message(
      "Message",
      name: "message",
    );
  }

  String get pay {
    return Intl.message(
      "Pay",
      name: "pay",
    );
  }

  String get to {
    return Intl.message(
      "To",
      name: "to",
    );
  }

  String get unarchive {
    return Intl.message(
      "unarchive",
      name: "unarchive",
    );
  }

  String get archive {
    return Intl.message(
      "Archive",
      name: "archive",
    );
  }

  String get reply {
    return Intl.message(
      "Reply",
      name: "reply",
    );
  }

  //explore
  String get explore {
    return Intl.message(
      "Explore",
      name: "explore",
    );
  }

  String get exit {
    return Intl.message(
      "Exit",
      name: "exit",
    );
  }

  String get choosePlan {
    return Intl.message(
      "Choose Plan",
      name: "choosePlan",
    );
  }

  String get areYouSureWantToExit {
    return Intl.message(
      "Are You Sure Want To Exit?",
      name: "areYouSureWantToExit",
    );
  }

  String get yes {
    return Intl.message(
      "Yes",
      name: "yes",
    );
  }

  String get no {
    return Intl.message(
      "No",
      name: "no",
    );
  }

  String get copied {
    return Intl.message(
      "Copied!",
      name: "copied",
    );
  }

  String get copyUrl {
    return Intl.message(
      "Copy Url",
      name: "copyUrl",
    );
  }

  String get request {
    return Intl.message(
      "Request",
      name: "request",
    );
  }

  String get send {
    return Intl.message(
      "Send",
      name: "send",
    );
  }

  //index
  String get scanQrCode {
    return Intl.message(
      "Scan QR Code",
      name: "scanQrCode",
    );
  }

  String get introMsg1 {
    return Intl.message(
      "Slydo allows you to send and receive\npayments instantly in Africa",
      name: "introMsg1",
    );
  }

  String get introMsg2 {
    return Intl.message(
      "Slydo allows you to send and receive\npayments instantly in Africa",
      name: "introMsg2",
    );
  }

  String get viewTransactions {
    return Intl.message(
      "View transactions",
      name: "viewTransactions",
    );
  }

  String get anEasyWayToAcceptAndReceivePayment {
    return Intl.message(
      "An easy way to accept \n and receive payments.",
      name: "anEasyWayToAcceptAndReceivePayment",
    );
  }

  String get skip {
    return Intl.message(
      "Skip",
      name: "skip",
    );
  }

  String get done {
    return Intl.message(
      "Done",
      name: "done",
    );
  }

  // messageList
  String get filter {
    return Intl.message(
      "Filter",
      name: "filter",
    );
  }

  String get all {
    return Intl.message(
      "All",
      name: "all",
    );
  }

  String get archived {
    return Intl.message(
      "Archived",
      name: "archived",
    );
  }

  String get sent {
    return Intl.message(
      "Sent",
      name: "sent",
    );
  }

  String get starred {
    return Intl.message(
      "Starred",
      name: "starred",
    );
  }

  String get noMessages {
    return Intl.message(
      "No Messages",
      name: "noMessages",
    );
  }

  String get areYouSureWantToDeleteThisMsg {
    return Intl.message(
      "Are you sure want to delete this Message?",
      name: "areYouSureWantToDeleteThisMsg",
    );
  }

  String get messageIsDeletedSuccessfully {
    return Intl.message(
      "Message is deleted successfully!!",
      name: "messageIsDeletedSuccessfully",
    );
  }

  String get error {
    return Intl.message(
      "Error",
      name: "error",
    );
  }

  //payout_transactions
  String get bankPayout {
    return Intl.message(
      "Bank Payout",
      name: "bankPayout",
    );
  }

  String get payoutHistoryEmpty {
    return Intl.message(
      "Payout history empty !!",
      name: "payoutHistoryEmpty",
    );
  }

  //request_payment_list
  String get paymentRequests {
    return Intl.message(
      "Payment Requests",
      name: "paymentRequests",
    );
  }

  String get noPendingPaymentRequest {
    return Intl.message(
      "No Pending Payment Request",
      name: "noPendingPaymentRequest",
    );
  }

  String get reject {
    return Intl.message(
      "Reject",
      name: "reject",
    );
  }

  String get sendMoney {
    return Intl.message(
      "Send Money",
      name: "sendMoney",
    );
  }

  String get accept {
    return Intl.message(
      "Accept",
      name: "accept",
    );
  }

  String get areYouSureWantToAcceptThisRequest {
    return Intl.message(
      "Are you sure want to Accept this request?",
      name: "areYouSureWantToAcceptThisRequest",
    );
  }

  String get paymentRequestAccepted {
    return Intl.message(
      "Payment Request Accepted !!",
      name: "paymentRequestAccepted",
    );
  }

  String get areYouSureWantToRejectThisPayment {
    return Intl.message(
      "Are you sure want to reject this request?",
      name: "areYouSureWantToRejectThisPayment",
    );
  }

  String get paymentRequestRejected {
    return Intl.message(
      "Payment Request Rejected !!",
      name: "paymentRequestRejected",
    );
  }

  //scan_qr_code
  String get flip {
    return Intl.message(
      "Flip",
      name: "flip",
    );
  }

  //search_auto_complete
  String get users {
    return Intl.message(
      "Users",
      name: "users",
    );
  }

  String get products {
    return Intl.message(
      "Products",
      name: "products",
    );
  }

  String get services {
    return Intl.message(
      "Services",
      name: "services",
    );
  }

  String get find {
    return Intl.message(
      "Find",
      name: "find",
    );
  }

  String get pleaseTypeSomethingToGetResult {
    return Intl.message(
      "Please type something to get results",
      name: "pleaseTypeSomethingToGetResult",
    );
  }

  String get noResultFound {
    return Intl.message(
      "No Result Found!",
      name: "noResultFound",
    );
  }

  //setting
  String get appVersion {
    return Intl.message(
      "App Version",
      name: "appVersion",
    );
  }

  String get buildNumber {
    return Intl.message(
      "Build number",
      name: "buildNumber",
    );
  }

  String get logout {
    return Intl.message(
      "Logout",
      name: "logout",
    );
  }

  String get editProfile {
    return Intl.message(
      "Edit Profile",
      name: "editProfile",
    );
  }

  String get addAccount {
    return Intl.message(
      "Add Account",
      name: "addAccount",
    );
  }

  String get selectTheImageSource {
    return Intl.message(
      "Select the image Source",
      name: "selectTheImageSource",
    );
  }

  String get selectTheVideoSource {
    return Intl.message(
      "Select the video Source",
      name: "selectTheVideoSource",
    );
  }

  String get camera {
    return Intl.message(
      "Camera",
      name: "camera",
    );
  }

  String get gallery {
    return Intl.message(
      "Gallery",
      name: "gallery",
    );
  }

  String get addServices {
    return Intl.message(
      "Add Services",
      name: "addServices",
    );
  }

  String get addProducts {
    return Intl.message(
      "Add Products",
      name: "addProducts",
    );
  }

  String get bankName {
    return Intl.message(
      "Bank Name",
      name: "bankName",
    );
  }

  String get account {
    return Intl.message(
      "Account",
      name: "account",
    );
  }

  String get name {
    return Intl.message(
      "Name",
      name: "name",
    );
  }

  String get payoutList {
    return Intl.message(
      "Payout List",
      name: "payoutList",
    );
  }

  String get language {
    return Intl.message(
      "Langauge",
      name: "language",
    );
  }

  String get selectYourLanguage {
    return Intl.message(
      "Select your Language",
      name: "selectYourLanguage",
    );
  }

  String get languageSwitchedTo {
    return Intl.message(
      "Language switched to",
      name: "languageSwitchedTo",
    );
  }

  String get transaction {
    return Intl.message(
      "Transaction",
      name: "transaction",
    );
  }

  //transaction detail page
  String get myTransaction {
    return Intl.message(
      "My Transaction",
      name: "myTransaction",
    );
  }

  String get status {
    return Intl.message(
      "Status",
      name: "status",
    );
  }

  String get category {
    return Intl.message(
      "Category",
      name: "category",
    );
  }

  String get accountType {
    return Intl.message(
      "Account Type",
      name: "accountType",
    );
  }

  String get chooseAccountType {
    return Intl.message(
      "Choose Account Type",
      name: "chooseAccountType",
    );
  }

  String get note {
    return Intl.message(
      "Note",
      name: "note",
    );
  }

  String get description {
    return Intl.message(
      "Description",
      name: "description",
    );
  }

  // transactions_list
  String get transactionHistoryEmpty {
    return Intl.message(
      "Transaction history empty",
      name: "transactionHistoryEmpty",
    );
  }

  String get invoiceEmpty {
    return Intl.message(
      "Invoice empty",
      name: "invoiceEmpty",
    );
  }

  String get addContract {
    return Intl.message(
      "Add Contract",
      name: "addContract",
    );
  }

  String get contractEmpty {
    return Intl.message(
      "Contract empty",
      name: "contractEmpty",
    );
  }

  String get utilityHistoryEmpty {
    return Intl.message(
      "Utility history empty",
      name: "utilityHistoryEmpty",
    );
  }

  String get utilityTransactionHistory {
    return Intl.message(
      "Utility Transaction History",
      name: "utilityTransactionHistory",
    );
  }

  String get providerListEmpty {
    return Intl.message(
      "Provider list empty",
      name: "providerListEmpty",
    );
  }

  String get received {
    return Intl.message(
      "Received",
      name: "received",
    );
  }

  //passcodePopup
  String get enterPassCode {
    return Intl.message(
      "Enter Passcode",
      name: "enterPassCode",
    );
  }

  //add_product
  String get addProduct {
    return Intl.message(
      "Add Product",
      name: "addProduct",
    );
  }

  String get addImage {
    return Intl.message(
      "Add Image",
      name: "addImage",
    );
  }

  String get productName {
    return Intl.message(
      "Product name",
      name: "productName",
    );
  }

  String get pleaseEnterProductName {
    return Intl.message(
      "Please Enter Product Name",
      name: "pleaseEnterProductName",
    );
  }

  String get shortDescription {
    return Intl.message(
      "Short Description",
      name: "shortDescription",
    );
  }

  String get productCondition {
    return Intl.message(
      "Product Condition",
      name: "productCondition",
    );
  }

  String get price {
    return Intl.message(
      "Price",
      name: "price",
    );
  }

  String get pleaseEnterValidAmout {
    return Intl.message(
      "Please Enter Valid Amount",
      name: "pleaseEnterValidAmout",
    );
  }

  String get add {
    return Intl.message(
      "Add",
      name: "add",
    );
  }

  String get productAddedSuccessfully {
    return Intl.message(
      "Product Added Succesfully",
      name: "productAddedSuccessfully",
    );
  }

  String get pleaseAddImage {
    return Intl.message(
      "Please Add Image",
      name: "pleaseAddImage",
    );
  }

  String get pleaseSelectProductCategoryAndCondition {
    return Intl.message(
      "Please Select Product Category and Condition",
      name: "pleaseSelectProductCategoryAndCondition",
    );
  }

  String get manufacturer {
    return Intl.message(
      "Manufacturer",
      name: "manufacturer",
    );
  }

  String get pleaseEnterManufacturerName {
    return Intl.message(
      "Please Enter Manufacturer Name",
      name: "pleaseEnterManufacturerName",
    );
  }

  String get isAvailable {
    return Intl.message(
      "is Available",
      name: "isAvailable",
    );
  }

  String get availableFrom {
    return Intl.message(
      "Available From",
      name: "availableFrom",
    );
  }

  //add_service
  String get addService {
    return Intl.message(
      "Add Service",
      name: "addService",
    );
  }

  String get enterServiceName {
    return Intl.message(
      "Enter Service Name",
      name: "enterServiceName",
    );
  }

  String get pleaseEnterServiceName {
    return Intl.message(
      "Please Enter Service Name",
      name: "pleaseEnterServiceName",
    );
  }

  String get describeYourServiceHere {
    return Intl.message(
      "Describe your service here..",
      name: "describeYourServiceHere",
    );
  }

  String get descriptionMustNotEmpty {
    return Intl.message(
      "Description must not empty",
      name: "descriptionMustNotEmpty",
    );
  }

  String get selectCategory {
    return Intl.message(
      "Select Catagory",
      name: "selectCategory",
    );
  }

  String get priceOfService {
    return Intl.message(
      "Price Of Service",
      name: "priceOfService",
    );
  }

  String get serviceAddedSuccessfully {
    return Intl.message(
      "Service Added Succesfully",
      name: "serviceAddedSuccessfully",
    );
  }

  //edit product
  String get editProduct {
    return Intl.message(
      "Edit Product",
      name: "editProduct",
    );
  }

  String get update {
    return Intl.message(
      "Update",
      name: "update",
    );
  }

  String get productEditedSuccessfully {
    return Intl.message(
      "Product Edited Successfully",
      name: "productEditedSuccessfully",
    );
  }

  String get productDeletedSuccessfully {
    return Intl.message(
      "Product deleted Successfully !!",
      name: "productDeletedSuccessfully",
    );
  }

  String get editService {
    return Intl.message(
      "Edit Service",
      name: "editService",
    );
  }

  String get serviceEditedSuccessfully {
    return Intl.message(
      "Service Edited Successfully",
      name: "serviceEditedSuccessfully",
    );
  }

  String get serviceDeletedSuccessfully {
    return Intl.message(
      "Service Deleted Successfully",
      name: "serviceDeletedSuccessfully",
    );
  }

  //product_detail_page
  String get productDetail {
    return Intl.message(
      "Product Detail",
      name: "productDetail",
    );
  }

  String get details {
    return Intl.message(
      "Details",
      name: "details",
    );
  }

  String get sellersOtherProduct {
    return Intl.message(
      "Seller's Other Products",
      name: "sellersOtherProduct",
    );
  }

  String get comingSoon {
    return Intl.message(
      "Coming Sonn!",
      name: "comingSoon",
    );
  }

  //service_detail_page
  String get serviceDetail {
    return Intl.message(
      "Service Detail",
      name: "serviceDetail",
    );
  }

  String get sellersOtherServices {
    return Intl.message(
      "Seller's Other Services",
      name: "sellersOtherServices",
    );
  }

  //profile
  String get noProducts {
    return Intl.message(
      "No Products",
      name: "noProducts",
    );
  }

  String get noReviews {
    return Intl.message(
      "No Reviews",
      name: "noReviews",
    );
  }

  String get post {
    return Intl.message(
      "Post ",
      name: "post",
    );
  }

  String get noPosts {
    return Intl.message(
      "No Posts",
      name: "noPosts",
    );
  }

  String get notNow {
    return Intl.message(
      "Not now",
      name: "notNow",
    );
  }

  String get noServices {
    return Intl.message(
      "No Services",
      name: "noServices",
    );
  }

  //transaction_graph
  String get transactionGraph {
    return Intl.message(
      "Transaction Graph",
      name: "transactionGraph",
    );
  }

  String get weeklySpending {
    return Intl.message(
      "Weekly Spending",
      name: "weeklySpending",
    );
  }

  String get expenditure {
    return Intl.message(
      "Expenditure",
      name: "expenditure",
    );
  }

  String get income {
    return Intl.message(
      "Income",
      name: "income",
    );
  }

  String get days {
    return Intl.message(
      "Days",
      name: "days",
    );
  }

  String get amount {
    return Intl.message(
      "Amount",
      name: "amount",
    );
  }

  String get sundayAbb {
    return Intl.message(
      "Su",
      name: "sundayAbb",
    );
  }

  String get mondayAbb {
    return Intl.message(
      "Mo",
      name: "mondayAbb",
    );
  }

  String get tuesdayAbb {
    return Intl.message(
      "Tu",
      name: "tuesdayAbb",
    );
  }

  String get wednesdayAbb {
    return Intl.message(
      "We",
      name: "wednesdayAbb",
    );
  }

  String get thursdayAbb {
    return Intl.message(
      "Th",
      name: "thursdayAbb",
    );
  }

  String get fridayAbb {
    return Intl.message(
      "Fr",
      name: "fridayAbb",
    );
  }

  String get saturdayAbb {
    return Intl.message(
      "Sa",
      name: "saturdayAbb",
    );
  }

  String get day {
    return Intl.message(
      "Day",
      name: "day",
    );
  }

  //bar_chart
  String get weeklySpendingChart {
    return Intl.message(
      "Weekly Spending Chart",
      name: "weeklySpendingChart",
    );
  }

  String get noTransactionDoneThisWeek {
    return Intl.message(
      "No Transactions done this week",
      name: "noTransactionDoneThisWeek",
    );
  }

  //bvn_verification_page

  String get bvnVerification {
    return Intl.message(
      "BVN Verification",
      name: "bvnVerification",
    );
  }

  String get enterYourBVNNUmber {
    return Intl.message(
      "Enter Your BVN Number",
      name: "enterYourBVNNUmber",
    );
  }

  String get invalidBVNNumber {
    return Intl.message(
      "Invalid BVN Number",
      name: "invalidBVNNumber",
    );
  }

  String get verify {
    return Intl.message(
      "Verify",
      name: "verify",
    );
  }

  //compose Message
  String get re {
    return Intl.message(
      "Re",
      name: "re",
    );
  }

  //user_address
  String get addAddress {
    return Intl.message(
      "Add Address",
      name: "addAddress",
    );
  }

  String get address {
    return Intl.message(
      "Address",
      name: "Address",
    );
  }

  String get billingAddress {
    return Intl.message(
      "Billing Address",
      name: "billingAddress",
    );
  }

  String get addressLine1 {
    return Intl.message(
      "Address Line 1",
      name: "addressLine1",
    );
  }

  String get invalidAddress {
    return Intl.message(
      "Invalid Address",
      name: "invalidAddress",
    );
  }

  String get addressLine2 {
    return Intl.message(
      "Address Line 2",
      name: "addressLine2",
    );
  }

  String get city {
    return Intl.message(
      "City",
      name: "city",
    );
  }

  String get invalidCity {
    return Intl.message(
      "Invalid City",
      name: "invalidCity",
    );
  }

  String get state {
    return Intl.message(
      "State",
      name: "state",
    );
  }

  String get invalidState {
    return Intl.message(
      "Invalid State",
      name: "invalidState",
    );
  }

  String get addressAddedSuccessFully {
    return Intl.message(
      "Address Added Successfully",
      name: "addressAddedSuccessFully",
    );
  }

  //order_tile
  String get ref {
    return Intl.message(
      "Ref",
      name: "ref",
    );
  }

  //card_payment_page
  String get cardPayment {
    return Intl.message(
      "Card Payment",
      name: "cardPayment",
    );
  }

  String get cardNumber {
    return Intl.message(
      "Card Number",
      name: "cardNumber",
    );
  }

  String get cardHolderName {
    return Intl.message(
      "Card Holder's Name",
      name: "cardHolderName",
    );
  }

  String get fieldCannotBeEmpty {
    return Intl.message(
      "Field cannot be empty",
      name: "fieldCannotBeEmpty",
    );
  }

  String get slydoPayAccepts {
    return Intl.message(
      "Slydopay accepts the following credit card:",
      name: "slydoPayAccepts",
    );
  }

  String get securelySaveCard {
    return Intl.message(
      "Securely save this card",
      name: "securelySaveCard",
    );
  }

  String get doesNotSaveUsersCard {
    return Intl.message(
      "Slydo does not store user's credit cards info on it's servers. It is stored and processed by our gateway partners.",
      name: "doesNotSaveUsersCard",
    );
  }

  String get expiredDate {
    return Intl.message(
      "Expied Date",
      name: "expiredDate",
    );
  }

  String get cvv {
    return Intl.message(
      "CVV",
      name: "cvv",
    );
  }

  String get cardHolder {
    return Intl.message(
      "Card Holder",
      name: "cardHolder",
    );
  }

  String get top_Up {
    return Intl.message(
      "Top Up",
      name: "top_Up",
    );
  }

  String get topUp {
    return Intl.message(
      "TopUp",
      name: "topUp",
    );
  }

  String get topUpByCreditCard {
    return Intl.message(
      "Top up by credit card",
      name: "topUpByCreditCard",
    );
  }

  String get topUpWithCreditAndDebitCard {
    return Intl.message(
      "Top up with Credit/Debit card",
      name: "topUpWithCreditAndCard",
    );
  }

  String get creditDebitCard {
    return Intl.message(
      "Credit/Debit Card",
      name: "creditDebitCard",
    );
  }

  String get virtualAccount {
    return Intl.message(
      "Virtual Account",
      name: "virtualAccount",
    );
  }

  String get myWallet {
    return Intl.message(
      "My Wallet",
      name: "myWallet",
    );
  }

  String get invalidDetail {
    return Intl.message(
      "Invalid Detail",
      name: "invalidDetail",
    );
  }

  //checkout_shopping_cart
  String get basket {
    return Intl.message(
      "Basket",
      name: "basket",
    );
  }

  String get shoppingCartIsEmpty {
    return Intl.message(
      "Shopping Cart Is Empty !!",
      name: "shoppingCartIsEmpty",
    );
  }

  String get total {
    return Intl.message(
      "Total",
      name: "total",
    );
  }

  String get buy {
    return Intl.message(
      "Buy",
      name: "buy",
    );
  }

  String get pleaseAddSomeItemsFirst {
    return Intl.message(
      "Please Add Some Items First !!",
      name: "pleaseAddSomeItemsFirst",
    );
  }

  String get remove {
    return Intl.message(
      "Remove",
      name: "remove",
    );
  }

  String get confirmation {
    return Intl.message(
      "Confirmation",
      name: "confirmation",
    );
  }

  String get areYouSureWantToPlaceThisOrderFor {
    return Intl.message(
      "Are You Sure Want To Place this Order For",
      name: "areYouSureWantToPlaceThisOrderFor",
    );
  }

  String get place {
    return Intl.message(
      "PLACE",
      name: "place",
    );
  }

  //order_detail_page
  String get orderDetail {
    return Intl.message(
      "Order Detail",
      name: "orderDetail",
    );
  }

  String get enterYourNoteHere {
    return Intl.message(
      "Enter Your Note Here",
      name: "enterYourNoteHere",
    );
  }

  String get noSpecialNoteAttached {
    return Intl.message(
      "No Special Note Attached",
      name: "noSpecialNoteAttached",
    );
  }

  String get newOrder {
    return Intl.message(
      "New Order",
      name: "newOrder",
    );
  }

  String get awaitingPayment {
    return Intl.message(
      "Awaiting Payment",
      name: "awaitingPayment",
    );
  }

  String get canceled {
    return Intl.message(
      "Canceled",
      name: "canceled",
    );
  }

  String get completed {
    return Intl.message(
      "Completed",
      name: "completed",
    );
  }

  String get onHold {
    return Intl.message(
      "On Hold",
      name: "onHold",
    );
  }

  String get pending {
    return Intl.message(
      "Pending",
      name: "pending",
    );
  }

  String get processing {
    return Intl.message(
      "Processing",
      name: "processing",
    );
  }

  String get itemIsRemovedSuccessfullyFromCart {
    return Intl.message(
      "Item is Removed Successfully From Cart",
      name: "itemIsRemovedSuccessfullyFromCart",
    );
  }

  //orderList
  String get orders {
    return Intl.message(
      "Orders",
      name: "orders",
    );
  }

  String get noOrdersPresent {
    return Intl.message(
      "No Orders Present !!",
      name: "noOrdersPresent",
    );
  }

  //product_detail_page
  String get youCanNotPurchaseThisItem {
    return Intl.message(
      "You Can Not Purchase This Item !!",
      name: "youCanNotPurchaseThisItem",
    );
  }

  String get share {
    return Intl.message(
      "Share",
      name: "share",
    );
  }

  String get seeAll {
    return Intl.message(
      "See all",
      name: "seeAll",
    );
  }

  String get buyNow {
    return Intl.message(
      "Buy Now",
      name: "buyNow",
    );
  }

  //service_detail_page
  String get providersOtherService {
    return Intl.message(
      "Provider's Other Services",
      name: "providersOtherService",
    );
  }

  //transaction_graph
  String get incomeExpenditure {
    return Intl.message(
      "Income/Expenditure",
      name: "incomeExpenditure",
    );
  }

  String get weekRange {
    return Intl.message(
      "Week Range",
      name: "weekRange",
    );
  }

  //user_dashboard
  String get profile {
    return Intl.message(
      "Profile",
      name: "profile",
    );
  }

  String get bank {
    return Intl.message(
      "Bank",
      name: "bank",
    );
  }

  String get myStore {
    return Intl.message(
      "My Store",
      name: "myStore",
    );
  }

  String get myProfile {
    return Intl.message(
      "My Profile",
      name: "myProfile",
    );
  }

  String get business {
    return Intl.message(
      "Business",
      name: "business",
    );
  }

  String get more {
    return Intl.message(
      "More",
      name: "more",
    );
  }

  String get madeInNigeria {
    return Intl.message(
      "Made in Nigeria",
      name: "madeInNigeria",
    );
  }

  String get updateAvatar {
    return Intl.message(
      "Update Avatar",
      name: "updateAvatar",
    );
  }

  String get createAPost {
    return Intl.message(
      "Create a post",
      name: "createAPost",
    );
  }

  String get editPost {
    return Intl.message(
      "Edit post",
      name: "editPost",
    );
  }

  String get deletePost {
    return Intl.message(
      "Delete Post",
      name: "deleteBlog",
    );
  }

  String get postSettings {
    return Intl.message(
      "Post settings",
      name: "postSettings",
    );
  }

  String get createPost {
    return Intl.message(
      "Create Post",
      name: "createPost",
    );
  }

  String get bankAccounts {
    return Intl.message(
      "Bank Accounts",
      name: "bankAccounts",
    );
  }

  //user_profile
  String get info {
    return Intl.message(
      "Info",
      name: "info",
    );
  }

  //delete_product_and_service
  String get areYouSureWantToDeleteThisItem {
    return Intl.message(
      "Are You Sure Want To Delete This Item ?",
      name: "areYouSureWantToDeleteThisItem",
    );
  }

  //splash
  String get retry {
    return Intl.message(
      "Retry",
      name: "retry",
    );
  }

  String get bvnTermsAndCondition {
    return Intl.message(
      "By clicking Register you are agreeing to the Terms and Conditions.",
      name: "bvnTermsAndCondition",
    );
  }

  String get documentVerificationTermsAndCondition {
    return Intl.message(
      "By clicking Register you are agreeing to the Terms and Conditions.",
      name: "documentVerificationTermsAndCondition",
    );
  }

  String get termsForRegistration {
    return Intl.message(
      "This Phone Number Should Be The Number Associated With your BVN",
      name: "termsForRegistration",
    );
  }

  String get termsForUserAgreeCheckBox {
    return Intl.message(
      "I Agree That If I Give Mismatch Number To My BVN I Will Be solely Responsible For The Consequence.",
      name: "termsForUserAgreeCheckBox",
    );
  }

  String get termsForName {
    return Intl.message(
      "This Name Must Match The Name On Your BVN",
      name: "termsForName",
    );
  }

  String get bankAccountTerms {
    return Intl.message(
      "This Bank Account Must Match Your BVN And Phone Number Registered With Slydo.",
      name: "bankAccountTerms",
    );
  }

  String get bankAccountUserAgreeTerm {
    return Intl.message(
      "Putting Misleading Info May Results In Delays Or Lost of Money.",
      name: "bankAccountUserAgreeTerm",
    );
  }

  //block_list
  String get noBlockedContacts {
    return Intl.message(
      "No Blocked Contacts",
      name: "noBlockedContacts",
    );
  }

  String get unblock {
    return Intl.message(
      "Unblock",
      name: "unblock",
    );
  }

  String get areYouSureWantToUnblock {
    return Intl.message(
      "Are You Sure Want To Unblock",
      name: "areYouSureWantToUnblock",
    );
  }

  String get isUnblockedSuccessfully {
    return Intl.message(
      "is Unblocked Successfully",
      name: "isUnblockedSuccessfully",
    );
  }

  //contact_request_list
  String get currentlyYouHaveNoAnyContactRequest {
    return Intl.message(
      "Currently You Have No Any Contact Request",
      name: "currentlyYouHaveNoAnyContactRequest",
    );
  }

  String get areYouSureWantToRejectRequestFrom {
    return Intl.message(
      "Are You Sure Want To Reject Request From",
      name: "areYouSureWantToRejectRequestFrom",
    );
  }

  String get requestFrom {
    return Intl.message(
      "Request From",
      name: "requestFrom",
    );
  }

  String get isRejectedSuccessfully {
    return Intl.message(
      "is Rejected Successfully",
      name: "isRejectedSuccessfully",
    );
  }

  String get areYouSureWantToAdd {
    return Intl.message(
      "Are You Sure Want To Add",
      name: "areYouSureWantToAdd",
    );
  }

  String get inYourContacts {
    return Intl.message(
      "In Your Contacts",
      name: "inYourContacts",
    );
  }

  String get isAddedToYourContactList {
    return Intl.message(
      "is Added to your Contact List",
      name: "isAddedToYourContactList",
    );
  }

  //contacts_dashboard
  String get contacts {
    return Intl.message(
      "Contacts",
      name: "contacts",
    );
  }

  String get blocked {
    return Intl.message(
      "Blocked",
      name: "blocked",
    );
  }

  //contacts_list
  String get currentlyYouHaveNoAnyContacts {
    return Intl.message(
      "Currently You Have No Any Contacts",
      name: "currentlyYouHaveNoAnyContacts",
    );
  }

  String get block {
    return Intl.message(
      "Block",
      name: "block",
    );
  }

  String get connect {
    return Intl.message(
      "Connect",
      name: "connect",
    );
  }

  String get areYouSureWantToBlock {
    return Intl.message(
      "Are You Sure Want To Block",
      name: "areYouSureWantToBlock",
    );
  }

  String get isBlockedSuccessfully {
    return Intl.message(
      "is blocked Successfully",
      name: "isBlockedSuccessfully",
    );
  }

  String get areYouSureWantToDelete {
    return Intl.message(
      "Are You Sure Want To Delete",
      name: "areYouSureWantToDelete",
    );
  }

  String get fromYouContactList {
    return Intl.message(
      "From Your Contact List",
      name: "fromYouContactList",
    );
  }

  String get isRemovedSuccessfully {
    return Intl.message(
      "is Removed From Contact List Successfully",
      name: "isRemovedSuccessfully",
    );
  }

  String get blockUser {
    return Intl.message(
      "Block User",
      name: "blockUser",
    );
  }

  String get isBlocked {
    return Intl.message(
      "is Blocked",
      name: "isBlocked",
    );
  }

  //user_dashboard
  String get updateMyAvatar {
    return Intl.message(
      "Update My Avatar",
      name: "updateMyAvatar",
    );
  }

  String get myAddress {
    return Intl.message(
      "My Address",
      name: "myAddress",
    );
  }

  String get myContactsAndRequest {
    return Intl.message(
      "My Contacts/Request",
      name: "myContactsAndRequest",
    );
  }

  String get addContact {
    return Intl.message(
      "Add Contact",
      name: "addContact",
    );
  }

  String get contactRequestSent {
    return Intl.message(
      "Contact Request Sent",
      name: "contactRequestSent",
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<AppLocalization> {
  final Locale overriddenLocale;

  const AppLocalizationDelegate(this.overriddenLocale);

  @override
  bool isSupported(Locale locale) => [
        'am',
        'ar',
        'en',
        'es',
        'fr',
        'ha',
        'pt',
        'sw',
        'yo',
        'zu'
      ].contains(locale.languageCode);

  @override
  Future<AppLocalization> load(Locale locale) => AppLocalization.load(locale);

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalization> old) => false;
}
