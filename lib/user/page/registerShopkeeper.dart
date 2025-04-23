import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/components/textFieldComponent.dart';
import 'package:mobile/user/page/selectMap.dart';
import 'package:mobile/user/service/auth.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/user/service/controller/googlemap.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterShopkeeper extends StatefulWidget {
  @override
  State<RegisterShopkeeper> createState() => _RegisterShopkeeperState();
}

class _RegisterShopkeeperState extends State<RegisterShopkeeper> {
  //Google map

  //
  final FirebaseAuthService _auth = FirebaseAuthService();
  final ImagePicker picker = ImagePicker();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController shopNameController = TextEditingController();
  final TextEditingController branchController = TextEditingController();
  final TextEditingController telController = TextEditingController();
  final TextEditingController birthdayController = TextEditingController();
  final TextEditingController placeController = TextEditingController();
  final TextEditingController postcodeController = TextEditingController();
  final TextEditingController nameShopkeeperController =
      TextEditingController();
  final TextEditingController surnameShopkeeperController =
      TextEditingController();
  final TextEditingController placeShopkeeperController =
      TextEditingController();
  final TextEditingController nationalityShopkeeperController =
      TextEditingController();
  final TextEditingController birthdayShopkeeperController =
      TextEditingController();

  final TextEditingController postcodeShopkeeperController =
      TextEditingController();
  final TextEditingController telShopkeeperController = TextEditingController();

  File? ShopCoverImg;
  File? ShopImg;
  File? CertificateImg;

  bool regisLoading = false;

  // shop place
  String? selectedProvince;
  String? selectedDistrict;
  String? selectedSubDistrict;
  // user place
  String? selectedUserProvince;
  String? selectedUserDistrict;
  String? selectedUserSubDistrict;

  bool firstPageValidate = false;
  bool secondPageValidate = false;
  bool thirdPageValidate = false;
  bool fourthPageValidate = false;

  int currentPage = 0;
  bool pinMap = false;
  Map googleLocate = {
    'lat': null,
    'lng': null,
    'formatted_address': null,
    'place_name': null,
  };
  final PageController _pageController = PageController();

  final Map<String, List<String>> provinceToDistricts = {
    'กรุงเทพมหานคร': ['เขตพระนคร', 'เขตดุสิต', 'เขตหนองจอก'],
    'นนทบุรี': ['เมืองนนทบุรี', 'บางกรวย', 'บางใหญ่'],
    'ปทุมธานี': ['เมืองปทุมธานี', 'คลองหลวง', 'ธัญบุรี'],
  };
  final Map<String, List<String>> districtToSubDistricts = {
    'เขตพระนคร': ['แขวงพระบรมมหาราชวัง', 'แขวงวังบูรพาภิรมย์'],
    'เขตดุสิต': ['แขวงดุสิต', 'แขวงวชิรพยาบาล'],
    'เขตหนองจอก': ['แขวงกระทุ่มราย', 'แขวงหนองจอก'],
    'เมืองนนทบุรี': ['ตำบลสวนใหญ่', 'ตำบลบางเขน'],
    'บางกรวย': ['ตำบลบางกรวย', 'ตำบลบางขนุน'],
    'บางใหญ่': ['ตำบลบางใหญ่', 'ตำบลเสาธงหิน'],
    'เมืองปทุมธานี': ['ตำบลบางปรอก', 'ตำบลบางพูด'],
    'คลองหลวง': ['ตำบลคลองหนึ่ง', 'ตำบลคลองสอง'],
    'ธัญบุรี': ['ตำบลรังสิต', 'ตำบลประชาธิปัตย์'],
  };
  var pathAPI = '';
  @override
  void initState() {
    super.initState();
    emailController.addListener(checkFields);
    passwordController.addListener(checkFields);
    shopNameController.addListener(checkFields);
    placeController.addListener(checkFields);
    postcodeController.addListener(checkFields);
    telController.addListener(checkFields);
    birthdayController.addListener(checkFields);
    nameShopkeeperController.addListener(checkFields);
    nationalityShopkeeperController.addListener(checkFields);
    surnameShopkeeperController.addListener(checkFields);
    placeShopkeeperController.addListener(checkFields);
    postcodeShopkeeperController.addListener(checkFields);
    postcodeController.addListener(checkFields);
    selectedProvince = provinceToDistricts.keys.first;
    selectedDistrict = provinceToDistricts[selectedProvince]!.first;
    selectedSubDistrict = districtToSubDistricts[selectedDistrict]!.first;

    selectedUserProvince = provinceToDistricts.keys.first;
    selectedUserDistrict = provinceToDistricts[selectedUserProvince]!.first;
    selectedUserSubDistrict =
        districtToSubDistricts[selectedUserDistrict]!.first;

    postcodeShopkeeperController.addListener(checkFields);
    if (provinceToDistricts.isNotEmpty) {
      selectedProvince = provinceToDistricts.keys.first;
      if (provinceToDistricts[selectedProvince]!.isNotEmpty) {
        selectedDistrict = provinceToDistricts[selectedProvince]!.first;
        if (districtToSubDistricts[selectedDistrict]!.isNotEmpty) {
          selectedSubDistrict = districtToSubDistricts[selectedDistrict]!.first;
        }
      }
      selectedUserProvince = provinceToDistricts.keys.first;
      if (provinceToDistricts[selectedUserProvince]!.isNotEmpty) {
        selectedUserDistrict = provinceToDistricts[selectedUserProvince]!.first;
        if (districtToSubDistricts[selectedUserDistrict]!.isNotEmpty) {
          selectedUserSubDistrict =
              districtToSubDistricts[selectedUserDistrict]!.first;
        }
      }
    }
    _pageController.addListener(() {
      setState(() {
        currentPage = _pageController.page?.round() ?? 0;
      });
    });
  }

  void checkFields() {
    setState(() {
      firstPageValidate =
          emailController.text.isNotEmpty && passwordController.text.isNotEmpty;
      secondPageValidate = shopNameController.text.isNotEmpty &&
          postcodeController.text.isNotEmpty &&
          placeController.text.isNotEmpty;
      thirdPageValidate =
          telController.text.isNotEmpty && emailController.text.isNotEmpty;
      fourthPageValidate = nameShopkeeperController.text.isNotEmpty &&
          surnameShopkeeperController.text.isNotEmpty &&
          nationalityShopkeeperController.text.isNotEmpty &&
          placeShopkeeperController.text.isNotEmpty &&
          postcodeShopkeeperController.text.isNotEmpty;
    });
  }

  TimeOfDay? openTime;
  TimeOfDay? closeTime;
  String formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    final format = MaterialLocalizations.of(context).formatTimeOfDay(time);
    return format;
  }

  String formatTimeOfDay2(TimeOfDay? time) {
    // final format = MaterialLocalizations.of(context).formatTimeOfDay(time);
    String formattedTime = "${time?.hour.toString().padLeft(2, '0')}:"
        "${time?.minute.toString().padLeft(2, '0')}";
    print("test $formattedTime");
    return formattedTime;
  }

  Future<void> _selectOpenTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: openTime ?? TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue, // Header background color
              onPrimary: Colors.white, // Header text color
              surface: Colors.white, // Background color
              onSurface: Colors.black, // Text color
            ),
            dialogBackgroundColor:
                Colors.white, // Background color of the dialog
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != openTime) {
      setState(() {
        openTime = picked;
        print(formatTimeOfDay2(openTime));
      });
    }
  }

  Future<void> _selectCloseTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: closeTime ?? TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue, // Header background color
              onPrimary: Colors.white, // Header text color
              surface: Colors.white, // Background color
              onSurface: Colors.black, // Text color
            ),
            dialogBackgroundColor:
                Colors.white, // Background color of the dialog
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != closeTime) {
      setState(() {
        closeTime = picked;
        print(formatTimeOfDay2(closeTime));
        print(closeTime);
      });
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
                  getImage();
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

  Future getImage() async {
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      setState(() {
        if (pickedFile != null) {
          ShopCoverImg = File(pickedFile.path);
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

  void showPicker2(BuildContext context) {
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
                  getImage2();
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

  Future getImage2() async {
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      setState(() {
        if (pickedFile != null) {
          ShopImg = File(pickedFile.path);
        }
      });
    } on Exception catch (e) {
      print(e);
    }
  }

  Future<void> openCamera2(BuildContext context) async {
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      // Handle the captured image
      print('Image path: ${image.path}');
    }
  }

  void showPicker3(BuildContext context) {
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
                  getImage3();
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

  Future getImage3() async {
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      setState(() {
        if (pickedFile != null) {
          CertificateImg = File(pickedFile.path);
        }
      });
    } on Exception catch (e) {
      print(e);
    }
  }

  Future<void> openCamera3(BuildContext context) async {
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      // Handle the captured image
      print('Image path: ${image.path}');
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }

  void previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }

  Future<bool> _onWillPop() async {
    if (currentPage > 0) {
      previousPage();
      return Future.value(false);
    }
    return Future.value(true);
  }

  Future<void> signUpFunc() async {
    await fetchUrl();
    await _signUp();
  }

  Future<void> fetchUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      pathAPI = prefs.getString('apiUrl') ?? 'http://10.0.2.2:3000';
    });
    print(pathAPI);
  }

  Future<void> _signUp() async {
    String email = emailController.text;
    String password = passwordController.text;
    String name = shopNameController.text;
    String tel = telController.text;
    String birthday = birthdayController.text;
    // User? user;
    try {
      User? user = await _auth.signUpWithEmailAndPassword(email, password);
      setState(() {
        regisLoading = true;
      });
      if (user != null) {
        print('Sign up success');
        print(user);
        print(user.uid);

        // Create the request
        final url = Uri.parse("http://$pathAPI/authentication/registerShop");
        var request = http.MultipartRequest('POST', url);

        // Add the JSON fields to the request
        request.fields['uid'] = user.uid;
        request.fields['role'] = "shopkeeper";
        request.fields['tel'] = telShopkeeperController.text ?? '';
        request.fields['email'] = emailController.text ?? '';
        request.fields['shopName'] = shopNameController.text ?? '';
        request.fields['branch'] = branchController.text ?? '';

        request.fields['shopkeeperData[name]'] =
            nameShopkeeperController.text ?? '';
        request.fields['shopkeeperData[surname]'] =
            surnameShopkeeperController.text ?? '';
        request.fields['shopkeeperData[nationality]'] =
            nationalityShopkeeperController.text ?? '';

        request.fields['shopLocation_th[place]'] = placeController.text ?? '';
        request.fields['shopLocation_th[province]'] = selectedProvince ?? '';
        request.fields['shopLocation_th[district]'] = selectedDistrict ?? '';
        request.fields['shopLocation_th[subdistrict]'] =
            selectedSubDistrict ?? '';
        request.fields['shopLocation_th[postcode]'] =
            postcodeController.text ?? '';

        request.fields['googleLocation[lat]'] =
            googleLocate['lat']?.toString() ?? '';
        request.fields['googleLocation[lng]'] =
            googleLocate['lng']?.toString() ?? '';
        request.fields['googleLocation[formatted_address]'] =
            googleLocate['formatted_address'] ?? '';
        request.fields['googleLocation[place_name]'] =
            googleLocate['place_name'] ?? '';

        request.fields['shopkeeperLocation[userPlace]'] =
            placeShopkeeperController.text;
        request.fields['shopkeeperLocation[province]'] = selectedUserProvince!;
        request.fields['shopkeeperLocation[district]'] = selectedUserDistrict!;
        request.fields['shopkeeperLocation[subdistrict]'] =
            selectedUserSubDistrict!;
        request.fields['shopkeeperLocation[postcode]'] =
            postcodeShopkeeperController.text;

        request.fields['openAt'] = formatTimeOfDay2(openTime);
        request.fields['closeAt'] = formatTimeOfDay2(closeTime);

        // Add image files
        List<http.MultipartFile> imageFiles = [];

        if (ShopCoverImg != null) {
          imageFiles.add(await http.MultipartFile.fromPath(
            'images',
            ShopCoverImg!.path,
          ));
        }

        if (ShopImg != null) {
          imageFiles.add(await http.MultipartFile.fromPath(
            'images',
            ShopImg!.path,
          ));
        }

        if (CertificateImg != null) {
          imageFiles.add(await http.MultipartFile.fromPath(
            'images',
            CertificateImg!.path,
          ));
        }

        request.files.addAll(imageFiles);

        // Send the request
        var response = await request.send();

        // Read the response
        if (response.statusCode == 200) {
          setState(() {
            regisLoading = false;
          });
          print('Uploaded successfully');
          Navigator.pushNamed(context, '/signIn');
        } else {
          setState(() {
            regisLoading = false;
          });
          print('Failed to upload');
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        regisLoading = false;
      });
      _auth.handleFirebaseAuthError(e);
      print(e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
        onWillPop: _onWillPop,
        child: Stack(children: [
          Scaffold(
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              leading: currentPage == 1
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () {
                        _pageController.animateToPage(
                          0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeIn,
                        );
                      },
                    )
                  : null,
            ),
            body: PageView(
              // scrollDirection: Axis.vertical,
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                SingleChildScrollView(
                  child: Container(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      child: Center(
                          child: Padding(
                        padding: const EdgeInsets.only(left: 40, right: 40),
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 20,
                            ),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text('ตั้งค่าอีเมล์และรหัสผ่าน',
                                    style: TextStyle(fontSize: 24)),
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            const Text(
                              'คุณสามารถใช้สิ่งนี้เพื่อเข้าสู่ระบบ เราจะแนะนำคุณตลอด\nกระบวนการเริ่มต้นใช้งานหลังจากบัญชีของคุณได้รับ\nแล้วสร้าง.',
                              style: TextStyle(
                                  color: Color.fromARGB(255, 134, 134, 134)),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Container(
                              width: 300,
                              height: 40,
                              child: buildBorderTextField(emailController,
                                  'อีเมล', 'name@example.com', false),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Container(
                              width: 300,
                              height: 40,
                              child: buildBorderTextField(passwordController,
                                  'รหัสผ่าน', 'ป้อนรหัสผ่านที่ปลอดภัย', true),
                            ),
                            const SizedBox(
                              height: 380,
                            ),
                            SizedBox(
                              width: 230,
                              child: ElevatedButton(
                                onPressed: firstPageValidate ? nextPage : null,
                                style: ElevatedButton.styleFrom(
                                  shadowColor: Colors.transparent,
                                  backgroundColor: firstPageValidate
                                      ? Colors.blue
                                      : Colors.grey,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                child: Text(
                                  'ไปหน้าถัดไป',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: GoogleFonts.mitr().fontFamily,
                                      color: firstPageValidate
                                          ? Colors.white
                                          : const Color.fromARGB(
                                              255, 56, 56, 56)),
                                ),
                              ),
                            ),
                            // const ClipRect(
                            //   child: Row(
                            //     mainAxisAlignment: MainAxisAlignment.center,
                            //     children: [
                            //       Icon(
                            //         Icons.arrow_downward,
                            //         color: Colors.grey,
                            //       ),
                            //       SizedBox(
                            //         width: 10,
                            //       ),
                            //       Text(
                            //         'ไปหน้าถัดไป',
                            //         style:
                            //             TextStyle(fontSize: 20, color: Colors.grey),
                            //       ),
                            //       Icon(
                            //         Icons.arrow_downward,
                            //         color: Colors.transparent,
                            //       ),
                            //     ],
                            //   ),
                            // )
                          ],
                        ),
                      ))),
                ),
                SingleChildScrollView(
                  child: Container(
                    color: Colors.white,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 40, right: 40),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            const Text(
                              'ข้อมูลร้านค้า',
                              style: TextStyle(
                                fontSize: 24,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'ข้อมูลของผู้ดูแลร้านค้า ไว้ติดต่อร้านค้ากรณีที่เกิดปัญหา',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                            const SizedBox(height: 20),
                            buildUnderlineTextField(shopNameController,
                                'ชื่อร้าน', 'ชื่อร้าน', false, false),
                            const SizedBox(height: 16),
                            buildUnderlineTextField(
                                branchController,
                                'ชื่อสาขา / ย่าน (ถ้ามี)',
                                'ชื่อสาขา',
                                false,
                                false),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                const Text('ที่อยู่ร้าน'),
                                Spacer(),
                                Text(pinMap ? 'ปักหมุดแล้ว' : 'ยังไม่ปักหมุด',
                                    style: TextStyle(
                                        color: pinMap
                                            ? Colors.green
                                            : Colors.red)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 60,
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            SelectMapLocate()),
                                  );
                                  print(result);
                                  setState(() {
                                    if (result != null) {
                                      googleLocate = result;
                                      pinMap = true;
                                    }
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  side: const BorderSide(
                                      color: Color(0xFFD1D1D1)),
                                  elevation: 1,
                                  shadowColor: Colors.black.withOpacity(0.1),
                                  backgroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.location_on_outlined,
                                        color: Colors.grey[600], size: 20),
                                    const SizedBox(width: 12),
                                    Text(
                                      'ปักหมุดที่ตั้งร้าน',
                                      style: TextStyle(
                                        fontFamily:
                                            GoogleFonts.mitr().fontFamily,
                                        color: Colors.grey[800],
                                        fontSize: 16,
                                      ),
                                    ),
                                    const Icon(Icons.location_on_outlined,
                                        color: Colors.transparent, size: 20),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            buildUnderlineTextField(
                                placeController,
                                'เลขที่อยู่ร้าน หรือ ข้อมูลสถานที่ตั้งร้าน (โดยละเอียด)',
                                'กรอกเลขที่บ้านพร้อมชื่อถนน หรืออสถานที่ใกล้เคียง',
                                false,
                                false),
                            const SizedBox(height: 16),
                            SelectOption(
                              label: "จังหวัด",
                              options: provinceToDistricts.keys.toList(),
                              selectedValue: selectedProvince ?? '',
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedProvince = newValue!;
                                  selectedDistrict =
                                      provinceToDistricts[selectedProvince]!
                                          .first;
                                  selectedSubDistrict =
                                      districtToSubDistricts[selectedDistrict]!
                                          .first;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            if (selectedProvince != null)
                              SelectOption(
                                label: "อำเภอ / เขต",
                                options: provinceToDistricts[selectedProvince]!,
                                selectedValue: selectedDistrict ?? '',
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedDistrict = newValue!;
                                    selectedSubDistrict =
                                        districtToSubDistricts[
                                                selectedDistrict]!
                                            .first;
                                  });
                                },
                              ),
                            const SizedBox(height: 16),
                            if (selectedProvince != null)
                              SelectOption(
                                label: "ตำบล / แขวง",
                                options:
                                    districtToSubDistricts[selectedDistrict]!,
                                selectedValue: selectedSubDistrict ?? '',
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedSubDistrict = newValue!;
                                  });
                                },
                              ),
                            const SizedBox(height: 16),
                            buildUnderlineTextField(postcodeController,
                                'รหัสไปรษณีย์', 'รหัสไปรษณีย์', false, false),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 280,
                                  child: ElevatedButton(
                                    onPressed:
                                        secondPageValidate ? nextPage : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: secondPageValidate
                                          ? Colors.blue
                                          : const Color.fromARGB(
                                              135, 199, 199, 199),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                    child: Text(
                                      secondPageValidate
                                          ? 'ดำเนินการต่อ'
                                          : 'กรุณากรอกข้อมูลให้ครบ',
                                      style: TextStyle(
                                          color: secondPageValidate
                                              ? Colors.white
                                              : const Color.fromARGB(
                                                  255, 60, 60, 60),
                                          fontSize: 16),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SingleChildScrollView(
                  child: Container(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 40, right: 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          const Text(
                            'ติดต่อร้านค้า และ เวลาเปิดปิด',
                            style: TextStyle(
                              fontSize: 24,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'ลูกค้าอาจติดต่อคุณไปทางเบอร์โทรศัพท์หรืออีเมลนี้',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'และ เวลาเปิดปิดร้านค้าของคุณ',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          const SizedBox(height: 10),
                          buildUnderlineTextField(telShopkeeperController,
                              'เบอร์โทรศัพท์', 'เบอร์โทรศัพท์', false, false),
                          const SizedBox(height: 16),
                          buildUnderlineTextField(
                              emailController, 'อีเมล', 'อีเมล', false, true),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    'เวลาเปิดร้าน',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  if (openTime != null)
                                    Text(
                                      '${openTime!.format(context)}',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  if (openTime == null)
                                    Text(
                                      '         ',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  Container(
                                    width: 100,
                                    child: ElevatedButton(
                                      onPressed: () => _selectOpenTime(context),
                                      child: Text(
                                        'เวลาเปิดร้าน',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        shadowColor: Colors.transparent,
                                        backgroundColor: firstPageValidate
                                            ? Colors.green
                                            : Colors.grey,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Text(
                                    'เวลาปิดร้าน',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  if (closeTime != null)
                                    Text(
                                      '${closeTime!.format(context)}',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  if (closeTime == null)
                                    Text(
                                      '         ',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  Container(
                                    width: 100,
                                    child: ElevatedButton(
                                      onPressed: () =>
                                          _selectCloseTime(context),
                                      child: Text(
                                        'เวลาปิดร้าน',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        shadowColor: Colors.transparent,
                                        backgroundColor: firstPageValidate
                                            ? Colors.red
                                            : Colors.grey,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 300),
                          Center(
                            child: SizedBox(
                              width: 230,
                              child: ElevatedButton(
                                onPressed: firstPageValidate ? nextPage : null,
                                style: ElevatedButton.styleFrom(
                                  shadowColor: Colors.transparent,
                                  backgroundColor: firstPageValidate
                                      ? Colors.blue
                                      : Colors.grey,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                child: Text(
                                  'ไปหน้าถัดไป',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: GoogleFonts.mitr().fontFamily,
                                      color: firstPageValidate
                                          ? Colors.white
                                          : const Color.fromARGB(
                                              255, 56, 56, 56)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 40, right: 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        const Text(
                          'รายละเอียดร้าน',
                          style: TextStyle(
                            fontSize: 24,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'ใส่รูปภาพของร้านค้า สินค้าของคุณ เพื่อให้ลูกค้ารับรู้ร้านค้าของคุณ และ ทะเบียนพาณิชย์ไว้สำหรับยืนยันว่าร้านค้าของคุณเป็นร้านค้าที่ถูกต้อง ',
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 24),
                        CustomImageUploadButton(
                            label: 'รูปหน้าปกร้าน',
                            onPressed: () {
                              showPicker(
                                context,
                              );
                            }),
                        const SizedBox(height: 16),
                        CustomImageUploadButton(
                            label: 'รูปประจำร้าน',
                            onPressed: () {
                              showPicker2(
                                context,
                              );
                            }),
                        const SizedBox(height: 16),
                        CustomImageUploadButton(
                            label: 'ใบทะเบียนพาณิชย์',
                            onPressed: () {
                              showPicker3(
                                context,
                              );
                            }),
                        const SizedBox(height: 166),
                        Center(
                          child: SizedBox(
                            width: 230,
                            child: ElevatedButton(
                              onPressed: firstPageValidate ? nextPage : null,
                              style: ElevatedButton.styleFrom(
                                shadowColor: Colors.transparent,
                                backgroundColor: firstPageValidate
                                    ? Colors.blue
                                    : Colors.grey,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              child: Text(
                                'ไปหน้าถัดไป',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: GoogleFonts.mitr().fontFamily,
                                    color: firstPageValidate
                                        ? Colors.white
                                        : const Color.fromARGB(
                                            255, 56, 56, 56)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SingleChildScrollView(
                  child: Container(
                    color: Colors.white,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 40, right: 40),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            const Text(
                              'ข้อมูลผู้ดูแล',
                              style: TextStyle(
                                fontSize: 24,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'เราจะแสดงข้อมูลต่อไปนี้ของคุณให้ลูกค้าบนแอปฯ',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Container(
                                  width: 150,
                                  child: buildUnderlineTextField(
                                      nameShopkeeperController,
                                      'ชื่อ',
                                      'ใส่ชื่อจริงของผู้ดูแลร้าน',
                                      false,
                                      false),
                                ),
                                SizedBox(width: 10),
                                Container(
                                  width: 150,
                                  child: buildUnderlineTextField(
                                      surnameShopkeeperController,
                                      'นามสกุล ',
                                      'ใส่นามสกุลของผู้ดูแล',
                                      false,
                                      false),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            buildUnderlineTextField(
                                nationalityShopkeeperController,
                                'เชื้อชาติ',
                                'เชื้อชาติ',
                                false,
                                false),
                            const SizedBox(height: 8),
                            buildUnderlineTextField(
                                placeShopkeeperController,
                                'ที่อยู่อาศัย (โดยละเอียด)',
                                'กรอกเลขที่บ้านพร้อมชื่อถนน หรืออสถานที่ใกล้เคียง',
                                false,
                                false),
                            const SizedBox(height: 16),
                            SelectOption(
                              label: "จังหวัด",
                              options: provinceToDistricts.keys.toList(),
                              selectedValue: selectedUserProvince ?? '',
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedUserProvince = newValue!;
                                  selectedUserDistrict =
                                      provinceToDistricts[selectedUserProvince]!
                                          .first;
                                  selectedUserSubDistrict =
                                      districtToSubDistricts[
                                              selectedUserDistrict]!
                                          .first;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            if (selectedProvince != null)
                              SelectOption(
                                label: "อำเภอ / เขต",
                                options:
                                    provinceToDistricts[selectedUserProvince]!,
                                selectedValue: selectedUserDistrict ?? '',
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedUserDistrict = newValue!;
                                    selectedUserSubDistrict =
                                        districtToSubDistricts[
                                                selectedUserDistrict]!
                                            .first;
                                  });
                                },
                              ),
                            const SizedBox(height: 16),
                            if (selectedProvince != null)
                              SelectOption(
                                label: "ตำบล / แขวง",
                                options: districtToSubDistricts[
                                    selectedUserDistrict]!,
                                selectedValue: selectedUserSubDistrict ?? '',
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedUserSubDistrict = newValue!;
                                  });
                                },
                              ),
                            const SizedBox(height: 16),
                            buildUnderlineTextField(
                                postcodeShopkeeperController,
                                'รหัสไปรษณีย์',
                                'รหัสไปรษณีย์',
                                false,
                                false),
                            const SizedBox(height: 68),
                            Center(
                              child: SizedBox(
                                width: 280,
                                child: ElevatedButton(
                                  onPressed:
                                      fourthPageValidate ? signUpFunc : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: fourthPageValidate
                                        ? Colors.blue
                                        : const Color.fromARGB(
                                            135, 199, 199, 199),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                  child: Text(
                                    fourthPageValidate
                                        ? 'ดำเนินการต่อ'
                                        : 'กรุณากรอกข้อมูลให้ครบ',
                                    style: TextStyle(
                                        color: fourthPageValidate
                                            ? Colors.white
                                            : const Color.fromARGB(
                                                255, 60, 60, 60),
                                        fontSize: 16),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (regisLoading)
            Container(
              color: Colors.black.withOpacity(0.3), // สีดำโปร่งบาง
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white), // ให้สีวงกลมเป็นขาว
                ),
              ),
            ),
        ]));
  }
}
