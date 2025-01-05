// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:yajurmandir/res/Colors.dart';
//
// class FileStorage extends StatefulWidget {
//   const FileStorage({super.key});
//
//   @override
//   State<FileStorage> createState() => _FileStorageState();
// }
//
// class _FileStorageState extends State<FileStorage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor:pinkDark,
//         title: Text('CSV File Storage'.toUpperCase()),
//         centerTitle: true,
//
//       ),
//       body:getData(context)
//     );
//   }
//
//   Future<List<String>> getStoredData() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     List<String>? stringList = prefs.getStringList('file_paths');
//     return stringList ?? [];
//
//   }
//
//   FutureBuilder<List<String>?> getData(BuildContext context) {
//     return FutureBuilder<List<String>?>(
//
//       future: getStoredData(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Center(child: CircularProgressIndicator());
//         } else if (snapshot.hasError) {
//           return Center(child: Text('Error: ${snapshot.error}'));
//         } else {
//           List<String> stringList = snapshot.data!;
//           return Container(
//             child:  MasonryGridView.builder(
//                 physics: NeverScrollableScrollPhysics(),
//                 padding: EdgeInsets.only(bottom: 10),
//                 crossAxisSpacing: 10,
//                 mainAxisSpacing: 10,
//                 shrinkWrap: true,
//                 gridDelegate:
//                 const SliverSimpleGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 4,
//                 ),
//                 itemCount: stringList.length,
//                 itemBuilder: (context, index){
//                   return InkWell(
//                     onTap: ()async{
//                       if (Platform.isAndroid) {
//
//
//                       }
//                     },
//                     child: Padding(
//                       padding: const EdgeInsets.all(5.0),
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children : [
//                           Icon(Icons.featured_play_list_rounded,color: pinkDark,size: 50,),
//                           Text("File-"+stringList[index].split("-")[1]),
//                         ],
//                       ),
//                     ),
//                   );
//                 }),
//           );
//         }
//       },
//     );
//   }
//
//
//
//
//
//
//   Widget _buildUI(BuildContext context, List<String>? list) {
//
//     if(list!.isEmpty){
//       return Center(child: Text('File Not Found'),);
//     }
//     else{
//       return Container(
//         child:  MasonryGridView.builder(
//             physics: NeverScrollableScrollPhysics(),
//             padding: EdgeInsets.only(bottom: 10),
//             crossAxisSpacing: 10,
//             mainAxisSpacing: 10,
//             shrinkWrap: true,
//             gridDelegate:
//             const SliverSimpleGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 1,
//             ),
//             itemCount: list[0]!.length,
//             itemBuilder: (context, index){
//               return Icon(Icons.featured_play_list_rounded);
//             }),
//       );
//     }
//
//
//   }
//
// }
