import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rendezvous_beta_v3/widgets/profile_view/photo_bar.dart';
import '../../constants.dart';


class ImageBackground extends StatefulWidget {
  const ImageBackground(
      {Key? key,
      required this.isExpanded,
      required this.userPhotos,
      required this.activeIndex,
      required this.onTapDown,
      required this.onTapUp,
      this.onDragStart,
      this.onDragUpdate,
      this.onDragCancel,
      this.onDragEnd})
      : super(key: key);
  final bool isExpanded;
  final List userPhotos;
  final int activeIndex;
  final void Function(TapDownDetails) onTapDown;
  final void Function(TapUpDetails) onTapUp;
  final void Function(DragStartDetails)? onDragStart;
  final void Function(DragUpdateDetails)? onDragUpdate;
  final void Function()? onDragCancel;
  final void Function(DragEndDetails)? onDragEnd;

  @override
  _ImageBackgroundState createState() => _ImageBackgroundState();
}

class _ImageBackgroundState extends State<ImageBackground> {

  Widget applyImageGradient(Widget child) => ShaderMask(
      blendMode: BlendMode.darken,
      shaderCallback: (bounds) {
        return LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              widget.isExpanded ? kDarkTransparent : Colors.transparent,
              widget.isExpanded ? Colors.black87 : Colors.black54
            ]).createShader(bounds);
      },
    child: child,
      );

  Widget get images {
    if (widget.userPhotos is List<XFile?>) {
      List<XFile?> userImages = [];
      for (XFile? image in widget.userPhotos) {
        if (image != null) {
          userImages.add(image);
        }
      }
      return userImages.isNotEmpty
          ? Image(
              image: FileImage(File(userImages[widget.activeIndex]!.path)),
              fit: BoxFit.cover,
            )
          : Container();
    } else if (widget.userPhotos is List<String>) {
      return Image.network(widget.userPhotos[widget.activeIndex], fit: BoxFit.cover);
    }
    return Container();
  }

  Widget get imageStack => Stack(
    fit: StackFit.expand,
        children: [
          images,
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: PhotoBar(
                  activeIndex: widget.activeIndex,
                  length: widget.userPhotos.length),
            ),
          )
        ],
      );

  void cacheImages() {
    for (String imagePath in widget.userPhotos) {
      final image = Image.network(imagePath, fit: BoxFit.cover);
      precacheImage(image.image, context);
    }
  }


  @override
  void didChangeDependencies() {
    if (widget.userPhotos[0] is String) {
      cacheImages();
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTapDown,
      onTapUp: widget.onTapUp,
      onHorizontalDragStart: widget.onDragStart,
      onHorizontalDragUpdate: widget.onDragUpdate,
      onHorizontalDragCancel: widget.onDragCancel,
      onHorizontalDragEnd: widget.onDragEnd,
      child: applyImageGradient(imageStack),
    );
  }
}
