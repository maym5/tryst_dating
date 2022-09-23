import 'package:flutter/material.dart';

const kTileBackGroundColor = Colors.white10;

const kNameTextStyle = TextStyle(
  color: Colors.white,
  fontSize: 35.0,
  fontWeight: FontWeight.w400,
);

const kAgeTextStyle = TextStyle(
  color: Colors.white,
  fontSize: 30.0,
  fontWeight: FontWeight.w200,
);

const kAppleReviewUid = "s6ULZ0L7iKXPgPss1KnKO3Mk4ca2";

const kExpandTextAnimationDuration = Duration(milliseconds: 200);

const kBioTextStyle = TextStyle(
  color: Colors.white,
  fontSize: 23.0,
  fontWeight: FontWeight.w300,
  inherit: false,
);

const kProfileInfoPadding = EdgeInsets.fromLTRB(10, 0, 10, 0);

final kOffWhite = Colors.white.withOpacity(0.8);

final kTextStyle = TextStyle(
  color: Colors.white.withOpacity(0.6),
  fontSize: 25,
);

final kRatingStyle = TextStyle(
  color: Colors.white.withOpacity(0.6),
  fontSize: 25,
  fontFamily: "Kanit"
);

final kGreyWithAlpha = Colors.grey.withAlpha(50);

const kTileTitlePadding = EdgeInsets.fromLTRB(0, 10, 0, 10);

const kTileFieldPadding =
    EdgeInsets.all(10); // get rid of all this tile constants

const kTilePadding = EdgeInsets.fromLTRB(4, 4, 4, 10);

const kGenderButtonSize = Size(125, 125);

const kTextFieldDecoration = InputDecoration(
  hintText: '',
  hintStyle: TextStyle(
    color: Colors.grey,
  ),
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.grey, width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.red, width: 2.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
);

final SliderThemeData kSliderTheme = SliderThemeData(
  rangeTickMarkShape: const RoundRangeSliderTickMarkShape(tickMarkRadius: 6),
  inactiveTickMarkColor: Colors.white30,
  activeTickMarkColor: Colors.redAccent,
  activeTrackColor: Colors.redAccent,
  inactiveTrackColor: kGreyWithAlpha,
  thumbColor: Colors.redAccent,
  valueIndicatorTextStyle: const TextStyle(color: Colors.white, fontSize: 25),
  overlayColor: Colors.redAccent.withOpacity(0.1),
  disabledThumbColor: kGreyWithAlpha,
);

const kPricePickerPadding = EdgeInsets.fromLTRB(10, 30, 10, 0);

final kInactiveColor = kGreyWithAlpha.withOpacity(0.8);

const kActiveColor = Colors.redAccent;

const kWarningTextStyle = TextStyle(
  fontSize: 18,
  color: kActiveColor,
  fontFamily: 'Kanit',
);

final kDateTypeContainerDecoration = BoxDecoration(
    borderRadius: const BorderRadius.all(Radius.circular(50)),
    color: Colors.black54.withOpacity(0.5));

const kDateTypeGridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
    childAspectRatio: 2,
    mainAxisSpacing: 2,
    crossAxisSpacing: 2,
    crossAxisCount: 3);

const kRatingCircleGradient = LinearGradient(
    colors: [Color(0xFFFD297B), Color(0xFFFF5864), Color(0xFFFF655B)],
    stops: [0.2, 0.4, 0.9]);

const kMessageBubbleGradient = LinearGradient(
    // colors: [Colors.pink, Colors.redAccent, Colors.red],
  colors: [Color(0xFFFD297B), Color(0xFFFF5864), Color(0xFFFF655B)],
    stops: [0.2, 0.4, 0.9],
);

const kButtonGradient = LinearGradient(
    colors: [Color(0xFFFD297B), Color(0xFFFF5864), Colors.redAccent],
    stops: [0.2, 0.4, 0.9]);

const kBioPadding = EdgeInsets.fromLTRB(10, 0, 0, 0);

const kPopUpColor = Color(0xFF0A0E21);

const kUserInfoAlignment = Alignment(-0.9, 0.65);

const kDarkTransparent = Color(0x44000000);

const kPopUpColorScheme = ColorScheme.light(
  primary: Colors.redAccent,
  onPrimary: Colors.white,
  onSurface: Colors.white,
);

final kTextButtonStyle = TextButtonThemeData(
    style: ButtonStyle(
  shape: MaterialStateProperty.resolveWith((states) => const CircleBorder()),
  overlayColor:
      MaterialStateProperty.resolveWith((states) => kActiveColor.withOpacity(0.1)),
));

const kAddIcon = Icon(Icons.add, size: 20, color: Colors.white,);

const kDeleteIcon = Icon(Icons.clear, size: 20, color: Colors.white,);

const kBorderRadius = BorderRadius.all(Radius.circular(25));

const kImagePickerGridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 3, childAspectRatio: 0.65);

final kImagePickerButtonStyle = ButtonStyle(
    alignment: Alignment.center,
    fixedSize:
        MaterialStateProperty.resolveWith((states) => const Size(30, 30)),
    backgroundColor: MaterialStateProperty.resolveWith((states) => kActiveColor),
    shape: MaterialStateProperty.resolveWith((states) => const CircleBorder()));

const kWrapPadding = EdgeInsets.fromLTRB(0, 20, 0, 20);

const kChatBubbleBorderRadius = BorderRadius.only(
    topRight: Radius.circular(8),
    bottomLeft: Radius.circular(25),
    bottomRight: Radius.circular(25),
    topLeft: Radius.circular(25)
);

const kIntroPageBackgroundDecoration = BoxDecoration(
  gradient: LinearGradient(
    end: Alignment.bottomRight,
    begin: Alignment.topLeft,
    colors: [
      Color(0xFF010332),
      Color(0xFF100328),
      Color(0xFF29011C),
      Color(0xFF43000D),
      Color(0xFF530005)
    ],
    stops: [
      0.12, 0.4, 0.8, 0.9, 1
    ],
  ),
);

const kWelcomePageDecoration = BoxDecoration(
  gradient: LinearGradient(
    end: Alignment.bottomRight,
    begin: Alignment.topLeft,
    colors: [
      Color(0xFF040D20),
      Color(0xFF29011C),
      Color(0xFF43000D),
      Color(0xFF530005)
    ],
    stops: [
      0.4, 0.8, 0.9, 1
    ],
  ),
);

const kHyperLinkTextStyle = TextStyle(
    decoration: TextDecoration.underline,
    fontFamily: 'Kanit',
    color: Colors.redAccent,
    fontSize: 13);

const kPageBackgroundDecoration = BoxDecoration(
  color: kEggShell
);

const kEggShell = Color(0xFFF9FEFF);



