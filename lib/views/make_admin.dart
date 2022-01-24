import 'package:custom/custom_text.dart';
import 'package:custom/ftn.dart';
import 'package:flutter/material.dart';
import 'package:virgin_hyperloop/constants/constants.dart';
import 'package:virgin_hyperloop/models/user.dart';
import 'package:virgin_hyperloop/services/firebase/authentication.dart';
import 'package:virgin_hyperloop/services/firebase/train.dart';
import 'package:virgin_hyperloop/views/booking/booking.dart';

class MakeAdminScreen extends StatefulWidget {
  MakeAdminScreen({Key? key}) : super(key: key);

  @override
  _MakeAdminScreenState createState() => _MakeAdminScreenState();
}

class _MakeAdminScreenState extends State<MakeAdminScreen> {
  final controller = TextEditingController();
  List<UserModel> users = [];

  Future searchForUser(String value) async {
    users.clear();
    setState(() {});
    if (value != "") {
      users = await Authentication.getUserByUsername(value);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: CustomText(
          "Make Admin",
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
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: CustomScreenUtility(context).width * 0.8,
                  child: CustomTF(
                    controller: controller,
                    hintText: "Search for user to make admin",
                  ),
                ),
                IconButton(
                    onPressed: () async {
                      await searchForUser(controller.text);
                    },
                    icon: const Icon(Icons.search))
              ],
            ),
            SizedBox(
              height: 20,
            ),
            users.isEmpty ? const CustomText("No Users Found") : Container(),
            ...users
                .map((e) => BuildPassengerTile(
                      userModel: e,
                      iconColor: e.role == "admin"
                          ? Colors.red[400]
                          : Colors.green[400],
                      trailingIcon: Icons.admin_panel_settings_rounded,
                      onRemoveTap: (UserModel? user) async {
                        if (user != null) {
                          final value = await Authentication().makeAdmin(user);
                          ScaffoldMessenger.of(context).showSnackBar(
                              Constants.customSnackBar(content: value));
                          await searchForUser(controller.text);
                        }
                      },
                    ))
                .toList()
          ],
        ),
      ),
    );
  }
}
