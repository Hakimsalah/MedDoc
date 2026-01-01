import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class list_doctor1 extends StatelessWidget {
  final String image;
  final String maintext;
  final String subtext;
  final String numRating;
  final String distance;

  list_doctor1(
      {required this.distance,
      required this.image,
      required this.maintext,
      required this.numRating,
      required this.subtext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Color.fromARGB(134, 228, 227, 227)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              flex: 5,
              fit: FlexFit.loose,
              child: Center(
                child: Container(
                  alignment: Alignment.topCenter,
                  width: 12.w,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage(image),
                          filterQuality: FilterQuality.high,
                          fit: BoxFit.cover),
                      shape: BoxShape.circle),
                ),
              ),
            ),
            Flexible(
              flex: 5,
              fit: FlexFit.loose,
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    //Main text
                    Text(
                      maintext,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                          fontSize: 13.sp, fontWeight: FontWeight.bold),
                    ),
                    //Sub text
                    Text(
                      subtext,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                          fontSize: 11.sp,
                          color: Colors.black45,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 0.6.h,
                    ),
                    //Rating star container start from here!!
                    Row(
                      children: [
                        Container(
                          height: 2.6.h,
                          width: 20.w,
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 240, 236, 236),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 2.w),
                          child: Row(children: [
                            Container(
                              height: 1.9.h,
                              width: 3.5.w,
                              decoration: const BoxDecoration(
                                  image: DecorationImage(
                                      image: AssetImage(
                                        "assets/icons/star.png",
                                      ),
                                      filterQuality: FilterQuality.high)),
                            ),
                            SizedBox(
                              width: 2.w,
                            ),
                            Text(
                              numRating,
                              style: GoogleFonts.poppins(
                                  fontSize: 11.sp,
                                  color: Color.fromARGB(255, 4, 179, 120),
                                  fontWeight: FontWeight.bold),
                            ),
                          ]),
                        ),
                        //Sizebox betwen ratting + distance
                        SizedBox(width: 3.w),
                        Container(
                          height: 1.9.h,
                          width: 3.5.w,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage(
                                  "assets/icons/Location.png",
                                ),
                                filterQuality: FilterQuality.high),
                          ),
                        ),
                        Text(
                          distance,
                          style: GoogleFonts.poppins(
                              fontSize: 11.sp,
                              color: Color.fromARGB(255, 133, 133, 133),
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
