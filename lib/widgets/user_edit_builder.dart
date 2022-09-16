import 'package:flutter/material.dart';
import 'package:rendezvous_beta_v3/constants.dart';
import 'package:rendezvous_beta_v3/dialogues/error_dialogue.dart';
import 'package:rendezvous_beta_v3/widgets/profile_view/profile_view.dart';
import 'fields/date_type_picker.dart';
import 'fields/gender_field.dart';
import 'fields/photo_picker.dart';
import 'fields/price_picker.dart';
import 'fields/slider_field.dart';
import 'fields/text_input_field.dart';
import 'gradient_button.dart';
import 'tile_card.dart';
import 'package:url_launcher/url_launcher.dart';

class UserEditBuilder extends StatelessWidget {
  const UserEditBuilder(
      {Key? key,
      required this.index,
      required this.showErrors,
      required this.onButtonPress,
      this.homePage = false})
      : super(key: key);
  final int index;
  final bool showErrors;
  final void Function() onButtonPress;
  final bool homePage;
  static int itemCount = 13;
  static final Uri _privacyUrl = Uri.parse(
      "https://app.termly.io/document/privacy-policy/72d5eaea-f908-415a-902b-357902e9cf33");

  Widget get _version => Text(
        "version 1.0.1+2",
        style: kTextStyle.copyWith(fontSize: 12),
      );

  Widget _privacyPolicy(BuildContext context) => GestureDetector(
        onTap: () {
          _launchPrivacyPolicy(context);
        },
        child: const Text(
          "Privacy Policy",
          style: kHyperLinkTextStyle,
        ),
      );

  void _launchPrivacyPolicy(BuildContext context) async {
    try {
      if (await canLaunchUrl(_privacyUrl)) {
        await launchUrl(_privacyUrl);
      }
    } catch (e) {
      await showGeneralDialog(
          context: context,
          pageBuilder: (context, animation, _) =>
              ErrorDialogue(animation: animation));
    }
  }

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
            onPressed: onButtonPress),
      );
    } else if (index == fields.length + 1) {
      return homePage
          ? Padding(
              padding: const EdgeInsets.fromLTRB(35, 0, 35, 0),
              child: GradientButton(
                  title: "Check out profile",
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                UserProfile(homePage: homePage)));
                  }),
            )
          : Container();
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 35, 0, 50),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _version,
            const SizedBox(
              width: 10,
            ),
            _privacyPolicy(context)
          ],
        ),
      ),
    );
  }
}
