import 'package:flutter/material.dart';
import 'package:virgin_hyperloop/constants/constants.dart';
import 'package:virgin_hyperloop/views/booking/booking.dart';

class UserModel {
  final String uid;
  final String username;
  final String? email;
  final String? profilePic;
  final int? age;
  final String role;
  final Color? color;

  UserModel(
      {required this.uid,
      required this.username,
      this.role = "user",
      this.email,
      this.profilePic,
      this.age,
      this.color});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
        uid: json["uid"],
        username: json["username"],
        email: json["email"],
        profilePic: json["profilePic"],
        age: json["age"],
        role: json["role"],
        color: Constants.getRandomColor);
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'role': role,
        'username': username,
        'email': email,
        'profilePic': profilePic,
        'age': age,
      };
}

enum BookingSeatStatus { booked, notBooked, unavailable }
