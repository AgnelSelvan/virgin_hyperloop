import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:virgin_hyperloop/enum/seat_status.dart';
import 'package:virgin_hyperloop/models/user.dart';
import 'package:virgin_hyperloop/services/firebase/train.dart';
import 'package:virgin_hyperloop/views/booking/booking.dart';

class BookingSeatModel {
  String uid;
  final String seatNumber;
  final List<int> seatMatric;
  final TrainSeatStatus trainSeatStatus;

  BookingSeatModel(
      {required this.seatNumber,
      required this.seatMatric,
      required this.trainSeatStatus,
      required this.uid});
}
