import 'package:flutter/material.dart';
import '../cloud/users.dart';
import '../widgets/page_background.dart';
import '../widgets/profile_view/profile_view.dart';
import '../widgets/user_edit_builder.dart';

// class OnboardingUserEditPage extends StatefulWidget {
//   static const id = "onboarding_user_edit_page";
//   const OnboardingUserEditPage({Key? key}) : super(key: key);
//
//   @override
//   _OnboardingUserEditPageState createState() => _OnboardingUserEditPageState();
// }
//
// class _OnboardingUserEditPageState extends State<OnboardingUserEditPage> {
//   late bool showErrors;
//
//   @override
//   void initState() {
//     showErrors = false;
//     super.initState();
//   }
//
//   void onButtonPress() {
//     if (UserData.canCreateUser) {
//       UserData().uploadUserData();
//       Navigator.pushNamed(context, UserProfile.id);
//     } else {
//       setState(() {
//         showErrors = true;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return PageBackground(
//       body: ListView.builder(
//           itemCount: UserEditBuilder.itemCount,
//           itemBuilder: (context, index) => UserEditBuilder(
//               index: index,
//               showErrors: showErrors,
//               onButtonPress: onButtonPress
//           ),
//       ),
//     );
//   }
// }

class UserEditPage extends StatefulWidget {
  static const id = "user_edit_page";
  const UserEditPage({Key? key, this.pop = false}) : super(key: key);
  final bool pop;

  @override
  _UserEditPageState createState() => _UserEditPageState();
}

class _UserEditPageState extends State<UserEditPage> {
  late bool showErrors;

  @override
  void initState() {
    showErrors = false;
    super.initState();
  }

  void onButtonPress() {
    if (UserData.canCreateUser) {
      UserData().uploadUserData();
      if (widget.pop) {
        Navigator.pop(context);
      } else {
        Navigator.pushNamed(context, UserProfile.id);
      }
    } else {
      setState(() {
        showErrors = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageBackground(
      body: ListView.builder(
        itemCount: UserEditBuilder.itemCount,
        itemBuilder: (context, index) => UserEditBuilder(
            index: index,
            showErrors: showErrors,
            onButtonPress: onButtonPress
        ),
      ),
    );
  }
}

