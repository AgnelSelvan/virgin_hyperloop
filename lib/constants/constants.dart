import 'package:custom/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:virgin_hyperloop/enum/seat_status.dart';
import 'package:virgin_hyperloop/models/convey.dart';
import 'package:virgin_hyperloop/services/firebase/train.dart';
import 'dart:ui' as ui;

class Constants {
  static var primaryColor = const Color(0xFFF31111);
  static var primaryMaterialColor =
      const MaterialColor(0xFFF31111, <int, Color>{
    50: Color(0xFFFFEBEE),
    100: Color(0xFFFFCDD2),
    200: Color(0xFFEF9A9A),
    300: Color(0xFFE57373),
    400: Color(0xFFEF5350),
    500: Color(0xFFF31111),
    600: Color(0xFFE53935),
    700: Color(0xFFD32F2F),
    800: Color(0xFFC62828),
    900: Color(0xFFB71C1C),
  });

  static final List<Color> _colorsList = [
    Colors.green[400]!,
    Colors.red[400]!,
    Colors.yellow[400]!,
    Colors.blue[400]!,
    Colors.orange[400]!,
    Colors.purple[400]!,
    Colors.indigo[400]!
  ];

  static Color get getRandomColor {
    _colorsList.shuffle();
    return _colorsList.first;
  }

  static String getInitial(String username) {
    if (username == "") {
      return "";
    }
    if (!username.contains(" ")) {
      return username.split("").first;
    } else {
      final names = username.split(" ");
      final first = names.first.split("").first;
      final last = names.last.split("").first;
      return first == last ? first : "$first$last";
    }
  }

  Future<void> showErrorDialog(
      BuildContext context, String title, String message) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: CustomText(message),
            title: CustomText(title),
            actions: [
              CustomTextButton(
                "Okay",
                onPressed: () => Navigator.pop(context),
              )
            ],
          );
        });
  }

  static Future<void> askYesOrNoDialog(
      BuildContext context, String title, String message, VoidCallback onYesTap,
      {VoidCallback? onNoTap}) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: CustomText(message),
            title: CustomText(title),
            actions: [
              CustomTextButton(
                "Yes",
                backgoundColor: Colors.green[400],
                textColor: Colors.white,
                onPressed: onYesTap,
              ),
              CustomTextButton(
                "No",
                textColor: Colors.white,
                backgoundColor: Colors.red[400],
                onPressed: () {
                  Navigator.pop(context);
                  if (onNoTap != null) {
                    onNoTap();
                  }
                },
              ),
            ],
          );
        });
  }

  Future<void> showLoginDialog(
      BuildContext context, VoidCallback handleLogin) async {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomText(
                  "Login",
                  size: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ],
            ),
            contentPadding: const EdgeInsets.all(20),
            alignment: Alignment.center,
            children: [
              const SizedBox(height: 10),
              CustomText(
                "Please Login in to Continue",
                color: Colors.grey[500],
              ),
              const SizedBox(height: 10),
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  handleLogin();
                },
                child: Image.asset(
                  googleImage,
                  width: 50,
                  height: 50,
                ),
              )
            ],
          );
        });
  }

  static const _assetsDir = "assets/";
  static const _imagesDir = _assetsDir + "images/";
  static const loginImage = _imagesDir + "login.png";
  static const cancelImage = _imagesDir + "cancel.png";
  static const logoImage = _imagesDir + "logo.png";
  static const maskImage = _imagesDir + "mask.jpg";
  static const unauthorizedImage = _imagesDir + "unauthorized.png";
  static const upDownImage = _imagesDir + "up-down.png";
  static const googleImage = _imagesDir + "google.png";

  static SnackBar customSnackBar(
      {required String content, Color? backgroundColor, Color? textColor}) {
    return SnackBar(
      backgroundColor: backgroundColor ?? Colors.green[400],
      content: Text(
        content,
        style: TextStyle(color: textColor ?? Colors.white, letterSpacing: 0.5),
      ),
    );
  }

  static final blackShadow = [
    BoxShadow(
      color: Colors.grey[200]!,
      blurRadius: 10.0,
    ),
  ];

  static String getSeatNumber(List<int> seatMatrix) {
    print("Seat Matrix $seatMatrix");
    var seatReco = "A";
    if (seatMatrix.first == 1) {
      seatReco = "B";
    } else if (seatMatrix.first == 2) {
      seatReco = "C";
    } else if (seatMatrix.first == 3) {
      seatReco = "D";
    }
    return "$seatReco${seatMatrix[1] + 1}";
  }

  Future<List<String>> getJourneyTitleByConveyId(String? conveyId) async {
    if (conveyId != null) {
      final convey = await FirestoreDB().getConveyByConveyId(conveyId);
      return [convey.startPoint, convey.endPoint];
    }
    return ["Mumbai BKC Portal", "Pune"];
  }

  List<String> getJourneyTitleByConvey(ConveyModel conveyModel) {
    return [conveyModel.startPoint, conveyModel.endPoint];
  }

  static const totalPodSeat = 28;
  static const totalPodAvailableSeat = 14;
  static const totalConveySeat = 6 * totalPodSeat;
  static const totalConveyAvailableSeat = 6 * totalPodAvailableSeat;

  double getBookingPercentageByConvey(ConveyModel conveyModel) {
    const totalSeat = totalConveyAvailableSeat;
    int bookedSeat = 0;
    for (var pod in conveyModel.podsList) {
      for (var seat in pod.seatsModelList) {
        if (seat.seatStatus == TrainSeatStatus.booked) {
          bookedSeat += 1;
        }
      }
    }
    return double.parse(((bookedSeat / totalSeat) * 100).toStringAsFixed(2));
  }

  double getBookingPercentageByPod(PodModel podModel) {
    const totalSeat = totalPodAvailableSeat;
    int bookedSeat = 0;
    for (var pod in podModel.seatsModelList) {
      if (pod.seatStatus == TrainSeatStatus.booked) {
        bookedSeat += 1;
      }
    }
    return double.parse(((bookedSeat / totalSeat) * 100).toStringAsFixed(2));
  }
}
