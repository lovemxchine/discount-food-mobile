import 'package:flutter/material.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SelectMapLocate extends StatefulWidget {
  const SelectMapLocate({Key? key}) : super(key: key);

  @override
  State<SelectMapLocate> createState() => _SelectMapLocateState();
}

class _SelectMapLocateState extends State<SelectMapLocate> {
  final String apiKey = 'AIzaSyAsMbXKCUZGZTVfBpYNtu2k6lvbTm5PhFU';
  Prediction? _selectedPrediction;
  Map<String, dynamic> _placeDetails = {};
  bool _isLoading = false;

  Future<void> _getPlaceDetails(String placeId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(
          'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey'));

      if (response.statusCode == 200) {
        final result = json.decode(response.body)['result'];
        setState(() {
          _placeDetails = {
            'place_name': result['name'],
            'formatted_address': result['formatted_address'],
            'lat': result['geometry']['location']['lat'],
            'lng': result['geometry']['location']['lng'],
          };
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load place details');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GooglePlaceAutoCompleteTextField(
              textEditingController: TextEditingController(),
              googleAPIKey: apiKey,
              inputDecoration: InputDecoration(
                hintText: 'Search for a place',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: Icon(Icons.search),
              ),
              debounceTime: 800,
              countries: ['TH'],
              isLatLngRequired: true,
              getPlaceDetailWithLatLng: (Prediction prediction) {
                setState(() {
                  _selectedPrediction = prediction;
                });
                if (prediction.placeId != null) {
                  _getPlaceDetails(prediction.placeId!);
                }
              },
              itemClick: (Prediction prediction) {
                setState(() {
                  _selectedPrediction = prediction;
                });
                if (prediction.placeId != null) {
                  _getPlaceDetails(prediction.placeId!);
                }
              },
            ),
            SizedBox(height: 16),
            if (_isLoading)
              CircularProgressIndicator()
            else if (_placeDetails.isNotEmpty)
              Container(
                width: 350,
                decoration: BoxDecoration(
                  color: Colors.white30,
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Place Name:',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      Text('${_placeDetails['place_name']}'),
                      SizedBox(height: 8),
                      Text('Address:',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      Text('${_placeDetails['formatted_address']}'),
                    ],
                  ),
                ),
              ),
            if (_placeDetails.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: SizedBox(
                  width: 120,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      print('Selected place: $_placeDetails');
                      // Here you can handle the button press, e.g., send data back to the previous screen
                      Navigator.pop(context, _placeDetails);
                    },
                    child: Text('ยืนยัน',
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                      backgroundColor: Color.fromARGB(255, 54, 120, 244),
                      padding: EdgeInsets.all(8),
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
