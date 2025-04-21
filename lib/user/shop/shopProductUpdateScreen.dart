import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';

import 'package:shared_preferences/shared_preferences.dart';

class ProductUpdateScreen extends StatefulWidget {
  final productData;

  ProductUpdateScreen({Key? key, required this.productData}) : super(key: key);

  @override
  State<ProductUpdateScreen> createState() => _ProductUpdateScreenState();
}

class _ProductUpdateScreenState extends State<ProductUpdateScreen> {
  final PageController _pageController = PageController();
  final bool isLoading = true;
  final MediaType mediaType = MediaType('application', 'json');
  late int currentQuantity;
  var pathAPI = "";

  Future<String?> getUID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_uid');
  }

  Future<void> updateProduct() async {
    await fetchUrl();
    await updateProd();
  }

  Future<void> fetchUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      pathAPI = prefs.getString('apiUrl') ?? 'http://10.0.2.2:3000';
    });
    print(pathAPI);
  }

  String formatExpiredDate(String dateStr) {
    DateTime dateTime = DateTime.parse(dateStr);
    return DateFormat('dd-MM-yyyy').format(dateTime);
  }

  Future<void> updateProd() async {
    try {
      String? uid = await getUID();
      String prodID = widget.productData['productId'];
      print(uid);
      print(prodID);

      final url = Uri.parse("http://$pathAPI/shop/$uid/product/$prodID");
      var response = await http.patch(url,
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode({"updateStock": currentQuantity, "allow": false}));
      print(currentQuantity);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('อัพเดตสต็อกสินค้าสำเร็จ')),
        );
        Navigator.pushNamed(context, '/shop');
      } else {
        throw Exception('Failed to update product');
      }
    } catch (e) {
      print(e);
      print("error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating product: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      currentQuantity = widget.productData['stock'];
    });
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
                child: Container(
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
                        Container(
                          width: double.infinity,
                          height: 250,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image:
                                  Image.network(widget.productData['imageUrl'])
                                      .image,
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        SizedBox(height: 15),
                        Text(
                          widget.productData['productName'],
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 15),
                        Row(
                          children: [
                            Spacer(),
                            Text(
                              'ลดเหลือ : ${widget.productData['salePrice']} บาท',
                              style: TextStyle(
                                //bold
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                            Spacer(),
                            Text(
                              'ราคาเดิม : ${widget.productData['originalPrice']} บาท',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            Spacer(),
                          ],
                        ),
                        SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Spacer(),
                            Text(
                              'วันที่หมดอายุ : ${formatExpiredDate(widget.productData['expiredDate'])} ', //${formatDiscountDate(productData['expiredDate'])}
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(width: 85),
                            Spacer(),
                          ],
                        ),
                        SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 39,
                              width: 39,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (currentQuantity > 0) {
                                    setState(() {
                                      currentQuantity--;
                                    });
                                  }
                                  print("Button tapped!");
                                },
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        5), // Rounded corners
                                  ),
                                  backgroundColor:
                                      Colors.red, // Background color
                                  padding: EdgeInsets.all(8),
                                ),
                                child: Icon(Icons.remove, color: Colors.white),
                              ),
                            ),
                            SizedBox(width: 20),
                            Container(
                              padding: EdgeInsets.all(8),
                              child: Text(
                                'จำนวน :  ${currentQuantity} ชิ้น',
                                style: TextStyle(fontSize: 16),
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                  color: Colors.grey,
                                  width: 1,
                                ),
                              ),
                            ),
                            SizedBox(width: 20),
                            Container(
                              height: 39,
                              width: 39,
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    currentQuantity++;
                                  });
                                  print("Button tapped!");
                                },
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        5), // Rounded corners
                                  ),
                                  backgroundColor:
                                      Colors.green, // Background color
                                  padding: EdgeInsets.all(8),
                                ),
                                child: Icon(Icons.add, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 15),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                )),
                            onPressed: () {
                              updateProduct();
                            },
                            child: Center(
                              child: Container(
                                  child: Text(
                                'อัพเดตข้อมูลสินค้า',
                                style: TextStyle(color: Colors.white),
                              )),
                            )),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
