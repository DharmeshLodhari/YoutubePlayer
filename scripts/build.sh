echo BUILDING IOS SLYDO
cd .. && cd ios && rm -rf Pods && rm -rf .symlinks && rm -rf Podfile.lock && cd .. && rm -rf pubspec.lock && fvm flutter clean && fvm flutter pub get && cd ios && pod install && cd ..
fvm flutter build xcarchive --release
open /Users/brijeshsakariya/StudioProjects/slydo/build/ios/archive/Runner.xcarchive