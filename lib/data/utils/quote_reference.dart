String buildQuoteNumber([DateTime? now]) {
  final stamp = now ?? DateTime.now();
  return 'QR-${stamp.year}${_two(stamp.month)}${_two(stamp.day)}-'
      '${_two(stamp.hour)}${_two(stamp.minute)}${_two(stamp.second)}';
}

String buildBookingReference([DateTime? now]) {
  final stamp = now ?? DateTime.now();
  return 'BK-${stamp.year}${_two(stamp.month)}${_two(stamp.day)}-'
      '${_two(stamp.hour)}${_two(stamp.minute)}${_two(stamp.second)}';
}

String _two(int value) => value.toString().padLeft(2, '0');
