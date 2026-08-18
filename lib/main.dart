import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_languages.dart';
import 'package:fuodz/my_app.dart';
import 'package:fuodz/services/crashlytics.service.dart';
import 'package:fuodz/services/local_storage.service.dart';
import 'package:fuodz/services/phone_util.service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

//ssll handshake error
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      //setting up firebase notifications
      await Firebase.initializeApp();
      await PhoneUtilService.init();

      await translator.init(
        localeType: LocalizationDefaultType.asDefined,
        languagesList: AppLanguages.codes,
        assetsDirectory: 'assets/lang/',
      );

      //
      await LocalStorageService.getPrefs();

      //prevent ssl error
      HttpOverrides.global = new MyHttpOverrides();
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
      CrashlyticsService.log("App started");

      //font
      await GoogleFonts.pendingFonts([GoogleFonts.plusJakartaSans()]);
      // Run app!
      runApp(LocalizedApp(child: MyApp()));
    },
    (error, stackTrace) {
      CrashlyticsService.recordError(error, stackTrace, reason: "runZonedGuarded");
    },
  );
}
