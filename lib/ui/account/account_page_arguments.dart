import 'package:ardoise/model/firebase/account.dart';
import 'package:ardoise/model/firebase/fund_user.dart';

class AccountPageArguments{
  final String account;
  final FundUser user;

  AccountPageArguments({
    required this.user,
    required this.account});
}