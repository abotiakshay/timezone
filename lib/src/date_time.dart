part of timezone;

/// TimeZone aware DateTime
class TZDateTime implements DateTime {
  // Weekday constants that are returned by [weekday] method:
  static const int MONDAY = 1;
  static const int TUESDAY = 2;
  static const int WEDNESDAY = 3;
  static const int THURSDAY = 4;
  static const int FRIDAY = 5;
  static const int SATURDAY = 6;
  static const int SUNDAY = 7;
  static const int DAYS_PER_WEEK = 7;

  // Month constants that are returned by the [month] getter.
  static const int JANUARY = 1;
  static const int FEBRUARY = 2;
  static const int MARCH = 3;
  static const int APRIL = 4;
  static const int MAY = 5;
  static const int JUNE = 6;
  static const int JULY = 7;
  static const int AUGUST = 8;
  static const int SEPTEMBER = 9;
  static const int OCTOBER = 10;
  static const int NOVEMBER = 11;
  static const int DECEMBER = 12;
  static const int MONTHS_PER_YEAR = 12;

  Location _location;

  TimeZone _timeZone;

  /// Native [DateTime] is used as a Calendar object
  DateTime _localDateTime;

  int _millisecondsSinceEpoch = 0;

  /// The number of milliseconds since
  /// the "Unix epoch" 1970-01-01T00:00:00Z (UTC).
  ///
  /// This value is independent of the time zone.
  ///
  /// This value is at most
  /// 8,640,000,000,000,000ms (100,000,000 days) from the Unix epoch.
  /// In other words: [:millisecondsSinceEpoch.abs() <= 8640000000000000:].
  int get millisecondsSinceEpoch => millisecondsSinceEpoch;

  /// [Location]
  Location get location => _location;

  /// [TimeZone]
  TimeZone get timeZone => _location.timeZone(millisecondsSinceEpoch);

  /// True if this [TZDateTime] is set to UTC time.
  ///
  /// ```dart
  /// final dDay = new TZDateTime.utc(1944, 6, 6);
  /// assert(dDay.isUtc);
  /// ```
  ///
  bool get isUtc => identical(_location, LocationDatabase.UTC);

  /// True if this [TZDateTime] is set to Local time.
  ///
  /// ```dart
  /// final dDay = new TZDateTime.local(1944, 6, 6);
  /// assert(dDay.isLocal);
  /// ```
  ///
  bool get isLocal => identical(_location, LocationDatabase.local);

  /// Constructs a [TZDateTime] instance specified in the [location] time zone.
  ///
  /// For example,
  /// to create a new DateTime object representing April 29, 2014, 6:04am:
  ///
  /// ```dart
  /// final detroit = getLocation('America/Detroit');
  ///
  /// final annularEclipse = new TZDateTime(location,
  ///     2014, TZDateTime.APRIL, 29, 6, 4);
  /// ```
  TZDateTime(Location location, int year, [int month = 1, int day = 1, int hour
      = 0, int minute = 0, int second = 0, int millisecond = 0])
      : _location = location,
        _localDateTime = new DateTime.utc(
          year,
          month,
          day,
          hour,
          minute,
          second,
          millisecond) {

    if (isUtc) {
      _timeZone = const TimeZone(0, false, 'UTC');
      _millisecondsSinceEpoch = _localDateTime.millisecondsSinceEpoch;
    } else {
      _timeZone =
          _location.timeZoneFromLocal(_localDateTime.millisecondsSinceEpoch);
      _millisecondsSinceEpoch =
          _localDateTime.millisecondsSinceEpoch - _timeZone.offset;
    }
  }

  /// Constructs a [TZDateTime] instance specified in the UTC time zone.
  ///
  /// ```dart
  /// final dDay = new TZDateTime.utc(1944, TZDateTime.JUNE, 6);
  /// ```
  TZDateTime.utc(int year, [int month = 1, int day = 1, int hour = 0, int minute
      = 0, int second = 0, int millisecond = 0])
      : this(
          LocationDatabase.UTC,
          year,
          month,
          day,
          hour,
          minute,
          second,
          millisecond);

  /// Constructs a [TZDateTime] instance specified in the local time zone.
  ///
  /// ```dart
  /// final dDay = new TZDateTime.utc(1944, TZDateTime.JUNE, 6);
  /// ```
  TZDateTime.local(int year, [int month = 1, int day = 1, int hour = 0,
      int minute = 0, int second = 0, int millisecond = 0])
      : this(
          LocationDatabase.local,
          year,
          month,
          day,
          hour,
          minute,
          second,
          millisecond);

  /// Constructs a [TZDateTime] instance with current date and time in the
  /// [location] time zone.
  ///
  /// ```dart
  /// final detroit = getLocation('America/Detroit');
  ///
  /// final thisInstant = new TZDateTime.now(detroit);
  /// ```
  TZDateTime.now(Location location) : _location = location {
    final now = new DateTime.now();
    _millisecondsSinceEpoch = now.millisecondsSinceEpoch;
    if (isUtc) {
      _timeZone = const TimeZone(0, false, 'UTC');
    } else {
      _timeZone = _location.timeZone(_millisecondsSinceEpoch);
    }
    _localDateTime =
        new DateTime.fromMillisecondsSinceEpoch(_millisecondsSinceEpoch, isUtc: true);
  }

  /// Constructs a new [TZDateTime] instance with the given
  /// [millisecondsSinceEpoch].
  ///
  /// The constructed [TZDateTime] represents
  /// 1970-01-01T00:00:00Z + [millisecondsSinceEpoch] ms in the given
  /// time zone [location].
  TZDateTime.fromMillisecondsSinceEpoch(Location location,
      int millisecondsSinceEpoch)
      : _location = location,
        _millisecondsSinceEpoch = millisecondsSinceEpoch,
        _localDateTime = new DateTime.fromMillisecondsSinceEpoch(
          millisecondsSinceEpoch,
          isUtc: true) {

    if (isUtc) {
      _timeZone = const TimeZone(0, false, 'UTC');
    } else {
      _timeZone = _location.timeZone(millisecondsSinceEpoch);
    }
  }

  /// Constructs a new [DateTime] instance based on [formattedString].
  ///
  /// Throws a [FormatException] if the input cannot be parsed.
  ///
  /// The function parses a subset of ISO 8601
  /// which includes the subset accepted by RFC 3339.
  ///
  /// The result is always in the provided time zone.
  ///
  /// Examples of accepted strings:
  ///
  /// * `"2012-02-27 13:27:00"`
  /// * `"2012-02-27 13:27:00.123456z"`
  /// * `"20120227 13:27:00"`
  /// * `"20120227T132700"`
  /// * `"20120227"`
  /// * `"+20120227"`
  /// * `"2012-02-27T14Z"`
  /// * `"2012-02-27T14+00:00"`
  /// * `"-123450101 00:00:00 Z"`: in the year -12345.
  /// * `"2002-02-27T14:00:00-0500"`: Same as `"2002-02-27T19:00:00Z"`
  static TZDateTime parse(Location location, String formattedString) {
    final t = DateTime.parse(formattedString).millisecondsSinceEpoch;
    return new TZDateTime.fromMillisecondsSinceEpoch(location, t);
  }

  /// Returns this DateTime value in the UTC time zone.
  ///
  /// Returns [this] if it is already in UTC.
  /// Otherwise this method is equivalent to:
  TZDateTime toUtc() {
    if (isUtc) {
      return this;
    }
    return new TZDateTime.fromMillisecondsSinceEpoch(
        LocationDatabase.UTC,
        millisecondsSinceEpoch);
  }

  /// Returns this DateTime value in the local time zone.
  ///
  /// Returns [this] if it is already in the local time zone.
  /// Otherwise this method is equivalent to:
  TZDateTime toLocal() {
    if (isLocal) {
      return this;
    }
    return new TZDateTime.fromMillisecondsSinceEpoch(
        LocationDatabase.local,
        millisecondsSinceEpoch);
  }

  static String _fourDigits(int n) {
    int absN = n.abs();
    String sign = n < 0 ? "-" : "";
    if (absN >= 1000) return "$n";
    if (absN >= 100) return "${sign}0$absN";
    if (absN >= 10) return "${sign}00$absN";
    return "${sign}000$absN";
  }

  static String _threeDigits(int n) {
    if (n >= 100) return "${n}";
    if (n >= 10) return "0${n}";
    return "00${n}";
  }

  static String _twoDigits(int n) {
    if (n >= 10) return "${n}";
    return "0${n}";
  }

  /// Returns a human-readable string for this instance.
  ///
  /// The returned string is constructed for the time zone of this instance.
  /// The `toString()` method provides a simply formatted string.
  /// It does not support internationalized strings.
  /// Use the [intl](http://pub.dartlang.org/packages/intl) package
  /// at the pub shared packages repo.
  String toString() {
    String y = _fourDigits(year);
    String m = _twoDigits(month);
    String d = _twoDigits(day);
    String h = _twoDigits(hour);
    String min = _twoDigits(minute);
    String sec = _twoDigits(second);
    String ms = _threeDigits(millisecond);
    if (isUtc) {
      return "$y-$m-$d $h:$min:$sec.${ms}Z";
    } else {
      return "$y-$m-$d $h:$min:$sec.$ms";
    }
  }

  /// Returns an ISO-8601 full-precision extended format representation.
  /// The format is "YYYY-MM-DDTHH:mm:ss.sssZ" for UTC time, and
  /// "YYYY-MM-DDTHH:mm:ss.sss" (no trailing "Z") for non-UTC time.
  String toIso8601String() {
    String y = _fourDigits(year);
    String m = _twoDigits(month);
    String d = _twoDigits(day);
    String h = _twoDigits(hour);
    String min = _twoDigits(minute);
    String sec = _twoDigits(second);
    String ms = _threeDigits(millisecond);
    if (isUtc) {
      return "$y-$m-${d}T$h:$min:$sec.${ms}Z";
    } else {
      return "$y-$m-${d}T$h:$min:$sec.$ms";
    }
  }

  /// Returns a new [TZDateTime] instance with [duration] added to [this].
  TZDateTime add(Duration duration) {
    return new TZDateTime.fromMillisecondsSinceEpoch(
        _location,
        _millisecondsSinceEpoch + duration.inMilliseconds);
  }

  /// Returns a new [TZDateTime] instance with [duration] subtracted from
  /// [this].
  TZDateTime subtract(Duration duration) {
    return new TZDateTime.fromMillisecondsSinceEpoch(
        _location,
        _millisecondsSinceEpoch - duration.inMilliseconds);
  }

  /// Returns a [Duration] with the difference between [this] and [other].
  Duration difference(TZDateTime other) {
    return new Duration(
        milliseconds: _millisecondsSinceEpoch - other._millisecondsSinceEpoch);
  }

  /// Returns true if [other] is a [DateTime] at the same moment and in the
  /// same [Location].
  ///
  /// ```dart
  /// final detroit   = getLocation('America/Detroit');
  /// final dDayUtc   = new TZDateTime.utc(1944, DateTime.JUNE, 6);
  /// final dDayLocal = new TZDateTime(detroit, 1944, DateTime.JUNE, 6);
  ///
  /// assert(dDayUtc.isAtSameMomentAs(dDayLocal) == false);
  /// ````
  ///
  /// See [isAtSameMomentAs] for a comparison that adjusts for time zone.
  bool operator ==(other) {
    if (!(other is TZDateTime)) {
      return false;
    }

    return (millisecondsSinceEpoch == other.millisecondsSinceEpoch &&
        _location == other._location);
  }

  /// Returns true if [this] occurs before [other].
  ///
  /// The comparison is independent of whether the time is in UTC or in other
  /// time zone.
  ///
  /// ```dart
  /// final berlinWallFell = new TZDateTime(UTC, 1989, 11, 9);
  /// final moonLanding    = new TZDateTime(UTC, 1969, 7, 20);
  ///
  /// assert(berlinWallFell.isBefore(moonLanding) == false);
  /// ```
  bool isBefore(DateTime other) {
    return millisecondsSinceEpoch < other.millisecondsSinceEpoch;
  }

  /// Returns true if [this] occurs after [other].
  ///
  /// The comparison is independent of whether the time is in UTC or in other
  /// time zone.
  ///
  /// ```dart
  /// final berlinWallFell = new TZDateTime(UTC, 1989, 11, 9);
  /// final moonLanding    = new TZDateTime(UTC, 1969, 7, 20);
  ///
  /// assert(berlinWallFell.isAfter(moonLanding) == true);
  /// ```
  bool isAfter(DateTime other) {
    return millisecondsSinceEpoch > other.millisecondsSinceEpoch;
  }

  /// Returns true if [this] occurs at the same moment as [other].
  ///
  /// The comparison is independent of whether the time is in UTC or in other
  /// time zone.
  ///
  /// ```dart
  /// final berlinWallFell = new TZDateTime(UTC, 1989, 11, 9);
  /// final moonLanding    = new TZDateTime(UTC, 1969, 7, 20);
  ///
  /// assert(berlinWallFell.isAtSameMomentAs(moonLanding) == false);
  /// ```
  bool isAtSameMomentAs(TZDateTime other) {
    return millisecondsSinceEpoch == other.millisecondsSinceEpoch;
  }

  /// Compares this [TZDateTime] object to [other],
  /// returning zero if the values are equal.
  ///
  /// This function returns a negative integer
  /// if this [TZDateTime] is smaller (earlier) than [other],
  /// or a positive integer if it is greater (later).
  int compareTo(TZDateTime other) =>
      millisecondsSinceEpoch.compareTo(other.millisecondsSinceEpoch);

  int get hashCode => millisecondsSinceEpoch;

  /// The abbreviated time zone name&mdash;for example,
  /// [:"CET":] or [:"CEST":].
  String get timeZoneName => _timeZone.abbr;

  /// The time zone offset, which is the difference between time at [location]
  /// and UTC.
  ///
  /// The offset is positive for time zones east of UTC.
  ///
  /// Note, that JavaScript, Python and C return the difference between UTC and
  /// local time. Java, C# and Ruby return the difference between local time and
  /// UTC.
  Duration get timeZoneOffset => new Duration(milliseconds: _timeZone.offset);

  /// The year.
  int get year => _localDateTime.year;

  /// The month [1..12].
  int get month => _localDateTime.month;

  /// The day of the month [1..31].
  int get day => _localDateTime.day;

  /// The hour of the day, expressed as in a 24-hour clock [0..23].
  int get hour => _localDateTime.hour;

  /// The minute [0...59].
  int get minute => _localDateTime.minute;

  /// The second [0...59].
  int get second => _localDateTime.second;

  /// The millisecond [0...999].
  int get millisecond => _localDateTime.millisecond;

  /// The day of the week [MONDAY]..[SUNDAY].
  ///
  /// In accordance with ISO 8601
  /// a week starts with Monday, which has the value 1.
  int get weekday => _localDateTime.weekday;
}
