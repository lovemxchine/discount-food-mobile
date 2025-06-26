import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/user/customer/googleMapShopDetail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile/user/customer/productInshop.dart';
import 'package:mobile/user/customer/reportShop.dart';
// import 'package:latlong2/latlong.dart'; // for LatLng
import 'package:url_launcher/url_launcher.dart';

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
  TextEditingController titleController =
      TextEditingController(); // Fixed: for title
  TextEditingController descriptionController =
      TextEditingController(); // Fixed: for description
  bool _isLoading = false;
  var pathAPI = '';
  late String shopUid;

  @override
  void initState() {
    super.initState();
    shopUid = widget.shopData['uid'];
    initFetch();
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<String?> getUID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_uid');
  }

  Future<bool> reportShop({
    required String title,
    required String description,
  }) async {
    String apiUrl = await fetchUrl();
    String userUid = await getUID() ?? '';
    final url = Uri.parse('$apiUrl/customer/reportShop');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userUid': userUid,
        'shopUid': shopData?['uid'] ?? shopUid,
        'shopName': shopData?['name'],
        'title': title,
        'description': description,
      }),
    );
    print('Report response: ${response.statusCode}');
    if (response.statusCode == 200) {
      // Success
      return true;
    } else {
      // Error
      print('Report failed: ${response.body}');
      return false;
    }
  }

  Future<void> initFetch() async {
    await fetchUrl();
    await _fetchShopDetails();
  }

  Future<String> fetchUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      pathAPI = prefs.getString('apiUrl') ?? 'http://10.0.2.2:3000';
    });
    print("API Path: $pathAPI");
    return prefs.getString('apiUrl') as String;
  }

  Future<void> _fetchShopDetails() async {
    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse("$pathAPI/customer/getShopDetails?uid=$shopUid");
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

    Future<void> getCurrentLocation() async {
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
      debugPrint('Current location: $location');
    }

    // Fixed: This should be called once in initState, not inside build
    // getCurrentLocation();

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
                        Center(
                          child: Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(top: 16),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      final lat = shopData?['googleLocation']
                                              ?['lat'] ??
                                          0.0;
                                      final lng = shopData?['googleLocation']
                                              ?['lng'] ??
                                          0.0;
                                      final url =
                                          'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng';
                                      // Open Google Maps in browser
                                      Future.delayed(Duration.zero, () async {
                                        if (await canLaunchUrl(
                                            Uri.parse(url))) {
                                          await launchUrl(Uri.parse(url),
                                              mode: LaunchMode
                                                  .externalApplication);
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content: Text(
                                                    'ไม่สามารถเปิด Google Maps ได้')),
                                          );
                                        }
                                        Navigator.pop(context);
                                      });
                                      return const SizedBox.shrink();
                                    },
                                  ),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.only(top: 12),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(10),
                                  border:
                                      Border.all(color: Colors.blue.shade200),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 8),
                                      child: Icon(Icons.map,
                                          color: Colors.blue, size: 28),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.only(right: 12),
                                      child: Text(
                                        'ดูแผนที่ร้าน',
                                        style: TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
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
                                  child: Reportshop(
                                    titleController: titleController,
                                    descriptionController:
                                        descriptionController,
                                    onReport: reportShop,
                                  ),
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
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final Future<bool> Function(
      {required String title, required String description}) onReport;

  const Reportshop({
    super.key,
    required this.titleController,
    required this.descriptionController,
    required this.onReport,
  });

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
              controller: titleController, // Fixed: Use the correct controller
              decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'กรุณาระบุหัวข้อ',
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
              controller:
                  descriptionController, // Fixed: Use the correct controller
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'กรุณาระบุรายละเอียด',
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
            onPressed: () async {
              // Validate input
              if (titleController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('กรุณาระบุหัวข้อ')),
                );
                return;
              }

              if (descriptionController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('กรุณาระบุรายละเอียด')),
                );
                return;
              }

              try {
                // Show loading
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                );

                // Send report
                bool success = await onReport(
                  title: titleController.text.trim(),
                  description: descriptionController.text.trim(),
                );

                // Hide loading
                Navigator.of(context).pop();

                if (success) {
                  // Clear the form
                  titleController.clear();
                  descriptionController.clear();

                  // Close the dialog
                  Navigator.of(context).pop();

                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('ส่งรายงานเรียบร้อยแล้ว'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  // Show error message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('เกิดข้อผิดพลาด ไม่สามารถส่งรายงานได้'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } catch (e) {
                // Hide loading if still showing
                Navigator.of(context).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('เกิดข้อผิดพลาด: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 44, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              "รายงาน",
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
