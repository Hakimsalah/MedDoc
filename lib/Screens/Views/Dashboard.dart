import 'package:emart_app/Screens/Views/articlePage.dart';
import 'package:emart_app/Screens/Views/doctor_search.dart';
import 'package:emart_app/Screens/Views/find_doctor.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../Widgets/list_doctor1.dart';
import '../Widgets/article.dart';
import 'package:emart_app/Screens/Widgets/safe_asset_image.dart';


class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
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
          IconButton(
            icon: SafeAssetImage("assets/icons/bell.png", width: 4.h, height: 4.h, fit: BoxFit.contain),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.person, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h)
              .copyWith(bottom: MediaQuery.of(context).viewInsets.bottom + 2.h),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
            TextField(
              onTap: () {
                Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.rightToLeft,
                    child: const find_doctor(),
                  ),
                );
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[200],
                prefixIcon:
                    const Icon(Icons.search, color: Color(0xFF03BE96)),
                hintText: "Search doctor, drugs, articles...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            SizedBox(height: 3.h),

            // Quick actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _quickAction(
                    icon: "assets/icons/Doctor.png",
                    text: "Book Appointment",
                    onTap: () {}),
                _quickAction(
                    icon: "assets/icons/document.png",
                    text: "My Documents",
                    onTap: () {}),
                _quickAction(
                    icon: "assets/icons/video.png",
                    text: "Virtual Consult",
                    onTap: () {}),
              ],
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
                        child: const doctor_search(),
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
              height: 24.h,
              child: ListView(
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                children: [
                  list_doctor1(
                      distance: "130m Away",
                      image: "assets/icons/male-doctor.png",
                      maintext: "Dr. Marcus Horizon",
                      numRating: "4.7",
                      subtext: "Cardiologist"),
                ],
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

            article(
              image: "assets/images/article1.png",
              dateText: "Jun 10, 2021",
              duration: "5min read",
              mainText:
                  "The 25 Healthiest Fruits You Can Eat, According to a Nutritionist",
            ),
          ],
        ),
      ),
    ));
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
            style: GoogleFonts.inter(
                fontSize: 14.sp, fontWeight: FontWeight.w500),
          )
        ],
      ),
    );
  }
}
