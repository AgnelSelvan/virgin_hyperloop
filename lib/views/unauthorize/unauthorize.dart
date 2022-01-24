import 'package:custom/custom_text.dart';
import 'package:custom/ftn.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:virgin_hyperloop/constants/constants.dart';
import 'package:virgin_hyperloop/services/firebase/authentication.dart';

class UnauthorizedScreen extends StatefulWidget {
  final String value;
  final VoidCallback handleLogin;
  UnauthorizedScreen({Key? key, required this.value, required this.handleLogin})
      : super(key: key);

  @override
  _UnauthorizedScreenState createState() => _UnauthorizedScreenState();
}

class _UnauthorizedScreenState extends State<UnauthorizedScreen> {
  Future<void> onLoginClicked() async {
    await Constants().showLoginDialog(context, () async {
      final user = await Authentication.signInWithGoogle(context: context);
      // if (user != null) {
      //   ScaffoldMessenger.of(context).showSnackBar(Constants.customSnackBar(
      //       content: "Logged in as ${user.displayName}"));
      // }
      widget.handleLogin();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: CustomScreenUtility(context).width,
      height: CustomScreenUtility(context).height,
      padding: const EdgeInsets.all(30),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(Constants.unauthorizedImage),
            const SizedBox(height: 30),
            CustomText(
              "Unauthorized",
              size: 24,
              fontWeight: FontWeight.bold,
              color: Constants.primaryColor,
            ),
            const SizedBox(height: 5),
            CustomText("Please Login to check your ${widget.value}",
                size: 18, color: Colors.grey[600]),
            const SizedBox(height: 25),
            CustomTextButton(
              "Login",
              textColor: Colors.white,
              backgoundColor: Constants.primaryColor,
              onPressed: onLoginClicked,
            ),
          ],
        ),
      ),
    );
  }
}
