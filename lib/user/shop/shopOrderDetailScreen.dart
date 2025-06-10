import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
import 'package:mobile/utils/func/fetchData.dart';

import 'package:shared_preferences/shared_preferences.dart';

class OrderDetailScreen extends StatefulWidget {
  final orderData;

  OrderDetailScreen({Key? key, required this.orderData}) : super(key: key);

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final bool isLoading = true;
  late int currentQuantity;
  var pathAPI = "";
  var userProfile = {};

  Future<String?> getUID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_uid');
  }

  String formatExpiredDate(String dateStr) {
    DateTime dateTime = DateTime.parse(dateStr);
    return DateFormat('dd-MM-yyyy').format(dateTime);
  }

  Future<void> initFetch() async {
    await fetchUrl();
    await fetchShopProfile();
  }

  String formatOrderDate(String dateStr) {
    DateTime dateTime = DateTime.parse(dateStr);
    return DateFormat('วันที่ dd/MM/yyyy เวลา HH:mm น.').format(dateTime);
  }

  Future<void> fetchUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      pathAPI = prefs.getString('apiUrl') ?? 'http://10.0.2.2:3000';
    });
    print(pathAPI);
  }

  Future<void> fetchShopProfile() async {
    await getData(pathAPI +
            '/customer/profileDetail?uid=${widget.orderData['customerUid']}')
        .then((response) {
      if (response != null) {
        setState(() {
          userProfile = response['data'];
        });
        print(userProfile);
        print(widget.orderData);
      } else {
        print('Error fetching shop profile');
      }
    }).catchError((error) {
      print('Error: $error');
    });
  }

  Future<void> updateOrderProfile(String status) async {
    try {
      String? uid = await getUID();
      String orderId = widget.orderData['orderId'];

      final url = Uri.parse("$pathAPI/shop/updateOrderStatus");
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        // body: json.encode({'shopUid': shopUID, 'uid': uid}),
        body: json.encode({
          "customerUid": userProfile['uid'] ?? '',
          "shopUid": uid ?? '',
          "orderId": orderId,
          "status": status
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('อัพเดตสถานะคำสั่งซื้อสำเร็จ')),
        );
        Navigator.pushNamed(context, '/shop');
      } else {
        throw Exception('Failed to update order status');
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating order status: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    initFetch();
    // currentQuantity = widget.productData['stock'];
    // print(currentQuantity);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: const Color.fromARGB(255, 224, 217, 217),
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 224, 217, 217),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.pop(context); // Navigate back to the previous screen
            },
          ),
        ),
        body: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Container(
                      clipBehavior: Clip.hardEdge,
                      width: double.infinity,
                      height: 540,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.grey,
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            const SizedBox(height: 15),
                            const Text(
                              'รายละเอียดการสั่งซื้อ',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("ชื่อผู้สั่ง: ",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    )),
                                Text(
                                    "${userProfile['fname'] ?? ''} ${userProfile['lname'] ?? ''}",
                                    style: const TextStyle(
                                      fontSize: 14,
                                    )),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("เบอร์ติดต่อ: ",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    )),
                                Text("${userProfile['tel'] ?? ''}",
                                    style: const TextStyle(
                                      fontSize: 14,
                                    )),
                              ],
                            ),
                            const Divider(
                              color: Colors.grey,
                              thickness: 1,
                            ),
                            const SizedBox(height: 10),
                            Text(formatOrderDate(
                                widget.orderData['orderAt'] ?? '')),
                            const SizedBox(height: 10),
                            Container(
                              height: 300,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: Column(
                                  children: [
                                    DataTable(
                                      columnSpacing: 20,
                                      columns: [
                                        DataColumn(
                                            label: Container(
                                                width: 100,
                                                child: Text('ชื่อสินค้า'))),
                                        DataColumn(label: Text('จำนวน')),
                                        DataColumn(label: Text('ราคา')),
                                        DataColumn(label: Text('รวม')),
                                      ],
                                      rows: [
                                        ...widget.orderData['list'],
                                      ].map<DataRow>((item) {
                                        return DataRow(cells: [
                                          DataCell(Text(item['foodName'])),
                                          DataCell(
                                              Text(item['amount'].toString())),
                                          DataCell(
                                              Text(item['price'].toString())),
                                          DataCell(Text(
                                              (item['price'] * item['amount'])
                                                  .toString())),
                                        ]);
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                                "ราคารวมทั้งหมด: ${widget.orderData['totalPrice'] ?? ""} บาท"),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (widget.orderData['status'] == 'Pending Order')
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              )),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return Dialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Container(
                                    width: 500,
                                    height: 600,
                                    child: Column(
                                      children: [
                                        const SizedBox(height: 20),
                                        const Text(
                                          'หลักฐานการชำระเงิน',
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 20),
                                        Container(
                                          width: 300,
                                          height: 300,
                                          child: Image.network(
                                            widget.orderData['receiptUrl'] ??
                                                'https://via.placeholder.com/150',
                                            fit: BoxFit.cover,
                                            width: 300,
                                            height: 300,
                                            loadingBuilder:
                                                (BuildContext context,
                                                    Widget child,
                                                    ImageChunkEvent?
                                                        loadingProgress) {
                                              if (loadingProgress == null)
                                                return child;
                                              return Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  value: loadingProgress
                                                              .expectedTotalBytes !=
                                                          null
                                                      ? loadingProgress
                                                              .cumulativeBytesLoaded /
                                                          (loadingProgress
                                                                  .expectedTotalBytes ??
                                                              1)
                                                      : null,
                                                ),
                                              );
                                            },
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    Center(
                                              child: Icon(Icons.broken_image,
                                                  size: 80, color: Colors.grey),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 40),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          // crossAxisAlignment:/
                                          // CrossAxisAlignment.center,
                                          children: [
                                            Spacer(),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.green,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                              onPressed: () {
                                                // Navigator.pop(context);
                                                updateOrderProfile('Success');
                                                Navigator.pop(context);
                                              },
                                              child: const Text(
                                                'ยืนยัน',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                            const SizedBox(width: 20),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                              onPressed: () {
                                                updateOrderProfile('Rejected');
                                                Navigator.pop(context);
                                              },
                                              child: const Text(
                                                'ปฎิเสธ',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                            Spacer(),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          child: Container(
                              child: const Text(
                            'หลักฐานการชำระเงิน',
                            style: TextStyle(color: Colors.white),
                          ))),
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
