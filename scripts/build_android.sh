echo BUILDING ANDROID SLYDO
cd .. &&  rm -rf pubspec.lock && fvm flutter clean && fvm flutter pub get
fvm flutter build apk --release
#fvm flutter build appbundle --release
#open /Users/macminisrashtasoft/Hemali/slydo/build/app/outputs/bundle/release/
open /Users/macmini8/Documents/Project/slydo/build/app/outputs/flutter-apk/
#open /Users/brijeshsakariya/StudioProjects/slydo/build/app/outputs/flutter-apk/
#open /Users/macminisrashtasoft/Hemali/slydo/build/app/outputs/flutter-apk/
