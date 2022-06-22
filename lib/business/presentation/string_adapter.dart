import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class StringAdapter{
  static String formatCurrency(BuildContext context, double value){
    Locale locale = Localizations.localeOf(context);
    NumberFormat currencyFormatter = NumberFormat.simpleCurrency(locale: locale.languageCode,decimalDigits: 2);
    return currencyFormatter.format(value);
  }

  static String formatDateLong(BuildContext context, DateTime date) {
    Locale locale = Localizations.localeOf(context);
    return DateFormat("EEE d MMM yyyy",locale.languageCode).format(date);
  }

  static String formatDateTimeLong(BuildContext context, DateTime date) {
    Locale locale = Localizations.localeOf(context);
    return DateFormat("EEE d MMM yyyy HH:mm:ss",locale.languageCode).format(date);
  }
}