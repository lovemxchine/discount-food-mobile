import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:mobile/user/customer/cartList.dart';
import 'package:mobile/user/customer/productDetail.dart';
import 'package:mobile/user/customer/shopDetail.dart';

String formatExpiredDate(String dateStr) {
  DateTime dateTime = DateTime.parse(dateStr);
  return DateFormat('dd/MM/yyyy').format(dateTime);
}

class ProductInShop extends StatefulWidget {
  ProductInShop({super.key, required this.shopData});
  Map<String, dynamic> shopData;
  @override
  State<ProductInShop> createState() => _ProductInShopState();
}

class _ProductInShopState extends State<ProductInShop> {
  int cartCount = 12;
  bool _isLoading = false;
  List listProducts = [];

  @override
  initState() {
    super.initState();
    _fetchData();
    fetchProduct();
  }

  Future<void> _fetchData() async {
    print(widget.shopData);
  }

  Future<void> fetchProduct() async {
    final url = Uri.parse(
        "http://10.0.2.2:3000/shop/${widget.shopData['shopkeeperUid']}/getAllProduct");
    var response = await http.get(url);
    final responseData = jsonDecode(response.body);
    setState(() {
      listProducts = responseData['data'];
    });

    print(listProducts.length);
    print(listProducts);
    print("hi");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                                    image: AssetImage('assets/images/alt.png'),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
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
                                          builder: (context) => Shopdetail(
                                            shopData: widget.shopData,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      'รายละเอียดร้านค้า',
                                      style: TextStyle(
                                        color: Color.fromARGB(255, 95, 95, 95),
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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
                            final item = listProducts[
                                index]; 
                            return ProductCard(
                              productName: item['productName'],
                              expirationDate: item['expiredDate'],
                              oldPrice: item['originalPrice'],
                              newPrice: item['salePrice'],
                              imageAsset: item['imageUrl'],
                              productData:
                                  item, 
                            );
                          },
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(16),
                        color: Colors.white,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Cartlist()),
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$cartCount ตะกร้าสินค้า',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.shopping_cart, color: Colors.white),
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
          Positioned(
            top: 40,
            left: 12,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Icon(
                Icons.arrow_back_ios_new_outlined,
                color: Colors.black,
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              mini: true,
            ),
          ),
        ],
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
  final Map<String, dynamic> productData;

  ProductCard({
    Key? key,
    required this.productName,
    required this.expirationDate,
    required this.oldPrice,
    required this.newPrice,
    required this.productData,
    this.imageAsset = 'assets/images/alt.png',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetail(shopData: productData),
          ),
        );
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
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
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset('assets/images/alt.png');
                    },
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
                  SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'ราคาเดิม $oldPrice บาท',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'เหลือ $newPrice บาท',
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
                        color: Color.fromARGB(255, 57, 57, 57),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
