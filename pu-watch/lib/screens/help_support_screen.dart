import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  // Change this to your real state lead number
  final String stateLeadNumber = "2348066316416"; // 234 format, no +
  final String stateName = "Ondo";

  Future<void> openWhatsApp(BuildContext context) async {
    final text = Uri.encodeComponent("Hello State Lead, I need help at PU. My location: Akwa Ibom. Issue: ");
    final url = Uri.parse("https://wa.me/$stateLeadNumber?text=$text");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not open WhatsApp')));
    }
  }

  void showEmergencySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("🚨 Report Emergency", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red[800])),
            SizedBox(height: 12),
            _emergencyTile(context, Icons.warning, "Violence at PU", Colors.red),
            _emergencyTile(context, Icons.backpack, "Ballot Box Snatching", Colors.orange),
            _emergencyTile(context, Icons.person_off, "Intimidation / Threat", Colors.red),
            _emergencyTile(context, Icons.block, "Vote Buying", Colors.orange),
            SizedBox(height: 10),
            Text("Your GPS will be auto-attached.", style: TextStyle(fontSize: 11, color: Colors.grey)),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _emergencyTile(BuildContext context, IconData icon, String title, Color color) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
      trailing: Icon(Icons.send, size: 18),
      onTap: () async {
        Navigator.pop(context);
        try {
          Position pos = await Geolocator.getCurrentPosition();
          var box = await Hive.openBox('emergencies');
          await box.add({
            'type': title,
            'lat': pos.latitude,
            'lng': pos.longitude,
            'time': DateTime.now().toIso8601String(),
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ Emergency reported: $title\n📍 ${pos.latitude}, ${pos.longitude}'), backgroundColor: Colors.red[800]));
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('📴 Saved offline. Will sync when online.'), backgroundColor: Colors.orange[800]));
        }
      },
    );
  }

  void showEC8AGuide(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("How to Capture EC8A"),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("📸 60-Second Guide:", style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 12),
              Text("1️⃣ Wait for counting to finish\n\n2️⃣ Make sure EC8A is pasted on wall\n\n3️⃣ Stand directly in front (no shadow)\n\n4️⃣ Capture ALL numbers clearly\n\n5️⃣ Take 2 photos - close + wide with party agents\n\n6️⃣ Check photo is readable before submit\n\n⚠️ DO NOT crop or edit!"),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(8)),
                child: Text("💡 Tip: Use flash if dark, hold phone steady, include PU code in watermark.", style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text("Got it"))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Help & Support"), backgroundColor: Colors.green[800]),
      body: ListView(
        padding: EdgeInsets.all(14),
        children: [
          _card(
            icon: Icons.warning_rounded,
            iconColor: Colors.white,
            bgColor: Colors.red[600]!,
            title: "Report Emergency",
            subtitle: "Violence, snatching, threat",
            onTap: () => showEmergencySheet(context),
          ),
          _card(
            icon: Icons.play_arrow_rounded,
            iconColor: Colors.white,
            bgColor: Colors.green[700]!,
            title: "How to Capture EC8A",
            subtitle: "Watch 60-sec guide",
            onTap: () => showEC8AGuide(context),
          ),
          _card(
            icon: Icons.chat_bubble,
            iconColor: Colors.white,
            bgColor: Colors.blue[700]!,
            title: "Contact State Lead",
            subtitle: "$stateName - Chat on WhatsApp",
            onTap: () => openWhatsApp(context),
          ),
          SizedBox(height: 20),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("PU-Watch Support", style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 6),
                Text("Hotline: 0700-PUWATCH\nEmail: support@puwatch.ng\n\nIf app fails, SMS your PU code + Results to State Lead.", style: TextStyle(fontSize: 12, color: Colors.black87)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required IconData icon, required Color iconColor, required Color bgColor, required String title, required String subtitle, required VoidCallback onTap}) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: bgColor, child: Icon(icon, color: iconColor)),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 12)),
        trailing: Icon(Icons.arrow_forward_ios, size: 14),
        onTap: onTap,
      ),
    );
  }
}
