import 'dart:convert';


import 'package:agriconnect/models/infoTreatment.dart';
import 'package:agriconnect/util/SelectContry/selectContry.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cupertino_list_tile/cupertino_list_tile.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:multiselect/multiselect.dart';

import 'package:http/http.dart' as http;

class SignForAllScreen extends StatefulWidget {
  const SignForAllScreen({Key? key}) : super(key: key);

  @override
  State<SignForAllScreen> createState() => _SignScreenState();
}

class _SignScreenState extends State<SignForAllScreen> {
  String domain = "@agrimeteo.com";
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _nameController = TextEditingController();

  final _numController = TextEditingController();
  final _comment = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  //checkbox variable
  final auth = FirebaseAuth.instance;

  String categories = "";
  List<String> langues = [];
  List<String> type = [];

  FirebaseFirestore firestore = FirebaseFirestore.instance;

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
  Map<String, dynamic> data = {"country": "Benin", "continent": "Afrique"};

  bool isloading = false;

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  Future sendEmail(String msg) async {
    final url = Uri.parse("https://api.emailjs.com/api/v1.0/email/send");
    const serviceId = 'service_1x6aald';
    const templateId = "template_9mmv9wk";
    const userId = "mkBtt6K5gMfkebSNC";

    final response = await http.post(url,
        headers: {'Content-Type': 'application/'},
        body: json.encode({
          "service_id": serviceId,
          "template_id": templateId,
          "user_id": userId,
          "template_params": {
            "name": auth.currentUser!.displayName,
            "subject": "Demande d'inscription",
            "massage": msg,
            "user_email": auth.currentUser!.email
          }
        }));
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
            appBar: AppBar(
              title: const Text("Inscription"),
              backgroundColor: Colors.green,
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
                                //nom
                                TextFormField(
                                  keyboardType: TextInputType.name,
                                  controller: _nameController,

                                  decoration: const InputDecoration(
                                    hintText: 'Nom Complet?',
                                    hintStyle: TextStyle(
                                      color: Color.fromARGB(183, 94, 171, 56),
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
                                    labelText: 'Nom *',
                                    suffixStyle: TextStyle(
                                        color:
                                            Color.fromARGB(183, 94, 171, 56)),
                                  ),
                                  validator: (String? value) {
                                    return (value == null || value == "")
                                        ? 'Ce champ est obligatoire:'
                                        : null;
                                  },
                                  //onSaved: (val) => name = val!,
                                ),
                                const SizedBox(
                                  height: 12,
                                ),
                                //Type d'utilisateur
                                DropDownMultiSelect(
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
                                const SizedBox(
                                  height: 12,
                                ),
                                //Pays
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
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
                                        children: [Text(data['continent'])],
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  height: 12,
                                ),
                                //numero de Téléphone
                                TextFormField(
                                  keyboardType: TextInputType.phone,
                                  controller: _numController,
                                  decoration: const InputDecoration(
                                    hintText: 'numero de telephone?',
                                    labelText: 'Contact *',
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
                                    hintStyle: TextStyle(
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
                                  //onSaved: (val) => num = val!,
                                ),
                                const SizedBox(
                                  height: 12,
                                ),
                                //langue
                                Container(
                                  width: 300.0,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: const Color.fromARGB(
                                            183, 43, 97, 16)),
                                    borderRadius: BorderRadius.circular(9),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15.0, vertical: 6.0),
                                  child: DropdownButtonFormField<String>(
                                    isExpanded: true,
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
                                const SizedBox(
                                  height: 12,
                                ),
                                //filieres
                                /*Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      DropDownMultiSelect(
                                        onChanged: (List<String> x) {
                                          setState(() {
                                            categories = x;
                                          });
                                        },
                                        options: const [
                                          'Maïs',
                                          'Riz',
                                          'Soja',
                                          'Ananas',
                                          'Maraichage',
                                          'Anacarde',
                                          'Cacao',
                                          'Hévéa',
                                          'Coton',
                                          'Manioc',
                                          'Igname',
                                          'Autres'
                                        ],
                                        selectedValues: categories,
                                        whenEmpty: ' Filières*',
                                      ),
                                    ]),
*/
                                //commentaire

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      height:
                                          MediaQuery.of(context).size.height /
                                              10,
                                      width: MediaQuery.of(context).size.width,
                                      child: TextField(
                                        keyboardType: TextInputType.multiline,
                                        maxLines: null,
                                        minLines: null,
                                        expands: true,
                                        controller: _comment,
                                        decoration: InputDecoration(
                                            contentPadding:
                                                const EdgeInsets.fromLTRB(
                                                    10, 10, 10, 0),
                                            filled: true,
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: const BorderSide(
                                                    width: 2.0))),
                                      ),
                                    ),
                                  ],
                                ),

                                ElevatedButton(
                                  onPressed: () async {
                                    InfoTreatment infoTreatment = InfoTreatment(
                                        nom: _nameController.text,
                                       
                                        pays: data['contry'],
                                        number: _numController.text,
                                        langue: selectedLang,
                                        filieres: categories,
                                        );
                                    sendEmail(infoTreatment.toString());

                                    if (type.isNotEmpty &&
                                        categories.isNotEmpty &&
                                        categories.isNotEmpty) {
                                      setState(() {
                                        isloading = true;
                                      });
                                      print(infoTreatment);
                                    } else {}
                                  },
                                  child: const Text('Valider'),
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.green,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10.0, horizontal: 50),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(30.0)),
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
