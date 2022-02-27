import 'package:ardoise/ui/account/account_page.dart';
import 'package:ardoise/ui/account/account_page_arguments.dart';
import 'package:ardoise/ui/admin/admin_user_details_arguments.dart';
import 'package:ardoise/ui/authentication/user_page.dart';
import 'package:ardoise/ui/transaction/transaction_amount_page.dart';
import 'package:ardoise/ui/transaction/transaction_description_page.dart';
import 'package:ardoise/ui/transaction/transaction_details_page.dart';
import 'package:ardoise/ui/transaction/transaction_page_arguments.dart';
import 'package:ardoise/ui/transaction/transaction_account_page.dart';
import 'package:ardoise/ui/admin/admin_user_details_page.dart';
import 'package:ardoise/ui/admin/admin_user_list_page.dart';
import 'package:ardoise/ui/authentication/signin_page.dart';
import 'package:ardoise/ui/transaction/transaction_summary_page.dart';
import 'package:ardoise/ui/transaction/transaction_type_page.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'firebase_options.dart';
import 'model/firebase/fund_user.dart';
import 'model/viewmodel/transactionlist_viewmodel.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate],
        supportedLocales: [Locale('fr', 'FR')],
        locale: Locale('fr', 'FR'),
        title: 'Flutter Demo',
        theme: ThemeData(
          scaffoldBackgroundColor: Color.fromRGBO(20, 33, 61, 100),
          primaryColor: Colors.white,
          backgroundColor: Colors.black,
          colorScheme: const ColorScheme(
            brightness: Brightness.dark,
            background: Colors.black,
            onBackground: Colors.white,
            primary: Colors.white,
            primaryVariant: Colors.white,
            onPrimary: Colors.black,
            secondary: Colors.pink,
            secondaryVariant: Colors.green,
            onSecondary: Colors.white,
            surface: Colors.white,
            onSurface: Colors.black,
            error: Colors.transparent,
            onError: Colors.pink,
          ),
        ),
        initialRoute: '/',
        onGenerateRoute: (settings){
          switch(settings.name){
            case '/home':
              String accountId = (settings.arguments as AccountPageArguments).accountId;
              return MaterialPageRoute(builder: (context) => AccountPage(accountId: accountId));
            case '/transaction/type':
              String accountId = (settings.arguments as AccountPageArguments).accountId;
              return MaterialPageRoute(builder: (context) => TransactionTypePage(accountId: accountId));
            case '/transaction/account':
              TransactionAccountPageArguments transaction = (settings.arguments as TransactionAccountPageArguments);
              return MaterialPageRoute(builder: (context) => TransactionAccountPage(transaction: transaction));
            case '/transaction/amount':
              TransactionAmountPageArguments transaction = (settings.arguments as TransactionAmountPageArguments);
              return MaterialPageRoute(builder: (context) => TransactionAmountPage(transaction: transaction));
            case '/transaction/description':
              TransactionDescriptionPageArguments transaction = (settings.arguments as TransactionDescriptionPageArguments);
              return MaterialPageRoute(builder: (context) => TransactionDescritpionPage(transaction: transaction));
            case  '/transaction/summary':
              TransactionPageArguments transaction = (settings.arguments as TransactionPageArguments);
              return MaterialPageRoute(builder: (context) => TransactionSummaryPage(transaction: transaction));
            case  '/transaction/details':
              TransactionTileViewModel transaction = (settings.arguments as TransactionTileViewModel);
              return MaterialPageRoute(builder: (context) => TransactionDetailsPage(transaction: transaction));
            case '/user/details':
              FundUser user = (settings.arguments as FundUser);
              return MaterialPageRoute(builder: (context) => UserPage(user: user));
            case '/admin/users/details':
              AdminUserDetailsArguments user = settings.arguments as AdminUserDetailsArguments;
              return MaterialPageRoute(builder: (context) => AdminUserDetails(arguments: user));

          }
        },
        routes: {
          '/':(context) => const SignInPage(),
          '/admin/users': (context) => const AdminUserList(),
        });
  }
}