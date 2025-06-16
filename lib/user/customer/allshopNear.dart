import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile/components/bottomNav.dart';
import 'package:mobile/user/customer/homePage.dart';
import 'package:mobile/user/customer/mailBox.dart';
import 'package:mobile/user/customer/favoritePage.dart';
import 'package:mobile/user/customer/productInshop.dart';
import 'package:mobile/user/customer/settingsPage.dart';
import 'package:mobile/utils/func/fetchData.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AllShopNearby extends StatefulWidget {
  @override
  State<AllShopNearby> createState() => _AllShopNearbyState();
}

class _AllShopNearbyState extends State<AllShopNearby> {
  String location = 'Getting location...';
  var pathAPI = '';
  List listProducts = [];
  double selectedDistance = 5.0; // Default distance in km
  Position? currentPosition; // Store current position

  // Distance options
  final List<double> distanceOptions = [1.0, 2.0, 5.0, 10.0, 15.0, 20.0];

  Map<String, dynamic>? userProfileData;
  bool _isLoading = true;
  bool _isLoadingShops = false;

  @override
  void initState() {
    super.initState();
    initFetch();
    _fetchProfile();
  }

  Future<void> updateFav(String shopUID) async {
    String? uid = await getUID();
    setState(() {
      _isLoading = true;
    });
    final url = Uri.parse("$pathAPI/customer/favoriteShop");

    try {
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'shopUid': shopUID, 'uid': uid}),
      );
      final Map<String, dynamic> responseData = json.decode(response.body);
      print("$pathAPI/customer/profileDetail?uid=$uid");

      if (response.statusCode == 200) {
        setState(() {
          userProfileData = responseData['data'];
        });
        print(userProfileData);
      } else {
        // Handle error
      }
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error: $e');
    }
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
      currentPosition = position;
    });
    print('Current location: $location');

    // Fetch shops with default distance
    await _fetchNearbyShops();
  }

  Future<void> _fetchNearbyShops() async {
    if (currentPosition == null) return;

    setState(() {
      _isLoadingShops = true;
    });

    try {
      final result = await getData(
          '$pathAPI/shop/nearbyShop?lat=${currentPosition!.latitude}&lng=${currentPosition!.longitude}&distance=$selectedDistance');
      print(
          '$pathAPI/shop/nearbyShop?lat=${currentPosition!.latitude}&lng=${currentPosition!.longitude}&distance=$selectedDistance');

      if (result['status'] == "success") {
        setState(() {
          listProducts = result['data'];
        });
      } else {
        listProducts = []; // Clear the list if no data or error
      }
      print("nearby shop ${listProducts}");
    } catch (e) {
      print('Error fetching nearby shops: $e');
    } finally {
      setState(() {
        _isLoadingShops = false;
      });
    }
  }

  void _showDistanceSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'เลือกระยะทาง',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ...distanceOptions.map((distance) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 5),
                  child: ListTile(
                    title: Text(
                      '${distance.toStringAsFixed(distance == distance.toInt() ? 0 : 1)} กิโลเมตร',
                      style: const TextStyle(fontSize: 16),
                    ),
                    leading: Radio<double>(
                      value: distance,
                      groupValue: selectedDistance,
                      onChanged: (double? value) async {
                        if (value != null) {
                          setState(() {
                            selectedDistance = value;
                          });
                          Navigator.pop(context);
                          await _fetchNearbyShops(); // Refresh shops with new distance
                        }
                      },
                      activeColor: const Color(0xFFFF6838),
                    ),
                    onTap: () {
                      setState(() {
                        selectedDistance = distance;
                      });
                      Navigator.pop(context);
                      _fetchNearbyShops(); // Refresh shops with new distance
                    },
                  ),
                );
              }).toList(),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Future<String> getUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('apiUrl') ?? 'http://10.0.2.2:3000';
  }

  Future<String?> getUID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_uid');
  }

  Future<void> _fetchProfile() async {
    String? uid = await getUID();
    var pathAPI = await getUrl();

    if (uid == null) {
      // Handle the case when UID is not available
      return;
    }
    print("pathAPI $pathAPI");
    final url = Uri.parse("$pathAPI/customer/profileDetail?uid=$uid");

    try {
      var response = await http.get(url);
      final Map<String, dynamic> responseData = json.decode(response.body);
      print("$pathAPI/customer/profileDetail?uid=$uid");

      if (response.statusCode == 200) {
        setState(() {
          userProfileData = responseData['data'];
          _isLoading = false;
        });
        print("userProfileData:  $userProfileData");
      } else {
        setState(() {
          _isLoading = false;
        });
        // Handle error
      }
    } catch (e) {
      print('Error: $e');
    }
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        userProfileData != null
                            ? Text(
                                '${userProfileData!['fname']} ${userProfileData!['lname']}',
                                style: const TextStyle(
                                    fontSize: 18, color: Colors.white),
                              )
                            : const Text(
                                'กำลังโหลด...',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white),
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
                  ),
                  // Distance selector button
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                'ร้านค้าที่กำลังลดราคา',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Container(
                              child: Text(
                                'ในระยะ ${selectedDistance.toStringAsFixed(selectedDistance == selectedDistance.toInt() ? 0 : 1)} กิโลเมตร',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: _showDistanceSelector,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 0, 0, 0)
                                  .withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.black, width: 1),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.location_on,
                                    color: Colors.black, size: 18),
                                const SizedBox(width: 4),
                                Text(
                                  '${selectedDistance.toStringAsFixed(selectedDistance == selectedDistance.toInt() ? 0 : 1)} กม.',
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 16),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.keyboard_arrow_down,
                                    color: Colors.black, size: 18),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: _isLoading || _isLoadingShops
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : RefreshIndicator(
                              onRefresh: _fetchNearbyShops,
                              child: SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                child: listProducts.isEmpty
                                    ? Container(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.5,
                                        child: const Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.store_outlined,
                                              size: 64,
                                              color: Colors.grey,
                                            ),
                                            SizedBox(height: 16),
                                            Text(
                                              'ไม่มีร้านค้าใกล้เคียง',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.grey),
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              'ลองเปลี่ยนระยะทางในการค้นหา',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                      )
                                    : Column(
                                        children: [
                                          ...listProducts.map((item) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8,
                                                      horizontal: 20),
                                              child: InkWell(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          ProductInShop(
                                                        shopData: item,
                                                      ),
                                                    ),
                                                  );
                                                },
                                                child: Container(
                                                  height: 90,
                                                  padding:
                                                      const EdgeInsets.all(12),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
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
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Container(
                                                        width: 80,
                                                        height: 80,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.grey,
                                                          image:
                                                              DecorationImage(
                                                            image: NetworkImage(item[
                                                                        'imgUrl']
                                                                    [
                                                                    'shopUrl'] ??
                                                                'https://via.placeholder.com/150'),
                                                            fit: BoxFit.cover,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 20),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              item['name'],
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 12,
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                height: 5),
                                                            Text(
                                                              'เวลาเปิด-ปิด: ${item['openTime'] ?? '10:00'} - ${item['closeTime'] ?? '22:00'}',
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 12,
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                height: 5),
                                                            // Show distance if available
                                                            if (item[
                                                                    'distance'] !=
                                                                null)
                                                              Text(
                                                                'ระยะทาง: ${item['distance'].toStringAsFixed(1)} กม.',
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize: 11,
                                                                  color: Colors
                                                                      .grey,
                                                                ),
                                                              ),
                                                          ],
                                                        ),
                                                      ),
                                                      InkWell(
                                                        onTap: () {
                                                          updateFav(
                                                              item['uid']);
                                                          setState(() {
                                                            initFetch();
                                                          });
                                                        },
                                                        child: Icon(
                                                          userProfileData?[
                                                                          'favShop']
                                                                      ?.contains(
                                                                          item[
                                                                              'uid']) ??
                                                                  false
                                                              ? Icons.favorite
                                                              : Icons
                                                                  .favorite_border,
                                                          color: Colors.red,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                          Container(
                                            height: 90,
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          )
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
}
