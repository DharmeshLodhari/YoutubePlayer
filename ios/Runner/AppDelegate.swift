import UIKit
import Flutter
import GoogleMaps
import Firebase
import flutter_downloader

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      FirebaseApp.configure()
      FlutterDownloaderPlugin.setPluginRegistrantCallback(registerPlugins)
//       GMSServices.provideAPIKey("AIzaSyCLDiXFm1mRQEsutNrxX_Hv-sHrbhvASzY")
      GMSServices.provideAPIKey("AIzaSyAs0AD96236ASgq_7l8u4q9OHW0bOuESV8")
      application.registerForRemoteNotifications()
      GeneratedPluginRegistrant.register(with: self)
      return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

private func registerPlugins(registry: FlutterPluginRegistry) {
    if (!registry.hasPlugin("FlutterDownloaderPlugin")) {
       FlutterDownloaderPlugin.register(with: registry.registrar(forPlugin: "FlutterDownloaderPlugin")!)
    }
}

