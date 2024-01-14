import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class aVLMESSLoading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.teal[100],
      child: Center(
        child: SpinKitFadingCircle(
          color: Colors.blue,
          size: 100.0,
        ),
      ),
    );
  }
}
