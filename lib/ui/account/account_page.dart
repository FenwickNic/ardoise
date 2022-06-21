import 'package:ardoise/business/data/firebase_adapter.dart';
import 'package:ardoise/model/common/app_error.dart';
import 'package:ardoise/model/firebase/account.dart';
import 'package:ardoise/ui/account/account_page_arguments.dart';
import 'package:ardoise/ui/transaction/transaction_page_arguments.dart';
import 'package:ardoise/ui/widget/account_info.dart';
import 'package:ardoise/ui/widget/paid_transaction_list.dart';
import 'package:ardoise/ui/widget/app_drawer.dart';
import 'package:ardoise/ui/widget/pending_transaction_list.dart';
import 'package:ardoise/ui/widget/settings_header.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class AccountPage extends StatefulWidget {
  final AccountPageArguments arguments;
  const AccountPage({Key? key, required this.arguments}) : super(key: key);

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage>  with SingleTickerProviderStateMixin{
  int selectedIndex = 0;
  final FirebaseAdapter _database = FirebaseAdapter();

  final List<Widget> tabs = [
    Tab(text: 'Opérations passées'),
    Tab(text: 'Opérations à valider'),
  ];

  late TabController _tabController;
  late Future<Account> _account;

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _tabController = TabController(
        length: tabs.length,
        initialIndex: 0,
        vsync: this);
    _account = _database.fetchAccountById(widget.arguments.account);
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 100,
          title: Padding(
            padding: EdgeInsets.only(top: 10, bottom: 20, left: 10),
            child:
            Text("Mon Compte",
              style:
              Theme.of(context).textTheme.headline1,
            ),
          ),
            leading: null,
            actions: [
              Builder(builder: (context) {
                return IconButton(onPressed: () {Scaffold.of(context).openDrawer();}, icon: Icon(Icons.settings));
              })
            ],
            automaticallyImplyLeading: false,
            centerTitle: false
        ),
        drawer: AppDrawer(user: widget.arguments.user),
        floatingActionButton: FutureBuilder(
            future: _account,
            builder: (context, AsyncSnapshot<Account>snapshot){
              if(snapshot.connectionState == ConnectionState.done){
                return FloatingActionButton(
                    onPressed: () {
                      Navigator.pushNamed(context,
                          '/transaction/type',
                          arguments: TransactionTypePageArguments(user: widget.arguments.user, account: snapshot.data!));
                    },
                    child: const Icon(Icons.add)
                );
              }
              return Container();
            })
        ,
        backgroundColor: Theme.of(context).primaryColor,
        body:
        
        Builder(
            builder: (context) =>
                ListView(
                    children: [
                      FutureBuilder(
                        future: _account,
                        builder: (BuildContext context, AsyncSnapshot<Account> snapshot) {
                          if(snapshot.connectionState == ConnectionState.done){
                            if(snapshot.hasData){
                              return AccountInfo(account: snapshot.data!);
                            }else{
                              throw AppError(
                                  severity: ESeverityLevel.Critical,
                                  message: "Compte introuvable",
                                  description: "Une erreur critique nous empêche de retrouver votre compte veuillez nous contacter afin de nous aider à identifier ce problème."
                              );
                            }
                          }
                          return Shimmer.fromColors(
                              baseColor: Colors.grey[350]!,
                              highlightColor: Colors.grey[300]!,
                              child: const SizedBox(height: 100, width: 100,)
                          );
                        },
                      ),

                      TabBar(
                        controller: _tabController,
                        labelColor: Theme.of(context).primaryColor,
                        indicatorColor: Theme.of(context).primaryColor,
                        tabs: tabs,
                        onTap: (int index) {
                          setState(() {
                            selectedIndex = index;
                            _tabController.animateTo(index);
                          });
                        },
                      ),
                      FutureBuilder(
                          future: _account,
                          builder: (context, AsyncSnapshot<Account> snapshot) {
                            if (snapshot.connectionState == ConnectionState.done) {
                              if (snapshot.hasData) {
                                return [
                                  PaidTransactionList(
                                      user: widget.arguments.user,
                                      account: snapshot.data!
                                  ),
                                  PendingTransactionList(
                                      user: widget.arguments.user,
                                      account: snapshot.data!
                                  )
                                ][selectedIndex];
                              } else {
                                throw AppError(
                                    severity: ESeverityLevel.Critical,
                                    message: "Impossible d'afficher les opérations",
                                    description: "Une erreur nous empêche d'afficher les opérations sur votre compte."
                                );
                              }
                            }
                            return Center(child: CircularProgressIndicator());
                          })
                    ])
        ));
  }

}


