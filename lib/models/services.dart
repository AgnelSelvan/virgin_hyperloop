import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ServiceModel {
  final String name;
  final IconData icon;
  final Color color;

  ServiceModel(this.name, this.icon, this.color);

  static List<ServiceModel> datas = [
    ServiceModel("Flight", Icons.flight_rounded, Colors.blue[300]!),
    ServiceModel("Train", Icons.train, Colors.yellow[300]!),
    ServiceModel("Bus", Icons.bus_alert, Colors.purple[300]!),
    ServiceModel("Taxi", Icons.local_taxi, Colors.pink[300]!),
    ServiceModel("Hotel", Icons.hotel, Colors.orangeAccent),
    ServiceModel("Eats", Icons.food_bank, Colors.lightBlue[300]!),
    ServiceModel("Adventure", Icons.compass_calibration, Colors.green[300]!),
    ServiceModel("Events", Icons.celebration, Colors.redAccent),
  ];
}
