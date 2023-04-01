import 'package:flutter/material.dart';

class ImgItem extends StatelessWidget {
  final int index;
  final String url;
  final double width;
  const ImgItem({Key? key, required this.index, required this.url, required this.width}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Image.network(url,fit: BoxFit.cover,
        height: 242,
        width: width,
        alignment: Alignment.center,),
    );
  }
}
