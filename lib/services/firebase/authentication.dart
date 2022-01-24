import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:virgin_hyperloop/constants/constants.dart';
import 'package:virgin_hyperloop/models/user.dart';
import 'package:virgin_hyperloop/services/firebase/train.dart';

class Authentication {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  static final _usersCollection = firestore.collection("users");

  static Future<FirebaseApp> initializeFirebase() async {
    FirebaseApp firebaseApp = await Firebase.initializeApp();

    return firebaseApp;
  }

  static Future<User?> signInWithGoogle({required BuildContext context}) async {
    User? user;

    GoogleSignIn googleSignIn = GoogleSignIn();

    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();

    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      try {
        final UserCredential userCredential =
            await auth.signInWithCredential(credential);

        user = userCredential.user;
        if (user != null) {
          addUserDataToDB(user);
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'account-exists-with-different-credential') {
          ScaffoldMessenger.of(context).showSnackBar(
            Constants.customSnackBar(
              content: 'The account already exists with a different credential',
            ),
          );
        } else if (e.code == 'invalid-credential') {
          ScaffoldMessenger.of(context).showSnackBar(
            Constants.customSnackBar(
              content: 'Error occurred while accessing credentials. Try again.',
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          Constants.customSnackBar(
            content: 'Error occurred using Google Sign In. Try again.',
          ),
        );
      }
    }

    return user;
  }

  static Future<void> signOut({required BuildContext context}) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      await auth.signOut();
      await googleSignIn.signOut();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        Constants.customSnackBar(
          content: 'Error signing out. Try again.',
        ),
      );
    }
  }

  static bool get isUserLoggedIn {
    return getCurrentUser == null ? false : true;
  }

  static User? get getCurrentUser {
    return auth.currentUser;
  }

  static Future<void> addUserDataToDB(User user) async {
    DocumentSnapshot doc = await _usersCollection.doc(user.uid).get();
    if (doc.data() == null) {
      final userModel = UserModel(
          uid: user.uid,
          username: user.displayName ?? "",
          email: user.email,
          profilePic: user.photoURL ?? "",
          age: null);
      await _usersCollection.doc(user.uid).set(userModel.toJson());
    }
  }

  static Future<UserModel?> getMyData(String uid) async {
    final doc = await _usersCollection.doc(uid).get();
    try {
      return UserModel.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  static Future<List<UserModel>> getUserByUsername(String username) async {
    final uDocs = await _usersCollection.get();
    final currentUser = Authentication.getCurrentUser;
    List<UserModel> datas = [];
    for (var doc in uDocs.docs) {
      final user = UserModel.fromJson(doc.data());
      if (currentUser != null) {
        if (user.uid == currentUser.uid) {
          continue;
        }
      }
      if (user.username.contains(username)) {
        datas.add(user);
      }
    }

    return datas;
  }

  Future<String> makeAdmin(UserModel userModel) async {
    if (userModel.role == "user") {
      await _usersCollection.doc(userModel.uid).update({"role": "admin"});
      return "Updated ${userModel.username} Role as Admin";
    } else {
      await _usersCollection.doc(userModel.uid).update({"role": "user"});
      return "Demoted ${userModel.username} From Admin to User";
    }
  }
}
