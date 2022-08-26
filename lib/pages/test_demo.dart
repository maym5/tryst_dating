import 'package:flutter/material.dart';
import 'package:rendezvous_beta_v3/widgets/discover_view/demo_profile.dart';
import 'package:rendezvous_beta_v3/widgets/page_background.dart';

class TestDemoPage extends StatefulWidget {
  const TestDemoPage({Key? key}) : super(key: key);
  static const id = "test_demo";

  @override
  State<TestDemoPage> createState() => _TestDemoPageState();
}

class _TestDemoPageState extends State<TestDemoPage> {
  @override
  Widget build(BuildContext context) {
    return const PageBackground(
        body: DemoProfile(),
    );
  }
}
