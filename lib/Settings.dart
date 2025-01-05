
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yajurmandir/AllProvider.dart';
import 'package:yajurmandir/GateRegisterProvider.dart';
import 'package:yajurmandir/MasterDataProvider.dart';

import 'package:yajurmandir/res/Colors.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';

import 'Utils/AlertDialogUtil.dart';

class Settings extends ConsumerStatefulWidget {
  const Settings({super.key});

  @override
  ConsumerState<Settings> createState() => _SettingsState();
}

class _SettingsState extends ConsumerState<Settings> {
  TextEditingController nameController=TextEditingController();
  TextEditingController imageController=TextEditingController();
  late MasterDataProvider _masterRegisterProvider;

  String userImageFilePath='';

  Widget checkImageWasPresentOrNot (String photoUrl){


    if(photoUrl.isNotEmpty){
      File imageFile=File(photoUrl);
      return Image.file(imageFile);
    }
    else{
      return Icon(Icons.image_not_supported_outlined);
    }
  }

  Future<void> _pickFile() async {
    String filePath = await FilePicker.platform.pickFiles(
      type: FileType.image,
      // allowedExtensions: ['json'],
    ).then((result) {
      if (result != null) {
        return result.files.single.path!;
      }
      return 'File not found';
    });

    if (filePath != null) {
      userImageFilePath=filePath;
      imageController.text='Imported Successfully';
      print('filepath was not null'+userImageFilePath.toString());
    }
    else{
      print('filepath was null');
    }
  }

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((_) {
      ref.read(masterRegisterProviderALLP).loadUserData();

    });
  }
  @override
  Widget build(BuildContext context) {
    _masterRegisterProvider=ref.watch(masterRegisterProviderALLP);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: pinkDark,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: Text('Regular Visitors'.toUpperCase(),style: TextStyle(color: Colors.white,fontSize: 14),),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
              heroTag: 'FAB12',
              backgroundColor: pinkDark,
              onPressed: (){
                showDialogForChangePassword();
              },
              child: Icon(Icons.key,color: Colors.white,)),
          SizedBox(width: 30,),
          FloatingActionButton(
            heroTag: 'FAB7',
              backgroundColor: pinkDark,
              onPressed: (){
                showDialogToAddMember();
              },
              child: Icon(Icons.add,color: Colors.white,)),
          SizedBox(width: 30,),
          FloatingActionButton(
            heroTag: 'FAB8',
              backgroundColor: pinkDark,
              onPressed: (){
                showDialog(context: context, builder: (context) => AlertDialog(
                  title: Text('Are you sure want delete this Regular Visitors\'s list'),
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
                          onTap:()async{
                            Navigator.pop(context);

                            _masterRegisterProvider.deleteTable();

                          },
                          child: Container(
                              width: 150,height: 40,
                              child: Center(child: Text('DELETE',style: TextStyle(fontSize: 15,color: pinkDark),)))),

                    ],
                  ),
                ),);

              },
              child: Icon(Icons.delete,color: Colors.white,)),
        ],
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
        if(_masterRegisterProvider.userList.isEmpty)
          Expanded(
            flex:9,
            child: Center(
                child: Text('Regular Visitor Data Not Found'),),
          ),

          if(_masterRegisterProvider.userList.isNotEmpty)
          Expanded(
            flex:9,
            child: Padding(
              padding: const EdgeInsets.only(top:20,bottom:20),
              child: ListView.builder(
                  itemCount: _masterRegisterProvider.userList.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    var item=_masterRegisterProvider.userList[index];

                    return Center(
                      child: Padding(
                        padding: EdgeInsets.only(bottom:10),
                        child: Container(

                          decoration: BoxDecoration(
                            border: Border.all(
                              color: pinkDark,
                            )
                          ),
                          width: MediaQuery.of(context).size.width *0.5,
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: ListTile(
                              leading: checkImageWasPresentOrNot(item['photoUrl'].toString()),
                              title: Text(item['name'].toString()),
                              trailing: InkWell(
                                  onTap: (){
                                    showDialog(context: context, builder: (context) => AlertDialog(
                                      title: Text('Are you sure want delete this member '+item['name'].toString()),
                                      content: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [

                                          InkWell(
                                              onTap: (){
                                                Navigator.pop(context);
                                              },
                                              child: Container(
                                                  width: 150,height: 40,
                                                  child: Center(child: Text('CANCEL',style: TextStyle(fontSize: 15,color: Colors.black),)))),

                                          InkWell(
                                              onTap:()async{
                                                Navigator.pop(context);

                                                _masterRegisterProvider.deleteUser(index);

                                              },
                                              child: Container(
                                                  width: 100,height: 40,
                                                  child: Center(child: Text('DELETE',style: TextStyle(fontSize: 15,color: pinkDark,fontWeight: FontWeight.w800),)))),

                                        ],
                                      ),
                                    ),);

                                  },
                                  child: Icon(Icons.delete,color: pinkDark,size: 30,)),
                            ),
                          ),
                        ),
                      ),
                    );
                  },),
            ),
          ),

          Expanded(flex:1,child: Container(
            width: double.infinity,
              decoration:BoxDecoration(
               border: Border(
               top: BorderSide(color: pinkDark,)
                 )
               ),
              child: Center(child: Text('Version: 1.0'))))
        ],
      ),
    );
  }

  Widget settingsButton(String value){

    return Padding(
      padding: const EdgeInsets.only(left:20,right: 20,bottom:20),
      child: Container(
        padding: EdgeInsets.only(left:20),
        width: double.infinity,
        height: 55,
        decoration: BoxDecoration(color: pinkDark,border: Border.all(color: Colors.white),borderRadius: BorderRadius.circular(15)),
        child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(value.toUpperCase(),style: TextStyle(fontSize: 14,color: Colors.white),)),
      ),
    );

  }

  void showDialogToAddMember(){
    imageController.text='';
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
                      child: TextField(
                        textAlign: TextAlign.center,
                        style:const TextStyle(
                          fontSize: 16,
                          color: pinkDark,
                        ),
                        controller: nameController,
                        keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.characters,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'ENTER NAME',
                          hintStyle: TextStyle(
                            letterSpacing: 2,
                            fontSize: 16,
                            color: pinkDark,
                          ),
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[ a-zA-Z.]')),
                          LengthLimitingTextInputFormatter(50),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10,),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: pinklightDark2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: TextField(
                        readOnly: true,
                        onTap: (){
                          _pickFile();
                        },
                        textAlign: TextAlign.center,
                        style:const TextStyle(
                          fontSize: 16,
                          color: pinkDark,
                        ),
                        controller: imageController,
                        keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.characters,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'SELECT IMAGE',
                          hintStyle: TextStyle(
                            letterSpacing: 2,
                            fontSize: 16,
                            color: pinkDark,
                          ),
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[ a-zA-Z.]')),
                          LengthLimitingTextInputFormatter(50),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20,),

                  InkWell(
                    onTap: (){
                      String name=removeLastSpace(nameController.text);

                      if(name.isEmpty){
                        showAlertDialog_oneBtn(context, 'Warning', 'Please Enter Name');
                      }
                      else if(checkRegularVisitorPresentOrNot(name)){
                        showAlertDialog_oneBtn(context, 'Warning', 'Visitor name should be unique');
                      }

                      else{

                        _masterRegisterProvider.addUser(name, userImageFilePath);
                        nameController.text='';
                        userImageFilePath='';
                        Navigator.pop(context);

                      }

                    },
                    child: Container(
                      color: Colors.green,
                      width: MediaQuery.of(context).size.width/2,
                      height: 45,
                      child: Center(
                        child: Text("Update",style: TextStyle(color: Colors.white),),
                      ),
                    ),

                  ),

                  SizedBox(height: 10,),
                  InkWell(
                    onTap: (){

                      nameController.text='';
                      userImageFilePath='';
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





                ],
              ),
            ),
          ),
        ),
      ),

    ),);
  }


  bool checkRegularVisitorPresentOrNot(String value){
    bool status=false;
    int visitorsListLength=_masterRegisterProvider.userListGate.length;
    var item=_masterRegisterProvider.userListGate;
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

  void showDialogForChangePassword() async{
    TextEditingController oldPwdController=TextEditingController();
    TextEditingController newPwdController=TextEditingController();
    TextEditingController confirmNewPwdController=TextEditingController();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String currentPassword=prefs.getString('password').toString();



    showDialog(context: context, builder: (context) {
      return AlertDialog(
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if(currentPassword=='null')
              Text('ADD PASSWORD',style: TextStyle(fontWeight: FontWeight.bold),),
              if(currentPassword!='null')
              Text('CHANGE PASSWORD',style: TextStyle(fontWeight: FontWeight.bold),),
              if(currentPassword!='null')
              SizedBox(height: 10,),
              if(currentPassword!='null')
              Container(
                width: 400,
                height: 55,
                child: TextField(
          
                  controller: oldPwdController,
                  decoration: InputDecoration(
                    labelText: 'Enter Old Password',
                      labelStyle: TextStyle(fontSize: 14,color:Maincolor)
                  ),
                  style: TextStyle(fontSize: 14),
                ),
              ),
              SizedBox(height: 10,),
              Container(
                width: 400,
                height: 55,
                child: TextField(
                  controller: newPwdController,
                  decoration: InputDecoration(
                    labelText: 'Enter New Password',
                      labelStyle: TextStyle(fontSize: 14,color:Maincolor)
                  ),
                  style: TextStyle(fontSize: 14),
                ),
              ),
              SizedBox(height: 10,),
              Container(
                width: 400,
                height: 55,
                child: TextField(
                  controller: confirmNewPwdController,
          
                  decoration: InputDecoration(

                    labelText: 'Confirm New Password',
                    labelStyle: TextStyle(fontSize: 14,color:Maincolor)
                  ),
                  style: TextStyle(fontSize: 14),
                ),
              ),
              SizedBox(height: 35,),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),color: Maincolor,
          
                ),
                width: 300,
                height:45 ,
                child: InkWell(
                  onTap: (){
                    String oldPasswordValue= oldPwdController.text;
                    String newPasswordValue= newPwdController.text;
                    String confirmPwdValue= confirmNewPwdController.text;
                    if(currentPassword=='null'){
                      if(newPasswordValue.isEmpty){
                        showAlertDialog_oneBtn_msg(context, 'New Password must not be empty');
                      }
                      else if(confirmPwdValue.isEmpty){
                        showAlertDialog_oneBtn_msg(context, 'Confirm Password must not be empty');
                      }
                      else if(newPasswordValue!=confirmPwdValue){
                        showAlertDialog_oneBtn_msg(context, 'New Password and Confirm Password Mis Match, Please try again');
                      }
                      else{
                        prefs.setString('password', newPasswordValue);
                        Navigator.pop(context);
                        showToast(context, 'Password Updated Successfully');
                      }
                    }
                    else{
                      if(oldPasswordValue.isEmpty){
                        showAlertDialog_oneBtn_msg(context, 'Old Password must not be empty');
                      }

                      else if(oldPasswordValue!=currentPassword){
                        showAlertDialog_oneBtn_msg(context, 'Old Password was Mis Match , Please try again.');
                      }
                      else if(newPasswordValue.isEmpty){
                        showAlertDialog_oneBtn_msg(context, 'New Password must not be empty');
                      }
                      else if(confirmPwdValue.isEmpty){
                        showAlertDialog_oneBtn_msg(context, 'Confirm Password must not be empty');
                      }
                      else if(newPasswordValue!=confirmPwdValue){
                        showAlertDialog_oneBtn_msg(context, 'New Password and Confirm Password Mis Match, Please try again');
                      }
                      else{
                        prefs.setString('password', newPasswordValue);
                        Navigator.pop(context);
                        showToast(context, 'Password Updated Successfully');
                      }
                    }

                  },
                  child: Center(child: Text('Change Password',style: TextStyle(color: Colors.white),),),
                ),
              ),
              SizedBox(height: 20,),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black)
                ),
                width: 300,
                height:45 ,
                child: InkWell(
                  onTap: (){
                    oldPwdController.text='';
                    newPwdController.text='';
                    confirmNewPwdController.text='';
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
}
