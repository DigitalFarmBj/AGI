import 'dart:io';
import 'package:agriconnect/models/infoTreatment.dart';
import 'package:agriconnect/pages/about/custom_rect_tween.dart';
import 'package:agriconnect/pages/about/hero_dialod_route.dart';

import 'package:agriconnect/service/auth.dart';
import 'package:agriconnect/util/font/background.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:get/get.dart';

import 'package:url_launcher/url_launcher.dart';

import 'signIn.dart';

class LogHome extends StatefulWidget {
  const LogHome({Key? key}) : super(key: key);

  @override
  State<LogHome> createState() => _LogHomeState();
}

class _LogHomeState extends State<LogHome> {
  //initialisation
  Future<FirebaseApp> _initialisefirebase() async {
    FirebaseApp firebaseApp = await Firebase.initializeApp();
    return firebaseApp;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _initialisefirebase(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return const LoginScreen();
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String domain = "@agriconnect.com";
  String phoneNumber = '+22994772347';
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  Map<String, dynamic> map = {};
  List<dynamic> list = [];
  bool _laoding = true;
  openwhatsapp() async {
    var whatsapp = phoneNumber;
    var whatsappURl_android =
        "whatsapp://send?phone=" + whatsapp + "&text=hello";
    var whatappURL_ios = "https://wa.me/$whatsapp?text=${Uri.parse("hello")}";
    if (Platform.isIOS) {
      // for iOS phone only
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

  openCalling() async {
    final call = 'tel:$phoneNumber';
    if (await canLaunchUrl(Uri.parse(call))) {
      // ignore: deprecated_member_use
      await launch(call);
    }
  }

  void _showDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Inscription"),
            content: const Text("Contactez nous pour vous inscrire"),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      onPressed: () {
                        Navigator.of(context).push(HeroDialogRoute(
                          builder: (context) {
                            return EmailDialogForm();
                          },
                        ));
                      },
                      icon: const Icon(Icons.email),
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

  void showSnackBar(String text) {
    final snackBar = SnackBar(
      content: Text(
        text,
        style: TextStyle(fontSize: 20),
      ),
      backgroundColor: Colors.green,
    );
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  AuthService service = AuthService();
  final _usernameController = TextEditingController();
  final _passwordControler = TextEditingController();
  Widget buildPortrail() {
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        verticalDirection: VerticalDirection.down,
        children: <Widget>[
          Background(
            height: 470.0,
            child: Column(
              children: [
                Expanded(
                  flex: 6,
                  child: Row(
                    children: [
                      //logo

                      Expanded(
                          flex: 6,
                          child: FadeInDown(
                            delay: Duration(milliseconds: 2500),
                            child: Padding(
                                padding:
                                    const EdgeInsets.only(top: 15.0, right: 10),
                                child: Image.asset(
                                  'assets/images/logo1.png',
                                )),
                          )),
                    ],
                  ),
                ),
                Expanded(
                  flex: 6,
                  child: Row(
                    children: [
                      Form(
                        child: Expanded(
                          flex: 6,
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 32, right: 32, top: 7.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                FadeInDown(
                                  delay: Duration(milliseconds: 2100),
                                  child: RichText(
                                    textAlign: TextAlign.center,
                                    text: const TextSpan(
                                      children: <TextSpan>[
                                        TextSpan(
                                          text: 'Identifiant',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Color.fromARGB(
                                                183, 94, 171, 56),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 14,
                                ),
                                FadeInDown(
                                  delay: Duration(milliseconds: 1900),
                                  child: SizedBox(
                                    height: 45,
                                    child: TextField(
                                      controller: _usernameController,
                                      keyboardType: TextInputType.text,
                                      decoration: const InputDecoration(
                                        hintText: 'azoveC203',
                                        hintStyle: TextStyle(
                                          color: Color(0xFFBABABA),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(12.0),
                                          ),
                                          borderSide: BorderSide(
                                            color: Color(0xFFBEC5D1),
                                            width: 1,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(12.0),
                                          ),
                                          borderSide: BorderSide(
                                            color: Color(0xFFBEC5D1),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 14,
                                ),
                                FadeInDown(
                                  delay: Duration(milliseconds: 1500),
                                  child: RichText(
                                    textAlign: TextAlign.right,
                                    text: const TextSpan(
                                      children: <TextSpan>[
                                        TextSpan(
                                          text: 'Code secret',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Color.fromARGB(
                                                183, 94, 171, 56),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 14,
                                ),
                                FadeInDown(
                                  delay: Duration(milliseconds: 1100),
                                  child: SizedBox(
                                    height: 45,
                                    child: TextField(
                                      controller: _passwordControler,
                                      autocorrect: false,
                                      enableSuggestions: false,
                                      obscureText: true,
                                      decoration: const InputDecoration(
                                        hintText: '************',
                                        hintStyle: TextStyle(
                                          color: Color(0xFFBABABA),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(12.0),
                                          ),
                                          borderSide: BorderSide(
                                            color: Color(0xFFBEC5D1),
                                            width: 1,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(12.0),
                                          ),
                                          borderSide: BorderSide(
                                            color: Color(0xFFBEC5D1),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                FadeInDown(
                                    delay: Duration(milliseconds: 800),
                                    child: Container(
                                      alignment: Alignment.topRight,
                                      margin: EdgeInsets.only(top: 22),
                                      width: Get.width / 0.5,
                                      height: Get.height / 32,
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          const Text(
                                            "si vous n\'avez pas de compte!",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 12),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              _showDialog(context);

                                              showSnackBar(
                                                  "Vous recevrez une reponse par mail ou Whatsapp");
                                            },
                                            child: const Text(
                                              'S\'inscrire',
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  color: Color.fromARGB(
                                                      183, 94, 171, 56),
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                    /* Container(
                                      alignment: Alignment.topRight,
                                      margin: EdgeInsets.only(top: 22),
                                      width: Get.width / 2,
                                      height: Get.height / 32,
                                      child: FittedBox(
                                          child: RichText(
                                        text: const TextSpan(
                                            text:
                                                'si vous n\'avez pas de compte',
                                            style: TextStyle(
                                                color: Color.fromARGB(
                                                    225, 90, 90, 90),fontSize: 20),
                                            children: <InlineSpan>[
                                              TextSpan(
                                                  text: "S'inscrire",
                                                  style: TextStyle(
                                                      color: Color.fromARGB(
                                              183, 94, 171, 56),
                                                      fontWeight:
                                                          FontWeight.w500))
                                            ]),
                                      )),
                                    ),
                                 
                                 
                                 */

                                    /*Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          _showDialog(context);
                                         
                                        },
                                        child: Container(
                                          alignment: Alignment.topRight,
                                          child: const Text(
                                            'S\'inscrire',
                                            textAlign: TextAlign.right,
                                            style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: Color.fromARGB(
                                                    183, 94, 171, 56)),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                               */
                                    ),
                                SizedBox(
                                  height: 10,
                                ),
                                FadeInDown(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      MaterialButton(
                                          height: 40,
                                          minWidth: 285,
                                          color: const Color.fromARGB(
                                              183, 94, 171, 56),
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12.0)),
                                          child: const Text(
                                            'Se connecter',
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white),
                                          ),
                                          onPressed: () async {
                                            String email = "";
                                            if (_usernameController
                                                    .text.isNotEmpty &&
                                                _passwordControler
                                                    .text.isNotEmpty) {
                                              email = _usernameController.text +
                                                  domain;
                                              service.loginUser(
                                                  context,
                                                  email.trim(),
                                                  _passwordControler.text);
                                              if (_laoding) {
                                                Center(
                                                  child: SpinKitDoubleBounce(
                                                    size: 140,
                                                    itemBuilder:
                                                        (context, index) {
                                                      final colors = [
                                                        Colors.white,
                                                        Colors.green,
                                                        Colors.red
                                                      ];
                                                      final color = colors[
                                                          index %
                                                              colors.length];

                                                      return DecoratedBox(
                                                          decoration:
                                                              BoxDecoration(
                                                                  color: color,
                                                                  shape: BoxShape
                                                                      .circle));
                                                    },
                                                  ),
                                                );
                                              } else {
                                                firestore
                                                    .collection('userData')
                                                    .doc(auth.currentUser!.uid)
                                                    .update({
                                                  "users":
                                                      FieldValue.arrayUnion(
                                                          list)
                                                });
                                              }
                                            } else {
                                              service.errorBox(context,
                                                  'Remplissez tous les champs svp');
                                            }
                                          }),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  /* Widget buildPaysage() {
    return Background(
      height: 400.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            flex: 6,
            child: Padding(
                padding: const EdgeInsets.only(top: 15.0, right: 10),
                child: Image.asset(
                  'assets/images/logo.png',
                )),
          ),
          Expanded(
            flex: 3,
            child: Form(
              child: Column(
                children: [
                  const SizedBox(
                    height: 8,
                  ),
                  Expanded(
                    flex: 6,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 32,
                        right: 32,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            textAlign: TextAlign.center,
                            text: const TextSpan(
                              children: <TextSpan>[
                                TextSpan(
                                  text: 'Identifiant',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color.fromARGB(183, 94, 171, 56),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 45,
                            child: TextField(
                              controller: _usernameController,
                              keyboardType: TextInputType.text,
                              decoration: const InputDecoration(
                                hintText: 'azoveC203',
                                hintStyle: TextStyle(
                                  color: Color(0xFFBABABA),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(12.0),
                                  ),
                                  borderSide: BorderSide(
                                    color: Color(0xFFBEC5D1),
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(12.0),
                                  ),
                                  borderSide: BorderSide(
                                    color: Color(0xFFBEC5D1),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          RichText(
                            textAlign: TextAlign.right,
                            text: const TextSpan(
                              children: <TextSpan>[
                                TextSpan(
                                  text: 'Code secret',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color.fromARGB(183, 94, 171, 56),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 14,
                          ),
                          SizedBox(
                            height: 45,
                            child: TextField(
                              controller: _passwordControler,
                              autocorrect: false,
                              enableSuggestions: false,
                              obscureText: true,
                              decoration: const InputDecoration(
                                hintText: '************',
                                hintStyle: TextStyle(
                                  color: Color(0xFFBABABA),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(12.0),
                                  ),
                                  borderSide: BorderSide(
                                    color: Color(0xFFBEC5D1),
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(12.0),
                                  ),
                                  borderSide: BorderSide(
                                    color: Color(0xFFBEC5D1),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: TextButton(
                              onPressed: () {
                                _showDialog(context);
                              },
                              child: Container(
                                alignment: Alignment.topRight,
                                child: const Text(
                                  'S\'inscrire',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color.fromARGB(183, 94, 171, 56)),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Expanded(
                            child: Container(
                              alignment: Alignment.topCenter,
                              child: MaterialButton(
                                  height: 50,
                                  minWidth: 285,
                                  color: const Color.fromARGB(183, 94, 171, 56),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(12.0)),
                                  child: const Text(
                                    'Se connecter',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white),
                                  ),
                                  onPressed: () async {
                                    String email = "";
                                    if (_usernameController.text.isNotEmpty &&
                                        _passwordControler.text.isNotEmpty) {
                                      email = _usernameController.text + domain;
                                      service.loginUser(context, email,
                                          _passwordControler.text);
                                      firestore
                                          .collection('userData')
                                          .doc(auth.currentUser!.uid)
                                          .update({
                                        "users": FieldValue.arrayUnion(list)
                                      });
                                    } else {
                                      service.errorBox(context,
                                          'Remplissez tous les champs svp');
                                    }
                                  }),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
*/
  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown
    ]);
    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          maintainBottomViewPadding: true,
          minimum: EdgeInsets.zero,
          child: Scaffold(
            body: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              scrollDirection: Axis.vertical,
              child: buildPortrail(),
            ),
          ),
        ),
      );
}

const String _heroAddTodo = 'email';

class EmailDialogForm extends StatelessWidget {
  EmailDialogForm({super.key});

  var nameCtrl = TextEditingController();
  var numCtrl = TextEditingController();
  var paysCtrl = TextEditingController();
  var msgCtrl = TextEditingController();
  var langCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Hero(
            tag: _heroAddTodo,
            createRectTween: (begin, end) {
              return CustomRectTween(begin: begin!, end: end!);
            },
            child: Material(
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32)),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Veillez renseigner ces informations",
                        style: TextStyle(fontSize: 15),
                      ),
                      SizedBox(
                        height: 6,
                      ),
                      buildTextField(
                        title: 'Nom et Prenoms',
                        controller: nameCtrl,
                        inputType: TextInputType.name,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      buildTextField(
                        title: 'Pays',
                        controller: paysCtrl,
                        inputType: TextInputType.text,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      buildTextField(
                        title: 'Langue parlée',
                        controller: langCtrl,
                        inputType: TextInputType.text,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      buildTextField(
                        title: 'Contact (whatsapp)',
                        controller: numCtrl,
                        inputType: TextInputType.phone,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      buildTextField(
                        maxLines: 5,
                        title: 'Message (Preciser les filières)',
                        controller: msgCtrl,
                        inputType: TextInputType.text,
                      ),
                      Divider(
                        color: Color.fromARGB(255, 188, 207, 12),
                        thickness: 0.2,
                      ),
                      TextButton(
                          style: TextButton.styleFrom(
                              minimumSize: Size.fromHeight(50),
                              textStyle: TextStyle(fontSize: 15)),
                          onPressed: () {
                            InfoTreatment infoTreatment = InfoTreatment(
                              nom: nameCtrl.text,
                              pays: paysCtrl.text,
                              number: numCtrl.text,
                              langue: langCtrl.text,
                              filieres: msgCtrl.text,
                            );
                            launchEmail(
                                toEmail: "compte@onghedi.org",
                                subject: "Agriconnect_Inscription",
                                message: infoTreatment.toString());

                            Navigator.pop(context);
                          },
                          child: Text(
                            'Envoyer',
                            style: TextStyle(color: Colors.red),
                          ))
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
  void _showDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Inscription"),
            content: const Text("Contactez nous pour vous inscrire"),
            actions: [
              Text(
                  "Vous recevrez une reponse par Whatsapp ou par mail dans peu de temps")
            ],
          );
        });
  }

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
}

/*class LoginCircularProgress extends StatelessWidget {
  // final String content;
  const LoginCircularProgress({
    Key? key,
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
                        "chargement de la connexion...",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      Spacer(),
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
*/
