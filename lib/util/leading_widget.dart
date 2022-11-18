import 'dart:io';

import 'package:flutter/material.dart';

class LeadingWidget extends StatelessWidget {
  final void Function() onPressed;
  final bool isEnable;
  const LeadingWidget({Key? key, required this.onPressed, required this.isEnable}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if(!isEnable) {
      return Container();
    }
    if (Platform.isAndroid) {
      return IconButton(onPressed: onPressed, icon: Icon(Icons.arrow_back));
    } else {
      return IconButton(onPressed: onPressed, icon: Icon(Icons.arrow_back_ios));
    }
  }
}
