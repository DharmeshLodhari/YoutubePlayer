import 'dart:convert';

import 'package:Slydo/screens/more_apps/payment_and_banking/models/FinancialInstitution.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/models/account_tier.dart';

class VirtualAccount {
  String? accountName;
  String? accountNumber;
  String? createdAt;
  String? customerUsername;
  FinancialInstitution? financialInstitution;
  AccountTier? accountTier;
  bool? isActive;
  String? note;
  String? updatedAt;

  VirtualAccount({
    this.accountName,
    this.accountNumber,
    this.createdAt,
    this.customerUsername,
    this.financialInstitution,
    this.accountTier,
    this.isActive,
    this.note = "",
    this.updatedAt,
  });

  factory VirtualAccount.fromJson(Map<String, dynamic> json) {
    return VirtualAccount(
      accountName: json['account_name'],
      accountNumber: json['account_number'],
      createdAt: json['created_at'],
      customerUsername: json['customer_username'],
      financialInstitution: json['financial_institution'] != null
          ? FinancialInstitution.fromJson(json['financial_institution'])
          : null,
      accountTier: json['account_tier'] != null
          ? AccountTier.fromJson(json['account_tier'])
          : null,
      isActive: json['is_active'],
      note: json['note'],
      updatedAt: json['updated_at'],
    );
  }

  factory VirtualAccount.fromDBJson(Map<String, dynamic> json) {
    return VirtualAccount(
      accountName: json['account_name'],
      accountNumber: json['account_number'],
      createdAt: json['created_at'],
      customerUsername: json['customer_username'],
      financialInstitution: FinancialInstitution.fromJson(
        jsonDecode(json['financial_institution']),
      ),
      accountTier: AccountTier.fromJson(
        jsonDecode(json['account_tier']),
      ),
      isActive: json['is_active'] == 1 ? true : false,
      note: json['note'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['account_name'] = this.accountName;
    data['account_number'] = this.accountNumber;
    data['created_at'] = this.createdAt;
    data['customer_username'] = this.customerUsername;
    data['is_active'] = this.isActive;
    data['note'] = this.note;
    data['updated_at'] = this.updatedAt;
    if (this.financialInstitution != null) {
      data['financial_institution'] = this.financialInstitution!.toJson();
    }
    if (this.accountTier != null) {
      data['account_tier'] = this.accountTier!.toJson();
    }
    return data;
  }

  Map<String, dynamic> toDBJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['account_name'] = this.accountName;
    data['account_number'] = this.accountNumber;
    data['created_at'] = this.createdAt;
    data['customer_username'] = this.customerUsername;
    data['is_active'] = this.isActive == true ? 1 : 0;
    data['note'] = this.note;
    data['updated_at'] = this.updatedAt;
    data['financial_institution'] =
        jsonEncode(this.financialInstitution!.toJson());
    data['account_tier'] = jsonEncode(this.accountTier!.toJson());
    return data;
  }
}
