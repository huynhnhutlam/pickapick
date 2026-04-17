extension TimeStringExtension on String {
  /// Chuyển "HH:mm" thành tổng số phút trong ngày
  /// Ví dụ: "08:30" → 510
  int toMinutes() {
    final parts = split(':');
    if (parts.length != 2) return 0;

    final hours = int.tryParse(parts[0]) ?? 0;
    final minutes = int.tryParse(parts[1]) ?? 0;

    return hours * 60 + minutes;
  }
}
