import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:rendezvous_beta_v3/constants.dart';
import 'package:rendezvous_beta_v3/widgets/discover_view/discover_view.dart';

import '../cloud_functions/users.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({Key? key}) : super(key: key);

  @override
  _DiscoverPageState createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        children: [
          StreamBuilder(
          stream: DiscoverService().discoverStream,
            builder: (BuildContext context, AsyncSnapshot stream) {
              if (stream.hasData) {
                return DiscoverView(
                    dateTypes: stream.data!['dates'],
                    images: stream.data!["imageURLs"],
                    age: stream.data!["age"],
                    name: stream.data!["name"],
                    bio: stream.data!["bio"]);
              } else {
                return Center(
                  child: Text("Data not available", style: kTextStyle),
                );
              }
            }
        ),
        ],
      ),
    );
  }
}



class DiscoverService {
  // TODO: figure this out
  DiscoverService();
  final Map<String, dynamic> data = UserData.toJson();

  Stream get discoverStream {
    FirebaseFirestore db = FirebaseFirestore.instance;
    late final Stream stream = db.collection("userData").where(
        "distance", isLessThanOrEqualTo: data["distance"]).where(
        "gender", arrayContainsAny: data["prefGender"]).where(
        "dates", arrayContainsAny: data["dates"]).where(
        "age", isGreaterThanOrEqualTo: data["minAge"]).where(
        "age", isLessThanOrEqualTo: data["maxAge"]).where(
        "minPrice", isGreaterThanOrEqualTo: data["minPrice"]).where(
        "maxPrice", isLessThanOrEqualTo: data["maxPrice"]).snapshots();
    return stream.map((event) => UserData.fromJson(event));
  }

  // Stream<Map> convertStream(Stream source) async* {
  //   Stream<Map> result;
  //   await for (var item in source) {
  //     UserData.fromJson(item);
  //   }
  // }
  //
  // Stream<Map> get discoverStream {
  //   return convertStream(rawStream);
  // }

}