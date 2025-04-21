import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import 'package:mobile/user/page/shopDetails.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

String formatExpiredDate(String dateStr) {
  DateTime dateTime = DateTime.parse(dateStr);
  return DateFormat('dd/MM/yyyy').format(dateTime);
}

class GuestProductInShop extends StatefulWidget {
  GuestProductInShop({super.key, required this.shopData});
  Map<String, dynamic> shopData;
  @override
  State<GuestProductInShop> createState() => _GuestProductInShopState();
}

class _GuestProductInShopState extends State<GuestProductInShop> {
  int cartCount = 12;
  bool _isLoading = false;
  List listProducts = [];
  var pathAPI = '';

  Future<void> fetchUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      pathAPI = prefs.getString('apiUrl') ?? 'http://10.0.2.2:3000';
    });
    print(pathAPI);
  }

  Future<void> initFetch() async {
    await fetchUrl();
    await fetchProduct();
  }

  @override
  initState() {
    super.initState();
    initFetch();

  }

  Future<void> fetchProduct() async {
    // Uri url = "http://52.65.210.113:3000/" as Uri;
    print(widget.shopData['shopkeeperUid']);
    final url = Uri.parse(
        "http://$pathAPI/shop/${widget.shopData['shopkeeperUid']}/getAllProduct");
    var response = await http.get(
      url,
    );
    final responseData = jsonDecode(response.body);
    setState(() {
      listProducts = responseData['data'];
    });

    // List arrData = decodedData['data'];
    print(listProducts.length);
    print(listProducts);
    print("hi");
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Column(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    width: double.infinity,
                    height: 200,
                    child: Image.asset(
                      'assets/images/alt.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 224, 217, 217),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12.0),
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage(
                                          'assets/images/alt.png'), // ใช้ AssetImage
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.shopData['name'],
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'ระยะเวลาเปิด - ปิด (${widget.shopData['openAt']} - ${widget.shopData['closeAt']})',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  SizedBox(height: 20),
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ShopDetails(
                                            shopData: widget.shopData,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      'รายละเอียดร้านค้า',
                                      style: TextStyle(
                                        color: const Color.fromARGB(
                                            255, 95, 95, 95),
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: GridView.builder(
                            padding: EdgeInsets.all(16),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 3 / 4,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: listProducts.length,
                            itemBuilder: (context, index) {
                              return ProductCard(
                                productName: listProducts[index]['productName'],
                                expirationDate: listProducts[index]
                                    ['expiredDate'],
                                oldPrice: listProducts[index]['originalPrice'],
                                newPrice: listProducts[index]['salePrice'],
                                imageAsset: listProducts[index]['imageUrl'],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 40,
              left: 12,
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Icon(Icons.arrow_back),
                backgroundColor: Colors.transparent,
                // foregroundColor: Colors.black,
                elevation: 0,
                mini: true, // Makes the button smaller
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final String productName;
  final String expirationDate;
  final int oldPrice;
  final int newPrice;
  final String imageAsset;

  ProductCard({
    Key? key,
    required this.productName,
    required this.expirationDate,
    required this.oldPrice,
    required this.newPrice,
    this.imageAsset = 'assets/images/alt.png',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
                child: Image.network(
                  imageAsset,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                // SizedBox(height: 4),
                // Text(
                //   'หมดอายุวันที่ ${formatExpiredDate(expirationDate)}',
                //   style: TextStyle(fontSize: 12, color: Colors.grey),
                // ),
                SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ราคาเดิม ${oldPrice} บาท',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'เหลือ ${newPrice} บาท',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Center(
                  child: Text(
                    'รายละเอียดสินค้า',
                    style: TextStyle(
                      color: const Color.fromARGB(255, 57, 57, 57),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
