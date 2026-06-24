String formatMinutesShort(num totalMinutes) {
  final minutesInt = totalMinutes.round();
  if (minutesInt <= 0) return '0 phút';
  final hours = minutesInt ~/ 60;
  final minutes = minutesInt % 60;
  if (hours == 0) return '$minutes phút';
  if (minutes == 0) return '$hours giờ';
  return '${hours}h ${minutes}p';
}

String formatStopwatch(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  final seconds = duration.inSeconds.remainder(60);
  if (hours > 0) {
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }
  return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
}
