String greetingForNow() {
  final hour = DateTime.now().hour;
  if (hour < 11) return 'Chào buổi sáng 🌸';
  if (hour < 18) return 'Chào buổi chiều';
  return 'Chào buổi tối';
}

String formatBabyAge(DateTime dateOfBirth) {
  final now = DateTime.now();
  var months = (now.year - dateOfBirth.year) * 12 + now.month - dateOfBirth.month;
  var days = now.day - dateOfBirth.day;
  if (days < 0) {
    months -= 1;
    final prevMonth = DateTime(now.year, now.month - 1, dateOfBirth.day);
    days = now.difference(prevMonth).inDays;
  }
  if (months <= 0 && days <= 0) return 'Mới sinh';
  final parts = <String>[];
  if (months > 0) parts.add('$months tháng');
  if (days > 0) parts.add('$days ngày');
  return parts.join(' ');
}

String formatTime(DateTime time) {
  return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
}

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

DateTime startOfDay(DateTime date) => DateTime(date.year, date.month, date.day);
