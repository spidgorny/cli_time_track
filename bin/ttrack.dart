import 'dart:core';
import 'dart:io';

import 'package:date_calendar/date_calendar.dart';
import 'package:duration/duration.dart';
import 'package:yaml/yaml.dart';

const dow = ['00', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];

bool asSpellout = false;
bool asTime = true;
bool asHours = false;

Future<void> main(List<String> args) async {
  var timeFile = (args.length > 0 && args[0] != null) ? args[0] : 'time.yaml';
  asSpellout = args.contains('--asSpellout');
  asTime = args.contains('--asTime');
  asHours = args.contains('--asHours');
  print('Loading ' + timeFile);
  var yaml = await new File(timeFile).readAsString();
  // print(yaml);
  var doc = loadYaml(yaml);
  // print(doc);
  var perDay = getSumHoursPerDay(doc);
  var g = GregorianCalendar.now();
  var monday = g.addDays(-(g.weekday - 1)); // monday
  var lastWeek = monday.addWeeks(-1);
  printWeek(perDay, lastWeek);
  printWeek(perDay, monday);
  printMonth(perDay);
}

Map<Calendar, Duration> getSumHoursPerDay(YamlList doc) {
  Map<Calendar, Duration> map = {};
  for (YamlMap day in doc) {
    // print('Day: ' + day.keys.first);
    var yamlEntries = day[day.keys.first];
    if (yamlEntries == null) {
      continue;
    }
    var entries = List.from(yamlEntries);
    // print(entries);
    Duration hours = entries.fold(Duration(), (Duration acc, map) {
      var mmap = Map.from(map);
      Duration dur = parseDurationOrRange(mmap.keys.first.toString());
      // print(['-', mmap.keys.first, dur.inMinutes]);
      return acc + dur;
    });
    //print(prettyDuration(hours));
    var dt = DateTime.parse(day.keys.first);
    map[GregorianCalendar.fromDateTime(dt)] = hours;
  }
  return map;
}

Duration parseDurationOrRange(String source) {
  Duration dur = Duration();
  if (source.toString().startsWith('[')) {
    // print(['>', source]);
    RegExp exp = new RegExp(r"\[(\d\d):(\d\d)\s?-\s?(\d\d):(\d\d)\]");
    List<RegExpMatch> matches = exp.allMatches(source).toList();
    if (matches == null || matches.isEmpty) {
      print("Unable to parse duration here: " + source);
      return dur;
    }
    var match0 = matches.elementAt(0);
    var from_h = int.parse(match0.group(1));
    var from_m = int.parse(match0.group(2));
    var till_h = int.parse(match0.group(3));
    var till_m = int.parse(match0.group(4));
    // print([from_h, from_m, till_h, till_m]);
    DateTime f = DateTime(2000, 1, 1, from_h, from_m);
    DateTime t = DateTime(2000, 1, 1, till_h, till_m);
    dur = Duration(minutes: t.hour * 60 + t.minute - f.hour * 60 - f.minute);
  } else {
    dur = parseDuration(source);
  }
  return dur;
}

void printWeek(Map<Calendar, Duration> perDay, Calendar monday) {
  print('Week ' + weekNumber(monday).toString() + ' (daily):');
  for (int i = 0; i < 7; i++) {
    var day = monday.addDays(i);
    var weekDay = dow[day.weekday];
    Duration dur = perDay[day] != null ? perDay[day] : Duration();
    String hours = dur.inMinutes > 0 ? printDur(dur) : '--:--';
    String chart = '▉' * (dur.inMinutes ~/ 10);
    chart = splitStringByLength(chart, 6).join(' ');
    print([day.toString(), weekDay, hours, chart].join('\t'));
  }
  print('');
}

/// https://stackoverflow.com/questions/61508277/dart-flutter-split-string-every-nth-character?rq=1
List<String> splitStringByLength(String str, int length) {
  RegExp exp = new RegExp(r".{" + "$length" + "}");
  Iterable<Match> matches = exp.allMatches(str);
  var list = matches.map((m) => m.group(0));
  // print([str.length, length, str.length % length]);
  return list.toList()..add(str.substring(str.length - str.length % length));
}

/// https://stackoverflow.com/questions/49393231/how-to-get-day-of-year-week-of-year-from-a-datetime-dart-object
int weekNumber(Calendar date) {
  return ((date.dayOfYear - date.weekday + 10) / 7).floor();
}

void printMonth(Map<Calendar, Duration> perDay) {
  print('Current month (weekly):');
  var g = GregorianCalendar.now();
  var first = GregorianCalendar(g.year, g.month, 1);
  Map<int, Duration> weeks = {};
  for (int i = 0; i < first.monthLength; i++) {
    var day = first.addDays(i);
    if (perDay[day] != null) {
      var weekNr = weekNumber(day);
      var hours = weeks[weekNr] ?? Duration();
      weeks[weekNr] = hours + perDay[day];
    }
  }

  for (int weekNr in weeks.keys) {
    var dur = weeks[weekNr];
    String chart = '▉' * (dur.inMinutes ~/ 15);
    chart = splitStringByLength(chart, 4).join(' ');
    print(['W' + weekNr.toString(), printDur(dur), chart].join('\t'));
  }
}

String printDur(Duration dur) {
  if (asSpellout) {
    return printDuration(dur);
  } else if (asHours) {
    return (dur.inMinutes / 60).toStringAsFixed(2) + 'h';
  } else {
    return dur.toString().substring(0, 4).padLeft(5, '0');
  }
}
