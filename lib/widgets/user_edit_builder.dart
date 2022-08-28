import 'package:flutter/material.dart';
import 'package:rendezvous_beta_v3/widgets/profile_view/profile_view.dart';
import 'fields/date_type_picker.dart';
import 'fields/gender_field.dart';
import 'fields/photo_picker.dart';
import 'fields/price_picker.dart';
import 'fields/slider_field.dart';
import 'fields/text_input_field.dart';
import 'gradient_button.dart';
import 'tile_card.dart';

class UserEditBuilder extends StatelessWidget {
  const  UserEditBuilder({Key? key, required this.index, required this.showErrors, required this.onButtonPress, this.homePage = false}) : super(key: key);
  final int index;
  final bool showErrors;
  final void Function() onButtonPress;
  final bool homePage;
  static int itemCount = 12;


  @override
  Widget build(BuildContext context) {
    List<Widget> fields = [
      PhotoPicker(showError: showErrors),
      NameField(showError: showErrors),
      AgeSlider(showError: showErrors),
      BioField(showError: showErrors),
      PickGenderField(
        showError: showErrors,
      ),
      PreferredGenderField(
        showError: showErrors,
      ),
      PreferredAgeSlider(showError: showErrors),
      DistanceSlider(showError: showErrors),
      DateTypePicker(showError: showErrors),
      PricePicker(showError: showErrors),
    ];
    if (index <= fields.length - 1) {
      return TileCard(child: fields[index]);
    } else if (index == fields.length) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(35, 35, 35, 10),
        child: GradientButton(
            title: homePage ? "Save Changes" : "Check out your profile",
            onPressed: onButtonPress
        ),
      );
    }
    return homePage ? Padding(
      padding: const EdgeInsets.fromLTRB(35, 0, 35, 0),
      child: GradientButton(
          title: "Check out profile",
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => UserProfile(homePage: homePage)));
          }
      ),
    ) : Container();
  }
}
