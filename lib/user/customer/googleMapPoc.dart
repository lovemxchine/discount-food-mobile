import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class LocationPickerScreen extends StatefulWidget {
  @override
  _LocationPickerScreenState createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  LatLng? _pickedLocation;
  GoogleMapController? _mapController;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied');
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

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
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  void _selectLocation(LatLng location) {
    setState(() {
      _pickedLocation = location;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: Text('เลือกตำแหน่งบนแผนที่'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: _pickedLocation == null
                ? null
                : () {
                    Navigator.pop(context, _pickedLocation);
                  },
          ),
        ],
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
              if (_currentPosition != null) {
                controller.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(
                      target: LatLng(
                        _currentPosition!.latitude,
                        _currentPosition!.longitude,
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
                    )
                  }
                : {},
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
          ),
          Positioned(
            left: 16,
            bottom: 16,
            child: FloatingActionButton(
              onPressed: _getCurrentLocation,
              child: Icon(Icons.my_location),
              tooltip: 'Get Current Location',
              backgroundColor: Colors.blueGrey,
              elevation: 4,
            ),
          ),
        ],
      ),
    );
  }
}
