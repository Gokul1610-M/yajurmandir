import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yajurmandir/GateRegister.dart';

import 'Utils/Utils.dart';

class ScreensaverScreen extends StatefulWidget {
  @override
  _ScreensaverScreenState createState() => _ScreensaverScreenState();
}

class _ScreensaverScreenState extends State<ScreensaverScreen> {
  @override
  Widget build(BuildContext context) {

    return AnnotatedRegion<SystemUiOverlayStyle>(
    value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark
    ),
      child: Scaffold(
        body: GestureDetector(
          onTap: (){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => GateRegister()));

          },
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                height: double.infinity,
                child:Utils().placeholderWithImageAsset(context)
              ),
              Positioned(
                bottom: 10,
                right: 80,
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    //color: Colors.black.withOpacity(0.6),
                    //borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Tap Screen To Continue..\n  LOVE ALL SERVE ALL',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

  }

}