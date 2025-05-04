import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile/components/bottomNav.dart';
import 'package:mobile/user/customer/allshopNear.dart';
import 'package:mobile/user/customer/favoritePage.dart';
import 'package:mobile/user/customer/historyPage.dart';
import 'package:mobile/user/customer/homePage.dart';
import 'package:mobile/user/customer/mailboxDetail.dart';
import 'package:mobile/user/customer/settingsPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class MailBoxPage extends StatefulWidget {
  @override
  State<MailBoxPage> createState() => _MailBoxPageState();
}

class _MailBoxPageState extends State<MailBoxPage> {
  Map<String, dynamic>? userProfileData;
  bool _isLoading = true;
  // var pathAPI = '';

  Future<String> fetchUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('apiUrl') ?? 'http://10.0.2.2:3000';
  }

  Future<String?> getUID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_uid');
  }

  Future<void> _fetchProfile() async {
    String? uid = await getUID();
    var pathAPI = await fetchUrl();

    if (uid == null) {
      // Handle the case when UID is not available
      return;
    }
    print("pathAPI $pathAPI");
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
        print("userProfileData:  $userProfileData");
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
  void initState() {
    super.initState();
    _fetchProfile();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(255, 104, 56, 1),
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Color.fromRGBO(255, 104, 56, 1),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.only(top: 40.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(width: 16),
                        Container(
                          width: 60,
                          height: 60,
                          decoration: const BoxDecoration(
                            color: Colors.grey,
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: AssetImage('assets/images/alt.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            userProfileData != null
                                ? Text(
                                    '${userProfileData!['fname']} ${userProfileData!['lname']}',
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.white),
                                  )
                                : Text(
                                    'กำลังโหลด...',
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.white),
                                  ),
                            const SizedBox(height: 5),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'ผู้ใช้งานทั่วไป',
                                style: TextStyle(
                                    fontSize: 13, color: Colors.white),
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
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'รายการดำเนินการ',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: 16),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Historypage()),
                            );
                          },
                          child: Text(
                            'ประวัติการสั่งซื้อ',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: 2,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: InkWell(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return _buildMailBoxDetailPopup(
                                          context, index);
                                    },
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 60,
                                            height: 60,
                                            decoration: BoxDecoration(
                                              color: Colors.grey,
                                              image: const DecorationImage(
                                                image: AssetImage(
                                                    'assets/images/alt.png'),
                                                fit: BoxFit.cover,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  'ข้อความจากทางร้านค้า',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const Text(
                                                  'Top Market - เซ็นทรัลเวสเกต',
                                                  style:
                                                      TextStyle(fontSize: 12),
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      index == 0
                                                          ? 'รับสินค้าแล้ว'
                                                          : 'ยกเลิกสินค้า',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: index == 0
                                                            ? Colors.green
                                                            : Colors.red,
                                                      ),
                                                    ),
                                                    const Text(
                                                      'รายละเอียดสินค้า',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 5),
                                                Text(
                                                  'วันที่ ${index == 0 ? '18' : '22'}/7/2567 เวลา ${index == 0 ? '21:00' : '21:45'} น.',
                                                  style: const TextStyle(
                                                      fontSize: 12),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
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

class DetailPage extends StatelessWidget {
  final int index;

  DetailPage({required this.index});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(index == 0 ? 'รับสินค้าแล้ว' : 'ยกเลิกสินค้า'),
      ),
      body: Center(
        child: Text('รายละเอียดสำหรับการดำเนินการ $index'),
      ),
    );
  }
}

Widget _buildMailBoxDetailPopup(BuildContext context, int index) {
  return Dialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    elevation: 0,
    backgroundColor: Colors.transparent,
    child: contentBox(context, index),
  );
}

Widget contentBox(BuildContext context, int index) {
  return Container(
    height: 600,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.grey[100],
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: const Icon(Icons.close),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'รายละเอียดร้านค้า',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: const [
                Text(
                  'เบอร์ติดต่อ :',
                  style: TextStyle(fontSize: 10),
                ),
                Text(
                  '092-881-8000',
                  style: TextStyle(fontSize: 10),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Divider(
          color: Colors.black,
          thickness: 1,
        ),
        const SizedBox(height: 8),
        Center(
          child: Column(
            children: const [
              Text(
                'วันที่ 18 / 7 / 2567',
                style: TextStyle(fontSize: 12),
              ),
              Text(
                'เวลาที่สั่งสินค้า : 21.00 น.',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView(
            children: [
              _buildProductItem(
                'ข้าวคลุกกะปิ',
                'หมดอายุวันที่ 25 / 7 / 2567',
                'ราคา: 24.00 บาท',
                'จำนวน: 2',
              ),
              _buildProductItem(
                'ข้าวปลาซาบะ',
                'หมดอายุวันที่ 25 / 7 / 2567',
                'ราคา: 14.00 บาท',
                'จำนวน: 1',
              ),
              _buildProductItem(
                'ข้าวไก่ทอด',
                'หมดอายุวันที่ 25 / 7 / 2567',
                'ราคา: 30.00 บาท',
                'จำนวน: 1',
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: Column(
            children: const [
              Text(
                'ค่าจัดส่ง + ค่าดำเนินการ : 141.00 + 33.00 บาท',
                style: TextStyle(fontSize: 12),
              ),
              Text(
                'รวม : 174.00 บาท',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildProductItem(
    String productName, String expiryDate, String price, String quantity) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          productName,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        Text(expiryDate, style: const TextStyle(fontSize: 12)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(price, style: const TextStyle(fontSize: 12)),
            Text(quantity, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ],
    ),
  );
}
