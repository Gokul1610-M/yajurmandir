import 'dart:async';
import 'dart:io';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:lecle_downloads_path_provider/lecle_downloads_path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yajurmandir/MasterDataProvider.dart';
import 'package:yajurmandir/NameSuggesstionModel.dart';
import 'package:yajurmandir/res/Colors.dart';
import 'AllProvider.dart';
import 'GateRegisterProvider.dart';
import 'Screensaver.dart';
import 'Settings.dart';
import 'Utils/AlertDialogUtil.dart';
import 'Utils/DBHelper.dart';
import 'Utils/Utils.dart';

class GateRegister extends ConsumerStatefulWidget {

   GateRegister({super.key});

  @override
  ConsumerState<GateRegister> createState() => _GateRegisterState();
}

class _GateRegisterState extends ConsumerState<GateRegister> {



  _GateRegisterState();

  late GateRegisterProvider _gateRegisterProvider;
  late MasterDataProvider _masterDataProvider;
  late Timer _timer;
  var authorizationrequest;
  late SharedPreferences _prefs;
  DateTime _lastAlertTime=DateTime.now();
  DateTime _lastAlertTime30Days=DateTime.now();
  TextEditingController dateFilterController=TextEditingController();

  String secretLockKey='S-A-I';
  List<String> secretLock=[];
  @override

  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((_) {

      secretLock.clear();
      
      String day=DateTime.now().day.toString();
      if(day.length==1){day='0'+day;}else{}

      String month=DateTime.now().month.toString();
      if(month.length==1){month='0'+month;}else{}

      String year=DateTime.now().year.toString();
      String tempDate=year+'-'+month+'-'+day;


      dateFilterController.text=tempDate;
        permissionRequest();

        ref.read(gateRegisterProviderALLP).queryWithDateAndTime(tempDate,'udate');
        // ref.read(gateRegisterProviderALLP).queryData();

        ref.read(masterRegisterProviderALLP).loadUserData();
        _initSharedPreferences();

    });

  }

  Future<void> _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _getLastAlertTime();
    every30DaysBackup();
  }

  void every30DaysBackup(){
    final lastAlertTimeString = _prefs.getString('every30daysupdate');
    if (lastAlertTimeString != null) {
      _lastAlertTime30Days = DateTime.parse(lastAlertTimeString);
    } else {
      _lastAlertTime30Days = DateTime.now();
    }
    takeBackupEvery30Days();
  }

  void _getLastAlertTime() {
    final lastAlertTimeString = _prefs.getString('lastAlertTime');
    if (lastAlertTimeString != null) {
      _lastAlertTime = DateTime.parse(lastAlertTimeString);
    } else {
      _lastAlertTime = DateTime.now();
    }
    _showAlertIfNeeded();
  }

  void takeBackupEvery30Days(){
    final now = DateTime.now();
    final difference = now.difference(_lastAlertTime30Days).inDays;


    if (difference >= 30) {

     generateCSVFile();
    }
  }

  void _showAlertIfNeeded() {
    final now = DateTime.now();
    final difference = now.difference(_lastAlertTime).inDays;

    print('difference:'+difference.toString());
    // if (difference >= 15) {
    if (difference >= 10) {

      _showAlertForWarningBackup();
    }
  }

  Future<void> _showAlertForWarningBackup() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Important !!!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Please take backup every 10 Days. You might loose data'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel',style: TextStyle(color: Colors.black54),),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),

            TextButton(
              child: Text('Take BackUp Now.',style: TextStyle(color: pinkDark),),
              onPressed: () {
                Navigator.of(context).pop();
                _lastAlertTime = DateTime.now();
                _prefs.setString('lastAlertTime', _lastAlertTime.toIso8601String());
                generateCSVFile();
              },
            ),
          ],
        );
      },
    );
  }



  void permissionRequest () async{


    var status = await Permission.storage.status;
    if (status.isDenied) {
      print('Permission Status Deniend');
      try{status = await Permission.storage.request();}
      catch (e){print('Permission Exception:'+e.toString());}

    }
    else{
      if (status.isGranted) {}
      else {showAlertDialog_oneBtnPermission(context, 'Warning', 'Please enable permission in app settings');}
    }




  }

  Widget _buildHeader(){
    return Row(
      children: [
        SizedBox(width:20),

        Container(
            decoration: BoxDecoration(
                color: pinkDark,
                border: Border.all(color: Colors.black,width: 1)),
            width: 100,
            height: 55,
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Center(child: Text('S.No',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold))),)
        ),
        Container(
            decoration: BoxDecoration(color: pinkDark,border: Border.all(color: Colors.black,width: 1)),
            width: 100,
            height: 55,
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Center(child: Text('Actions',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),
              ),
              ),
              )
        ),

        // listItemHeader('Date'),
        listItemHeader('Name'),
        listItemHeader('In'),listItemHeader('Out'),
        listItemHeader('In'),listItemHeader('Out'),
        listItemHeader('In'),listItemHeader('Out'),
        listItemHeader('In'),listItemHeader('Out'),
        listItemHeader('In'),listItemHeader('Out'),
        listItemHeader('In'),listItemHeader('Out'),
        listItemHeader('In'),listItemHeader('Out'),
        listItemHeader('In'),listItemHeader('Out'),
        listItemHeader('In'),listItemHeader('Out'),
        listItemHeader('In'),listItemHeader('Out'),
      ],
    );

  }

  @override
  Widget build(BuildContext context) {
    _gateRegisterProvider=ref.watch(gateRegisterProviderALLP);
    _masterDataProvider=ref.watch(masterRegisterProviderALLP);

    return GestureDetector(
      onTap: (){
        // _timer.cancel();
        // _startInactivityTimer();
      },
      child: MaterialApp(

        home: Scaffold(
          
          floatingActionButton: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left:30,right: 10),
                child: FloatingActionButton(
                    onPressed: ()async{
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      String currentPassword=prefs.getString('password').toString();
                      if(currentPassword=='null'){
                        showToast(context, 'Password Not Found, Please Add Password In Settings');
                      }
                      else{
                        TextEditingController pwdController=TextEditingController();
                        showDialog(context: context, builder: (context) {
                          return AlertDialog(
                            content: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [



                                  TextFormField(

                                    obscureText: true,
                                    controller: pwdController,
                                    decoration: InputDecoration(
                                      suffixIcon: Icon(Icons.key,color: Maincolor,),
                                      label: Text('Enter Password To Continue'),
                                      labelStyle: TextStyle(fontSize: 14,color:Maincolor)
                                    ),
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  SizedBox(height: 20,),
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),color: Maincolor,

                                    ),
                                    width: 300,
                                    height:45 ,
                                    child: InkWell(
                                      onTap: (){
                                        String passwordValue= pwdController.text;

                                          if(passwordValue.isEmpty){
                                            showAlertDialog_oneBtn_msg(context, 'New Password must not be empty');
                                          }

                                          else if(passwordValue!=currentPassword){
                                            showAlertDialog_oneBtn_msg(context, 'Password Mis Match, Please try again');
                                          }
                                          else{
                                            pwdController.text='';
                                            Navigator.pop(context);
                                            showDialog(context: context, builder: (context) {
                                              return AlertDialog(
                                                content: Text('Are you sure want to delete all data in this list.'),
                                                actions: [
                                                  Padding(
                                                    padding: const EdgeInsets.only(bottom:10),
                                                    child: InkWell(
                                                        onTap:(){Navigator.pop(context);},
                                                        child: Text('Cancel',style: TextStyle(color: Colors.black,fontSize: 18))),
                                                  ),
                                                  SizedBox(width: 10,),
                                                  Padding(
                                                    padding: const EdgeInsets.only(bottom:10),
                                                    child: InkWell(
                                                        onTap:(){
                                                          Navigator.pop(context);
                                                          _gateRegisterProvider.deleteDB();
                                                        },
                                                        child: Text('Delete',style: TextStyle(color: pinkDark,fontSize: 18),)),
                                                  ),

                                                ],
                                              );
                                            },);
                                          }



                                      },
                                      child: Center(child: Text('VALIDATE',style: TextStyle(color: Colors.white),),),
                                    ),
                                  ),
                                  SizedBox(height: 20,),
                                  Container(

                                    width: 300,
                                    height:45 ,
                                    child: InkWell(
                                      onTap: (){
                                        pwdController.text='';
                                        Navigator.pop(context);
                                      },
                                      child: Center(child: Text('Cancel'),),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },);

                      }

                    },
                    heroTag: 'FAB1',
                    backgroundColor: pinkDark,
                    child: Icon(Icons.delete,color: Colors.white)),
              ),

              Padding(
                padding: EdgeInsets.only(left:10,right: 10),
                child: FloatingActionButton(
                  heroTag: 'FAB2',
                  backgroundColor: pinkDark,
                  onPressed: ()async{

                    // _gateRegisterProvider.deleteDB();
                    // Navigate to Settings Page
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Settings(),));
                  },
                  child: Icon(Icons.settings_rounded,color: Colors.white,),
                ),
              ),

              Padding(
                padding: EdgeInsets.only(left: 10,right: 10),
                child: FloatingActionButton(
                  heroTag: 'FAB3',
                  backgroundColor: pinkDark,
                  onPressed: (){
                    showDialog(context: context, builder: (context) => AlertDialog(
                      title: Text('Are you sure want to generate CSV file for back up'),
                      content: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [

                          InkWell(
                              onTap: (){
                                Navigator.pop(context);
                              },
                              child: Container(
                                  width: 150,height: 40,
                                  child: Center(child: Text('NO',style: TextStyle(fontSize: 15,color: Colors.black),)))),

                          InkWell(
                              onTap:(){
                                Navigator.pop(context);
                                generateCSVFile();


                              },
                              child: Container(
                                  width: 150,height: 40,
                                  child: Center(child: Text('YES',style: TextStyle(fontSize: 15,color: Colors.black),)))),

                        ],
                      ),
                    ),);

                  },
                  child: Icon(Icons.file_download,color: Colors.white,),
                ),
              ),

              Padding(
                padding: EdgeInsets.only(left:10,right: 10),
                child: FloatingActionButton(
                  heroTag: 'FAB6',
                  backgroundColor: pinkDark,
                  onPressed: (){

                    showNewRowDialog();
                  },
                  child: Icon(Icons.add,color: Colors.white,),
                ),
              ),

              // Padding(
              //   padding: EdgeInsets.only(left:10,right: 10),
              //   child: FloatingActionButton(
              //     heroTag: 'FAB7',
              //     backgroundColor: pinkDark,
              //     onPressed: (){
              //
              //       _gateRegisterProvider.queryData();
              //     },
              //     child: Icon(Icons.query_stats,color: Colors.white,),
              //   ),
              // ),

            ],
          ),
          appBar: AppBar(
            backgroundColor:pinkDark,
            title: InkWell(
                onTap:(){
                  secretLock.add('A');
                },
                child: Text('Yajur Mandir'.toUpperCase())),
            centerTitle: true,
            leading: InkWell(
                onTap: (){
                  secretLock.add('S');
                },
                child: Image.asset('assets/app_swami_thumb_nail_edited.png',height: 300,width: 300,fit:BoxFit.cover)),
            actions:[
              Padding(
                padding: const EdgeInsets.only(right:20),
                child: InkWell(
                    onTap: (){
                      secretLock.add('I');
                      checkPasswordWasCombined();
                    },
                    child: Image.asset('assets/sarvadarma logo_edited.png')),
              ),
            ]

          ),
          body: ListView(
            children: [
              if(!_gateRegisterProvider.loading )
                Padding(
                  padding: const EdgeInsets.only(top:20),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left:20),
                        child: Text('Filter By Date: ',style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500),),
                      ),
                      const SizedBox(width: 5,),
                     Container(
                       width: 200,
                       child: TextField(
                         onTap: () async {
                           final DateTime? picked = await showDatePicker(
                             context: context,
                             initialDate: DateTime.now(),
                             firstDate: DateTime.now().subtract(Duration(
                                 days: 30
                             )),
                             lastDate: DateTime.now(),
                             builder: (context, child) {
                               return Theme(
                                 data: ThemeData.light().copyWith(
                                   colorScheme: ColorScheme.light().copyWith(
                                     primary: pinkDark, // Color of the selected text
                                     onPrimary: Colors.white, // Color of the background
                                   ),
                                 ),
                                 child: child!,
                               );
                             },
                           );

                           if (picked != null) {

                             String year= picked.year.toString();
                             String month=picked.month.toString();
                             if(month.length==1){month='0'+month;}
                             else{}
                             String day=picked.day.toString();
                             if(day.length==1){day='0'+day;}
                             else{}
                             String _selectedDate=year+'-'+month+'-'+day;
                              dateFilterController.text=_selectedDate;


                             _gateRegisterProvider.queryWithDateAndTime(_selectedDate,'udate');

                             // timeController.text=finalDateTime;
                           }

                         },
                         readOnly: true,
                         controller: dateFilterController,
                         decoration: InputDecoration(border: InputBorder.none),
                         style: TextStyle(color: pinkDark,fontWeight: FontWeight.w600),
                       ),
                     )
                    ],
                  ),
                ),
                if(!_gateRegisterProvider.loading &&_gateRegisterProvider.userDataList.isNotEmpty)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Container(

                    width:4650,
                    // height: MediaQuery.of(context).size.height-100,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,

                      child: Padding(
                        padding: const EdgeInsets.only(bottom:15),
                        child: Container(
                          child: ListView.builder(

                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: _gateRegisterProvider.userDataList.length+1,
                            itemBuilder: (context, i) {
                              if(i==0){
                                return Padding(
                                  padding: const EdgeInsets.only(top:20),
                                  child: _buildHeader(),
                                );
                              }
                              else{
                                int index=i-1;
                                String vm=_gateRegisterProvider.userDataList[index].starTime1.toString();
                                print("vm:"+vm);
                                return Container(

                                  child: Row(
                                    children: [
                                      SizedBox(width:20),
                                      Container(
                                          decoration: BoxDecoration(border: Border.all(color: Colors.black,width: 1)),
                                          width: 100,
                                          height: 45,
                                          child: Padding(
                                            padding: const EdgeInsets.all(5),
                                            child: Center(child: Text((index+1).toString())),)
                                      ),
                                      Container(
                                          decoration: BoxDecoration(border: Border.all(color: Colors.black,width: 1)),
                                          width: 100,
                                          height: 45,
                                          child: Padding(
                                            padding: const EdgeInsets.all(5),
                                            child: Center(child: InkWell(
                                                onTap: (){
                                                  showDialog(context: context, builder: (context) => AlertDialog(
                                                    title: Text('Are you sure want to delete '+_gateRegisterProvider.userDataList[index].name.toString()),
                                                    content: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                      children: [
                                                          InkWell(
                                                              onTap:(){
                                                                _gateRegisterProvider.deleteData(_gateRegisterProvider.userDataList[index].id,dateFilterController.text);
                                                                Navigator.pop(context);
                                                              },
                                                              child: Container(
                                                                  width: 150,height: 40,
                                                                  child: Center(child: Text('OKAY',style: TextStyle(fontSize: 15,color: Colors.black),)))),

                                                          InkWell(
                                                              onTap: (){
                                                                Navigator.pop(context);
                                                              },
                                                              child: Container(
                                                                  width: 150,height: 40,
                                                                  child: Center(child: Text('CANCEL',style: TextStyle(fontSize: 15,color: Colors.black),)))),

                                                      ],
                                                    ),
                                                  ),);
                                                },
                                                child: Icon(Icons.delete_outline,color: pinkDark,size: 30,))),)
                                      ),

                                      // listItem( _gateRegisterProvider.userDataList[index].udate),

                                      InkWell(
                                          onTap:(){
                                            showNameEditDialog(_gateRegisterProvider.userDataList[index].id,_gateRegisterProvider.userDataList[index].name);
                                          },
                                          child: listItem( _gateRegisterProvider.userDataList[index].name)),


                                      InkWell(
                                          onTap:(){

                                            showTimeDialog('Start Time 1',_gateRegisterProvider.userDataList[index].id,'startTime1',_gateRegisterProvider.userDataList[index].name.toString());
                                          },
                                          child: listItem( splitPlus(_gateRegisterProvider.userDataList[index].starTime1))),


                                      InkWell(
                                          onTap:(){
                                            showTimeDialog('End Time 1',_gateRegisterProvider.userDataList[index].id,'endTime1',_gateRegisterProvider.userDataList[index].name.toString());
                                          },
                                          child: listItem(splitPlus(_gateRegisterProvider.userDataList[index].endTime1))),

                                      InkWell(
                                          onTap:(){
                                            showTimeDialog('Start Time 2',_gateRegisterProvider.userDataList[index].id,'startTime2',_gateRegisterProvider.userDataList[index].name.toString());
                                          },
                                          child: listItem( splitPlus(_gateRegisterProvider.userDataList[index].starTime2))),


                                      InkWell(

                                          onTap:(){
                                            showTimeDialog('End Time 2',_gateRegisterProvider.userDataList[index].id,'endTime2',_gateRegisterProvider.userDataList[index].name.toString());
                                          },

                                          child: listItem(splitPlus(_gateRegisterProvider.userDataList[index].endTime2))),

                                      InkWell(
                                          onTap:(){
                                            showTimeDialog('Start Time 3',_gateRegisterProvider.userDataList[index].id,'startTime3',_gateRegisterProvider.userDataList[index].name.toString());
                                          },
                                          child: listItem( splitPlus(_gateRegisterProvider.userDataList[index].starTime3))),

                                      InkWell(
                                          onTap:(){
                                            showTimeDialog('End Time 3',_gateRegisterProvider.userDataList[index].id,'endTime3',_gateRegisterProvider.userDataList[index].name.toString());
                                          },
                                          child: listItem(splitPlus(_gateRegisterProvider.userDataList[index].endTime3))),

                                      InkWell(
                                          onTap:(){
                                            showTimeDialog('Start Time 4',_gateRegisterProvider.userDataList[index].id,'startTime4',_gateRegisterProvider.userDataList[index].name.toString());
                                          },
                                          child: listItem( splitPlus(_gateRegisterProvider.userDataList[index].starTime4))),


                                      InkWell(
                                          onTap:(){
                                            showTimeDialog('End Time 4',_gateRegisterProvider.userDataList[index].id,'endTime4',_gateRegisterProvider.userDataList[index].name.toString());
                                          },
                                          child: listItem(splitPlus(_gateRegisterProvider.userDataList[index].endTime4))),

                                      InkWell(
                                          onTap:(){
                                            showTimeDialog('Start Time 5',_gateRegisterProvider.userDataList[index].id,'startTime5',_gateRegisterProvider.userDataList[index].name.toString());
                                          },
                                          child: listItem( splitPlus(_gateRegisterProvider.userDataList[index].starTime5))),

                                      InkWell(
                                          onTap:(){
                                            showTimeDialog('End Time 5',_gateRegisterProvider.userDataList[index].id,'endTime5',_gateRegisterProvider.userDataList[index].name.toString());
                                          },
                                          child: listItem(splitPlus(_gateRegisterProvider.userDataList[index].endTime5))),

                                      InkWell(
                                          onTap:(){
                                            showTimeDialog('Start Time 6',_gateRegisterProvider.userDataList[index].id,'startTime6',_gateRegisterProvider.userDataList[index].name.toString());
                                          },
                                          child: listItem( splitPlus(_gateRegisterProvider.userDataList[index].starTime6))),

                                      InkWell(
                                          onTap:(){
                                            showTimeDialog('End Time 6',_gateRegisterProvider.userDataList[index].id,'endTime6' ,_gateRegisterProvider.userDataList[index].name.toString());
                                          },
                                          child: listItem(splitPlus(_gateRegisterProvider.userDataList[index].endTime6))),

                                      InkWell(
                                          onTap:(){
                                            showTimeDialog('Start Time 7',_gateRegisterProvider.userDataList[index].id,'startTime7',_gateRegisterProvider.userDataList[index].name.toString());
                                          },
                                          child: listItem( splitPlus(_gateRegisterProvider.userDataList[index].starTime7))),

                                      InkWell(
                                          onTap:(){
                                            showTimeDialog('End Time 7',_gateRegisterProvider.userDataList[index].id,'endTime7',_gateRegisterProvider.userDataList[index].name.toString());
                                          },
                                          child: listItem(splitPlus(_gateRegisterProvider.userDataList[index].endTime7))),

                                      InkWell(
                                          onTap:(){
                                            showTimeDialog('Start Time 8',_gateRegisterProvider.userDataList[index].id,'startTime8',_gateRegisterProvider.userDataList[index].name.toString());
                                          },
                                          child: listItem( splitPlus(_gateRegisterProvider.userDataList[index].starTime8))),

                                      InkWell(
                                          onTap:(){
                                            showTimeDialog('End Time 8',_gateRegisterProvider.userDataList[index].id,'endTime8',_gateRegisterProvider.userDataList[index].name.toString());
                                          },
                                          child: listItem(splitPlus(_gateRegisterProvider.userDataList[index].endTime8))),

                                      InkWell(
                                          onTap:(){
                                            showTimeDialog('Start Time 9',_gateRegisterProvider.userDataList[index].id,'startTime9',_gateRegisterProvider.userDataList[index].name.toString());
                                          },
                                          child: listItem( splitPlus(_gateRegisterProvider.userDataList[index].starTime9))),


                                      InkWell(
                                          onTap:(){
                                            showTimeDialog('End Time 9',_gateRegisterProvider.userDataList[index].id,'endTime9',_gateRegisterProvider.userDataList[index].name.toString());
                                          },
                                          child: listItem(splitPlus(_gateRegisterProvider.userDataList[index].endTime9))),

                                      InkWell(
                                          onTap:(){
                                            showTimeDialog('Start Time 10',_gateRegisterProvider.userDataList[index].id,'startTime10',_gateRegisterProvider.userDataList[index].name.toString());
                                          },
                                          child: listItem( splitPlus(_gateRegisterProvider.userDataList[index].starTime10))),

                                      InkWell(
                                          onTap:(){
                                            showTimeDialog('End Time 10',_gateRegisterProvider.userDataList[index].id,'endTime10',_gateRegisterProvider.userDataList[index].name.toString());
                                          },
                                          child: listItem(splitPlus(_gateRegisterProvider.userDataList[index].endTime10))),
                                      const SizedBox(width:15,),
                                    ],
                                  ),
                                );
                              }

                            },),
                        ),
                      ),
                    ),
                  ),
                ),
                if(!_gateRegisterProvider.loading && _gateRegisterProvider.userDataList.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top:200),
                      child: Text('No Data Found',style: TextStyle(
                        fontSize: 17,color: Colors.black),),
                    ),
                  ),
              if(_gateRegisterProvider.loading)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top:200),
                    child: SpinKitCircle(color: pinkDark,size: 45),
                  ),
                )
            ],

          ),
        ),
      ),
    );
  }



  Widget listItemHeader(String value){
    return   Container(

        decoration: BoxDecoration(color:pinkDark,border: Border.all(color: Colors.black,width: 1)),
        width: 200,
        height: 55,
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Center(child: Text(value,style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold))),
        ));

  }

  Widget listItem(String value){
    return   Container(

        decoration: BoxDecoration(border: Border.all(color: Colors.black,width: 1)),
        width: 200,
        height: 45,
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Center(child: Text(value)),
        ));

  }

  String splitPlus(String value){

    if(value.isEmpty){
      return '';
    }
    else{
      return _formatTime(value.split(' ')[1].toString());
    }

  }

  String _formatTime(String timeString) {
    List<String> parts = timeString.split(':');
    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);
    TimeOfDay timeOfDay = TimeOfDay(hour: hour, minute: minute);
    DateTime dateTime = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, timeOfDay.hour, timeOfDay.minute);
    String formattedTime = DateFormat.jm().format(dateTime);
    return formattedTime;
  }

  showNameEditDialog(int id ,String name){
    TextEditingController nameController1=TextEditingController();
    nameController1.text=name;
    showDialog(context: context, builder: (context) => AlertDialog(

      content: Padding(
        padding: const EdgeInsets.only(left:20,right:20),
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.fromLTRB(10, 0, 10, 0),

            child: Container(


              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [

                  SizedBox(height: 20,),


                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: pinklightDark2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child:Row(
                        children: [
                          Expanded(
                            flex:9,
                            child: TextField(
                              controller: nameController1,

                              style:const TextStyle(color: pinkDark),



                              decoration:const InputDecoration(

                                  hintText: 'ENTER NAME',
                                  hintStyle: TextStyle(
                                      color: pinkDark
                                  ),
                                  border: InputBorder.none),

                            ),
                          ),
                          Expanded(flex:1,child: InkWell(
                              onTap:(){
                                if(_masterDataProvider.userListGate.isEmpty){
                                  showAlertDialog_oneBtn(context, 'Warning', 'No regular visitors list found, Please add it in settings');
                                }
                                else{
                                  showDialog(context: context, builder: (context) {
                                    return  AlertDialog(
                                      content: SingleChildScrollView(
                                        child: Container(
                                          height: _masterDataProvider.userListGate.length*80, // Adjust the height as needed
                                          width: 300,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Align(
                                                  alignment:AlignmentDirectional.topEnd,
                                                  child: InkWell(
                                                      onTap:(){Navigator.pop(context);},
                                                      child: Icon(Icons.close,color: pinkDark,size: 20,))),
                                              ListView.builder(
                                                itemCount: _masterDataProvider.userListGate.length,
                                                shrinkWrap:true,
                                                physics: NeverScrollableScrollPhysics(),
                                                itemBuilder: (context, index) {
                                                  var item=_masterDataProvider.userListGate[index];
                                                  return
                                                    ListTile(
                                                      onTap: (){
                                                        nameController1.text=item.name;
                                                        print('Testing Name2::'+nameController1.text);
                                                        Navigator.pop(context);
                                                      },
                                                      leading: checkImageWasPresentOrNot(item.profileImage),
                                                      title: Text(item.name),
                                                    );
                                                },),

                                            ],
                                          ),
                                        ),
                                      ),
                                    );

                                  },);
                                }
                              },
                              child: Center(child: Icon(Icons.arrow_drop_down))))
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20,),



                  InkWell(
                    onTap: (){
                      String name=removeLastSpace(nameController1.text);
                      print('Testing line1:'+name);

                      if(name.isEmpty){
                        showAlertDialog_oneBtn(context, 'Warning', 'Please Enter Name');
                      }

                      else{
                        _gateRegisterProvider.updateData(id,'name',name,dateFilterController.text);
                        nameController1.text='';

                        Navigator.pop(context);
                      }

                    },
                    child: Container(
                      color: Colors.green,
                      width: MediaQuery.of(context).size.width/2,
                      height: 45,
                      child: Center(
                        child: Text("Update Name",style: TextStyle(color: Colors.white),),
                      ),
                    ),

                  ),

                  SizedBox(height: 20,),
                  InkWell(
                    onTap: (){


                      Navigator.pop(context);},
                    child: Container(
                      color: Colors.red,
                      width: MediaQuery.of(context).size.width/2,
                      height: 45,
                      child: Center(
                        child: Text("Cancel",style: TextStyle(color: Colors.white),),
                      ),
                    ),

                  ),

                  SizedBox(height: 20,),

                ],
              ),
            ),
          ),
        ),
      ),

    ),);
  }

  Widget customAutoComplete(TextEditingController name1Controller){
    return Autocomplete<NameSuggesstionModel>(
      // options: _masterDataProvider.userListGate,

      displayStringForOption: (NameSuggesstionModel suggestion) => suggestion.name,
      onSelected: (NameSuggesstionModel selectedSuggestion) {
        name1Controller.text=selectedSuggestion.name;
        print('You selected: ${selectedSuggestion.name}');
      },
      fieldViewBuilder: (BuildContext context, TextEditingController textEditingController,
          FocusNode focusNode, VoidCallback onFieldSubmitted) {
        return TextFormField(
          controller: textEditingController,
          focusNode: focusNode,
          style: TextStyle(color: pinkDark),
          decoration: InputDecoration(
            border: InputBorder.none, // Hides the border
          ),
          onChanged: (String value) {
            // You can use this callback to filter suggestions based on user input
          },
          onFieldSubmitted: (String value) {
            // Handle submitted value if needed
          },
        );
      },
      optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<NameSuggesstionModel> onSelected,
          Iterable<NameSuggesstionModel> options) {
        return Material(
          elevation: 4.0,
          child: Container(
            constraints: BoxConstraints(maxHeight: 200.0),
            child: ListView.builder(
              itemCount: options.length,
              itemBuilder: (BuildContext context, int index) {
                final suggestion = options.elementAt(index);
                return Container(
                  width: MediaQuery.of(context).size.width/2,
                  child: ListTile(
                    leading:checkImageWasPresentOrNot(suggestion.profileImage), // Add image here
                    title: Text(suggestion.name),
                    onTap: () {
                      onSelected(suggestion);
                    },
                  ),
                );
              },
            ),
          ),
        );
      },
      optionsBuilder: (TextEditingValue textEditingValue) {
      return _masterDataProvider.userListGate;
      },
    );
  }
  showTimeDialog(String cellName,int id,String tagName, String memberName){

    String finalDateTime='';
    String value='';
    TextEditingController timeController=TextEditingController();

    if(cellName.startsWith('Start Time')){
      value='Select In Time';
    }
    else{
      value='Select Out Time';
    }
    timeController.text=value;
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext bc){
          return AlertDialog(
            content: Padding(
              padding: const EdgeInsets.only(left:20,right:20),
              child: SingleChildScrollView(
                child: Container(
                  margin: EdgeInsets.fromLTRB(10, 0, 10, 0),

                  child: Container(


                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: 20,),
                        Text('Visitor Name: '+memberName.toUpperCase()),
                        SizedBox(height: 10,),


                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: pinklightDark2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: TextField(
                              textAlign: TextAlign.center,
                              onTap: () async {
                                final TimeOfDay? pickedTime = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.fromDateTime( DateTime.now()),
                                  builder: (context, child) {
                                    return Theme(
                                      data: ThemeData.light().copyWith(
                                        colorScheme: ColorScheme.light().copyWith(
                                          primary: pinkDark, // Color of the selected text
                                          onPrimary: Colors.white, // Color of the background
                                        ),
                                      ),
                                      child: child!,
                                    );
                                  },
                                );



                                if (pickedTime != null) {

                                  String _selectedDate =dateFilterController.text ;

                                  String hr=pickedTime.hour.toString();
                                  if(hr.length==1){hr='0'+hr;}
                                  else{}
                                  String min=pickedTime.minute.toString();
                                  if(min.length==1){min='0'+min;}
                                  else{}
                                  String _selectedTime= hr+':'+min+':00';


                                  finalDateTime=_selectedDate+' '+_selectedTime;
                                  print('fDateTime:'+finalDateTime.toString());
                                  timeController.text=_formatTime(_selectedTime.toString());
                                }
                              },

                              style:const TextStyle(
                                fontSize: 16,
                                color: pinkDark,
                              ),
                              readOnly: true,
                              controller: timeController,
                              keyboardType: TextInputType.text,
                              textCapitalization: TextCapitalization.words,
                              decoration:const InputDecoration(
                                border: InputBorder.none,
                                hintText:'',
                                hintStyle: TextStyle(
                                  fontSize: 16,
                                  letterSpacing: 2,
                                  color: pinkDark,
                                ),
                              ),

                            ),
                          ),
                        ),

                        SizedBox(height: 30,),

                        InkWell(
                          onTap: (){

                            String starTime=timeController.text;
                            if(starTime==value){
                              showAlertDialog_oneBtn(context, 'Warning', 'Please  Select '+value);
                            }
                            else{
                              _gateRegisterProvider.updateData(id,tagName,finalDateTime,dateFilterController.text);


                              Navigator.pop(context);

                            }

                          },
                          child: Container(
                            color: Colors.green,
                            width: MediaQuery.of(context).size.width/2,
                            height: 45,
                            child: Center(
                              child: Text("Update"),
                            ),
                          ),

                        ),

                        SizedBox(height: 20,),
                        InkWell(
                          onTap: (){

                            Navigator.pop(context);

                          },

                          child: Container(
                            color: Colors.red,
                            width: MediaQuery.of(context).size.width/2,
                            height: 45,
                            child: Center(
                              child: Text("Cancel",style: TextStyle(color: Colors.white),),
                            ),
                          ),

                        ),
                        SizedBox(height: 10,),
                        InkWell(
                          onTap: (){

                            _gateRegisterProvider.updateData(id,tagName,'',dateFilterController.text);
                            Navigator.pop(context);

                          },
                          child: Container(
                            color: Colors.amberAccent,
                            width: MediaQuery.of(context).size.width/2,
                            height: 45,
                            child: Center(
                              child: Text("Mark Empty"),
                            ),
                          ),

                        ),
                        SizedBox(height: 20,),

                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }
    );
  }

  void showNewRowDialog()async{



    String finalDateTime='';
    TextEditingController nameController=TextEditingController();
    TextEditingController startTimeController=TextEditingController();
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext bc){
          return AlertDialog(
            content: Padding(
              padding: const EdgeInsets.only(left:20,right:20),
              child: SingleChildScrollView(
                child: Container(


                  child: Container(


                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: 20,),

                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: pinklightDark2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child:Row(
                              children: [
                                Expanded(
                                  flex:6,
                                  child:  AutoCompleteTextField<NameSuggesstionModel>(
                                    controller: nameController,

                                    style:const TextStyle(color: pinkDark),
                                    key: GlobalKey(),
                                    clearOnSubmit: false,
                                    suggestions: _masterDataProvider.userListGate,

                                    decoration:const InputDecoration(

                                        hintText: 'ENTER NAME',
                                        hintStyle: TextStyle(
                                            color: pinkDark
                                        ),
                                        border: InputBorder.none),
                                    itemFilter: (item, query) {
                                      print('Query: ${query.toLowerCase()}');
                                      return item.name.toLowerCase().startsWith(query.toLowerCase());
                                    },
                                    itemSorter: (a, b) {
                                      return a.name.compareTo(b.name);
                                    },
                                    itemSubmitted: (item) {
                                      // Do something with the selected item
                                      nameController.text=item.name;
                                      print('Selected: ${item.name}');
                                    },
                                    itemBuilder: (context, item) {
                                      File photoFile=File(item.profileImage.toString());
                                      return Container(
                                        decoration: BoxDecoration(
                                            border: Border(
                                                bottom: BorderSide(color: Colors.black54,)
                                            )
                                        ),
                                        height: 70,
                                        child: Center(
                                          child: Row(
                                            children: [
                                              checkImageWasPresentOrNot(item.profileImage),

                                              SizedBox(width: 8),
                                              Text(item.name),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Expanded(flex:1,child: InkWell(
                                    onTap:(){
                                      if(_masterDataProvider.userListGate.isEmpty){
                                        showAlertDialog_oneBtn(context, 'Warning', 'No regular visitors list found, Please add it in settings');
                                      }
                                      else{
                                        showDialog(context: context, builder: (context) {
                                          return  AlertDialog(
                                            content: SingleChildScrollView(
                                              child: Container(
                                                height: _masterDataProvider.userListGate.length*80, // Adjust the height as needed
                                                width: 300,
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Align(
                                                        alignment:AlignmentDirectional.topEnd,
                                                        child: InkWell(
                                                            onTap:(){Navigator.pop(context);},
                                                            child: Icon(Icons.close,color: pinkDark,size: 20,))),
                                                    ListView.builder(
                                                      itemCount: _masterDataProvider.userListGate.length,
                                                        shrinkWrap:true,
                                                        physics: NeverScrollableScrollPhysics(),
                                                        itemBuilder: (context, index) {
                                                        var item=_masterDataProvider.userListGate[index];
                                                        return
                                                        ListTile(
                                                          onTap: (){
                                                            nameController.text=item.name;
                                                            Navigator.pop(context);
                                                          },
                                                          leading: checkImageWasPresentOrNot(item.profileImage),
                                                          title: Text(item.name),
                                                        );
                                                    },),

                                                  ],
                                                ),
                                              ),
                                            ),
                                          );

                                        },);
                                      }
                                    },
                                    child: Center(child: Icon(Icons.arrow_drop_down,color: pinkDark,))))
                              ],
                            ),
                          ),
                        ),


                        SizedBox(height: 20,),

                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: pinklightDark2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: TextField(
                              textAlign: TextAlign.start,
                              onTap: () async  {
                                  final TimeOfDay? pickedTime = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.fromDateTime( DateTime.now()),
                                    builder: (context, child) {
                                      return Theme(
                                        data: ThemeData.light().copyWith(
                                          colorScheme: ColorScheme.light().copyWith(
                                            primary: pinkDark, // Color of the selected text
                                            onPrimary: Colors.white, // Color of the background
                                          ),
                                        ),
                                        child: child!,
                                      );
                                    },
                                  );

                                  if (pickedTime != null) {


                                    String _selectedDate =dateFilterController.text ;

                                    String hr=pickedTime.hour.toString();
                                    if(hr.length==1){hr='0'+hr;}
                                    else{}
                                    String min=pickedTime.minute.toString();
                                    if(min.length==1){min='0'+min;}
                                    else{}
                                    String _selectedTime= hr+':'+min+':00';


                                    finalDateTime=_selectedDate+' '+_selectedTime;
                                    print('fDateTime:'+finalDateTime.toString());
                                    startTimeController.text=_formatTime(_selectedTime.toString());
                                  }
                                },




                              style:const TextStyle(
                                fontSize: 16,
                                color: pinkDark,
                              ),
                              readOnly: true,
                              controller: startTimeController,
                              keyboardType: TextInputType.text,
                              textCapitalization: TextCapitalization.words,
                              decoration:const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'SELECT IN TIME',
                                  hintStyle: TextStyle(
                                    fontSize: 16,
                                    letterSpacing: 2,
                                    color: pinkDark,
                                  ),
                              ),

                            ),
                          ),
                        ),

                        SizedBox(height: 30,),

                        InkWell(

                          onTap: (){
                            String name=removeLastSpace(nameController.text);
                            String starTime=startTimeController.text;
                            if(name.isEmpty){
                              showAlertDialog_oneBtn(context, 'Warning', 'Please Enter Name');
                            }
                            // else if(starTime.isEmpty){
                            //   showAlertDialog_oneBtn(context, 'Warning', 'Please Enter Start Time');
                            // }
                            else if(checkRegularMemberPresentOrNot(name)){
                              showAlertDialog_oneBtn(context, 'Warning', 'Member was already added in list');
                            }
                            else{

                              print('FinaldateTime:'+finalDateTime.toString()+':');
                              print('FilterDate:'+dateFilterController.text.toString());

                              _gateRegisterProvider.insertDataFirstTime(name,finalDateTime,dateFilterController.text);

                              Navigator.pop(context);

                            }

                          },
                          child: Container(
                            color: Colors.green,
                            width: MediaQuery.of(context).size.width/2,
                            height: 45,
                            child: Center(
                              child: Text("Add Entry",style: TextStyle(color: Colors.white),),
                            ),
                          ),

                        ),

                        SizedBox(height: 20,),

                        InkWell(
                          onTap: (){
                            Navigator.pop(context);


                            },
                          child: Container(
                            color: Colors.red,
                            width: MediaQuery.of(context).size.width/2,
                            height: 45,

                            child: Center(
                              child: Text("Cancel",style: TextStyle(color: Colors.white),),
                            ),
                          ),

                        ),

                        SizedBox(height: 20,),

                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }
    );
  }


  String formatDate(String value) {
    DateTime date=DateTime.parse(value);
    String result=DateFormat('yyyy-MM-dd').format(date);
    print('DBOutputResult'+result);
    return result;
  }

  Future<void> writeCsvFile(List<List<dynamic>> rows) async {
    showLoadingView(context);
     String rootPath=await getFolderPath();

     String filesubHeader=DateTime.now().day.toString()+'-'+DateTime.now().month.toString()+'-'+DateTime.now().year.toString()+'-'+DateTime.now().hour.toString()+'-'+DateTime.now().minute.toString()+'-'+DateTime.now().second.toString();
     String filePath = rootPath+'/Yajur Mandir CSV-'+filesubHeader+'.csv';

     String csvData = ListToCsvConverter().convert(rows);


    File file = File(filePath);
    await file.writeAsString(csvData);

    print('Generated filePath:'+filePath.toString());


    Future.delayed(const Duration(seconds: 5),(){
    insertPathToSharedPrefernce(filesubHeader+'.csv');
    });

    print('CSV file created at: $filePath');
  }

  Future<String> getFolderPath() async {

      final Directory? appDirectory = await DownloadsPath.downloadsDirectory();
      final String folderPath = '${appDirectory!.path}/Yajur Mandir';
      final Directory folder = Directory(folderPath);
      if (!(await folder.exists())) {
        await folder.create(recursive: true);
        print('Folder created at: $folderPath');

      }
      return folderPath;

  }

  void insertPathToSharedPrefernce(String filePath) async{
    Navigator.pop(context);
    showAlertDialog_oneBtn(context, 'Success', 'File Downloaded Successfully, Please check in  Storage --> Downloads --> Yajur Mandir --> '+filePath);
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // print('Generated filePath1:'+filePath.toString());
    //
    // List<String> tempfilePathList=[];
    // List<String> tempfileTimeList=[];
    //
    // print('Generated filePath2:'+filePath.toString());
    //
    // List<String>? filePathList=prefs.getStringList('file_paths');
    // print('Generated filePath3:'+filePath.toString());
    // List<String>? fileTimeList=prefs.getStringList('file__created_time');
    //
    // print('Generated filePath4:'+filePath.toString());
    //
    // if(filePathList==null){
    //   print('filepath was null');
    //   tempfilePathList.add(filePath);
    //
    //   prefs.setStringList('file_paths', tempfilePathList);
    // }
    // else{
    //   print('filepath was not null');
    //   filePathList!.add(filePath);
    //
    //   prefs.setStringList('file_paths', filePathList);
    // }
    //
    //
    // List<String>? d=prefs.getStringList('file_paths');
    // print("FLength"+d!.length.toString());
    // Navigator.pop(context);
  }

  void generateCSVFile() async {
    List<Map<String,dynamic>> data=await _gateRegisterProvider.writeToCSVFile();
    if(data.isNotEmpty){
      List<List<dynamic>> rows = [

        [
          'id',
          'Name' ,
          'Date' ,
          'Start Time1' ,
          'End Time1',
          'Start Time2' ,
          'End Time2',
          'Start Time3' ,
          'End Time3',
          'Start Time4' ,
          'End Time4',
          'Start Time5' ,
          'End Time5',
          'Start Time6' ,
          'End Time6',
          'Start Time7' ,
          'End Time7',
          'Start Time8' ,
          'End Time8',
          'Start Time9' ,
          'End Time9',
          'Start Time10' ,
          'End Time10',
        ],

        ...data.map((entry) => [
          entry['id'],
          entry['name'] ,
          entry['udate'] ,
          entry['startTime1'] ,
          entry['endTime1'],
          entry['startTime2'] ,
          entry['endTime2'] ,
          entry['startTime3'] ,
          entry['endTime3'] ,
          entry['startTime4'] ,
          entry['endTime4'] ,
          entry['startTime5'] ,
          entry['endTime5'] ,
          entry['startTime6'] ,
          entry['endTime6'] ,
          entry['startTime7'] ,
          entry['endTime7'] ,
          entry['startTime8'] ,
          entry['endTime8'] ,
          entry['startTime9'] ,
          entry['endTime9'] ,
          entry['startTime10'] ,
          entry['endTime10']
        ]

        ) // Data rows
      ];

      writeCsvFile(rows);
    }
    else{
      showAlertDialog_oneBtn(context, 'Warning', 'No Data Found , Unable To Export CSV');
    }

  }

  void showFilterDialog(){

    String finalDateTime='';

    TextEditingController timeController=TextEditingController();

    timeController.text='';
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext bc){
          return AlertDialog(
            content: Padding(
              padding: const EdgeInsets.only(left:20,right:20),
              child: SingleChildScrollView(
                child: Container(
                  margin: EdgeInsets.fromLTRB(10, 0, 10, 0),

                  child: Container(


                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: 20,),


                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: pinklightDark2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: TextField(
                              textAlign: TextAlign.center,
                              onTap: () async {
                                final DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now().subtract(Duration(
                                    days: 30
                                  )),
                                  lastDate: DateTime.now(),
                                  builder: (context, child) {
                                    return Theme(
                                      data: ThemeData.light().copyWith(
                                        colorScheme: ColorScheme.light().copyWith(
                                          primary: pinkDark, // Color of the selected text
                                          onPrimary: Colors.white, // Color of the background
                                        ),
                                      ),
                                      child: child!,
                                    );
                                  },
                                );

                                if (picked != null) {

                                  String year= picked.year.toString();
                                  String month=picked.month.toString();
                                  if(month.length==1){month='0'+month;}
                                  else{}
                                  String day=picked.day.toString();
                                  if(day.length==1){day='0'+day;}
                                  else{}
                                  String _selectedDate=year+'-'+month+'-'+day;



                                  finalDateTime=_selectedDate;
                                  print('fDateTime:'+finalDateTime.toString());

                                  timeController.text=_selectedDate;
                                  // timeController.text=finalDateTime;
                                }

                              },


                              style:const TextStyle(
                                fontSize: 16,
                                color: pinkDark,
                              ),
                              readOnly: true,
                              controller: timeController,
                              keyboardType: TextInputType.text,
                              textCapitalization: TextCapitalization.words,
                              decoration:const InputDecoration(
                                border: InputBorder.none,
                                hintText:'Select Date',
                                hintStyle: TextStyle(
                                  fontSize: 16,
                                  letterSpacing: 2,
                                  color: pinkDark,
                                ),
                              ),

                            ),
                          ),
                        ),

                        SizedBox(height: 30,),

                        InkWell(
                          onTap: (){

                            String starTime=timeController.text;
                            if(starTime.isEmpty){
                              showAlertDialog_oneBtn(context, 'Warning', 'Please Select Date');
                            }
                            else{
                              _gateRegisterProvider.queryWithDateAndTime(timeController.text,'udate');


                              Navigator.pop(context);

                            }

                          },
                          child: Container(
                            color: Colors.green,
                            width: MediaQuery.of(context).size.width/2,
                            height: 45,
                            child: Center(
                              child: Text("Filter Now"),
                            ),
                          ),

                        ),

                        SizedBox(height: 20,),
                        InkWell(
                          onTap: (){

                            Navigator.pop(context);

                          },

                          child: Container(
                            color: Colors.red,
                            width: MediaQuery.of(context).size.width/2,
                            height: 45,
                            child: Center(
                              child: Text("Cancel",style: TextStyle(color: Colors.white),),
                            ),
                          ),

                        ),

                        SizedBox(height: 20,),

                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }
    );

  }
  bool checkRegularMemberPresentOrNot(String value){
    bool status=false;
    int visitorsListLength=_gateRegisterProvider.userDataList.length;
    var item=_gateRegisterProvider.userDataList;
    for(int i=0 ; i<visitorsListLength; i++){
      print(item[i].name.toLowerCase()+"=="+value.toLowerCase());
      if(value.toLowerCase()==item[i].name.toLowerCase()){
        status=true;
      }
    }

    return status;
  }
  String removeLastSpace(String input) {
    if (input.isNotEmpty && input.endsWith(' ')) {
      return input.substring(0, input.length - 1);
    } else {
      return input;
    }
  }

  Widget checkImageWasPresentOrNot (String photoUrl){


    if(photoUrl.isNotEmpty){
      File imageFile=File(photoUrl);
      return Image.file(imageFile,width: 25,height: 25,);
    }
    else{
      return Icon(Icons.image_not_supported_outlined);
    }
  }
  checkPasswordWasCombined(){
    String secretKeyQueried=secretLock.join('-');
    if(secretKeyQueried==secretLockKey){
      showDialog(context: context, builder: (context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              Text('Are you sure want to delete password for DB Deletion ?'),
              SizedBox(height: 30,),
              InkWell(
                  onTap: ()async{
                    SharedPreferences pref=await SharedPreferences.getInstance();
                    pref.remove('password');
                    Navigator.pop(context);
                    showToast(context, 'Successfully password removed');
                  },
                  child: Container(
                    color: Maincolor,
                      width: 200,height: 45,
                      child: Center(child: Text('OK')))),
              SizedBox(height: 10,),
              InkWell(
                  onTap: ()async{
                    Navigator.pop(context);
                  },
                  child: Text('CANCEL'))
            ],
          ),
        );
      },);
    }
  }
}
