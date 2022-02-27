import 'package:ardoise/business/data/firebase_adapter.dart';
import 'package:ardoise/model/firebase/fund_user.dart';
import 'package:ardoise/ui/admin/admin_user_details_arguments.dart';
import 'package:ardoise/ui/widget/app_drawer.dart';
import 'package:ardoise/ui/widget/user_tile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AdminUserList extends StatefulWidget {
  const AdminUserList({Key? key}) : super(key: key);

  @override
  _AdminUserListState createState() => _AdminUserListState();
}

class _AdminUserListState extends State<AdminUserList> {
  FirebaseAdapter _database = FirebaseAdapter();

  late Future<List<FundUser>> _userList;
  FundUser? _currentUser;

  @override
  void initState(){

    _userList = _database.fetchUserList();
    _database.fetchUserById(FirebaseAuth.instance.currentUser!.uid).then(
            (user) =>
            setState(() => _currentUser = user   )
    );

    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: _currentUser == null ?
        null :
        AppDrawer(user: _currentUser!),
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.pushNamed(
                  context,
                  '/admin/users/details',
                  arguments: AdminUserDetailsArguments(user: null)
              );
            },
            child: Icon(Icons.add)
        ),
        body:Builder(
    builder: (context) =>
        ListView(
          children: [
            _buildHeader(context),
            Text("Utilisateurs",
                style: Theme.of(context).textTheme.headline5
            ),
            FutureBuilder(
                future: _userList,
                builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  if(snapshot.hasData) {
                    List<FundUser> data = snapshot.data!;
                    return ListView.builder(
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(),
                        itemCount: data.length,
                        itemBuilder: (builder, index) {
                          return UserTile(user: data[index]);
                        });
                  }else{
                    return Text("Qui utilise l'application?");
                  }
                })
          ],
        )
    ));
  }
  Widget _buildHeader(BuildContext context){
    return Container(
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Bienvenue',
                  style: TextStyle(
                    fontSize: 30,
                  )),
              IconButton(
                  icon: Icon(Icons.settings),
                  onPressed: () { Scaffold.of(context).openDrawer(); }
              )
            ])
    );
  }
}
