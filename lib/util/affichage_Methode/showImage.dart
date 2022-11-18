import 'package:flutter/material.dart';

class ShowImage extends StatelessWidget {
  final String imageUrl;

  const ShowImage({required this.imageUrl, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Center(
        child: Container(
          height: size.height,
          width: size.width,
          color: Color.fromARGB(183, 43, 97, 16),
          child: Image.network(imageUrl),
        ),
      ),
    );
  }
}
