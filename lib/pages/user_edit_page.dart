import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:rendezvous_beta_v3/constants.dart';
import '../dialogues/log_out_dialogue.dart';
import '../models/users.dart';
import '../widgets/page_background.dart';
import '../widgets/profile_view/profile_view.dart';
import '../widgets/user_edit_builder.dart';
import 'dart:io';

class UserEditPage extends StatefulWidget {
  static const id = "user_edit_page";
  const UserEditPage({Key? key, this.onHomePageButtonPress}) : super(key: key);
  final void Function()? onHomePageButtonPress;

  @override
  _UserEditPageState createState() => _UserEditPageState();
}

class _UserEditPageState extends State<UserEditPage>{
  late bool showErrors;
  late bool showSpinners;

  @override
  void initState() {
    showErrors = false;
    showSpinners = false;
    super.initState();
  }

  void onButtonPress() async {
    if (UserData.canCreateUser) {
      setState(() => showSpinners = true);
      await UserData().uploadUserData();
      setState(() => showSpinners = false);
      if (widget.onHomePageButtonPress != null) {
        widget.onHomePageButtonPress!();
      } else {
        Navigator.pushNamed(context, UserProfile.id);
      }
    } else {
      setState(() {
        showErrors = true;
      });
    }
  }

  IconData get _optionsIcon => Platform.isIOS ? Icons.more_horiz : Icons.more_vert;

  @override
  Widget build(BuildContext context) {
    return PageBackground(
      appBar: PreferredSize(
        preferredSize: const Size(double.infinity, 50),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.black45,
          title: Text("Rendezvous", style: kTextStyle.copyWith(color: Colors.redAccent)),
          actions: [
            // get current user and only show this if they're on discover
            IconButton(
              icon: Icon(_optionsIcon),
              color: Colors.redAccent,
              onPressed: () {
                showGeneralDialog(
                  barrierColor: Colors.black.withOpacity(0.5),
                  context: context,
                  transitionBuilder: (ctx, _animation, _, child) =>
                      LogOutDialogue(animation: _animation),
                  pageBuilder: (BuildContext context, _animation, _) {
                    return Container();
                  },
                  transitionDuration: const Duration(milliseconds: 200),
                  barrierDismissible: true,
                  barrierLabel: '',
                );
              },
            )
          ],
        ),
      ),
      body: ModalProgressHUD(
        inAsyncCall: showSpinners,
        progressIndicator: const CircularProgressIndicator(color: Colors.redAccent),
        color: kDarkTransparent,
        child: ListView.builder(
          itemCount: UserEditBuilder.itemCount,
          itemBuilder: (context, index) => UserEditBuilder(
              index: index,
              homePage: widget.onHomePageButtonPress != null,
              showErrors: showErrors,
              onButtonPress: onButtonPress
          ),
        ),
      ),
    );
  }

}

