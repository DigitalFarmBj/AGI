import 'dart:convert';
import 'dart:io';

import 'package:agriconnect/pages/Sign_Registed/loginPage.dart';
import 'package:agriconnect/pages/about/hero_dialod_route.dart';
import 'package:agriconnect/pages/menu/home.dart';
import 'package:agriconnect/util/affichage_Methode/TextPlug/buildMessage.dart';
import 'package:agriconnect/util/affichage_Methode/TextPlug/textCustom.dart';
import 'package:agriconnect/util/affichage_Methode/audioPlayer.dart';
import 'package:agriconnect/util/affichage_Methode/showImage.dart';
import 'package:agriconnect/util/affichage_Methode/videos_plug/videoPlayer.dart';
import 'package:agriconnect/util/pushNotification/pushNotification.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import 'package:readmore/readmore.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:url_launcher/url_launcher.dart';

Future<void> _firebaseMessaging(RemoteMessage message) async {
  print("Manipulation des messages en arrière plan ${message.messageId}");
}

class ViewMessages extends StatefulWidget {
  const ViewMessages({Key? key}) : super(key: key);

  @override
  State<ViewMessages> createState() => _ViewMessagesState();
}

class _ViewMessagesState extends State<ViewMessages>
    with WidgetsBindingObserver {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  PushNotification? _notificationInfo;
  late AndroidNotificationChannel channel;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  String userEdit = "";
  String phoneNumber = '';
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
                  setState(() {
                    // phoneNumber = map['numero'];
                  });
                  return map != null
                      ? ListTile(
                          /*leading: CircleAvatar(
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
                        */
                          )
                      : Container();
                } else
                  return Container();
              });
        });
  }

  /*Future<void> getUserInformation() async {
    await _firestore
        .collection('userData')
        .doc(_auth.currentUser!.uid)
        .get()
        .then((value) => {
              setState(() {
                data['contact'] = value['numero'];
                data['pays'] = value['pays'];
                data['langue'] = value['langue'];
                userEdit = value['editeur'];
              })
            });
  }*/

  @override
  void initState() {
    fetch();

    super.initState();
  }

  /* void _showDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("A propos"),
            content: const Text(
                "Cette application est développée par HEDI ONG et DIGITAL FARM ."),
            actions: <Widget>[
              TextButton(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }
*/
  /* void _showDialog1(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Nous Contacter"),
            content: const Text("Appelez nous ou écrivez nous via Whatsapp  "),
            buttonPadding: const EdgeInsets.only(bottom: 5),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      onPressed: () {
                        openCalling();
                      },
                      icon: const Icon(Icons.call),
                    ),
                  ),
                  Container(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      onPressed: () {
                        openwhatsapp();
                      },
                      icon: const Icon(Icons.whatsapp_outlined),
                    ),
                  ),
                ],
              )
            ],
          );
        });
  }
*/
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

  /* openwhatsapp() async {
    var whatsapp = phoneNumber;
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
*/
  /* openCalling() async {
    final call = 'tel:$phoneNumber';
    if (await canLaunchUrl(Uri.parse(call))) {
      // ignore: deprecated_member_use
      await launch(call);
    }
  }
*/
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

  final ScrollController _controller = ScrollController();
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
            //drawer: MenuDrawer(),
            appBar: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: const Color.fromARGB(183, 43, 97, 16),

              /* PopupMenuButton(
                icon: const Icon(Icons.menu),
                itemBuilder: (context) => [
                  PopupMenuItem(
                      child: Row(
                    children: const [
                      CircleAvatar(
              backgroundColor: Colors.white,
              radius: 20,
              backgroundImage: AssetImage("assets/images/climat.png"),),
                      Padding(
                        padding: EdgeInsets.only(left: 10.0),
                        child: Text("Climat"),
                      )
                    ],
                  )),
                   PopupMenuItem(
                      child: Row(
                    children: const [
                      CircleAvatar(
              backgroundColor: Colors.white,
              radius: 20,
              backgroundImage: AssetImage("assets/images/rice.jpg"),),
                      Padding(
                        padding: EdgeInsets.only(left: 10.0),
                        child: Text("Riz"),
                      )
                    ],
                  )),


                 PopupMenuItem(
                      child: Row(
                    children: const [
                      CircleAvatar(
              backgroundColor: Colors.white,
              radius: 20,
              backgroundImage: AssetImage("assets/images/ma.jpg"),),
                      Padding(
                        padding: EdgeInsets.only(left: 10.0),
                        child: Text("Maïs"),
                      )
                    ],
                  )),
                   PopupMenuItem(
                      child: Row(
                    children: const [
                      CircleAvatar(
              backgroundColor: Colors.white,
              radius: 20,
              backgroundImage: AssetImage("assets/images/soja.jpg"),),
                      Padding(
                        padding: EdgeInsets.only(left: 10.0),
                        child: Text("Soja"),
                      )
                    ],
                  )),




                   PopupMenuItem(
                      child: Row(
                    children: const [
                      CircleAvatar(
              backgroundColor: Colors.white,
              radius: 20,
              backgroundImage: AssetImage("assets/images/ana.jpg"),),
                      Padding(
                        padding: EdgeInsets.only(left: 10.0),
                        child: Text("Annanas"),
                      )
                    ],
                  )),
                   PopupMenuItem(
                      child: Row(
                    children: const [
                      CircleAvatar(
              backgroundColor: Colors.white,
              radius: 20,
              backgroundImage: AssetImage("assets/images/marai.jpg"),),
                      Padding(
                        padding: EdgeInsets.only(left: 10.0),
                        child: Text("Mairaichage"),
                      )
                    ],
                  )),


                 PopupMenuItem(
                      child: Row(
                    children: const [
                      CircleAvatar(
              backgroundColor: Colors.white,
              radius: 20,
              backgroundImage: AssetImage("assets/images/anarcade.png"),),
                      Padding(
                        padding: EdgeInsets.only(left: 10.0),
                        child: Text("Anarcade"),
                      )
                    ],
                  )),
                   PopupMenuItem(
                      child: Row(
                    children: const [
                      CircleAvatar(
              backgroundColor: Colors.white,
              radius: 20,
              backgroundImage: AssetImage("assets/images/cacao.png"),),
                      Padding(
                        padding: EdgeInsets.only(left: 10.0),
                        child: Text("Cacao"),
                      )
                    ],
                  )),
                  
                ],
              ),
             */
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
            ),
            body: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                controller: scrollController,
                child: Column(
                  children: [
                    // Menu(),
                    Container(
                      height: MediaQuery.of(context).size.height / 1.25,
                      width: MediaQuery.of(context).size.width,
                      child: StreamBuilder<QuerySnapshot>(
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
                                Map<String, dynamic> map =
                                    snapshot.data!.docs[index].data()
                                        as Map<String, dynamic>;

                                return messageType(
                                    MediaQuery.of(context).size, map, context);
                              },
                            );
                          } else {
                            return Container();
                          }
                        },
                      ),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 15.0, vertical: 7),
                child: GNav(
                  color: Colors.white,
                  activeColor: Colors.white,
                  gap: 8,
                  tabBackgroundColor: Colors.green,
                  padding: EdgeInsets.all(16),
                  tabs: [
                    GButton(
                      icon: Icons.settings,
                      text: 'A PROPOS',
                      onPressed: () {
                        Navigator.of(context).push(HeroDialogRoute(
                          builder: (context) {
                            return SignalerDialogForm();
                          },
                        ));
                      },
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
            )),
      );

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

  Widget buildPaysage() {
    final size = MediaQuery.of(context).size;
    return Text('data');
  }
}

/// Tag-value used for the add todo popup button.
