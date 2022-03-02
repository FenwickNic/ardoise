import 'package:ardoise/model/common/app_error.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ErrorSnackBar extends SnackBar{
  final AppError error;
  ErrorSnackBar({required this.error}) : super(
    backgroundColor: Colors.red,
    content: ListTile(
      title: Text(error.message),
      subtitle: Text(error.description),
    )
  );
}
