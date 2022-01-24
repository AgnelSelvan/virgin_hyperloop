import 'package:custom/custom_text.dart';
import 'package:custom/ftn.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:virgin_hyperloop/constants/constants.dart';
import 'package:virgin_hyperloop/enum/admin.dart';
import 'package:virgin_hyperloop/models/services.dart';
import 'package:virgin_hyperloop/models/user.dart';
import 'package:virgin_hyperloop/services/firebase/authentication.dart';
import 'package:virgin_hyperloop/views/admin/add/train.dart';
import 'package:virgin_hyperloop/views/admin/history.dart';
import 'package:virgin_hyperloop/views/booking/booking.dart';
import 'package:virgin_hyperloop/views/make_admin.dart';
import 'package:virgin_hyperloop/views/unauthorize/unauthorize.dart';

class ProfileScreen extends StatefulWidget {
  ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? user = Authentication.getCurrentUser;
  UserModel? userModel;

  void handleLogin() async {
    user = Authentication.getCurrentUser;
    if (user != null) {
      ScaffoldMessenger.of(context).showSnackBar(Constants.customSnackBar(
          content: "Logged in as ${user?.displayName}"));
    }
    await getMyData();
    setState(() {});
  }

  Future<void> handleLogout() async {
    Navigator.pop(context);
    await Authentication.signOut(context: context);
    user = Authentication.getCurrentUser;
    setState(() {});
  }

  Future<void> getMyData() async {
    user = Authentication.getCurrentUser;
    if (user != null) {
      userModel = await Authentication.getMyData(user!.uid);
    }
    setState(() {});
  }

  @override
  void initState() {
    getMyData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return user == null
        ? UnauthorizedScreen(
            value: "Profile",
            handleLogin: handleLogin,
          )
        : Container(
            child: SafeArea(
                child: Container(
              color: Colors.grey[50],
              child: Column(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.vertical(bottom: Radius.circular(40))),
                    child: Column(
                      children: [
                        Container(
                          height: AppBar().preferredSize.height,
                          alignment: Alignment.centerRight,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                  onPressed: () {
                                    Constants.askYesOrNoDialog(
                                        context,
                                        "Logout",
                                        "Are you sure want to logout ?", () {
                                      handleLogout();
                                    });
                                  },
                                  icon: Icon(
                                    Icons.logout_rounded,
                                    color: Constants.primaryColor,
                                  )),
                              userModel == null
                                  ? Container()
                                  : userModel!.role == "admin"
                                      ? PopupMenuButton<AdminEnum>(
                                          itemBuilder: (_) => AdminEnum.values
                                              .map((e) =>
                                                  PopupMenuItem<AdminEnum>(
                                                      child: CustomText(Admin()
                                                          .getAdminEnumToStr(
                                                              e)),
                                                      value: e))
                                              .toList(),
                                          onSelected: (AdminEnum? val) {
                                            print(val);
                                            if (val != null) {
                                              if (val == AdminEnum.addTrain) {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            AddTrain()));
                                              } else if (val ==
                                                  AdminEnum.ticketHistory) {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            TrainHistory()));
                                              } else if (val ==
                                                  AdminEnum.makeAdmin) {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            MakeAdminScreen()));
                                              }
                                            }
                                          },
                                        )
                                      : Container(),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        user?.photoURL == null
                            ? BuildUserImage(
                                username: user!.displayName ?? "",
                                userColor: null,
                                size: 120,
                              )
                            : CircleAvatar(
                                radius: 60,
                                backgroundImage: user?.photoURL == null
                                    ? null
                                    : NetworkImage(user!.photoURL!),
                              ),
                        const SizedBox(
                          height: 40,
                        ),
                        CustomText(
                          "${user?.displayName}",
                          size: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.7,
                          color: Colors.grey[700],
                        ),
                        const SizedBox(
                          height: 3,
                        ),
                        CustomText(
                          "${user?.email}",
                          size: 14,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(
                          height: 3,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 15),
                          decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(100)),
                          child: CustomText("${userModel?.role}"),
                        ),
                        const SizedBox(
                          height: 25,
                        ),
                      ],
                    ),
                  ),
                  Wrap(
                    children: ServiceModel.datas
                        .map((e) => Container(
                              margin: const EdgeInsets.all(15),
                              width: 60,
                              child: Column(
                                children: [
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                        color: e.color,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Icon(
                                      e.icon,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  CustomText(
                                    e.name,
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.w500,
                                  )
                                ],
                              ),
                            ))
                        .toList(),
                  )
                ],
              ),
            )),
          );
  }
}
