import 'package:flutter/cupertino.dart';

import 'categories.dart';

class SingleChoice extends ChangeNotifier {
  String __currentCateg = categories[0];
  SingleChoice();
  String get currentCateg => __currentCateg;
  updateCategory(dynamic value) {
    if (value != null) {
      __currentCateg = value;
      notifyListeners();
    }
  }
}
