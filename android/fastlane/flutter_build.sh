#!/bin/bash
cd ../../
if [ "$1" == "--clean" ]
then
   echo "Running clean..."
   fvm flutter clean
else
   echo "Skipping clean..."
fi
if [ "$1" == "--apk" ]
then
   echo "Building APK..."
   fvm flutter build apk --release
else
   echo "Building AAB..."
   fvm flutter build appbundle --release
fi