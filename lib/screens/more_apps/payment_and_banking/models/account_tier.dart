/// tier_type : "1"
/// daily_cumulative_transaction_limit : "50000"
/// cumulative_balance : "300000"

class AccountTier {
  AccountTier({
    this.tierType,
    this.dailyCumulativeTransactionLimit,
    this.cumulativeBalance,
  });

  AccountTier.fromJson(dynamic json) {
    tierType = json['tier_type'];
    dailyCumulativeTransactionLimit =
        json['daily_cumulative_transaction_limit'];
    cumulativeBalance = json['cumulative_balance'];
  }
  String? tierType;
  String? dailyCumulativeTransactionLimit;
  String? cumulativeBalance;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['tier_type'] = tierType;
    map['daily_cumulative_transaction_limit'] = dailyCumulativeTransactionLimit;
    map['cumulative_balance'] = cumulativeBalance;
    return map;
  }
}
