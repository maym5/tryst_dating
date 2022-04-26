import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rendezvous_beta_v3/widgets/discover_view/discover_view.dart';
import '../services/discover_service.dart';

class DiscoverPage extends StatefulWidget {
  static const id = "discover_page";
  const DiscoverPage({Key? key}) : super(key: key);

  @override
  _DiscoverPageState createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  // TODO: build like widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: DiscoverService().discoverData,
        builder: (context, AsyncSnapshot<QuerySnapshot<Map>> snapshot) => PageView.builder(
          scrollDirection: Axis.vertical,
          itemBuilder: (BuildContext context, int index) {
            if (snapshot.hasData) {
              final List<Map<String, dynamic>> documents = snapshot.data!.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
              final Map<String, dynamic> currentDoc = documents[index];
              return DiscoverView(
                // TODO: 1) test this!!!
                data: DiscoverData.getDiscoverData(currentDoc),
              );
            } else {
              // TODO: add animation
              return const Center(
                child: Text("Couldn't fetch any data"),
              );
            }
          }
        ),
        ),
      );
  }
}


class DiscoverData {
  DiscoverData(this.name, this.age, this.images, this.dates, this.bio);
  final String name;
  final int age;
  final List<String> dates;
  final List<String> images;
  final String bio;

  static List<String> listToListOfStrings(List list) {
    final List<String> aListOfStrings = [];
    for (var item in list) {
      aListOfStrings.add(item.toString());
    } return aListOfStrings;
  }

  // factory DiscoverData.getDiscoverData(String name, int age, List dates, List images, String bio) {
  //   final List<String> _dates = listToListOfStrings(dates);
  //   final List<String> _images = listToListOfStrings(images);
  //   return DiscoverData(name, age, _images, _dates, bio);
  // }

  factory DiscoverData.getDiscoverData(Map<String, dynamic> data) {
    final List<String> _dates = listToListOfStrings(data["dates"]);
    final List<String> _images = listToListOfStrings(data["images"]);
    return DiscoverData(data["name"], data["age"], _images, _dates, data["bio"]);
  }

}