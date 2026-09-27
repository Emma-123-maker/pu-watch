import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});
  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  String? gpsText;
  String? puCode = "AK/02/03/005";
  bool isOffline = false;
  int pendingCount = 0;
  late Box box;

  @override
  void initState() {
    super.initState();
    initOffline();
  }

  Future<void> initOffline() async {
    await Hive.initFlutter();
    box = await Hive.openBox('checkins_queue');
    checkConnection();
    Connectivity().onConnectivityChanged.listen((result) {
      setState(() {
        isOffline = result == ConnectivityResult.none;
      });
      if (!isOffline) syncPending();
    });
    setState(() {
      pendingCount = box.values.where((e) => e['synced'] == false).length;
    });
  }

  Future<void> checkConnection() async {
    var result = await Connectivity().checkConnectivity();
    setState(() {
      isOffline = result == ConnectivityResult.none;
    });
  }

  Future<void> getLocation() async {
    LocationPermission perm = await Geolocator.requestPermission();
    Position pos = await Geolocator.getCurrentPosition();
    setState(() {
      gpsText = "${pos.latitude}, ${pos.longitude}";
    });
  }

  Future<void> submitCheckIn() async {
    if (gpsText == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('⚠️ Please capture GPS first')),
      );
      return;
    }

    Map payload = {
      'pu_code': puCode,
      'gps': gpsText,
      'timestamp': DateTime.now().toIso8601String(),
      'synced': false,
    };

    await box.add(payload);
    setState(() {
      pendingCount = box.values.where((e) => e['synced'] == false).length;
    });

    if (isOffline) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('📴 Offline saved! $pendingCount pending — will auto-sync when online'), backgroundColor: Colors.orange[800]),
      );
    } else {
      // Simulate online upload, then mark synced
      await Future.delayed(Duration(seconds: 1)); // replace with your API call
      // Mark last as synced
      var lastIndex = box.length - 1;
      var last = box.getAt(lastIndex);
      last['synced'] = true;
      await box.putAt(lastIndex, last);
      setState(() {
        pendingCount = box.values.where((e) => e['synced'] == false).length;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Check-in sent! Online mode'), backgroundColor: Colors.green[800]),
      );
    }
  }

  Future<void> syncPending() async {
    if (box.values.where((e) => e['synced'] == false).isEmpty) return;
    // Here you would loop and upload each pending to your server
    for (int i = 0; i < box.length; i++) {
      var item = box.getAt(i);
      if (item['synced'] == false) {
        try {
          await Future.delayed(Duration(milliseconds: 500)); // replace with API call
          item['synced'] = true;
          await box.putAt(i, item);
        } catch (_) {}
      }
    }
    setState(() {
      pendingCount = box.values.where((e) => e['synced'] == false).length;
    });
    if (mounted && pendingCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('🔄 All offline check-ins synced!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("PU Check-In"),
        backgroundColor: Colors.green[800],
        actions: [
          Padding(
            padding: EdgeInsets.all(12),
            child: Chip(
              label: Text(isOffline? '📴 OFFLINE $pendingCount' : '🌐 ONLINE',
                  style: TextStyle(color: Colors.white, fontSize: 12)),
              backgroundColor: isOffline? Colors.orange[800] : Colors.green[600],
            ),
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            if (isOffline)
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.orange[100], borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    Icon(Icons.wifi_off, color: Colors.orange[800]),
                    SizedBox(width: 8),
                    Expanded(child: Text('Offline Mode Active — Check-ins saved locally & will sync later. Pending: $pendingCount')),
                  ],
                ),
              ),
            SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(labelText: "Enter PU Code e.g AK/02/03/005", border: OutlineInputBorder()),
              onChanged: (v) => puCode = v,
              controller: TextEditingController(text: puCode),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(onPressed: getLocation, icon: Icon(Icons.gps_fixed), label: Text("Capture GPS Proof")),
            SizedBox(height: 20),
            if (gpsText!= null)
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.green[50], border: Border.all(color: Colors.green)),
                child: Text("📍 $gpsText\n⏰ ${DateTime.now()}\n✅ Verified at PU: $puCode", style: TextStyle(fontSize: 16)),
              ),
            Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green[800], minimumSize: Size(double.infinity, 50)),
              onPressed: submitCheckIn,
              child: Text(isOffline? "SAVE OFFLINE CHECK-IN" : "CHECK-IN NOW", style: TextStyle(color: Colors.white)),
            ),
            if (pendingCount > 0)
              TextButton(onPressed: syncPending, child: Text("🔄 Sync $pendingCount pending now")),
          ],
        ),
      ),
    );
  }
}
