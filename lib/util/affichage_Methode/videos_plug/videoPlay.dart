
import 'package:flutter/material.dart';

import 'package:video_player/video_player.dart';

import 'basic_overlay.dart';

class VideoPlayerWidget extends StatelessWidget {
  final VideoPlayerController controller;
  const VideoPlayerWidget({Key? key, required this.controller})
      : super(key: key);
  @override
  Widget build(BuildContext context) =>
      controller != null && controller.value.isInitialized
          ? Container(
              alignment: Alignment.topCenter,
              child: Container(
                alignment: Alignment.topCenter,
                child: buildVideo(),
              ),
            )
          : Center(
              child: Container(
                alignment: Alignment.topCenter,
                height: 200,
                child: const Center(
                  child: const CircularProgressIndicator(),
                ),
              ),
            );
  Widget buildVideo() => Stack(
        alignment: Alignment.topCenter,
        children: [
          buildVideoPlayer(),
          Positioned.fill(child: BasicOverlayer(controller: controller))
        ],
      );
  Widget buildVideoPlayer() => AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: VideoPlayer(controller),
      );
}
