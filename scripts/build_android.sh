echo BUILDING ANDROID SLYDO
cd .. &&  rm -rf pubspec.lock && fvm flutter clean && fvm flutter pub get
fvm flutter build apk --release
#open /Users/macmini8/Documents/Project/slydo/build/app/outputs//bundle/release/
open /Users/macmini8/Documents/Project/slydo/build/app/outputs/flutter-apk/
#open /Users/brijeshsakariya/StudioProjects/slydo/build/app/outputs/flutter-apk/