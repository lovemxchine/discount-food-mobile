import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile/user/customer/allshopNear.dart';
import 'package:mobile/user/shop/profile.dart';

import 'package:mobile/user/shop/shopDiscountProductScreen.dart';
import 'package:mobile/user/shop/shopMainScreen.dart';
import 'package:mobile/user/customer/mailboxDetail.dart';
import 'package:mobile/user/shop/shopOrderList.dart';

class BottomNavShop extends StatefulWidget {
  @override
  _BottomNavShopState createState() => _BottomNavShopState();
}

class _BottomNavShopState extends State<BottomNavShop> {
  int _currentIndex = 2;

  final List<Widget> _pages = [
    DiscountProductScreen(),
    OrderListScreen(),
    ShopMainScreen(),
    Placeholder(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Stack(
          children: [
            _pages[_currentIndex],
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  child: BottomNavigationBar(
                    // backgroundColor: Colors.transparent,
                    elevation: 0,
                    currentIndex: _currentIndex,
                    onTap: (index) {
                      // if (index == 4) {
                      //   Navigator.pushNamed(context, '/signIn');
                      // }
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    type: BottomNavigationBarType.fixed,
                    items: const [
                      BottomNavigationBarItem(
                          icon: Icon(Icons.store), label: 'สินค้าลดราคา'),
                      BottomNavigationBarItem(
                          icon: Icon(Icons.favorite), label: 'รายการสั่ง'),
                      BottomNavigationBarItem(
                          icon: Icon(Icons.home), label: 'หน้าหลัก'),
                      BottomNavigationBarItem(
                          icon: Icon(Icons.mail), label: 'ดำเนินการ'),
                      BottomNavigationBarItem(
                          icon: Icon(Icons.settings), label: 'ตั้งค่า'),
                    ],
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
