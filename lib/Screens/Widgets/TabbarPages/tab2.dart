import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:emart_app/Screens/Widgets/safe_asset_image.dart';

class tab2 extends StatelessWidget {
  const tab2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(children: [
        SizedBox(height: 40),
        Center(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.1,
            width: MediaQuery.of(context).size.width * 0.9,
            child: TextField(
              textAlign: TextAlign.start,
              obscureText: false,
              keyboardType: TextInputType.text,
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                  fillColor: Color.fromARGB(255, 247, 247, 247),
                  filled: true,
                  prefixIcon: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: SafeAssetImage("assets/icons/lock.png", width: 3.h, height: 3.h, fit: BoxFit.contain),
                  ),
                  prefixIconColor: Color.fromARGB(255, 3, 190, 150),
                  label: Text("Enter your password"),
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(30),
                  )),
            ),
          ),
        ),
        SizedBox(height: 20),
        Container(
          height: MediaQuery.of(context).size.height * 0.05,
          width: MediaQuery.of(context).size.width,
          child: ElevatedButton(
            onPressed: () {
              // Réinitialisation du mot de passe
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromARGB(255, 3, 190, 150),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(
              "Reset Password",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 18.sp,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
