import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class AudioShowing extends StatefulWidget {
  final String audioUrl;
  final int code;

  const AudioShowing({Key? key, required this.audioUrl, required this.code})
      : super(key: key);

  @override
  State<AudioShowing> createState() => _AudioShowingState();
}

class _AudioShowingState extends State<AudioShowing>
    with SingleTickerProviderStateMixin {
  final audioPlayer = AudioPlayer();
  bool isPlaying = false;
  late AnimationController animCtrl;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  String formatTime(Duration duration) {
    String toDigits(int n) => n.toString().padLeft(2, '0');
    final hours = toDigits(duration.inHours);
    final minutes = toDigits(duration.inMinutes.remainder(60));
    final secondes = toDigits(duration.inSeconds.remainder(60));
    return [
      if (duration.inHours > 0) hours,
      minutes,
      secondes,
    ].join(':');
  }

  @override
  void initState() {
    super.initState();
    animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));

    audioPlayer.onPlayerStateChanged.listen((event) {
      setState(() {
        isPlaying = event == PlayerState.PLAYING;
      });
    });
    audioPlayer.onDurationChanged.listen((duree) {
      setState(() {
        duration = duree;
      });
    });
    audioPlayer.onAudioPositionChanged.listen((posi) {
      setState(() {
        position = posi;
      });
    });
  }

  @override
  void dispose() {
    animCtrl.dispose();
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int onPress = widget.code;
    return Container(
      child: Row(
        children: <Widget>[
          CircleAvatar(
            backgroundColor: Colors.white,
            radius: 35,
            child: IconButton(
              onPressed: () async {
                if (onPress == widget.code) {
                  if (isPlaying) {
                    await audioPlayer.pause();
                  } else {
                    String url = widget.audioUrl;
                    await audioPlayer.play(url);
                  }
                } else {
                  await audioPlayer.pause();
                }
              },
              icon: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                color: const Color.fromARGB(183, 43, 97, 16),
                size: 30,
              ),
              iconSize: 30,
            ),
          ),
          const SizedBox(
            width: 10.0,
          ),
          Slider(
              activeColor: const Color.fromARGB(183, 43, 97, 16),
              inactiveColor: const Color.fromARGB(183, 43, 97, 16),
              min: 0,
              max: duration.inSeconds.toDouble(),
              value: position.inSeconds.toDouble(),
              onChanged: (value) async {
                if (onPress == widget.code) {
                  final position = Duration(seconds: value.toInt());
                  await audioPlayer.seek(position);
                }
              }),
        ],
      ),
    );
  }
}
