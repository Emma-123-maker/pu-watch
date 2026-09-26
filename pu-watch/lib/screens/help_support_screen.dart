import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Help & Support"), backgroundColor: Colors.green[800]),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Card(child: ListTile(leading: Icon(Icons.report, color: Colors.red), title: Text("Report Emergency"), subtitle: Text("Violence, snatching, threat"), onTap: () {})),
          Card(child: ListTile(leading: Icon(Icons.play_circle, color: Colors.green), title: Text("How to Capture EC8A"), subtitle: Text("Watch 60-sec guide"), onTap: () {})),
          Card(child: ListTile(leading: Icon(Icons.chat, color: Colors.blue), title: Text("Contact State Lead"), subtitle: Text("Akwa Ibom - Chat on WhatsApp"), onTap: () async {
            final url = Uri.parse("https://wa.me/2340000000000");
            await launchUrl(url);
          })),
        ],
      ),
    );
  }
}
