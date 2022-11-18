import 'dart:io';

import 'package:agriconnect/pages/Sign_Registed/loginPage.dart';
import 'package:agriconnect/pages/about/custom_rect_tween.dart';
import 'package:agriconnect/pages/about/hero_dialod_route.dart';
import 'package:agriconnect/pages/user_profile/profileScreen.dart';
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
import 'package:url_launcher/url_launcher.dart';

import 'settings/drawer_menu_widget.dart';

class Home extends StatelessWidget {
  final VoidCallback openDrawer;
  final String pays;
  Home({super.key, required this.openDrawer, required this.pays});

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //String userEdit = "";
  // String phoneNumber = '';

  String formatTime(Duration duration) {
    String toDigits(int n) => n.toString().padLeft(2, '0');
    final hours = toDigits(duration.inHours);
    final minutes = toDigits(duration.inMinutes.remainder(60));
    final secondes = toDigits(duration.inSeconds.remainder(60));
    return [
      if (duration.inHours > 0) hours,
      minutes,
      secondes,
    ].join(':');
  }

  var isLargeScreen = false;
  ScrollController scrollController = ScrollController();

  Map<String, dynamic> data = {"contact": "", "pays": "", "langue": ""};
  final Stream<QuerySnapshot> users = FirebaseFirestore.instance
      .collection('userData')
      .where("statut", isEqualTo: "éditeur")
      .snapshots();

  final Stream<QuerySnapshot> docId =
      FirebaseFirestore.instance.collection('sending').snapshots();

  Widget messageType(
      Size size, Map<String, dynamic> map, BuildContext context) {
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

  Widget fetch() {
    if (_auth.currentUser!.displayName!.isNotEmpty) {
      return StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('sending')
            .doc(_auth.currentUser!.displayName)
            .collection('envoyers')
            .orderBy("codetime", descending: true)
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
            return Container();
          }
        },
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('sending')
          .doc(pays)
          .collection('envoyers')
          .orderBy("codetime", descending: true)
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
          return Container();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      backgroundColor: Colors.white,
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
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          controller: scrollController,
          child: Column(
            children: [
              Container(
                  height: MediaQuery.of(context).size.height / 1.25,
                  width: MediaQuery.of(context).size.width,
                  child: fetch()

                  /* StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('sending')
                      .doc(_auth.currentUser!.displayName)
                      .collection('envoyers')
                      .orderBy("codetime", descending: true)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.data != null) {
                      return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          Map<String, dynamic> map = snapshot.data!.docs[index]
                              .data() as Map<String, dynamic>;

                          return messageType(
                              MediaQuery.of(context).size, map, context);
                        },
                      );
                    } else {
                      return Container();
                    }
                  },
                ),
              */
                  ),
            ],
          )),
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

//les autres class

const String _heroAddTodo = 'About us';
const String _heroNum = 'Calling';

/// {@template add_todo_popup_card}
/// Popup card to add a new [Todo]. Should be used in conjuction with
/// [HeroDialogRoute] to achieve the popup effect.
///
/// Uses a [Hero] with tag [_heroAddTodo].
/// {@endtemplate}
class SignalerDialogForm extends StatelessWidget {
  SignalerDialogForm({super.key});

  Future launchEmail({
    required String toEmail,
    required String subject,
    required String message,
  }) async {
    final url =
        'mailto:$toEmail?subject=${Uri.encodeFull(subject)}&body=${Uri.encodeFull(message)}';
    if (await canLaunchUrl(Uri.parse(url))) {
      // ignore: deprecated_member_use
      await launch(url);
    }
  }

  Widget buildTextField(
          {required String title,
          required TextEditingController controller,
          required TextInputType inputType,
          int maxLines = 1}) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 6,
          ),
          TextField(
            keyboardType: inputType,
            maxLines: maxLines,
            controller: controller,
            decoration: InputDecoration(
                border: OutlineInputBorder(borderSide: BorderSide(width: 1))),
          )
        ],
      );
  var msgCtrl = TextEditingController();
  void _showDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return const AlertDialog(
            title:  Text("Signaler"),
            content:  Text("Message bien envoyé"),
           
          );
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
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Hero(
            tag: _heroAddTodo,
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
                      buildTextField(
                        maxLines: 5,
                        title: 'Message',
                        controller: msgCtrl,
                        inputType: TextInputType.text,
                      ),
                      const Divider(
                        color: Colors.white,
                        thickness: 0.2,
                      ),
                      TextButton(
                          onPressed: () {
                            launchEmail(
                                toEmail: "agriconnectafrica@gmail.com",
                                subject: "Agriconnect_Signaler",
                                message: msgCtrl.text);
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const ProfileScreen(),
                            ));
                          },
                          child: Text('Envoyer'))
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CallingDialog extends StatefulWidget {
  const CallingDialog({
    super.key,
  });

  @override
  State<CallingDialog> createState() => _CallingDialogState();
}

class _CallingDialogState extends State<CallingDialog> {
  String phoneNumber = '';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String userCountry = "";
  String userEdit = '';
  // Map<String, dynamic> data = {"contact": "", "pays": "", "langue": ""};
  final Stream<QuerySnapshot> users = FirebaseFirestore.instance
      .collection('userData')
      .where("statut", isEqualTo: "éditeur")
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
                if ((map['identifiant'] == userEdit)) {
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
                          trailing: CircleAvatar(
                              backgroundImage:
                                  AssetImage("assets/images/call.png")),
                          onTap: () => openCalling(map['numero']),
                        )
                      : Container();
                } else
                  return Container();
              });
        });
  }

  openCalling(phone) async {
    final call = 'tel:$phone';
    if (await canLaunchUrl(Uri.parse(call))) {
      // ignore: deprecated_member_use
      await launch(call);
    }
  }

  Future<void> getUserInformation() async {
    await _firestore
        .collection('userData')
        .doc(_auth.currentUser!.uid)
        .get()
        .then((value) => {
              setState(() {
                userEdit = value['editeur'];
              })
            });
  }

  @override
  void initState() {
    getUserInformation();
    fetch();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Hero(
          tag: _heroNum,
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

class WhatsappDialog extends StatefulWidget {
  const WhatsappDialog({
    super.key,
  });

  @override
  State<WhatsappDialog> createState() => _WhatsappDialogState();
}

class _WhatsappDialogState extends State<WhatsappDialog> {
  String phoneNumber = '';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String userEdit = "";
  String userCountry = "";
  Map<String, dynamic> data = {"contact": "", "pays": "", "langue": ""};
  final Stream<QuerySnapshot> users = FirebaseFirestore.instance
      .collection('userData')
      .where("statut", isEqualTo: "éditeur")
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
                if ((map['identifiant'] == userEdit)) {
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
                          trailing: CircleAvatar(
                              backgroundImage:
                                  AssetImage("assets/images/call.png")),
                          onTap: () => openwhatsapp(map['numero']),
                        )
                      : Container();
                } else
                  return Container();
              });
        });
  }

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

  Future<void> getUserInformation() async {
    await _firestore
        .collection('userData')
        .doc(_auth.currentUser!.uid)
        .get()
        .then((value) => {
              setState(() {
                userEdit = value['editeur'];
              })
            });
  }

  @override
  void initState() {
    getUserInformation();
    fetch();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Hero(
          tag: _heroNum,
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
