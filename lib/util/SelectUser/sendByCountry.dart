

import 'package:agriconnect/pages/AdminPage/adminPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SendByContry extends StatefulWidget {
  const SendByContry({Key? key}) : super(key: key);

  @override
  State<SendByContry> createState() => _SendByContryState();
}

class _SendByContryState extends State<SendByContry>
    with WidgetsBindingObserver {
  Map<String, dynamic>? userMap;
  bool isLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String contry = "";
  bool isAdmin = false;
  int index = 0;
  String idRecup = '';
  final isDialOpen = ValueNotifier(false);
  String pays = '';

  Future<String> getUser() async {
    await _firestore
        .collection('userData')
        .doc(_auth.currentUser!.uid)
        .get()
        .then((value) => {
              if (value['statut'] == 'admin')
                {
                  idRecup = value['identifiant'],
                  if (idRecup == _auth.currentUser!.email)
                    setState(() {
                      isAdmin = true;
                    })
                }
              else if (value['statut'] == 'éditeur')
                {contry = value['pays']}
              else
                contry = contry
            });
    return contry;
  }

  final Stream<QuerySnapshot> users = FirebaseFirestore.instance
      .collection('userData')
      .orderBy('statut', descending: false)
      .snapshots();
  Future<String> getUserCountry() async {
    await _firestore
        .collection('userData')
        .doc(_auth.currentUser!.uid)
        .get()
        .then((value) => {
              if (value['uid'] == _auth.currentUser!.uid)
                {
                  pays = value['pays'],
                }
              else
                pays = ''
            });
    return pays;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    getUser();
    fetch();
    getUserCountry();
  }

  String chatRoomId(String user) {
    return user;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        if (isDialOpen.value) {
          isDialOpen.value = false;
          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Les pays',
            style: TextStyle(fontFamily: "POPPINS"),
          ),
          centerTitle: true,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    colors: [Colors.green, Colors.red],
                    begin: Alignment.bottomRight,
                    end: Alignment.topLeft)),
          ),
          elevation: 20,
          automaticallyImplyLeading: false,
          //backgroundColor: Colors.grautomaticallyImplyLeading: false,een,
        ),
        body: isLoading
            ? Center(
                child: Container(
                  height: size.height / 20,
                  width: size.height / 20,
                  child: const CircularProgressIndicator(),
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                        alignment: Alignment.bottomLeft,
                        height: size.height,
                        width: size.width,
                        child: fetch()),
                  ],
                ),
              ),
      ),
    );
  }

  Widget fetch() {
    return StreamBuilder<QuerySnapshot>(
        stream: users,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something is wrong');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text('Loading');
          }
          final data = snapshot.requireData;

          return ListView.builder(
              itemCount: data.size,
              itemBuilder: (context, index) {
                Map<String, dynamic> map =
                    snapshot.data!.docs[index].data() as Map<String, dynamic>;
                if (map['pays'] == contry) {
                  return map != null
                      ? ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.green[700],
                            child: const Icon(Icons.account_box,
                                color: Colors.white),
                          ),
                          title: Text(
                            "${map['pays']}",
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          trailing: map['isSelect']
                              ? Icon(
                                  Icons.check_circle,
                                  color: Colors.green[700],
                                )
                              : const Icon(
                                  Icons.check_circle_outline,
                                  color: Colors.grey,
                                ),
                          onTap: () {
                            setState(() {
                              map['isSelect'] = !map['isSelect'];
                              if (map['isSelect'] == true) {
                                userMap = map;
                                String roomId = chatRoomId(userMap!['pays']);
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (_) => AdminScreen(
                                        userMap: userMap!,
                                        chatRoomId: roomId, token: '',)));
                              }
                            });
                          },
                        )
                      : Container();
                } else if (isAdmin == true) {
                  return map != null
                      ? ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.green[700],
                            child: const Icon(Icons.account_box,
                                color: Colors.white),
                          ),
                          title: Text(
                            "${map['pays']}",
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          trailing: map['isSelect']
                              ? Icon(
                                  Icons.check_circle,
                                  color: Colors.green[700],
                                )
                              : const Icon(
                                  Icons.check_circle_outline,
                                  color: Colors.grey,
                                ),
                          onTap: () {
                            setState(() {
                              map['isSelect'] = !map['isSelect'];
                              if (map['isSelect'] == true) {
                                userMap = map;
                                String roomId = chatRoomId(userMap!['pays']);
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (_) => AdminScreen(
                                        userMap: userMap!,
                                        chatRoomId: roomId, token: '',)));
                              }
                            });
                          },
                        )
                      : Container();
                } else {
                  return Container();
                }
              });
        });
  }
}
