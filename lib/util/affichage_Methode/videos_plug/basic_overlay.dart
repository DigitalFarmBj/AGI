import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class BasicOverlayer extends StatelessWidget {
  final VideoPlayerController controller;
  const BasicOverlayer({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () =>
            controller.value.isPlaying ? controller.pause() : controller.play(),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            buildPlay(),
            Positioned(bottom: 0, left: 0, right: 0, child: builIndicator())
          ],
        ),
      );
  Widget builIndicator() =>
      VideoProgressIndicator(controller, allowScrubbing: true);
  Widget buildPlay() => controller.value.isPlaying
      ? Container()
      : Container(
          alignment: Alignment.center,
          color: Colors.black26,
          child: const Icon(
            Icons.play_arrow,
            color: Colors.white,
            size: 80,
          ),
        );
}
