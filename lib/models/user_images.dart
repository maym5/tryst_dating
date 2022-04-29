import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import "dart:io";
import 'users.dart';
import 'package:collection/collection.dart';

class UserImages with ChangeNotifier {
  UserImages();

  static List<XFile?> userImages = List.filled(9, null);

  static bool showImageError() {
    int nonNullImages = 0;
    for (XFile? image in userImages) {
      if (image != null) {
        nonNullImages++;
      }
    } return !(nonNullImages >= 1);
  }

  Future<void> addImages(int index) async {
    List<XFile>? images = await ImagePicker().pickMultiImage(imageQuality: 50);
    if (images != null) {
      for (XFile image in images) {
        if (index <= userImages.length - 1) {
          userImages[index] = image;
          index++;
        }
      }
      notifyListeners();
    } else {
      throw Exception("Unable to find those images");
    }
  }

  Future<void> addImageFromCamera(int index) async {
    XFile? image = await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 50);
    userImages[index] = image;
    notifyListeners();
  }

  void deleteImage(int index) {
    userImages[index] = null;
    notifyListeners();
  }

  void reorderImages(int oldIndex, int newIndex) {
    var _selectedPhoto = userImages[oldIndex];
    if (newIndex - oldIndex > 1) {
      for (int i = oldIndex; i <= newIndex; i++) {
        if (i != oldIndex && i != newIndex) {
          userImages[i - 1] = userImages[i];
        } else if (i == newIndex) {
          userImages[i - 1] = userImages[i];
          userImages[newIndex] = _selectedPhoto;
        }
      }
    } else if (newIndex - oldIndex < -1) {
      var nextPhoto = userImages[newIndex];
      for (int i = newIndex; i <= oldIndex; i++) {
        late dynamic currentPhoto;
        if (i == newIndex) {
          userImages[i] = _selectedPhoto;
        } else {
          currentPhoto = userImages[i];
          userImages[i] = nextPhoto;
          nextPhoto = currentPhoto;
        }
      }
    } else {
      var _replacedPhoto = userImages[newIndex];
      userImages[newIndex] = _selectedPhoto;
      userImages[oldIndex] = _replacedPhoto;
    }
    notifyListeners();
  }

  static Future<void> uploadImages(User user) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    List<XFile> _userImages = userImages.whereNotNull().toList();
    UserData.imageURLs.clear();
    for (int i=0; i < _userImages.length; i++) {
      String path = "images/${user.uid}/$i";
      final file = File(_userImages[i].path);
      TaskSnapshot snapshot = await storage.ref().child(path).putFile(file);
      if (snapshot.state == TaskState.success) {
        final String downloadUrl = await snapshot.ref.getDownloadURL();
        UserData.imageURLs.add(downloadUrl);
      } else {
        throw("Something went wrong uploading those images");
      }
    }
  }
}