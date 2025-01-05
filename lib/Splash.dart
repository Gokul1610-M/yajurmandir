import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:yajurmandir/GateRegister.dart';
import 'package:yajurmandir/Utils/Utils.dart';

import 'NameSuggesstionModel.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {





  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer(Duration(seconds: 6), () {

     
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => GateRegister()));

     

    });
  }
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark
        )
    );
    return  AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark
      ),
      child: Scaffold(
        body:Stack(
            children:[
              Utils().placeholderWithImageAsset(context),
              Positioned(
                  left: 0,right: 0,bottom: 30,
                  child: SpinKitCircle(
                    color: Colors.white,size: 40,
                  )),
            ]),
      ),
    );
  }
}
