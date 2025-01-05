import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:permission_handler/permission_handler.dart';

import '../res/Colors.dart';


import 'package:toast/toast.dart';


void showToast(BuildContext context,String msg, {int? duration, int? gravity}) {
  ToastContext().init(context);
  Toast.show(msg, duration: Toast.lengthLong, gravity: gravity);
}

void showAlertDialog_oneBtntwowithnoback(BuildContext context,String tittle,String message)
{
  AlertDialog alert = AlertDialog(

    backgroundColor: Colors.white,
    title: Text(tittle),
    // content: CircularProgressIndicator(),
    content: Text(message,style: TextStyle(color: Colors.black45)),
    actions: [
      GestureDetector(
        onTap: (){
          Navigator.pop(context,true);
          Navigator.pop(context,true);
        },
        child: Align(
          alignment: Alignment.centerRight,
          child: Container(
            height: 35,
            width: 100,
         //   color: Colors.white,
            child:Center(child: Text('OK',style: TextStyle(color: Maincolor),)),
          ),
        ),
      ),
    ],
  );
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return WillPopScope(
          onWillPop: ()async => false,
          child: alert);
    },
  ).then((exit) {
    if (exit == null) return;

    if (exit) {
      // back to previous screen

      //  Navigator.pop(context);
    } else {
      // user pressed No button
    }
  }

  );
}

void showAlertDialog_oneBtn(BuildContext context,String tittle,String message)
{
  AlertDialog alert = AlertDialog(

    backgroundColor: Colors.white,
    title: Text(tittle),
    // content: CircularProgressIndicator(),
    content: Text(message,style: TextStyle(color: Colors.black45)),
    actions: [
      GestureDetector(
        onTap: (){
          Navigator.pop(context,true);
          },
        child: Align(
          alignment: Alignment.centerRight,
          child: Container(
            height: 35,
            width: 100,
          //  color: Colors.white,
            child:Center(child: Text('OK',style: TextStyle(color:Maincolor),)),
          ),
        ),
      ),
    ],
  );
  showDialog(

    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6,sigmaY: 6),
        child: alert,
      );
    },
  );
}

void showAlertDialog_oneBtnPermission(BuildContext context,String tittle,String message)
{
  AlertDialog alert = AlertDialog(

    backgroundColor: Colors.white,
    title: Text(tittle),
    // content: CircularProgressIndicator(),
    content: Text(message,style: TextStyle(color: Colors.black45)),
    actions: [
      GestureDetector(
        onTap: ()async{

          Navigator.pop(context,true);
          await Permission.storage.request();
        },
        child: Align(
          alignment: Alignment.centerRight,
          child: Container(
            height: 35,
            width: 100,
            //  color: Colors.white,
            child:Center(child: Text('OK',style: TextStyle(color:Maincolor),)),
          ),
        ),
      ),
    ],
  );
  showDialog(

    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6,sigmaY: 6),
        child: alert,
      );
    },
  );
}

void showAlertDialog_oneBtn_msg(BuildContext context,String message)
{
  AlertDialog alert = AlertDialog(


    title: Text(message,style: TextStyle(fontSize: 13),),
    // content: CircularProgressIndicator(),

    actions: [
      GestureDetector(
        onTap: (){Navigator.pop(context,true);},
        child: Align(
          alignment: Alignment.centerRight,
          child: Container(
            height: 35,
            width: 100,
            color: Colors.white,
            child:Center(child: Text('Ok',style: TextStyle(color: Maincolor),)),
          ),
        ),
      ),
    ],
  );
  showDialog(

    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6,sigmaY: 6),
        child: alert,
      );
    },
  );
}




void showAlertDialog_forAppUpdate(BuildContext context,String tittle,String message)
{
  // AlertDialog alert = AlertDialog(
  //  // backgroundColor: Colors.white,
  //   title: Text(tittle),
  //   // content: CircularProgressIndicator(),
  //   content: Text(message,style: TextStyle(color: Colors.black45)),
  //   actions: [
  //     GestureDetector(
  //       onTap: (){
  //         if(CommonUtils.deviceType.toString()=="1"){
  //           //Apple
  //           gotoAppstore(context);
  //         }
  //         else if(CommonUtils.deviceType.toString()=="2"){
  //           // android
  //           gotoPlaystore(context);
  //         }
  //
  //       },
  //       child: Align(
  //         alignment: Alignment.centerRight,
  //         child: Container(
  //           height: 35,
  //           width: 100,
  //         //  color: Colors.white,
  //           child:Center(child: Text(ok,style: TextStyle(color: Maincolor),)),
  //         ),
  //       ),
  //     ),
  //   ],
  // );
  // showDialog(
  //   barrierDismissible: false,
  //   context: context,
  //   builder: (BuildContext context) {
  //     return WillPopScope(
  //         onWillPop: ()async => false,
  //         child: alert);
  //   },
  // ).then((exit){
  //   if (exit == null) return;
  //
  //   if (exit) {
  //     // back to previous screen
  //
  //     Navigator.pop(context);
  //   } else {
  //     // user pressed No button
  //   }
  // });
}

void gotoPlaystore(BuildContext context){
  // LaunchReview.launch(
  //   androidAppId: "com.velovelo.rewards",
  // );
}
void gotoAppstore(BuildContext context){
  // StoreRedirect.redirect(androidAppId:  "com.velovelo.rewards",iOSAppId:"6450112759" );

}

void showAlertDialog_oneBtnWitDismiss(BuildContext context,String tittle,String message)
{
  AlertDialog alert = AlertDialog(
    backgroundColor: Colors.white,
    title: Text(tittle),
    // content: CircularProgressIndicator(),
    content: Text(message,style: TextStyle(color: Colors.black45)),
    actions: [
      GestureDetector(
        onTap: (){Navigator.pop(context,true);


        },
        child: Align(
          alignment: Alignment.centerRight,
          child: Container(
            height: 35,
            width: 100,
            color: Colors.white,
            child:Center(child: Text('OK',style: TextStyle(color: Maincolor),)),
          ),
        ),
      ),
    ],
  );

  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  ).then((exit){
    if (exit == null) return;

    if (exit) {
      // back to previous screen

      Navigator.pop(context);
    } else {
      // user pressed No button
    }
  });

}
void showLoadingView(BuildContext context){
AlertDialog   alert = AlertDialog(
    backgroundColor: Colors.white,

    // content: CircularProgressIndicator(),
    content: Container(
      height: 50,
      child: Center(
        child: Row(
          children: [
            SpinKitCircle(
            color: Maincolor,
            size: 50.0,
            ),
            Text('Loading',style: TextStyle(color: Colors.black,fontSize: 18),),
          ],
        ),
      ),
    ),

  );
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );



}


/*Future<void> feedbackpoints(BuildContext context) async {

  final http.Response response = await http.post(
    Uri.parse(FBPOSTSTATUSCMD),
    body: {
      "device_type": CommonUtils.deviceType,
      "device_token": CommonUtils.deviceToken,
      "cma_timestamps": Utils().getTimeStamp(),
      "time_zone": Utils().getTimeZone(),
      "software_version": CommonUtils.softwareVersion,
      "os_version": CommonUtils.osVersion,
      'consumer_application_type': CommonUtils.consumerApplicationType,
      'consumer_language_id': CommonUtils.consumerLanguageId,
      'device_token_id': CommonUtils.deviceTokenID,
      'consumer_id':  CommonUtils.consumerID,
      'program_id' : prgmId,
     //  'transaction_program_idNewUiPPNcmdforAllCma': prgmId,
      'merchant_id': CommonUtils.merchantID,
      'member_id': memberid,
      'outlet_id':  outletid,
      'reward_points': fbPoints,
      'transaction_id': transId,
     // 'country_index':  CommonUtils.countryindex,
    },
  ).timeout(Duration(seconds: 30));
  print("chcek"+response.body.toString());
  var data=jsonDecode(response.body);
  print("check1"+data.toString());
  var status = data["Status"];
  var msg = data["Message"];
  if (status == 'True' || status == '1') {
    print("check3");
   //  Navigator.pop(context);
    showThanksDialog(context, msg);
  }
  else {
    showAlertDialog_oneBtn(context,alert1, msg);
  }
}*/

