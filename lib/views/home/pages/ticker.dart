import 'dart:async';

import 'package:custom/custom_text.dart';
import 'package:custom/ftn.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:virgin_hyperloop/constants/constants.dart';
import 'package:virgin_hyperloop/models/payment.dart';
import 'package:virgin_hyperloop/services/firebase/authentication.dart';
import 'package:virgin_hyperloop/services/firebase/train.dart';
import 'package:virgin_hyperloop/views/status/status.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class TicketHistoryScreen extends StatefulWidget {
  const TicketHistoryScreen({Key? key}) : super(key: key);

  @override
  _TicketScreenState createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketHistoryScreen> {
  List<BookedTicketModel> bookedTicketHistory = [];
  getInitialData() async {
    final user = Authentication.getCurrentUser;
    if (user != null) {
      bookedTicketHistory = await FirestoreDB().getBookingHistory(user.uid);
      setState(() {});
    } else {
      Timer(Duration.zero, () {
        ScaffoldMessenger.of(context).showSnackBar(Constants.customSnackBar(
            content: "Please Login again Something went wrong",
            backgroundColor: Colors.red));
      });
    }
  }

  @override
  void initState() {
    getInitialData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          Container(
            width: CustomScreenUtility(context).width,
            height: AppBar().preferredSize.height,
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomText(
                    "Ticket History",
                    color: Colors.grey[700],
                    fontWeight: FontWeight.bold,
                    size: 18,
                  ),
                  IconButton(
                      onPressed: () async {
                        try {
                          final barcodeScanRes =
                              await FlutterBarcodeScanner.scanBarcode(
                                  '#ff6666', 'Cancel', true, ScanMode.QR);
                          if (barcodeScanRes == "-1" ||
                              barcodeScanRes == "null") {
                            ScaffoldMessenger.of(context).showSnackBar(
                                Constants.customSnackBar(
                                    content: 'Barcode cancelled',
                                    backgroundColor: Colors.red));
                            return;
                          }
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => StatusScreen(
                                      bookedTicketID: barcodeScanRes)));
                        } on PlatformException {
                          ScaffoldMessenger.of(context).showSnackBar(
                              Constants.customSnackBar(
                                  content: 'Failed to get platform version.',
                                  backgroundColor: Colors.red));
                        }

                        // If the widget was removed from the tree while the asynchronous platform
                        // message was in flight, we want to discard the reply rather than calling
                        // setState to update our non-existent appearance.
                        if (!mounted) return;
                      },
                      icon: const Icon(
                        Icons.camera,
                        color: Colors.orange,
                      ))
                ],
              ),
            ),
          ),
          bookedTicketHistory.isEmpty
              ? const CustomText("No Ticket History found")
              : Column(
                  children: bookedTicketHistory
                      .map((e) => FutureBuilder<List<String>?>(
                          future:
                              Constants().getJourneyTitleByConveyId(e.conveyId),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Container();
                            }
                            if (snapshot.hasError) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  Constants.customSnackBar(
                                      content: "${snapshot.error}"));
                              return Container();
                            }
                            return ListTile(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => StatusScreen(
                                            bookedTicketID: e.id)));
                              },
                              title: CustomText(
                                snapshot.data == null
                                    ? "Mumbai BKC Portal - Pune "
                                    : "${snapshot.data?.first} - ${snapshot.data?.last}",
                                size: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[600],
                              ),
                              subtitle:
                                  CustomText("ID - ${e.id}".toUpperCase()),
                              leading: Icon(
                                Icons.airplane_ticket_outlined,
                                color: Constants.primaryColor,
                              ),
                            );
                          }))
                      .toList(),
                ),
          // ...List.generate(
          //     1,
          //     (index) => ListTile(
          //           title: CustomText(
          //             "ID - ${1234 + index}",
          //             size: 18,
          //             fontWeight: FontWeight.bold,
          //             color: Colors.grey[600],
          //           ),
          //           subtitle: CustomText("CST - Sion"),
          //           leading: Icon(
          //             Icons.airplane_ticket_outlined,
          //             color: Constants.primaryColor,
          //           ),
          //           trailing: Icon(
          //             Icons.share,
          //             color: Colors.green[400],
          //           ),
          //         )).toList()
        ],
      ),
    ));
  }
}
