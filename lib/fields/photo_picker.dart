import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../constants.dart';
import 'package:reorderable_grid/reorderable_grid.dart';
import 'package:provider/provider.dart';

import '../widgets/field_title.dart';
import '../cloud_functions/user_images.dart';
import '../widgets/warning_widget.dart';

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
    XFile? image = UserImages.userImages[widget.index];
    if (image != null) {
      return ClipRRect(
        borderRadius: kBorderRadius,
        child: Image(
          image: FileImage(File(image.path)),
          fit: BoxFit.fill,
        ),
      );
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
  const PhotoPickerButton({Key? key, required this.containsUserImage, required this.onPressed}) : super(key: key);
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
      this.tileOneColor,
      required this.titleTwo,
      required this.onTileOneTap,
      required this.onTileTwoTap})
      : super(key: key);
  final IconData iconOne;
  final IconData iconTwo;
  final String titleOne;
  final Color? tileOneColor;
  final String titleTwo;
  final void Function() onTileOneTap;
  final void Function() onTileTwoTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kTileBackGroundColor,
      child: Wrap(
        children: <ListTile>[
          ListTile(
            leading: Icon(iconOne, color: tileOneColor ?? kOffWhite),
            title: Text(
              titleOne,
              style: kTextStyle.copyWith(color: tileOneColor ?? kOffWhite, fontSize: 15),
            ),
            onTap: () {
              onTileOneTap();
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(iconTwo, color: kOffWhite),
            title: Text(titleTwo, style: kTextStyle.copyWith(fontSize: 15)),
            onTap: () {
              onTileTwoTap();
              Navigator.pop(context);
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
      onTileOneTap: () {
        images.addImages(index);
      },
      onTileTwoTap: () {
        images.addImageFromCamera(index);
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
                    WarningWidget(showError: widget.showError && UserImages.showImageError(), name: "Photo Picker")
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
