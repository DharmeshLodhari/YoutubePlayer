import 'package:flutter/material.dart';

class Country {
  String name;
  String flag;
  String phonePrefix;

  Country({
    @required this.name,
    @required this.phonePrefix,
    this.flag,
  });
}
