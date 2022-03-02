import 'package:ardoise/ui/_common/error_page.dart';
import 'package:ardoise/ui/account/account_page.dart';
import 'package:ardoise/ui/account/account_page_arguments.dart';
import 'package:ardoise/ui/account/account_pending_page.dart';
import 'package:ardoise/ui/account/home_page.dart';
import 'package:ardoise/ui/admin/admin_user_details_arguments.dart';
import 'package:ardoise/ui/authentication/forgot_email_page.dart';
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
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'firebase_options.dart';
import 'model/common/app_error.dart';
import 'model/firebase/fund_user.dart';
import 'model/viewmodel/transactiondetails_viewmodel.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  //Initialise the connection to the database
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  //Prevent phone rotation
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown]);

  //Log Reporting
  await SentryFlutter.init(
        (options) {
      options.dsn = 'https://19baa07740e741baa28d85aa627d811c@o1157022.ingest.sentry.io/6238946';
      options.tracesSampleRate = 1.0;
    },
    appRunner: () => runApp(MonArdoiseApp()),
  );
}

class MonArdoiseApp extends StatelessWidget {
  const MonArdoiseApp({Key? key}) : super(key: key);

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
          appBarTheme: const AppBarTheme(
            elevation: 0,
            systemOverlayStyle: SystemUiOverlayStyle(
              //statusBarColor: Colors.white,
              statusBarIconBrightness: Brightness.dark,
              statusBarBrightness: Brightness.light,
            ),
          ),
          primaryColor: Color.fromRGBO(252, 163, 17, 1),
          colorScheme: const ColorScheme(
            brightness: Brightness.light,

            //Behind scrollable content.
            background: Color.fromRGBO(57, 160, 237, 1),
            onBackground: Colors.black,

            //Buttons
            primary: Color.fromRGBO(57, 160, 237, 1),
            primaryVariant: Colors.blue,
            onPrimary: Colors.white,

            //Filter clips
            secondary: Colors.pink,
            secondaryVariant: Colors.green,
            onSecondary: Colors.white,

            surface: Colors.red,
            onSurface: Colors.black,

            error: Colors.red,
            onError: Colors.pink,
          ),
          inputDecorationTheme: const InputDecorationTheme(
            isDense: true,


            errorBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.red)
            ),
            errorStyle: TextStyle(color: Colors.red),
          ),
          cardTheme: CardTheme(
            color: Color.fromRGBO(57, 160, 237, 1),
          ),
          textTheme: TextTheme(
            headline3: TextStyle(fontSize: 30, color: Colors.black, )
          ),
        ),

        initialRoute: '/',
        onGenerateRoute: (settings){
          switch(settings.name){
            case '/home':
              FundUser user = (settings.arguments as FundUser);
              return MaterialPageRoute(builder: (context) => HomePage(user: user));
            case '/account':
              AccountPageArguments arguments = (settings.arguments as AccountPageArguments);
              return MaterialPageRoute(builder: (context) => AccountPage(arguments: arguments));
            case '/account/pending':
              AccountPageArguments arguments = (settings.arguments as AccountPageArguments);
              return MaterialPageRoute(builder: (context) => AccountPendingPage(arguments: arguments));
            case '/transaction/type':
              AccountPageArguments arguments = (settings.arguments as AccountPageArguments);
              return MaterialPageRoute(builder: (context) => TransactionTypePage(arguments: arguments));
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
              TransactionDetailsViewModel transaction = (settings.arguments as TransactionDetailsViewModel);
              return MaterialPageRoute(builder: (context) => TransactionDetailsPage(transaction: transaction));
            case '/user/details':
              FundUser user = (settings.arguments as FundUser);
              return MaterialPageRoute(builder: (context) => UserPage(user: user));
            case '/admin/users':
              return MaterialPageRoute(builder: (context) => AdminUserList());
            case '/admin/users/details':
              AdminUserDetailsArguments user = settings.arguments as AdminUserDetailsArguments;
              return MaterialPageRoute(builder: (context) => AdminUserDetails(arguments: user));
            case '/forgot-email':
              return MaterialPageRoute(builder: (context) => ForgotEmailPage());
            case '/error':
              AppError error = settings.arguments as AppError;
              return MaterialPageRoute(builder: (context) => ErrorPage(error: error));
          }
        },
        routes: {
          '/':(context) => const SignInPage(),

        });
  }
}