import 'dart:io';

import 'package:agriconnect/pages/AdminPage/adminPage.dart';
import 'package:agriconnect/pages/AdminPage/sendingAll.dart';
import 'package:agriconnect/pages/Sign_Registed/SignForAll.dart';
import 'package:agriconnect/pages/Sign_Registed/loginPage.dart';
import 'package:agriconnect/pages/Sign_Registed/signIn.dart';
import 'package:agriconnect/pages/about/custom_rect_tween.dart';
import 'package:agriconnect/pages/about/hero_dialod_route.dart';
import 'package:agriconnect/pages/user_profile/profileScreen.dart';
import 'package:agriconnect/service/notification_service.dart';
import 'package:agriconnect/util/leading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import 'package:url_launcher/url_launcher.dart';

class AllUsers extends StatefulWidget {
  const AllUsers({Key? key}) : super(key: key);

  @override
  State<AllUsers> createState() => _AllUsersState();
}

class _AllUsersState extends State<AllUsers> with WidgetsBindingObserver {
  Map<String, dynamic>? userMap;
  bool isLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List groupList = [];
  List<String> useLng = [];
  String contry = "";
  bool isAdmin = false;
  int index = 0;
  String idRecup = '';
  final isDialOpen = ValueNotifier(false);
  String userId = '';
  bool _selectionChoisie = false;
  bool edit = false;

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
                {
                  setState(() {
                    edit = true;
                  }),
                  contry = value['pays'],
                  userId = value["identifiant"]
                }
              else
                contry = contry
            });
    return contry;
  }

  /* Future<String> getUserToken() async {
    await _firestore
        .collection('userData')
        .doc(_auth.currentUser!.uid)
        .get()
        .then((value) => {
              if (value['uid'] == _auth.currentUser!.uid)
                {
                  setState(() {
                    userToken = value['token'];
                  })
                }
              else
                userToken = ''
            });
    return userToken;
  }*/

  final Stream<QuerySnapshot> users = FirebaseFirestore.instance
      .collection('userData')
      .orderBy('statut', descending: true)
      .snapshots();
  /* Future<String> getUserCountry() async {
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
    return contry;
  }
*/
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    getUser();

    fetch();

    NotificationService.initialize();
  }

  Future openWebsite({required String url, bool inApp = false}) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      // ignore: deprecated_member_use
      await launch(url,
          forceWebView: inApp, forceSafariVC: inApp, enableJavaScript: true);
    }
  }

  String chatRoomId(String user) {
    return user;
  }

  /* Future<String> getUsers() async {
    await _firestore
        .collection('userData')
        .doc(_auth.currentUser!.uid)
        .get()
        .then((value) => {
              if (value['statut'] == 'admin')
                contry = value['pays']
              else
                contry = contry
            });
    return contry;
  }
*/
  void _supprAction() async {
    final confirmSuppr = await showDialog(
        context: context,
        builder: (context) {
          if (Platform.isIOS) {
            return CupertinoAlertDialog(
              title: const Text(
                  "Etes-vous sur de vouloir supprimer cet utilisateur?"),
              content: const Text(
                  "Après la suppression vous pouvez plus revenir en arrière!",
                  style: TextStyle(color: Color(0xFFFF0000))),
              actions: [
                TextButton(
                  child: const Text("non"),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                TextButton(
                  child: const Text("oui",
                      style: TextStyle(color: Color(0xFFFF0000))),
                  onPressed: () => Navigator.of(context).pop(true),
                )
              ],
            );
          } else {
            return AlertDialog(
              title: const Text(
                  "Etes-vous sur de vouloir supprimer cet utilisateur?"),
              actions: [
                TextButton(
                  child: const Text("non"),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                TextButton(
                  child: const Text("oui",
                      style: TextStyle(color: Color(0xFFFF0000))),
                  onPressed: () => Navigator.of(context).pop(true),
                )
              ],
            );
          }
        });

    if (confirmSuppr) {
      //controller.deleteContacts();
      setState(() {
        _selectionChoisie = false;
      });
    }
  }

  Future<bool> _onWillPop() async {
    if (_selectionChoisie) {
      setState(() {
        _selectionChoisie = false;
        //controller.clearSelected();
      });
      return false;
    } else {
      return true;
    }
  }

  Future addUser() async {
    if (isAdmin == true) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SignScreen(),
            fullscreenDialog: true,
          ));
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SignForAllScreen(),
            fullscreenDialog: true,
          ));
      /* final url = 'https://agrimeteo.hediong.org';
      openWebsite(url: url, inApp: true);*/
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        if (isDialOpen.value) {
          isDialOpen.value = false;
          return false;
        } else
          return true;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: LeadingWidget(
              isEnable: _selectionChoisie, onPressed: () => _onWillPop()),
          leadingWidth: _selectionChoisie ? kTextTabBarHeight : 0.0,

          /* actions: <Widget>[
            /*IconButton(
              icon: const Icon(
                Icons.add,
                size: 30,
              ),
              tooltip: 'Enregistrer un Utilisateur',
              onPressed: () async {
                if (isAdmin == true) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignScreen(),
                        fullscreenDialog: true,
                      ));
                } else {
                  final url = 'https://agrimeteo.hediong.org';
                  openWebsite(url: url, inApp: true);
                }
              },
            ),
            */
            IconButton(
                onPressed: () async {
                  FirebaseAuth _auth = FirebaseAuth.instance;
                  try {
                    await _auth.signOut();
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                          fullscreenDialog: true,
                        ));
                  } catch (e) {
                    print("error");
                  }
                },
                icon: const Icon(Icons.logout)),
          ],
         */
          title: const Text(
            'Les utilisateurs',
            style: TextStyle(fontFamily: "POPPINS"),
          ),
          actions: [
            Visibility(
              visible: _selectionChoisie,
              child: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: _supprAction,
              ),
            ),
            /*TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ProfileScreen(),
                          fullscreenDialog: true));
                },
                child: const CircleAvatar(
                  child: Icon(Icons.notifications_active),
                ))
          */

         
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15.0, vertical: 7),
                child: GNav(
                  color: Colors.white,
                  activeColor: Colors.white,
                  gap: 2,
                  tabBackgroundColor: Colors.transparent,
                  padding: EdgeInsets.all(10),
                  tabs: [
                    GButton(
                      icon: Icons.notifications_active_sharp,
                      
                    //  text: 'Notification',
                      onPressed: () {
                        Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ProfileScreen(),
                          fullscreenDialog: true));
                      },
                    ),
                  ],
                ),
              ),
            
          ],
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
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                        alignment: Alignment.bottomLeft,
                        height: size.height / 1.25,
                        width: size.width,
                        child: fetch()),
                  ],
                ),
              ),
        //floatingActionButton: buildNavigationButton(),
        floatingActionButton: isAdmin == true
            ? SpeedDial(
                animatedIcon: AnimatedIcons.menu_close,
                backgroundColor: Colors.green[700],
                overlayColor: Colors.indigo,
                overlayOpacity: 0.4,
                spacing: 12,
                openCloseDial: isDialOpen,
                spaceBetweenChildren: 12,
                children: [
                  SpeedDialChild(
                      child: const CircleAvatar(
                        backgroundImage:
                            AssetImage("assets/images/shutdown.png"),
                      ),
                      onTap: () async {
                        /*                PopupMenuButton(
                    icon: const Icon(Icons.person),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                          child: Row(
                        children: [
                          CircleAvatar(backgroundImage: AssetImage("assets/images/change.png"),),
                          Padding(
                            padding: EdgeInsets.only(left: 10.0),
                            child:
                                Text("Changer de Comp"),
                          )
                        ],
                      )),
                      PopupMenuItem(
                          child: Row(
                        children: [
                          Icon(
                            Icons.phone,
                            color: Colors.black,
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 10.0),
                            child: Text("Contact: ${data['contact']}"),
                          )
                        ],
                      )),
                     
                   
                    ],
                  );*/
                        try {
                          await _auth.signOut();
                          // ignore: use_build_context_synchronously
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                                fullscreenDialog: true,
                              ));
                        } catch (e) {
                          print("error");
                        }
                      },
                      label: 'Deconnexion',
                      labelStyle:
                          TextStyle(color: Colors.green[700], fontSize: 17)),
                  SpeedDialChild(
                      foregroundColor: Colors.white,
                      child: Icon(
                        Icons.message,
                        color: Colors.green[700],
                      ),
                      label: 'Message Commun',
                      onTap: () async {
                        if (isAdmin == false) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SendForAll(
                                  chatRoomId: contry,
                                ),
                                fullscreenDialog: true,
                              ));
                        } else {
                          Navigator.of(context).push(HeroDialogRoute(
                            builder: (context) {
                              return const CountryChoiceDialog();
                            },
                          ));
                        }
                      },
                      labelStyle:
                          TextStyle(color: Colors.green[700], fontSize: 17)),
                  SpeedDialChild(
                      onTap: () => addUser(),
                      child: const CircleAvatar(
                        backgroundImage: AssetImage("assets/images/user.png"),
                      ),
                      label: 'Ajouter un Utilisateur',
                      labelStyle:
                          TextStyle(color: Colors.green[700], fontSize: 17)),
                ],
              )
            : SpeedDial(
                animatedIcon: AnimatedIcons.menu_close,
                backgroundColor: Colors.green[700],
                overlayColor: Colors.indigo,
                overlayOpacity: 0.4,
                spacing: 12,
                openCloseDial: isDialOpen,
                spaceBetweenChildren: 12,
                children: [
                  SpeedDialChild(
                      child: const CircleAvatar(
                        backgroundImage:
                            AssetImage("assets/images/shutdown.png"),
                      ),
                      onTap: () async {
                        /*                PopupMenuButton(
                    icon: const Icon(Icons.person),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                          child: Row(
                        children: [
                          CircleAvatar(backgroundImage: AssetImage("assets/images/change.png"),),
                          Padding(
                            padding: EdgeInsets.only(left: 10.0),
                            child:
                                Text("Changer de Comp"),
                          )
                        ],
                      )),
                      PopupMenuItem(
                          child: Row(
                        children: [
                          Icon(
                            Icons.phone,
                            color: Colors.black,
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 10.0),
                            child: Text("Contact: ${data['contact']}"),
                          )
                        ],
                      )),
                     
                   
                    ],
                  );*/
                        try {
                          await _auth.signOut();
                          // ignore: use_build_context_synchronously
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                                fullscreenDialog: true,
                              ));
                        } catch (e) {
                          print("error");
                        }
                      },
                      label: 'Deconnexion',
                      labelStyle:
                          TextStyle(color: Colors.green[700], fontSize: 17)),
                  SpeedDialChild(
                      foregroundColor: Colors.white,
                      child: Icon(
                        Icons.message,
                        color: Colors.green[700],
                      ),
                      label: 'Message Commun',
                      onTap: () async {
                        if (isAdmin == false) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SendForAll(
                                  chatRoomId: contry,
                                ),
                                fullscreenDialog: true,
                              ));
                        } else {
                          Navigator.of(context).push(HeroDialogRoute(
                            builder: (context) {
                              return const CountryChoiceDialog();
                            },
                          ));
                        }
                      },
                      labelStyle:
                          TextStyle(color: Colors.green[700], fontSize: 17)),
                ],
              ),

        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        //bottomNavigationBar: buildBottomBar(),
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
                if (map['statut'] == 'user' || map['statut']=="admin") {
                  if (map['editeur'] == userId || map['statut']=="admin") {
                    return map != null
                        ? ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.green[700],
                              child: const Icon(Icons.account_box,
                                  color: Colors.white),
                            ),
                            title: Text(
                              "${map['nom']} (${map['statut']})",
                              style: const TextStyle(
                                color: Colors.green,
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                                "${map['pays']} (langue: ${map['langue']})"),
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
                                  String roomId = chatRoomId(userMap!['nom']);
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (_) => AdminScreen(
                                            userMap: userMap!,
                                            chatRoomId: roomId,
                                            token: map['token'],
                                          )));
                                }
                              });
                            },
                          )
                        : Container();
                  } else
                    return Container();
                } else if (isAdmin == true) {
                  if (map['nom'] == _auth.currentUser!.displayName)
                    return Container();
                  return map != null
                      ? ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.green[700],
                            child: const Icon(Icons.account_box,
                                color: Colors.white),
                          ),
                          title: Text(
                            "${map['nom']} (${map['statut']})",
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle:
                              Text("${map['pays']} (langue: ${map['langue']})"),
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
                                String roomId = chatRoomId(userMap!['nom']);
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (_) => AdminScreen(
                                          userMap: userMap!,
                                          chatRoomId: roomId,
                                          token: map['token'],
                                        )));
                              }
                            });
                          },
                        )
                      : Container();
                } else
                  return Container();
              });
        });
  }

  /* Widget fetch() {
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
                            "${map['nom']}",
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle:
                              Text("${map['pays']} (langue: ${map['langue']})"),
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
                                String roomId = chatRoomId(userMap!['nom']);
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (_) => AdminScreen(
                                          userMap: userMap!,
                                          chatRoomId: roomId,
                                          token: map['token'],
                                        )));
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
                            "${map['nom']} (${map['statut']})",
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle:
                              Text("${map['pays']} (langue: ${map['langue']})"),
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
                                String roomId = chatRoomId(userMap!['nom']);
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (_) => AdminScreen(
                                          userMap: userMap!,
                                          chatRoomId: roomId,
                                          token: map['token'],
                                        )));
                              }
                            });
                          },
                        )
                      : Container();
                } else
                  return Container();
              });
        });
  }*/
}

String _pays = 'Les pays';

class CountryChoiceDialog extends StatefulWidget {
  const CountryChoiceDialog({
    super.key,
  });

  @override
  State<CountryChoiceDialog> createState() => _CountryChoiceDialogState();
}

class _CountryChoiceDialogState extends State<CountryChoiceDialog> {
  String phoneNumber = '';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<String> _listPays = [];
  List<String> _listCountry = [];

  final Stream<QuerySnapshot> users = FirebaseFirestore.instance
      .collection('userData')
      .where("statut", isEqualTo: "user")
      .snapshots();
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
                //_listPays.add(map['pays']);
                if (_listCountry.contains(map['pays']))
                  return Container();
                else {
                  _listCountry.add(map["pays"]);
                  return ListTile(
                    title: Text(
                      map["pays"],
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
                          String roomId = map['pays'];
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => AdminScreen(
                                    userMap: map,
                                    chatRoomId: roomId,
                                    token: map['token'],
                                  )));
                        }
                      });
                    },
                  );
                }

                /* _listPays.forEach((element) {
                  if (_listCountry.contains(element)) {
                    //print(element);
                    _listCountry = _listCountry;
                  } else {
                  
                      _listCountry.add(element);
                    
                  }
                });*/
                //print(_listCountry);
                /*  _pays.forEach((pys) {
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green[700],
                      child: const Icon(Icons.flag, color: Colors.white),
                    ),
                    title: Text(
                      pys,
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: () => openwhatsapp(map['numero']),
                  );
                });
*/

                /*  ListView.builder(
                  itemCount: _listCountry.length,
                  prototypeItem: ListTile(
                    title: Text(_listCountry.first),
                  ),
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_listCountry[index]),
                    );
                  },
                );*/
              });
        });
  }

  /* Widget buildWidget() {
    if (_listCountry.isEmpty)
      return Container(
        child: Text("Rien"),
      );
    else {
      return ListView.builder(
        itemCount: _listCountry.length,
        prototypeItem: ListTile(
          title: Text(_listCountry.first),
        ),
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_listCountry[index]),
          );
        },
      );
    }
  }*/

  openwhatsapp(phone) async {
    var whatsapp = phone;
    var whatsappURl_android =
        "whatsapp://send?phone=" + whatsapp + "&text=hello";
    var whatappURL_ios = "https://wa.me/$whatsapp?text=${Uri.parse("hello")}";
    if (Platform.isIOS) {
      if (await canLaunchUrl(Uri.parse(whatappURL_ios))) {
        // ignore: deprecated_member_use
        await launch(whatappURL_ios, forceSafariVC: false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: new Text("whatsapp non pas installer")));
      }
    } else {
      // android , web
      if (await canLaunchUrl(Uri.parse(whatsappURl_android))) {
        // ignore: deprecated_member_use
        await launch(whatsappURl_android);
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: new Text("whatsapp non installé")));
      }
    }
  }

  @override
  void initState() {
    users;
    fetch();

    //buildWidget();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Hero(
          tag: _pays,
          createRectTween: (begin, end) {
            return CustomRectTween(begin: begin!, end: end!);
          },
          child: Material(
            color: Colors.white70,
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height / 5.25,
                      width: MediaQuery.of(context).size.width,
                      child: fetch(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    ;
  }
}

//for choice conexion

class ChangingAccount extends StatefulWidget {
  const ChangingAccount({
    super.key,
  });

  @override
  State<ChangingAccount> createState() => _ChangingAccountState();
}

class _ChangingAccountState extends State<ChangingAccount> {
  String phoneNumber = '';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<String> _listPays = [];
  List<String> _listCountry = [];
  Future<void> getUserInformation() async {
    await _firestore
        .collection('userData')
        .doc(_auth.currentUser!.uid)
        .get()
        .then((value) => {setState(() {})});
  }

  @override
  void initState() {
    //buildWidget();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Hero(
          tag: _pays,
          createRectTween: (begin, end) {
            return CustomRectTween(begin: begin!, end: end!);
          },
          child: Material(
            color: Colors.white70,
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height / 5.25,
                      width: MediaQuery.of(context).size.width,
                      child: Column(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
