import 'package:flutter/services.dart';

abstract class StringValidator {
  bool isValid(String value);
}

class RegexValidator implements StringValidator {
  final String regexSource;
  RegexValidator({required this.regexSource});

  @override
  bool isValid(String value) {
    try {
      final regex = RegExp(regexSource);
      final matches = regex.allMatches(value);
      for (Match match in matches) {
        if (match.start == 0 && match.end == value.length) return true;
      }
      return false;
    } catch (e) {
      //invalid regex
      assert(false, e.toString());
      return true;
    }
  }
}

class ValidatorInputFormater implements TextInputFormatter {
  final StringValidator editingVali;
  ValidatorInputFormater({required this.editingVali});
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final odldValueValid = editingVali.isValid(oldValue.text);
    final newValueValid = editingVali.isValid(newValue.text);
    if (odldValueValid && !newValueValid) return oldValue;
    return newValue;
  }
}
