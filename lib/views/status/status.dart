import 'dart:io';
import 'dart:typed_data';

import 'package:custom/custom_text.dart';
import 'package:custom/ftn.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:syncfusion_flutter_barcodes/barcodes.dart';
import 'package:virgin_hyperloop/constants/constants.dart';
import 'package:virgin_hyperloop/enum/train.dart';
import 'package:virgin_hyperloop/models/convey.dart';
import 'package:virgin_hyperloop/models/payment.dart';
import 'package:virgin_hyperloop/models/user.dart';
import 'package:virgin_hyperloop/services/firebase/authentication.dart';
import 'package:virgin_hyperloop/services/firebase/train.dart';
import 'package:virgin_hyperloop/views/admin/add/train.dart';
import 'package:virgin_hyperloop/views/booking/booking.dart';

class StatusScreen extends StatefulWidget {
  final String bookedTicketID;
  const StatusScreen({Key? key, required this.bookedTicketID})
      : super(key: key);

  @override
  _StatusScreenState createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  bool isLoading = true;
  BookedTicketModel? bookedTicketModel;
  UserModel? userModel;
  ScreenshotController screenshotController = ScreenshotController();

  getData() async {
    isLoading = true;
    setState(() {});
    try {
      bookedTicketModel =
          await FirestoreDB().getBookedTicketByID(widget.bookedTicketID);
      if (bookedTicketModel != null) {
        userModel = await Authentication.getMyData(bookedTicketModel!.userId);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(Constants.customSnackBar(
          content: 'Failed to get ticket status.',
          backgroundColor: Colors.red));
    }
    isLoading = false;
    setState(() {});
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
              onPressed: () async {
                final image = await screenshotController.capture();
                if (image == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      Constants.customSnackBar(
                          content: "Something went wrong!",
                          backgroundColor: Colors.red[400]));
                  return;
                }
                await Share.file('Booked Ticket', 'ticket.png',
                    image.buffer.asUint8List(), 'image/png',
                    text:
                        'Full Name:${userModel?.username}\nSeat Number:${"${bookedTicketModel?.seatNumber}"}');
              },
              icon: Icon(
                Icons.share,
                size: 18,
                color: Colors.grey[700],
              ))
        ],
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios,
              size: 18,
              color: Colors.grey[700],
            )),
        centerTitle: true,
        title: CustomText(
          bookedTicketModel == null
              ? "Booking Status"
              : "${bookedTicketModel?.id}".toUpperCase(),
          size: 20,
          fontWeight: FontWeight.w500,
          color: Colors.grey[600],
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: SizedBox(
          width: CustomScreenUtility(context).width,
          child: isLoading
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator()),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      width: CustomScreenUtility(context).width * 0.8,
                      decoration: BoxDecoration(
                          color: Constants.primaryColor,
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.all(20),
                      child: Screenshot(
                        controller: screenshotController,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10)),
                          child: Column(
                            children: [
                              Table(
                                children: [
                                  TableRow(children: [
                                    CustomText(
                                      "Full Name",
                                      color: Colors.grey[400],
                                      fontWeight: FontWeight.bold,
                                      size: 16,
                                    ),
                                    CustomText(
                                      "Seat Place",
                                      color: Colors.grey[400],
                                      fontWeight: FontWeight.bold,
                                      size: 16,
                                    )
                                  ]),
                                  TableRow(children: [
                                    CustomText(
                                      "${userModel?.username}",
                                      color: Colors.grey[800],
                                      size: 16,
                                    ),
                                    CustomText(
                                      "${bookedTicketModel?.seatNumber}",
                                      color: Colors.grey[800],
                                      size: 16,
                                    )
                                  ]),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Divider(
                                color: Constants.primaryColor,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Container(
                                height: 80,
                                child: SfBarcodeGenerator(
                                  value: '${bookedTicketModel?.id}',
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              CustomText(
                                "Booking Code ${bookedTicketModel?.id}",
                                color: Colors.grey[600],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    bookedTicketModel == null
                        ? Container()
                        : FutureBuilder<ConveyModel>(
                            future: FirestoreDB().getConveyByConveyId(
                                bookedTicketModel!.conveyId),
                            builder: (context, snapshot) {
                              if (snapshot.data == null) {
                                return Container();
                              }

                              return Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      BuildTimeContainer(
                                        dateTime:
                                            snapshot.data!.startTime!.toDate(),
                                        message: "Departure Time",
                                      ),
                                      BuildTimeContainer(
                                        dateTime:
                                            snapshot.data!.endTime!.toDate(),
                                        message: "Arrival Time",
                                        bgColor: Colors.yellow[100],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  CustomText(
                                    // ignore: unrelated_type_equality_checks
                                    "POD " +
                                        (snapshot.data!.status ==
                                                TrainStatusEnum.initial
                                            ? "is"
                                            : "was") +
                                        " on Platform : ${snapshot.data?.platformNumber}",
                                    fontWeight: FontWeight.bold,
                                  ),
                                ],
                              );
                            }),
                    const SizedBox(
                      height: 20,
                    ),
                    bookedTicketModel == null
                        ? Container()
                        : Container(
                            width: CustomScreenUtility(context).width * 0.8,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomText(
                                  "Passengers List",
                                  color: Colors.grey[700]!,
                                  size: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                ...bookedTicketModel!.passengerList
                                    .map((e) => BuildPassengerTile(
                                          userModel: e,
                                          onRemoveTap: null,
                                        ))
                                    .toList()
                              ],
                            ),
                          ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      width: CustomScreenUtility(context).width * 0.8,
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: CustomText(
                            "Train Itenerary",
                            color: Colors.grey[700]!,
                            size: 16,
                            fontWeight: FontWeight.bold,
                          )),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      width: CustomScreenUtility(context).width * 0.8,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.grey[400]!,
                          )),
                      padding: const EdgeInsets.all(10),
                      child: Theme(
                        data: Theme.of(context)
                            .copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          title: CustomText(
                            "Train Journey",
                            color: Colors.grey[800],
                            size: 16,
                          ),
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 20),
                              height: 160,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      BuidFormattedDateTime(
                                          dateTime: DateTime.now()),
                                      BuidFormattedDateTime(
                                          dateTime: DateTime.now()),
                                    ],
                                  ),
                                  Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Constants.primaryColor),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                      ),
                                      Container(
                                        width: 0.4,
                                        height: 90,
                                        color: Colors.red,
                                      ),
                                      Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            color: Constants.primaryColor),
                                      ),
                                    ],
                                  ),
                                  FutureBuilder<List<String>?>(
                                      future: Constants()
                                          .getJourneyTitleByConveyId(
                                              bookedTicketModel?.conveyId),
                                      builder: (context, snapshot) {
                                        if (!snapshot.hasData) {
                                          return Container();
                                        }
                                        if (snapshot.hasError) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                                  Constants.customSnackBar(
                                                      content:
                                                          "${snapshot.error}"));
                                          return Container();
                                        }
                                        return Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            BuidLocation(
                                                location:
                                                    "${snapshot.data?.first}"),
                                            BuidLocation(
                                                location:
                                                    "${snapshot.data?.last}"),
                                          ],
                                        );
                                      }),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 60,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class BuidLocation extends StatelessWidget {
  final String location;
  const BuidLocation({Key? key, required this.location}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomText(
          location,
          size: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey[800],
        ),
        CustomText(
          "Portal",
          size: 16,
          color: Colors.grey[600],
        ),
      ],
    );
  }
}

class BuidFormattedDateTime extends StatelessWidget {
  final DateTime dateTime;
  const BuidFormattedDateTime({Key? key, required this.dateTime})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final time = DateFormat('hh:mm a').format(dateTime);
    final date = DateFormat('EEE,dd MMM').format(dateTime);
    return Column(
      children: [
        CustomText(
          time,
          size: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey[800],
        ),
        CustomText(
          date,
          size: 16,
          color: Colors.grey[600],
        ),
      ],
    );
  }
}

class VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => RotatedBox(
        quarterTurns: 1,
        child: Divider(),
      );
}
