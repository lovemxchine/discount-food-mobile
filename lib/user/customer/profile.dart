import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mobile/components/textFieldComponent.dart';
import 'package:mobile/user/page/selectMap.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class Profile extends StatefulWidget {
  final VoidCallback settingIsDetail;
  const Profile({super.key, required this.settingIsDetail});

  @override
  State<Profile> createState() => _Profile();
}

class _Profile extends State<Profile> {
// List<dynamic> listProducts = [];

  bool isLoading = true;
  late Map<String, dynamic> userProfileData;
  MediaType mediaType = MediaType('application', 'json');
  final ImagePicker picker = ImagePicker();

  late TextEditingController lnameController = TextEditingController();
  late TextEditingController emailController = TextEditingController();
  late TextEditingController fnameController = TextEditingController();
  late TextEditingController telController = TextEditingController();
  var pathAPI = '';
  @override
  void initState() {
    super.initState();
    initFetch();
  }

  Future<void> openCamera(BuildContext context) async {
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      // Handle the captured image
      print('Image path: ${image.path}');
    }
  }

  void showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Library'),
                onTap: () {
                  initImage();
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  openCamera(context);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String formatDiscountDate(Map<String, dynamic> timestamp) {
    int seconds = timestamp['_seconds'];
    int nanoseconds = timestamp['_nanoseconds'];

    // Convert seconds to DateTime
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);

    // Add nanoseconds
    dateTime = dateTime.add(Duration(microseconds: nanoseconds ~/ 1000));

    // Format the DateTime object into a desired format
    String formattedDate = DateFormat('dd-MM-yyyy').format(dateTime);

    return formattedDate;
  }

  Future<void> initFetch() async {
    await fetchUrl();
    await _fetchData();
  }

  Future<void> initImage() async {
    await fetchUrl();
  }

  Future<void> fetchUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      pathAPI = prefs.getString('apiUrl') ?? 'http://10.0.2.2:3000';
    });
    print(pathAPI);
  }

  Future<String?> getUID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_uid');
  }

  Future<void> _fetchData() async {
    print("before fetch");
    String? uid = await getUID();
    final url = Uri.parse("$pathAPI/customer/profileDetail?uid=$uid");

    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        print("API response: ${response.body}");
        final responseData = jsonDecode(response.body);

        setState(() {
          userProfileData = responseData['data'];
          fnameController.text = userProfileData['fname'] ?? '';
          lnameController.text = userProfileData['lname'] ?? '';
          emailController.text = userProfileData['email'] ?? '';
          telController.text = userProfileData['tel'] ?? '';
          isLoading = false;
        });
      } else {
        print("Failed to load data: ${response.statusCode}");
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Column(
        children: [
          InkWell(
            onTap: () {
              widget.settingIsDetail();
            },
            child: const Row(
              children: [
                Icon(Icons.person_rounded, size: 18),
                SizedBox(width: 5),
                Text(
                  "รายละเอียดโปรไฟล์",
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 9),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return Dialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Container(
                            width: 500, // Set custom width
                            height: 600, // Set custom height
                            padding: EdgeInsets.all(
                                16), // Add padding inside the container
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    children: [
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Icon(Icons.close,
                                              color: Colors.grey[600]),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Text("ชื่อ"),
                                  SizedBox(height: 5),
                                  Container(
                                    height: 20,
                                    child: TextField(
                                      controller: fnameController,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text("นามสกุล"),
                                  SizedBox(height: 5),
                                  Container(
                                    height: 20,
                                    child: TextField(
                                      controller: lnameController,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text("อีเมล"),
                                  SizedBox(height: 5),
                                  Container(
                                    height: 20,
                                    child: TextField(
                                      controller: emailController,
                                       readOnly: true,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text("เบอร์"),
                                  SizedBox(height: 5),
                                  Container(
                                    height: 20,
                                    child: TextField(
                                      controller: telController,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                ])),
                      );
                    },
                  );
                },
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.black, // Underline color
                        width: 1, // Underline thickness
                      ),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: const Row(children: [
                    Text(
                      "แก้ไขข้อมูล",
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    Spacer(),
                    Icon(
                      Icons.edit,
                      size: 16,
                    )
                  ]),
                )),
          ),
        ],
      ),
    );
  }
}
