class CreditCardData {
  int amount;
  String? pin;
  String cvv;
  String email;
  int cardNumber;
  String? currency;
  String expiryDate;
  String cardHolder;

  CreditCardData({
    this.pin,
    this.currency,
    required this.cvv,
    required this.email,
    required this.amount,
    required this.expiryDate,
    required this.cardHolder,
    required this.cardNumber,
  });

  copyWith({
    int? amount,
    String? pin,
    String? cvv,
    String? email,
    int? cardNumber,
    String? currency,
    String? expiryDate,
    String? cardHolder,
  }) {
    return CreditCardData(
      pin: pin ?? this.pin,
      cvv: cvv ?? this.cvv,
      email: email ?? this.email,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      expiryDate: expiryDate ?? this.expiryDate,
      cardHolder: cardHolder ?? this.cardHolder,
      cardNumber: cardNumber ?? this.cardNumber,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "cvv": cvv,
      "pin": pin,
      "email": email,
      "amount": amount,
      "currency": currency,
      "expiry_date": expiryDate,
      "card_holder": cardHolder,
      "card_number": cardNumber,
    };
  }
}
