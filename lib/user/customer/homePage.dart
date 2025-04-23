import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/components/bottomNav.dart';
import 'package:mobile/user/customer/allshopNear.dart';
import 'package:mobile/user/customer/homePage.dart';
import 'package:mobile/user/customer/mailBox.dart';
import 'package:mobile/user/customer/favoritePage.dart';
import 'package:mobile/user/customer/productInshop.dart';
import 'package:mobile/user/customer/settingsPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Homepage extends StatefulWidget {
  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  List<dynamic> listProducts = [];
  List<dynamic> filteredItems = [];
  Map<String, dynamic>? userProfileData;
  TextEditingController searchController = TextEditingController();
  bool _isLoading = false;
  var pathAPI = '';
  //int _currentIndex = 2;

  @override
  void initState() {
    super.initState();
    initFetch();
    searchController.addListener(filterItems);
  }

  @override
  void dispose() {
    searchController.removeListener(filterItems);
    searchController.dispose();
    super.dispose();
  }

  void filterItems() {
    setState(() {
      filteredItems = listProducts
          .where((item) => item['name']
              .toLowerCase()
              .contains(searchController.text.toLowerCase()))
          .toList();
    });
  }

  Future<void> initFetch() async {
    await fetchUrl();
    await _fetchData();
    await _fetchProfile();
  }

  Future<void> fetchUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      pathAPI = prefs.getString('apiUrl') ?? 'http://10.0.2.2:3000';
    });
    print(pathAPI);
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });
    final url = Uri.parse("http://$pathAPI/customer/availableShop");

    try {
      var response = await http.get(url);
      final Map<String, dynamic> responseData = json.decode(response.body);
      print(responseData);

      if (response.statusCode == 200) {
        setState(() {
          listProducts = responseData['data'];
          filteredItems = listProducts;
          _isLoading = false;
        });
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

  Future<String?> getUID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_uid');
  }

  Future<void> _fetchProfile() async {
    String? uid = await getUID();
    final url = Uri.parse("http://$pathAPI/customer/profileDetail?uid=$uid");

    try {
      var response = await http.get(url);
      final Map<String, dynamic> responseData = json.decode(response.body);
      print("http://$pathAPI/customer/profileDetail?uid=$uid");

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

  Future<void> updateFav(String shopUID) async {
    String? uid = await getUID();
    final url = Uri.parse("http://$pathAPI/customer/favoriteShop");

    try {
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'shopUid': shopUID, 'uid': uid}),
      );
      final Map<String, dynamic> responseData = json.decode(response.body);
      print("http://$pathAPI/customer/profileDetail?uid=$uid");

      if (response.statusCode == 200) {
        setState(() {
          userProfileData = responseData['data'];
        });
        print(userProfileData);
      } else {
        // Handle error
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Color.fromRGBO(255, 104, 56, 1),
        body: Column(
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
            SizedBox(height: 20),
            Expanded(
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: Icon(Icons.search, color: Colors.grey),
                          hintText: 'ค้นหาร้านค้า',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'ร้านค้ากำลังลดราคา',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'ดูทั้งหมด',
                            style: TextStyle(fontSize: 16, color: Colors.blue),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: _isLoading
                          ? Center(
                              child: CircularProgressIndicator(),
                            )
                          : SingleChildScrollView(
                              child: Column(
                                children: filteredItems.map((item) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 20),
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ProductInShop(
                                              shopData: item,
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
                                          boxShadow: [
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
                                                  image: NetworkImage(item[
                                                              'imgUrl']
                                                          ['shopUrl'] ??
                                                      'https://via.placeholder.com/150'),
                                                  fit: BoxFit.cover,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                            ),
                                            SizedBox(width: 20),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    item['name'],
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  SizedBox(height: 5),
                                                  Text(
                                                    'เวลาเปิด - ปิด ( ${item['openAt']} -  ${item['closeAt']} )',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  SizedBox(height: 5),
                                                  // Text(
                                                  //   'ระยะห่าง',
                                                  //   style: TextStyle(
                                                  //     fontSize: 12,
                                                  //     color: Colors.black,
                                                  //   ),
                                                  // ),
                                                ],
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () {
                                                updateFav(item['shopId']);
                                                setState(() {
                                                  initFetch();
                                                });
                                              },
                                              child: Icon(
                                                userProfileData?['favShop']
                                                            ?.contains(item[
                                                                'shopId']) ??
                                                        false
                                                    ? Icons.favorite
                                                    : Icons.favorite_border,
                                                color: Colors.red,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ), //นี่
                            ), //นี้
                    ), //บรรทัดนี้
                    // invisible product
                    Container(
                      height: 75,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    )
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
