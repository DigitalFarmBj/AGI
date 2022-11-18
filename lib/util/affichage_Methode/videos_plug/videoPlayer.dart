
import 'package:flutter/material.dart';

import 'package:video_player/video_player.dart';

import 'videoPlay.dart';

class ShowVideo extends StatefulWidget {
  final String vidUrl;

  const ShowVideo({Key? key, required this.vidUrl}) : super(key: key);

  @override
  State<ShowVideo> createState() => _ShowVideoState();
}

class _ShowVideoState extends State<ShowVideo> {
  late VideoPlayerController _controller;
  //final textController = TextEditingController(text: widget.vidUrl);
  Duration position = Duration();
  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.vidUrl)
      ..addListener(() => setState(() {}))
      ..setLooping(true)
      ..initialize().then((_) => _controller.play());
    _controller.seekTo(position);
  }

  void buttonPressed() {
    if (_controller != null) {
      setState(() {
        _controller.value.isPlaying ? _controller.pause() : _controller.play();
      });
    }
  }

  @override
  Widget build(BuildContext context) => Container(
        alignment: Alignment.topCenter,
        child: Column(
          children: [
            VideoPlayerWidget(controller: _controller),
          ],
        ),
      );
}
