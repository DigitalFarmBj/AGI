import 'dart:convert';

import 'package:cupertino_list_tile/cupertino_list_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';

class SelectCategorie extends StatefulWidget {
  const SelectCategorie({Key? key}) : super(key: key);

  @override
  _SelectCategorieState createState() => _SelectCategorieState();
}

class _SelectCategorieState extends State<SelectCategorie> {
  List<dynamic>? donneeRecup; // data decoded from the json file
  List<dynamic>? donnee; // data to display on the screen
  var _searchController = TextEditingController();
  var searchValue = "";
  @override
  void initState() {
    _getData();
  }

  Future _getData() async {
    final String response = await rootBundle.loadString('assets/admin.json');
    donneeRecup = await json.decode(response) as List<dynamic>;
    setState(() {
      donnee = donneeRecup;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [Colors.green, Colors.red],
                  begin: Alignment.bottomRight,
                  end: Alignment.topLeft)),
      child: CupertinoPageScaffold(
        backgroundColor: Colors.transparent,
        
        child: CustomScrollView(

          slivers: [

            const CupertinoSliverNavigationBar(
              
              largeTitle: Text(
                "Selectionner la categorie",
                style: TextStyle(fontSize: 12, color: Colors.green),
              ),
              previousPageTitle: "",
            ),
            SliverToBoxAdapter(
              child: CupertinoSearchTextField(
                onChanged: (value) {
                  setState(() {
                    searchValue = value;
                  });
                },
                controller: _searchController,
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate((donnee != null)
                  ? donnee!
                      .where((e) => e['cat']
                          .toString()
                          .toLowerCase()
                          .contains(searchValue.toLowerCase()))
                      .map((e) => CupertinoListTile(
                            onTap: () {
                              print(e['cat']);
                              Navigator.pop(context, {
                                "cat": e['cat'],
                              });
                            },
                            title: Text(e['cat']),
                          ))
                      .toList()
                  : [Center(child: Text("Loading"))]),
            )
          ],
        ),
      ),
    );
  }
}
