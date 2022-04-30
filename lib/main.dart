import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:rendezvous_beta_v3/pages/discover_page.dart';
import 'package:rendezvous_beta_v3/pages/home_page.dart';
import 'package:rendezvous_beta_v3/pages/loading_page.dart';
import 'package:rendezvous_beta_v3/pages/login_page.dart';
import 'package:rendezvous_beta_v3/pages/sign_up_page.dart';
import 'package:rendezvous_beta_v3/pages/user_edit_page.dart';
import 'package:rendezvous_beta_v3/widgets/profile_view/profile_view.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  runApp(const Rendezvous());
}

class Rendezvous extends StatelessWidget {
  const Rendezvous({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      initialRoute: LoadingPage.id,
      routes: <String, WidgetBuilder> {
        LoadingPage.id : (BuildContext context) => const LoadingPage(),
        HomePage.id :  (BuildContext context) => const HomePage(),
        UserEditPage.id : (BuildContext context) => const UserEditPage(),
        UserProfile.id : (BuildContext context) => const UserProfile(),
        SignUpPage.id : (BuildContext context) => const SignUpPage(),
        LoginPage.id : (BuildContext context) => const LoginPage(),
        DiscoverPage.id : (BuildContext context) => const DiscoverPage(),
      },
    );
  }
}

