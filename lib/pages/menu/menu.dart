import 'package:flutter/material.dart';

class Menu extends StatelessWidget {
  Menu({Key? key}) : super(key: key);

  final List mainItems = [
    {"nom":'Climat',
    "photo":"assets/images/climat.png"},
    {"nom":'Riz',
    "photo":"assets/images/rice.jpg"},
    {"nom":'Maïs',
    "photo":"assets/images/ma.jpg"},
    {"nom":'Soja',
    "photo":"assets/images/soja.jpg"},
    {"nom":'Ananas',
    "photo":"assets/images/ana.jpg"},
    {"nom":'Maraichage',
    "photo":"assets/images/marai.jpg"},
    {"nom":'Anarcade',
    "photo":"assets/images/anarcade.png"},
    {"nom":'Cacao',
    "photo":"assets/images/cacao.png"},
    {"nom":'Hévéa',
    "photo":"assets/images/hevea.png"},
    {"nom":'Coton',
    "photo":"assets/images/coton.png"},
    {"nom":'Manioc',
    "photo":"assets/images/manioc.png"},
    {"nom":'Igname',
    "photo":"assets/images/igname.png"},
    {"nom":'Patate',
    "photo":"assets/images/patate.png"},
    {"nom":'Autre',
    "photo":"assets/images/other.png"},
    
    
  
    
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: mainItems.map((item) {
        return Container(
          //color: Colors.blue,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          child: Column(
            children: [
              CircleAvatar(
              backgroundColor: Colors.white,
              radius: 20,
              backgroundImage: AssetImage(item['photo']),),
              const SizedBox(height: 8,),
              Text(item['nom'], maxLines: 1,
              style: const TextStyle(
                fontSize: 12
              ),)
            ],
          ),
        );
      }).toList()
          

          ),
    );
  }
}
