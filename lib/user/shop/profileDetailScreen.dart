import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mobile/components/textFieldComponent.dart';
import 'package:mobile/user/page/selectMap.dart';
import 'package:mobile/user/shop/shopProductDetailScreen.dart';

import 'package:shared_preferences/shared_preferences.dart';

class ProfileDetailScreen extends StatefulWidget {
  // bool isDetail;
  final VoidCallback settingIsDetail;
  ProfileDetailScreen({super.key, required this.settingIsDetail});

  State<ProfileDetailScreen> createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends State<ProfileDetailScreen> {
  // List<dynamic> listProducts = [];
  late Map<String, dynamic> shopDetail;
  bool isLoading = true;
  MediaType mediaType = MediaType('application', 'json');
  final ImagePicker picker = ImagePicker();

  late TextEditingController _nameController = TextEditingController();
  late TextEditingController _emailController = TextEditingController();
  late TextEditingController shopNameController = TextEditingController();
  late TextEditingController shopPositionController = TextEditingController();
  late TextEditingController shopImgUrlController = TextEditingController();
  late TextEditingController shopImgCoverUrlController =
      TextEditingController();
  var pathAPI = '';
  @override
  void initState() {
    super.initState();
    initFetch();
  }

  Future getImage() async {
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      setState(() {
        if (pickedFile != null) {
          _saveImage(File(pickedFile.path));
          setState(() {
            shopImgUrlController =
                File(pickedFile.path) as TextEditingController;
          });
        }
      });
    } on Exception catch (e) {
      print(e);
    }
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
    await getImage();
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
    // Uri url = "http://52.65.210.113:3000/" as Uri;
    print("before fetch");
    String? uid = await getUID();
    final url = Uri.parse("http://$pathAPI/shop/profileDetail/${uid}");
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        print("API response: ${response.body}");
        final responseData = jsonDecode(response.body);
        setState(() {
          shopDetail = responseData;
          shopNameController.text =
              shopDetail['data']['shopData']['name'] ?? '';
          shopPositionController.text = shopDetail['position'] ?? '';
          shopImgUrlController.text =
              shopDetail['data']['shopData']['imgUrl']['shopUrl'] ?? '';
          shopImgCoverUrlController.text =
              shopDetail['data']['shopData']['imgUrl']['shopCoverUrl'] ?? '';
          isLoading = false;
        });
        print(shopImgCoverUrlController.text);
        print(shopImgUrlController.text);
      } else {
        print("Failed to load data: ${response.statusCode}");
        // Handle the error accordingly
      }
    } catch (e) {
      print("Error fetching data: $e");
      // Handle the error accordingly
    }
  }

  Future<void> _saveImage(File image) async {
    // Uri url = "http://52.65.210.113:3000/" as Uri;
    print("before fetch");
    String? uid = await getUID();
    final url = Uri.parse("http://$pathAPI/shop/uploadImage");
    try {
      var response = await http.post(url,
          body: jsonEncode({
            "shopUrl": image,
          }),
          headers: {
            "Content-Type": "application/json",
          });
      if (response.statusCode == 200) {
        print("API response: ${response.body}");
        final responseData = jsonDecode(response.body);
        setState(() {});
      } else {
        print("Failed to load data: ${response.statusCode}");
        // Handle the error accordingly
      }
    } catch (e) {
      print("Error fetching data: $e");
      // Handle the error accordingly
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
          const Row(children: [
            Icon(Icons.person_rounded, size: 18),
            SizedBox(width: 5),
            Text("รายละเอียดโปรไฟล์",
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  fontSize: 16,
                ))
          ]),
          SizedBox(height: 9),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: InkWell(
                onTap: () {
                  widget.settingIsDetail();
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
                        "ข้อมูลบัญชี",
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      Spacer(),
                      Icon(
                        Icons.edit,
                        size: 16,
                      )
                    ]))),
          ),
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
                                  Text("ชื่อร้านค้า"),
                                  SizedBox(height: 10),
                                  Container(
                                    height: 20,
                                    child: TextField(
                                      controller: shopNameController,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text("ตำแหน่งร้านค้า"),
                                  SizedBox(height: 10),
                                  Center(
                                    child: SizedBox(
                                      height: 50,
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          final result = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    SelectMapLocate()),
                                          );
                                          print("result of select map");

                                          print(result);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          side: const BorderSide(
                                              color: Color(0xFFD1D1D1)),
                                          elevation: 1,
                                          shadowColor:
                                              Colors.black.withOpacity(0.1),
                                          backgroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.location_on_outlined,
                                                color: Colors.grey[600],
                                                size: 20),
                                            const SizedBox(width: 12),
                                            Text(
                                              'แก้ไขร้านค้า',
                                              style: TextStyle(
                                                fontFamily: GoogleFonts.mitr()
                                                    .fontFamily,
                                                color: Colors.grey[800],
                                                fontSize: 16,
                                              ),
                                            ),
                                            const Icon(
                                                Icons.location_on_outlined,
                                                color: Colors.transparent,
                                                size: 20),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text("รูปร้านค้า"),
                                  SizedBox(height: 10),
                                  Center(
                                    child: SizedBox(
                                      height: 50,
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          showDialog(
                                              context: context,
                                              barrierDismissible: false,
                                              builder: (BuildContext context) {
                                                return Dialog(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15.0),
                                                    ),
                                                    child: Container(
                                                      width:
                                                          600, // Set custom width
                                                      height:
                                                          800, // Set custom height
                                                      padding: EdgeInsets.all(
                                                          16), // Add padding inside the container
                                                      child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: <Widget>[
                                                            Row(
                                                              children: [
                                                                Align(
                                                                  alignment:
                                                                      Alignment
                                                                          .topLeft,
                                                                  child:
                                                                      TextButton(
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                    },
                                                                    child: Icon(
                                                                        Icons
                                                                            .close,
                                                                        color: Colors
                                                                            .grey[600]),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            Container(
                                                              width: double
                                                                  .infinity,
                                                              height: 200,
                                                              child: shopImgUrlController
                                                                      .text
                                                                      .isNotEmpty
                                                                  ? Image
                                                                      .network(
                                                                      shopImgUrlController
                                                                          .text
                                                                          .trim(),
                                                                      errorBuilder: (context,
                                                                              error,
                                                                              stackTrace) =>
                                                                          Center(
                                                                              child: Text("Failed to load image")),
                                                                    )
                                                                  : const Text(
                                                                      "No image available"),
                                                            ),
                                                            SizedBox(
                                                                height: 10),
                                                            CustomImageUploadButton(
                                                                label:
                                                                    'รูปหน้าปกร้าน',
                                                                onPressed: () {
                                                                  showPicker(
                                                                    context,
                                                                  );
                                                                }),
                                                            SizedBox(
                                                                height: 10),
                                                            Container(
                                                              width: double
                                                                  .infinity,
                                                              height: 200,
                                                              child: shopImgCoverUrlController
                                                                      .text
                                                                      .isNotEmpty
                                                                  ? Image
                                                                      .network(
                                                                      shopImgCoverUrlController
                                                                          .text
                                                                          .trim(),
                                                                      errorBuilder: (context,
                                                                              error,
                                                                              stackTrace) =>
                                                                          Center(
                                                                              child: Text("Failed to load image")),
                                                                    )
                                                                  : const Text(
                                                                      "No image available"),
                                                            ),
                                                            SizedBox(
                                                                height: 10),
                                                            CustomImageUploadButton(
                                                                label:
                                                                    'รูปหน้าปกพื้นหลังร้าน',
                                                                onPressed: () {
                                                                  showPicker(
                                                                    context,
                                                                  );
                                                                }),
                                                            SizedBox(
                                                                height: 10),
                                                            ElevatedButton(
                                                                style: ElevatedButton
                                                                    .styleFrom(
                                                                        backgroundColor:
                                                                            Colors
                                                                                .blue,
                                                                        shape:
                                                                            RoundedRectangleBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(8),
                                                                        )),
                                                                onPressed: () {
                                                                  // updateProfile();
                                                                },
                                                                child: Container(
                                                                    child: Text(
                                                                  'อัพเดตข้อมูลสินค้า',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white),
                                                                ))),
                                                          ]),
                                                    ));
                                              });
                                        },
                                        style: ElevatedButton.styleFrom(
                                          side: const BorderSide(
                                              color: Color(0xFFD1D1D1)),
                                          elevation: 1,
                                          shadowColor:
                                              Colors.black.withOpacity(0.1),
                                          backgroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.location_on_outlined,
                                                color: Colors.grey[600],
                                                size: 20),
                                            const SizedBox(width: 12),
                                            Text(
                                              'แก้ไขรูปร้านค้า',
                                              style: TextStyle(
                                                fontFamily: GoogleFonts.mitr()
                                                    .fontFamily,
                                                color: Colors.grey[800],
                                                fontSize: 16,
                                              ),
                                            ),
                                            const Icon(
                                                Icons.location_on_outlined,
                                                color: Colors.transparent,
                                                size: 20),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
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
                      "ข้อมูลร้านค้า",
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
