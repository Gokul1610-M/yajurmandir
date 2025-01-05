import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yajurmandir/GateRegister.dart';
import 'package:yajurmandir/res/colors.dart';
import 'package:yajurmandir/res/strings.dart';

import 'Splash.dart';


Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();


  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  //
  runApp(  ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Maincolor,
      statusBarBrightness: Brightness.light,

    ));
    return
      MaterialApp(
        theme: ThemeData(
          primaryColorDark: Colors.orange,
          primaryColorLight: Colors.orange,
          primaryColor: Colors.orange,

          // You can customize more colors here if needed
        ),
        builder: (context, child) {
          return MediaQuery(
            child: child ?? Container(),
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.1),
          );
        },
        debugShowCheckedModeBanner: false,
        title: appName,

        home: Splash(),

      );
  }
}

