import 'package:flutter/cupertino.dart';

class Navigate {
  static void gotoLogin(BuildContext context) {
    Navigator.pushNamed(context, "/login");
  }

  static void gotoAuthenticate(BuildContext context) {
    Navigator.pushNamed(context, "/auth");
  }
}
