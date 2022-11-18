import 'dart:async';


import 'package:agriconnect/util/font/fontAnim.dart';
import 'package:agriconnect/util/navigate.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 6), () => Navigate.gotoAuthenticate(context));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Positioned.fill(
              child: Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.bottomRight,
                    colors: [
                  Color.fromARGB(183, 43, 119, 6),
                  Color.fromARGB(255, 226, 176, 156)
                ])),
          )),
          const Padding(padding: EdgeInsets.only(bottom: 15)),
          Image.asset(
            'assets/images/logo1.png',
          ),
          const Positioned.fill(
              child: Opacity(
            opacity: 0.5,
            child: FontAnim(50),
          )),
          /*const SizedBox(
            height: 12,
            child: Padding(
                padding:
                    EdgeInsets.only(left: 0, right: 0, top: 50, bottom: 20)),
          ),*/
          /*Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: const <Widget>[
              CircularProgressIndicator(
                color: Colors.white,
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                'AGRIMETEO',
                style: TextStyle(
                    fontFamily: 'POPPINS', fontSize: 24, color: Colors.white),
              ),
              Padding(padding: EdgeInsets.only(bottom: 40.0))
            ],
          )*/
        ],
      ),
    );
  }
}
