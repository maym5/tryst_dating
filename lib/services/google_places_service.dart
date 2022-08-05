import 'package:dio/dio.dart';
import '../models/users.dart';

class GooglePlacesService {
  GooglePlacesService({this.venueType});
  final String PLACES_API_KEY = "AIzaSyCl-kVxhkNP1ySziCMs8kdkMMMbOMLlg6k";
  final String basePath =
      "https://maps.googleapis.com/maps/api/place/nearbysearch/json?";
  final String detailsBasePath =
      "https://maps.googleapis.com/maps/api/place/details/json?";
  final String? venueType;
  final Dio dio = Dio();

  Future<List> get venues async {
    final double meters = UserData.maxDistance! * 1609.34;
    final String _path = basePath +
        "&location=${UserData.location?.latitude}%2C${UserData.location?.longitude}" +
        "&radius=$meters" +
        "&keyword=$venueType" +
        "&minprice=${UserData.minPrice}" +
        "&maxprice=${UserData.maxPrice}" +
        "&key=$PLACES_API_KEY";
    try {
      final Response _venues = await dio.get(_path);
      final _venueData = _venues.data;
      final List results = _venueData["results"];
      if (results.isNotEmpty) {
        return results;
      }
      return [];
    } catch (e) {
      print("venueError: $e");
      return [];
    }
  }

  Future<String> get venueId async {
    List _venues = await venues;
    if (_venues.isNotEmpty) {
      // results are returned ranked by prominence, so we grab the first one
      return _venues[0]["place_id"];
    }
    throw "No venues found";
  }

  Future<Map> get venue async {
    String _fields = "fields=name%2Copening_hours";
    try {
      String _id = await venueId;
      String _path =
          detailsBasePath + _fields + "&place_id=$_id" + "&key=$PLACES_API_KEY";
      final Response result = await dio.get(_path);
      final _data = result.data;
      if (result.statusCode! >= 200 && result.statusCode! < 300) {
        return {
          "name": _data["result"]["name"],
          "id" : _id,
          "openHours": _data["result"]["opening_hours"]["periods"],
          "weekdayText" : _data["result"]["opening_hours"]["weekday_text"],
          "status": 'ok'
        };
      } else {
        return {"status": "HTML error"};
      }
    } catch (e) {
      return {"status": e};
    }
  }

  Future<Map> venueFromId(String id) async {
    String _fields = "fields=name%2Copening_hours";
    try {
      String _path = detailsBasePath + _fields + "&place_id=$id" + "&key=$PLACES_API_KEY";
      final Response result = await dio.get(_path);
      final _data = result.data;
      if (result.statusCode! >= 200 && result.statusCode! < 300) {
        return {
          "name": _data["result"]["name"],
          "id" : id,
          "openHours": _data["result"]["opening_hours"]["periods"],
          "weekdayText" : _data["result"]["opening_hours"]["weekday_text"],
          "status": 'ok'
        };
      } else {
        return {"status": "HTML error"};
      }
    } catch(e) {
      return {"status": e};
    }
  }

  static Future<bool> checkDateTime(DateTime dateTime, Map venue) async {
    // 1) convert day of week to int
    // 2) get open hours frm venue getter
    // 3) convert open hours to a DateTime object
    // 4) return whether or not the given time is between the open hours on that day
    final day = dateTime.weekday;
    try {
      final Map openHours = venue["openHours"][day];
      final String _openTime = openHours["open"]["time"];
      final String _closeTime = openHours["close"]["time"];
      final _open = DateTime(
          dateTime.year,
          dateTime.month,
          dateTime.day,
          int.parse(_openTime.substring(0, 2)),
          int.parse(_openTime.substring(2)));
      final _close = DateTime(
          dateTime.year,
          dateTime.month,
          int.parse(_closeTime.substring(0, 2)) < 12
              ? dateTime.day + 1
              : dateTime.day,
          int.parse(_closeTime.substring(0, 2)),
          int.parse(_closeTime.substring(2)));
      if (dateTime.isBefore(_close) && dateTime.isAfter(_open)) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
