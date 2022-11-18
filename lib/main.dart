
import 'package:agriconnect/pages/validator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'pages/Sign_Registed/Autheticate.dart';
import 'pages/Sign_Registed/loginPage.dart';
import 'pages/splashScreen.dart';
import 'util/Choix_Filieres/notif.dart';
import 'util/pushNotification/notification_page.dart';

Future<void> _firebaseMessaging(RemoteMessage message) async {
  print("Manipulation des messages en arrière plan ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  LocalNotification();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessaging);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,
  ]).then(
    (value) => runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider<SingleChoice>(create: (_) => SingleChoice())
      ],
      child: const MyApp(),
    )),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          fontFamily: 'Poppins',
          primarySwatch: Colors.blue,
        ),
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
        routes: {
          "/login": (context) => const LoginScreen(),
          "/auth": (context) => const Authenticate(),
        }
        
        
        
        );
  }
}

class DecimalNumberSubmitValidator implements StringValidator {
  @override
  bool isValid(String value) {
    try {
      final number = double.parse(value);
      return number > 0.0;
    } catch (e) {
      return false;
    }
  }
}

class EmailEditingRegexValidator extends RegexValidator {
  EmailEditingRegexValidator()
      : super(
            regexSource:
                "^[a-zA-Z0-9_.+-]*(@([a-zA-Z0-9-]*(\\.[a-zA-Z0-9-]*)?)?)?\$");
}

class EmailEmailSubmitRegexValidator extends RegexValidator {
  EmailEmailSubmitRegexValidator()
      : super(
            regexSource:
                "^[a-zA-Z0-9_.+-]*(@([a-zA-Z0-9-]*(\\.[a-zA-Z0-9-]*)?)?)?\$");
}
