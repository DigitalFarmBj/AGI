


import 'package:agriconnect/pages/Sign_Registed/signIn.dart';
import 'package:agriconnect/pages/about/hero_dialod_route.dart';
import 'package:agriconnect/pages/user_profile/profileScreen.dart';
import 'package:agriconnect/util/DeviceInfo/DeviceInfo.dart';
import 'package:agriconnect/util/DeviceInfo/ipDeviceInfo.dart';
import 'package:agriconnect/util/SelectUser/allUser.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';


class AuthService {
  final auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic> map = {};
  List<dynamic> list = [];

  Future<User?> createAccount(context, email, password, nom, type, number, pays,
      statut, langue, filieres) async {
    try {
       showDialog(
        context: context,
        builder: (context) {
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      );
      UserCredential user = await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      print("Enregistrement reussie");
      user.user!.updateDisplayName(nom);

      await _firestore.collection('userData').doc(auth.currentUser!.uid).set({
        "identifiant": email,
        "nom": nom,
        "utilisateur": type,
        "numero": number,
        "pays": pays,
        "code": password,
        "filieres": filieres,
        "langue": langue,
        "uid": auth.currentUser!.uid,
        "statut": statut,
        "isSelect": false,
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: SaveSuccefully(
          content: 'Utilissateur enregistrer avec succès',
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ));
      /* Navigator.of(context).push(HeroDialogRoute(
        builder: (context) {
          return const SaveUserDialog(
            msg: 'Utilissateur enregistrer avec succès',
          );
        },
      ));*/

      //initUser(user);

      await auth.signOut;
      storeNotification();
    } catch (e) {
      //errorBox(context, e);
      Navigator.of(context).push(HeroDialogRoute(
        builder: (context) {
          return const SaveUserDialog(
            msg: 'Mot de passe Erroné',
          );
        },
      ));
      return null;
    }
  }

  Future<User?> loginUser(context, email, password) async {
    try {
      showDialog(
        context: context,
        builder: (context) {
          return  Center(
            child: SpinKitFadingFour(
              color: Colors.white,
            ),
          );
        },
      );

      UserCredential userCredential = await auth.signInWithEmailAndPassword(
          email: email, password: password);
      print('Connection reussite!');
      _firestore
          .collection('userData')
          .doc(auth.currentUser!.uid)
          .get()
          .then((value) => {
                userCredential.user!.updateDisplayName(value['nom']),
                if (value['statut'] == 'admin')
                  {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AllUsers()))
                  }
                else if (value['statut'] == 'éditeur')
                  {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AllUsers()))
                  }
                else
                  {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ProfileScreen()))
                  }
              });
      storeNotification();
      /* _firestore
          .collection('userData')
          .doc(auth.currentUser!.uid)
          .update({"users": FieldValue.arrayUnion(list)});*/
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: ErrorSnackBar(
          title: 'Erreur',
          content: 'Identifiant ou Code incorrect',
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ));
      //errorBox(context, 'Identifiant ou Code incorrect');
    }
  }

  Future init() async {
    final ipAdress = await IpInfoApi.getIpAdress();
    final phone = await DeviceInfo.getPhone();

    map = {'IP Adress': ipAdress, 'phone': phone};
    list.add(map);
  }

  void errorBox(context, e) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: const Text("Erreur"),
            content: Text(e.toString(),
                style:
                    const TextStyle(color: Color.fromARGB(183, 94, 171, 56))),
          );
        });
  }

  storeNotification() async {
    String? token = await FirebaseMessaging.instance.getToken();
    _firestore
        .collection('userData')
        .doc(auth.currentUser!.uid)
        .set({'token': token}, SetOptions(merge: true));
  }
}

class SaveSuccefully extends StatelessWidget {
  final String content;
  const SaveSuccefully({
    Key? key,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: EdgeInsets.all(16),
          height: 90,
          decoration: BoxDecoration(
              color: Color.fromARGB(255, 44, 199, 70),
              borderRadius: BorderRadius.all(Radius.circular(20))),
          child: Row(
            children: [
              const SizedBox(
                width: 48,
              ),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Enregistrement",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      Spacer(),
                      Text(
                        content,
                        style: TextStyle(color: Colors.white, fontSize: 12),
                        maxLines: 12,
                        overflow: TextOverflow.ellipsis,
                      )
                    ]),
              ),
            ],
          ),
        ),
        Positioned(
            bottom: 0,
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.only(bottomLeft: Radius.circular(20)),
              child: SvgPicture.asset(
                "assets/images/bubbles.svg",
                height: 48,
                width: 40,
                color: Color.fromARGB(255, 185, 221, 23),
              ),
            )),
        Positioned(
            top: -20,
            left: 0,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SvgPicture.asset(
                  "assets/images/fail.svg",
                  height: 40,
                ),
                Positioned(
                  top: 10,
                  child: SvgPicture.asset(
                    "assets/images/close.svg",
                    height: 16,
                  ),
                ),
              ],
            ))
      ],
    );
  }
}
