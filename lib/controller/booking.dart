import 'package:flutter/material.dart';
import 'package:virgin_hyperloop/constants/constants.dart';
import 'package:virgin_hyperloop/enum/seat_status.dart';
import 'package:virgin_hyperloop/models/booking.dart';
import 'package:virgin_hyperloop/models/convey.dart';
import 'package:virgin_hyperloop/models/user.dart';
import 'package:virgin_hyperloop/services/firebase/authentication.dart';
import 'package:virgin_hyperloop/services/firebase/train.dart';
import 'package:virgin_hyperloop/views/booking/booking.dart';
import 'package:virgin_hyperloop/views/status/status.dart';

class BookingController with ChangeNotifier {
  List<BookingSeatModel> _selectedBookingSeat = [];
  List<BookingSeatModel> get selectedBookingSeat => _selectedBookingSeat;
  set addToSelectedBooking(BookingSeatModel bookingSeatModel) {
    _selectedBookingSeat.add(bookingSeatModel);
    debugPrint("$_selectedBookingSeat");
    notifyListeners();
  }

  void generateSeatNumber(List<int> seatMatrix) {
    var seatReco = "A";
    var gate = 1;
    if (seatMatrix[1] == 2) {
      seatReco = "B";
    } else if (seatMatrix[1] == 3) {
      seatReco = "C";
      gate = 2;
    } else if (seatMatrix[1] == 4) {
      seatReco = "D";
      gate = 2;
    }
    final seatNumber = "Gate$gate / $seatReco${seatMatrix[1] + 1}";
    debugPrint(seatNumber);
    debugPrint("$seatMatrix");
    final val = _selectedBookingSeat.where((e) {
      print(e.seatMatric);
      return e.seatMatric[0] == seatMatrix[0] &&
          e.seatMatric[1] == seatMatrix[1];
    }).toList();
    print(val);
    if (val.isEmpty) {
      final model = BookingSeatModel(
          uid: FirestoreDB.getUID,
          seatNumber: seatNumber,
          seatMatric: seatMatrix,
          trainSeatStatus: TrainSeatStatus.booked);
      addToSelectedBooking = model;
    }
  }

  final passengerController = TextEditingController(text: "1");
  void increasePassengerCount() {
    try {
      final count = int.parse(passengerController.text);
      passengerController.text = "${count + 1}";
    } catch (e) {
      passengerController.text = "1";
    }
    updatePrice();
    notifyListeners();
  }

  void decreasePassengerCount() {
    try {
      final count = int.parse(passengerController.text);
      passengerController.text = "${count - 1}";
    } catch (e) {
      passengerController.text = "1";
    }
    updatePrice();
    notifyListeners();
  }

  double price = 99;
  void updatePrice() {
    price = 0;
    final count = int.parse(passengerController.text);
    price = 99.0 * count;
  }

  List<UserModel> _passengersList = [];
  List<UserModel> get passengersList => _passengersList;
  set addPassenger(UserModel userModel) {
    _passengersList.add(userModel);
    notifyListeners();
  }

  set removePassenger(UserModel userModel) {
    _passengersList.remove(userModel);
    notifyListeners();
  }

  List<String> gatesList = [];
  String currentSelectedGate = "";

  ConveyModel? _latestConvey;
  ConveyModel? get latestConvey => _latestConvey;
  set setLatestConvey(ConveyModel? conveyModel) {
    _latestConvey = conveyModel;
    if (_latestConvey != null) {
      gatesList = List.generate(_latestConvey?.numberOfPods ?? 0,
          (index) => "Gate ${_latestConvey?.trainNumber}${index + 1}").toList();
      currentSelectedGate = gatesList.first;
    }
    notifyListeners();
  }

  void onGateTap(int btnInt) {
    if (btnInt == 0) {
      if (gatesList.contains(currentSelectedGate)) {
        if ((gatesList.indexOf(currentSelectedGate) + 1) > 1) {
          currentSelectedGate =
              gatesList[gatesList.indexOf(currentSelectedGate) - 1];
        }
        print("currentSelectedGate: $currentSelectedGate");
        notifyListeners();
        return;
      }
    } else {
      if (gatesList.contains(currentSelectedGate)) {
        if ((gatesList.indexOf(currentSelectedGate) + 1) < gatesList.length) {
          currentSelectedGate =
              gatesList[gatesList.indexOf(currentSelectedGate) + 1];
        }
        print("currentSelectedGate: $currentSelectedGate");
        notifyListeners();
        return;
      }
    }
    throw "Something went wrong!";
  }

  bool isFetched = false;
  Future<ConveyModel?> getConveyInfo(String startPoint, String endPoint) async {
    if (!isFetched) {
      setLatestConvey =
          await FirestoreDB.getConveyForBookingTicket(startPoint, endPoint);
      if (_latestConvey != null) {
        isFetched = true;
      }
      return _latestConvey;
    }
  }

  Future<PodModel?> vacantLastSeatNumber(List<PodModel> podsList) async {
    if (_latestConvey != null) {
      for (var pod in podsList) {
        final podModel = await FirestoreDB.getVacantSeatByConveyId(
            _latestConvey!.uid, pod.uid, int.parse(passengerController.text));
        return podModel;
      }
    }
    return null;
  }

  // Future<PodModel> getCurrentSeatNumber(BuildContext context) async {
  //   PodModel datas;
  //   await getConveyInfo();
  //   if (_latestConvey != null) {
  //     final podsList = await FirestoreDB().getPodsByConveyId(
  //         int.parse(passengerController.text), _latestConvey!.uid);
  //     final seatsList = await vacantLastSeatNumber(podsList);
  //     // debugPrint("LIST: ${seatsList.length}");
  //     datas = seatsList;
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(Constants.customSnackBar(
  //         content:
  //             "Convey not added, We will notify once the convey is added"));
  //   }
  //   return datas;
  // }

  PodModel? _currentSelectedSeats;
  PodModel? get currentSelectedSeats => _currentSelectedSeats;
  set setCurrentSelectedSeats(PodModel? datas) {
    _currentSelectedSeats = datas;
  }

  List<String> getSeatsFromCurrentSelectedSeats() {
    return _currentSelectedSeats?.seatsModelList
            .map((e) =>
                "Gate ${_latestConvey?.trainNumber}${_currentSelectedSeats?.podNumber} / ${e.seatNumber}")
            .toList() ??
        [""];
  }

  getSeatNumberList(BuildContext context) {
    // Get Avaible Pod Seats
    // Check if pod Seat is equal to passenger Length
    // If Equal the give the String
    // else check in the Next POD
  }

  Future<List<String>> getSeatNumbersList(BuildContext context) async {
    if (_latestConvey != null) {
      final podsList = await FirestoreDB().getPodsByConveyId(
          int.parse(passengerController.text), _latestConvey!.uid);
      setCurrentSelectedSeats = await vacantLastSeatNumber(podsList);
      if (_currentSelectedSeats != null) {
        List<String> strList = [];

        for (var item in _currentSelectedSeats!.seatsModelList) {
          // debugPrint("${podModel.seatsModelList.length}");
          if (strList.length >= int.parse(passengerController.text)) {
            break;
          }

          strList.add(
              "Gate ${_latestConvey?.trainNumber}${_currentSelectedSeats!.podNumber} / ${item.seatNumber}");
        }

        return strList;
      }
    }
    return [];
  }

  Future<void> onPaymentSuccess(
      BuildContext context, String paymentId, double amount) async {
    print(
        "Hello ${currentSelectedSeats!.seatsModelList.take(int.parse(passengerController.text)).map((e) => e.uid).toList()}");
    // try {
    final bokkingId = await FirestoreDB().addBookedSeatToDB(
        passengersList,
        Authentication.getCurrentUser!.uid,
        paymentId,
        _latestConvey!.uid,
        _currentSelectedSeats!.uid,
        _currentSelectedSeats!.seatsModelList
            .take(int.parse(passengerController.text))
            .map((e) => e.uid)
            .toList(),
        _currentSelectedSeats!.seatsModelList
            .map((e) =>
                "Gate ${_latestConvey?.trainNumber}${_currentSelectedSeats?.podNumber} / ${e.seatNumber}")
            .toList()
            .take(int.parse(passengerController.text))
            .join(","),
        amount);
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => StatusScreen(
                  bookedTicketID: bokkingId,
                )));
    // } catch (e) {
    //   ScaffoldMessenger.of(context).showSnackBar(Constants.customSnackBar(
    //       content: "Error $e", backgroundColor: Colors.red));
    // }
  }
}
