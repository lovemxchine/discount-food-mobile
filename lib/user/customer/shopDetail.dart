import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile/user/customer/productInshop.dart';
import 'package:mobile/user/customer/reportShop.dart';
import 'package:latlong2/latlong.dart'; // for LatLng

class Shopdetail extends StatefulWidget {
  final Map<String, dynamic> shopData;
  const Shopdetail({super.key, required this.shopData});

  @override
  State<Shopdetail> createState() => _ShopdetailState();
}

class _ShopdetailState extends State<Shopdetail> {
  List<dynamic> listProducts = [];
  List<dynamic> filteredItems = [];
  Map<String, dynamic>? shopData;
  TextEditingController searchController = TextEditingController();
  bool _isLoading = false;
  var pathAPI = '';
  late String shopUid;

  @override
  void initState() {
    super.initState();
    shopUid = widget.shopData['uid'];
    initFetch();
    searchController.addListener(filterItems);
  }

  @override
  void dispose() {
    searchController.removeListener(filterItems);
    searchController.dispose();
    super.dispose();
  }

  void filterItems() {
    setState(() {
      filteredItems = listProducts
          .where((item) => item['name']
              .toLowerCase()
              .contains(searchController.text.toLowerCase()))
          .toList();
    });
  }

  Future<void> initFetch() async {
    await fetchUrl();
    await _fetchShopDetails();
  }

  Future<void> fetchUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      pathAPI = prefs.getString('apiUrl') ?? 'http://10.0.2.2:3000';
    });
    print("API Path: $pathAPI");
  }

  Future<void> _fetchShopDetails() async {
    setState(() {
      _isLoading = true;
    });

    final url =
        Uri.parse("http://$pathAPI/customer/getShopDetails?uid=$shopUid");
    print("Calling URL: $url");
    print("UID used: $shopUid");

    try {
      var response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final data = responseData['data'];
        print(response.body);

        if (data == null || data is! Map<String, dynamic>) {
          print('Invalid data from server');
          setState(() {
            _isLoading = false;
          });
          return;
        }

        setState(() {
          shopData = data;
          _isLoading = false;
        });
        print(shopData);
      } else {
        setState(() {
          _isLoading = false;
        });
        print('Server returned an error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching shop details: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    late double latitude;
    late double longitude;
    String location = 'Unknown location';

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
    }

    initState() {
      super.initState();
      _getCurrentLocation();
    }

    // void _refreshMap() {
    //   setState(() {
    //     // Update map data, e.g., move the center or update zoom
    //     latitude = 13.7700;
    //     longitude = 100.5100;
    //   });
    // }

    if (location != 'Unknown location') {
      List<String> latLng = location.split(',');
      latitude = double.parse(latLng[0].split(': ')[1]);
      longitude = double.parse(latLng[1].split(': ')[1]);
    } else {
      latitude = 0.0;
      longitude = 0.0;
    }
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          'รายละเอียดร้านอาหาร',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: _isLoading || shopData == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Stack(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            height: 200,
                            child: FlutterMap(
                              options: MapOptions(
                                initialCenter: LatLng(
                                    latitude, longitude), // ตำแหน่งที่อยู่
                                maxZoom: 15.0,
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate:
                                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                                  subdomains: ['a', 'b', 'c'],
                                ),
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      point: LatLng(latitude, longitude),
                                      width: 40,
                                      height: 40,
                                      child: Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.location_on,
                                          size: 20,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            )),
                        SizedBox(height: 16),
                        Text(
                          shopData?['name'],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'ระยะเวลาเปิด - ปิด ( ${shopData?['openAt']} -  ${shopData?['closeAt']} )',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.local_shipping, color: Colors.blue),
                            SizedBox(width: 8),
                            Text(
                              'มีบริการจัดส่ง',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Divider(),
                        SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.phone, color: Colors.red),
                            SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ติดต่อร้านค้า',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'เบอร์: ${shopData?['tel']}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  'อีเมล์: ${shopData?['email']}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.location_on, color: Colors.red),
                            SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'ตำแหน่งที่ตั้ง',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    '${shopData?['shopLocation_th']?['place'] ?? ''}, '
                                    '${shopData?['shopLocation_th']?['subdistrict'] ?? ''}, '
                                    '${shopData?['shopLocation_th']?['district'] ?? ''}, '
                                    '${shopData?['shopLocation_th']?['province'] ?? ''}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 100),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return Dialog(
                                insetPadding: const EdgeInsets.all(16),
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: AnimatedPadding(
                                  padding: EdgeInsets.only(
                                    bottom: MediaQuery.of(context)
                                            .viewInsets
                                            .bottom +
                                        16,
                                    top: 16,
                                    left: 16,
                                    right: 16,
                                  ),
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.decelerate,
                                  child: Reportshop(),
                                ),
                              );
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 34, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 5,
                          shadowColor: Colors.black,
                        ),
                        child: const Text(
                          'รายงาน',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
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

class Reportshop extends StatelessWidget {
  const Reportshop({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.black),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          const Text(
            "ชื่อหัวข้อ",
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintStyle: const TextStyle(
                    color: Colors.grey,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  )),
            ),
          ),
          const Text(
            "เนื้อหา",
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          const SizedBox(
            height: 4,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: TextField(
              minLines: 8,
              maxLines: 13,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintStyle: const TextStyle(
                  color: Colors.grey,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 44, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              "ยืนยัน",
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: Colors.white),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
