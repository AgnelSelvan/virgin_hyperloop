import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:virgin_hyperloop/constants/constants.dart';
import 'package:virgin_hyperloop/enum/station.dart';
import 'package:virgin_hyperloop/models/booking.dart';
import 'package:virgin_hyperloop/models/convey.dart';
import 'package:virgin_hyperloop/services/firebase/train.dart';

class TrainController with ChangeNotifier {
  final trainNumberController = TextEditingController();
  var platform = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13];
  var alphabet = [
    "A",
    "B",
    "C",
    "D",
    "E",
    "F",
    "G",
    "H",
    "I",
    "J",
    "K",
    "L",
    "M",
    "N",
    "O",
    "P",
    "Q",
    "R",
    "S",
    "T",
    "U",
    "V",
    "W",
    "X",
    "Y",
    "Z"
  ];

  String? _selectedPlatform;
  String? get selectedPlatform => _selectedPlatform;
  set setSelectedPlatform(String? val) {
    _selectedPlatform = val;
    notifyListeners();
  }

  Future<void> addConveyToDB(
      BuildContext context, DateTime startTime, DateTime endTime) async {
    if (_selectedPlatform == null) {
      print("Platform Null");
      ScaffoldMessenger.of(context).showSnackBar(Constants.customSnackBar(
          content: "Please Select A Platform",
          backgroundColor: Colors.red[500]));
      return;
    }
    final todayDate = DateTime.now();
    final convey = ConveyModel(
        trainNumber: trainNumberController.text,
        platformNumber: _selectedPlatform ?? "1",
        numberOfPods: 6,
        createdAt: DateTime.now(),
        conveySeatIdsList: [],
        uid: FirestoreDB.getUID,
        startPoint: Station().getStationEnumToStr(_start),
        endPoint: Station().getStationEnumToStr(_destination),
        startTime: Timestamp.fromDate(startTime),
        endTime: Timestamp.fromDate(endTime),
        podsList: []);
    ScaffoldMessenger.of(context).showSnackBar(
        Constants.customSnackBar(content: "Convey Added Successfully"));
    await FirestoreDB.addConveyToDB(convey);
    trainNumberController.clear();
    _selectedPlatform = null;

    updateTrainNumber();
  }

  StationEnum _start = StationEnum.bkc;
  StationEnum _destination = StationEnum.pune;
  StationEnum get startStation => _start;
  StationEnum get destinationStation => _destination;
  set setStartStation(StationEnum? stationEnum) {
    if (stationEnum != null) {
      if (_destination == stationEnum) {
        throw "Start and End Destination cannot be same";
      }
      _start = stationEnum;
    }
    notifyListeners();
  }

  void reverseStationPoint() {
    final tempVal = _start;
    _start = _destination;
    _destination = tempVal;
    notifyListeners();
  }

  set setDestinationStation(StationEnum? stationEnum) {
    if (stationEnum != null) {
      if (_start == stationEnum) {
        throw "Start and End Destination cannot be same";
      }
      _destination = stationEnum;
    }
    notifyListeners();
  }

  Future<void> updateTrainNumber() async {
    final conveyModel = await FirestoreDB.getLastConvey();
    if (conveyModel == null) {
      trainNumberController.text = "A";
      notifyListeners();
    } else {
      if (alphabet.contains(conveyModel.trainNumber)) {
        final index = alphabet.indexOf(conveyModel.trainNumber);
        trainNumberController.text = alphabet[index + 1];
        notifyListeners();
      }
    }
  }
}
