import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:virgin_hyperloop/enum/seat_status.dart';
import 'package:virgin_hyperloop/enum/train.dart';
import 'package:virgin_hyperloop/models/user.dart';
import 'package:virgin_hyperloop/views/booking/booking.dart';

class PodSeatModel {
  final String uid;
  final String seatNumber;
  final DateTime createdAt;
  final String? userId;
  final List<UserModel> passengersList;
  final TrainSeatStatus seatStatus;

  PodSeatModel(
      {required this.seatNumber,
      required this.createdAt,
      required this.uid,
      required this.userId,
      required this.passengersList,
      required this.seatStatus});
  factory PodSeatModel.fromJson(Map<String, dynamic> json) {
    final List pass = json["passengersList"] as List;
    final List<UserModel> passList = [];
    for (final item in pass) {
      passList.add(UserModel.fromJson(item));
    }

    return PodSeatModel(
      uid: json["uid"],
      createdAt: (json["createdAt"] as Timestamp).toDate(),
      seatNumber: json["seatNumber"],
      userId: json["userId"],
      passengersList: passList,
      seatStatus: TrainSeat().getEnumFromStr(json["seatStatus"]),
    );
  }

  Map<String, dynamic> toJson() => {
        'seatNumber': seatNumber,
        'userId': userId,
        'createdAt': createdAt,
        'passengersList': passengersList.map((e) => e.toJson()).toList(),
        'uid': uid,
        'seatStatus': TrainSeat().getTrainSeatEnumToStr(seatStatus)
      };

  PodSeatModel.clone(PodSeatModel randomObject)
      : this(
            seatNumber: randomObject.seatNumber,
            createdAt: randomObject.createdAt,
            uid: randomObject.uid,
            userId: randomObject.userId,
            passengersList: randomObject.passengersList,
            seatStatus: randomObject.seatStatus);
}

class PodModel {
  final String uid;
  final String conveyId;
  final String podNumber;
  final DateTime createdAt;
  List<String> podSeatId = [];
  List<PodSeatModel> seatsModelList = [];

  PodModel(
      {required this.uid,
      required this.conveyId,
      required this.podNumber,
      required this.createdAt,
      required this.podSeatId,
      required this.seatsModelList});

  static PodModel clone(PodModel randomObject) {
    return PodModel(
        uid: randomObject.uid,
        conveyId: randomObject.conveyId,
        podNumber: randomObject.podNumber,
        createdAt: randomObject.createdAt,
        podSeatId: randomObject.podSeatId,
        seatsModelList: randomObject.seatsModelList);
  }

  factory PodModel.fromJson(
      Map<String, dynamic> json, List<PodSeatModel>? seats) {
    return PodModel(
        conveyId: json["conveyId"],
        podNumber: json["podNumber"],
        createdAt: (json["createdAt"] as Timestamp).toDate(),
        podSeatId: (json["podSeatId"] as List).cast<String>(),
        uid: json["uid"],
        seatsModelList: seats ?? []);
  }

  Map<String, dynamic> toJson() => {
        'conveyId': conveyId,
        'podNumber': podNumber,
        'createdAt': createdAt,
        'podSeatId': podSeatId,
        'uid': uid,
      };
}

class ConveyModel {
  final String uid;
  final String trainNumber;
  final int numberOfPods;
  final String platformNumber;
  final DateTime createdAt;
  List<String> conveySeatIdsList;
  final String startPoint;
  final String endPoint;
  final bool isSeatVacant;
  final TrainStatusEnum status;
  List<PodModel> podsList = [];
  Timestamp? startTime = Timestamp.now();
  Timestamp? endTime =
      Timestamp.fromDate(DateTime.now().add(const Duration(hours: 1)));

  ConveyModel(
      {required this.startPoint,
      required this.endPoint,
      required this.trainNumber,
      required this.numberOfPods,
      required this.createdAt,
      required this.conveySeatIdsList,
      required this.platformNumber,
      required this.uid,
      this.status = TrainStatusEnum.initial,
      this.isSeatVacant = true,
      this.startTime,
      this.endTime,
      required this.podsList});

  factory ConveyModel.fromJson(Map<String, dynamic> json) {
    return ConveyModel(
        trainNumber: json["trainNumber"],
        numberOfPods: json["numberOfPods"],
        createdAt: (json["createdAt"] as Timestamp).toDate(),
        conveySeatIdsList: (json["conveySeatIdsList"] as List).cast<String>(),
        uid: json["uid"],
        startPoint: json["startPoint"],
        status: TrainStatus().getEnumFromTrainStatusStr(json["status"]),
        endPoint: json["endPoint"],
        startTime: json["startTime"],
        endTime: json["endTime"],
        isSeatVacant: json["isSeatVacant"],
        podsList: [],
        platformNumber: json["platformNumber"]);
  }

  Map<String, dynamic> toJson() => {
        'trainNumber': trainNumber,
        'numberOfPods': numberOfPods,
        'startTime': startTime,
        'endTime': endTime,
        'createdAt': createdAt,
        'conveySeatIdsList': conveySeatIdsList,
        'startPoint': startPoint,
        'endPoint': endPoint,
        'uid': uid,
        'status': TrainStatus().getStrFromEnum(status),
        'isSeatVacant': isSeatVacant,
        'platformNumber': platformNumber,
      };
}
