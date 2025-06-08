import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
import 'package:mobile/user/shop/profileDetailScreen.dart';
import 'package:mobile/user/shop/shopProductDetailScreen.dart';

import 'package:shared_preferences/shared_preferences.dart';

class SettingsUserPage extends StatefulWidget {
  const SettingsUserPage({super.key});

  @override
  State<SettingsUserPage> createState() => _SettingsUserPageState();
}

class _SettingsUserPageState extends State<SettingsUserPage> {
  List<dynamic> listProducts = [];
  Map<String, dynamic>? userProfileData;
  bool _isLoading = false;
  MediaType mediaType = MediaType('application', 'json');
  bool isDetail = false;
  var pathAPI = '';
  @override
  void initState() {
    super.initState();
    initFetch();
  }

  void settingIsDetail() {
    setState(() {
      isDetail = !isDetail; // Ensure state updates correctly
    });
  }

  Future<void> initFetch() async {
    await fetchUrl();
    await _fetchProfile();
  }

  Future<void> fetchUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      pathAPI = prefs.getString('apiUrl') ?? 'http://10.0.2.2:3000';
    });
    print(pathAPI);
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

  Future<String?> getUID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_uid');
  }

  Future<void> _fetchProfile() async {
    String? uid = await getUID();
    final url = Uri.parse("$pathAPI/customer/profileDetail?uid=$uid");

    try {
      var response = await http.get(url);
      final Map<String, dynamic> responseData = json.decode(response.body);
      print("$pathAPI/customer/profileDetail?uid=$uid");

      if (response.statusCode == 200) {
        setState(() {
          userProfileData = responseData['data'];
          _isLoading = false;
        });
        print(userProfileData);
      } else {
        setState(() {
          _isLoading = false;
        });
        // Handle error
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        backgroundColor: Color.fromRGBO(255, 104, 56, 1),
        body: Stack(
          children: [
            Container(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 16),
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage('assets/images/alt.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      userProfileData != null
                          ? Text(
                              '${userProfileData!['fname']} ${userProfileData!['lname']}',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white),
                            )
                          : Text(
                              'กำลังโหลด...',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white),
                            ),
                      SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'ผู้ใช้งานทั่วไป',
                          style: TextStyle(fontSize: 13, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: 120,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 224, 217, 217),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16)
                          .copyWith(top: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            !isDetail ? 'ตั้งค่า' : "บัญชีของฉัน",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    Expanded(
                      child: SingleChildScrollView(
                        child: _isLoading
                            ? const Center(
                                child: CircularProgressIndicator(),
                              )
                            : Column(
                                children: [
                                  Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 20),
                                      child: Container(
                                        height: 540,
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: !isDetail
                                              ? Column(
                                                  children: [
                                                    const Row(children: [
                                                      Text("บัญชีของฉัน",
                                                          style: TextStyle(
                                                            decoration:
                                                                TextDecoration
                                                                    .underline,
                                                            fontSize: 16,
                                                          ))
                                                    ]),
                                                    SizedBox(height: 9),
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.all(8.0),
                                                      child: InkWell(
                                                          onTap: () {
                                                            settingIsDetail();
                                                          },
                                                          child: Container(
                                                            decoration:
                                                                const BoxDecoration(
                                                              border: Border(
                                                                bottom:
                                                                    BorderSide(
                                                                  color: Colors
                                                                      .black, // Underline color
                                                                  width:
                                                                      1, // Underline thickness
                                                                ),
                                                              ),
                                                            ),
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        8),
                                                            child: const Row(
                                                                children: [
                                                                  Text(
                                                                    "ข้อมูลบัญชี",
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                    ),
                                                                  ),
                                                                  Spacer(),
                                                                  Icon(
                                                                    Icons
                                                                        .arrow_forward_ios,
                                                                    size: 16,
                                                                  )
                                                                ]),
                                                          )),
                                                    ),
                                                    const Spacer(),
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.all(8.0),
                                                      child: InkWell(
                                                          onTap: () {
                                                            Navigator.pushNamed(
                                                                context,
                                                                '/signIn');
                                                          },
                                                          child: Container(
                                                            decoration:
                                                                const BoxDecoration(
                                                              border: Border(
                                                                bottom:
                                                                    BorderSide(
                                                                  color: Colors
                                                                      .black, // Underline color
                                                                  width:
                                                                      1, // Underline thickness
                                                                ),
                                                              ),
                                                            ),
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        8),
                                                            child: const Row(
                                                                children: [
                                                                  Text(
                                                                    "ออกจากระบบ",
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                    ),
                                                                  ),
                                                                ]),
                                                          )),
                                                    )
                                                  ],
                                                )
                                              : ProfileDetailScreen(
                                                  settingIsDetail:
                                                      settingIsDetail,
                                                ),
                                        ),
                                      )),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
