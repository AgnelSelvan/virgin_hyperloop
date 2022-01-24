import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:virgin_hyperloop/constants/constants.dart';
import 'package:virgin_hyperloop/enum/seat_status.dart';
import 'package:virgin_hyperloop/enum/train.dart';
import 'package:virgin_hyperloop/models/booking.dart';
import 'package:virgin_hyperloop/models/convey.dart';
import 'package:virgin_hyperloop/models/payment.dart';
import 'package:virgin_hyperloop/models/user.dart';

class FirestoreDB {
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  static final _conveysCollection = firestore.collection("conveys");
  static final _paymentsCollection = firestore.collection("payments");
  static final _bookedTicketsCollection = firestore.collection("booked_ticket");

  static Future<void> addConveyToDB(ConveyModel conveyModel) async {
    List<String> podIds = [];
    for (var pod = 0; pod < conveyModel.numberOfPods; pod++) {
      final podModel = PodModel(
          podSeatId: [],
          uid: FirestoreDB.getUID,
          conveyId: conveyModel.uid,
          podNumber: "${pod + 1}",
          createdAt: DateTime.now(),
          seatsModelList: []);
      List<String> podSeatIds = [];
      for (var i = 0; i < 7; i++) {
        for (var index = 0; index < 4; index++) {
          PodSeatModel? podSeatModel;
          if (i % 2 == 0) {
            if (int.parse("$index") % 2 == 1) {
              //Unavailable
              podSeatModel = PodSeatModel(
                  seatNumber: Constants.getSeatNumber([index, i]),
                  createdAt: DateTime.now(),
                  uid: FirestoreDB.getUID,
                  userId: null,
                  passengersList: [],
                  seatStatus: TrainSeatStatus.unavailable);
            } else {
              // "Available"
              podSeatModel = PodSeatModel(
                  seatNumber: Constants.getSeatNumber([index, i]),
                  createdAt: DateTime.now(),
                  uid: FirestoreDB.getUID,
                  userId: null,
                  passengersList: [],
                  seatStatus: TrainSeatStatus.available);
            }
          } else {
            if (int.parse("$index") % 2 == 1) {
              //Available
              podSeatModel = PodSeatModel(
                  seatNumber: Constants.getSeatNumber([index, i]),
                  createdAt: DateTime.now(),
                  uid: FirestoreDB.getUID,
                  userId: null,
                  passengersList: [],
                  seatStatus: TrainSeatStatus.available);
            } else {
              //Unavailable
              podSeatModel = PodSeatModel(
                  seatNumber: Constants.getSeatNumber([index, i]),
                  createdAt: DateTime.now(),
                  uid: FirestoreDB.getUID,
                  userId: null,
                  passengersList: [],
                  seatStatus: TrainSeatStatus.unavailable);
            }
          }
          print(i);
          print(
              "PodNymber: ${pod + 1} Seat Number: ${podSeatModel.seatNumber}");
          podSeatIds.add(podSeatModel.uid);
          await _conveysCollection
              .doc(conveyModel.uid)
              .collection("pods")
              .doc(podModel.uid)
              .collection("podSeat")
              .add(podSeatModel.toJson());
        }
      }
      podModel.podSeatId = podSeatIds;
      podIds.add(podModel.uid);
      _conveysCollection
          .doc(conveyModel.uid)
          .collection("pods")
          .doc(podModel.uid)
          .set(podModel.toJson());
    }
    conveyModel.conveySeatIdsList = podIds;
    await _conveysCollection.doc(conveyModel.uid).set(conveyModel.toJson());
  }

  static Future<ConveyModel?> getConveyForBookingTicket(
      String startPoint, String endPoint) async {
    final querySnap = await _conveysCollection
        .where("isSeatVacant", isEqualTo: true)
        .where("startPoint", isEqualTo: startPoint)
        .where("endPoint", isEqualTo: endPoint)
        .where("startTime", isGreaterThan: Timestamp.now())
        .orderBy('startTime', descending: false)
        .get();
    final doc = querySnap.docs.first;
    try {
      debugPrint("Model : ${ConveyModel.fromJson(doc.data())}");

      return ConveyModel.fromJson(doc.data());
    } catch (e) {
      debugPrint("Error $e");
      return null;
    }
  }

  static Future<ConveyModel?> getLastConvey() async {
    final querySnap =
        await _conveysCollection.orderBy('createdAt', descending: false).get();
    final doc = querySnap.docs.last;
    try {
      debugPrint("Model : ${ConveyModel.fromJson(doc.data())}");
      return ConveyModel.fromJson(doc.data());
    } catch (e) {
      debugPrint("Error $e");
      return null;
    }
  }

  static String get getUID {
    return _conveysCollection.doc().id;
  }

  static Future<PodModel> getPodbyPodId(String cid, String pid) async {
    final doc =
        await _conveysCollection.doc(cid).collection("pods").doc(pid).get();

    final qDocs = await _conveysCollection
        .doc(cid)
        .collection("pods")
        .doc(pid)
        .collection("podSeat")
        .where("seatStatus",
            isEqualTo:
                TrainSeat().getTrainSeatEnumToStr(TrainSeatStatus.available))
        .orderBy("createdAt", descending: false)
        .get();

    List<PodSeatModel> datas =
        qDocs.docs.map((e) => PodSeatModel.fromJson(e.data())).toList();
    return PodModel.fromJson(doc.data() as Map<String, dynamic>, datas);
  }

  static Future<PodModel> getNextPod(String conveyId, String podId) async {
    final qDocs = await _conveysCollection
        .doc(conveyId)
        .collection("pods")
        .orderBy("createdAt")
        .get();
    final value =
        qDocs.docs.map((e) => PodModel.fromJson(e.data(), null)).toList();
    final matchData = value.where((element) => element.uid == podId).toList();
    final index = value.indexOf(matchData.first);
    return value[index + 1];
  }

  static Future<QuerySnapshot> getSeatForVacant(
      String conveyId, String podId) async {
    return await _conveysCollection
        .doc(conveyId)
        .collection("pods")
        .doc(podId)
        .collection("podSeat")
        .where("seatStatus",
            isEqualTo:
                TrainSeat().getTrainSeatEnumToStr(TrainSeatStatus.available))
        .orderBy("createdAt", descending: false)
        .get();
  }

  static Future<PodModel> getVacantSeatByConveyId(
      String conveyId, String podId, int numOfSeats) async {
    final qDocs = await getSeatForVacant(conveyId, podId);
    if (qDocs.docs.length >= numOfSeats) {
      final pod = await getPodbyPodId(conveyId, podId);
      debugPrint("PodsLists = ${pod.seatsModelList.length} $numOfSeats");
      return pod;
    } else {
      final pod = await getNextPod(conveyId, podId);
      // await getSeatForVacant(conveyId, pod.uid);
      return getPodbyPodId(conveyId, pod.uid);
    }
  }

  Future<List<PodModel>> getPodsByConveyId(
      int numberOfPassenger, String conveyId) async {
    final qDocs = await _conveysCollection
        .doc(conveyId)
        .collection("pods")
        .orderBy("createdAt", descending: false)
        .get();
    List<PodModel> datas = [];
    for (final item in qDocs.docs) {
      datas.add(PodModel.fromJson(item.data(), null));
    }

    return datas;
  }

  Future<void> updatePodSeatStatus(
      TrainSeatStatus trainSeatStatus,
      String podId,
      String conveyId,
      List<String> seatIds,
      List<UserModel> passengerList,
      String userId) async {
    for (var seatId in seatIds) {
      print("ConveyID: $conveyId, PODID: $podId, seatID: $seatId");

      final docs = await _conveysCollection
          .doc(conveyId)
          .collection("pods")
          .doc(podId)
          .collection("podSeat")
          .where("uid", isEqualTo: seatId)
          .get();
      if (docs.docs.isNotEmpty) {
        await _conveysCollection
            .doc(conveyId)
            .collection("pods")
            .doc(podId)
            .collection("podSeat")
            .doc(docs.docs.first.id)
            .update({
          "seatStatus": TrainSeat().getTrainSeatEnumToStr(trainSeatStatus),
          "userId": userId,
          "passengersList": passengerList.map((e) => e.toJson()).toList()
        });
      }
    }
  }

  Future<String> addBookedSeatToDB(
      List<UserModel> passengersList,
      String userId,
      String paymentId,
      String conveyId,
      String podId,
      List<String> seatIds,
      String seatNumber,
      double amount) async {
    final ticketID = FirestoreDB.getUID;
    final bookedTicketModel = BookedTicketModel(
        paymentId: paymentId,
        conveyId: conveyId,
        podId: podId,
        passengerList: passengersList,
        seatIds: seatIds,
        amount: amount,
        userId: userId,
        id: ticketID,
        createdAt: Timestamp.now(),
        seatNumber: seatNumber);

    final payment = PaymentModel(
        paymentId: paymentId,
        id: FirestoreDB.getUID,
        bookingId: bookedTicketModel.id,
        amount: amount,
        userId: userId,
        createdAt: Timestamp.now());
    await _bookedTicketsCollection
        .doc(bookedTicketModel.id)
        .set(bookedTicketModel.toJson());
    await _paymentsCollection.doc(payment.id).set(payment.toJson());
    await updatePodSeatStatus(TrainSeatStatus.booked, podId, conveyId, seatIds,
        passengersList, userId);
    return bookedTicketModel.id;
  }

  Future<BookedTicketModel> getBookedTicketByID(String bid) async {
    final doc = await _bookedTicketsCollection.doc(bid).get();
    return BookedTicketModel.fromJson(doc.data() as Map<String, dynamic>);
  }

  Future<List<BookedTicketModel>> getBookingHistory(String userId) async {
    final qDocs = await _bookedTicketsCollection.get();
    List<BookedTicketModel> datas = [];
    for (final doc in qDocs.docs) {
      final model = BookedTicketModel.fromJson(doc.data());
      if (model.userId == userId) {
        datas.add(model);
      }
    }
    return datas;
  }

  Future<ConveyModel> getConveyByConveyId(String conveyId) async {
    final doc = await _conveysCollection.doc(conveyId).get();
    return ConveyModel.fromJson(doc.data() as Map<String, dynamic>);
  }

  Future<List<ConveyModel>> getAllTrainHistoryForAdmin() async {
    List<ConveyModel> conveysData = [];
    final qDocs = await _conveysCollection.get();
    for (final doc in qDocs.docs) {
      ConveyModel conveyModel = ConveyModel.fromJson(doc.data());
      final pDocs = await _conveysCollection
          .doc(conveyModel.uid)
          .collection("pods")
          .get();
      for (var pDoc in pDocs.docs) {
        PodModel podModel = PodModel.fromJson(pDoc.data(), []);
        final sDocs = await _conveysCollection
            .doc(conveyModel.uid)
            .collection("pods")
            .doc(podModel.uid)
            .collection("podSeat")
            .get();
        for (var sDoc in sDocs.docs) {
          podModel.seatsModelList.add(PodSeatModel.fromJson(sDoc.data()));
        }
        podModel.seatsModelList
            .sort((a, b) => a.seatNumber.compareTo(b.seatNumber));
        conveyModel.podsList.add(podModel);
        conveyModel.podsList.sort(
            (a, b) => int.parse(a.podNumber).compareTo(int.parse(b.podNumber)));
      }
      conveysData.add(conveyModel);
    }
    return conveysData;
  }

  Future<void> updateTrainStatusTo(
      TrainStatusEnum trainStatusEnum, String conveyId) async {
    await _conveysCollection
        .doc(conveyId)
        .update({"status": TrainStatus().getStrFromEnum(trainStatusEnum)});
  }
}
