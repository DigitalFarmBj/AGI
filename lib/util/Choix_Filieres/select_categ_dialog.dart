import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'categories.dart';
import 'notif.dart';

// ignore: must_be_immutable
class AddCategDialog extends StatelessWidget {
  // final Map<String, dynamic> userMap;
  // final String chatRoomId;
  AddCategDialog({
    Key? key,
    /*required this.userMap, required this.chatRoomId*/
  }) : super(key: key);

  // ignore: non_constant_identifier_names
  late dynamic MsgCat;
  @override
  Widget build(BuildContext context) {
    final _singleChoice = Provider.of<SingleChoice>(context);
    return AlertDialog(
      title: const Text('Choix de la catégorie'),
      content: SingleChildScrollView(
          child: Container(
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: categories
              .map((e) => RadioListTile(
                  title: Text(e),
                  value: e,
                  groupValue: _singleChoice.currentCateg,
                  selected: _singleChoice.currentCateg == e,
                  onChanged: (value) {
                    _singleChoice.updateCategory(value);
                    print(value);

                    /*  Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => AdminScreen(
                              userMap: userMap,
                              chatRoomId: chatRoomId,
                              categChoice: value,
                            )));
                 */
                    Navigator.of(context).pop();
                  }))
              .toList(),
        ),
      )),
    );
  }
}
