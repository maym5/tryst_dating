import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rendezvous_beta_v3/dialogues/error_dialogue.dart';
import 'dart:io';
import 'package:reorderable_grid/reorderable_grid.dart';
import 'package:provider/provider.dart';
import '../../constants.dart';
import '../../models/user_images.dart';
import '../field_title.dart';
import '../warning_widget.dart';

class GridBox extends StatefulWidget {
  const GridBox({Key? key, required this.index, required this.images})
      : super(key: key);
  final int index;
  final UserImages images;

  @override
  _GridBoxState createState() => _GridBoxState();
}

class _GridBoxState extends State<GridBox> {
  bool get _containsUserImage => UserImages.userImages[widget.index] != null;

  Widget? get _image {
    var image = UserImages.userImages[widget.index];
    if (image != null) {
      if (image.runtimeType == String) {
        return ClipRRect(
          borderRadius: kBorderRadius,
          child: Image.network(image, fit: BoxFit.cover),
        );
      } else if (image.runtimeType == XFile) {
        return ClipRRect(
          borderRadius: kBorderRadius,
          child: Image(
            image: FileImage(File(image.path)),
            fit: BoxFit.fill,
          ),
        );
      }
    }
    return null;
  }

  void _onPressed() {
    if (_containsUserImage) {
      widget.images.deleteImage(widget.index);
    } else {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return PhotoPickerBottomSheet(
              images: widget.images, index: widget.index);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          // the stack sizes itself off this container since its non-positioned
          height: 175,
          width: 100,
          color: Colors.transparent,
        ),
        Positioned(
          left: 15,
          top: 10,
          child: Container(
            height: 150,
            width: 100,
            decoration: BoxDecoration(
              color: kGreyWithAlpha,
              borderRadius: kBorderRadius,
            ),
            child: _image,
          ),
        ),
        PhotoPickerButton(
          containsUserImage: _containsUserImage,
          onPressed: _onPressed,
        )
      ],
    );
  }
}

class PhotoPickerButton extends StatelessWidget {
  const PhotoPickerButton(
      {Key? key, required this.containsUserImage, required this.onPressed})
      : super(key: key);
  final bool containsUserImage;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        alignment: Alignment.center,
        height: 35,
        width: 45,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: kButtonGradient,
        ),
        child: containsUserImage ? kDeleteIcon : kAddIcon,
      ),
    );
  }
}

class CustomBottomSheet extends StatelessWidget {
  // give its own file ?
  const CustomBottomSheet(
      {Key? key,
      required this.iconOne,
      required this.iconTwo,
      required this.titleOne,
      this.tileOneIconColor,
      required this.titleTwo,
      required this.onTileOneTap,
        this.tileColor,
      required this.onTileTwoTap,
        this.popTileTwo = true
      })
      : super(key: key);
  final IconData iconOne;
  final IconData iconTwo;
  final String titleOne;
  final Color? tileOneIconColor;
  final String titleTwo;
  final void Function() onTileOneTap;
  final void Function() onTileTwoTap;
  final Color? tileColor;
  final bool popTileTwo;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kTileBackGroundColor,
      child: Wrap(
        children: <ListTile>[
          ListTile(
            tileColor: tileColor,
            leading: Icon(iconOne, color: tileOneIconColor ?? kOffWhite),
            title: Text(
              titleOne,
              style: kTextStyle.copyWith(
                  color: tileOneIconColor ?? kOffWhite, fontSize: 15),
            ),
            onTap: () {
              onTileOneTap();
              Navigator.pop(context);
            },
          ),
          ListTile(
            tileColor: tileColor,
            leading: Icon(iconTwo, color: kOffWhite),
            title: Text(titleTwo, style: kTextStyle.copyWith(fontSize: 15)),
            onTap: () {
              onTileTwoTap();
              popTileTwo ? Navigator.pop(context) : null;
            },
          )
        ],
      ),
    );
  }
}

class PhotoPickerBottomSheet extends StatelessWidget {
  const PhotoPickerBottomSheet(
      {Key? key, required this.images, required this.index})
      : super(key: key);
  final UserImages images;
  final int index;

  @override
  Widget build(BuildContext context) {
    return CustomBottomSheet(
      iconOne: Icons.photo_library,
      iconTwo: Icons.photo_camera,
      titleOne: "Photo from gallery",
      titleTwo: "Photo from camera",
      tileColor: kPopUpColor,
      onTileOneTap: () {
        try {
          images.addImages(index);
        } catch (e) {
          showGeneralDialog(
              context: context,
              pageBuilder: (context, animation, _) =>
                  ErrorDialogue(animation: animation));
        }
      },
      onTileTwoTap: () {
        try {
          images.addImageFromCamera(index);
        } catch (e) {
          showGeneralDialog(
              context: context,
              pageBuilder: (context, animation, _) =>
                  ErrorDialogue(animation: animation));
        }
      },
    );
  }
}

class PhotoPicker extends StatefulWidget {
  const PhotoPicker(
      {Key? key,
      this.physics = const NeverScrollableScrollPhysics(),
      required this.showError})
      : super(key: key);
  final ScrollPhysics physics;
  final bool showError;

  @override
  _PhotoPickerState createState() => _PhotoPickerState();
}

class _PhotoPickerState extends State<PhotoPicker> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const FieldTitle(
          "Add Photos",
        ),
        ChangeNotifierProvider<UserImages>(
          create: (context) => UserImages(),
          builder: (context, _) {
            return Consumer<UserImages>(
              builder: (context, UserImages images, _) => Theme(
                data: ThemeData(canvasColor: Colors.transparent),
                child: Column(
                  children: [
                    ReorderableGridView.builder(
                      shrinkWrap: true,
                      physics: widget.physics,
                      onReorder: images.reorderImages,
                      gridDelegate: kImagePickerGridDelegate,
                      itemBuilder: (context, index) => GridBox(
                          key: ValueKey(index), index: index, images: images),
                      itemCount: 9,
                    ),
                    WarningWidget(
                        showError:
                            widget.showError && UserImages.showImageError(),
                        name: "Photo Picker")
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
