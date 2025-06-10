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

Future<String> fetchUrl() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('apiUrl') ?? 'http://10.0.2.2:3000';
}

class _MailBoxPageState extends State<MailBoxPage> {
  Map<String, dynamic>? userProfileData;
  bool _isLoading = true;
  // var pathAPI = '';

  Future<String?> getUID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_uid');
  }

  String formatDateTime(String isoString) {
    final dateTime = DateTime.parse(isoString).toLocal();
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year.toString();
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return 'เวลาที่สั่ง: วันที่ $day/$month/$year เวลา $hour.$minute';
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
        if (!mounted) return; // <--- เพิ่มบรรทัดนี้
        setState(() {
          userProfileData = responseData['data'];
          _isLoading = false;
        });
      } else {
        if (!mounted) return; // <--- เพิ่มบรรทัดนี้
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  List<dynamic> orderList = [];
  List<dynamic> originalOrderList = [];
  String orderStatus = '';

  Future<void> fetchOrders() async {
    String? uid = await getUID();
    var pathAPI = await fetchUrl();

    if (uid == null) return;

    final url = Uri.parse("$pathAPI/customer/fetchOrder?uid=$uid");
    print("$pathAPI/customer/fetchOrder?uid=$uid");

    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (!mounted) return; // <--- เพิ่มบรรทัดนี้

        setState(() {
          originalOrderList = responseData['data'] ?? [];
          orderList = responseData['data'] ?? [];
        });
      } else {
        // Handle error
      }
    } catch (e) {
      print('Error fetching orders: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchProfile();
    fetchOrders();
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
                        child: PopupMenuButton<String>(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                orderStatus == ''
                                    ? 'เลือกสถานะออเดอร์'
                                    : orderStatus == 'All'
                                        ? 'ทั้งหมด'
                                        : orderStatus == 'Success'
                                            ? 'ยืนยันการจ่ายเงิน'
                                            : orderStatus == 'Pending Order'
                                                ? 'รอการยืนยัน'
                                                : 'คำสั่งซื้อที่ถูกยกเลิก',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                              // Icon(Icons.more_vert, color: Colors.black),
                            ],
                          ),
                          onSelected: (value) {
                            setState(() {
                              if (value == 'Success') {
                                orderList = originalOrderList
                                    .where(
                                        (order) => order['status'] == 'Success')
                                    .toList();
                                orderStatus = 'Success';
                              } else if (value == 'Pending Order') {
                                orderList = originalOrderList
                                    .where((order) =>
                                        order['status'] == 'Pending Order')
                                    .toList();
                                orderStatus = 'Pending Order';
                                // ติดต่อร้านค้า
                              } else if (value == 'Rejected') {
                                orderList = originalOrderList
                                    .where((order) =>
                                        order['status'] == 'Rejected')
                                    .toList();
                                orderStatus = 'Rejected';
                                // ยกเลิกออเดอร์
                              } else if (value == "All") {
                                orderList = originalOrderList;
                                orderStatus = 'All';
                              }
                            });
                          },
                          itemBuilder: (BuildContext context) => [
                            const PopupMenuItem(
                              value: 'All',
                              child: Text('ทั้งหมด'),
                            ),
                            const PopupMenuItem(
                              value: 'Success',
                              child: Text('ยืนยันการจ่ายเงิน'),
                            ),
                            const PopupMenuItem(
                              value: 'Pending Order',
                              child: Text('รอการยืนยัน'),
                            ),
                            const PopupMenuItem(
                              value: 'Rejected',
                              child: Text('คำสั่งซื้อที่ถูกยกเลิก'),
                            ),
                          ],
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
                          itemCount: orderList.length,
                          itemBuilder: (context, index) {
                            print("orderList:${index} ${orderList[index]}");
                            return Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: index == 0 ? 16 : 8, bottom: 8),
                                  child: InkWell(
                                    onTap: () async {
                                      // TODO: send data
                                      final orderData;
                                      var pathAPI = await fetchUrl();

                                      final url = Uri.parse(
                                          "$pathAPI/customer/fetchOrderDetail?orderId=${orderList[index]['orderId']}&shopUid=${orderList[index]['shopUid']}");

                                      try {
                                        var response = await http.get(url);
                                        final Map<String, dynamic>
                                            responseData =
                                            json.decode(response.body);

                                        if (response.statusCode == 200) {
                                          if (!mounted)
                                            return; // <--- เพิ่มบรรทัดนี้
                                          orderData = responseData['data'];
                                          print("ORDER DATA $orderData");
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return _buildMailBoxDetailPopup(
                                                  context, index, orderData);
                                            },
                                          );
                                        } else {
                                          orderData = null;
                                        }
                                      } catch (e) {
                                        print('Error: $e');
                                      }
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
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            children: [
                                              const SizedBox(width: 16),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          'ออเดอร์ที่สั่งซื้อ',
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        Text(
                                                          'รายละเอียดสินค้า >',
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Text(
                                                      orderList[index]
                                                              ['shopName'] ??
                                                          'ร้านค้าไม่ระบุชื่อ',
                                                      style: TextStyle(
                                                          fontSize: 12),
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          orderList[index][
                                                                      'status'] ==
                                                                  'Success'
                                                              ? 'ยืนยันการจ่ายเงิน'
                                                              : orderList[index]
                                                                          [
                                                                          'status'] ==
                                                                      'Pending Order'
                                                                  ? "รอการยืนยัน"
                                                                  : "ยกเลิกการสั่งซื้อ",
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: orderList[
                                                                            index]
                                                                        [
                                                                        'status'] ==
                                                                    'Success'
                                                                ? Colors.green
                                                                : orderList[index]
                                                                            [
                                                                            'status'] ==
                                                                        'Pending Order'
                                                                    ? Colors
                                                                        .amber
                                                                    : Colors
                                                                        .red,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 5),
                                                    Text(
                                                      formatDateTime(
                                                          orderList[index]
                                                              ['orderAt']),
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
                                ),
                                if (index == orderList.length - 1)
                                  const SizedBox(height: 100),
                              ],
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

Widget _buildMailBoxDetailPopup(
    BuildContext context, int index, final orderData) {
  return Dialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    elevation: 0,
    backgroundColor: Colors.transparent,
    child: contentBox(context, index, orderData),
  );
}

Widget contentBox(BuildContext context, int index, final orderData) {
  String formatDateTime(String isoString) {
    final dateTime = DateTime.parse(isoString).toLocal();
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year.toString();
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return 'สั่งสินค้าเวลา: $day/$month/$year เวลา $hour.$minute';
  }

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
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Text(
              'เบอร์ติดต่อ : ',
              style: TextStyle(fontSize: 12),
            ),
            Text(
              orderData['tel'] ?? "",
              style: TextStyle(fontSize: 12),
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
            children: [
              Text(
                formatDateTime(orderData['orderAt']),
                style: TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 5),
              Text(
                'สถานะ: ${orderData['status'] == 'Success' ? 'ยืนยันการจ่ายเงิน' : orderData['status'] == 'Pending Order' ? 'รอการยืนยัน' : 'ยกเลิกการสั่งซื้อ'}',
                style: TextStyle(
                  fontSize: 12,
                  color: orderData['status'] == 'Success'
                      ? Colors.green
                      : orderData['status'] == 'Pending Order'
                          ? Colors.amber
                          : Colors.red,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 5),
        Expanded(
          child: ListView(
            children: [
              for (int i = 0; i < orderData['list'].length; i++)
                _buildProductItem(
                  orderData['list'][i]['foodName'] ?? 'ไม่ระบุชื่อสินค้า',
                  '${orderData['list'][i]['expiryDate'] != null ? formatDateTime(DateTime.fromMillisecondsSinceEpoch(orderData['list'][i]['expiryDate']['_seconds'] * 1000).toUtc().toIso8601String()) : ""}',
                  'ราคา: ${orderData['list'][i]['price']} บาท',
                  'จำนวน: ${orderData['list'][i]['amount']}',
                ),
              // _buildProductItem(
              //   'ข้าวคลุกกะปิ',
              //   'หมดอายุวันที่ 25 / 7 / 2567',
              //   'ราคา: 24.00 บาท',
              //   'จำนวน: 2',
              // ),
              // _buildProductItem(
              //   'ข้าวปลาซาบะ',
              //   'หมดอายุวันที่ 25 / 7 / 2567',
              //   'ราคา: 14.00 บาท',
              //   'จำนวน: 1',
              // ),
              // _buildProductItem(
              //   'ข้าวไก่ทอด',
              //   'หมดอายุวันที่ 25 / 7 / 2567',
              //   'ราคา: 30.00 บาท',
              //   'จำนวน: 1',
              // ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: Column(
            children: const [
              Text(
                'ราคา รวม : 174.00 บาท',
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
