import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});
  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  String? gpsText;
  String? puCode = "AK/02/03/005";

  Future<void> getLocation() async {
    LocationPermission perm = await Geolocator.requestPermission();
    Position pos = await Geolocator.getCurrentPosition();
    setState(() {
      gpsText = "${pos.latitude}, ${pos.longitude}";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("PU Check-In"), backgroundColor: Colors.green[800]),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(labelText: "Enter PU Code e.g AK/02/03/005", border: OutlineInputBorder()),
              onChanged: (v) => puCode = v,
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(onPressed: getLocation, icon: Icon(Icons.gps_fixed), label: Text("Capture GPS Proof")),
            SizedBox(height: 20),
            if(gpsText!= null) Text("📍 $gpsText\n⏰ ${DateTime.now()}\n✅ Verified at PU: $puCode", style: TextStyle(fontSize: 16)),
            Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green[800], minimumSize: Size(double.infinity, 50)),
              onPressed: () {},
              child: Text("CHECK-IN NOW", style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }
}
