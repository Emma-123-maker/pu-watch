import 'package:flutter/material.dart';
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

  // Load your PU data - replace with your real JSON/assets if you have it
  Future<void> _loadPUs() async {
    // TODO: Replace with your real PU list from assets/data
    // Example structure expected by PUDetailScreen
    final List<Map<String, dynamic>> dummyData = [
      {
        'pu_code': '30-08-04-001',
        'code': '30-08-04-001',
        'pu_name': 'LEA PRIMARY SCHOOL, EMIR PALACE',
        'name': 'LEA PRIMARY SCHOOL, EMIR PALACE',
        'lga': 'IBADAN NORTH',
        'ward': 'WARD 04',
        'state': 'OYO',
        'stateCode': '30',
      },
      {
        'pu_code': '30-08-04-002',
        'code': '30-08-04-002',
        'pu_name': 'OPEN SPACE, MARKET SQUARE',
        'name': 'OPEN SPACE, MARKET SQUARE',
        'lga': 'IBADAN NORTH',
        'ward': 'WARD 04',
        'state': 'OYO',
        'stateCode': '30',
      },
      {
        'pu_code': '30-08-05-001',
        'code': '30-08-05-001',
        'pu_name': 'COMMUNITY HALL, AGUIYI',
        'name': 'COMMUNITY HALL, AGUIYI',
        'lga': 'IBADAN NORTH',
        'ward': 'WARD 05',
        'state': 'OYO',
        'stateCode': '30',
      },
    ];

    setState(() {
      _allPUs = dummyData;
      _filteredPUs = dummyData;
      _isLoading = false;
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();
    if (query.isEmpty) {
      setState(() {
        _filteredPUs = _allPUs;
      });
      return;
    }
    setState(() {
      _filteredPUs = _allPUs.where((pu) {
        final code = (pu['pu_code']?? pu['code']?? '').toString().toLowerCase();
        final name = (pu['pu_name']?? pu['name']?? '').toString().toLowerCase();
        final lga = (pu['lga']?? '').toString().toLowerCase();
        final ward = (pu['ward']?? '').toString().toLowerCase();
        return code.contains(query) ||
            name.contains(query) ||
            lga.contains(query) ||
            ward.contains(query);
      }).toList();
    });
  }

  void _openPU(Map<String, dynamic> pu) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PUDetailScreen(
          pu: Map<String, dynamic>.from(pu),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PU-Watch 2027 - Search PU'),
      ),
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
                   ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
              ),
            ),
          ),
          if (_isLoading)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else
            Expanded(
              child: _filteredPUs.isEmpty
                 ? const Center(child: Text('No PU found'))
                  : ListView.separated(
                      itemCount: _filteredPUs.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final pu = _filteredPUs[index];
                        final code = pu['pu_code']?? pu['code']?? 'PU';
                        final name = pu['pu_name']?? pu['name']?? code;
                        final lga = pu['lga']?? '';
                        final ward = pu['ward']?? '';
                        final state = pu['state']?? '';
                        return ListTile(
                          title: Text(code.toString(),
                              style: const TextStyle(fontWeight: FontWeight.bold)),
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
