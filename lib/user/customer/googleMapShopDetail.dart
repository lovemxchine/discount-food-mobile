import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class GoogleMapShopDetail extends StatefulWidget {
  final LatLng? initialLocation;
  final bool lockOnStart;

  GoogleMapShopDetail({this.initialLocation, this.lockOnStart = false});

  @override
  _GoogleMapShopDetailState createState() => _GoogleMapShopDetailState();
}

class _GoogleMapShopDetailState extends State<GoogleMapShopDetail> {
  LatLng? _pickedLocation;
  GoogleMapController? _mapController;
  Position? _currentPosition;
  bool _isLocationLocked = false;

  @override
  void initState() {
    super.initState();

    if (widget.initialLocation != null) {
      _pickedLocation = widget.initialLocation;
      _isLocationLocked = widget.lockOnStart;

      // Center map after controller is ready
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_mapController != null) {
          _mapController!.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: _pickedLocation!,
                zoom: 15,
              ),
            ),
          );
        }
      });
    } else {
      _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showErrorDialog('Location services are disabled.');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showErrorDialog('Location permissions are denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showErrorDialog('Location permissions are permanently denied');
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        _currentPosition = position;
        _pickedLocation = LatLng(position.latitude, position.longitude);
      });

      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 15,
            ),
          ),
        );
      }

      // Show coordinates in console
      print(
          "Current Location: Lat: ${position.latitude}, Lng: ${position.longitude}");
    } catch (e) {
      print("Error getting location: $e");
      _showErrorDialog("Error getting location: $e");
    }
  }

  void _selectLocation(LatLng location) {
    if (!_isLocationLocked) {
      setState(() {
        _pickedLocation = location;
      });
      print(
          "Selected Location: Lat: ${location.latitude}, Lng: ${location.longitude}");
    }
  }

  void _toggleLocationLock() {
    setState(() {
      _isLocationLocked = !_isLocationLocked;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isLocationLocked
            ? 'Location locked! Pin cannot be moved.'
            : 'Location unlocked! You can move the pin.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Location Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showLocationInfo() {
    if (_pickedLocation != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Location Coordinates'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    'Latitude: ${_pickedLocation!.latitude.toStringAsFixed(6)}'),
                SizedBox(height: 8),
                Text(
                    'Longitude: ${_pickedLocation!.longitude.toStringAsFixed(6)}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: Text('ตำแหน่งร้านค้า'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(13.7563, 100.5018),
              zoom: 12,
            ),
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
              if (widget.initialLocation != null) {
                controller.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(
                      target: LatLng(
                        widget.initialLocation!.latitude,
                        widget.initialLocation!.longitude,
                      ),
                      zoom: 15,
                    ),
                  ),
                );
              }
            },
            onTap: _selectLocation,
            markers: _pickedLocation != null
                ? {
                    Marker(
                      markerId: MarkerId('picked-location'),
                      position: _pickedLocation!,
                      icon: _isLocationLocked
                          ? BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueRed)
                          : BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueBlue),
                      infoWindow: InfoWindow(
                        title: _isLocationLocked
                            ? 'Locked Location'
                            : 'Selected Location',
                        snippet:
                            'Lat: ${_pickedLocation!.latitude.toStringAsFixed(4)}, '
                            'Lng: ${_pickedLocation!.longitude.toStringAsFixed(4)}',
                      ),
                    )
                  }
                : {},
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
          ),

          // Current Location Button
          // Positioned(
          //   left: 16,
          //   bottom: 16,
          //   child: FloatingActionButton(
          //     onPressed: _getCurrentLocation,
          //     child: Icon(Icons.my_location),
          //     tooltip: 'Get Current Location',
          //     backgroundColor: Colors.blueGrey,
          //     elevation: 4,
          //     heroTag: "location_button",
          //   ),
          // ),

          // Lock/Unlock Button

          // Coordinates Display
          if (_pickedLocation != null)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Selected Location:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Lat: ${_pickedLocation!.latitude.toStringAsFixed(6)}',
                      style: TextStyle(fontSize: 12),
                    ),
                    Text(
                      'Lng: ${_pickedLocation!.longitude.toStringAsFixed(6)}',
                      style: TextStyle(fontSize: 12),
                    ),
                    if (_isLocationLocked)
                      Container(
                        margin: EdgeInsets.only(top: 4),
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'LOCKED',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
