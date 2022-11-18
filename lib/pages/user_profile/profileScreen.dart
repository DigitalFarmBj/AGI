//import 'dart:html';


import 'package:agriconnect/pages/menu/explorer_page.dart';
import 'package:agriconnect/pages/menu/home.dart';
import 'package:agriconnect/pages/menu/settings/drawerWidget.dart';
import 'package:agriconnect/pages/menu/settings/drawer_item.dart';
import 'package:agriconnect/pages/menu/settings/drawer_items.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<ListResult> futureFiles;

  Map<int, double> downloadProgress = {};

  final GlobalKey<ScaffoldState> _sb = GlobalKey<ScaffoldState>();

  final String logo = 'assets/images/agri2.png';
  final _auth = FirebaseAuth.instance;
  late double xOffset;
  late double yOffset;
  late double scaleFactor;
  bool isDragging = false;
  late bool isDrawerOpen;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  DrawerItem item = DrawerItems.tous;

  var country = "";

  Future<String> getUserCountry() async {
    await _firestore
        .collection('userData')
        .doc(_auth.currentUser!.uid)
        .get()
        .then((value) => {
              setState(() {
                country = value['pays'];
              }),
            });
    return country;
  }

  void openDrawer() => setState(() {
        xOffset = 230;
        yOffset = 150;
        scaleFactor = 0.6;
        isDrawerOpen = true;
      });
  void closeDrawer() => setState(() {
        xOffset = 0;
        yOffset = 0;
        scaleFactor = 1;
        isDrawerOpen = false;
      });
  @override
  void initState() {
    super.initState();
    getUserCountry();
    closeDrawer();
  }

  @override
  Widget build(BuildContext context) {
    /*   Future downloadFile(int index, Reference ref) async {
      final url = await ref.getDownloadURL();
      final tmpDir = await getTemporaryDirectory();
      final path = '${tmpDir.path}/${ref.name}';
      await Dio().download(url, path, onReceiveProgress: (received, total) {
        double progress = received / total;
        setState(() {
          downloadProgress[index] = progress;
        });
      });
      if (url.contains('.mp3')) {
        await GallerySaver.saveVideo(path, toDcim: true);
      } else if (url.contains('jpg')) {
        await GallerySaver.saveImage(path, toDcim: true);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Downloaded ${ref.name}')),
      );
    }
*/
    return Container(
      decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [Colors.green, Colors.red],
                  begin: Alignment.bottomRight,
                  end: Alignment.topLeft)),
      child: Scaffold(
        /* appBar: AppBar(
          centerTitle: true,
          backgroundColor: const Color(0xB758F10B),
        ),*/
        //drawer: MenuDrawer(),
        /*  Container(
            width: 230,
            color: Colors.cyan,
            child: Drawer(
              child: Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: <Widget>[
                    const SizedBox(
                      height: 100,
                      child: DrawerHeader(
                        decoration: BoxDecoration(
                          color: Color.fromARGB(183, 94, 171, 56),
                        ),
                        child: Text(
                          'Menu',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontFamily: 'cambria',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        padding: EdgeInsets.zero,
                        margin: EdgeInsets.zero,
                      ),
                    ),
                    SizedBox(
                      height: 60,
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.asset(
                            "assets/images/rice.jpg",
                            height: 50,
                            width: 50,
                          ),
                        ),
                        title: const Text('Riz',
                            style: TextStyle(color: Color(0xB758F10B))),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    SizedBox(
                      height: 60,
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.asset(
                            "assets/images/ana.jpg",
                            height: 50,
                            width: 50,
                          ),
                        ),
                        title: const Text('Ananas',
                            style: TextStyle(color: Color(0xB758F10B))),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    SizedBox(
                      height: 60,
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.asset(
                            "assets/images/soja.jpg",
                            height: 50,
                            width: 50,
                          ),
                        ),
                        title: const Text('Soja',
                            style: TextStyle(color: Color(0xB758F10B))),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    SizedBox(
                      height: 60,
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.asset(
                            "assets/images/ma.jpg",
                            height: 50,
                            width: 50,
                          ),
                        ),
                        title: const Text('Maïs',
                            style: TextStyle(color: Color(0xB758F10B))),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    SizedBox(
                      height: 60,
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.asset(
                            "assets/images/marai.jpg",
                            height: 50,
                            width: 50,
                          ),
                        ),
                        title: const Text('Maraichage',
                            style: TextStyle(color: Color(0xB758F10B))),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    SizedBox(
                      height: 60,
                      child: ListTile(
                        leading: const Icon(
                          Icons.cloudy_snowing,
                          color: Color.fromARGB(183, 94, 171, 56),
                          size: 40,
                        ),
                        title: const Text('Climat',
                            style: TextStyle(color: Color(0xB758F10B))),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    SizedBox(
                      height: 60,
                      child: ListTile(
                        leading: const Icon(
                          Icons.add,
                          color: Color.fromARGB(183, 94, 171, 56),
                          size: 40,
                        ),
                        title: const Text('Tout afficher',
                            style: TextStyle(color: Color(0xB758F10B))),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    const Divider(
                      height: 3,
                      thickness: 3,
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    const VerticalDivider(
                      width: 3,
                      thickness: 3,
                    ),
                    SizedBox(
                      height: 40,
                      child: ListTile(
                        leading: const Icon(
                          Icons.favorite,
                          color: Color.fromARGB(183, 94, 171, 56),
                          size: 30,
                        ),
                        title: const Text('A propos',
                            style: TextStyle(color: Color(0xB758F10B))),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    SizedBox(
                      height: 45,
                      child: ListTile(
                        leading: const Icon(
                          Icons.message,
                          color: Color.fromARGB(183, 94, 171, 56),
                          size: 30,
                        ),
                        title: const Text('Contacts',
                            style: TextStyle(color: Color(0xB758F10B))),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    SizedBox(
                      height: 45,
                      child: ListTile(
                        leading: const Icon(
                          Icons.person,
                          size: 30,
                          color: Color.fromARGB(183, 94, 171, 56),
                        ),
                        title: const Text('Confidentialité',
                            style: TextStyle(color: Color(0xB758F10B))),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          */
//color.fromRGBO(21,30,61,1)
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            
           Padding(
             padding: const EdgeInsets.only(top: 50),
             child: buildDrawer(),
           ),
             
            buildPage(),
          ],
        ),
      ),
    );
  }

  Widget buildDrawer() => SafeArea(child: DrawerWidget(
        onSelectedItem: (item) {
          setState(() => this.item = item);
          closeDrawer();
        },
      ));
  Widget buildPage() {
    return WillPopScope(
      onWillPop: () async {
        if (isDrawerOpen) {
          closeDrawer();
          return false;
        } else {
          return true;
        }
      },
      child: GestureDetector(
        onTap: closeDrawer,
        onHorizontalDragStart: (details) => isDragging = true,
        onHorizontalDragUpdate: (details) {
          if (!isDragging) return;
          const delta = 1;
          if (details.delta.dx > delta) {
            openDrawer();
          } else if (details.delta.dx < -delta) {
            closeDrawer();
          }
          isDragging = false;
        },
        child: AnimatedContainer(
            duration: Duration(milliseconds: 250),
            transform: Matrix4.translationValues(xOffset, yOffset, 0)
              ..scale(scaleFactor),
            child: AbsorbPointer(
              absorbing: isDrawerOpen,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(isDrawerOpen ? 20 : 0),
                child: Container(
                  color: isDrawerOpen
                      ? Colors.white12
                      : Color.fromRGBO(21, 30, 61, 1),
                  child: getDrawerPage(),
                ),
              ),
            )),
      ),
    );
  }

  Widget getDrawerPage() {
    switch (item) {
      case DrawerItems.climat:
        print(item.title);
        return ExplorerPage(
          openDrawer: openDrawer,
          categ: item.title,
          pays: country,
        );
      case DrawerItems.prVeg:
        print(item.title);
        return ExplorerPage(
          openDrawer: openDrawer,
          categ: item.title,
          pays: country,
        );
      case DrawerItems.prAnim:
        print(item.title);
        return ExplorerPage(
          openDrawer: openDrawer,
          categ: item.title,
          pays: country,
        );
      
      case DrawerItems.peche:
        print(item.title);
        return ExplorerPage(
          openDrawer: openDrawer,
          categ: item.title,
          pays: country,
        );
      case DrawerItems.trAgro:
       print(item.title);
        return ExplorerPage(
          openDrawer: openDrawer,
          categ: item.title,
          pays: country,
        );
      case DrawerItems.intrant:
        print(item.title);
        return ExplorerPage(
          openDrawer: openDrawer,
          categ: item.title,
          pays: country,
        );
     
      case DrawerItems.other:
        print(item.title);
        return ExplorerPage(
          openDrawer: openDrawer,
          categ: item.title,
          pays: country,
        );
      case DrawerItems.tous:
        print(item.title);
        return Home(
          openDrawer: openDrawer,
          pays: country,
        );
      case DrawerItems.signaler:
        return SignalerDialogForm();

      default:
        return Home(
          openDrawer: openDrawer,
          pays: country,
        );
    }
  }
}
