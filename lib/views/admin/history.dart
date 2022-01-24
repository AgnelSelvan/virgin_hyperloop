import 'package:custom/custom_text.dart';
import 'package:custom/ftn.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:virgin_hyperloop/constants/constants.dart';
import 'package:virgin_hyperloop/enum/filter.dart';
import 'package:virgin_hyperloop/enum/seat_status.dart';
import 'package:virgin_hyperloop/enum/train.dart';
import 'package:virgin_hyperloop/models/convey.dart';
import 'package:virgin_hyperloop/models/user.dart';
import 'package:virgin_hyperloop/services/firebase/authentication.dart';
import 'package:virgin_hyperloop/services/firebase/train.dart';
import 'package:virgin_hyperloop/views/booking/booking.dart';

class TrainHistory extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  TrainHistory({Key? key}) : super(key: key);

  @override
  _TrainHistoryState createState() => _TrainHistoryState();
}

class _TrainHistoryState extends State<TrainHistory> {
  User? user = Authentication.getCurrentUser;
  List<ConveyModel> conveysList = [];
  bool isLoading = true;

  Future<void> getInitialData() async {
    isLoading = true;
    setState(() {});
    conveysList = await FirestoreDB().getAllTrainHistoryForAdmin();
    isLoading = false;
    setState(() {});
  }

  @override
  void initState() {
    getInitialData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: CustomText(
          "Train History",
          color: Constants.primaryColor,
          size: 16,
        ),
        elevation: 0,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios,
              size: 16,
              color: Colors.grey[700],
            )),
      ),
      body: isLoading
          ? SizedBox(
              width: CustomScreenUtility(context).width,
              height: CustomScreenUtility(context).height,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(),
                ],
              ),
            )
          : Container(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: conveysList
                      .map((e) => ExpansionTile(
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CustomText(
                                      "Train Number : ${e.trainNumber}",
                                      fontWeight: FontWeight.bold,
                                      size: 14,
                                      color: Colors.grey[700],
                                    ),
                                    CustomText(
                                      "${Constants().getJourneyTitleByConvey(e).first} - ${Constants().getJourneyTitleByConvey(e).last}",
                                      color: Colors.grey[600],
                                      size: 12,
                                    )
                                  ],
                                ),
                                Column(
                                  children: [
                                    CustomText(
                                      "${Constants().getBookingPercentageByConvey(e)}",
                                      size: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Constants()
                                                  .getBookingPercentageByConvey(
                                                      e) >
                                              85
                                          ? Colors.green[400]
                                          : Colors.red[400],
                                    ),
                                    CustomText(
                                      "Booking Percentage",
                                      size: 10,
                                      color: Colors.grey[600],
                                    )
                                  ],
                                )
                              ],
                            ),
                            children: [
                              e.status == TrainStatusEnum.initial
                                  ? Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 20),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          CustomTextButton(
                                            "Start Jouney",
                                            onPressed: () async {
                                              if (Constants()
                                                      .getBookingPercentageByConvey(
                                                          e) >=
                                                  85) {
                                                await FirestoreDB()
                                                    .updateTrainStatusTo(
                                                        TrainStatusEnum
                                                            .inJouney,
                                                        e.uid);
                                                await getInitialData();
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(Constants
                                                        .customSnackBar(
                                                            content:
                                                                "Status Updated Successfully"));
                                              } else {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(Constants
                                                        .customSnackBar(
                                                            content:
                                                                "You cannot start the train unitil 85% Seat Occupancy",
                                                            backgroundColor:
                                                                Colors.red));
                                              }
                                            },
                                            textColor: Colors.white,
                                            backgoundColor: Colors.green[400],
                                          ),
                                        ],
                                      ),
                                    )
                                  : e.status == TrainStatusEnum.inJouney
                                      ? Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 20),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              CustomTextButton(
                                                "End Jouney",
                                                onPressed: () async {
                                                  await FirestoreDB()
                                                      .updateTrainStatusTo(
                                                          TrainStatusEnum
                                                              .finshed,
                                                          e.uid);
                                                  await getInitialData();
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(Constants
                                                          .customSnackBar(
                                                              content:
                                                                  "Journey Ended"));
                                                },
                                                textColor: Colors.white,
                                                backgoundColor: Colors.red[400],
                                              ),
                                            ],
                                          ),
                                        )
                                      : Container(),
                              ...e.podsList
                                  .map((p) => ExpansionTile(
                                        title: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            CustomText(
                                              "Pod Number : ${p.podNumber}",
                                              fontWeight: FontWeight.bold,
                                              size: 14,
                                              color: Colors.grey[700],
                                            ),
                                            Row(
                                              children: [
                                                Column(
                                                  children: [
                                                    CustomText(
                                                      "${Constants().getBookingPercentageByPod(p)}",
                                                      size: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Constants()
                                                                  .getBookingPercentageByConvey(
                                                                      e) >
                                                              85
                                                          ? Colors.green[400]
                                                          : Colors.red[400],
                                                    ),
                                                    CustomText(
                                                      "Pod Booking Percentage",
                                                      size: 10,
                                                      color: Colors.grey[600],
                                                    )
                                                  ],
                                                ),
                                                PopupMenuButton<
                                                    TrainHistoryFilterEnum>(
                                                  itemBuilder: (_) => TrainHistoryFilterEnum
                                                      .values
                                                      .map((e) => PopupMenuItem<
                                                              TrainHistoryFilterEnum>(
                                                          child: CustomText(
                                                              TrainHistoryFilterClass()
                                                                  .getStrByEnum(
                                                                      e)),
                                                          value: e))
                                                      .toList(),
                                                  icon: Icon(
                                                    Icons.filter_alt_outlined,
                                                    color: Colors.grey[500],
                                                    size: 16,
                                                  ),
                                                  onSelected:
                                                      (TrainHistoryFilterEnum?
                                                          val) {
                                                    print(val);
                                                    if (val != null) {
                                                      if (val ==
                                                          TrainHistoryFilterEnum
                                                              .filterByStatus) {
                                                        p.seatsModelList.sort((a,
                                                                b) =>
                                                            a.seatStatus ==
                                                                    b.seatStatus
                                                                ? 0
                                                                : 1);
                                                      } else if (val ==
                                                          TrainHistoryFilterEnum
                                                              .filterByNormal) {
                                                        p.seatsModelList.sort(
                                                            (a, b) => a
                                                                .seatNumber
                                                                .compareTo(b
                                                                    .seatNumber));
                                                      }
                                                      setState(() {});
                                                    }
                                                  },
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                        children: p.seatsModelList
                                            .map((s) => Container(
                                                  width: CustomScreenUtility(
                                                              context)
                                                          .width *
                                                      0.85,
                                                  child: s.seatStatus ==
                                                          TrainSeatStatus
                                                              .unavailable
                                                      ? Container(
                                                          height: 50,
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  left: 15),
                                                          child: Row(
                                                            children: [
                                                              const Icon(
                                                                Icons.dangerous,
                                                                color:
                                                                    Colors.red,
                                                              ),
                                                              const SizedBox(
                                                                  width: 10),
                                                              CustomText(
                                                                  s.seatNumber),
                                                              const SizedBox(
                                                                  width: 20),
                                                              CustomText(
                                                                "Seat Unavailable",
                                                                color: Colors
                                                                    .grey[400],
                                                              ),
                                                            ],
                                                          ))
                                                      : ExpansionTile(
                                                          title: Row(
                                                            children: [
                                                              Icon(
                                                                s.seatStatus ==
                                                                        TrainSeatStatus
                                                                            .booked
                                                                    ? Icons
                                                                        .check_circle
                                                                    : Icons
                                                                        .event_available,
                                                                color: s.seatStatus ==
                                                                        TrainSeatStatus
                                                                            .booked
                                                                    ? Colors
                                                                        .green
                                                                    : Colors
                                                                        .blue,
                                                              ),
                                                              const SizedBox(
                                                                  width: 10),
                                                              CustomText(
                                                                  s.seatNumber),
                                                              const SizedBox(
                                                                  width: 20),
                                                              CustomText(
                                                                s.seatStatus ==
                                                                        TrainSeatStatus
                                                                            .booked
                                                                    ? "Seat Booked"
                                                                    : "Seat Available",
                                                                color: Colors
                                                                    .grey[400],
                                                              ),
                                                            ],
                                                          ),
                                                          childrenPadding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  vertical: 15),
                                                          children: [
                                                            s.userId != null
                                                                ? FutureBuilder<
                                                                        UserModel?>(
                                                                    future: Authentication
                                                                        .getMyData(s
                                                                            .userId!),
                                                                    builder:
                                                                        (context,
                                                                            snapshot) {
                                                                      if (snapshot
                                                                              .data !=
                                                                          null) {
                                                                        return BuildPassengerTile(
                                                                            userModel:
                                                                                snapshot.data!);
                                                                      }
                                                                      return Container();
                                                                    })
                                                                : Container(),
                                                            CustomText(
                                                                "No. of Passengers: ${s.passengersList.length}")
                                                          ],
                                                        ),
                                                ))
                                            .toList(),
                                      ))
                                  .toList(),
                            ],
                          ))
                      .toList(),
                ),
              ),
            ),
    );
  }
}
