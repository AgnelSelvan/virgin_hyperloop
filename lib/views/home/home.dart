import 'package:custom/custom_text.dart';
import 'package:custom/ftn.dart';
import 'package:flutter/material.dart';
import 'package:virgin_hyperloop/constants/constants.dart';
import 'package:virgin_hyperloop/services/firebase/authentication.dart';
import 'package:virgin_hyperloop/views/home/pages/ticker.dart';
import 'package:virgin_hyperloop/views/home/pages/train.dart';
import 'package:virgin_hyperloop/views/profile/profile.dart';
import 'package:virgin_hyperloop/views/unauthorize/unauthorize.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<Widget> _widgetOptions = <Widget>[
    TrainScreen(),
    TicketHistoryScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.train,
                  color: _selectedIndex == 0
                      ? Constants.primaryColor
                      : Colors.grey[600]!),
              label: 'Train',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.airplane_ticket_outlined,
                  color: _selectedIndex == 1
                      ? Constants.primaryColor
                      : Colors.grey[600]!),
              label: 'Ticket History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person,
                  color: _selectedIndex == 2
                      ? Constants.primaryColor
                      : Colors.grey[600]!),
              label: 'Profile',
            ),
          ],
          type: BottomNavigationBarType.shifting,
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.black,
          iconSize: 20,
          onTap: _onItemTapped,
          elevation: 0),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
