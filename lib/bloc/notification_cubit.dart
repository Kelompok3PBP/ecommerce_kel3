import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/notification_service.dart';

class NotificationItem {
  final String title;
  final String body;
  final DateTime time;

  NotificationItem({
    required this.title,
    required this.body,
    required this.time,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'body': body,
    'time': time.toIso8601String(),
  };

  factory NotificationItem.fromJson(Map<String, dynamic> j) => NotificationItem(
    title: j['title'] ?? '',
    body: j['body'] ?? '',
    time: DateTime.parse(j['time']),
  );
}

class NotificationState {
  final bool initialized;
  final List<NotificationItem> history;

  NotificationState({required this.initialized, required this.history});

  factory NotificationState.initial() =>
      NotificationState(initialized: false, history: []);

  NotificationState copyWith({
    bool? initialized,
    List<NotificationItem>? history,
  }) {
    return NotificationState(
      initialized: initialized ?? this.initialized,
      history: history ?? List<NotificationItem>.from(this.history),
    );
  }
}

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationService _service = NotificationService();

  NotificationCubit() : super(NotificationState.initial()) {
    _init();
  }

  Future<void> _init() async {
    await _service.initNotification();
    emit(state.copyWith(initialized: true));
  }

  Future<void> show(String title, String body) async {
    if (!state.initialized) await _init();
    await _service.showNotification(title: title, body: body);
    final item = NotificationItem(
      title: title,
      body: body,
      time: DateTime.now(),
    );
    final newHistory = List<NotificationItem>.from(state.history)
      ..insert(0, item);
    emit(state.copyWith(history: newHistory));
  }

  Future<void> schedule(String title, String body, DateTime when) async {
    if (!state.initialized) await _init();
    await _service.showScheduledNotification(
      title: title,
      body: body,
      scheduledTime: when,
    );
    final item = NotificationItem(title: title, body: body, time: when);
    final newHistory = List<NotificationItem>.from(state.history)
      ..insert(0, item);
    emit(state.copyWith(history: newHistory));
  }

  void clearHistory() {
    emit(state.copyWith(history: []));
  }
}
