import 'dart:io';
import 'dart:math';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:yajurmandir/res/Colors.dart';

import '../NameSuggesstionModel.dart';




hexStringToColor(String hexColor) {
  hexColor = hexColor.toUpperCase().replaceAll("#", "");
  if (hexColor.length == 6) {
    hexColor = "FF" + hexColor;
  }
  return Color(int.parse(hexColor, radix: 16));
}

class Utils{
  List<NameSuggesstionModel> nameSuggestions=[];

  Widget placeholderWithImageAsset(BuildContext context){


    List<String> imgUrl=[
      // 'assets/1.jpg',
      'assets/2.jpg'
      // 'assets/3.jpg'
    ];

    return CarouselSlider.builder(
        carouselController: CarouselController(),
        options: CarouselOptions(
          autoPlay: true,
          viewportFraction: 1,
          height: MediaQuery.of(context).size.height,
          enlargeCenterPage: true, // Make the centered item larger
          aspectRatio: 16/9,
          autoPlayCurve: Curves.fastOutSlowIn, // Animation curve
          autoPlayAnimationDuration: Duration(milliseconds: 800),
          enableInfiniteScroll: true,
        ),
        itemCount: imgUrl!.length,

        itemBuilder:
            (BuildContext context, int itemIndex, int pageViewIndex) {

          return InkWell(
              onTap: (){},
              child: Image.asset(
                imgUrl[itemIndex],

                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.cover,
              ));
        });

  }
}
