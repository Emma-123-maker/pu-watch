import 'package:flutter/material.dart';
import '../models/election_result.dart';
import 'package:image_picker/image_picker.dart';

class PUDetailScreen extends StatefulWidget {
  final Map<String, dynamic> pu;

  // This constructor now accepts EITHER pu Map OR the old individual fields
  const PUDetailScreen({
    super.key,
    Map<String, dynamic>? pu,
    Map<String, dynamic>? originalPu,
    String? puCode,
    String? code,
    String? lga,
    String? lgaName,
    String? ward,
    String? wardName,
    String? stateCode,
    String? state,
    String? puName,
    String? pu_name,
    String? name,
  }) : pu = pu?? originalPu?? const {}!= const {}? _buildPu(pu, originalPu, puCode, code, lga, lgaName, ward, wardName, stateCode, state, puName, pu_name, name) : const {};

  static Map<String, dynamic> _buildPu(
    Map<String, dynamic>? pu,
    Map<String, dynamic>? originalPu,
    String? puCode,
    String? code,
    String? lga,
    String? lgaName,
    String? ward,
    String? wardName,
    String? stateCode,
    String? state,
    String? puName,
    String? pu_name,
    String? name,
  ) {
    if (pu!= null) return pu;
    if (originalPu!= null) return originalPu;
    return {
      'pu_code': puCode?? code?? 'PU',
      'code': puCode?? code?? 'PU',
      'puCode': puCode?? code?? 'PU',
      'lga': lga?? lgaName?? '',
      'ward': ward?? wardName?? '',
      'state': state?? stateCode?? '',
      'stateCode': state?? stateCode?? '',
      'pu_name': puName?? pu_name?? name?? puCode?? code?? 'PU',
      'name': puName?? pu_name?? name?? puCode?? code?? 'PU',
    };
  }

  @override
  State<PUDetailScreen> createState() => _PUDetailScreenState();
}

class _PUDetailScreenState extends State<PUDetailScreen> {
  ElectionType selectedElection = ElectionType.presidential;
  Map<String, TextEditingController> controllers = {};
  TextEditingController accreditedController = TextEditingController();
  TextEditingController othersController = TextEditingController();
  String? imagePath;
  final ImagePicker picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    for (var p in ElectionResult.allParties) {
      controllers[p] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (var c in controllers.values) { c.dispose(); }
    accreditedController.dispose();
    othersController.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final XFile? file = await picker.pickImage(source: ImageSource.camera, imageQuality: 70);
    if (file!= null) { setState(() { imagePath = file.path; }); }
  }

  void saveResult() {
    Map<String, int> votes = {};
    for (var p in ElectionResult.allParties) {
      var ctrl = controllers[p];
      int v = 0;
      if (ctrl!= null) { v = int.tryParse(ctrl.text)?? 0; }
      votes[p] = v;
    }
    int accredited = int.tryParse(accreditedController.text)?? 0;
    int others = int.tryParse(othersController.text)?? 0;
    String code = widget.pu['pu_code']!= null? widget.pu['pu_code'].toString() : (widget.pu['puCode']!= null? widget.pu['puCode'].toString() : 'PU');
    String lga = widget.pu['lga']!= null? widget.pu['lga'].toString() : '';
    String ward = widget.pu['ward']!= null? widget.pu['ward'].toString() : '';
    String state = widget.pu['state']!= null? widget.pu['state'].toString() : (widget.pu['stateCode']!= null? widget.pu['stateCode'].toString() : '');

    final result = ElectionResult(
      puCode: code, lga: lga, ward: ward, stateCode: state,
      electionType: selectedElection, accredited: accredited,
      partyVotes: votes, others: others,
      photoPath: imagePath?? '', timestamp: DateTime.now(), synced: false,
    );
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Saved ' + result.electionType.label + ' for ' + result.puCode)));
  }

  @override
  Widget build(BuildContext context) {
    String code = widget.pu['pu_code']!= null? widget.pu['pu_code'].toString() : (widget.pu['puCode']!= null? widget.pu['puCode'].toString() : 'PU');
    String lga = widget.pu['lga']!= null? widget.pu['lga'].toString() : '';
    String ward = widget.pu['ward']!= null? widget.pu['ward'].toString() : '';
    String state = widget.pu['state']!= null? widget.pu['state'].toString() : (widget.pu['stateCode']!= null? widget.pu['stateCode'].toString() : '');
    String name = widget.pu['pu_name']!= null? widget.pu['pu_name'].toString() : (widget.pu['name']!= null? widget.pu['name'].toString() : code);

    return Scaffold(
      appBar: AppBar(title: Text(code + ' - ' + name)),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButton<ElectionType>(
              value: selectedElection,
              isExpanded: true,
              items: ElectionType.values.map((e) {
                return DropdownMenuItem(value: e, child: Text(e.label + ' - ' + e.ecForm));
              }).toList(),
              onChanged: (v) { if (v!= null) setState(() { selectedElection = v; }); },
            ),
            SizedBox(height: 12),
            TextField(controller: accreditedController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Accredited Voters *', border: OutlineInputBorder())),
            SizedBox(height: 12),
            Text('Party Scores - ' + selectedElection.label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 8),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: ElectionResult.allParties.map((party) {
                return SizedBox(width: 150, child: TextField(controller: controllers[party], keyboardType: TextInputType.number, decoration: InputDecoration(labelText: party, border: OutlineInputBorder(), isDense: true)));
              }).toList(),
            ),
            SizedBox(height: 12),
            TextField(controller: othersController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Others / Invalid', border: OutlineInputBorder())),
            SizedBox(height: 16),
            ElevatedButton.icon(onPressed: pickImage, icon: Icon(Icons.camera_alt), label: Text(imagePath == null? 'Capture EC8' : 'Retake')),
            SizedBox(height: 20),
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: saveResult, child: Text('SAVE RESULT (Offline)'))),
            SizedBox(height: 8),
            Text(state + ' / ' + lga + ' / ' + ward, style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
