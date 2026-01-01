import 'package:flutter/material.dart';

class DoctorHome extends StatelessWidget {
  const DoctorHome({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "Doctor Dashboard",
          style: TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}
