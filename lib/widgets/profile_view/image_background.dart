import 'package:flutter/material.dart';
import 'package:rendezvous_beta_v3/widgets/profile_view/photo_bar.dart';
import '../../constants.dart';


class ImageBackground extends StatefulWidget {
  const ImageBackground(
      {Key? key,
      required this.isExpanded,
      required this.userPhotos,
      required this.activeIndex,
      required this.onTapDown,
      required this.onTapUp,})
      : super(key: key);
  final bool isExpanded;
  final List<String> userPhotos;
  final int activeIndex;
  final void Function(TapDownDetails) onTapDown;
  final void Function(TapUpDetails) onTapUp;

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

  Widget get images => Image.network(widget.userPhotos[widget.activeIndex], fit: BoxFit.cover);

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
    if (widget.userPhotos.isNotEmpty) {
      cacheImages();
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTapDown,
      onTapUp: widget.onTapUp,
      child: applyImageGradient(imageStack),
    );
  }
}