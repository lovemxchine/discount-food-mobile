import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_cropper/image_cropper.dart';
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
  Map<String, dynamic> payments = {
    "qrImg": "",
    "accountName": "Tops market",
    "bankName": "ธนาคารกสิกรไทย",
  };
  MediaType mediaType = MediaType('application', 'json');
  final ImagePicker picker = ImagePicker();

  late TextEditingController accNameController = TextEditingController();
  late TextEditingController bankNameController = TextEditingController();
  late TextEditingController bankNumberController = TextEditingController();
  late TextEditingController qrImgController = TextEditingController();

  late TextEditingController openAtController = TextEditingController();
  late TextEditingController closeAtController = TextEditingController();
  late TextEditingController telController = TextEditingController();

  late TextEditingController _nameController = TextEditingController();
  late TextEditingController _emailController = TextEditingController();
  late TextEditingController shopNameController = TextEditingController();
  late TextEditingController shopPositionController = TextEditingController();
  late TextEditingController shopImgUrlController = TextEditingController();
  late TextEditingController shopImgCoverUrlController =
      TextEditingController();

  File? newShopImage;
  File? newShopCoverImage;
  File? newShopQrImage;

  var pathAPI = '';
  @override
  void initState() {
    super.initState();
    initFetch();
  }

  Future<void> openCameraShop(BuildContext context) async {
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        newShopImage = File(image.path);
        // shopImgUrlController.text = image.path;
      });
      // Handle the captured image
      print('Image path: ${image.path}');
    }
  }

  Future<void> openCameraShopCover(BuildContext context) async {
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        newShopCoverImage = File(image.path);
        // shopImgUrlController.text = image.path;
      });
      // Handle the captured image
      print('Image path: ${image.path}');
    }
  }

  Future<void> openCameraShopQr(BuildContext context) async {
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: image!.path,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 100,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'ปรับแต่งรูปภาพ',
          toolbarColor: Colors.green,
          toolbarWidgetColor: Colors.white,
          backgroundColor: Colors.white,
          activeControlsWidgetColor: Colors.green,
          dimmedLayerColor: Colors.black.withOpacity(0.5),
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
          statusBarColor: Colors.green,
        ),
      ],
    );

    if (croppedFile != null) {
      setState(() {
        newShopQrImage = File(croppedFile!.path);
        // shopImgUrlController.text = image.path;
      });
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
                  getImageShop();
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  // emptyDialogContent();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  openCameraShop(context);
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  // emptyDialogContent();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void showPickerCover(BuildContext context) {
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
                  getImageShopCover();
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  // emptyDialogContent();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  openCameraShopCover(context);
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  // emptyDialogContent();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void showPickerQR(BuildContext context) {
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
                  getImageShopQR();
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  openCameraShopQr(context);
                  Navigator.of(context).pop();
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

  Future getImageShop() async {
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        if (shopImgUrlController.text.isNotEmpty) {
          await PaintingBinding.instance.imageCache
              .evict(NetworkImage(shopImgUrlController.text));
        }
        // _saveImage(File(pickedFile.path));
        setState(() {
          newShopImage = File(pickedFile.path);
          // shopImgUrlController.text = pickedFile.path;
          print("After setState: newShopCoverImage = $newShopImage");
          print("File exists: ${newShopImage!.existsSync()}");
        });
      }
    } on Exception catch (e) {
      print(e);
    }
  }

  Future getImageShopCover() async {
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        // _saveImage(File(pickedFile.path));
        setState(() {
          newShopCoverImage = File(pickedFile.path);
          // shopImgCoverUrlController.text = pickedFile.path;
        });
      }
    } on Exception catch (e) {
      print(e);
    }
  }

  Future getImageShopQR() async {
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile!.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 100,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'ปรับแต่งรูปภาพ',
            toolbarColor: Colors.green,
            toolbarWidgetColor: Colors.white,
            backgroundColor: Colors.white,
            activeControlsWidgetColor: Colors.green,
            dimmedLayerColor: Colors.black.withOpacity(0.5),
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            statusBarColor: Colors.green,
          ),
        ],
      );

      if (pickedFile != null) {
        setState(() {
          newShopQrImage = File(croppedFile!.path);
          // qrImgController.text = pickedFile.path;
        });
      }
    } on Exception catch (e) {
      print(e);
    }
  }

  Future<void> updateImageShop() async {
    try {
      String? uid = await getUID();
      // Create the request
      final url = Uri.parse("$pathAPI/shop/updateShopImages?uid=${uid}");
      var request = http.MultipartRequest('POST', url);

      List<http.MultipartFile> imageFiles = [];

      // Add image files

      if (newShopImage != null) {
        imageFiles.add(await http.MultipartFile.fromPath(
          'images',
          newShopImage!.path,
        ));
      }

      if (newShopCoverImage != null) {
        imageFiles.add(await http.MultipartFile.fromPath(
          'images',
          newShopCoverImage!.path,
        ));
      }

      request.files.addAll(imageFiles);

      // Send the request
      var response = await request.send();

      // Read the response
      if (response.statusCode == 200) {
        print('Uploaded successfully');
        Fluttertoast.showToast(
          msg: "อัปโหลดรูปภาพสำเร็จ",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
        );
      } else {
        print('Failed to upload');
      }
    } catch (e) {
      print('Error: $e');
      Fluttertoast.showToast(
        msg: "เกิดข้อผิดพลาดในการอัปโหลดรูปภาพ",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  Future<void> updatePaymentShop() async {
    try {
      String? uid = await getUID();
      // Create the request
      String? urls = await fetchUrl();
      final url = Uri.parse("$urls/shop/updatePayment");
      var request = http.MultipartRequest('POST', url);
      request.fields['shopId'] = uid ?? '';
      request.fields['accName'] = accNameController.text.trim();
      request.fields['bankName'] = bankNameController.text.trim();
      request.fields['bankNumber'] = bankNumberController.text.trim();
      // List<http.MultipartFile> imageFiles = [];

      // Add image files

      if (newShopQrImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          newShopQrImage!.path,
        ));
      }

      // Send the request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      final responseData = jsonDecode(response.body);

      // Read the response
      if (response.statusCode == 200) {
        print('Uploaded successfully');
        Fluttertoast.showToast(
          msg: "อัปเดตข้อมูลสำเร็จ",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
        );
      } else {
        print(
            'Failed to upload: ${response.statusCode} - ${responseData['message']}');
        print('Failed to upload');
      }
    } catch (e) {
      print('Error: $e');
      Fluttertoast.showToast(
        msg: "เกิดข้อผิดพลาดในการอัปเดตข้อมูล",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  Future<String> fetchUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      pathAPI = prefs.getString('apiUrl') ?? 'http://10.0.2.2:3000';
    });
    print(pathAPI);
    return prefs.getString('apiUrl') ?? 'http://10.0.2.2:3000';
  }

  Future<String?> getUID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_uid');
  }

  Future<void> updateShopString() async {
    String openAt = openAtController.text.trim();
    String closeAt = closeAtController.text.trim();
    String name = shopNameController.text.trim();
    String tel = telController.text.trim();
    String? uid = await getUID();
    final url = Uri.parse("$pathAPI/shop/updateShop?uid=$uid");
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "name": name,
          "tel": tel,
          "openAt": openAt,
          "closeAt": closeAt,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('อัปเดตข้อมูลสำเร็จ'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        print("Success: ${jsonDecode(response.body)['message']}");
      } else {
        print(" Failed: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> _fetchData() async {
    print("before fetch");
    String? uid = await getUID();
    final url = Uri.parse("$pathAPI/shop/profileDetail/${uid}");
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

          telController.text = shopDetail['data']['shopData']['tel'] ?? '';

          openAtController.text =
              shopDetail['data']['shopData']['openAt'] ?? '';
          closeAtController.text =
              shopDetail['data']['shopData']['closeAt'] ?? '';

          accNameController.text =
              shopDetail['data']['shopData']['payment']['accName'] ?? '';
          bankNameController.text =
              shopDetail['data']['shopData']['payment']['bankName'] ?? '';
          bankNumberController.text =
              shopDetail['data']['shopData']['payment']['bankNumber'] ?? '';
          qrImgController.text =
              shopDetail['data']['shopData']['payment']['qrImg'] ?? '';
          isLoading = false;
        });
        print(shopImgCoverUrlController.text);
        print(shopImgUrlController.text);
        print(accNameController.text);
        print(openAtController.text);
        print(telController.text);
      } else {
        print("Failed to load data: ${response.statusCode}");
        // Handle the error accordingly
      }
    } catch (e) {
      print("Error fetching data: $e");
      // Handle the error accordingly
    }
  }

  Future emptyDialogContent() {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Container(
            width: 600,
            constraints: BoxConstraints(
              maxHeight:
                  MediaQuery.of(context).size.height * 0.85, // ป้องกันล้นจอ
            ),
            padding: EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Icon(Icons.close, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  Container(
                    width: double.infinity,
                    height: 200,
                    child: newShopImage != null
                        ? Image.file(
                            newShopImage!,
                            key: ValueKey(newShopImage!.path +
                                DateTime.now()
                                    .millisecondsSinceEpoch
                                    .toString()), // Add this line
                            errorBuilder: (context, error, stackTrace) =>
                                Center(child: Text("Failed to load image")),
                          )
                        : shopImgUrlController.text.isNotEmpty
                            ? Image.network(
                                key: ValueKey(shopImgUrlController.text +
                                    DateTime.now()
                                        .millisecondsSinceEpoch
                                        .toString()),
                                shopImgUrlController.text.trim(),
                                errorBuilder: (context, error, stackTrace) =>
                                    Center(child: Text("Failed to load image")),
                              )
                            : const Text("No image available"),
                  ),
                  SizedBox(height: 10),
                  CustomImageUploadButton(
                    label: 'รูปหน้าปกร้าน',
                    onPressed: () {
                      showPicker(context);
                    },
                  ),
                  SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    height: 200,
                    child: newShopCoverImage != null
                        ? Image.file(
                            newShopCoverImage!,
                            key: ValueKey(
                                newShopCoverImage!.path), // Add this line
                            errorBuilder: (context, error, stackTrace) =>
                                Center(child: Text("Failed to load image")),
                          )
                        : shopImgCoverUrlController.text.isNotEmpty
                            ? Image.network(
                                shopImgCoverUrlController.text.trim(),
                                errorBuilder: (context, error, stackTrace) =>
                                    Center(child: Text("Failed to load image")),
                              )
                            : const Text("No image available"),
                  ),
                  SizedBox(height: 10),
                  CustomImageUploadButton(
                    label: 'รูปหน้าปกพื้นหลังร้าน',
                    onPressed: () {
                      showPickerCover(context);
                    },
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      // updateProfile();
                      updateImageShop();
                      Navigator.of(context).pop();
                    },
                    child: Center(
                      child: Text(
                        'ยืนยันการแก้ไข',
                        style: TextStyle(color: Colors.white),
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
                              maxHeight:
                                  MediaQuery.of(context).size.height * 0.8,
                            ),
                            padding: EdgeInsets.all(16),
                            child: SingleChildScrollView(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Icon(Icons.close,
                                            color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Text("ชื่อร้านค้า"),
                                  SizedBox(height: 5),
                                  Container(
                                    height: 40,
                                    child: TextField(
                                      controller: shopNameController,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 8, horizontal: 8),
                                        border: OutlineInputBorder(),
                                      ),
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text("เบอร์โทร"),
                                  SizedBox(height: 5),
                                  Container(
                                    height: 40,
                                    child: TextField(
                                      controller: telController,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 8, horizontal: 8),
                                        border: OutlineInputBorder(),
                                      ),
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text("เวลาเปิด"),
                                  SizedBox(height: 5),
                                  Container(
                                    height: 40,
                                    child: TextField(
                                      controller: openAtController,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 8, horizontal: 8),
                                        border: OutlineInputBorder(),
                                      ),
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text("เวลาปิด"),
                                  SizedBox(height: 5),
                                  Container(
                                    height: 40,
                                    child: TextField(
                                      controller: closeAtController,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 8, horizontal: 8),
                                        border: OutlineInputBorder(),
                                      ),
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  ElevatedButton(
                                    onPressed: () {
                                      updateShopString();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Container(
                                      width: double.infinity,
                                      padding:
                                          EdgeInsets.symmetric(vertical: 12),
                                      child: Center(
                                        child: Text(
                                          'บันทึกข้อมูล',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16),
                                        ),
                                      ),
                                    ),
                                  ),
                                ])),
                          ));
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
                              maxHeight:
                                  MediaQuery.of(context).size.height * 0.8,
                            ),
                            padding: EdgeInsets.all(16),
                            child: SingleChildScrollView(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Icon(Icons.close,
                                            color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),

                                  // Text("ตำแหน่งร้านค้า"),
                                  // SizedBox(height: 10),
                                  // Center(
                                  //   child: SizedBox(
                                  //     height: 50,
                                  //     width: double.infinity,
                                  //     child: ElevatedButton(
                                  //       onPressed: () async {
                                  //         final result = await Navigator.push(
                                  //           context,
                                  //           MaterialPageRoute(
                                  //               builder: (context) =>

                                  Text("รูปร้านค้า"),
                                  SizedBox(height: 10),
                                  Center(
                                    child: SizedBox(
                                      height: 50,
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          emptyDialogContent();
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
                                  SizedBox(height: 10),
                                  Text("ธุรกรรม"),
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
                                                        width: 600,
                                                        constraints:
                                                            BoxConstraints(
                                                          maxHeight:
                                                              MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height *
                                                                  0.85,
                                                        ),
                                                        padding: EdgeInsets.all(
                                                            16), // Add padding inside the container
                                                        child:
                                                            SingleChildScrollView(
                                                          child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: <Widget>[
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .end,
                                                                  children: [
                                                                    Align(
                                                                      alignment:
                                                                          Alignment
                                                                              .topLeft,
                                                                      child:
                                                                          TextButton(
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.of(context)
                                                                              .pop();
                                                                        },
                                                                        child: Icon(
                                                                            Icons
                                                                                .close,
                                                                            color:
                                                                                Colors.grey[600]),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                Container(
                                                                  width: double
                                                                      .infinity,
                                                                  height: 200,
                                                                  child: newShopQrImage !=
                                                                          null
                                                                      ? Image
                                                                          .file(
                                                                          newShopQrImage!,
                                                                          key: ValueKey(newShopQrImage!.path +
                                                                              DateTime.now().millisecondsSinceEpoch.toString()),
                                                                          errorBuilder: (context, error, stackTrace) =>
                                                                              Center(child: Text("Failed to load image")),
                                                                        )
                                                                      : qrImgController
                                                                              .text
                                                                              .isNotEmpty
                                                                          ? Image
                                                                              .network(
                                                                              qrImgController.text.trim(),
                                                                              key: ValueKey(qrImgController.text + DateTime.now().millisecondsSinceEpoch.toString()),
                                                                              errorBuilder: (context, error, stackTrace) => Center(child: Text("Failed to load image")),
                                                                            )
                                                                          : const Text(
                                                                              "No image available"),
                                                                ),
                                                                SizedBox(
                                                                    height: 10),
                                                                Center(
                                                                  child: Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      SizedBox(
                                                                        width:
                                                                            80,
                                                                        child:
                                                                            Text(
                                                                          "ชื่อบัญชี :",
                                                                          style:
                                                                              TextStyle(fontWeight: FontWeight.bold),
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        width:
                                                                            150,
                                                                        child:
                                                                            TextField(
                                                                          controller:
                                                                              accNameController,
                                                                          decoration:
                                                                              InputDecoration(
                                                                            isDense:
                                                                                true,
                                                                            contentPadding:
                                                                                EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                                                                            border:
                                                                                OutlineInputBorder(),
                                                                          ),
                                                                          style:
                                                                              TextStyle(fontSize: 16),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                    height: 10),
                                                                Center(
                                                                  child: Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      SizedBox(
                                                                        width:
                                                                            80,
                                                                        child:
                                                                            Text(
                                                                          "บัญชี :",
                                                                          style:
                                                                              TextStyle(fontWeight: FontWeight.bold),
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        width:
                                                                            150,
                                                                        child:
                                                                            TextField(
                                                                          controller:
                                                                              bankNameController,
                                                                          decoration:
                                                                              InputDecoration(
                                                                            isDense:
                                                                                true,
                                                                            contentPadding:
                                                                                EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                                                                            border:
                                                                                OutlineInputBorder(),
                                                                          ),
                                                                          style:
                                                                              TextStyle(fontSize: 16),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                    height: 10),
                                                                Center(
                                                                  child: Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      SizedBox(
                                                                        width:
                                                                            80,
                                                                        child:
                                                                            Text(
                                                                          "เลขบัญชี :",
                                                                          style:
                                                                              TextStyle(fontWeight: FontWeight.bold),
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        width:
                                                                            150,
                                                                        child:
                                                                            TextField(
                                                                          controller:
                                                                              bankNumberController,
                                                                          decoration:
                                                                              InputDecoration(
                                                                            isDense:
                                                                                true,
                                                                            contentPadding:
                                                                                EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                                                                            border:
                                                                                OutlineInputBorder(),
                                                                          ),
                                                                          style:
                                                                              TextStyle(fontSize: 16),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                    height: 10),
                                                                CustomImageUploadButton(
                                                                    label:
                                                                        'QR code',
                                                                    onPressed:
                                                                        () {
                                                                      showPickerQR(
                                                                        context,
                                                                      );
                                                                    }),
                                                                SizedBox(
                                                                    height: 10),
                                                                SizedBox(
                                                                    height: 10),
                                                                ElevatedButton(
                                                                    style: ElevatedButton
                                                                        .styleFrom(
                                                                            backgroundColor: Colors
                                                                                .blue,
                                                                            shape:
                                                                                RoundedRectangleBorder(
                                                                              borderRadius: BorderRadius.circular(8),
                                                                            )),
                                                                    onPressed:
                                                                        () {
                                                                      // updateProfile();
                                                                      print(
                                                                          "test");
                                                                      updatePaymentShop();
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                    },
                                                                    child: Container(
                                                                        child: Center(
                                                                            child: Text(
                                                                      'ยืนยันการแก้ไข',
                                                                      style: TextStyle(
                                                                          color:
                                                                              Colors.white),
                                                                    )))),
                                                              ]),
                                                        )));
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
                                              'แก้ไขรูปธุรกรรม',
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
                          ));
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
                      "ข้อมูลรูปภาพร้านค้า",
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
