import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PUSearchScreen extends StatefulWidget {
  const PUSearchScreen({super.key});
  @override
  State<PUSearchScreen> createState() => _PUSearchScreenState();
}

class _PUSearchScreenState extends State<PUSearchScreen> {
  List allPUs = [];
  List filtered = [];

  @override
  void initState() {
    super.initState();
    loadPU();
  }

  Future<void> loadPU() async {
    String data = await rootBundle.loadString('assets/data/pu_sample.json');
    setState(() {
      allPUs = json.decode(data);
      filtered = allPUs;
    });
  }

  void search(String q) {
    setState(() {
      filtered = allPUs.where((pu) =>
        pu['pu_code'].toString().toLowerCase().contains(q.toLowerCase()) ||
        pu['pu_name'].toString().toLowerCase().contains(q.toLowerCase()) ||
        pu['lga'].toString().toLowerCase().contains(q.toLowerCase())
      ).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Find Your PU"), backgroundColor: Colors.green[800]),
      body: Column(children: [
        Padding(padding: EdgeInsets.all(12), child: TextField(onChanged: search, decoration: InputDecoration(hintText: "Search PU code, name, LGA...", prefixIcon: Icon(Icons.search), border: OutlineInputBorder()))),
        Expanded(child: ListView.builder(itemCount: filtered.length, itemBuilder: (_, i) {
          var pu = filtered[i];
          return ListTile(title: Text("${pu['pu_code']} - ${pu['pu_name']}"), subtitle: Text("${pu['lga']}, ${pu['ward']}"), trailing: Icon(Icons.check_circle, color: Colors.green), onTap: () {});
        }))
      ]),
    );
  }
}
