import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';

class GooglePlacesService {
  GooglePlacesService();

  // Function to return GooglePlacesAutocomplete widget
  Widget placesAutocompleteTextField({
    required TextEditingController textEditingController,
    required Function(Map<String, dynamic>) onPlaceSelected,
    List<String> countries = const ['TH'], // Default to Thailand
  }) {
    return GooglePlaceAutoCompleteTextField(
      textEditingController: textEditingController,
      googleAPIKey: "AIzaSyAgl5EuSEHtVFBGiDYyFaRsix2fNHa45ck",
      inputDecoration: InputDecoration(
        hintText: 'Search Place',
        border: OutlineInputBorder(),
      ),
      countries: countries,
      getPlaceDetailWithLatLng: (prediction) {
        print("Place details: ${prediction.description}");
      },
      itemClick: (prediction) async {
        // Handle selected place, you can call Google Places API to get full details
        var placeDetails = {
          'placeId': prediction.placeId,
          'description': prediction.description,
        };
        onPlaceSelected(placeDetails);
      },
    );
  }

  // Function to move Google Map to the selected place
  void moveMapToPlace(GoogleMapController mapController, LatLng position) {
    mapController.animateCamera(CameraUpdate.newLatLngZoom(position, 14.0));
  }
}
