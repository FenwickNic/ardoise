import 'package:ardoise/model/firebase/fund_user.dart';
import 'package:ardoise/ui/admin/admin_user_details_arguments.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UserTile extends StatelessWidget {
  final FundUser user;
  const UserTile({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: Text(user.fullname),
      subtitle: Text(user.email),
      leading: CircleAvatar(
        child: Text(user.defaultAvatar),
      ),
    onTap: (){ Navigator.pushNamed(
    context,
    '/admin/users/details',
    arguments: AdminUserDetailsArguments(user: user),
    );
    });
  }
}
