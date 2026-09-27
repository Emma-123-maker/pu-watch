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
  String _loadedFrom = 'dummy';

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

  String _get(Map<String, dynamic> m, List<String> keys) {
    for (var k in keys) {
      if (m.containsKey(k) && m[k]!= null && m[k].toString().trim().isNotEmpty) {
        return m[k].toString().trim();
      }
    }
    return '';
  }

  Map<String, dynamic> _normalize(Map<String, dynamic> raw) {
    final code = _get(raw, ['pu_code','code','PU_CODE','puCode','id','PUcode','delimitation']);
    final name = _get(raw, ['pu_name','name','PU_NAME','polling_unit_name','puName']);
    final lga = _get(raw, ['lga','lgaName','lga_name','LGA','LGA_NAME']);
    final ward = _get(raw, ['ward','wardName','ward_name','WARD','WARD_NAME','reg_area']);
    final state = _get(raw, ['state','stateName','state_name','STATE','STATE_NAME','stateCode']);
    final stateCode = _get(raw, ['stateCode','state_code','state_code_id','STATE_CODE']);

    return {
      'pu_code': code.isNotEmpty? code : 'PU',
      'code': code.isNotEmpty? code : 'PU',
      'pu_name': name.isNotEmpty? name : code,
      'name': name.isNotEmpty? name : code,
      'lga': lga,
      'lgaName': lga,
      'ward': ward,
      'wardName': ward,
      'state': state,
      'stateName': state,
      'stateCode': stateCode.isNotEmpty? stateCode : state,
      // keep all original fields too
     ...raw,
    };
  }

  Future<void> _loadPUs() async {
    // List of possible file locations - add yours here
    final candidates = [
      'assets/pu_data.json',
      'assets/data/pu_data.json',
      'assets/pus.json',
      'assets/data/pus.json',
      'assets/oyo_pus.json',
      'assets/data/oyo_pus.json',
      'assets/polling_units.json',
      'assets/data/polling_units.json',
      'assets/data.json',
    ];

    for (var path in candidates) {
      try {
        final jsonString = await rootBundle.loadString(path);
        final dynamic decoded = jsonDecode(jsonString);
        List<dynamic> list;
        if (decoded is List) {
          list = decoded;
        } else if (decoded is Map && decoded.containsKey('data')) {
          list = decoded['data'] as List;
        } else if (decoded is Map && decoded.containsKey('polling_units')) {
          list = decoded['polling_units'] as List;
        } else {
          continue;
        }

        final normalized = list.map((e) => _normalize(Map<String, dynamic>.from(e as Map))).toList();

        if (normalized.isNotEmpty) {
          setState(() {
            _allPUs = normalized;
            _filteredPUs = normalized;
            _isLoading = false;
            _loadedFrom = '$path (${normalized.length} PUs)';
          });
          return;
        }
      } catch (_) {
        // try next path
      }
    }

    // Fallback - your 3 Ibadan North PUs
    final List<Map<String, dynamic>> dummyData = [
      {
        'pu_code': '30-08-04-001',
        'pu_name': 'LEA PRIMARY SCHOOL, EMIR PALACE',
        'lga': 'IBADAN NORTH', 'ward': 'WARD 04', 'state': 'OYO', 'stateCode': '30',
      },
      {
        'pu_code': '30-08-04-002',
        'pu_name': 'OPEN SPACE, MARKET SQUARE',
        'lga': 'IBADAN NORTH', 'ward': 'WARD 04', 'state': 'OYO', 'stateCode': '30',
      },
      {
        'pu_code': '30-08-05-001',
        'pu_name': 'COMMUNITY HALL, AGUIYI',
        'lga': 'IBADAN NORTH', 'ward': 'WARD 05', 'state': 'OYO', 'stateCode': '30',
      },
    ].map((e) => _normalize(e)).toList();

    setState(() {
      _allPUs = dummyData;
      _filteredPUs = dummyData;
      _isLoading = false;
      _loadedFrom = 'dummy (3 PUs) - add your JSON to assets/';
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();
    if (query.isEmpty) {
      setState(() => _filteredPUs = _allPUs);
      return;
    }
    setState(() {
      _filteredPUs = _allPUs.where((pu) {
        final code = (pu['pu_code']?? '').toString().toLowerCase();
        final name = (pu['pu_name']?? '').toString().toLowerCase();
        final lga = (pu['lga']?? '').toString().toLowerCase();
        final ward = (pu['ward']?? '').toString().toLowerCase();
        final state = (pu['state']?? '').toString().toLowerCase();
        return code.contains(query) || name.contains(query) || lga.contains(query) || ward.contains(query) || state.contains(query);
      }).toList();
    });
  }

  void _openPU(Map<String, dynamic> pu) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PUDetailScreen(pu: Map<String, dynamic>.from(pu))),
    );
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
                suffixIcon: _searchController.text.isNotEmpty
                   ? IconButton(icon: const Icon(Icons.clear), onPressed: () => _searchController.clear())
                    : null,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Align(alignment: Alignment.centerLeft, child: Text(_loadedFrom, style: const TextStyle(fontSize: 10, color: Colors.grey))),
          ),
          const SizedBox(height: 4),
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else
            Expanded(
              child: _filteredPUs.isEmpty
                 ? const Center(child: Text('No PU found'))
                  : ListView.separated(
                      itemCount: _filteredPUs.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final pu = _filteredPUs[index];
                        final code = pu['pu_code']?? 'PU';
                        final name = pu['pu_name']?? code;
                        final lga = pu['lga']?? '';
                        final ward = pu['ward']?? '';
                        final state = pu['state']?? pu['stateCode']?? '';
                        return ListTile(
                          title: Text(code.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('$name\n$state / $lga / $ward'),
                          isThreeLine: true,
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _openPU(pu),
                        );
                      },
                    ),
            ),
        ],
      ),
    );
  }
}
