import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mobile/provider/cart_model.dart';
import 'package:mobile/user/customer/payment.dart';
import 'package:provider/provider.dart';

class Cartlist extends StatefulWidget {
  const Cartlist({super.key});

  @override
  State<Cartlist> createState() => _CartlistState();
}

class _CartlistState extends State<Cartlist> {
  int quantity = 1;

  String formatExpiredDate(String dateStr) {
    DateTime dateTime = DateTime.parse(dateStr);
    return DateFormat('dd/MM/yyyy').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartModel>(context, listen: true);
    print(cart.total);
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Align(
          alignment: Alignment.topLeft,
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_outlined, color: Colors.black),
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
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Card(
                      color: Colors.grey[200],
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (var item in cart.items)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 16.0),
                                    child: Text(
                                      item['productName'] ?? 'ชื่อสินค้า',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 16.0, top: 8.0),
                                        child: Text(
                                          "หมดอายุวันที่ ${formatExpiredDate(item['expiredDate'])}",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.normal,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                      ),
                                      Spacer(),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            right: 16.0, top: 8.0),
                                        child: Text(
                                          "จำนวน :",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 16, top: 8.0),
                                        child: Text(
                                          "ราคา : ${item['salePrice']} บาท",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.normal,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                      ),
                                      Spacer(),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 0),
                                        child: IconButton(
                                          icon:
                                              Icon(Icons.remove_circle_outline),
                                          iconSize: 18,
                                          color: Colors.grey[400],
                                          onPressed: () {
                                            setState(() {
                                              setState(() {
                                                Provider.of<CartModel>(context,
                                                        listen: false)
                                                    .decrement(
                                                        item['productId']);
                                              });
                                              if (quantity > 1) quantity--;
                                            });
                                          },
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 4),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.grey,
                                            width: 2,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          color: Colors.white,
                                        ),
                                        child: Text(
                                          "${item['quantity']}",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 0),
                                        child: IconButton(
                                          icon: Icon(Icons.add_circle_outline),
                                          iconSize: 18,
                                          color: Colors.grey[400],
                                          onPressed: () {
                                            var cartModel =
                                                Provider.of<CartModel>(context,
                                                        listen: false)
                                                    .getByProductId(
                                                        item['productId']);
                                            if (cartModel?['stock'] -
                                                    item['quantity'] >
                                                0)
                                              setState(() {
                                                Provider.of<CartModel>(context,
                                                        listen: false)
                                                    .add(
                                                  item,
                                                  quantity,
                                                );
                                              });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            SizedBox(height: 16),
                            Divider(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 16),
                                  child: Text(
                                    "ค่าอาหาร : ${cart.total} บาท",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ),
                                Divider(),
                                SizedBox(height: 4),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 16),
                                      child: Text(
                                        "รายละเอียดเพิ่มเติม",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 16,
                                          ),
                                          child: TextField(
                                            minLines: 3,
                                            maxLines: 5,
                                            decoration: InputDecoration(
                                              filled: true,
                                              fillColor: Colors.white,
                                              hintText: "เช่น แขวนไว้หน้าบ้าน",
                                              hintStyle: const TextStyle(
                                                  color: Colors.grey),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "ราคารวมทั้งหมด",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "${cart.total} บาท",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Payment()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 54, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    "ชำระเงิน",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
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
