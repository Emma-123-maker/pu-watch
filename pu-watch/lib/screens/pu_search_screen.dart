import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'pu_detail_screen.dart';

class PUSearchScreen extends StatefulWidget {
  const PUSearchScreen({super.key});
  @override State<PUSearchScreen> createState() => _PUSearchScreenState();
}

class _PUSearchScreenState extends State<PUSearchScreen> {
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _allPUs = [];
  List<Map<String, dynamic>> _filteredPUs = [];
  bool _isLoading = true;
  String _info = '';

  @override
  void initState() {
    super.initState();
    _loadAllStates();
    _searchController.addListener(_filter);
  }

  String _g(Map m, List<String> keys) {
    for (var k in keys) {
      if (m[k]!=null && m[k].toString().trim().isNotEmpty) return m[k].toString().trim();
    }
    return '';
  }

  Map<String, dynamic> _norm(Map<String, dynamic> raw) {
    return {
      'pu_code': _g(raw, ['pu_code','code','id','delimitation']),
      'pu_name': _g(raw, ['pu_name','name','polling_unit_name']),
      'lga': _g(raw, ['lga','lgaName','lga_name','LGA']),
      'ward': _g(raw, ['ward','wardName','ward_name','reg_area']),
      'state': _g(raw, ['state','stateName','state_name']),
      'stateCode': _g(raw, ['stateCode','state_code']),
     ...raw,
    };
  }

  Future<void> _loadAllStates() async {
    List<Map<String, dynamic>> all = [];
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final files = manifest.listAssets().where((p) => p.contains('assets/data/states/') && p.endsWith('.json')).toList();

      for (var path in files) {
        try {
          final str = await rootBundle.loadString(path);
          final dyn = jsonDecode(str);
          List list = dyn is List? dyn : (dyn['data']?? dyn['pus']?? []);
          all.addAll(list.where((e) => e!=null).map((e) => _norm(Map<String, dynamic>.from(e))));
        } catch (_) {}
      }
      setState(() {
        _allPUs = all; _filteredPUs = all; _isLoading = false;
        _info = '${files.length} states | ${all.length} PUs loaded';
      });
      return;
    } catch (e) {
      // fallback for older Flutter - AssetManifest.json
      try {
        final manifestContent = await rootBundle.loadString('AssetManifest.json');
        final Map<String, dynamic> manifestMap = jsonDecode(manifestContent);
        final files = manifestMap.keys.where((k) => k.contains('assets/data/states/')).toList();
        for (var path in files) {
          try {
            final str = await rootBundle.loadString(path);
            final dyn = jsonDecode(str);
            List list = dyn is List? dyn : (dyn['data']?? []);
            all.addAll(list.map((e) => _norm(Map<String, dynamic>.from(e))));
          } catch (_) {}
        }
      } catch (_) {}
    }

    if (all.isEmpty) {
      try {
        final s = await rootBundle.loadString('assets/data/pu_sample.json');
        final d = jsonDecode(s);
        List list = d is List? d : (d['data']??[]);
        all = list.map((e)=> _norm(Map<String,dynamic>.from(e))).toList();
      } catch (_) {}
    }

    setState(() {
      _allPUs = all; _filteredPUs = all; _isLoading = false;
      _info = all.isEmpty? 'No PUs found - check pubspec' : '${all.length} PUs';
    });
  }

  void _filter() {
    final q = _searchController.text.toLowerCase().trim();
    if (q.isEmpty) { setState(()=> _filteredPUs = _allPUs); return; }
    setState(()=> _filteredPUs = _allPUs.where((pu) => pu.values.join(' ').toLowerCase().contains(q)).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PU-Watch 2027 - Search PU')),
      body: Column(children: [
        Padding(padding: const EdgeInsets.all(12), child: TextField(controller: _searchController, decoration: InputDecoration(labelText: 'Search code, name, LGA, ward, state', prefixIcon: const Icon(Icons.search), border: const OutlineInputBorder()))),
        Padding(padding: const EdgeInsets.symmetric(horizontal:12), child: Align(alignment: Alignment.centerLeft, child: Text(_info, style: const TextStyle(fontSize:11,color:Colors.green,fontWeight:FontWeight.bold)))),
        const SizedBox(height:4),
        if (_isLoading) const Expanded(child: Center(child: CircularProgressIndicator()))
        else Expanded(child: ListView.separated(itemCount: _filteredPUs.length, separatorBuilder: (_,__)=>const Divider(height:1), itemBuilder: (_,i){
          final pu = _filteredPUs[i];
          return ListTile(title: Text(pu['pu_code']??'', style: const TextStyle(fontWeight:FontWeight.bold)), subtitle: Text('${pu['pu_name']}\n${pu['state']} / ${pu['lga']} / ${pu['ward']}'), isThreeLine: true, trailing: const Icon(Icons.chevron_right), onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (_)=> PUDetailScreen(pu: Map<String,dynamic>.from(pu)))));
        })),
      ]),
    );
  }
}
