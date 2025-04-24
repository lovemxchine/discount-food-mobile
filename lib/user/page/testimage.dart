// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:http/http.dart' as http;

// class ImageUploadScreen extends StatefulWidget {
//   @override
//   _ImageUploadScreenState createState() => _ImageUploadScreenState();
// }

// class _ImageUploadScreenState extends State<ImageUploadScreen> {
//   File? _image;
//   final picker = ImagePicker();

//   Future getImage() async {
//     try {
//       final pickedFile = await picker.pickImage(source: ImageSource.gallery);

//       setState(() {
//         if (pickedFile != null) {
//           _image = File(pickedFile.path);
//         }
//       });
//     } on Exception catch (e) {
//       print(e);
//     }
//   }

//   Future<void> uploadImage() async {
//     if (_image == null) return;

//     var url = Uri.parse(' upload/');
//     var request = http.MultipartRequest('POST', url);
//     request.files.add(await http.MultipartFile.fromPath('image', _image!.path));

//     try {
//       var streamedResponse = await request.send();
//       var response = await http.Response.fromStream(streamedResponse);
//       if (response.statusCode == 200) {
//         print('Image uploaded successfully');
//       } else {
//         print('Image upload failed');
//       }
//     } on Exception catch (e) {
//       print(e);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Image Upload')),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             _image == null ? Text('No image selected.') : Image.file(_image!),
//             ElevatedButton(
//               onPressed: getImage,
//               child: Text('Pick Image'),
//             ),
//             ElevatedButton(
//               onPressed: uploadImage,
//               child: Text('Upload Image'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
