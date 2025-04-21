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

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<dynamic> listProducts = [];
  bool isLoading = true;
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
    await _fetchData();
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

  Future<void> _fetchData() async {
    // Uri url = "http://52.65.210.113:3000/" as Uri;
    String? uid = await getUID();
    final url = Uri.parse("http://$pathAPI/shop/${uid}/getAllProduct");
    var response = await http.get(
      url,
    );
    final responseData = jsonDecode(response.body);
    setState(() {
      listProducts = responseData['data'];
      listProducts.add(null);
    });

    isLoading = false;

    // List arrData = decodedData['data'];
    print(listProducts.length);
    print(listProducts);
    print("hi");
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF3864FF),
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFF3864FF),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.only(
                      top: 40.0,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(width: 16),
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            image: const DecorationImage(
                              image: AssetImage('assets/images/confuse.jpg'),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Guest',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white),
                            ),
                            const SizedBox(height: 5),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 25, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 224, 217, 217),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'ร้านค้า',
                                style: TextStyle(
                                    fontSize: 13, color: Colors.black),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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
                        child: isLoading
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
                                                      Text("บัญชีร้านค้า",
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
                                                                    "รายละเอียดบัญชีร้านค้า",
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
