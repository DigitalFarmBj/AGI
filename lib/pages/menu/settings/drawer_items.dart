

import 'package:flutter/material.dart';

import 'drawer_item.dart';

class DrawerItems {
  static const climat = DrawerItem(
      title: 'Climat/Eau',
      img: CircleAvatar(
        
        backgroundImage: AssetImage("assets/images/climat.png", ),
      ));
  static const prVeg = DrawerItem(
      title: 'Production végétale',
      img: CircleAvatar(
        backgroundImage: AssetImage("assets/images/proVeget.png"),
      ));

  static const prAnim = DrawerItem(
      title: 'Elevage',
      img: CircleAvatar(
        backgroundImage: AssetImage("assets/images/elevag.png"),
      ));


  static const peche = DrawerItem(
      title: 'Pêche/Aquaculture',
      img: CircleAvatar(
        backgroundImage: AssetImage("assets/images/peche.png"),
      ));


  static const trAgro = DrawerItem(
      title: 'Trans-agroalimentaire',
      img: CircleAvatar(
        backgroundImage: AssetImage("assets/images/transagro.png"),
      ));


  

  static const intrant = DrawerItem(
      title: 'Intrants/Equipements',
      img: CircleAvatar(
        backgroundImage: AssetImage("assets/images/intrants.png"),
      ));

  


  static const other = DrawerItem(
      title: 'Autres',
      img: CircleAvatar(
        backgroundColor: Colors.white,

        backgroundImage: AssetImage("assets/images/other.png",),
      ));

  static const tous = DrawerItem(
      title: 'Voir Tous'
      ,
      
      img: 
      
     CircleAvatar(
        backgroundColor: Colors.white,
        radius: 15,
       
        backgroundImage: AssetImage("assets/images/view.png"),
      )
      
      );

       static const signaler = DrawerItem(
      title: 'Signaler',
      img: CircleAvatar(
        backgroundColor: Colors.white,
       backgroundImage: AssetImage("assets/images/alert.png"),
      ));

  

  static final List<DrawerItem> all = [
    tous,
    climat,
    prVeg,
    prAnim,
    peche,
    trAgro,
    
    intrant,
    
    other,
    
    signaler

    
  ];
}
