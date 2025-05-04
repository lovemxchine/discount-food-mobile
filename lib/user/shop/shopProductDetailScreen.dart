import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
import 'package:mobile/components/textFieldComponent.dart';

import 'package:shared_preferences/shared_preferences.dart';

class ProductDetailScreen extends StatefulWidget {
  final productData;
  ProductDetailScreen({Key? key, required this.productData}) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final PageController _pageController = PageController();
  final TextEditingController dateController = TextEditingController();
  final bool isLoading = true;
  final MediaType mediaType = MediaType('application', 'json');
  late int currentQuantity;
  List<bool> isSelected = [false, false];
  var pathAPI = "";
  bool showStatus = true;
  Future<String?> getUID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_uid');
  }

  String formatExpiredDate(String dateStr) {
    DateTime dateTime = DateTime.parse(dateStr);
    return DateFormat('dd/MM/yyyy').format(dateTime);
  }

  Future<void> deleteProduct() async {
    await fetchUrl();
    await deleteProd();
  }

  Future<void> updateProduct(bool showStatus) async {
    await fetchUrl();
    await updateProd(showStatus);
  }

  Future<void> fetchUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      pathAPI = prefs.getString('apiUrl') ?? 'http://10.0.2.2:3000';
    });
    print(pathAPI);
  }

  Future<void> deleteProd() async {
    String? uid = await getUID();
    String prodID = widget.productData['productId'];
    final url = Uri.parse("$pathAPI/shop/$uid/product/$prodID");
    var response = await http.delete(url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({"imageUrl": widget.productData['imageUrl']}));
    final responseData = jsonDecode(response.body);
    print(responseData);
  }

  Future<void> updateProd(bool status) async {
    try {
      bool updateStatus = status;
      String? uid = await getUID();
      String prodID = widget.productData['productId'];
      print(uid);
      print(prodID);

      final url = Uri.parse("$pathAPI/shop/$uid/product/$prodID");
      var response = await http.patch(url,
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode({
            "expired_date": dateController.text,
            "updateStock": currentQuantity,
            "showStatus": updateStatus,
            "allow": true
          }));
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Product updated successfully')),
        );
        // wait 3 sec and navigate to shop screen
        // await Future.delayed(Duration(seconds: 1));
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
    dateController.text = formatExpiredDate(widget.productData['expiredDate']);
    showStatus = widget.productData['showStatus'];
    isSelected = [showStatus, !showStatus];
    print(widget.productData);
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
          actions: [
            ElevatedButton.icon(
              onPressed:
                  // () {
                  //   deleteProd(); // Navigate back to the previous screen
                  // },
                  () => showDialog<String>(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  title: const Text('ยืนยันการลบสินค้า'),
                  content: const Text('ยืนยันการลบสินค้านี้ใช่หรือไม่ ?'),
                  actions: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'ยกเลิก',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        TextButton(
                          onPressed: () => {
                            deleteProduct(),
                            Navigator.pushNamed(context, '/shop')
                          },
                          child: const Text('ยืนยัน',
                              style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              icon: const Icon(Icons.delete, color: Colors.red),
              label: const Text(
                'ลบสินค้า',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.red,
                backgroundColor: Colors.white, // Text and icon color
                side: BorderSide(
                  color: Colors.red,
                ), // Border color
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(20), // Adjust the radius as needed
                ), // BorderRadius
              ),
            ),
            SizedBox(
              width: 20,
            )
          ],
        ),
        body: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  width: double.infinity,
                  height: 600,
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Spacer(),
                            Text(
                              widget.productData['productName'],
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Spacer(),
                            ToggleButtons(
                              isSelected: isSelected,
                              onPressed: (int index) {
                                setState(() {
                                  for (int i = 0; i < isSelected.length; i++) {
                                    isSelected[i] = i == index;
                                  }
                                  showStatus = index ==
                                      0; // Update showStatus based on the selected index
                                  print(
                                      "showStatus updated to: $showStatus"); // D
                                });
                              },
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(6.0),
                                  child: Text('กำลังขาย',
                                      style: TextStyle(color: Colors.green)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(6.0),
                                  child: Text('ไม่ได้ขาย',
                                      style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                            Spacer(),
                          ],
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
                        Container(
                          width: 290,
                          child: customDateField(
                              dateController, context, 'วันหมดอายุ', 22),
                        ),
                        SizedBox(height: 30),
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
                        SizedBox(height: 30),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                )),
                            onPressed: () {
                              updateProduct(showStatus);
                            },
                            child: Container(
                                child: Text(
                              'อัพเดตข้อมูลสินค้า',
                              style: TextStyle(color: Colors.white),
                            ))),
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
