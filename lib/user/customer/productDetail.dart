import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/provider/cart_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

String formatExpiredDate(String dateStr) {
  DateTime dateTime = DateTime.parse(dateStr);
  return DateFormat('dd/MM/yyyy').format(dateTime);
}

class ProductDetail extends StatefulWidget {
  final Map<String, dynamic> shopData;

  ProductDetail({super.key, required this.shopData});

  @override
  State<ProductDetail> createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  int quantity = 0;
  bool _isLoading = false;
  List listProducts = [];
  var pathAPI = '';
  @override
  void initState() {
    super.initState();
    initFetch();
    print(widget.shopData);
  }

  Future<void> initFetch() async {
    await fetchUrl();
    // await fetchProduct();
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
    setState(() {
      listProducts = responseData['data'];
    });

    print(listProducts.length);
    print(listProducts);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[400],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Align(
          alignment: Alignment.topLeft,
          child: IconButton(
            icon: Icon(Icons.close, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                widget.shopData['imageUrl'],
                                width: double.infinity,
                                height: 300,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                    "ชื่อสินค้า: ${widget.shopData['productName']}",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    )),
                                // widget.shopData['productName'],
                                // style: TextStyle(
                                //   fontSize: 18,
                                //   fontWeight: FontWeight.bold,
                                // ),
                                // ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Text(
                              'จำนวนคงเหลือ ${widget.shopData['stock']}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                            SizedBox(height: 12),
                            Row(
                              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'ลดเหลือ : ${widget.shopData['salePrice']} บาท',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'ราคาเดิม: ${widget.shopData['originalPrice']} บาท',
                                  style: TextStyle(
                                    fontSize: 14,
                                    decoration: TextDecoration.lineThrough,
                                    decorationColor: Colors.red,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              'หมดอายุวันที่ ${formatExpiredDate(widget.shopData['expiredDate'])}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
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
          ),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: () {
                    setState(() {
                      final cart =
                          Provider.of<CartModel>(context, listen: false);
                      final simplified = cart.items
                          .map((item) => {
                                "productName": item["productName"],
                                "salePrice": item["salePrice"],
                                "quantity": item["quantity"],
                                "productId": item["productId"],
                              })
                          .toList();

                      print(simplified);
                      print(cart.count);
                      if (quantity > 0) quantity--;
                    });
                  },
                ),
                Text(
                  '$quantity',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    final cart = Provider.of<CartModel>(context, listen: false)
                        .items
                        .where((item) =>
                            item["productId"] == widget.shopData["productId"])
                        .toList();
                    // print(widget.shopData['stock'] - cart[0]['quantity']);
                    print(quantity);
                    setState(() {
                      // print(cart);
                      int cartQuantity =
                          cart.isNotEmpty && cart[0]['quantity'] != null
                              ? cart[0]['quantity'] as int
                              : 0;
                      if (quantity <
                          (widget.shopData['stock'] - cartQuantity)) {
                        quantity++;
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text('ไม่สามารถเพิ่มได้เกินจำนวนคงเหลือ')),
                        );
                      }
                    });
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    // ฟังก์ชันเมื่อกดปุ่มเพิ่มลงตะกร้าสินค้า
                    print(widget.shopData);
                    if (quantity <= 0) {
                      return;
                    }
                    // Provider.of<CartModel>(context, listen: false).clear();

                    Provider.of<CartModel>(context, listen: false).add(
                      widget.shopData,
                      quantity,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('เพิ่ม $quantity ชิ้นลงตะกร้า')),
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: quantity <= 0 ? Colors.grey : Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    quantity <= 0 ? "ไม่สามารถเพิ่มได้" : 'เพิ่มลงตะกร้าสินค้า',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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
