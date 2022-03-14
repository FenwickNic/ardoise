import 'package:ardoise/model/common/app_error.dart';
import 'package:flutter/material.dart';

class ErrorPage extends StatelessWidget {
  final AppError error;
  const ErrorPage({Key? key, required this.error}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text(error.message),
          Text(error.description)
        ],
      )
    );
  }
}
