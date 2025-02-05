import 'dart:convert';

void main() {
  String data = jsonEncode({
    'price': 300,
    'user_currency_rate': 'd7039710-772c-4b58-9750-2f35b9f10bf2'
  });

  print(data);
}
