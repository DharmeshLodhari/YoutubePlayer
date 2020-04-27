import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/messages_all.dart';

class AppLocalization {
  static Future<AppLocalization> load(Locale locale) {
    final String name =
        locale.countryCode.isEmpty ? locale.languageCode : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      return AppLocalization();
    });
  }

  static AppLocalization of(BuildContext context) {
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

  String get submitButton {
    return Intl.message(
      "Submit",
      name: "submitButton",
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
      "Verify your identity",
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

  String get serverError {
    return Intl.message(
      "Server Error Please try after some time !",
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

  String get youCanAddMaximumTwoAccount {
    return Intl.message(
      "You can add maximum two bank account",
      name: "youCanAddMaximumTwoAccount",
    );
  }

  String get youDontHaveAnyAccountPleaseAddOne {
    return Intl.message(
      "You Don't have any Bank Account Please Add one",
      name: "youDontHaveAnyAccountPleaseAddOne",
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
      "You can not delete only bank account",
      name: "youCanNotDeleteOnlyBankAccount",
    );
  }

  String get accountDeletedSuccessfully {
    return Intl.message(
      "Account Deleted Successfully",
      name: "accountDeletedSuccessfully",
    );
  }

  String get accountIsNotDeleted {
    return Intl.message(
      "Account is not deleted !!",
      name: "accountIsNotDeleted",
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
      "This Account is Alerady Default Account",
      name: "thisAccountIsAlreadyDefaultAccount",
    );
  }

  String get accountUpdatedSuccessfully {
    return Intl.message(
      "Account updated successfully !!",
      name: "accountUpdatedSuccessfully",
    );
  }

  String get accountIsNotUpdated {
    return Intl.message(
      "Account is not updated !!",
      name: "accountIsNotUpdated",
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
      "",
      name: "archive",
    );
  }

  String get reply {
    return Intl.message(
      "Replay",
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

  //home
  String get exit {
    return Intl.message(
      "Exit",
      name: "exit",
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

  String get buildnumber {
    return Intl.message(
      "Build number",
      name: "buildnumber",
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

  String get camera {
    return Intl.message(
      "Camera",
      name: "camera",
    );
  }

  String get gallary {
    return Intl.message(
      "Gallary",
      name: "gallary",
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

  //transaction detail page
  String get transaction {
    return Intl.message(
      "Transaction",
      name: "transaction",
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

  String get availabeFrom {
    return Intl.message(
      "Available From",
      name: "availabeFrom",
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

  String get noServices {
    return Intl.message(
      "No Services",
      name: "noServices",
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<AppLocalization> {
  final Locale overriddenLocale;

  const AppLocalizationDelegate(this.overriddenLocale);

  @override
  bool isSupported(Locale locale) => ['en', 'gu'].contains(locale.languageCode);

  @override
  Future<AppLocalization> load(Locale locale) => AppLocalization.load(locale);

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalization> old) => false;
}
