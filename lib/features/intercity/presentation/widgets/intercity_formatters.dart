// Role : Formatte dates, heures et prix en francais sans dependre de l'init locale intl.
const _kMonths = [
  'janv.',
  'févr.',
  'mars',
  'avr.',
  'mai',
  'juin',
  'juil.',
  'août',
  'sept.',
  'oct.',
  'nov.',
  'déc.',
];

const _kWeekdays = ['lun.', 'mar.', 'mer.', 'jeu.', 'ven.', 'sam.', 'dim.'];

String formatShortDate(DateTime date) {
  return '${date.day} ${_kMonths[date.month - 1]} ${date.year}';
}

/// Date courte sans année — ex. `25 juil.` (écran résultats).
String formatDayMonth(DateTime date) {
  return '${date.day} ${_kMonths[date.month - 1]}';
}

const _kMonthsLong = [
  'janvier',
  'février',
  'mars',
  'avril',
  'mai',
  'juin',
  'juillet',
  'août',
  'septembre',
  'octobre',
  'novembre',
  'décembre',
];

/// Date longue sans année — ex. `25 juillet` (empty state).
String formatDayMonthLong(DateTime date) {
  return '${date.day} ${_kMonthsLong[date.month - 1]}';
}

String formatWeekdayDate(DateTime date) {
  final weekday = _kWeekdays[date.weekday - 1];
  return '$weekday ${date.day} ${_kMonths[date.month - 1]}';
}

String formatPriceFcfa(double price) {
  return '${_formatGroupedNumber(price)} FCFA';
}

/// Prix compact Figma résultats — ex. `4 500 F`.
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
  if (hours > 0) return '${hours}h${minutes.toString().padLeft(2, '0')}';
  return '$minutes min';
}
