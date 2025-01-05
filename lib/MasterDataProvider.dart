import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yajurmandir/NameSuggesstionModel.dart';

class MasterDataProvider extends ChangeNotifier{
  List<Map<String, String>> userList = [];
  List<NameSuggesstionModel> userListGate = [];

  Future<void> loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String jsonString = prefs.getString('userList').toString();
    if (jsonString != null && jsonString!='null') {

      List<dynamic> jsonList = json.decode(jsonString);

      userListGate = jsonList.map((e) => NameSuggesstionModel.fromJson(e)).toList();

        userList = jsonList.map((e) => Map<String, String>.from(e)).toList();
    }
    else{
      userList=[];
      userListGate=[];
    }
    notifyListeners();
  }

  Future<void> _saveUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Serialize the List<Map<String, String>> to a JSON string
    String jsonString = json.encode(userList);
    // Store the JSON string in SharedPreferences
    await prefs.setString('userList', jsonString);
    loadUserData();
  }

  void addUser(String name, String photoUrl) {

      userList.add({'name': name, 'photoUrl': photoUrl});

    _saveUserData(); // Save updated user data to SharedPreferences
  }



  void deleteUser(int index) {

    userList.removeAt(index);

    _saveUserData(); // Save updated user data to SharedPreferences
  }

  void deleteTable() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('userList');


    loadUserData(); // Save updated user data to SharedPreferences
  }

}