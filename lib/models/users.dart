import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rendezvous_beta_v3/models/user_images.dart';
import 'package:rendezvous_beta_v3/pages/discover_page.dart';
import 'package:rendezvous_beta_v3/services/authentication.dart';

class UserData with ChangeNotifier {
  static String? name;
  static int? age;
  static String? gender;
  static String? bio;
  static Set<String> dates = {};
  static Set<String> prefGender = {};
  static int? minAge;
  static int? maxAge;
  static int? maxDistance;
  static int? minPrice;
  static int? maxPrice;
  static List<String> imageURLs = [];
  static Position? location;

  UserData();

  static Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'gender': gender.toString(),
      'bio': bio,
      'dates': dates.toList(),
      'prefGender': prefGender.toList(),
      'minAge': minAge,
      'maxAge': maxAge,
      'distance': maxDistance,
      'minPrice': minPrice,
      "maxPrice": maxPrice,
      'imageURLs': imageURLs,
      "loaction" : location,
      "uid": currentUserUID
    };
  }

  static Set<String> toSetOfString(dynamic values) {
    Set<String> result = {};
    for (var item in values) {
      result.add(item.toString());
    }
    return result;
  }

  static void fromJson(Map<String, dynamic> incomingData) {
    name = incomingData["name"];
    age = incomingData["age"];
    gender = incomingData["gender"];
    prefGender = toSetOfString(incomingData["prefGender"]);
    bio = incomingData["bio"];
    dates = toSetOfString(incomingData["dates"]);
    maxPrice = incomingData["maxPrice"];
    minPrice = incomingData["minPrice"];
    maxDistance = incomingData["distance"];
    maxAge = incomingData["maxAge"];
    minAge = incomingData["minAge"];
    imageURLs = DiscoverData.listToListOfStrings(incomingData["imageURLs"]);
  }

  User? retrieveUser({FirebaseAuth? auth}) {
    auth ??= FirebaseAuth.instance;
    return auth.currentUser;
  }

  Future<void> uploadUserData() async {
    final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
    User? _user = retrieveUser();
    if (_user != null) {
      await UserImages.uploadImages(_user);
      Map<String, dynamic> _userData = UserData.toJson();
      _fireStore.collection("userData").doc(_user.uid).set(_userData);
    }
  }

  static bool get canCreateUser {
    for (var value in UserData.toJson().values) {
      if (value == null) {
        return false;
      }
    }
    return true;
  }

  static Future<Position> get userLocation async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error("Location services are not enabled");
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error("Location permissions are denied");
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          "Permissions are denied forever, there is nothing we can do");
    }
    return await Geolocator.getCurrentPosition();
  }

  static void resetUserData() {
    name = null;
    age = null;
    gender = null;
    bio = null;
    dates = {};
    prefGender = {};
    minAge = null;
    maxAge = null;
    maxDistance = null;
    minPrice = null;
    maxPrice = null;
    imageURLs = [];
    location = null;
    UserImages.clearPhotos();
  }

  Future<void> getUserData() async {
    final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
    User? _user = retrieveUser();
    final DocumentSnapshot snapshot =
        await _fireStore.collection("userData").doc(_user?.uid).get();
    final Map<String, dynamic> _data = snapshot.data() as Map<String, dynamic>;
    fromJson(_data);
    UserImages.getImagesFromUserData();
  }

  Future<void> uploadUserLocation() async {
    final FirebaseFirestore _db = FirebaseFirestore.instance;
    User? _user = retrieveUser();
    await _db.collection("userData").doc(_user?.uid).update({
      "location":
          GeoPoint(UserData.location!.latitude, UserData.location!.longitude)
    });
  }
}
