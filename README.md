# slydo

A new Flutter application.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


rm -rf ~/Developer/flutter/bin/cache
flutter doctor -v 
flutter clean     

### COMMANDS TO CREATE LOCALIZATION FILES 

1)

## NOTE: DO NOT REMOVE intl_XX.arb FILE EXCEPT FROM intl_XX.arb DELETE ALL FILE FROM l10n directory

DELETE intl_messages.arb and all (messages_XX.dart) from l10n folder

## THEN RUN THIS COMMAND
flutter pub run intl_translation:extract_to_arb --output-dir=lib/l10n lib/locale/app_localization.dart

intl_messages.arb file will be created in that directory

2)

## RUN THIS COMMAND WITH ALL THE ARB FILE PATH

flutter pub run intl_translation:generate_from_arb \
--output-dir=lib/l10n --no-use-deferred-loading \
lib/l10n/intl_messages.arb 
lib/l10n/intl_es.arb 
lib/l10n/intl_fr.arb 
lib/l10n/intl_pt.arb 
lib/l10n/intl_en.arb 
lib/l10n/intl_ha.arb 
lib/l10n/intl_yo.arb 
lib/l10n/intl_zu.arb 
lib/l10n/intl_sw.arb 
lib/l10n/intl_ar.arb 
lib/l10n/intl_am.arb 
lib/locale/app_localization.dart

flutter pub run intl_translation:generate_from_arb \
--output-dir=lib/l10n --no-use-deferred-loading \lib/l10n/intl_messages.arb lib/l10n/intl_es.arb lib/l10n/intl_fr.arb lib/l10n/intl_pt.arb lib/l10n/intl_en.arb lib/l10n/intl_ha.arb lib/l10n/intl_yo.arb lib/l10n/intl_zu.arb lib/l10n/intl_sw.arb lib/l10n/intl_ar.arb lib/l10n/intl_am.arb lib/locale/app_localization.dart
