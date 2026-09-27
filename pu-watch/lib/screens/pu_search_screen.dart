import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/state_dropdown.dart';

class PUSearchScreen extends StatefulWidget {
  const PUSearchScreen({super.key});
  @override
  State<PUSearchScreen> createState() => _PUSearchScreenState();
}

class _PUSearchScreenState extends State<PUSearchScreen> {
  List allPUs = [];
  List filtered = [];
  String currentStateCode = '03';
  String currentStateName = 'Akwa Ibom';

  @override
  void initState() {
    super.initState();
    loadPU();
  }

  Future<void> loadPU() async {
    // Try load selected state file first, fallback to sample
    try {
      String path = 'assets/data/states/03-akwa-ibom.json';
      String data = await rootBundle.loadString(path);
      setState(() {
        allPUs = json.decode(data);
        filtered = allPUs;
      });
    } catch (e) {
      // fallback to old sample
      String data = await rootBundle.loadString('assets/data/pu_sample.json');
      setState(() {
        allPUs = json.decode(data);
        filtered = allPUs;
      });
    }
  }
  
  Future<void> loadPUForState(String code, String name) async {
   try {
     String slug = name.toLowerCase().replaceAll(' ', '-');
     if (name.toLowerCase().contains('fct')) slug = 'fct-abuja';
     String fileName = 'assets/data/states/${code.toLowerCase()}-$slug.json';
     String data = await rootBundle.loadString(fileName);
     setState(() {
       allPUs = json.decode(data);
       filtered = allPUs;
       currentStateCode = code;
       currentStateName = name;
     });
   } catch (e) {
     ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(content: Text('Data for $name not added yet. Using sample.')),
     );
   }
  }
  

  void search(String q) {
    setState(() {
      filtered = allPUs.where((pu) =>
        pu['pu_code'].toString().toLowerCase().contains(q.toLowerCase()) ||
        pu['pu_name'].toString().toLowerCase().contains(q.toLowerCase()) ||
        pu['lga'].toString().toLowerCase().contains(q.toLowerCase()) ||
        pu['ward'].toString().toLowerCase().contains(q.toLowerCase())
      ).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Find Your PU"), backgroundColor: Colors.green[800]),
      body: Column(children: [
        Padding(padding: EdgeInsets.all(12), child: StateDropdown(
          onStateSelected: (code, name) {
            loadPUsForState(code, name);
          },
        )),
        Padding(padding: EdgeInsets.all(12), child: TextField(
          onChanged: search,
          decoration: InputDecoration(hintText: "Search PU code, name, LGA...", border: OutlineInputBorder(), prefixIcon: Icon(Icons.search))
        )),
        Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text("$currentStateName: ${filtered.length} PUs", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[800]))),
        Expanded(child: ListView.builder(itemCount: filtered.length, itemBuilder: (_, i) {
          var pu = filtered[i];
          return ListTile(
            title: Text("${pu['pu_code']} - ${pu['pu_name'] ?? pu['name'] ?? pu['polling_unit_name'] ?? 'PU'}"),
            subtitle: Text("${pu['lga']}, ${pu['ward']}"),
            onTap: () {
              // You can navigate to check-in here
            },
          );
        }))
      ])
    );
  }
}
