import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile/user/customer/googleMapShopDetail.dart';
import 'package:mobile/user/customer/productInshop.dart';

class ShopDetails extends StatefulWidget {
  ShopDetails({super.key, required this.shopData});
  Map<String, dynamic> shopData;
  @override
  State<ShopDetails> createState() => _ShopDetailsState();
}

class _ShopDetailsState extends State<ShopDetails> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'รายละเอียดร้านอาหาร',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // แผนที่ (คุณสามารถใช้ Google Maps API)
                    // Container(
                    //   height: 200,
                    //   child: GoogleMap(
                    //     initialCameraPosition: CameraPosition(
                    //       target: LatLng(52.4862, -1.8904), // ตำแหน่งที่อยู่
                    //       zoom: 14,
                    //     ),
                    //     markers: {
                    //       Marker(
                    //         markerId: MarkerId('storeLocation'),
                    //         position: LatLng(52.4862, -1.8904),
                    //       ),
                    //     },
                    //   ),
                    // ),
                    // Container(
                    //   height: 200,
                    // ),
                    // SizedBox(height: 16),
                    Text(
                      widget.shopData['name'],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'ระยะเวลาเปิด - ปิด (${widget.shopData['openAt']} - ${widget.shopData['closeAt']})',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),

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
                              'เบอร์: ${widget.shopData['tel']}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              'อีเมล์: ${widget.shopData['email']}',
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
                                '${widget.shopData?['shopLocation_th']?['place'] ?? ''}, '
                                '${widget.shopData?['shopLocation_th']?['subdistrict'] ?? ''}, '
                                '${widget.shopData?['shopLocation_th']?['district'] ?? ''}, '
                                '${widget.shopData?['shopLocation_th']?['province'] ?? ''}',
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
                    SizedBox(height: 16),
                    Center(
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(top: 16),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GoogleMapShopDetail(
                                  initialLocation: LatLng(
                                    widget.shopData?['googleLocation']
                                            ?['lat'] ??
                                        0.0,
                                    widget.shopData?['googleLocation']
                                            ?['lng'] ??
                                        0.0,
                                  ),
                                  lockOnStart: true,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(top: 12),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.blue.shade200),
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
            ],
          ),
        ),
      ),
    );
  }
}
