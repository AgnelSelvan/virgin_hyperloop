import 'package:custom/custom_text.dart';
import 'package:custom/ftn.dart';
import 'package:flutter/material.dart';
import 'package:virgin_hyperloop/constants/constants.dart';
import 'package:virgin_hyperloop/enum/station.dart';
import 'package:virgin_hyperloop/services/firebase/authentication.dart';
import 'package:virgin_hyperloop/views/booking/booking.dart';
import 'package:virgin_hyperloop/extension/strings.dart';

class TrainScreen extends StatefulWidget {
  TrainScreen({Key? key}) : super(key: key);

  @override
  _TrainScreenState createState() => _TrainScreenState();
}

class _TrainScreenState extends State<TrainScreen> {
  bool isReversed = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              const SizedBox(
                height: 15,
              ),
              const HomeHeader(),
              const SizedBox(
                height: 25,
              ),
              DestinationSelection(
                onReverseTap: () {
                  setState(() {
                    isReversed = !isReversed;
                  });
                },
                isReversed: isReversed,
              ),
              const SizedBox(
                height: 25,
              ),
              SizedBox(
                width: CustomScreenUtility(context).width * 0.8,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: Colors.grey[400]!)),
                      child: Icon(
                        Icons.info,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Container(
                      width: CustomScreenUtility(context).width * 0.8 - 70,
                      height: 50,
                      child: CustomTextButton(
                        "Continue",
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => BookingScreen(
                                        startPoint: isReversed
                                            ? Station().getStationEnumToStr(
                                                StationEnum.pune)
                                            : Station().getStationEnumToStr(
                                                StationEnum.bkc),
                                        endPoint: isReversed
                                            ? Station().getStationEnumToStr(
                                                StationEnum.bkc)
                                            : Station().getStationEnumToStr(
                                                StationEnum.pune),
                                      )));
                        },
                        backgoundColor: Constants.primaryColor,
                        textColor: Colors.white,
                        fontSize: 18,
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset("assets/images/mask.jpg"),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class DestinationSelection extends StatelessWidget {
  final VoidCallback onReverseTap;
  final bool isReversed;
  const DestinationSelection({
    Key? key,
    required this.onReverseTap,
    required this.isReversed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: CustomScreenUtility(context).width * 0.8,
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[600]!),
          borderRadius: BorderRadius.circular(5)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          DestinationSelectionContainer(
            destination: Destination.from,
            value: isReversed ? "Pune Portal" : "Mumbai BKC Portal",
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              const MySeparator(color: Colors.grey),
              Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: onReverseTap,
                    child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(5)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              "assets/images/up-down.png",
                              width: 25,
                            ),
                          ],
                        )),
                  ),
                ),
              )
            ],
          ),
          DestinationSelectionContainer(
            destination: Destination.to,
            value: !isReversed ? "Pune Portal" : "Mumbai BKC Portal",
          ),
        ],
      ),
    );
  }
}

class MySeparator extends StatelessWidget {
  final double height;
  final Color color;

  const MySeparator({this.height = 1, this.color = Colors.black});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 5.0;
        final dashHeight = height;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color),
              ),
            );
          }),
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
        );
      },
    );
  }
}

enum Destination { from, to }

class DestinationSelectionContainer extends StatelessWidget {
  final Destination destination;
  final String value;

  const DestinationSelectionContainer({
    Key? key,
    required this.value,
    required this.destination,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          top: destination == Destination.from ? 15 : 10,
          bottom: destination == Destination.to ? 15 : 5,
          left: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CustomText(
            destination.name.toString().capitalize(),
            size: 14,
            color: Colors.grey[500],
          ),
          const SizedBox(height: 5),
          CustomText(
            value,
            size: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          )
        ],
      ),
    );
  }
}

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Authentication.getCurrentUser;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: CustomScreenUtility(context).width * 0.6,
          child: CustomText(
            "Where do you want to go",
            size: 32,
            color: Colors.grey[700],
            fontWeight: FontWeight.bold,
          ),
        ),
        user?.photoURL == null
            ? CustomIcon(
                Icons.account_circle,
                color: Colors.grey[500],
                size: 80,
              )
            : Container(
                width: 85,
                height: 85,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    image:
                        DecorationImage(image: NetworkImage(user!.photoURL!))))
      ],
    );
  }
}
