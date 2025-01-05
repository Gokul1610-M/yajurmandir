import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:yajurmandir/NameSuggesstionModel.dart';

import 'Utils/DBHelper.dart';

class GateRegisterProvider extends ChangeNotifier{
  bool loading=true;
  List<UserData> userDataList=[];
  List<MasterData> masterDataList=[];
  DBHelper dbHelper = DBHelper.instance;


  intialLoad()  {


    notifyListeners();
  }

  queryData()async{
    List<Map<String,dynamic>> maps= await dbHelper.queryAll();
    print("Inserted Lengthg:"+maps.length.toString());
    userDataList=List.generate(maps.length, (i) {
      return  UserData(
          id: maps[i]['id'],
          name: maps[i]['name'],
          udate: maps[i]['udate'],

          starTime1: maps[i]['startTime1'], endTime1: maps[i]['endTime1'],
          starTime2: maps[i]['startTime2'], endTime2: maps[i]['endTime2'],
          starTime3: maps[i]['startTime3'], endTime3: maps[i]['endTime3'],
          starTime4: maps[i]['startTime4'], endTime4: maps[i]['endTime4'],
          starTime5: maps[i]['startTime5'], endTime5: maps[i]['endTime5'],
          starTime6: maps[i]['startTime6'], endTime6: maps[i]['endTime6'],
          starTime7: maps[i]['startTime7'], endTime7: maps[i]['endTime7'],
          starTime8: maps[i]['startTime8'], endTime8: maps[i]['endTime8'],
          starTime9: maps[i]['startTime9'], endTime9: maps[i]['endTime9'],
          starTime10: maps[i]['startTime10'], endTime10: maps[i]['endTime10']);
    });
    loading=false;
    notifyListeners();  
  }

  insertDataFirstTime(String name, String startTime1,String filterDate) async {

    print('filterDate:'+filterDate.toString());
    Map<String, dynamic> row = {
      'name': name,
      // 'udate': startTime1.split(' ')[0].toString(),
      'udate':filterDate,
      'startTime1': startTime1,
      'endTime1': '',
      'startTime2': '',
      'endTime2': '',
      'startTime3': '',
      'endTime3': '',
      'startTime4': '',
      'endTime4': '',
      'startTime5': '',
      'endTime5': '',
      'startTime6': '',
      'endTime6': '',
      'startTime7': '',
      'endTime7': '',
      'startTime8': '',
      'endTime8': '',
      'startTime9': '',
      'endTime9': '',
      'startTime10': '',
      'endTime10': '',

    };
    int id = await dbHelper.insert(row);
    queryWithDateAndTime(filterDate, 'udate');

    notifyListeners();
  }

  deleteData(int id,var filterDate) async {

    await dbHelper.delete(id);
    queryWithDateAndTime(filterDate, 'udate');
  }


  updateData(int id, String tagName,String tagValue, String filterDate) async {
    Map<String, dynamic> row = {
      tagName: tagValue
    };

    await dbHelper.update(row,id);

    queryWithDateAndTime(filterDate, 'udate');
  }

  Future<List<Map<String, dynamic>>> writeToCSVFile() async {
    List<Map<String, dynamic>> fetchedData=await dbHelper.fetchDataFromDatabase();
    return fetchedData;
  }

  deleteDB()async{
  await dbHelper.deletDatabase();
  userDataList=[];
  loading=false;
  notifyListeners();
  }

  deleteTable() async {
    await dbHelper.deleteTable();
    userDataList=[];
    loading=false;
    notifyListeners();
  }

  void queryWithDateAndTime(String value, String columnName) async{

    try{List<Map<String,dynamic>> maps= await dbHelper.queryRecordsFilter(columnName,value);
    print("Queryed Record:"+maps.length.toString());
    userDataList=List.generate(maps.length, (i) {
      return  UserData(
          id: maps[i]['id'],
          name: maps[i]['name'],
          udate: maps[i]['udate'],

          starTime1: maps[i]['startTime1'], endTime1: maps[i]['endTime1'],
          starTime2: maps[i]['startTime2'], endTime2: maps[i]['endTime2'],
          starTime3: maps[i]['startTime3'], endTime3: maps[i]['endTime3'],
          starTime4: maps[i]['startTime4'], endTime4: maps[i]['endTime4'],
          starTime5: maps[i]['startTime5'], endTime5: maps[i]['endTime5'],
          starTime6: maps[i]['startTime6'], endTime6: maps[i]['endTime6'],
          starTime7: maps[i]['startTime7'], endTime7: maps[i]['endTime7'],
          starTime8: maps[i]['startTime8'], endTime8: maps[i]['endTime8'],
          starTime9: maps[i]['startTime9'], endTime9: maps[i]['endTime9'],
          starTime10: maps[i]['startTime10'], endTime10: maps[i]['endTime10']);
    });}
    catch (e){}



    loading=false;
    notifyListeners();
  }






}


class UserData{

  int id;
  String udate;
  String name;
  String starTime1,endTime1;
  String starTime2,endTime2;
  String starTime3,endTime3;
  String starTime4,endTime4;
  String starTime5,endTime5;
  String starTime6,endTime6;
  String starTime7,endTime7;
  String starTime8,endTime8;
  String starTime9,endTime9;
  String starTime10,endTime10;

  UserData({
    required this.id,
    required this.name,
    required this.udate,
    required this.starTime1,
    required this.endTime1,
    required this.starTime2,
    required this.endTime2,
    required this.starTime3,
    required this.endTime3,
    required this.starTime4,
    required this.endTime4,
    required this.starTime5,
    required this.endTime5,
    required this.starTime6,
    required this.endTime6,
    required this.starTime7,
    required this.endTime7,
    required this.starTime8,
    required this.endTime8,
    required this.starTime9,
    required this.endTime9,
    required this.starTime10,
    required this.endTime10});

  factory UserData.fromMap(Map<String, dynamic> map) {
    return UserData(
      id: map['id'],
      name: map['name'],
      udate: map['udate'],
      starTime1: map['startTime1'],
      endTime1: map['endTime1'],
      starTime2: map['startTime2'],
      endTime2: map['endTime2'],
      starTime3: map['startTime3'],
      endTime3: map['endTime3'],
      starTime4: map['startTime4'],
      endTime4: map['endTime4'],
      starTime5: map['startTime5'],
      endTime5: map['endTime5'],
      starTime6: map['startTime6'],
      endTime6: map['endTime6'],
      starTime7: map['startTime7'],
      endTime7: map['endTime7'],
      starTime8: map['startTime8'],
      endTime8: map['endTime8'],
      starTime9: map['startTime9'],
      endTime9: map['endTime9'],
      starTime10: map['startTime10'],
      endTime10: map['endTime10'],
      
    );
  }

}

class MasterData{

  int id;
  String name;
  String filepath;

  MasterData({
    required this.id,
    required this.name,
    required this.filepath,
  });

  factory MasterData.fromMap(Map<String, dynamic> map) {
    return MasterData(
        id: map['id'],
        name: map['name'],
        filepath: map['filepath']


    );
  }

}