

import 'package:flutter/material.dart';

import 'drawer_item.dart';
import 'drawer_items.dart';

class DrawerWidget extends StatelessWidget {
  final ValueChanged<DrawerItem> onSelectedItem;
  const DrawerWidget({super.key, required this.onSelectedItem});

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        child: Column(children: [buildDrawerItems(context)]),
      );

  Widget buildDrawerItems(BuildContext context) => Column(
      children: DrawerItems.all
          .map((item) => ListTile(
                leading: item.img,
                title: Text(
                  item.title,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                onTap: () => onSelectedItem(item),
              ))
          .toList());
}
