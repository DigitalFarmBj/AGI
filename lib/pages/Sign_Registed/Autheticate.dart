


import 'package:agriconnect/pages/user_profile/profileScreen.dart';
import 'package:agriconnect/util/SelectUser/allUser.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'loginPage.dart';

/*class Authenticate extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final String id;
  @override
  Widget build(BuildContext context) {
    if (_auth.currentUser != null) {
      if (_auth.currentUser!.email == id) {
        return const AllUsers();
      } else {
        return const ViewMessages();
      }
    } else {
      return const LoginScreen();
    }
  }
}*/

class Authenticate extends StatefulWidget {
  const Authenticate({Key? key}) : super(key: key);

  @override
  State<Authenticate> createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String id = '';
  bool isAdmin = false;
  @override
  void initState() {
    super.initState();
    getUser();
  }

  Future<String> getUser() async {
    await _firestore
        .collection('userData')
        .doc(_auth.currentUser!.uid)
        .get()
        .then((value) => {
              if (value['statut'] == 'admin')
                {
                  id = value['identifiant'],
                  if (id == _auth.currentUser!.email)
                    setState(() {
                      isAdmin = true;
                    })
                }
              else if (value['statut'] == 'éditeur')
                {
                  id = value['identifiant'],
                  if (id == _auth.currentUser!.email)
                    setState(() {
                      isAdmin = true;
                    })
                }
              else
                {
                  id = value['identifiant'],
                  if (id == _auth.currentUser!.email)
                    setState(() {
                      isAdmin = false;
                    })
                }
            });
    return id;
  }

  @override
  Widget build(BuildContext context) {
    if (_auth.currentUser != null) {
      if (isAdmin == true) {
        return const AllUsers();
      } else {
        return const ProfileScreen();
      }
    } else {
      return const LoginScreen();
    }
  }
}
