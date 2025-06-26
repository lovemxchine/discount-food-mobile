import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/components/bottomNav.dart';
import 'package:mobile/components/bottomNavShop.dart';
import 'package:mobile/firebase_options.dart';
import 'package:mobile/provider/cart_model.dart';
import 'package:mobile/user/customer/cartList.dart';
import 'package:mobile/user/customer/historyPage.dart';
import 'package:mobile/user/customer/homePage.dart';
import 'package:mobile/user/customer/mailboxDetail.dart';
import 'package:mobile/user/customer/payment.dart';
import 'package:mobile/user/customer/productDetail.dart';
import 'package:mobile/user/customer/productInshop.dart';
import 'package:mobile/user/customer/reportShop.dart';
import 'package:mobile/user/customer/settingsPage.dart';
import 'package:mobile/user/customer/shopDetail.dart';
import 'package:mobile/user/customer/submitPayment.dart';
import 'package:mobile/user/page/guest.dart';
import 'package:mobile/user/page/guestProduct.dart';
import 'package:mobile/user/page/registerCustomer.dart';
import 'package:mobile/user/page/registerShopkeeper.dart';
import 'package:mobile/user/page/selectMap.dart';
import 'package:mobile/user/page/signIn.dart';
import 'package:mobile/user/page/registerRole.dart';
import 'package:mobile/user/shop/profileDetailScreen.dart';
import 'package:mobile/user/shop/shopAddProductScreen.dart';
import 'package:mobile/user/shop/shopMainScreen.dart';
import 'package:mobile/user/shop/shopManageProductScreen.dart';
import 'package:mobile/user/shop/shopProductDetailScreen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'user/customer/googleMapPoc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SharedPreferences prefs = await SharedPreferences.getInstance();
  runApp(ChangeNotifierProvider(
    create: (_) => CartModel(),
    child: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _setApiUrl();
  }

  Future<void> _setApiUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('apiUrl',
        // 'http://10.0.2.2:3000'); //TODO: dont forget to change to https://discount-food-api.onrender.com
    'https://discount-food-api.onrender.com'); //TODO: dont forget to change to https://discount-food-api.onrender.com
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: GoogleFonts.mitr().fontFamily,
          brightness: Brightness.light,
          primaryColor: Colors.blue,
        ),
        routes: {
          '/': (context) => SignIn(),
          '/signIn': (context) => SignIn(),
          '/registerRole': (context) => RegisterRole(),
          '/registerRole/customer': (context) => RegisterCustomer(),
          '/registerRole/shopkeeper': (context) => RegisterShopkeeper(),
          '/registerRole/shopkeeper/selectMap': (context) => SelectMapLocate(),
          '/home': (context) => Homepage(),
          '/setting/user': (context) => SettingsUserPage(),
          '/guest': (context) => GuestScreen(),
          // '/guest/productInShop': (context) => GuestProductInShop(),
          '/shop': (context) => BottomNavShop(),
          '/shop/mainScreen': (context) => ShopMainScreen(),
          '/shop/manageProduct': (context) => ManageProductScreen(),
          // '/shop/productDetails': (context) => ProductDetailScreen(),
          // '/customer/productDetail': (context) => ProductDetail(),
          '/shop/addProduct': (context) => AddProductScreen(),
          // '/shop/profileDetail': (context) => ProfileDetailScreen(),

          '/customer': (context) => BottomNavCustomer(),

          ///'/customer/productInshop': (context) => ProductInShop(),
          //'/customer/shopDetail': (context) => Shopdetail(),
          // '/customer/cartList': (context) => Cartlist(),
          // '/customer/payMent': (context) => Payment(),
          '/customer/historyPage': (context) => Historypage(),
          //'/customer/reportShop': (context) => Reportshop(),
          //'/customer/submitPayment': (context) => Submitpayment(),
          // '/customer/mailboxDetail': (context) => MailBoxDetailPage(),
          '/googleMap': (context) => LocationPickerScreen(),
        });
  }
}
