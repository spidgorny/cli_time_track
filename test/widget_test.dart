// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:date_calendar/date_calendar.dart';

import '../bin/ttrack.dart';

void main() {
  test_weekNumber();
  test_parseDurationOrRange();
}

void test_weekNumber() {
  var g = GregorianCalendar(2020, 11, 01);
  var week = weekNumber(g);
  assert(week == 44);
}

void test_parseDurationOrRange() {
  assert(parseDurationOrRange('[09:30-10:00]') == Duration(minutes: 30));
}
