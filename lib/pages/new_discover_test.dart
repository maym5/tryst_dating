import 'package:flutter/material.dart';
import 'package:rendezvous_beta_v3/services/discover_service.dart';
import 'package:rendezvous_beta_v3/widgets/discover_view/discover_view.dart';
import 'package:rendezvous_beta_v3/widgets/page_background.dart';

class TestDiscoverPage extends StatelessWidget {
  static const id = "test_discover_page";
  const TestDiscoverPage({Key? key}) : super(key: key);

  static final DiscoverData _data = DiscoverData(
      "Rebecca",
      21,
      ["https://firebasestorage.googleapis.com/v0/b/rendezvous-beta-v3.appspot.com/o/images%2Fyb4DGHUek1TvmDXLRvlFqCB9fD02%2F16627498187789570?alt=media&token=e2fcb33f-6c91-4f98-8f1f-bf969960d886"],
      ["bar"],
      "this has been a test blah blah blah blah blah blah blah blah blah blah",
      "yb4DGHUek1TvmDXLRvlFqCB9fD02");

  @override
  Widget build(BuildContext context) {
    return PageBackground(
      body: DiscoverView(
          data: _data,
          onDragUpdate: (double rating) {},
      ),
    );
  }
}
