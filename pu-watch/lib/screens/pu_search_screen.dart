import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'pu_detail_screen.dart';

class PUSearchScreen extends StatefulWidget {
  const PUSearchScreen({super.key});

  @override
  State<PUSearchScreen> createState() => _PUSearchScreenState();
}

class _PUSearchScreenState extends State<PUSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _allPUs = [];
  List<Map<String, dynamic>> _filteredPUs = [];
  bool _isLoading = true;
  String _info = '';

  @override
  void initState() {
    super.initState();
    _loadPUs();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  String _g(Map<String, dynamic> m, List<String> keys) {
    for (var k in keys) {
      if (m[k]!= null && m[k].toString().trim().isNotEmpty) return m[k].toString().trim();
    }
    return '';
  }

  Map<String, dynamic> _normalize(Map<String, dynamic> raw) {
    return {
      'pu_code': _g(raw, ['pu_code','code','PU_CODE','id','delimitation','puCode']),
      'code': _g(raw, ['pu_code','code','PU_CODE','id']),
      'pu_name': _g(raw, ['pu_name','name','PU_NAME','puName','polling_unit_name']),
      'name': _g(raw, ['pu_name','name','PU_NAME','puName']),
      'lga': _g(raw, ['lga','lgaName','lga_name','LGA']),
      'ward': _g(raw, ['ward','wardName','ward_name','WARD','reg_area']),
      'state': _g(raw, ['state','stateName','state_name','STATE','stateCode']),
      'stateCode': _g(raw, ['stateCode','state_code','STATE_CODE','state']),
     ...raw,
    };
  }

  Future<void> _loadPUs() async {
    List<Map<String, dynamic>> all = [];

    // 1. Load pu_sample.json - your main file
    try {
      final s = await rootBundle.loadString('assets/data/pu_sample.json');
      final d = jsonDecode(s);
      List list = d is List? d : (d['data']?? d['polling_units']?? []);
      all.addAll(list.map((e) => _normalize(Map<String, dynamic>.from(e))));
      _info = 'pu_sample.json: ${all.length}';
    } catch (e) {
      _info = 'pu_sample.json failed: $e';
    }

    // 2. Also try states_index.json + all state files if sample is small
    if (all.length < 100) {
      try {
        final indexStr = await rootBundle.loadString('assets/data/states_index.json');
        final indexData = jsonDecode(indexStr);
        List states = indexData is List? indexData : (indexData['states']?? []);

        for (var st in states) {
          String code = '';
          if (st is Map) code = _g(Map<String, dynamic>.from(st), ['code','stateCode','id']);
          if (st is String) code = st;
          if (code.isEmpty) continue;

          final paths = [
            'assets/data/states/$code.json',
            'assets/data/states/${code.toLowerCase()}.json',
            'assets/data/states/${code.toUpperCase()}.json',
            'assets/data/states/30.json', // Oyo fallback
          ];

          for (var p in paths) {
            try {
              final s = await rootBundle.loadString(p);
              final d = jsonDecode(s);
              List list = d is List? d : (d['data']?? d['pus']?? []);
              final norm = list.map((e) => _normalize(Map<String, dynamic>.from(e))).toList();
              if (norm.isNotEmpty) {
                all.addAll(norm);
                break;
              }
            } catch (_) {}
          }
        }
        if (all.length > 3) _info = 'states/ folder: ${all.length} PUs';
      } catch (_) {}
    }

    if (all.isEmpty) {
      all = [
        _normalize({'pu_code':'30-08-04-001','pu_name':'LEA PRIMARY SCHOOL, EMIR PALACE','lga':'IBADAN NORTH','ward':'WARD 04','state':'OYO','stateCode':'30'}),
        _normalize({'pu_code':'30-08-04-002','pu_name':'OPEN SPACE, MARKET SQUARE','lga':'IBADAN NORTH','ward':'WARD 04','state':'OYO'}),
        _normalize({'pu_code':'30-08-05-001','pu_name':'COMMUNITY HALL, AGUIYI','lga':'IBADAN NORTH','ward':'WARD 05','state':'OYO'}),
      ];
      _info = 'Using dummy (assets not found)';
    }

    setState(() {
      _allPUs = all;
      _filteredPUs = all;
      _isLoading = false;
    });
  }

  void _onSearchChanged() {
    final q = _searchController.text.toLowerCase().trim();
    if (q.isEmpty) { setState(() => _filteredPUs = _allPUs); return; }
    setState(() {
      _filteredPUs = _allPUs.where((pu) {
        return pu.values.join(' ').toLowerCase().contains(q);
      }).toList();
    });
  }

  void _openPU(Map<String, dynamic> pu) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => PUDetailScreen(pu: Map<String, dynamic>.from(pu))));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PU-Watch 2027 - Search PU')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by PU code, name, LGA, ward',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: _searchController.text.isNotEmpty? IconButton(icon: const Icon(Icons.clear), onPressed: ()=> _searchController.clear()): null,
              ),
            ),
          ),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Align(alignment: Alignment.centerLeft, child: Text(_info, style: const TextStyle(fontSize: 10, color: Colors.grey)))),
          const SizedBox(height: 4),
          if (_isLoading) const Expanded(child: Center(child: CircularProgressIndicator()))
          else Expanded(
            child: ListView.separated(
              itemCount: _filteredPUs.length,
              separatorBuilder: (_,__)=> const Divider(height:1),
              itemBuilder: (context, i) {
                final pu = _filteredPUs[i];
                return ListTile(
                  title: Text(pu['pu_code'].toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${pu['pu_name']}\n${pu['state']} / ${pu['lga']} / ${pu['ward']}'),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: ()=> _openPU(pu),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
