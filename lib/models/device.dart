class Device {
  String firebaseToken;
  String type; // Android OR IOS
  String mode;
  String deviceId;
  String deviceName;

  Device(
      {this.firebaseToken,
      this.type,
      this.mode,
      this.deviceId,
      this.deviceName});
}

class Language {
  const Language(this.name, this.languageCode);
  final String name;
  final String languageCode;
}

List<Language> languages = <Language>[
  Language('English', 'en'),
  Language('Spanish', 'es'),
  Language('French', 'fr'),
  Language('Portuguese', 'pt'),
  Language('Hausa', "ha"),
  Language('Yoruba', "yo"),
  Language('Zulu', 'zu'),
  Language('Swahili', "sw"),
  Language('Arabic', "ar"),
  Language('Amharic', "am"),
];

Language getLanguageByLanguageCode(String languageCode) {
  // ignore: missing_return
  languages.forEach((lang) {
    if (languageCode == lang.languageCode) {
      return lang;
    }
  });
  return languages.first;
}
