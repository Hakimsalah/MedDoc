import 'package:emart_app/Screens/Auth/Profile_screen.dart';
import 'package:emart_app/Screens/Auth/shedule_screen.dart';
import 'package:emart_app/Screens/Views/Dashboard.dart';
import 'package:emart_app/Screens/Widgets/TabbarPages/message_tab_all.dart';
import 'package:flutter/material.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
class PatientHome extends StatefulWidget {
  const PatientHome({super.key});

  @override
  State<PatientHome> createState() => _PatientHomeState();
}

class _PatientHomeState extends State<PatientHome> {
  int page = 0;

  final List<Widget> pages = const [
    Dashboard(),
    message_tab_all(),
    shedule_screen(),
    Profile_screen(),
  ];

  final List<IconData> icons = [
    FontAwesomeIcons.house,
    FontAwesomeIcons.envelope,
    FontAwesomeIcons.calendarCheck,
    FontAwesomeIcons.user,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[page],

      bottomNavigationBar: AnimatedBottomNavigationBar(
        icons: icons,
        activeIndex: page,
        gapLocation: GapLocation.none,
        height: 70,
        iconSize: 22,
        activeColor: const Color(0xFF03BE96),
        inactiveColor: Colors.grey.shade400,
        onTap: (index) {
          setState(() {
            page = index;
          });
        },
      ),
    );
  }
}
