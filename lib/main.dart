import 'package:flutter/material.dart';
import 'package:virgin_hyperloop/constants/constants.dart';
import 'package:virgin_hyperloop/views/splash/splash.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Virgin Hyperloop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Constants.primaryMaterialColor,
      ),
      home: SpashScreen(),
    );
  }
}
