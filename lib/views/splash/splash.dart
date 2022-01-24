import 'dart:async';

import 'package:custom/custom_text.dart';
import 'package:custom/ftn.dart';
import 'package:flutter/material.dart';
import 'package:virgin_hyperloop/constants/constants.dart';
import 'package:virgin_hyperloop/services/firebase/authentication.dart';
import 'package:virgin_hyperloop/views/home/home.dart';

class SpashScreen extends StatefulWidget {
  SpashScreen({Key? key}) : super(key: key);

  @override
  _SpashScreenState createState() => _SpashScreenState();
}

class _SpashScreenState extends State<SpashScreen> {
  @override
  void initState() {
    Authentication.initializeFirebase();
    Timer(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomeScreen()));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      width: CustomScreenUtility(context).width,
      height: CustomScreenUtility(context).height,
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(Constants.logoImage),
          const SizedBox(height: 28),
          const SizedBox(
              width: 25, height: 25, child: CircularProgressIndicator()),
        ],
      ),
    ));
  }
}
