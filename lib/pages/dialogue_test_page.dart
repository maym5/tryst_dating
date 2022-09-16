import 'package:flutter/material.dart';
import 'package:rendezvous_beta_v3/models/dates_model.dart';
import 'package:rendezvous_beta_v3/widgets/gradient_button.dart';
import 'package:rendezvous_beta_v3/widgets/page_background.dart';

import '../services/authentication_service.dart';
import '../services/match_data_service.dart';

class DialogueTestPage extends StatelessWidget {
  static const id = "dialogue_test_page";
  const DialogueTestPage({Key? key}) : super(key: key);
  static final DateTime _dateTime = DateTime.now();

  static final DateData _zach = DateData(
      name: 'Zacharie Dupertuis',
      matchID: 'IeDsvnDuXvdRDIVEzir0JeTQlKx2',
      venue: "Boat Shed Restaurant",
      venueID: "ChIJlcsgeNU5kFQR3axG2oM18_E",
      age: 20,
      dateTypes: ["restaurant"],
      dateType: "restaurant",
      agreedToDate: [
        "IeDsvnDuXvdRDIVEzir0JeTQlKx2",
        AuthenticationService.currentUser
      ],
      image:
          "https://firebasestorage.googleapis.com/v0/b/rendezvous-beta-v3.appspot.com/o/images%2FIeDsvnDuXvdRDIVEzir0JeTQlKx2%2F16627489800330310?alt=media&token=3558dbcc-fc6f-415c-ba66-25a9914978f8",
      dateTime: _dateTime);

  @override
  Widget build(BuildContext context) {
    return PageBackground(
        body: Center(
      child: GradientButton(
        title: 'Ask out',
        onPressed: () async {
          try {
            print("here");
            await DatesModel(dateData: _zach).getDate(context);
          } catch (e) {
            print(e);
          }
        },
      ),
    ));
  }
}
