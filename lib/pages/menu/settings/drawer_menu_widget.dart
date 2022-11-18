import 'dart:ui';

import 'package:flutter/material.dart';



class DrawerMenuWidget extends StatelessWidget {
  final VoidCallback onClicked;
  const DrawerMenuWidget({super.key, required this.onClicked});

  @override
  Widget build(BuildContext context) => IconButton(
      onPressed: onClicked, icon: Icon(Icons.menu),
      color: Colors.white,
      
      
      
      );
}
