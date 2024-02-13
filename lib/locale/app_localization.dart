import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/messages_all.dart';
import '../utils/util.dart';

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

  String get accountNumberHint {
    return Intl.message(
      "Account Number",
      name: "accountNumberHint",
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

  String get locationError {
    return Intl.message(
      "Location must contain atleast two character",
      name: "locationError",
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

  String get jobRefNumber {
    return Intl.message(
      "Job Reference Number",
      name: "jobRefNumber",
    );
  }

  String get location {
    return Intl.message(
      "Location",
      name: "location",
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

  String get alreadyHaveOtp {
    return Intl.message(
      "Already Have OTP?",
      name: "alreadyHaveOtp",
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

  String get upgrade {
    return Intl.message(
      "Upgrade",
      name: "upgrade",
    );
  }

  String get cartPaymentRequest {
    return Intl.message(
      "Cart Payment Request",
      name: "cartPaymentRequest",
    );
  }

  String get upgradeHomeMsg {
    return Intl.message(
      "Are you sure you want to upgrade account to business account?",
      name: "upgradeHomeMsg",
    );
  }

  String get noAddressFound {
    return Intl.message(
      "No Address Found",
      name: "noAddressFound",
    );
  }

  String get addNewAddress {
    return Intl.message(
      "Add New Address",
      name: "addNewAddress",
    );
  }

  String get addressFoundMsg {
    return Intl.message(
      "Kindly add an address to your list to continue using this App. This will help us give you recommendation that are relevant & closer to you.",
      name: "addressFoundMsg",
    );
  }

  String get changeAddress {
    return Intl.message(
      "Change Address",
      name: "changeAddress",
    );
  }

  String get selectAddress {
    return Intl.message(
      "Select Address",
      name: "selectAddress",
    );
  }

  String get changeAddressMsg {
    return Intl.message(
      "Kindly add a current address to your list to continue using this App. This will help us give you recommendation that are relevant & closer to you.",
      name: "addressFoundMsg",
    );
  }

  String get freeze {
    return Intl.message(
      "Freeze",
      name: "freeze",
    );
  }

  String get unFreeze {
    return Intl.message(
      "UnFreeze",
      name: "unFreeze",
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

  String get searchHomeQuickViewHint {
    return Intl.message(
      "Search",
      name: "searchHomeQuickViewHint",
    );
  }

  String get paymentSubTitle {
    return Intl.message(
      "Manage all your payment activities in one place.",
      name: "paymentSubTitle",
    );
  }

  String get businessSubTitle {
    return Intl.message(
      "Manage all your business activities in one place.",
      name: "paymentSubTitle",
    );
  }

  String get socialSubTitle {
    return Intl.message(
      "Manage all your Social activities in one place.",
      name: "paymentSubTitle",
    );
  }

  String get lifestyleSubTitle {
    return Intl.message(
      "Manage all your lifestyles activities in one place.",
      name: "paymentSubTitle",
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

  String get viewNow {
    return Intl.message(
      "View Now",
      name: "viewNow",
    );
  }

  String get ignore {
    return Intl.message(
      "Ignore",
      name: "ignore",
    );
  }

  String get process {
    return Intl.message(
      "Process",
      name: "process",
    );
  }

  String get upgradeMessage {
    return Intl.message(
      "To apply for this job, please upgrade to a business account",
      name: "upgradeMessage",
    );
  }

  String get paymentLinkConfirmationMsg {
    return Intl.message(
      "You are about to create a payment link, this service will cost you ",
      name: "paymentLinkConfirmationMsg",
    );
  }

  String get create {
    return Intl.message(
      "Create",
      name: "create",
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

  String get invalidWeight {
    return Intl.message(
      "Invalid Weight",
      name: "invalidWeight",
    );
  }

  String get invalidHeight {
    return Intl.message(
      "Invalid Height",
      name: "invalidHeight",
    );
  }

  String get invalidCount {
    return Intl.message(
      "Invalid Inventory Count",
      name: "invalidCount",
    );
  }

  String get invalidWidth {
    return Intl.message(
      "Invalid Width",
      name: "invalidWidth",
    );
  }

  String get dailyPaymentLinkLimit {
    return Intl.message(
      "You can only send NGN${moneyDisplayNormalizer(200000 * 100)} at once.",
      name: "dailyPaymentLinkLimit",
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

  String get couldNotPlaceTheOrder {
    return Intl.message(
      "Could Not Place The Order",
      name: "couldNotPlaceTheOrder",
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
      "you are about to transfer money into a bank account, this service will cost ",
      name: "noteForUser",
    );
  }

  String get noteForUser2 {
    return Intl.message(
      "You are about to transfer money into a bank account, this service will cost ",
      name: "noteForUser2",
    );
  }

  String get noteForUserPayLink {
    return Intl.message(
      "You are about to create a payment link, this service will cost ",
      name: "noteForUserPayLink",
    );
  }

  String get minimumTransfer {
    return Intl.message(
      "Minimum Transferable Fund: ",
      name: "minimumTransfer",
    );
  }

  String get availableFund {
    return Intl.message(
      "Available Fund: ",
      name: "availableFund",
    );
  }

  // registration
  String get signUp {
    return Intl.message(
      "Sign Up",
      name: "signUp",
    );
  }

  String get country {
    return Intl.message(
      "Country",
      name: "country",
    );
  }

  String get selectYourCountry {
    return Intl.message(
      "Select your Country",
      name: "selectYourCountry",
    );
  }

  String get registerTopInformation {
    return Intl.message(
      "Please enter your phone number. This phone number must be the one registered with your BVN",
      name: "registerTopInformation",
    );
  }

  String get search {
    return Intl.message(
      "Search",
      name: "search",
    );
  }

  String get suggestions {
    return Intl.message(
      "Suggestions",
      name: "suggestions",
    );
  }

  String get noSuggestions {
    return Intl.message(
      "No Suggestions",
      name: "noSuggestions",
    );
  }

  String get chat {
    return Intl.message(
      "Chat",
      name: "chat",
    );
  }

  ///Create paid group chat
  ///Make public
  ///Limit group members
  ///Max. number of users

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

  String get saySomething {
    return Intl.message(
      "Say something about your experience",
      name: "saySomething",
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

  String get payment {
    return Intl.message(
      "Payment",
      name: "payment",
    );
  }

  String get businessTools {
    return Intl.message(
      "Business Tools",
      name: "businessTools",
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

  //Subscription

  String get profileUpgradeSuccessful {
    return Intl.message(
      "Your profile upgrade was successful.",
      name: "profileUpgradeSuccessful",
    );
  }

  String get businessNameNotAvailable {
    return Intl.message(
      "'Business name not available'",
      name: "businessNameNotAvailable",
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

  String get variant {
    return Intl.message(
      "Variants",
      name: "variant",
    );
  }

  String get addOn {
    return Intl.message(
      "Add-Ons",
      name: "addOn",
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

  String get creditCardFeatureNotAvailable {
    return Intl.message(
      "Credit card feature not available at the moment",
      name: "creditCardFeatureNotAvailable",
    );
  }

  String get walletFeatureNotAvailable {
    return Intl.message(
      "Wallet feature not available at the moment",
      name: "walletFeatureNotAvailable",
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

  String get noOptionYetDetail {
    return Intl.message(
      "No option yet, when you create an option you will see them on this page",
      name: "noOptionYetDetail",
    );
  }

  String get noVariantDetail {
    return Intl.message(
      "No variant yet, when you create an option you will see them on this page",
      name: "noVariantDetail",
    );
  }

  String get noOptionYet {
    return Intl.message(
      "No Option Yet",
      name: "noOptionYet",
    );
  }

  String get noVariantYet {
    return Intl.message(
      "No Variant Yet",
      name: "noVariantYet",
    );
  }

  String get newOption {
    return Intl.message(
      "New Variant",
      name: "newOption",
    );
  }

  String get option {
    return Intl.message(
      "Option",
      name: "option",
    );
  }

  String get newAddOns {
    return Intl.message(
      "New Add-ons",
      name: "newAddOns",
    );
  }

  String get updateVariant {
    return Intl.message(
      "Update Variant",
      name: "updateVariant",
    );
  }

  String get noMembersYet {
    return Intl.message(
      "No Members Yet",
      name: "noAddOnYet",
    );
  }

  String get noAddOnYet {
    return Intl.message(
      "No Add-Ons Yet",
      name: "noAddOnYet",
    );
  }

  String get noAddOnYetSub {
    return Intl.message(
      "No add-ons yet, when you create add-ons you will see them on this page",
      name: "noAddOnYetSub",
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

  String get youDontHaveAnyShippingOptionPleaseAddOne {
    return Intl.message(
      "You Don't have any Shipping Option Please Add one",
      name: "youDontHaveAnyShippingOptionPleaseAddOne",
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

  String get variantDeletedSuccessfully {
    return Intl.message(
      "Variant Deleted Successfully",
      name: "variantDeletedSuccessfully",
    );
  }

  String get requestPaymentSuccessfully {
    return Intl.message(
      "Send Request Payment Successfully",
      name: "requestPaymentSuccessfully",
    );
  }

  String get requestFailed {
    return Intl.message(
      "Request Failed",
      name: "requestFailed",
    );
  }

  String get memberAddedSuccessfully {
    return Intl.message(
      "Member Added Successfully",
      name: "memberAddedSuccessfully",
    );
  }

  String get memberDeletedSuccessfully {
    return Intl.message(
      "Member Deleted Successfully",
      name: "memberDeletedSuccessfully",
    );
  }

  String get memberIsNotDeleted {
    return Intl.message(
      "Member is not deleted !!",
      name: "memberIsNotDeleted",
    );
  }

  String get addOnDeletedSuccessfully {
    return Intl.message(
      "Add-on Deleted Successfully",
      name: "addOnDeletedSuccessfully",
    );
  }

  String get addOnOptionDeletedSuccessfully {
    return Intl.message(
      "Add-on Option Deleted Successfully",
      name: "addOnOptionDeletedSuccessfully",
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

  String get variantIsNotDeleted {
    return Intl.message(
      "Variant is not deleted !!",
      name: "variantIsNotDeleted",
    );
  }

  String get addOnIsNotDeleted {
    return Intl.message(
      "Add-on is not deleted !!",
      name: "addOnIsNotDeleted",
    );
  }

  String get addOnOptionIsNotDeleted {
    return Intl.message(
      "Add-on option is not deleted !!",
      name: "addOnOptionIsNotDeleted",
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

  String get moment {
    return Intl.message(
      "Moment",
      name: "moment",
    );
  }

  String get moments {
    return Intl.message(
      "Moments",
      name: "moments",
    );
  }

  String get noMoments {
    return Intl.message(
      "No Moments",
      name: "noMoments",
    );
  }

  String get store {
    return Intl.message(
      "Store",
      name: "store",
    );
  }

  String get enableInSuperStore {
    return Intl.message(
      "Enable in Super Store",
      name: "enableInSuperStore",
    );
  }

  String get measurement {
    return Intl.message(
      "Measurement",
      name: "measurement",
    );
  }

  String get discount {
    return Intl.message(
      "Discount",
      name: "discount",
    );
  }

  String get trackInventoryView {
    return Intl.message(
      "Track Inventory",
      name: "trackInventoryView",
    );
  }

  String get superStore {
    return Intl.message(
      "Super Store",
      name: "superStore",
    );
  }

  String get myProducts {
    return Intl.message(
      "My Products",
      name: "myProducts",
    );
  }

  String get myServices {
    return Intl.message(
      "My Services",
      name: "myServices",
    );
  }

  String get slydoBlogs {
    return Intl.message(
      "Slydo Blogs",
      name: "slydoBlog",
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

  String get previewMoment {
    return Intl.message(
      "Moment",
      name: "previewMoment",
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

  String get leave {
    return Intl.message(
      "Leave",
      name: "leave",
    );
  }

  String get noContinue {
    return Intl.message(
      "No, Continue",
      name: "continue",
    );
  }

  String get exitApp {
    return Intl.message(
      "Exit App",
      name: "exitApp",
    );
  }

  String get youSureYouWantToExitApp {
    return Intl.message(
      "Are you sure want to exit the app?",
      name: "youSureYouWantToExitApp",
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

  String get paymentLink {
    return Intl.message(
      "Payment Links",
      name: "payment",
    );
  }

  String get freezeCard {
    return Intl.message(
      "Freeze Card",
      name: "freezeCard",
    );
  }

  String get fundCard {
    return Intl.message(
      "Fund Card",
      name: "fundCard",
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

  String get quickActions {
    return Intl.message(
      "Shortcuts",
      name: "quickActions",
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

  String get outOfStock {
    return Intl.message(
      "Out Of Stock",
      name: "outOfStock",
    );
  }

  String get productOutOfStock {
    return Intl.message(
      "Product Out Of Stock",
      name: "productOutOfStock",
    );
  }

  String get cantPurchaseYourOwnServices {
    return Intl.message(
      "You can't purchase your own goods and service",
      name: "cantPurchaseYourOwnServices",
    );
  }

  String get serviceOutOfStock {
    return Intl.message(
      "Service Out Of Stock",
      name: "serviceOutOfStock",
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

  String get payNow {
    return Intl.message(
      "Pay Now",
      name: "payNow",
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

  String get paymentRequestCancelled {
    return Intl.message(
      "Payment Request Cancelled !!",
      name: "paymentRequestCancelled",
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

  // jobs

  String get findJobs {
    return Intl.message(
      "Find Jobs",
      name: "find jobs",
    );
  }

  String get posted {
    return Intl.message(
      "Posted",
      name: "posted",
    );
  }

  String get applied {
    return Intl.message(
      "Applied",
      name: "applied",
    );
  }

  String get myJobs {
    return Intl.message(
      "My Jobs",
      name: "myJobs",
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

  String get noPaymentLink {
    return Intl.message(
      "No payment Link",
      name: "noPaymentLink",
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

  String get logoutMsg {
    return Intl.message(
      "Do you want to Logout?",
      name: "logoutMsg",
    );
  }

  String get editProfile {
    return Intl.message(
      "Edit Profile",
      name: "editProfile",
    );
  }

  String get goodMorning {
    return Intl.message(
      "Good Morning",
      name: "goodMorning",
    );
  }

  String get goodAfternoon {
    return Intl.message(
      "Good Afternoon",
      name: "goodAfternoon",
    );
  }

  String get goodEvening {
    return Intl.message(
      "Good Evening",
      name: "goodEvening",
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

  String get pincode {
    return Intl.message(
      "Passcode",
      name: "passcode",
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
      "Transactions",
      name: "transactions",
    );
  }

  //transaction detail page
  String get myTransaction {
    return Intl.message(
      "My Transactions",
      name: "myTransaction",
    );
  }

  String get myPaymentRequests {
    return Intl.message(
      "My Payment Requests",
      name: "myPaymentRequests",
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

  String get siUnit {
    return Intl.message(
      "SI Unit",
      name: "siUnit",
    );
  }

  String get type {
    return Intl.message(
      "Type",
      name: "type",
    );
  }

  String get selectType {
    return Intl.message(
      "Select Type",
      name: "selectType",
    );
  }

  String get cardBrand {
    return Intl.message(
      "Card Brand",
      name: "cardBrand",
    );
  }

  String get cardType {
    return Intl.message(
      "Card Type",
      name: "cardType",
    );
  }

  String get state {
    return Intl.message(
      "State",
      name: "state",
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

  String get emptyList {
    return Intl.message(
      "Empty List",
      name: "emptyList",
    );
  }

  String get emptyBeneficiary {
    return Intl.message(
      "Beneficiary List is Empty",
      name: "emptyBeneficiary",
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

  String get cardLabel {
    return Intl.message(
      "Card Label",
      name: "cardLabel",
    );
  }

  String get reason {
    return Intl.message(
      "Reason",
      name: "reason",
    );
  }

  String get productLabel {
    return Intl.message(
      "Product Label",
      name: "productLabel",
    );
  }

  String get serviceLabel {
    return Intl.message(
      "Service Label",
      name: "serviceLabel",
    );
  }

  String get firstName {
    return Intl.message(
      "First Name",
      name: "firstName",
    );
  }

  String get lastName {
    return Intl.message(
      "Last Name",
      name: "lastName",
    );
  }

  String get size {
    return Intl.message(
      "Size",
      name: "size",
    );
  }

  String get title {
    return Intl.message(
      "Title",
      name: "title",
    );
  }

  String get color {
    return Intl.message(
      "Color",
      name: "color",
    );
  }

  String get pleaseEnterProductName {
    return Intl.message(
      "Please Enter Product Name",
      name: "pleaseEnterProductName",
    );
  }

  String get pleaseEnterLabel {
    return Intl.message(
      "Please Enter Label",
      name: "pleaseEnterLabel",
    );
  }

  String get pleaseEnterReason {
    return Intl.message(
      "Please Enter Reason",
      name: "pleaseEnterReason",
    );
  }

  String get pleaseEnterProductLabel {
    return Intl.message(
      "Please Enter Product Label",
      name: "pleaseEnterProductLabel",
    );
  }

  String get pleaseEnterServiceLabel {
    return Intl.message(
      "Please Enter Service Label",
      name: "pleaseEnterServiceLabel",
    );
  }

  String get pleaseEnterFirstName {
    return Intl.message(
      "Please Enter First Name",
      name: "pleaseEnterFirstName",
    );
  }

  String get pleaseEnterLastName {
    return Intl.message(
      "Please Enter Last Name",
      name: "pleaseEnterLastName",
    );
  }

  String get pleaseEnterAddress {
    return Intl.message(
      "Please Enter Address",
      name: "pleaseEnterAddress",
    );
  }

  String get pleaseEnterCity {
    return Intl.message(
      "Please Enter City",
      name: "pleaseEnterCity",
    );
  }

  String get pleaseEnterZipCode {
    return Intl.message(
      "Please Enter Zip Code",
      name: "pleaseEnterZipCode",
    );
  }

  String get pleaseEnterBvn {
    return Intl.message(
      "Please Enter BVN",
      name: "pleaseEnterBvn",
    );
  }

  String get pleaseEnterIdNumber {
    return Intl.message(
      "Please Enter ID Number",
      name: "pleaseEnterIdNumber",
    );
  }

  String get pleaseEnterColor {
    return Intl.message(
      "Please Enter Color",
      name: "pleaseEnterColor",
    );
  }

  String get pleaseEnterSize {
    return Intl.message(
      "Please Enter Size",
      name: "pleaseEnterSize",
    );
  }

  String get pleaseEnterTitle {
    return Intl.message(
      "Please Enter Title",
      name: "pleaseEnterTitle",
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

  String get weight {
    return Intl.message(
      "Weight",
      name: "weight",
    );
  }

  String get height {
    return Intl.message(
      "Height",
      name: "height",
    );
  }

  String get width {
    return Intl.message(
      "Width",
      name: "width",
    );
  }

  String get comparePrice {
    return Intl.message(
      "Compare Price At",
      name: "comparePrice",
    );
  }

  String get pleaseEnterValidAmout {
    return Intl.message(
      "Please Enter Valid Amount",
      name: "pleaseEnterValidAmout",
    );
  }

  String get pleaseEnterValidWeight {
    return Intl.message(
      "Please Enter Valid Weight",
      name: "pleaseEnterValidWeight",
    );
  }

  String get pleaseEnterValidHeight {
    return Intl.message(
      "Please Enter Valid Height",
      name: "pleaseEnterValidHeight",
    );
  }

  String get pleaseEnterValidCount {
    return Intl.message(
      "Please Enter Valid Count",
      name: "pleaseEnterValidCount",
    );
  }

  String get pleaseEnterValidWidth {
    return Intl.message(
      "Please Enter Valid Width",
      name: "pleaseEnterValidWidth",
    );
  }

  String get add {
    return Intl.message(
      "Add",
      name: "add",
    );
  }

  String get addOns {
    return Intl.message(
      "Add-ons",
      name: "add-ons",
    );
  }

  String get productAddedSuccessfully {
    return Intl.message(
      "Product Added Successfully",
      name: "productAddedSuccessfully",
    );
  }

  String get jobRemovedFromListing {
    return Intl.message(
      "Unlist Successfully",
      name: "jobRemovedFromListingSuccessfully",
    );
  }

  String get jobAcceptedFromListing {
    return Intl.message(
      "Accepted Successfully",
      name: "jobRemovedFromListingSuccessfully",
    );
  }

  String get endJob {
    return Intl.message(
      "Job ended Successfully",
      name: "endJob",
    );
  }

  String get appliedForJobSuccessfully {
    return Intl.message(
      "Application successful",
      name: "jobAppliedSuccessfully",
    );
  }

  String get cancelledApplicactionForJobSuccessfully {
    return Intl.message(
      "Job Cancelled Successfully",
      name: "jobCancelledSuccessfully",
    );
  }

  String get journyStartedSuccessfully {
    return Intl.message(
      "Job Started Successfully",
      name: "jobCancelledSuccessfully",
    );
  }

  String get pleaseAddImage {
    return Intl.message(
      "Please Add Image",
      name: "pleaseAddImage",
    );
  }

  String get categoryAndLocationSelection {
    return Intl.message(
      "Please select Location and Category",
      name: "categoryAndLocationSelection",
    );
  }

  String get addDueDate {
    return Intl.message(
      "Please add a due date for the Job",
      name: "addDueDate",
    );
  }

  String get pleaseSelectProductCategoryAndCondition {
    return Intl.message(
      "Please Select Product Category and Condition",
      name: "pleaseSelectProductCategoryAndCondition",
    );
  }

  String get pleaseSelectWeightHeightWidth {
    return Intl.message(
      "Please Select Weight, Height and Width SI Unit",
      name: "pleaseSelectWeightHeightWidth",
    );
  }

  String get pleaseFillWeight {
    return Intl.message(
      "Please Fill Weight and SI Unit",
      name: "pleaseFillWeight",
    );
  }

  String get pleaseFillHeight {
    return Intl.message(
      "Please Fill Height and SI Unit",
      name: "pleaseFillHeight",
    );
  }

  String get pleaseFillWidth {
    return Intl.message(
      "Please Fill Width and SI Unit",
      name: "pleaseFillWidth",
    );
  }

  String get pleaseSelectStateOrIdTYpe {
    return Intl.message(
      "Please Select State and ID Type",
      name: "pleaseSelectStateOrIdTYpe",
    );
  }

  String get pleaseSelectCardBrand {
    return Intl.message(
      "Please Select Card Brand And Card Type",
      name: "pleaseSelectCardBrand",
    );
  }

  String get pleaseSelectCategory {
    return Intl.message(
      "Please Select Category",
      name: "pleaseSelectCategory",
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

  String get pleaseEnterCartName {
    return Intl.message(
      "Please Enter Cart Name",
      name: "pleaseEnterCartName",
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

  String get noFollowingUsers {
    return Intl.message(
      "No following users",
      name: "noFollowingUsers",
    );
  }

  String get noFollowers {
    return Intl.message(
      "No followers",
      name: "noFollowers",
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

  String get noTransaction {
    return Intl.message(
      "No Transactions",
      name: "noTransaction",
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

  String get shippingAddress {
    return Intl.message(
      "Shipping Address",
      name: "shippingAddress",
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
      "This cart is empty",
      name: "thisCartIsEmpty",
    );
  }

  String get total {
    return Intl.message(
      "Total",
      name: "total",
    );
  }

  String get subTotal {
    return Intl.message(
      "Subtotal",
      name: "subTotal",
    );
  }

  String get shipping {
    return Intl.message(
      "Shipping",
      name: "shipping",
    );
  }

  String get tax {
    return Intl.message(
      "Tax",
      name: "tax",
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

  String get paymentReceived {
    return Intl.message(
      "Payment Received",
      name: "paymentReceived",
    );
  }

  String get orderPickedUp {
    return Intl.message(
      "Order Picked Up",
      name: "orderPickedUp",
    );
  }

  String get outForDelivery {
    return Intl.message(
      "Out For Delivery",
      name: "outForDelivery",
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

  String get selectRequiredAddons {
    return Intl.message(
      "Select required addons",
      name: "selectRequiredAddons",
    );
  }

  String get selectVariantColor {
    return Intl.message(
      "Select colour first",
      name: "selectVariantColor",
    );
  }

  String get selectVariantSize {
    return Intl.message(
      "Select size first",
      name: "selectVariantSize",
    );
  }

  String get selectVariantColorSize {
    return Intl.message(
      "Select colour and size",
      name: "selectVariantColorSize",
    );
  }

  String get share {
    return Intl.message(
      "Share",
      name: "share",
    );
  }

  String get download {
    return Intl.message(
      "Download",
      name: "download",
    );
  }

  String get print {
    return Intl.message(
      "Print",
      name: "print",
    );
  }

  String get highestPrice {
    return Intl.message(
      "Highest price",
      name: "highestPrice",
    );
  }

  String get lowestPrice {
    return Intl.message(
      "Lowest price",
      name: "lowestPrice",
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

  String get social {
    return Intl.message(
      "Socials",
      name: "social",
    );
  }

  String get lifestyle {
    return Intl.message(
      "Lifestyles",
      name: "lifestyle",
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

  String get shippingOptions {
    return Intl.message(
      "Shipping Options",
      name: "shippingOptions",
    );
  }

  String get addShippingOption {
    return Intl.message(
      "Add Shipping Option",
      name: "addShippingOption",
    );
  }

  String get modifyShippingOption {
    return Intl.message(
      "Modify Shipping Option",
      name: "modifyShippingOption",
    );
  }

  String get edit {
    return Intl.message(
      "Edit",
      name: "edit",
    );
  }

  String get blogs {
    return Intl.message(
      "Blogs",
      name: "blogs",
    );
  }

  String get ask {
    return Intl.message(
      "Ask",
      name: "ask",
    );
  }

  String get deletePost {
    return Intl.message(
      "Delete Post",
      name: "deletePost",
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

  String get registerAccountUserAgreeTerm {
    return Intl.message(
      "I confirm that this number is valid and I can receive OTP with it to continue this registration.",
      name: "registerAccountUserAgreeTerm",
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
  String get friends {
    return Intl.message(
      "Friends",
      name: "friends",
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

  String get following {
    return Intl.message(
      "Following",
      name: "following",
    );
  }

  String get followers {
    return Intl.message(
      "Followers",
      name: "followers",
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

  String get myContacts {
    return Intl.message(
      "Contacts",
      name: "myContacts",
    );
  }

  String get chatChannels {
    return Intl.message(
      "Channels",
      name: "chatChannels",
    );
  }

  String get noChannels {
    return Intl.message(
      "No Channels",
      name: "noChannels",
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

  //find jobs
  String get categories {
    return Intl.message(
      "Categories",
      name: "categories",
    );
  }

  String get from {
    return Intl.message(
      "From",
      name: "from",
    );
  }

  String get jobTitle {
    return Intl.message(
      "Job Title",
      name: "job title",
    );
  }

  String get jobAddedSuccessfully {
    return Intl.message(
      "Job Added Successfully",
      name: "jobAddedSuccessfully",
    );
  }

  String get jobListSuccessfully {
    return Intl.message(
      "Job Listed Successfully",
      name: "jobListedSuccessfully",
    );
  }

  String get jobEditedSuccessfully {
    return Intl.message(
      "Job Edited Successfully",
      name: "jobEditedSuccessfully",
    );
  }

  String get wantToGetDone {
    return Intl.message(
      "Job Description",
      name: "whatDoYouWantToGetDone",
    );
  }

  String get jobCategoryFit {
    return Intl.message(
      "Which category best fit this task?",
      name: "whichCategoryBestFitThisTask?",
    );
  }

  String get jobTiming {
    return Intl.message(
      "Timing",
      name: "timing",
    );
  }

  String get tuskFee {
    return Intl.message(
      "Task Fee",
      name: "taskFee",
    );
  }

  String get howToDoIt {
    return Intl.message(
      "How can this task be done?",
      name: "howCanThisTaskBeDone?",
    );
  }

  String get yourBudget {
    return Intl.message(
      "Your Budget",
      name: "yourBudget",
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
