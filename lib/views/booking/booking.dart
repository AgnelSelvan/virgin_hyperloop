import 'package:custom/custom_text.dart';
import 'package:custom/ftn.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:virgin_hyperloop/constants/constants.dart';
import 'package:virgin_hyperloop/controller/booking.dart';
import 'package:virgin_hyperloop/enum/seat_status.dart';
import 'package:virgin_hyperloop/extension/strings.dart';
import 'package:virgin_hyperloop/models/convey.dart';
import 'package:virgin_hyperloop/models/user.dart';
import 'package:virgin_hyperloop/services/firebase/authentication.dart';
import 'package:virgin_hyperloop/views/status/status.dart';

class BookingScreen extends StatefulWidget {
  final String startPoint;
  final String endPoint;
  const BookingScreen(
      {Key? key, required this.startPoint, required this.endPoint})
      : super(key: key);

  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  late Razorpay _razorpay;
  double amount = 0;
  late BookingController bookingController;

  final currentUser = Authentication.getCurrentUser;
  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }

  void openCheckout(double price, String tickets) async {
    amount = price;
    var options = {
      'key': 'rzp_test_9SXPJw8jBRSDfa',
      'amount': price * 100,
      'name': '${currentUser?.displayName}',
      'description': 'Ticket: $tickets',
      'prefill': {'contact': '', 'email': '${currentUser?.email}'},
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    bookingController.onPaymentSuccess(
        context, response.paymentId ?? "", amount);
    ScaffoldMessenger.of(context).showSnackBar(
        Constants.customSnackBar(content: "SUCCESS: ${response.paymentId!}"));
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(Constants.customSnackBar(
        content:
            "ERROR: " + response.code.toString() + " - " + response.message!,
        backgroundColor: Colors.red[400]));
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(Constants.customSnackBar(
        content: "EXTERNAL_WALLET: " + response.walletName!,
        backgroundColor: Colors.red[400]));
  }

  Future<UserModel?> showAddPassengerDialog(BuildContext context) async {
    final controller = TextEditingController();
    final ageController = TextEditingController();
    return showDialog<UserModel>(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: CustomText(
              "Add Passengers Details",
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
              size: 16,
            ),
            contentPadding: const EdgeInsets.all(20),
            children: [
              const SizedBox(height: 20),
              CustomTF(
                controller: controller,
                hintText: "Enter Name",
              ),
              const SizedBox(height: 10),
              CustomTF(
                controller: ageController,
                hintText: "Enter Age",
              ),
              const SizedBox(height: 20),
              CustomTextButton(
                "Add",
                onPressed: () {
                  Navigator.pop(
                      context,
                      UserModel(
                          uid: "1",
                          username: controller.text,
                          color: Constants.getRandomColor,
                          age: int.tryParse(ageController.text)));
                },
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
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
          "${widget.startPoint} - ${widget.endPoint}",
          size: 20,
          fontWeight: FontWeight.w500,
          color: Colors.grey[600],
        ),
      ),
      body: ChangeNotifierProvider<BookingController>(
        create: (context) => BookingController(),
        child: Consumer<BookingController>(builder: (context, myModel, child) {
          bookingController = myModel;
          return Container(
            padding: const EdgeInsets.all(15),
            child: Container(
              width: CustomScreenUtility(context).width,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ...TrainSeatStatus.values
                            .map((e) => TrainSeatStatusContainer(
                                  trainSeatStatus: e,
                                  onSeatTap: null,
                                ))
                            .toList()
                      ],
                    ),
                    const SizedBox(height: 20),
                    FutureBuilder<ConveyModel?>(
                        future: myModel.getConveyInfo(
                            widget.startPoint, widget.endPoint),
                        builder: (context, snapshot) {
                          // print("Rebuilding");
                          // if (snapshot.data == null) {
                          //   return Container();
                          // }
                          return Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  IconButton(
                                      onPressed: () {
                                        myModel.onGateTap(0);
                                      },
                                      icon: const Icon(
                                        Icons.arrow_back_ios,
                                        size: 18,
                                      )),
                                  CustomText(
                                    myModel.currentSelectedGate,
                                    size: 18,
                                    color: Colors.grey[700],
                                  ),
                                  IconButton(
                                      onPressed: () {
                                        print("object");
                                        myModel.onGateTap(1);
                                      },
                                      icon: const Icon(
                                        Icons.arrow_forward_ios,
                                        size: 18,
                                      ))
                                ],
                              ),
                              Container(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 5),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Constants.primaryColor),
                                    borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 20),
                                child: TrainSeatingArrangement(
                                    column: 7,
                                    onSeatTapValue: (val) {
                                      myModel.generateSeatNumber(val);
                                    },
                                    bookingController: myModel),
                              )
                            ],
                          );
                        }),
                    Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 5),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: Constants.blackShadow,
                      ),
                      width: CustomScreenUtility(context).width,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              CustomText(
                                "No. Of Passenger",
                                color: Colors.grey[600],
                                size: 14,
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              Row(
                                children: [
                                  Row(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          final count = int.parse(myModel
                                                  .passengerController.text) -
                                              1;
                                          if (count == 0) {
                                            Constants().showErrorDialog(
                                                context,
                                                "Error",
                                                "Number of Passengers cannot be empty");
                                            return;
                                          }
                                          if (myModel.passengersList.length >
                                              (count)) {
                                            Constants().showErrorDialog(
                                                context,
                                                "Error",
                                                "Please remove Passenger from the list");
                                            return;
                                          }
                                          myModel.decreasePassengerCount();
                                        },
                                        child: Icon(Icons.remove_circle,
                                            color: Constants.primaryColor),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Container(
                                        width: 70,
                                        height: 50,
                                        child: CustomTF(
                                          controller:
                                              myModel.passengerController,
                                          textAlign: TextAlign.center,
                                          textInputType: TextInputType.number,
                                          onChanged: (String? val) {
                                            setState(() {});
                                          },
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          myModel.increasePassengerCount();
                                        },
                                        child: Icon(
                                          Icons.add_circle,
                                          color: Colors.green[400],
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Column(
                            children: myModel.passengersList
                                .map((e) => BuildPassengerTile(
                                      userModel: e,
                                      onRemoveTap: (val) {
                                        myModel.removePassenger = val;
                                      },
                                    ))
                                .toList(),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          myModel.passengerController.text == "0"
                              ? Container()
                              : int.parse(myModel.passengerController.text) <=
                                      myModel.passengersList.length
                                  ? Container()
                                  : Column(
                                      children: [
                                        CustomTextButtonIcon(
                                          Icons.account_circle_rounded,
                                          "Add Passenger",
                                          onPressed: () async {
                                            final userModel =
                                                await showAddPassengerDialog(
                                                    context);
                                            if (userModel != null) {
                                              if (userModel.username == "") {
                                                Constants().showErrorDialog(
                                                    context,
                                                    "Username",
                                                    "Username cannot be empty");
                                                return;
                                              }
                                              myModel.addPassenger = userModel;
                                            }
                                          },
                                          backgoundColor:
                                              Constants.primaryColor,
                                          textColor: Colors.white,
                                        ),
                                      ],
                                    ),
                          const SizedBox(
                            height: 20,
                          ),
                          Container(
                            margin: const EdgeInsets.all(10),
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(color: Colors.red[100]!)),
                            child: Column(
                              children: [
                                const CustomText(
                                    "Note: To get the latest Seat Number click here!"),
                                CustomTextButton(
                                  "Refresh",
                                  onPressed: () {
                                    myModel.notifyListeners();
                                  },
                                )
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Table(
                            children: [
                              TableRow(children: [
                                CustomText(
                                  "Your Seat",
                                  color: Colors.grey[500],
                                  fontWeight: FontWeight.bold,
                                  size: 18,
                                ),
                                FutureBuilder<List<String>>(
                                    future: myModel.getSeatNumbersList(context),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) {
                                        return Column(
                                          children: [
                                            Container(
                                                width: 10,
                                                height: 10,
                                                child:
                                                    const CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                )),
                                          ],
                                        );
                                      }
                                      if (snapshot.data == null) {
                                        return const CustomText("Error");
                                      }
                                      return CustomText(
                                        snapshot.data!.join(", "),
                                        color: Colors.grey[600],
                                        size: 16,
                                      );
                                    })
                              ]),
                              TableRow(children: [
                                Container(
                                  margin: const EdgeInsets.only(top: 10),
                                  child: CustomText(
                                    "Total Price",
                                    color: Colors.grey[500],
                                    fontWeight: FontWeight.bold,
                                    size: 18,
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(top: 10),
                                  child: CustomText(
                                    "₹ ${myModel.price}",
                                    color: Colors.grey[600],
                                    size: 16,
                                  ),
                                )
                              ])
                            ],
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          Container(
                            width:
                                CustomScreenUtility(context).width * 0.8 - 70,
                            height: 50,
                            child: CustomTextButton(
                              "Continue",
                              onPressed: () async {
                                final datas = myModel
                                    .currentSelectedSeats!.seatsModelList
                                    .map((e) => e.uid)
                                    .toList();
                                print(
                                    "$datas ${myModel.currentSelectedSeats!.seatsModelList.take(int.parse(myModel.passengerController.text)).map((e) => e.uid).toList()}");
                                final isLoggedIn =
                                    Authentication.isUserLoggedIn;
                                if (isLoggedIn) {
                                  if (myModel.passengersList.length ==
                                      int.parse(
                                          myModel.passengerController.text)) {
                                    openCheckout(
                                        myModel.price,
                                        myModel
                                            .getSeatsFromCurrentSelectedSeats()
                                            .take(int.parse(myModel
                                                .passengerController.text))
                                            .join(','));
                                  }
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      Constants.customSnackBar(
                                          content:
                                              "Error Please add Passengers",
                                          backgroundColor: Colors.red[400]));
                                } else {
                                  await Constants().showLoginDialog(context,
                                      () async {
                                    final user =
                                        await Authentication.signInWithGoogle(
                                            context: context);
                                    if (user != null) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                          Constants.customSnackBar(
                                              content:
                                                  "Logged in as ${user.displayName}"));
                                    }
                                  });
                                }
                              },
                              backgoundColor: Constants.primaryColor,
                              textColor: Colors.white,
                              fontSize: 18,
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

typedef UserCallback = void Function(UserModel val);

class BuildPassengerTile extends StatelessWidget {
  final UserModel userModel;
  final UserCallback? onRemoveTap;
  final IconData? trailingIcon;
  final Color? iconColor;
  const BuildPassengerTile({
    Key? key,
    required this.userModel,
    this.onRemoveTap,
    this.trailingIcon,
    this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: CustomText(
        userModel.username,
        color: Colors.grey[700],
        fontWeight: FontWeight.bold,
      ),
      subtitle: userModel.age == null
          ? null
          : CustomText(
              "Age: ${userModel.age}",
              color: Colors.grey[600],
            ),
      leading: BuildUserImage(
        username: userModel.username,
        userColor: userModel.color,
      ),
      trailing: onRemoveTap == null
          ? null
          : IconButton(
              onPressed: () {
                onRemoveTap!(userModel);
                // myModel.removePassenger = e;
              },
              icon: Icon(
                trailingIcon ?? Icons.delete_forever,
                color: iconColor ?? Colors.red,
              ),
            ),
    );
  }
}

class BuildUserImage extends StatelessWidget {
  final String username;
  final Color? userColor;
  final double? size;
  const BuildUserImage({
    Key? key,
    required this.username,
    this.userColor,
    this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: size ?? 50,
        height: size ?? 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size ?? 25),
            color: userColor ?? Constants.getRandomColor),
        child: CustomText(
          Constants.getInitial(username),
          color: Colors.white,
          size: size == null ? 16 : 30,
        ));
  }
}

typedef StringCallback = void Function(String val);

class CustomTF extends StatelessWidget {
  final TextEditingController controller;
  final TextAlign textAlign;
  final String? hintText;
  final StringCallback? onChanged;
  final TextInputType? textInputType;

  const CustomTF(
      {Key? key,
      required this.controller,
      this.textAlign = TextAlign.start,
      this.hintText,
      this.onChanged,
      this.textInputType})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      textAlign: textAlign,
      controller: controller,
      keyboardType: textInputType,
      decoration: InputDecoration(
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: Colors.grey[200]!)),
          hintStyle: TextStyle(color: Colors.grey[800]),
          hintText: hintText),
    );
  }
}

typedef ValueCallback = void Function(List<int> val);

class TrainSeatingArrangement extends StatelessWidget {
  final int column;
  final ValueCallback onSeatTapValue;
  final BookingController bookingController;
  const TrainSeatingArrangement({
    Key? key,
    required this.column,
    required this.onSeatTapValue,
    required this.bookingController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: CustomScreenUtility(context).width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ["A", "B", "", "C", "D"]
                .map((e) => CustomText(
                      e,
                      color: Colors.grey[500],
                      size: 14,
                    ))
                .toList(),
          ),
        ),
        const SizedBox(
          height: 15,
        ),
        ...List.generate(column, (i) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [1, 2, "3", 3, 4].map((index) {
                final val = bookingController.selectedBookingSeat.where((e) {
                  return e.seatMatric.contains(index) &&
                      e.seatMatric.contains(i + 1);
                }).toList();
                final isSelected = val.length == 1;
                if (index == "3") {
                  return CustomText(
                    "${i + 1}",
                    size: 16,
                    color: Colors.grey[700],
                  );
                } else {
                  if (i % 2 == 0) {
                    if (int.parse("$index") % 2 == 1) {
                      return SeatStatusContainer(
                        trainSeatStatus: TrainSeatStatus.available,
                        size: CustomScreenUtility(context).width / 8,
                        onSeatTap: null,
                        isSelected: false,
                      );
                    } else {
                      return SeatStatusContainer(
                        trainSeatStatus: TrainSeatStatus.unavailable,
                        size: CustomScreenUtility(context).width / 8,
                        isSelected: isSelected,
                        onSeatTap: () {
                          onSeatTapValue([int.parse("$index"), i + 1]);
                        },
                      );
                    }
                  } else {
                    if (int.parse("$index") % 2 == 1) {
                      return SeatStatusContainer(
                        trainSeatStatus: TrainSeatStatus.unavailable,
                        size: CustomScreenUtility(context).width / 8,
                        isSelected: isSelected,
                        onSeatTap: () {
                          onSeatTapValue([int.parse("$index"), i + 1]);
                        },
                      );
                    } else {
                      return SeatStatusContainer(
                        trainSeatStatus: TrainSeatStatus.available,
                        size: CustomScreenUtility(context).width / 8,
                        isSelected: false,
                        onSeatTap: null,
                      );
                    }
                  }
                }
              }).toList(),
            ),
          );
        }).toList()
      ],
    );
  }
}

class TrainSeatStatusContainer extends StatelessWidget {
  final TrainSeatStatus trainSeatStatus;
  final VoidCallback? onSeatTap;
  const TrainSeatStatusContainer({
    Key? key,
    required this.trainSeatStatus,
    required this.onSeatTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(children: [
        SeatStatusContainer(
          trainSeatStatus: trainSeatStatus,
          isSelected: false,
          onSeatTap: onSeatTap,
        ),
        const SizedBox(
          width: 10,
        ),
        CustomText(
          trainSeatStatus.name.toString().capitalize(),
          color: Colors.grey[600],
          size: 12,
        )
      ]),
    );
  }
}

class SeatStatusContainer extends StatelessWidget {
  final double? size;
  final VoidCallback? onSeatTap;
  final bool isSelected;
  const SeatStatusContainer({
    Key? key,
    required this.trainSeatStatus,
    this.size,
    required this.onSeatTap,
    required this.isSelected,
  }) : super(key: key);

  final TrainSeatStatus trainSeatStatus;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      // onTap: onSeatTap,
      child: Container(
          width: size ?? 20,
          height: size ?? 20,
          child: trainSeatStatus == TrainSeatStatus.unavailable
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/images/cancel.png",
                      width: (size ?? 20) / 1.5,
                    ),
                  ],
                )
              : null,
          decoration: BoxDecoration(
              // image: const DecorationImage(
              //   image: AssetImage(
              //     "assets/images/cancel.png",
              //   ),
              //   scale: 0.5,
              // ),
              color: trainSeatStatus == TrainSeatStatus.unavailable
                  ? Colors.grey[300]
                  : trainSeatStatus == TrainSeatStatus.booked
                      ? Constants.primaryColor
                      : isSelected
                          ? Constants.primaryColor
                          : Colors.white,
              border: trainSeatStatus == TrainSeatStatus.unavailable
                  ? null
                  : Border.all(color: Constants.primaryColor, width: 2),
              borderRadius: BorderRadius.circular(size == null ? 5 : 15))),
    );
  }
}
