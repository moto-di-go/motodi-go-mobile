f = r'D:\Projects\moto-di-go\motodi-go-mobile\lib\features\intercity\presentation\widgets\intercity_formatters.dart'
with open(f, 'r', encoding='utf-8') as fh:
    c = fh.read()

new_content = '''import 'package:flutter/widgets.dart';

// Role : Formatte dates, heures et prix avec support FR/EN sans dependre de l'init locale intl.
const _kMonthsFr = [
  'janv.', 'f\u00e9vr.', 'mars', 'avr.', 'mai', 'juin',
  'juil.', 'ao\u00fbt', 'sept.', 'oct.', 'nov.', 'd\u00e9c.',
];

const _kMonthsEn = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

const _kWeekdaysFr = ['lun.', 'mar.', 'mer.', 'jeu.', 'ven.', 'sam.', 'dim.'];
const _kWeekdaysEn = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

const _kMonthsLongFr = [
  'janvier', 'f\u00e9vrier', 'mars', 'avril', 'mai', 'juin',
  'juillet', 'ao\u00fbt', 'septembre', 'octobre', 'novembre', 'd\u00e9cembre',
];

const _kMonthsLongEn = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

List<String> _months(BuildContext? context) {
  if (context != null && Localizations.localeOf(context).languageCode == 'en') return _kMonthsEn;
  return _kMonthsFr;
}

List<String> _monthsLong(BuildContext? context) {
  if (context != null && Localizations.localeOf(context).languageCode == 'en') return _kMonthsLongEn;
  return _kMonthsLongFr;
}

List<String> _weekdays(BuildContext? context) {
  if (context != null && Localizations.localeOf(context).languageCode == 'en') return _kWeekdaysEn;
  return _kWeekdaysFr;
}

String formatShortDate(DateTime date, {BuildContext? context}) {
  return '${date.day} ${_months(context)[date.month - 1]} ${date.year}';
}

/// Date courte sans ann\u00e9e \u2014 ex. `25 juil.` / `25 Jul`.
String formatDayMonth(DateTime date, {BuildContext? context}) {
  return '${date.day} ${_months(context)[date.month - 1]}';
}

/// Date longue sans ann\u00e9e \u2014 ex. `25 juillet` / `25 July`.
String formatDayMonthLong(DateTime date, {BuildContext? context}) {
  return '${date.day} ${_monthsLong(context)[date.month - 1]}';
}

String formatWeekdayDate(DateTime date, {BuildContext? context}) {
  final weekday = _weekdays(context)[date.weekday - 1];
  return '$weekday ${date.day} ${_months(context)[date.month - 1]}';
}

String formatPriceFcfa(double price) {
  return '${_formatGroupedNumber(price)} FCFA';
}

/// Prix compact Figma r\u00e9sultats \u2014 ex. `4 500 F`.
String formatPriceF(double price) {
  return '${_formatGroupedNumber(price)} F';
}

String _formatGroupedNumber(double price) {
  final rounded = price.round();
  final text = rounded.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < text.length; i++) {
    if (i > 0 && (text.length - i) % 3 == 0) buffer.write(' ');
    buffer.write(text[i]);
  }
  return buffer.toString();
}

String formatDuration(Duration duration) {
  if (duration.isNegative) return '0 min';
  final hours = duration.inHours;
  final minutes = duration.inMinutes % 60;
  if (hours > 0) return '${hours}h${minutes.toString().padLeft(2, \\'0\\')}';
  return '$minutes min';
}

/// Horodatage relatif Figma timeline \u2014 ex. `Aujourd\\'hui \u2022 08:14` / `Today \u2022 08:14`.
String formatRelativeDayTime(DateTime date, {BuildContext? context}) {
  final local = date.toLocal();
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(local.year, local.month, local.day);
  final time =
      '${local.hour.toString().padLeft(2, \\'0\\')}:${local.minute.toString().padLeft(2, \\'0\\')}';
  final isEn = context != null && Localizations.localeOf(context).languageCode == 'en';
  if (day == today) return isEn ? 'Today \u2022 $time' : "Aujourd\\'hui \u2022 $time";
  if (day == today.subtract(const Duration(days: 1))) return isEn ? 'Yesterday \u2022 $time' : 'Hier \u2022 $time';
  return '${formatDayMonth(local, context: context)} \u2022 $time';
}
'''

# Actually, let me write it properly without escaped quotes issues
with open(f, 'w', encoding='utf-8') as fh:
    fh.write(c)  # restore original for now

print("Will use StrReplace instead")
