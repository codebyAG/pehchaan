import 'device_store.dart';
import 'pehchaan_api.dart';

/// Analytics events (§11): queued locally, flushed in batches, fire and
/// forget. A failure never surfaces to the user; the batch just waits for
/// the next flush with its ids unchanged so the server can dedupe.
class EventQueue {
  EventQueue._();

  static const _flushAt = 20;
  static const _maxPerRequest = 200;
  static const _maxQueued = 2000;

  static bool _flushing = false;

  static Future<void> appOpen() => track('app_open');
  static Future<void> designView(String designId) => track('design_view', designId);
  static Future<void> personalizeComplete(String designId) =>
      track('personalize_complete', designId);
  static Future<void> shareComplete(String designId) =>
      track('share_complete', designId);
  static Future<void> downloadComplete(String designId) =>
      track('download_complete', designId);

  static Future<void> track(String type, [String? designId]) async {
    try {
      final queue = await DeviceStore.eventQueue();
      queue.add({
        'id': uuidV4(),
        'design_id': designId,
        'type': type,
        'at': _isoWithOffset(DateTime.now()),
      });
      // Bound the backlog if the device stays offline for a long time.
      final trimmed = queue.length > _maxQueued
          ? queue.sublist(queue.length - _maxQueued)
          : queue;
      await DeviceStore.setEventQueue(trimmed);
      if (trimmed.length >= _flushAt) flush();
    } catch (_) {}
  }

  static Future<void> flush() async {
    if (_flushing) return;
    _flushing = true;
    try {
      while (true) {
        final queue = await DeviceStore.eventQueue();
        if (queue.isEmpty) break;
        final batch = queue.take(_maxPerRequest).toList();
        await PehchaanApi.sendEvents(batch);
        // Re-read: events may have been added while the request was out.
        final sentIds = batch.map((e) => e['id']).toSet();
        final remaining = (await DeviceStore.eventQueue())
            .where((e) => !sentIds.contains(e['id']))
            .toList();
        await DeviceStore.setEventQueue(remaining);
        if (batch.length < _maxPerRequest) break;
      }
    } catch (_) {
      // Retry on the next flush.
    } finally {
      _flushing = false;
    }
  }

  static String _isoWithOffset(DateTime t) {
    final o = t.timeZoneOffset;
    final sign = o.isNegative ? '-' : '+';
    final h = o.inHours.abs().toString().padLeft(2, '0');
    final m = (o.inMinutes.abs() % 60).toString().padLeft(2, '0');
    final local = t.toIso8601String().split('.').first;
    return '$local$sign$h:$m';
  }
}
