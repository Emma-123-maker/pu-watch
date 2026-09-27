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

  // Dropdown state
  String? _selectedState;
  String? _selectedLGA;
  String? _selectedWard;
  List<String> _states = [];
  List<String> _lgas = [];
  List<String> _wards = [];

  @override
  void initState() {
    super.initState();
    _loadAllStates();
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.removeListener(_applyFilters);
    _searchController.dispose();
    super.dispose();
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
      'lga': _g(raw, ['lga','lgaName','lga_name','LGA']).toUpperCase(),
      'ward': _g(raw, ['ward','wardName','ward_name','reg_area']).toUpperCase(),
      'state': _g(raw, ['state','stateName','state_name']).trim(),
      'stateCode': _g(raw, ['stateCode','state_code']),
    ...raw,
      // keep normalized copies for filter
      'lga_norm': _g(raw, ['lga','lgaName','lga_name','LGA']).toUpperCase(),
      'ward_norm': _g(raw, ['ward','wardName','ward_name','reg_area']).toUpperCase(),
      'state_norm': _g(raw, ['state','stateName','state_name']).trim(),
    };
  }

  Future<void> _loadAllStates() async {
    List<Map<String, dynamic>> all = [];
    List<String> filesLoaded = [];
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      filesLoaded = manifest.listAssets().where((p) => p.contains('assets/data/states/') && p.endsWith('.json')).toList();

      for (var path in filesLoaded) {
        try {
          final str = await rootBundle.loadString(path);
          final dyn = jsonDecode(str);
          List list = dyn is List? dyn : (dyn['data']?? dyn['pus']?? []);
          all.addAll(list.where((e) => e!=null).map((e) => _norm(Map<String, dynamic>.from(e))));
        } catch (_) {}
      }
    } catch (e) {
      try {
        final manifestContent = await rootBundle.loadString('AssetManifest.json');
        final Map<String, dynamic> manifestMap = jsonDecode(manifestContent);
        filesLoaded = manifestMap.keys.where((k) => k.contains('assets/data/states/')).toList();
        for (var path in filesLoaded) {
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

    // Build states list
    final stateSet = <String>{};
    for (var pu in all) { if(pu['state'].toString().isNotEmpty) stateSet.add(pu['state'].toString()); }

    setState(() {
      _allPUs = all;
      _filteredPUs = all;
      _isLoading = false;
      _states = stateSet.toList()..sort();
      _info = filesLoaded.isNotEmpty? '${filesLoaded.length} states | ${all.length} PUs loaded' : '${all.length} PUs loaded';
    });
  }

  void _onStateChanged(String? val) {
    setState(() {
      _selectedState = val;
      _selectedLGA = null;
      _selectedWard = null;
      _lgas = [];
      _wards = [];
      if (val!= null) {
        final lgasSet = <String>{};
        for (var pu in _allPUs.where((p)=> p['state']==val)) { if(pu['lga'].toString().isNotEmpty) lgasSet.add(pu['lga'].toString()); }
        _lgas = lgasSet.toList()..sort();
      }
    });
    _applyFilters();
  }

  void _onLGAChanged(String? val) {
    setState(() {
      _selectedLGA = val;
      _selectedWard = null;
      _wards = [];
      if (val!= null && _selectedState!= null) {
        final wardSet = <String>{};
        for (var pu in _allPUs.where((p)=> p['state']==_selectedState && p['lga']==val)) { if(pu['ward'].toString().isNotEmpty) wardSet.add(pu['ward'].toString()); }
        _wards = wardSet.toList()..sort();
      }
    });
    _applyFilters();
  }

  void _onWardChanged(String? val) {
    setState(() => _selectedWard = val);
    _applyFilters();
  }

  void _applyFilters() {
    final q = _searchController.text.toLowerCase().trim();
    setState(() {
      _filteredPUs = _allPUs.where((pu) {
        if (_selectedState!= null && pu['state']!= _selectedState) return false;
        if (_selectedLGA!= null && pu['lga']!= _selectedLGA) return false;
        if (_selectedWard!= null && pu['ward']!= _selectedWard) return false;
        if (q.isNotEmpty) {
          final hay = '${pu['pu_code']} ${pu['pu_name']} ${pu['lga']} ${pu['ward']} ${pu['state']}'.toLowerCase();
          if (!hay.contains(q)) return false;
        }
        return true;
      }).toList();
    });
  }

  void _clearAll() {
    setState(() {
      _selectedState = null; _selectedLGA = null; _selectedWard = null;
      _lgas = []; _wards = [];
      _searchController.clear();
      _filteredPUs = _allPUs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PU-Watch 2027 - Search PU')),
      body: Column(children: [
        // FILTERS SECTION
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(children: [
            // State dropdown
            DropdownButtonFormField<String>(
              value: _selectedState,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Select State', border: OutlineInputBorder(), isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
              items: _states.map((s) => DropdownMenuItem(value: s, child: Text(s, overflow: TextOverflow.ellipsis))).toList(),
              onChanged: _onStateChanged,
            ),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedLGA,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Select LGA', border: OutlineInputBorder(), isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                  items: _lgas.map((l) => DropdownMenuItem(value: l, child: Text(l, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis))).toList(),
                  onChanged: _selectedState==null? null : _onLGAChanged,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedWard,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Select Ward', border: OutlineInputBorder(), isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                  items: _wards.map((w) => DropdownMenuItem(value: w, child: Text(w, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis))).toList(),
                  onChanged: _selectedLGA==null? null : _onWardChanged,
                ),
              ),
            ]),
            const SizedBox(height: 8),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search code, name, LGA, ward, state',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                isDense: true,
                suffixIcon: (_selectedState!=null || _searchController.text.isNotEmpty)
                 ? IconButton(icon: const Icon(Icons.clear), onPressed: _clearAll) : null,
              ),
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal:12),
          child: Align(alignment: Alignment.centerLeft, child: Text('$_info | Showing ${_filteredPUs.length} PUs', style: const TextStyle(fontSize:11,color:Colors.green,fontWeight:FontWeight.bold))),
        ),
        const SizedBox(height:4),
        if (_isLoading) const Expanded(child: Center(child: CircularProgressIndicator()))
        else Expanded(
          child: _filteredPUs.isEmpty
         ? const Center(child: Text('No PU matches your filter'))
          : ListView.separated(
            itemCount: _filteredPUs.length > 3000? 3000 : _filteredPUs.length,
            separatorBuilder: (_,__)=>const Divider(height:1),
            itemBuilder: (_,i){
              final pu = _filteredPUs[i];
              return ListTile(
                title: Text(pu['pu_code']??'', style: const TextStyle(fontWeight:FontWeight.bold)),
                subtitle: Text('${pu['pu_name']}\n${pu['state']} / ${pu['lga']} / ${pu['ward']}'),
                isThreeLine: true,
                trailing: const Icon(Icons.chevron_right),
                onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (_)=> PUDetailScreen(pu: Map<String,dynamic>.from(pu)))),
              );
            },
          ),
        ),
        if (_filteredPUs.length > 3000)
          const Padding(padding: EdgeInsets.all(6), child: Text('Showing first 3000 - filter by State/LGA/Ward to narrow', style: TextStyle(fontSize:10, color: Colors.grey))),
      ]),
    );
  }
}
