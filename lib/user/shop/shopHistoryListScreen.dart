import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
import 'package:mobile/user/shop/shopOrderDetailScreen.dart';
import 'package:mobile/user/shop/shopOrderHistoryDetail.dart';
import 'package:mobile/user/shop/shopProductDetailScreen.dart';
import 'package:mobile/user/shop/shopProductUpdateScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryListScreen extends StatefulWidget {
  const HistoryListScreen({super.key});

  State<HistoryListScreen> createState() => HistoryListScreenState();
}

// TODO: fixed reload realtime data
class HistoryListScreenState extends State<HistoryListScreen> {
  List<dynamic> listOrder = [];
  bool isLoading = true;
  MediaType mediaType = MediaType('application', 'json');
  var pathAPI = '';
  var fname = '';
  var lname = '';
  @override
  void initState() {
    super.initState();
    initFetch();
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

  String formatExpiredDate(String dateStr) {
    DateTime dateTime = DateTime.parse(dateStr);
    return DateFormat('dd-MM-yyyy').format(dateTime);
  }

  Future<String?> getUID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_uid');
  }

  Future<void> initFetch() async {
    await fetchUrl();
    await _fetchData();
  }

  Future<void> fetchUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      pathAPI = prefs.getString('apiUrl') ?? 'http://10.0.2.2:3000';
      fname = prefs.getString('username') ?? '';
      lname = prefs.getString('lastname') ?? '';
    });
    print(pathAPI);
  }

  String formatOrderDate(String dateStr) {
    DateTime dateTime = DateTime.parse(dateStr);
    return DateFormat('dd/MM/yyyy เวลา HH:mm น.').format(dateTime);
  }

  Future<void> _fetchData() async {
    String? uid = await getUID();
    // print("$pathAPI/shop/${uid}/fetchOrder");
    final url = Uri.parse("$pathAPI/shop/${uid}/fetchOrder");
    var response = await http.get(
      url,
    );
    final responseData = jsonDecode(response.body);

    setState(() {
      listOrder = responseData['data'] ?? [];
    });
    // while (responseData['data'].length < 3) {
    //   setState(() {
    //     listOrder.add(null);
    //   });
    // }
    isLoading = false;

    // List arrData = decodedData['data'];
    print(listOrder.length);
    print(listOrder);
    print("test log");
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
                            Text(
                              '$fname $lname',
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
                          const Text(
                            'ประวัติการรายการสั่งซื้อ',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: isLoading
                            ? const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Center(child: CircularProgressIndicator())
                                ],
                              )
                            : Column(
                                children: [
                                  for (int i = 0; i < listOrder.length; i++)
                                    if (listOrder[i] != null)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8, horizontal: 20),
                                        child: InkWell(
                                          onTap: () {
                                            print("logging ${listOrder[i]}");

                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    OrderHistoryDetailScreen(
                                                  orderData: listOrder[i],
                                                ),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            height: 90,
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Color.fromARGB(
                                                  255, 237, 237, 237),
                                              border: Border.all(
                                                color: const Color.fromARGB(
                                                    255, 181, 181, 181),
                                                width: 2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(6.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                          "วันที่ " +
                                                                  formatOrderDate(
                                                                      listOrder[
                                                                              i]
                                                                          [
                                                                          'orderAt'])
                                                              as String,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 12,
                                                          )),
                                                    ],
                                                  ),
                                                  Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                          listOrder[i]
                                                              ['status'],
                                                          style: TextStyle(
                                                              fontSize: 12,
                                                              color: listOrder[
                                                                              i]
                                                                          [
                                                                          'status'] ==
                                                                      "Pending Order"
                                                                  ? Colors
                                                                      .orange
                                                                  : listOrder[i]
                                                                              [
                                                                              'status'] ==
                                                                          "Rejected"
                                                                      ? Colors
                                                                          .red
                                                                      : Colors
                                                                          .green)),
                                                      Spacer(),
                                                      Text(
                                                        "รายละเอียดรายการ",
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        width: 5,
                                                      ),
                                                      Icon(
                                                        Icons.arrow_forward,
                                                        size: 20,
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 20),
                                      child: Container(
                                        height: 80,
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                            color: Colors.transparent),
                                      ))
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
