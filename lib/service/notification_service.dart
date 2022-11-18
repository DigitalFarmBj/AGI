

import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static void initialize() {
    // pour envoyer de notification a iOS ou web
    FirebaseMessaging.instance.requestPermission();

    FirebaseMessaging.onMessage.listen((event) {
      print("Un nouveau evenment onMessage a été publié");
    });
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      print('Un nouveau evenment onMessageOpenedApp a été publié');
    });
  }

  static Future<String?> getToken() async {
    return FirebaseMessaging.instance.getToken(
        vapidKey:
            "BNCCa_3Fpb3i4kq-F70by7_OoM-yTYqmOuSlqUsxledKrHB0NEePBhbbK6SdLBnHmXAwvYaQGdusfWyKc9_5qto");
  }
}
