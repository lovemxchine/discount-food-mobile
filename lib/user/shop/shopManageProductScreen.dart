import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ManageProductScreen extends StatefulWidget {
  const ManageProductScreen({super.key});

  State<ManageProductScreen> createState() => ManageProductScreenState();
}

// TODO: fixed reload realtime data
class ManageProductScreenState extends State<ManageProductScreen> {
  List<dynamic> listProducts = [];
  bool isLoading = true;
  MediaType mediaType = MediaType('application', 'json');
  var pathAPI = '';
  @override
  void initState() {
    super.initState();
    initFetch();
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
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 16),
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.pushNamed(
                                            context, '/shop/addProduct');
                                      },
                                      child: Container(
                                        height: 110,
                                        padding: const EdgeInsets.all(16),
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
                                        child: const Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Spacer(),
                                            Icon(Icons.add),
                                            Spacer()
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  for (int i = 0; i < listProducts.length; i++)
                                    if (listProducts[i] != null)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8, horizontal: 16),
                                        child: InkWell(
                                          onTap: () {
                                            // print(listProducts[i]['discountAt']);
                                            Navigator.pushNamed(
                                                context, '/test/image',
                                                arguments: listProducts[i]);
                                          },
                                          child: Container(
                                            height: 110,
                                            padding: const EdgeInsets.all(16),
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
                                                              listProducts[i]
                                                                  ['imageUrl'])
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
                                                      Text(
                                                        listProducts[i]
                                                            ['productName'],
                                                        style: const TextStyle(
                                                            fontSize: 16,
                                                            color:
                                                                Colors.black),
                                                      ),
                                                      const SizedBox(height: 5),
                                                      const Text(
                                                        'ระยะเวลาเปิด - ปิด (10:00 - 22:00)',
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            color:
                                                                Colors.black),
                                                      ),

                                                      // const Text(
                                                      //   'ระยะห่าง 1.5km',
                                                      //   style: TextStyle(
                                                      //       fontSize: 14,
                                                      //       color:
                                                      //           Colors.black),
                                                      // ),
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
