import 'package:flutter/material.dart';
import '../../constants.dart';
import '../../models/users.dart';
import '../field_title.dart';
import '../warning_widget.dart';

class TextInputField extends StatefulWidget {
  const TextInputField({
    Key? key,
    required this.title,
    required this.onChanged,
    required this.showError,
    this.errorMessage,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.hintText,
    this.initialValue,
    this.controller,
  }) : super(key: key);
  final String title;
  final String? errorMessage;
  final bool showError;
  final int maxLines;
  final void Function(String) onChanged;
  final TextInputType keyboardType;
  final String? hintText;
  final bool obscureText;
  final String? initialValue;
  final TextEditingController? controller;

  @override
  State<TextInputField> createState() => _TextInputFieldState();
}

class _TextInputFieldState extends State<TextInputField> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialValue);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        FieldTitle(widget.title),
        Padding(
          padding: kTileFieldPadding,
          child: TextField(
            controller: widget.controller ?? _controller,
            cursorColor: kActiveColor,
            obscureText: widget.obscureText,
            maxLines: widget.maxLines,
            keyboardType: widget.keyboardType,
            decoration:
                kTextFieldDecoration.copyWith(hintText: widget.hintText),
            onChanged: (value) {
              setState(() {
                widget.onChanged(value);
              });
            },
          ),
        ),
        WarningWidget(
          name: widget.title,
          showError: widget.showError,
          errorMessage: widget.errorMessage,
        ),
      ],
    );
  }
}

class NameField extends StatefulWidget {
  const NameField({Key? key, required this.showError}) : super(key: key);
  final bool showError;

  @override
  State<NameField> createState() => _NameFieldState();
}

class _NameFieldState extends State<NameField> {
  @override
  Widget build(BuildContext context) {
    return TextInputField(
        title: "Name",
        initialValue: UserData.name,
        onChanged: (name) {
          if (name == "") {
            setState(() {
              UserData.name = null;
            });
          } else {
            setState(() {
              UserData.name = name;
            });
          }
        },
        showError: widget.showError && UserData.name == null
    );
  }
}

class BioField extends StatefulWidget {
  const BioField({Key? key, required this.showError}) : super(key: key);
  final bool showError;

  @override
  State<BioField> createState() => _BioFieldState();
}

class _BioFieldState extends State<BioField> {
  @override
  Widget build(BuildContext context) {
    return TextInputField(
        title: "Bio",
        maxLines: 6,
        initialValue: UserData.bio,
        onChanged: (bio) {
          if (bio == "") {
            setState(() {
              UserData.bio = null;
            });
          } else {
            setState(() {
              UserData.bio = bio;
            });
          }
        },
        showError: widget.showError && UserData.bio == null,
    );
  }
}


