import 'package:flutter/material.dart';
import 'package:mobile/user/customer/allshopNear.dart';
import 'package:mobile/user/customer/homePage.dart';
import 'package:mobile/user/customer/mailBox.dart';
import 'package:mobile/user/customer/favoritePage.dart';
import 'package:mobile/user/customer/settingsPage.dart';
import 'package:mobile/user/customer/mailboxDetail.dart';

class BottomNavCustomer extends StatefulWidget {
  @override
  _BottomNavCustomerState createState() => _BottomNavCustomerState();
}

class _BottomNavCustomerState extends State<BottomNavCustomer> {
  int _currentIndex = 2;

  final List<Widget> _pages = [
    AllShopNearby(),
    FavoritePage(),
    Homepage(),
    MailBoxPage(),
    SettingsUserPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Stack(
          children: [
            // Content
            _pages[_currentIndex],

            // Bottom Navigation Bar
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
                          icon: Icon(Icons.store), label: 'ร้านค้าใกล้เคียง'),
                      BottomNavigationBarItem(
                          icon: Icon(Icons.favorite), label: 'ร้านค้าโปรด'),
                      BottomNavigationBarItem(
                          icon: Icon(Icons.home), label: 'หน้าหลัก'),
                      BottomNavigationBarItem(
                          icon: Icon(Icons.mail), label: 'ข้อความ'),
                      BottomNavigationBarItem(
                          icon: Icon(Icons.settings), label: 'การตั้งค่า'),
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
