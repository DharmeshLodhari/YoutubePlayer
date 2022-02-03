package com.slydo.slydo;

import io.flutter.app.FlutterApplication;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.PluginRegistrantCallback;
//import io.flutter.plugins.firebasemessaging.FlutterFirebaseMessagingService;
//import io.flutter.plugins.firebasemessaging.FirebaseMessagingPlugin;
import io.flutter.plugins.pathprovider.PathProviderPlugin;
import com.dexterous.flutterlocalnotifications.FlutterLocalNotificationsPlugin;
import me.carda.awesome_notifications.AwesomeNotificationsPlugin;
import com.tekartik.sqflite.SqflitePlugin;
import io.flutter.plugins.deviceinfo.DeviceInfoPlugin;
import com.example.devicelocale.DevicelocalePlugin;
//import be.tramckrijte.workmanager.WorkmanagerPlugin;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.embedding.engine.FlutterEngine;

import android.os.Build;

public class Application extends FlutterApplication implements PluginRegistrantCallback {
    @Override
    public void onCreate() {
        super.onCreate();
//        FlutterFirebaseMessagingService.setPluginRegistrant(this);
//        WorkmanagerPlugin.setPluginRegistrantCallback(this);
    }

    @Override
    public void registerWith(PluginRegistry registry) {
        PathProviderPlugin.registerWith(registry.registrarFor("io.flutter.plugins.pathprovider.PathProviderPlugin"));
        SqflitePlugin.registerWith(registry.registrarFor("com.tekartik.sqflite.SqflitePlugin"));
        DeviceInfoPlugin.registerWith(registry.registrarFor("io.flutter.plugins.deviceinfo.DeviceInfoPlugin"));
        DevicelocalePlugin.registerWith(registry.registrarFor("com.example.devicelocale.DevicelocalePlugin"));
        AwesomeNotificationsPlugin.registerWith(registry.registrarFor("me.carda.awesome_notifications.AwesomeNotificationsPlugin"));
//        FirebaseMessagingPlugin.registerWith(registry.registrarFor("io.flutter.plugins.firebasemessaging.FirebaseMessagingPlugin"));
        FlutterLocalNotificationsPlugin.registerWith(registry.registrarFor("com.dexterous.flutterlocalnotifications.FlutterLocalNotificationsPlugin"));
//        WorkmanagerPlugin.registerWith(registry.registrarFor("be.tramckrijte.workmanager.WorkmanagerPlugin"));
    }
}