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

  Future<bool> updateCustomer() async {
    String name = fnameController.text.trim();
    String surname = lnameController.text.trim();
    String tel = telController.text.trim();

    try {
      String? uid = await getUID();
      if (uid == null) {
        print("ERROR: UID is null");
        return false;
      }

      final url = Uri.parse("$pathAPI/customer/updateCustomer?uid=$uid");
      print("DEBUG: Calling URL: $url");
      print("DEBUG: UID: $uid");
      print("DEBUG: Data: fname=$name, lname=$surname, tel=$tel");

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fname': name,
          'lname': surname,
          'tel': tel,
        }),
      );

      print("DEBUG: Response status: ${response.statusCode}");
      print("DEBUG: Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == 'success';
      } else {
        print(
            "ERROR: Server returned ${response.statusCode}: ${response.body}");
        return false;
      }
    } catch (e) {
      print('ERROR: Exception occurred: $e');
      return false;
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
                          width: 500,
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.height * 0.8,
                          ),
                          padding: EdgeInsets.all(16),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                   mainAxisAlignment: MainAxisAlignment.end,
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
                                Text("ชื่อ"),
                                SizedBox(height: 5),
                                Container(
                                  height: 50,
                                  child: TextField(
                                    controller: fnameController,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 10),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text("นามสกุล"),
                                SizedBox(height: 5),
                                Container(
                                  height: 50,
                                  child: TextField(
                                    controller: lnameController,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 10),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text("อีเมล"),
                                SizedBox(height: 5),
                                Container(
                                  height: 50,
                                  child: TextField(
                                    controller: emailController,
                                    readOnly: true,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 10),
                                      fillColor: Colors.grey[200],
                                      filled: true,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text("เบอร์"),
                                SizedBox(height: 5),
                                Container(
                                  height: 50,
                                  child: TextField(
                                    controller: telController,
                                    keyboardType: TextInputType.phone,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 10),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.white,
                                      padding:
                                          EdgeInsets.symmetric(vertical: 15),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: () async {
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (BuildContext context) {
                                          return Center(
                                              child:
                                                  CircularProgressIndicator());
                                        },
                                      );

                                      bool success = await updateCustomer();

                                      Navigator.of(context).pop();

                                      if (success) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content:
                                                Text('ข้อมูลอัพเดตสำเร็จ!'),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'อัพเดตข้อมูลไม่สำเร็จ. กรุณาลองอีกครั้ง.'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    },
                                    child: Text(
                                      'อัพเดตข้อมูล',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
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
