class NotificationModel {
  int? _id;
  String _title;
  String _body;
  DateTime _time;

  NotificationModel({
    int? id,
    required String title,
    required String body,
    DateTime? time,
  }) : _id = id,
       _title = title,
       _body = body,
       _time = time ?? DateTime.now();

  // Getters
  int? get id => _id;
  String get title => _title;
  String get body => _body;
  DateTime get time => _time;

  // Setters
  set setId(int? v) => _id = v;
  set setTitle(String v) => _title = v;
  set setBody(String v) => _body = v;
  set setTime(DateTime v) => _time = v;

  factory NotificationModel.fromJson(Map<String, dynamic> j) {
    return NotificationModel(
      id: j['id'] as int?,
      title: (j['title'] ?? '') as String,
      body: (j['body'] ?? '') as String,
      time: j['time'] != null ? DateTime.parse(j['time']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': _id,
    'title': _title,
    'body': _body,
    'time': _time.toIso8601String(),
  };

  NotificationModel copyWith({
    int? id,
    String? title,
    String? body,
    DateTime? time,
  }) {
    return NotificationModel(
      id: id ?? _id,
      title: title ?? _title,
      body: body ?? _body,
      time: time ?? _time,
    );
  }
}
