import 'package:intl/intl.dart';

/// Combines a calendar date (year/month/day) with a time slot string like
/// "11:00 AM" into one correct DateTime — needed because appointment dates
/// and time slots were previously stored disconnected from each other,
/// causing incorrect past-time booking and auto-completion behavior.
DateTime combineDateAndTimeSlot(DateTime date, String timeSlot) {
  final parsedTime = DateFormat('h:mm a').parse(timeSlot);
  return DateTime(date.year, date.month, date.day, parsedTime.hour, parsedTime.minute);
}