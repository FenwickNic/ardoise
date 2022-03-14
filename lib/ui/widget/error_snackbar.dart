import 'package:ardoise/model/common/app_error.dart';
import 'package:flutter/material.dart';

class ErrorSnackBar extends SnackBar{
  final AppError error;
  ErrorSnackBar({Key? key, required this.error}) : super(key: key,
    backgroundColor: Colors.red,
    content: ListTile(
      title: Text(error.message),
      subtitle: Text(error.description),
    )
  );
}
