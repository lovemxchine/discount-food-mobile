import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> getData(String url) async {
  try {
    // Send GET request
    final response = await http.get(Uri.parse(url));
    // Check if the response was successful (status code 200)
    if (response.statusCode == 404) {
      // Parse the JSON response body
      return jsonDecode(response.body);
    }
    if (response.statusCode == 200) {
      // Parse the JSON response body
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  } catch (e) {
    // Handle errors (e.g., no internet, bad URL)
    print("Error: $e");
    return {};
  }
}
