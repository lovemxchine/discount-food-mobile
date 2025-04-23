import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile/components/bottomNav.dart';
import 'package:mobile/user/customer/homePage.dart';
import 'package:mobile/user/customer/mailBox.dart';
import 'package:mobile/user/customer/favoritePage.dart';
import 'package:mobile/user/customer/settingsPage.dart';
import 'package:mobile/utils/func/fetchData.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AllShopNearby extends StatefulWidget {
  @override
  State<AllShopNearby> createState() => _AllShopNearbyState();
}

class _AllShopNearbyState extends State<AllShopNearby> {
  String location = 'Getting location...';
  var pathAPI = '';
  List listProducts = [];

  @override
  void initState() {
    super.initState();
    initFetch();
  }

  Future<void> initFetch() async {
    await fetchUrl();
    await _getCurrentLocation();
  }

  Future<void> fetchUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      pathAPI = prefs.getString('apiUrl') ?? 'http://10.0.2.2:3000';
    });
    print(pathAPI);
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        location = 'Location services are disabled.';
      });
      return;
    }

    // Check permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          location = 'Location permission denied.';
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        location = 'Location permission permanently denied.';
      });
      return;
    }

    // Get location
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      location = 'Lat: ${position.latitude}, Lng: ${position.longitude}';
    });
    print('Current location: $location');

    final result = await getData(
        'http://$pathAPI/shop/nearbyShop?lat=${position.latitude}&lng=${position.longitude}');

    if (result['status'] == "success") {
      setState(() {
        listProducts = result['data'];
      });
    }
    print(listProducts.length);
    print(listProducts);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => true,
      child: Scaffold(
        backgroundColor: const Color(0xFFFF6838),
        body: Stack(
          children: [
            Container(
              color: const Color(0xFFFF6838),
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16.0,
                left: 16.0,
                right: 16.0,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      color: Colors.grey,
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage('assets/images/alt.png'),
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
                        style: TextStyle(fontSize: 18, color: Colors.white),
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
                          style: TextStyle(fontSize: 13, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
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
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: const Text(
                        'ร้านค้าที่กำลังลดราคาในระยะใกล้',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            for (int i = 0; i < 7; i++)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 20),
                                child: InkWell(
                                  onTap: () {
                                    // เผื่อกดดูสินค้า
                                  },
                                  child: Container(
                                    height: 90,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 1,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 80,
                                          height: 80,
                                          decoration: BoxDecoration(
                                            color: Colors.grey,
                                            image: const DecorationImage(
                                              image: AssetImage(
                                                  'assets/images/alt.png'),
                                              fit: BoxFit.cover,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                        ),
                                        const SizedBox(width: 20),
                                        const Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'ชื่อร้านค้า',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              SizedBox(height: 5),
                                              Text(
                                                'ระยะเวลาเปิด - ปิด',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              SizedBox(height: 5),
                                              // Text(
                                              //   'ระยะห่าง',
                                              //   style: TextStyle(
                                              //     fontSize: 12,
                                              //     color: Colors.black,
                                              //   ),
                                              // ),
                                            ],
                                          ),
                                        ),
                                        const Icon(Icons.favorite_border,
                                            color: Colors.red),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            Container(
                              height: 90,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                            )
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
      ),
    );
  }
}
