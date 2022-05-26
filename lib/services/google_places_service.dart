import 'dart:math';

import 'package:dio/dio.dart';
import '../models/users.dart';

class GooglePlacesService {
  GooglePlacesService({required this.venueType});
  final String PLACES_API_KEY = "AIzaSyCl-kVxhkNP1ySziCMs8kdkMMMbOMLlg6k";
  final String basePath =
      "https://maps.googleapis.com/maps/api/place/nearbysearch/json?";
  final String detailsBasePath = "https://maps.googleapis.com/maps/api/place/details/json?";
  final String venueType;
  final Dio dio = Dio();

  Future<List> get venues async {
    final double meters = UserData.maxDistance! * 1609.34;
    final String _path = basePath +
        "&location=${UserData.location?.latitude}%2C${UserData.location?.longitude}" +
        "&radius=$meters" +
        "&type=$venueType" +
        "&minprice=${UserData.minPrice}" +
        "&maxprice=${UserData.maxPrice}" +
        "&key=$PLACES_API_KEY";
    try {
      final Response _venues = await dio.get(_path);
      final _venueData = _venues.data;
      final List results = _venueData["results"];
      // type this shit brah//////
      // test this change in control statement
      if (results.isNotEmpty) {
        return results;
      } return [];
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<String> get venueId async {
    List _venues = await venues;
    if (_venues.isNotEmpty) {
      int randInt = Random().nextInt(_venues.length);
      return _venues[randInt]["place_id"];
    } return "No venues found";
  }

  Future<Map> get venue async {
    String _id = await venueId;
    String _fields = "fields=name%2Copening_hours";
    String _path = detailsBasePath + _fields + "&place_id=$_id" + "&key=$PLACES_API_KEY";
    try {
      final Response result = await dio.get(_path);
      final _data = result.data;
      // print("Data: $_data");
      return {
        "name" : _data["result"]["name"],
        "openHours" : _data["result"]["opening_hours"]["periods"],
        "status" : _data["status"]
      };
    } catch (e) {
      print(e);
      return {"status" : "not ok"};
    }
  }

  // Future<List<Map<String, dynamic>>> get venuesWithOpenHours async {

  //   List<Map<String, dynamic>> result = [];
  //   for (Map<String, dynamic> venue in await venues) {
  //     if (venue["opening_hours"]["periods"] != null) {
  //       result.add(venue);
  //     }
  //   } return result;
  // }

  // maybe grab max rating after eliminating all requests without opening hours
  // Future<Map<String, dynamic>> get venue async {
  //   double maxRating = 0;
  //   Map<String, dynamic> resultVenue = {};
  //   for (Map<String, dynamic> venue in await venuesWithOpenHours) {
  //     if (venue["rating"] > maxRating) {
  //       resultVenue = venue;
  //       maxRating = venue["rating"];
  //     }
  //   } return resultVenue;
  // }
  //
  // Future<String> get address async {
  //   final _venue = await venue;
  //   return _venue["formatted_address"];
  // }
  //
  // Future<String> get name async {
  //   final _venue = await venue;
  //   return _venue["name"];
  // }
  //
  // Future<List> get openHours async {
  //   final _venue = await venue;
  //   return _venue["opening_hours"]["periods"];
  // }

// final String basePath =
//     "https://maps.googleapis.com/maps/api/place/findplacefromtext/json?fields=formatted_address%2Cname%2Crating%2Copening_hours";
}
