import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';



import 'package:agriconnect/util/SelectUser/allUser.dart';
import 'package:agriconnect/util/affichage_Methode/TextPlug/buildMessage.dart';
import 'package:agriconnect/util/affichage_Methode/TextPlug/textCustom.dart';
import 'package:agriconnect/util/affichage_Methode/audioPlayer.dart';
import 'package:agriconnect/util/affichage_Methode/showImage.dart';
import 'package:agriconnect/util/affichage_Methode/videos_plug/videoPlayer.dart';
import 'package:agriconnect/util/filieres/selectCategorie.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';

import 'package:readmore/readmore.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'package:video_compress/video_compress.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({
    Key? key,
    required this.userMap,
    required this.chatRoomId,
    required this.token,
    //required this.categChoice,
  }) : super(key: key);
  final Map<String, dynamic> userMap;
  final String chatRoomId;
  final String token;
  //final dynamic categChoice;
  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> with WidgetsBindingObserver {
  Map<String, dynamic>? userMap;
  bool isLoading = false;
  bool _selectionChoisie = false;

  late DateFormat dateFormat;
  late DateFormat timeFormat;

  var time = DateTime.now();
  File? imageFile, otherFile;
  PlatformFile? fileVideo;
  Uint8List? thumbnailBytes;
  final TextEditingController _message = TextEditingController();
  final TextEditingController _description = TextEditingController();
  String usertoken = "";
  final List<String> listToken = [];


  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late AndroidNotificationChannel channel;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  final List<String> _audioExtensions = [
    'mp3',
    'm4a',
    'wav',
    'ogg',
    'aac',
  ];

  final List<String> _videoExtensions = ['mp4', 'avi', '3gp', 'm4a', '3gpp'];
  final List<String> _imgExtensions = [
    'png',
    'jpeg',
    'jpg',
    'git',
  ];
  Map<String, dynamic> data = {"cat": ""};

  //Les methodes
  void sendPushMessage(String token, String body, String title) async {
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=AIzaSyB0wtmTQrZjyMBhnNHsTGPIChm87JXz8TI',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{'body': body, 'title': title},
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': 'done'
            },
            "to": token,
          },
        ),
      );
    } catch (e) {
      print("error push notification");
    }
  }

  void listenFCM() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null && !kIsWeb) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              // TODO add a proper drawable resource to android, for now using
              //      one that already exists in example app.
              icon: '@mipmap/ic_launcher',
            ),
          ),
        );
      }
    });
  }

  void requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  void loadFCM() async {
    if (!kIsWeb) {
      channel = const AndroidNotificationChannel(
        'high_importance_channel', // id
        'High Importance Notifications', // title
        importance: Importance.high,
        enableVibration: true,
      );

      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

      /// Create an Android Notification Channel.
      ///
      /// We use this channel in the `AndroidManifest.xml` file to override the
      /// default FCM channel to enable heads up notifications.
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      /// Update the iOS foreground notification presentation options to allow
      /// heads up notifications.
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  Future<List<String>> getAllUserToken() async {
    await _firestore
        .collection('userData')
        .doc(_auth.currentUser!.uid)
        .get()
        .then((value) => {
              /*  listToken.forEach((element) {
                if (element == value['token'])
                  return;
                else {
                  setState(() {
                    listToken.add(element);
                  });
                }
              })
            */
            });
    return listToken;
  }

  String generateRandomString(int len) {
    var r = Random();
    String randomString =
        String.fromCharCodes(List.generate(len, (index) => r.nextInt(33) + 89));
    return randomString;
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
              title:
                  const Text("Etes-vous sur de vouloir supprimer ce message?"),
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

  /* storeNotification() async {
    String? token = await FirebaseMessaging.instance.getToken();
    _firestore
        .collection('sending')
        .doc(widget.chatRoomId)
        .collection('envoyers')
        .doc()
        .set({'token': token}, SetOptions(merge: true));
  }
*/
  /* sendNotification(String title, String token) async {
    final data = {
      'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      'id': 1,
      'status': 'done',
      'message': title,
    };
    try {
      http.Response response =
          await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
              headers: <String, String>{
                'Content-Type': 'application/json',
                'Autorization':
                    'key=AAAASR1zXIo:APA91bFWSbo2GM1V-tE0Wb6tvFNjfGm0FYzrgdLL14uvVS8tNkX222ZvaknHVkb7dwXa6E49CNltSbz9v7kM52Q0xVAlRKuijNb_LBF4DPM4EtrwdqzBNwyHhtGyv0UmtM06jYtv1nDs'
              },
              body: jsonEncode(<String, dynamic>{
                'notification': <String, dynamic>{
                  'title': title,
                  'body': 'vous avez un nouveau message',
                  'priority': 'high',
                  'data': data,
                  'to': '$token'
                }
              }));
      if (response.statusCode == 200) {
        print('Notification reçu');
      } else
        print('error');
    } catch (e) {}
  }*/
//Dialogue description methode
  Future<String?> openDescriptionDialog() => showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.blueGrey,
          insetPadding: EdgeInsets.all(10),
          title: Text("Description"),
          content: TextField(
            keyboardType: TextInputType.multiline,
            maxLines: null,
            minLines: null,
            expands: true,
            controller: _description,
            onSubmitted: (_) => submit(),
            decoration: InputDecoration(
              hintText: 'Votre texte',
              contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
              filled: true,
            ),
          ),
          actions: [TextButton(onPressed: submit, child: Text('Save'))],
        ),
      );
  void submit() async {
    Map<String, dynamic> dataResult = await Navigator.push(context,
        CupertinoPageRoute(builder: (context) => const SelectCategorie()));
    setState(() {
      if (dataResult != null) {
        data = dataResult;
        Navigator.of(context).pop(_description.text);
      }
    });
    _description.clear();
  }

//recuperer l'image
  Future getImage() async {
    ImagePicker _picker = ImagePicker();

    await _picker.pickImage(source: ImageSource.gallery).then((xFile) {
      if (xFile != null) {
        imageFile = File(xFile.path);

        uploadImage();
      }
    });
  }

//stocker l'image dans le firebase
  Future uploadImage() async {
    String fileName = const Uuid().v1();
    int status = 1;
   
     final desc = await openDescriptionDialog();
    if (desc != null) print(desc);

    await _firestore
        .collection('sending')
        .doc(widget.chatRoomId)
        .collection('envoyers')
        .doc(fileName)
        .set({
      "sendby": _auth.currentUser!.displayName,
      "message": "",
      "type": "img",
      "date": dateFormat.format(time),
      "time": timeFormat.format(time),
      "code": FieldValue.increment(1),
      "codetime": FieldValue.serverTimestamp(),
      "categorie": data['cat'],
      "desc": desc,
      "token": widget.token
    });

    var ref =
        FirebaseStorage.instance.ref().child('files').child("$fileName.jpg");

    var uploadTask = await ref.putFile(imageFile!).catchError((error) async {
      await _firestore
          .collection('sending')
          .doc(widget.chatRoomId)
          .collection('envoyers')
          .doc(fileName)
          .delete();

      status = 0;
    });

    if (status == 1) {
      String imageUrl = await uploadTask.ref.getDownloadURL();

      await _firestore
          .collection('sending')
          .doc(widget.chatRoomId)
          .collection('envoyers')
          .doc(fileName)
          .update({"message": imageUrl});
      sendPushMessage(widget.token, 'un nouvelle image', "Agrimetéo");
    }
  }

  Widget fetch() {
    return StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('sending')
            .doc(widget.chatRoomId)
            .collection('envoyers')
            .snapshots(),
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

                return Container();
              });
        });
  }

  //delete
  Future supprData(docId) async {
    final docUser =
        FirebaseFirestore.instance.collection("userData").doc(docId);
    docUser.delete();
  }

//recuperer et stocker autres fichiers

  Future uploadFile() async {
    String fileName = const Uuid().v1();
    int status = 1;
    int state = 1;

    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result == null) return;
    /*Map<String, dynamic> dataResult = await Navigator.push(context,
        CupertinoPageRoute(builder: (context) => const SelectCategorie()));*/
    final desc = await openDescriptionDialog();
    if (desc != null) print(desc);

    final path = result.files.first.path;

    setState(() {
      // if (dataResult != null) data = dataResult;
      otherFile = File(path!);
    });
    

    await _firestore
        .collection('sending')
        .doc(widget.chatRoomId)
        .collection('envoyers')
        .doc(fileName)
        .set({
      "sendby": _auth.currentUser!.displayName,
      "message": "",
      "type": "",
      "date": dateFormat.format(time),
      "time": timeFormat.format(time),
      "code": FieldValue.increment(1),
      "codetime": FieldValue.serverTimestamp(),
      "categorie": data['cat'],
      "token": widget.token,
      "desc": desc
    });

    var ref = FirebaseStorage.instance
        .ref()
        .child('files')
        .child("$fileName.${result.files.first.extension}");

    var uploadTask = await ref.putFile(otherFile!).catchError((error) async {
      await _firestore
          .collection('sending')
          .doc(widget.chatRoomId)
          .collection('envoyers')
          .doc(fileName)
          .delete();

      status = 0;
    });

    if (status == 1) {
      String fileUrl = await uploadTask.ref.getDownloadURL();
      result.files.forEach((element) async {
        print('Name: ${element.path}');
        print('Extension: ${element.extension}');

        if (_audioExtensions.contains(element.extension)) {
          _firestore
              .collection('sending')
              .doc(widget.chatRoomId)
              .collection('envoyers')
              .doc(fileName)
              .update({"message": fileUrl, "type": 'audio'});
        }
        if (_videoExtensions.contains(element.extension)) {
          setState(() {
            fileVideo = element;
          });

          final thnailBytes =
              await VideoCompress.getByteThumbnail(element.path.toString());
          setState(() => thumbnailBytes = thnailBytes);

          var reference = FirebaseStorage.instance
              .ref()
              .child('videoThumbnail')
              .child("$fileName.jpg");

          var uploadThumb = await reference
              .putData(thumbnailBytes!)
              .catchError((error) async {
            await _firestore
                .collection('sending')
                .doc(widget.chatRoomId)
                .collection('envoyers')
                .doc(fileName)
                .delete();

            state = 0;
          });

          String thmbUrl = await uploadThumb.ref.getDownloadURL();

          // generateThumbnail(fileVideo!);

          print(thmbUrl);

          _firestore
              .collection('sending')
              .doc(widget.chatRoomId)
              .collection('envoyers')
              .doc(fileName)
              .update(
                  {"message": fileUrl, "type": 'video', "thumbnail": thmbUrl});
          // generateThumbnail(fileUrl);

        }
        if (_imgExtensions.contains(element.extension)) {
          _firestore
              .collection('sending')
              .doc(widget.chatRoomId)
              .collection('envoyers')
              .doc(fileName)
              .update({"message": fileUrl, "type": 'img'});
        }
      });

      print(fileUrl);
      sendPushMessage(widget.token, 'Un nouveau fichier', 'Agrimeteo');
    }
  }

//Envoie du text
  void onSendMessage() async {
    if (_message.text.isNotEmpty) {
      Map<String, dynamic> dataResult = await Navigator.push(context,
          CupertinoPageRoute(builder: (context) => const SelectCategorie()));
      setState(() {
        if (dataResult != null) data = dataResult;
      });
      Map<String, dynamic> messages = {
        "sendby": _auth.currentUser!.displayName,
        "message": _message.text,
        "type": "text",
        "date": dateFormat.format(time),
        "time": timeFormat.format(time),
        "code": FieldValue.increment(1),
        "codetime": FieldValue.serverTimestamp(),
        "categorie": data['cat'],
        "token": widget.token
      };

      _message.clear();
      // sendNotification('AGRIMETEO', token!);
      await _firestore
          .collection('sending')
          .doc(widget.chatRoomId)
          .collection('envoyers')
          .add(messages);

      sendPushMessage(widget.token, _message.text, 'Agrimeteo');
    } else {
      print("Entrer un Texte");
    }
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

    /* 
 */
  }

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
    dateFormat = DateFormat.yMMMMd('fr');
    timeFormat = DateFormat.Hms('fr');
    getAllUserToken();

    requestPermission();

    loadFCM();

    listenFCM();
  }

  Widget sending() {
    final size = MediaQuery.of(context).size;

    return Container(
      height: size.height / 10,
      width: size.width,
      alignment: Alignment.center,
      child: Container(
        height: size.height / 12,
        width: size.width / 1.1,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: size.height / 10,
              width: size.width / 1.3,
              child: TextField(
                keyboardType: TextInputType.multiline,
                maxLines: null,
                minLines: null,
                expands: true,
                controller: _message,
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                    filled: true,
                    suffixIcon: IconButton(
                      onPressed: () {
                        getImage();
                        //sendNotification('AGRIMETEO', token!);
                      },
                      icon: const Icon(Icons.photo,
                          color: Color.fromARGB(183, 43, 97, 16)),
                    ),
                    prefixIcon: IconButton(
                      onPressed: () {
                        uploadFile();
                        //sendNotification('AGRIMETEO', token!);
                      },
                      icon: const Icon(
                        Icons.link,
                        size: 25,
                        color: Color.fromARGB(183, 43, 97, 16),
                      ),
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(width: 2.0))),
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.send,
                color: Color.fromARGB(183, 43, 97, 16),
              ),
              onPressed: onSendMessage,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPortrail() {
    final size = MediaQuery.of(context).size;
    return Column(
      children: [
        Container(
          height: size.height / 1.25,
          width: size.width,
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('sending')
                .doc(widget.chatRoomId)
                .collection('envoyers')
                .orderBy("codetime", descending: true)
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.data != null) {
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> map = snapshot.data!.docs[index].data()
                        as Map<String, dynamic>;

                    /* try {} catch (e) {
                      token = snapshot.data!.docs[index].get('token');
                    } catch (e) {}*/
                    return messageType(size, map, context);
                  },
                );
              } else {
                return Container();
              }
            },
          ),
        ),
        sending()
      ],
    );
  }

  Widget buildPaysage() {
    final size = MediaQuery.of(context).size;
    return Column(
      children: [
        Container(
          height: size.height,
          width: size.width,
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('sending')
                .doc(widget.chatRoomId)
                .collection('envoyers')
                .orderBy("codetime", descending: true)
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.data != null) {
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> map = snapshot.data!.docs[index].data()
                        as Map<String, dynamic>;

                    return messageType(size, map, context);
                  },
                );
              } else {
                return Container();
              }
            },
          ),
        ),
        sending()
      ],
    );
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: WillPopScope(
          onWillPop: _onWillPop,
          child: Scaffold(
            body: SingleChildScrollView(
              child: OrientationBuilder(
                builder: (BuildContext context, Orientation orientation) {
                  return orientation == Orientation.portrait
                      ? buildPortrail()
                      : buildPaysage();
                },
              ),
            ),
            appBar: AppBar(
              automaticallyImplyLeading: false,
              leadingWidth: 110,
              leading: SizedBox(
                width: 20,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AllUsers())),
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
              centerTitle: true,
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        colors: [Colors.green, Colors.red],
                        begin: Alignment.bottomRight,
                        end: Alignment.topLeft)),
              ),
              elevation: 20,
              backgroundColor: Colors.green,
              title: Center(child: Text('${_auth.currentUser!.displayName}')),
            ),
          ),
        ),
      );
}
