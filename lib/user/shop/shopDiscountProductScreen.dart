import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
import 'package:mobile/user/shop/shopProductDetailScreen.dart';
import 'package:mobile/user/shop/shopProductUpdateScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DiscountProductScreen extends StatefulWidget {
  const DiscountProductScreen({super.key});

  State<DiscountProductScreen> createState() => DiscountProductScreenState();
}

// TODO: fixed reload realtime data
class DiscountProductScreenState extends State<DiscountProductScreen> {
  List<dynamic> listProducts = [];
  bool isLoading = true;
  MediaType mediaType = MediaType('application', 'json');
  var pathAPI = '';
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
    });
    print(pathAPI);
  }

  Future<void> _fetchData() async {
    String? uid = await getUID();
    final url = Uri.parse("$pathAPI/shop/${uid}/getAllProduct");
    var response = await http.get(
      url,
    );
    final responseData = jsonDecode(response.body);
    setState(() {
      listProducts = responseData['data'];
    });
    while (responseData['data'].length < 3) {
      setState(() {
        listProducts.add(null);
      });
    }
    print("H");
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
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'สินค้าที่กำลังลดราคา',
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
                                  for (int i = 0; i < listProducts.length; i++)
                                    if (listProducts[i] != null)
                                      if (listProducts[i]['showStatus'] &&
                                          listProducts[i]['stock'] > 0)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8, horizontal: 20),
                                          child: InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ProductUpdateScreen(
                                                    productData:
                                                        listProducts[i],
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Container(
                                              height: 90,
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                boxShadow: const [
                                                  BoxShadow(
                                                    color: Colors.black26,
                                                    blurRadius: 1,
                                                    offset: Offset(0, 4),
                                                  ),
                                                ],
                                              ),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    width: 80,
                                                    height: 80,
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey,
                                                      image: DecorationImage(
                                                        image: Image.network(
                                                                listProducts[i][
                                                                    'imageUrl'])
                                                            .image,
                                                        fit: BoxFit.cover,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 20),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Text(
                                                              listProducts[i][
                                                                  'productName'],
                                                              style: const TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .black),
                                                            ),
                                                            Spacer(),
                                                            RichText(
                                                              text: TextSpan(
                                                                text:
                                                                    'สถานะ : ',
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        GoogleFonts.mitr()
                                                                            .fontFamily,
                                                                    fontSize:
                                                                        12,
                                                                    color: Colors
                                                                        .black),
                                                                children: [
                                                                  TextSpan(
                                                                    text: listProducts[i]
                                                                            [
                                                                            'showStatus']
                                                                        ? 'กำลังขาย'
                                                                        : 'ไม่ได้ขาย',
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      color: listProducts[i]
                                                                              [
                                                                              'showStatus']
                                                                          ? Colors
                                                                              .green
                                                                          : Colors
                                                                              .red,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            SizedBox(width: 20),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                            height: 5),
                                                        Row(
                                                          children: [
                                                            Text(
                                                              'ราคาเดิม ${listProducts[i]['originalPrice']} บาท',
                                                              style: const TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .black),
                                                            ),
                                                            Spacer(),
                                                            Text(
                                                              'ราคาขาย ${listProducts[i]['salePrice']} บาท',
                                                              style: const TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .black),
                                                            ),
                                                            SizedBox(width: 20),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                            height: 5),
                                                        Text(
                                                          'วันที่เริ่มขาย : ${formatDiscountDate(listProducts[i]['discountAt'])}',
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .black),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
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
            ),
          ],
        ),
      ),
    );
  }
}
