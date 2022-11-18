import 'package:agriconnect/pages/about/custom_rect_tween.dart';
import 'package:agriconnect/pages/about/hero_dialod_route.dart';
import 'package:agriconnect/service/auth.dart';
import 'package:agriconnect/util/SelectContry/selectContry.dart';
import 'package:agriconnect/util/SelectUser/allUser.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cupertino_list_tile/cupertino_list_tile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:multiselect/multiselect.dart';
import 'package:url_launcher/url_launcher.dart';

class SignHome extends StatefulWidget {
  const SignHome({Key? key}) : super(key: key);

  @override
  State<SignHome> createState() => _SignHomeState();
}

class _SignHomeState extends State<SignHome> {
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
            return const SignScreen();
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}

class SignScreen extends StatefulWidget {
  const SignScreen({Key? key}) : super(key: key);

  @override
  State<SignScreen> createState() => _SignScreenState();
}

class _SignScreenState extends State<SignScreen> {
  AuthService service = AuthService();
  String domain = "@agriconnect.com";
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _usernameController = TextEditingController();
  final _passwordControler = TextEditingController();
  final _confPasController = TextEditingController();
  final _nameController = TextEditingController();

  final _numController = TextEditingController();
  String state = 'user';

  final _formKey = GlobalKey<FormState>();

  //checkbox variable
  final auth = FirebaseAuth.instance;
  List<String> categories = [];
  List<String> langues = [];
  List<String> type = [];
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  //int userSelect = 1;
  List<String> LangItems = [
    'Yoruba',
    'Baoulé',
    'Djoula',
    'Fon',
    'Adja',
    'Dendi',
    'Idatcha',
    'Nago',
    'Bété',
    'Ewé',
    'Mina',
    'Wolof',
    'Anglais',
    'Français'
  ];
  String selectedLang = 'Yoruba';
  Map<String, dynamic> data = {"country": "Bénin", "code": "+229"};

  bool isloading = false;
  void _showDialog1(BuildContext context, String txt, String title) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Text(txt),
            actions: <Widget>[
              TextButton(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  void _listener() {
    setState(() {});
  }

  @override
  void initState() {
    _nameController.addListener(_listener);
    _numController.addListener(_listener);
    _usernameController.addListener(_listener);
    _passwordControler.addListener(_listener);
    _confPasController.addListener(_listener);

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();

    _numController.dispose();

    _usernameController.dispose();
    _passwordControler.dispose();
    _confPasController.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
            appBar: AppBar(
              title: const Text("Inscription"),
              leading: SizedBox(
                width: 20,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AllUsers()));
                  },
                  icon: Image.asset(
                    "assets/images/back.png",
                    width: 20,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Retour',
                    style: TextStyle(fontSize: 15, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                      alignment: Alignment.centerLeft,
                      elevation: 0,
                      primary: Colors.transparent,
                      minimumSize: const Size(100, 30)),
                ),
              ),
              backgroundColor: Colors.green,
              centerTitle: true,
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        colors: [Color.fromARGB(255, 4, 41, 5), Colors.red],
                        begin: Alignment.bottomRight,
                        end: Alignment.topLeft)),
              ),
              elevation: 20,
              automaticallyImplyLeading: false,
            ),
            body: isloading
                ? Center(
                    child: Container(
                      height: MediaQuery.of(context).size.height / 20,
                      width: MediaQuery.of(context).size.width / 20,
                      child: const CircularProgressIndicator(),
                    ),
                  )
                : SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: Column(
                      children: <Widget>[
                        Center(
                            child: Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 5),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                FadeInDown(
                                    delay: Duration(milliseconds: 3800),
                                    child: Formulaire(
                                        controller: _nameController,
                                        hintText: 'Nom',
                                        label: 'Nom connu de tous',
                                        textInput: TextInputType.name)),
                                const SizedBox(
                                  height: 12,
                                ),
                                FadeInDown(
                                  delay: Duration(milliseconds: 3200),
                                  child: DropDownMultiSelect(
                                    onChanged: (List<String> x) {
                                      setState(() {
                                        type = x;
                                      });
                                    },
                                    options: const [
                                      'Producteur/Cooperative',
                                      'Institution de Recherche',
                                      'ONG/Fédération',
                                      'Agence d\'Etat'
                                    ],
                                    selectedValues: type,
                                    whenEmpty: 'Utilisateur',
                                  ),
                                ),
                                const SizedBox(
                                  height: 12,
                                ),
                                FadeInDown(
                                  delay: Duration(milliseconds: 2900),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        "Choix du pays",
                                        style: TextStyle(color: Colors.green),
                                      ),
                                      CupertinoListTile(
                                        onTap: () async {
                                          Map<String, dynamic> dataResult =
                                              await Navigator.push(
                                                  context,
                                                  CupertinoPageRoute(
                                                      builder: (context) =>
                                                          const SelectCountry()));
                                          setState(() {
                                            if (dataResult != null)
                                              data = dataResult;
                                          });
                                        },
                                        title: Text(
                                          data['country'],
                                          style: const TextStyle(
                                              color: Colors.green),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Row(
                                          children: [Text(data['code'])],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 12,
                                ),
                                FadeInDown(
                                  delay: Duration(milliseconds: 2500),
                                  child: Formulaire(
                                    controller: _usernameController,
                                    hintText: 'Identifiant à attribuer',
                                    label: 'identifiant',
                                    textInput: TextInputType.text,
                                  ),
                                ),
                                const SizedBox(
                                  height: 12,
                                ),
                                FadeInDown(
                                    delay: Duration(milliseconds: 2100),
                                    child: Formulaire(
                                        controller: _numController,
                                        hintText: 'ex:55625459',
                                        label: 'Contact',
                                        textInput: TextInputType.phone)),
                                const SizedBox(
                                  height: 12,
                                ),
                                FadeInDown(
                                    delay: Duration(milliseconds: 1900),
                                    child: Formulaire(
                                        controller: _passwordControler,
                                        hintText: '***********',
                                        label: 'Code Secret',
                                        textInput:
                                            TextInputType.visiblePassword)),
                                const SizedBox(
                                  height: 12,
                                ),
                                FadeInDown(
                                    delay: Duration(milliseconds: 1500),
                                    child: Formulaire(
                                        controller: _confPasController,
                                        hintText: 'repeter le code',
                                        label: 'Confirmation',
                                        textInput:
                                            TextInputType.visiblePassword)),
                                const SizedBox(
                                  height: 12,
                                ),
                                FadeInDown(
                                  delay: Duration(milliseconds: 1100),
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: const Color.fromARGB(
                                              183, 43, 97, 16)),
                                      borderRadius: BorderRadius.circular(9),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15.0, vertical: 6.0),
                                    child: DropdownButtonFormField<String>(
                                      decoration: InputDecoration(
                                          enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: const BorderSide(
                                                  width: 5,
                                                  color: Colors.green))),
                                      value: selectedLang,
                                      items: LangItems.map(
                                          (e) => DropdownMenuItem<String>(
                                              value: e,
                                              child: Text(
                                                e,
                                                style: const TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.green),
                                              ))).toList(),
                                      onChanged: (item) => setState(() {
                                        selectedLang = item!;
                                        print(selectedLang);
                                      }),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 12,
                                ),
                                FadeInDown(
                                  delay: Duration(milliseconds: 800),
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        DropDownMultiSelect(
                                          onChanged: (List<String> x) {
                                            setState(() {
                                              categories = x;
                                            });
                                          },
                                          options: const [
                                            'Production végétale',
                                            'Production animale',
                                            'Pêche/Aquaculture',
                                            'Trans-agroalimentaire',
                                            'Elevage',
                                            'Intrants/Equipements',
                                            'Tous',
                                            'Autres',
                                          ],
                                          selectedValues: categories,
                                          whenEmpty: ' Filières*',
                                        ),
                                      ]),
                                ),
                                const SizedBox(
                                  height: 12,
                                ),
                                FadeInDown(
                                  delay: Duration(milliseconds: 400),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      const Text(
                                        'Statut',
                                        style: TextStyle(
                                            fontFamily: 'POPPINS',
                                            fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Radio<String>(
                                                value: 'admin',
                                                groupValue: state,
                                                onChanged: (value) {
                                                  setState(() {
                                                    state = value!;
                                                  });
                                                },
                                              ),
                                              const Text('Administrateur'),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Radio<String>(
                                                value: 'éditeur',
                                                groupValue: state,
                                                onChanged: (value) {
                                                  setState(() {
                                                    state = value!;
                                                  });
                                                },
                                              ),
                                              const Text('Editeur'),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Radio<String>(
                                                value: 'user',
                                                groupValue: state,
                                                onChanged: (value) {
                                                  setState(() {
                                                    state = value!;
                                                  });
                                                },
                                              ),
                                              const Text('Simple Utilisateur'),
                                            ],
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                FadeInDown(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if (type.isNotEmpty &&
                                          categories.isNotEmpty) {
                                        setState(() {
                                          isloading = true;
                                        });
                                        if (_confPasController.text !=
                                            _passwordControler.text) {
                                          /* Navigator.of(context)
                                              .push(HeroDialogRoute(
                                            builder: (context) {
                                              return SaveUserDialog(
                                                msg: 'Mot de passe Erroné',
                                              );
                                            },
                                          ));*/
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                            content: ErrorSnackBar(
                                              title: 'Erreur Mot de passe',
                                              content:
                                                  'Mot de passe pas convenable ',
                                            ),
                                            behavior: SnackBarBehavior.floating,
                                            backgroundColor: Colors.transparent,
                                            elevation: 0,
                                          ));
                                        } else {
                                          service.createAccount(
                                              context,
                                              _usernameController.text.trim() +
                                                  domain,
                                              _passwordControler.text,
                                              _nameController.text,
                                              type,
                                              data['code'] +
                                                  _numController.text,
                                              data['country'],
                                              state,
                                              selectedLang,
                                              categories);

                                          if (service != null) {
                                            if (state == "user") {
                                              Navigator.of(context)
                                                  .push(HeroDialogRoute(
                                                builder: (context) {
                                                  return const EditeurDialog();
                                                },
                                              ));
                                            } else {
                                              //_showDialog1(context, 'Succès');

                                            }

                                            setState(() {
                                              isloading = false;
                                            });

                                            print("Reussie");

                                            Get.back();
                                          } else {
                                            print("Echec");
                                          }
                                        }
                                      } else {
                                        print("Remplissez tous les champs");
                                        // _showDialog1(context, "Erreur!",'');
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                          content: ErrorSnackBar(
                                            title: 'Erreur',
                                            content:
                                                'Veillez remplir tous les champs',
                                          ),
                                          behavior: SnackBarBehavior.floating,
                                          backgroundColor: Colors.transparent,
                                          elevation: 0,
                                        ));
                                      }
                                    },
                                    child: Text('Creer'),
                                    style: ElevatedButton.styleFrom(
                                      primary: Colors.green,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10.0, horizontal: 50),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30.0)),
                                    
                                    
                                    
                                    ),


                                  ),
                                ),
                              ],
                            ),
                          ),
                        )),
                      ],
                    ),
                  )),
      );
}

class ErrorSnackBar extends StatelessWidget {
  final String title;
  final String content;
  const ErrorSnackBar({
    Key? key,
    required this.title,
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
              color: Color(0xFFC72C41),
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
                        title,
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
                color: Color(0xFF801336),
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

class Formulaire extends StatelessWidget {
  const Formulaire({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.label,
    required this.textInput,
  }) : super(key: key);

  final TextEditingController controller;
  final String? hintText;
  final String label;
  final TextInputType textInput;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: textInput,
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        fillColor: Color.fromARGB(255, 8, 49, 10),
        alignLabelWithHint: false,
        labelText: label,
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(12.0),
          ),
          borderSide: BorderSide(
            color: Color(0xFFBEC5D1),
            width: 1,
          ),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(12.0),
          ),
          borderSide: BorderSide(
            color: Color(0xFFBEC5D1),
          ),
        ),
        hintStyle: const TextStyle(
          color: Color.fromARGB(183, 94, 171, 56),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      validator: (String? value) {
        return (value == null || value == "")
            ? 'Ce champ est obligatoire:'
            : null;
      },
    );
  }
}

const String _heroNum = 'Calling';

class EditeurDialog extends StatefulWidget {
  const EditeurDialog({
    super.key,
  });

  @override
  State<EditeurDialog> createState() => _EditeurDialogState();
}

class _EditeurDialogState extends State<EditeurDialog> {
  String phoneNumber = '';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final Stream<QuerySnapshot> users = FirebaseFirestore.instance
      .collection('userData')
      .where("statut", isEqualTo: "éditeur")
      .snapshots();
  void _showDialog1(BuildContext context, String txt) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Enregistrement"),
            content: Text(txt),
            actions: <Widget>[
              TextButton(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
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
                          _firestore
                              .collection('userData')
                              .doc(_auth.currentUser!.uid)
                              .set({'editeur': map['identifiant']},
                                  SetOptions(merge: true));
                          // _showDialog1(context, 'Succès');
                          Navigator.pop(context);
                        })
                    : Container();
              });
        });
  }

  @override
  void initState() {
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

String dialo = 'Enregistrement';

class SaveUserDialog extends StatelessWidget {
  const SaveUserDialog({super.key, required this.msg});
  final String msg;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Hero(
          tag: dialo,
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
                    ListTile(
                      title: Text("Enregistrement"),
                      subtitle: Text(msg),
                    ),
                    const Divider(
                      color: Colors.white,
                      thickness: 0.2,
                    ),
                    TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SignScreen()));
                        },
                        child: Text('OK'))
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
