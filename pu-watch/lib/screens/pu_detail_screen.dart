import 'package:flutter/material.dart';
import '../models/election_result.dart';
import 'package:image_picker/image_picker.dart';

class PUDetailScreen extends StatefulWidget {
  final Map<String, dynamic> pu;
  const PUDetailScreen({super.key, required this.pu});
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

  String get puCode {
    if (widget.pu['pu_code']!= null) return widget.pu['pu_code'].toString();
    if (widget.pu['puCode']!= null) return widget.pu['puCode'].toString();
    if (widget.pu['code']!= null) return widget.pu['code'].toString();
    return 'PU';
  }
  String get lgaVal { if (widget.pu['lga']!= null) return widget.pu['lga'].toString(); return ''; }
  String get wardVal { if (widget.pu['ward']!= null) return widget.pu['ward'].toString(); return ''; }
  String get stateCode { if (widget.pu['state']!= null) return widget.pu['state'].toString(); if (widget.pu['stateCode']!= null) return widget.pu['stateCode'].toString(); return ''; }
  String get puName { if (widget.pu['pu_name']!= null) return widget.pu['pu_name'].toString(); if (widget.pu['name']!= null) return widget.pu['name'].toString(); return puCode; }

  @override
  void initState() {
    super.initState();
    for (var p in ElectionResult.allParties) { controllers[p] = TextEditingController(); }
  }
  @override
  void dispose() {
    for (var c in controllers.values) { c.dispose(); }
    accreditedController.dispose(); othersController.dispose(); super.dispose();
  }
  Future<void> pickImage() async {
    final XFile? file = await picker.pickImage(source: ImageSource.camera, imageQuality: 70);
    if (file!= null) { setState(() { imagePath = file.path; }); }
  }
  void saveResult() {
    Map<String, int> votes = {};
    for (var p in ElectionResult.allParties) {
      String txt = controllers[p]!= null? controllers[p]!.text : '0';
      int v = int.tryParse(txt)?? 0; votes[p] = v;
    }
    int accredited = int.tryParse(accreditedController.text)?? 0;
    int others = int.tryParse(othersController.text)?? 0;
    final result = ElectionResult(
      puCode: puCode, lga: lgaVal, ward: wardVal, stateCode: stateCode,
      electionType: selectedElection, accredited: accredited, partyVotes: votes, others: others,
      photoPath: imagePath!= null? imagePath! : '', timestamp: DateTime.now(), synced: false,
    );
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Saved ' + result.electionType.label + ' for ' + result.puCode + ' (Offline)')));
  }
  @override
  Widget build(BuildContext context) {
    List<DropdownMenuItem<ElectionType>> dropdownItems = [];
    for (var e in ElectionType.values) { dropdownItems.add(DropdownMenuItem(value: e, child: Text(e.label + ' - ' + e.ecForm))); }
    List<Widget> gridChildren = [];
    for (var party in ElectionResult.allParties) {
      gridChildren.add(TextField(controller: controllers[party], keyboardType: TextInputType.number, decoration: InputDecoration(labelText: party, border: OutlineInputBorder(), isDense: true)));
    }
    gridChildren.add(TextField(controller: othersController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Others / Invalid', border: OutlineInputBorder(), isDense: true)));
    return Scaffold(
      appBar: AppBar(title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(puCode, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), Text(puName, style: TextStyle(fontSize: 12))])),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Card(child: Padding(padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4), child: DropdownButton<ElectionType>(value: selectedElection, isExpanded: true, underline: SizedBox(), items: dropdownItems, onChanged: (v) { if (v!= null) { setState(() { selectedElection = v; }); } }))),
            SizedBox(height: 8),
            Text('Party Scores - ' + selectedElection.label, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 4), Text(stateCode + ' / ' + lgaVal + ' / ' + wardVal, style: TextStyle(color: Colors.grey)),
            SizedBox(height: 12),
            TextField(controller: accreditedController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Accredited Voters *', border: OutlineInputBorder())),
            SizedBox(height: 12),
            GridView.count(crossAxisCount: 2, shrinkWrap: true, physics: NeverScrollableScrollPhysics(), childAspectRatio: 3.2, mainAxisSpacing: 8, crossAxisSpacing: 8, children: gridChildren),
            SizedBox(height: 16),
            Row(children: [ElevatedButton.icon(onPressed: pickImage, icon: Icon(Icons.camera_alt), label: Text(imagePath == null? 'Capture EC8 Photo' : 'Retake Photo')), SizedBox(width: 12), imagePath!= null? Icon(Icons.check_circle, color: Colors.green) : SizedBox()]),
            SizedBox(height: 20),
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: saveResult, style: ElevatedButton.styleFrom(padding: EdgeInsets.all(16)), child: Text('SAVE RESULT (Offline)'))),
          ],
        ),
      ),
    );
  }
}
