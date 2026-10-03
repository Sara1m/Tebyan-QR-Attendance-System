import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'app/routes/app_pages.dart';
import 'app/src/session.dart';
import 'app/src/settings_service.dart';
import 'firebase_options.dart';
import 'generated/locales.g.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final storage = GetStorage();
  final String lang = storage.read('lang') ?? 'ar';

  // Wait until a saved login (if any) has been restored.
  final user = await FirebaseAuth.instance.authStateChanges().first;
  if (user == null) await Session.clear();

  final settings = Get.put(SettingsService(), permanent: true);

  runApp(
    GetMaterialApp(
      title: 'Tebyan',
      initialRoute: Session.isSignedIn ? Session.homeRoute : Routes.LOGIN,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
      translationsKeys: AppTranslation.translations,
      locale: Locale(lang),
      fallbackLocale: const Locale('en'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: settings.getLightTheme(),
      defaultTransition: Transition.cupertino,
    ),
  );
}
