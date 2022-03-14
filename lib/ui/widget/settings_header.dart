import 'package:flutter/material.dart';

class SettingsHeader extends StatelessWidget {
  final String title;
  const SettingsHeader({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.only(left:30, right:30, bottom: 10),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: const TextStyle(
                    fontSize: 30,
                  )),
              IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () { Scaffold.of(context).openDrawer(); }
              )
            ])
    );
  }
}
