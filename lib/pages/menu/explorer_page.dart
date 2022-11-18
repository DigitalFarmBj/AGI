import 'dart:ui';

import 'package:agriconnect/pages/Sign_Registed/loginPage.dart';
import 'package:agriconnect/pages/about/hero_dialod_route.dart';
import 'package:agriconnect/util/affichage_Methode/TextPlug/buildMessage.dart';
import 'package:agriconnect/util/affichage_Methode/TextPlug/textCustom.dart';
import 'package:agriconnect/util/affichage_Methode/audioPlayer.dart';
import 'package:agriconnect/util/affichage_Methode/showImage.dart';
import 'package:agriconnect/util/affichage_Methode/videos_plug/videoPlayer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:readmore/readmore.dart';

import 'home.dart';
import 'settings/drawer_menu_widget.dart';

class ExplorerPage extends StatelessWidget {
  final VoidCallback openDrawer;
  final String categ;
  final String pays;

  ExplorerPage(
      {super.key,
      required this.openDrawer,
      required this.categ,
      required this.pays});
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Stream<QuerySnapshot> users = FirebaseFirestore.instance
      .collection('userData')
      .orderBy("codetime", descending: true)
      .snapshots();

  Widget fetch() {
    if (_auth.currentUser!.displayName!.isNotEmpty) {
      return StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('sending')
            .doc(_auth.currentUser!.displayName)
            .collection('envoyers')
            .where("categorie", isEqualTo: categ)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.data != null) {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> map =
                    snapshot.data!.docs[index].data() as Map<String, dynamic>;

                return messageType(MediaQuery.of(context).size, map, context);
              },
            );
          } else {
            return Container(
                padding: EdgeInsets.only(top: 150),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    Center(
                      child: Text(
                        "Aucune donné trouvé",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ));
          }
        },
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('sending')
          .doc(pays)
          .collection('envoyers')
          .where("categorie", isEqualTo: categ)
          // .orderBy("codetime", descending: true).limit(1)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.data != null) {
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> map =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;

              return messageType(MediaQuery.of(context).size, map, context);
            },
          );
        } else {
          return Container(
              padding: EdgeInsets.only(top: 150),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  Center(
                    child: Text(
                      "Aucune donné trouvé",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ));
        }
      },
    );
  }

  Widget messageType(
      Size size, Map<String, dynamic> map, BuildContext context) 
      {
    if (map['type'] == 'text') {
      Container(
        height: size.height / 4.5,
        width: size.width,
        alignment: map['sendby'] == _auth.currentUser!.displayName
            ? Alignment.center
            : Alignment.center,
        child: Container(
          width: size.width,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 50),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9),
            color: const Color.fromARGB(38, 33, 149, 243),
          ),
        ),
      );
    }
    return map['type'] == 'text'
        ? BubbleMessage(
            painter: BubblePainter(),
            child: Container(
              decoration: BoxDecoration(
                border:
                    Border.all(color: const Color.fromARGB(183, 43, 97, 16)),
                borderRadius: BorderRadius.circular(9),
              ),
              constraints:
                  const BoxConstraints(maxWidth: 250.0, minWidth: 50.0),
              padding:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 6.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      map['date'],
                      style:
                          const TextStyle(fontSize: 12, fontFamily: 'POPPINS'),
                    ),
                  ),
                  const SizedBox(
                    height: 6,
                  ),
                  buildText(map['message']),
                  Container(
                    alignment: Alignment.topRight,
                    child: Text(
                      map['time'],
                      style: const TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                ],
              ),
            ),
          )
        : (map['type'] == 'audio')
            ? BubbleMessage(
                painter: BubblePainter(),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: const Color.fromARGB(183, 43, 97, 16)),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  constraints:
                      const BoxConstraints(maxWidth: 250, minWidth: 50),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 15.0, vertical: 6.0),
                  child: Column(
                    children: [
                      Container(
                        alignment: Alignment.bottomLeft,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                map['date'],
                                style: const TextStyle(
                                    fontSize: 12, fontFamily: 'POPPINS'),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                alignment: Alignment.topRight,
                                child: Text(
                                  map['time'],
                                  style: const TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      AudioShowing(audioUrl: map['message'], code: map['code']),
                      Container(
                        alignment: Alignment.topRight,
                        child: buildText(map['desc']),
                      ),
                      Row(
                        children: [
                          CircleAvatar(
                            child: Image.asset("assets/images/vue.png",
                                height: 20),
                            backgroundColor: Colors.white,
                          ),
                          Expanded(child: Text("vue"))
                        ],
                      )
                    ],
                  ),
                ),
              )
            : (map['type'] == 'img')
                ? BubbleMessage(
                    painter: BubblePainter(),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: const Color.fromARGB(183, 43, 97, 16)),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      constraints:
                          const BoxConstraints(maxWidth: 250.0, minWidth: 50.0),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15.0, vertical: 6.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  map['date'],
                                  style: const TextStyle(
                                      fontSize: 12, fontFamily: 'POPPINS'),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  alignment: Alignment.topRight,
                                  child: Text(
                                    map['time'],
                                    style: const TextStyle(
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          InkWell(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ShowImage(
                                  imageUrl: map['message'],
                                ),
                              ),
                            ),
                            child: Container(
                              height: size.height / 4.5,
                              width: size.width,
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: const Color.fromARGB(0, 2, 183, 2)),
                                borderRadius: BorderRadius.circular(9),
                                color: const Color.fromARGB(0, 2, 183, 2),
                              ),
                              alignment: map['message'] != ""
                                  ? null
                                  : Alignment.center,
                              child: map['message'] != ""
                                  ? Image.network(
                                      map['message'],
                                      fit: BoxFit.cover,
                                    )
                                  : const CircularProgressIndicator(),
                            ),
                          ),
                          Container(
                            alignment: Alignment.topRight,
                            child: buildText(map['desc']),
                          ),
                          Row(
                            children: [
                              CircleAvatar(
                                child: Image.asset("assets/images/vue.png",
                                    height: 20),
                                backgroundColor: Colors.white,
                              ),
                              Expanded(child: Text("vue"))
                            ],
                          )
                        ],
                      ),
                    ),
                  )
                : (map['type'] == 'video')
                    ? BubbleMessage(
                        painter: BubblePainter(),
                        child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: const Color.fromARGB(183, 43, 97, 16)),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            constraints: const BoxConstraints(
                                maxWidth: 250.0, minWidth: 50.0),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15.0, vertical: 6.0),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        map['date'],
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontFamily: 'POPPINS'),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        alignment: Alignment.topRight,
                                        child: Text(
                                          map['time'],
                                          style: const TextStyle(
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                InkWell(
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            ShowVideo(vidUrl: map['message'])),
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                        height: size.height / 4.5,
                                        width: size.width,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: const Color.fromARGB(
                                                  0, 2, 183, 2)),
                                          borderRadius:
                                              BorderRadius.circular(9),
                                          color: const Color.fromARGB(
                                              0, 2, 183, 2),
                                        ),
                                        alignment: map['message'] != ""
                                            ? null
                                            : Alignment.center,
                                        child: map['message'] != ""
                                            ? Image.network(
                                                map['thumbnail'],
                                                fit: BoxFit.cover,
                                              )
                                            : const CircularProgressIndicator(),
                                      ),
                                      const CircleAvatar(
                                        radius: 30,
                                        backgroundColor:
                                            Color.fromARGB(255, 105, 153, 27),
                                        child: Icon(
                                          Icons.play_arrow,
                                          size: 40,
                                          color: Colors.white,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.topRight,
                                  child: buildText(map['desc']),
                                ),
                                Row(
                                  children: [
                                    CircleAvatar(
                                      child: Image.asset(
                                          "assets/images/vue.png",
                                          height: 20),
                                      backgroundColor: Colors.white,
                                    ),
                                    Expanded(child: Text("vue"))
                                  ],
                                )
                              ],
                            )

                            //     : const CircularProgressIndicator(),

                            ),
                      )
                    : SpinKitCircle(
                        size: 140,
                        itemBuilder: (context, index) {
                          final colors = [
                            Colors.white,
                            Colors.green,
                            Colors.red
                          ];
                          final color = colors[index % colors.length];

                          return DecoratedBox(
                              decoration: BoxDecoration(
                                  color: color, shape: BoxShape.circle));
                        },
                      );
  }

  Widget buildText(String txt) {
    var styleButton = const TextStyle(
        fontSize: 10,
        color: Color.fromARGB(183, 43, 97, 16),
        fontWeight: FontWeight.bold);
    return ReadMoreText(
      txt,
      trimLines: 2,
      trimMode: TrimMode.Line,
      style: const TextStyle(fontSize: 14),
      trimCollapsedText: 'Voir Plus',
      trimExpandedText: 'Voir moins',
      lessStyle: styleButton,
      moreStyle: styleButton,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [Colors.green, Colors.red],
                  begin: Alignment.bottomRight,
                  end: Alignment.topLeft)),
        ),
        elevation: 20,
        title: Text("${_auth.currentUser!.displayName}"),
        actions: [
          IconButton(
              onPressed: () async {
                FirebaseAuth _auth = FirebaseAuth.instance;
                try {
                  await _auth.signOut();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginScreen(),
                        fullscreenDialog: true,
                      ));
                } catch (e) {
                  print("error");
                }
              },
              icon: const Icon(Icons.logout)),
        ],
        backgroundColor: Colors.transparent,
        leading: DrawerMenuWidget(onClicked: openDrawer),
      ),
      body: SingleChildScrollView(
        child: Container(
            height: MediaQuery.of(context).size.height / 1.25,
            width: MediaQuery.of(context).size.width,
            child: fetch()

            /*   StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('sending')
                .doc(_auth.currentUser!.displayName)
                .collection('envoyers')
                .orderBy("codetime", descending: true)
                .where("categorie", isEqualTo: categ)
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.data != null) {
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> map = snapshot.data!.docs[index].data()
                        as Map<String, dynamic>;

                    return messageType(
                        MediaQuery.of(context).size, map, context);
                  },
                );
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    Center(
                      child: Text(
                        "Aucune donné trouvé",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                );
              }
            },
          ),
       */
            ),
      ),
      bottomNavigationBar: Container(
        height: 65,
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.green, Colors.red],
                begin: Alignment.bottomRight,
                end: Alignment.topLeft)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 7),
          child: GNav(
            color: Colors.white,
            activeColor: Colors.white,
            gap: 8,
            tabBackgroundColor: Colors.green,
            padding: EdgeInsets.all(16),
            tabs: [
              GButton(
                icon: Icons.notifications_active_sharp,
                //text: 'Notification',
                onPressed: () {},
              ),
              GButton(
                icon: Icons.phone,
                text: 'Appel',
                onPressed: () {
                  //openCalling();
                  Navigator.of(context).push(HeroDialogRoute(
                    builder: (context) {
                      return const CallingDialog();
                    },
                  ));
                },
              ),
              GButton(
                icon: Icons.whatsapp,
                text: 'Message Whatsapp',
                onPressed: () {
                  Navigator.of(context).push(HeroDialogRoute(
                    builder: (context) {
                      return const WhatsappDialog();
                    },
                  ));
                },
              ),
            ],
          ),
        ),
      ));
}
/*


import 'package:agriconnect/util/affichage_Methode/TextPlug/buildMessage.dart';
import 'package:agriconnect/util/affichage_Methode/TextPlug/textCustom.dart';
import 'package:agriconnect/util/affichage_Methode/audioPlayer.dart';
import 'package:agriconnect/util/affichage_Methode/showImage.dart';
import 'package:agriconnect/util/affichage_Methode/videos_plug/videoPlayer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:readmore/readmore.dart';

import 'settings/drawer_menu_widget.dart';

class ExplorerPage extends StatefulWidget {
  final VoidCallback openDrawer;
  final String categ;
  const ExplorerPage({super.key, required this.openDrawer, required this.categ});

  @override
  State<ExplorerPage> createState() => _ExplorerPageState();
}

class _ExplorerPageState extends State<ExplorerPage> {
   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;


 
  VoidCallback opDraw(){
    return widget.openDrawer;
  }
  @override
  void initState() {
    opDraw();
    super.initState();
  }
  @override
   Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(backgroundColor: Colors.red,
    leading: DrawerMenuWidget(onClicked: opDraw),
    title: Text('Explorer page'),
    ),
    body: 
  );
}
*/