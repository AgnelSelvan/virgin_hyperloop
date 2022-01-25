import 'dart:math';

import 'package:custom/custom_text.dart';
import 'package:custom/ftn.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:virgin_hyperloop/constants/constants.dart';
import 'package:virgin_hyperloop/controller/train.dart';
import 'package:virgin_hyperloop/enum/station.dart';
import 'package:virgin_hyperloop/views/booking/booking.dart';

class AddTrain extends StatefulWidget {
  AddTrain({Key? key}) : super(key: key);

  @override
  _AddTrainState createState() => _AddTrainState();
}

// Convoy

class _AddTrainState extends State<AddTrain> {
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now().add(const Duration(hours: 1));

  Future<void> _selectTime(BuildContext context, String val) async {
    DateTime initialTime = DateTime.now();
    final pickedDate = await showDatePicker(
        context: context,
        initialDate: initialTime,
        firstDate: DateTime.now(),
        lastDate: initialTime.add(const Duration(days: 365)));
    if (pickedDate != null) {
      if (val == "s") {
        startDate = pickedDate;
      } else {
        endDate = pickedDate;
      }
    }
    setState(() {});
    final pickedTime = await showTimePicker(
        context: context,
        initialTime:
            TimeOfDay(hour: initialTime.hour, minute: initialTime.minute));
    if (pickedTime != null) {
      if (val == "s") {
        startDate = DateTime(startDate.year, startDate.month, startDate.day,
            pickedTime.hour, pickedTime.minute);
      } else {
        endDate = DateTime(endDate.year, endDate.month, endDate.day,
            pickedTime.hour, pickedTime.minute);
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: CustomText(
          "Add Convey",
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
      body: ChangeNotifierProvider<TrainController>(
        create: (context) => TrainController(),
        child: Consumer<TrainController>(builder: (context, trainModel, child) {
          return Container(
              alignment: Alignment.topCenter,
              child: Column(
                children: [
                  Container(
                      margin: const EdgeInsets.all(15),
                      width: CustomScreenUtility(context).width * 0.8,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          boxShadow: Constants.blackShadow,
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.white),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 15,
                          ),
                          CustomText(
                            "Add",
                            size: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Container(
                                width: 150,
                                child: CustomTF(
                                  controller: trainModel.trainNumberController,
                                  hintText: "Enter Train No",
                                ),
                              ),
                              IconButton(
                                  onPressed: () {
                                    trainModel.updateTrainNumber();
                                  },
                                  icon: const Icon(Icons.refresh))
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          DropdownButton<String>(
                              items: trainModel.platform
                                  .map((e) => DropdownMenuItem<String>(
                                      value: "$e", child: CustomText("$e")))
                                  .toList(),
                              hint: const CustomText("Select A Platform"),
                              value: trainModel.selectedPlatform,
                              onChanged: (String? val) {
                                trainModel.setSelectedPlatform = val;
                              }),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              DropdownButton<StationEnum>(
                                  value: trainModel.startStation,
                                  hint: const CustomText("Starting Station"),
                                  items: StationEnum.values
                                      .map((e) => DropdownMenuItem<StationEnum>(
                                          value: e,
                                          child: CustomText(Station()
                                              .getStationEnumToStr(e))))
                                      .toList(),
                                  onChanged: (StationEnum? val) {
                                    try {
                                      trainModel.setStartStation = val;
                                    } catch (e) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                              Constants.customSnackBar(
                                                  content: "$e",
                                                  backgroundColor: Colors.red));
                                    }
                                  }),
                              InkWell(
                                onTap: trainModel.reverseStationPoint,
                                child: RotatedBox(
                                  quarterTurns: 1,
                                  child: Container(
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                          color: Colors.grey[800],
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            Constants.upDownImage,
                                            width: 15,
                                          ),
                                        ],
                                      )),
                                ),
                              ),
                              DropdownButton<StationEnum>(
                                  value: trainModel.destinationStation,
                                  hint: const CustomText("Ending Station"),
                                  items: StationEnum.values
                                      .map((e) => DropdownMenuItem<StationEnum>(
                                          value: e,
                                          child: CustomText(Station()
                                              .getStationEnumToStr(e))))
                                      .toList(),
                                  onChanged: (StationEnum? val) {
                                    try {
                                      trainModel.setDestinationStation = val;
                                    } catch (e) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                              Constants.customSnackBar(
                                                  content: "$e",
                                                  backgroundColor: Colors.red));
                                    }
                                  }),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              BuildTimeContainer(
                                dateTime: startDate,
                                onTap: () {
                                  _selectTime(context, "s");
                                },
                                message: "Departure Time",
                              ),
                              BuildTimeContainer(
                                dateTime: endDate,
                                bgColor: Colors.yellow[100],
                                onTap: () {
                                  _selectTime(context, "e");
                                },
                                message: "Arrival Time",
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          CustomTextButton(
                            "Add",
                            onPressed: () async {
                              await trainModel.addConveyToDB(
                                  context, startDate, endDate);
                            },
                          ),
                        ],
                      )),
                ],
              ));
        }),
      ),
    );
  }
}

class BuildTimeContainer extends StatelessWidget {
  const BuildTimeContainer(
      {Key? key,
      required this.dateTime,
      this.bgColor,
      this.onTap,
      this.message})
      : super(key: key);

  final DateTime dateTime;
  final Color? bgColor;
  final VoidCallback? onTap;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final time = DateFormat('hh:mm a').format(dateTime);
    final date = DateFormat('EEE,dd MMM').format(dateTime);
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
            decoration: BoxDecoration(
                color: bgColor ?? Colors.green[100],
                borderRadius: BorderRadius.circular(3)),
            child: CustomText(
              "$date \n $time",
              color: Colors.grey[700],
            ),
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        message == null
            ? Container()
            : CustomText(
                message!,
                size: 10,
                color: Colors.grey[400],
              )
      ],
    );
  }
}
