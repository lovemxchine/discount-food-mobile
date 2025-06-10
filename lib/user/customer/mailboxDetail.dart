import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/components/bottomNav.dart';
import 'package:mobile/user/customer/allshopNear.dart';
import 'package:mobile/user/customer/homePage.dart';
import 'package:mobile/user/customer/mailBox.dart';
import 'package:mobile/user/customer/favoritePage.dart';
import 'package:mobile/user/customer/settingsPage.dart';

class MailBoxDetailPage extends StatefulWidget {
  @override
  State<MailBoxDetailPage> createState() => _MailBoxDetailPageState();
}

class _MailBoxDetailPageState extends State<MailBoxDetailPage> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => true,
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
                  // Profile Info Section
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
                              image: AssetImage('assets/your_image.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'ชาญณรงค์ ชาญเฌอ',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white),
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
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(16),
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
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => MailBoxPage()),
                                    );
                                  },
                                  child: const Icon(Icons.close),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      'รายละเอียดร้านค้า',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: const [
                                      Text(
                                        'เบอร์ติดต่อ :',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                      Text(
                                        '092-881-8000',
                                        style: TextStyle(fontSize: 14),
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
                                      style: TextStyle(fontSize: 14),
                                    ),
                                    Text(
                                      'เวลาที่สั่งสินค้า : 21.00 น.',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
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
                                      style: TextStyle(fontSize: 14),
                                    ),
                                    Text(
                                      'รวม : 174.00 บาท',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
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

  Widget _buildProductItem(
      String productName, String expiryDate, String price, String quantity) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            productName,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(expiryDate, style: const TextStyle(fontSize: 14)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(price, style: const TextStyle(fontSize: 14)),
              Text(quantity, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }
}
