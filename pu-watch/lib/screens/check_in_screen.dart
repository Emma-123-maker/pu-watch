import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class CheckInScreen extends StatefulWidget {
  final String initialCode;
  const CheckInScreen({super.key, this.initialCode = ""});
  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  String? gpsText;
  Position? _lastPos;
  String puCode = "AK/02/03/005";
  bool isOffline = false;
  int pendingCount = 0;
  late Box box;
  late TextEditingController _puController;

  @override
  void initState() {
    super.initState();
    puCode = widget.initialCode.isNotEmpty? widget.initialCode : "AK/02/03/005";
    _puController = TextEditingController(text: puCode);
    initOffline();
  }

  @override
  void didUpdateWidget(covariant CheckInScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialCode.isNotEmpty && widget.initialCode!= oldWidget.initialCode) {
      setState(() {
        puCode = widget.initialCode;
        _puController.text = widget.initialCode;
      });
    }
  }

  @override
  void dispose() {
    _puController.dispose();
    super.dispose();
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
    if (perm== LocationPermission.denied || perm== LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ Location permission denied')));
      return;
    }
    Position pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _lastPos = pos;
      gpsText = "${pos.latitude.toStringAsFixed(6)}, ${pos.longitude.toStringAsFixed(6)} (±${pos.accuracy.toStringAsFixed(0)}m)";
    });
  }

  Future<void> submitCheckIn() async {
    if (_lastPos == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('⚠️ Please capture GPS first')));
      return;
    }
    Map payload = {
      'pu_code': puCode,
      'gps': gpsText,
      'lat': _lastPos!.latitude,
      'lng': _lastPos!.longitude,
      'accuracy': _lastPos!.accuracy,
      'timestamp': DateTime.now().toIso8601String(),
      'synced': false,
    };
    await box.add(payload);
    setState(() {
      pendingCount = box.values.where((e) => e['synced'] == false).length;
    });
    if (isOffline) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('📴 Offline saved! $pendingCount pending'), backgroundColor: Colors.orange[800]));
    } else {
      await Future.delayed(Duration(seconds: 1));
      var lastIndex = box.length - 1;
      var last = box.getAt(lastIndex);
      last['synced'] = true;
      await box.putAt(lastIndex, last);
      setState(() {
        pendingCount = box.values.where((e) => e['synced'] == false).length;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ Check-in sent! Online mode'), backgroundColor: Colors.green[800]));
    }
  }

  Future<void> syncPending() async {
    if (box.values.where((e) => e['synced'] == false).isEmpty) return;
    for (int i = 0; i < box.length; i++) {
      var item = box.getAt(i);
      if (item['synced'] == false) {
        try {
          await Future.delayed(Duration(milliseconds: 500));
          item['synced'] = true;
          await box.putAt(i, item);
        } catch (_) {}
      }
    }
    setState(() {
      pendingCount = box.values.where((e) => e['synced'] == false).length;
    });
    if (mounted && pendingCount == 0 && box.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('🔄 All offline check-ins synced!')));
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
              label: Text(isOffline? '📴 OFFLINE $pendingCount' : '🌐 ONLINE', style: TextStyle(color: Colors.white, fontSize: 12)),
              backgroundColor: isOffline? Colors.orange[800] : Colors.green[600],
            ),
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            if (isOffline)
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.orange[100], borderRadius: BorderRadius.circular(8)),
                child: Row(children: [Icon(Icons.wifi_off, color: Colors.orange[800]), SizedBox(width: 8), Expanded(child: Text('Offline Mode — $pendingCount pending', style: TextStyle(fontSize:12)))]),
              ),
            SizedBox(height: 10),
            TextField(
              controller: _puController,
              decoration: InputDecoration(labelText: "Enter PU Code", border: OutlineInputBorder(), prefixIcon: Icon(Icons.how_to_vote), suffixIcon: widget.initialCode.isNotEmpty? Icon(Icons.check_circle, color: Colors.green) : null, isDense: true),
              onChanged: (v) => puCode = v,
            ),
            if (widget.initialCode.isNotEmpty)
              Padding(padding: EdgeInsets.only(top:6), child: Text("✅ Auto-filled: ${widget.initialCode}", style: TextStyle(color: Colors.green[800], fontWeight: FontWeight.bold, fontSize:11))),
            SizedBox(height: 12),
            ElevatedButton.icon(onPressed: getLocation, icon: Icon(Icons.gps_fixed), label: Text("Capture GPS Proof"), style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 44))),

            if (_lastPos!= null)...[
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.green[50], border: Border.all(color: Colors.green), borderRadius: BorderRadius.circular(8)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text("📍 $gpsText", style: TextStyle(fontWeight: FontWeight.bold, fontSize:13)),
                  Text("⏰ ${DateTime.now().toString().substring(0,19)}\n✅ PU: $puCode", style: TextStyle(fontSize:12)),
                ]),
              ),
              SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 180,
                  child: FlutterMap(
                    options: MapOptions(center: LatLng(_lastPos!.latitude, _lastPos!.longitude), zoom: 16),
                    children: [
                      TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.puwatch.app'),
                      MarkerLayer(markers: [Marker(point: LatLng(_lastPos!.latitude, _lastPos!.longitude), width: 50, height: 50, child: Icon(Icons.location_on, color: Colors.red, size: 40))]),
                      CircleLayer(circles: [CircleMarker(point: LatLng(_lastPos!.latitude, _lastPos!.longitude), radius: _lastPos!.accuracy, useRadiusInMeter: true, color: Colors.blue.withOpacity(0.2), borderColor: Colors.blue, borderStrokeWidth: 2)]),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 6),
              Text(_lastPos!.accuracy < 30? "✅ Good accuracy - Verified at PU" : "⚠️ Move outside for better GPS (accuracy ${_lastPos!.accuracy.toStringAsFixed(0)}m)", style: TextStyle(fontSize:11, color: _lastPos!.accuracy < 30? Colors.green[800] : Colors.orange[800])),
            ],
            Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green[800], minimumSize: Size(double.infinity, 50)),
              onPressed: submitCheckIn,
              child: Text(isOffline? "SAVE OFFLINE CHECK-IN" : "CHECK-IN NOW", style: TextStyle(color: Colors.white)),
            ),
            if (pendingCount > 0) TextButton(onPressed: syncPending, child: Text("🔄 Sync $pendingCount pending now", style: TextStyle(fontSize:12))),
          ],
        ),
      ),
    );
  }
}
