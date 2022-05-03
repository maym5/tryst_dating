import 'package:dio/dio.dart';
import 'dart:math';
import '../models/users.dart';

class GooglePlacesService {
  final String PLACES_API_KEY = "AIzaSyCl-kVxhkNP1ySziCMs8kdkMMMbOMLlg6k";
  final String basePath =
      "https://maps.googleapis.com/maps/api/place/findplacefromtext/json?fields=formatted_address%2Cname%2Crating%2Copening_hours%2Cgeometry";
  GooglePlacesService({required this.venueType});
  final String venueType;
  Dio dio = Dio();

  List<Map<String, dynamic>> get venues {
    final String _path = basePath +
        "&input=$venueType" +
        "&inputtype=textquery&locationbias=circle%3A2000%${UserData.location?.longitude}%2C${UserData.location?.latitude}" + "&key=$PLACES_API_KEY";
    final Map<String, List<Map<String, dynamic>>> _venue = dio.get(_path) as Map<String, List<Map<String, dynamic>>>;
    if (_venue["candidates"] != null) {
      return _venue["candidates"]!;
    } throw("could not find suitable venues");
  }

  // TODO: maybe grab max rating after eliminating all requests without opening hours
  Map<String, dynamic> get venue => venues[Random().nextInt(venues.length)];

  String get address => venue["formatted_address"];

  String get name => venue["name"];

  List? get openHours {
    if (venue["opening_hours"]["periods"] != null) {
      return venue["opening_hours"]["periods"];
    } else {
      return null;
    }
  }


}
