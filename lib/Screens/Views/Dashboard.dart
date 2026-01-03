import 'package:badges/badges.dart' as badges;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emart_app/Screens/Views/meet_notifications_screen.dart';
import 'package:emart_app/Screens/Widgets/ListDoctorCard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../data/doctors_mock.dart';
import '../Widgets/safe_asset_image.dart';
import '../Widgets/article.dart';
import 'doctor_search.dart';
import 'doctor_details_screen.dart';
import 'articlePage.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final doctors = doctorsMock;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Welcome Back!",
          style: GoogleFonts.inter(
            color: Colors.black87,
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('appointments')
                .where('patientId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                .where('status', isEqualTo: 'confirmed')
                .snapshots(),
            builder: (context, snapshot) {
              int notificationCount = 0;
              if (snapshot.hasData) {
                final now = DateTime.now();
                notificationCount = snapshot.data!.docs.where((doc) {
                  final date = (doc['date'] as Timestamp).toDate();
                  return date.isAfter(now);
                }).length;
              }

              return IconButton(
                icon: badges.Badge(
                  badgeContent: Text(
                    notificationCount.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                  showBadge: notificationCount > 0,
                  child: SafeAssetImage(
                    "assets/icons/bell.png",
                    width: 24,
                    height: 24,
                    fit: BoxFit.contain,
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MeetNotificationsScreen(),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Column(
          children: [
            // Search Bar
            Container(
              height: 6.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 247, 247, 247),
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                textAlignVertical: TextAlignVertical.center,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  prefixIcon: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: SafeAssetImage(
                      "assets/icons/search.png",
                      width: 24,
                      height: 24,
                      fit: BoxFit.contain,
                    ),
                  ),
                  prefixIconColor: const Color(0xFF03BE96),
                  hintText: "Search doctor, drugs, articles...",
                  border: InputBorder.none,
                ),
              ),
            ),
            SizedBox(height: 3.h),

            // Top Doctors
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Top Doctors",
                  style: GoogleFonts.inter(
                      fontSize: 18.sp, fontWeight: FontWeight.w700),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      PageTransition(
                        type: PageTransitionType.rightToLeft,
                        child: const DoctorSearch(specialty: "All"),
                      ),
                    );
                  },
                  child: Text(
                    "See all",
                    style: GoogleFonts.inter(
                        fontSize: 16.sp, color: const Color(0xFF03BE96)),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),

            SizedBox(
              height: 28.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: doctors.length,
                itemBuilder: (context, index) {
                  final doc = doctors[index];
                  return ListDoctorCard(
                    doctor: doc,
                    onTap: () {
                      Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.rightToLeft,
                          child: DoctorDetails(doctor: doc),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 3.h),

            // Articles
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Health Articles",
                  style: GoogleFonts.inter(
                      fontSize: 18.sp, fontWeight: FontWeight.w700),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      PageTransition(
                        type: PageTransitionType.rightToLeft,
                        child: const articlePage(),
                      ),
                    );
                  },
                  child: Text(
                    "See all",
                    style: GoogleFonts.inter(
                        fontSize: 16.sp, color: const Color(0xFF03BE96)),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),

            article(
              image: "assets/images/article1.png",
              dateText: "Jun 10, 2021",
              duration: "5min read",
              mainText:
                  "The 25 Healthiest Fruits You Can Eat, According to a Nutritionist",
            ),
            SizedBox(height: 2.h), // un petit espace entre les articles

// Deuxième article
article(
  image: "assets/images/capsules2.png",
  dateText: "Jun 10, 2020",
  duration: "5min read",
  mainText:
      "Comparing the AstraZeneca and Sinovac COVID-19 Vaccines",
),
          ],
        ),
      ),
    );
  }

  Widget _quickAction({
    required String icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: 7.h,
            width: 14.w,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F8F5),
              borderRadius: BorderRadius.circular(15),
            ),
            padding: const EdgeInsets.all(10),
            child: SafeAssetImage(
              icon,
              width: 14.w,
              height: 7.h,
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            text,
            style:
                GoogleFonts.inter(fontSize: 14.sp, fontWeight: FontWeight.w500),
          )
        ],
      ),
    );
  }
}
