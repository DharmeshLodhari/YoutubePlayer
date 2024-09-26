import 'dart:convert';

void main() {
  String data = jsonEncode({
    "price": 15000,
    "user_currency_rate": "49f52fc9-75cd-432d-b534-85ebb02555b7"
  });

  print(data);
}
