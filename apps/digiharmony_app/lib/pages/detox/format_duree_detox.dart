/// Formate une duree en « X min Y s ».
String formatDureeDetox(Duration d) {
  final m = d.inMinutes;
  final s = d.inSeconds % 60;
  return '$m min $s s';
}
