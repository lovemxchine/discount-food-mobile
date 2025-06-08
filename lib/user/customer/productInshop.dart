import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:mobile/provider/cart_model.dart';
import 'package:mobile/user/customer/cartList.dart';
import 'package:mobile/user/customer/productDetail.dart';
import 'package:mobile/user/customer/shopDetail.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  bool _isLoading = false;
  List listProducts = [];
  String pathAPI = '';

  @override
  initState() {
    super.initState();
    initFetch();
  }

  Future<void> initFetch() async {
    await fetchUrl();
    await fetchProduct();
  }

  Future<void> fetchUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      pathAPI = prefs.getString('apiUrl') ?? 'http://10.0.2.2:3000';
    });
    print(pathAPI);
  }

  Future<void> fetchProduct() async {
    final url = Uri.parse(
        "$pathAPI/shop/${widget.shopData['uid']}/getAvailableProduct");
    var response = await http.get(url);
    final responseData = jsonDecode(response.body);
    print("test $pathAPI/shop/${widget.shopData['uid']}/getAvailableProduct");
    setState(() {
      listProducts = responseData['data'];
    });

    print(listProducts.length);
    print(listProducts);
    print("hi");
  }

  @override
  Widget build(BuildContext context) {
    final cartCount = Provider.of<CartModel>(context, listen: true).count;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Main content column
          Column(
            children: [
              // Cover image space
              Container(
                width: double.infinity,
                height: 200,
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
                                    image: NetworkImage(
                                        widget.shopData['imgUrl']['shopUrl']),
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
                      if (listProducts.isEmpty)
                        Expanded(
                          child: GridView.builder(
                            padding: EdgeInsets.all(16),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 1,
                                    childAspectRatio: 1,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 12),
                            itemCount: 1,
                            itemBuilder: (context, index) {
                              return Container(
                                alignment: Alignment.center,
                                child: const Text(
                                  'ไม่มีสินค้าที่ลดราคาในขณะนี้',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      if (!listProducts.isEmpty)
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
                              final item = listProducts[index];
                              return ProductCard(
                                productName: item['productName'],
                                expirationDate: item['expiredDate'],
                                oldPrice: item['originalPrice'],
                                newPrice: item['salePrice'],
                                imageAsset: item['imageUrl'],
                                productData: item,
                              );
                            },
                          ),
                        ),
                      if (!listProducts.isEmpty)
                        Container(
                          padding: EdgeInsets.all(16),
                          color: Colors.white,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  cartCount <= 0 ? Colors.grey : Colors.green,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              if (cartCount <= 0) return;
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
                                  cartCount <= 0
                                      ? 'ไม่มีสินค้าในตะกร้า'
                                      : '$cartCount ตะกร้าสินค้า',
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
          // Positioned elements that must be direct children of Stack
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              width: double.infinity,
              height: 200,
              child: Image.network(
                widget.shopData['imgUrl']['shopCoverUrl'],
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset('assets/images/alt.png');
                },
              ),
            ),
          ),

          Positioned(
            top: 40,
            left: 12,
            child: FloatingActionButton(
              onPressed: () {
                Provider.of<CartModel>(context, listen: false).clear();

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
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    },
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
