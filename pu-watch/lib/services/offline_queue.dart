import 'package:hive_flutter/hive_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class OfflineQueue {
  static late Box box;

  static Future<void> init() async {
    await Hive.initFlutter();
    box = await Hive.openBox('checkins_queue');
  }

  static Future<void> saveCheckIn(Map data) async {
    data['timestamp'] = DateTime.now().toIso8601String();
    data['synced'] = false;
    await box.add(data);
  }

  static List getPending() {
    return box.values.where((e) => e['synced'] == false).toList();
  }

  static Future<bool> isOnline() async {
    var result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  static Future<void> syncAll(Function(Map) uploadFunc) async {
    if (!await isOnline()) return;
    for (var i = 0; i < box.length; i++) {
      var item = box.getAt(i);
      if (item['synced'] == false) {
        try {
          await uploadFunc(item);
          item['synced'] = true;
          await box.putAt(i, item);
        } catch (_) {}
      }
    }
  }
}
