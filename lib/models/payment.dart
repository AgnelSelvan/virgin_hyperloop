import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:virgin_hyperloop/models/user.dart';

class PaymentModel {
  final String paymentId;
  final String bookingId;
  final double amount;
  final String userId;
  final String id;
  final Timestamp createdAt;

  PaymentModel(
      {required this.paymentId,
      required this.bookingId,
      required this.id,
      required this.createdAt,
      required this.amount,
      required this.userId});
  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
        paymentId: json["paymentId"],
        createdAt: (json["createdAt"] as Timestamp),
        bookingId: json["bookingId"],
        userId: json["userId"],
        amount: json["amount"],
        id: json["id"]);
  }

  Map<String, dynamic> toJson() => {
        'paymentId': paymentId,
        'bookingId': bookingId,
        'createdAt': createdAt,
        'userId': userId,
        'amount': amount,
        'id': id,
      };
}

class BookedTicketModel {
  final String paymentId;
  final String conveyId;
  final String podId;
  final List<UserModel> passengerList;
  final List<String> seatIds;
  final double amount;
  final String userId;
  final String id;
  final Timestamp createdAt;
  final String seatNumber;

  BookedTicketModel(
      {required this.paymentId,
      required this.conveyId,
      required this.podId,
      required this.passengerList,
      required this.seatIds,
      required this.amount,
      required this.userId,
      required this.id,
      required this.createdAt,
      required this.seatNumber});
  factory BookedTicketModel.fromJson(Map<String, dynamic> json) {
    return BookedTicketModel(
        paymentId: json["paymentId"],
        conveyId: json["conveyId"],
        createdAt: (json["createdAt"] as Timestamp),
        seatIds: (json["seatIds"] as List).cast<String>(),
        podId: json["podId"],
        userId: json["userId"],
        amount: json["amount"],
        passengerList: (json["passengerList"] as List)
            .map((e) => UserModel.fromJson(e))
            .toList(),
        id: json["id"],
        seatNumber: json['seatNumber']);
  }

  Map<String, dynamic> toJson() => {
        'paymentId': paymentId,
        'conveyId': conveyId,
        'createdAt': createdAt,
        'seatIds': seatIds,
        'podId': podId,
        'userId': userId,
        'amount': amount,
        'passengerList': passengerList.map((e) => e.toJson()).toList(),
        'id': id,
        "seatNumber": seatNumber
      };
}
