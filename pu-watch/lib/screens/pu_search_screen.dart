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

  // FILTER STATE
  String searchQuery = '';
  String? selectedLGA;
  String? selectedWard;
  List<String> lgaList = [];
  List<String> wardList = [];

  @override
  void initState() {
    super.initState();
    loadPU();
  }

  // 🔒 Helper to clean nulls
  List _cleanPUs(List data) {
    return data.where((pu) {
      final n = (pu['pu_name'] ?? pu['name'] ?? pu['polling_unit_name'] ?? '').toString().toLowerCase().trim();
      final c = (pu['pu_code'] ?? pu['code'] ?? '').toString().toLowerCase().trim();
      if (n.isEmpty || c.isEmpty) return false;
      if (n == 'null' || c == 'null') return false;
      if (n.contains('null - pu')) return false;
      return true;
    }).toList();
  }

  void _rebuildFilterOptions() {
    var lgas = allPUs.map((e) => e['lga'].toString()).toSet().toList()..sort();
    List<String> wards;
    if (selectedLGA != null) {
      wards = allPUs.where((e) => e['lga'].toString() == selectedLGA).map((e) => e['ward'].toString()).toSet().toList()..sort();
    } else {
      wards = allPUs.map((e) => e['ward'].toString()).toSet().toList()..sort();
    }
    setState(() {
      lgaList = lgas;
      wardList = wards;
    });
  }

  void applyFilters() {
    setState(() {
      filtered = allPUs.where((pu) {
        final q = searchQuery.toLowerCase();
        bool okSearch = q.isEmpty ||
            pu['pu_code'].toString().toLowerCase().contains(q) ||
            pu['pu_name'].toString().toLowerCase().contains(q) ||
            pu['lga'].toString().toLowerCase().contains(q) ||
            pu['ward'].toString().toLowerCase().contains(q);

        bool okLGA = selectedLGA == null || pu['lga'].toString() == selectedLGA;
        bool okWard = selectedWard == null || pu['ward'].toString() == selectedWard;

        return okSearch && okLGA && okWard;
      }).toList();
    });
  }

  Future<void> loadPU() async {
    try {
      String path = 'assets/data/states/03-akwa-ibom.json';
      String data = await rootBundle.loadString(path);
      setState(() {
        allPUs = _cleanPUs(json.decode(data));
        selectedLGA = null;
        selectedWard = null;
      });
      _rebuildFilterOptions();
      applyFilters();
    } catch (e) {
      String data = await rootBundle.loadString('assets/data/pu_sample.json');
      setState(() {
        allPUs = _cleanPUs(json.decode(data));
        selectedLGA = null;
        selectedWard = null;
      });
      _rebuildFilterOptions();
      applyFilters();
    }
  }

  Future<void> loadPUForState(String code, String name) async {
    try {
      String slug = name.toLowerCase().replaceAll(' ', '-');
      if (slug.contains('fct')) slug = 'fct-abuja';
      String fileName = 'assets/data/states/$code-$slug.json';
      String data = await rootBundle.loadString(fileName);
      setState(() {
        allPUs = _cleanPUs(json.decode(data));
        currentStateCode = code;
        currentStateName = name;
        selectedLGA = null;
        selectedWard = null;
        searchQuery = '';
      });
      _rebuildFilterOptions();
      applyFilters();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data for $name not yet added. Add file $code-${name.toLowerCase()}.json')),
      );
    }
  }

  void search(String q) {
    searchQuery = q;
    applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Find Your PU'), backgroundColor: Colors.green[800]),
      body: Column(children: [
        Padding(padding: EdgeInsets.all(12), child: StateDropdown(
          onStateSelected: (code, name) {
            loadPUForState(code, name);
          },
        )),
        Padding(padding: EdgeInsets.all(12), child: TextField(
          onChanged: search,
          decoration: InputDecoration(
            hintText: 'Search PU code, name, LGA...',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.search),
            suffixIcon: searchQuery.isNotEmpty
                ? IconButton(icon: Icon(Icons.clear), onPressed: () { search(''); })
                : null,
          ),
        )),
        // LGA + WARD FILTERS
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: selectedLGA,
                  isExpanded: true,
                  decoration: InputDecoration(labelText: 'LGA', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                  items: [
                    DropdownMenuItem(value: null, child: Text('All LGAs')),
                    ...lgaList.map((l) => DropdownMenuItem(value: l, child: Text(l, overflow: TextOverflow.ellipsis))).toList()
                  ],
                  onChanged: (v) {
                    setState(() {
                      selectedLGA = v;
                      selectedWard = null;
                    });
                    _rebuildFilterOptions();
                    applyFilters();
                  },
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: selectedWard,
                  isExpanded: true,
                  decoration: InputDecoration(labelText: 'Ward', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                  items: [
                    DropdownMenuItem(value: null, child: Text('All Wards')),
                    ...wardList.map((w) => DropdownMenuItem(value: w, child: Text(w, overflow: TextOverflow.ellipsis))).toList()
                  ],
                  onChanged: (v) {
                    setState(() => selectedWard = v);
                    applyFilters();
                  },
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$currentStateName: ${filtered.length} PUs', style: TextStyle(fontWeight: FontWeight.bold)),
              if (selectedLGA != null || selectedWard != null)
                TextButton(onPressed: () {
                  setState(() {
                    selectedLGA = null;
                    selectedWard = null;
                  });
                  _rebuildFilterOptions();
                  applyFilters();
                }, child: Text('Clear')),
            ],
          ),
        ),
        Expanded(child: ListView.builder(itemCount: filtered.length, itemBuilder: (_, i) {
          var pu = filtered[i];
          return ListTile(
            title: Text('${pu['pu_code']} - ${pu['pu_name'] ?? pu['polling_unit_name'] ?? 'PU'}'),
            subtitle: Text('${pu['lga']}, ${pu['ward']}'),
            trailing: Icon(Icons.arrow_forward_ios, size: 12),
          );
        }))
      ]),
    );
  }
}
