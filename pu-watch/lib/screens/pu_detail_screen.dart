import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/election_result.dart';

class PUDetailScreen extends StatefulWidget {
  final Map pu;
  final String stateCode;
  final String stateName;
  const PUDetailScreen({super.key, required this.pu, required this.stateCode, required this.stateName});

  @override
  State<PUDetailScreen> createState() => _PUDetailScreenState();
}

class _PUDetailScreenState extends State<PUDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final accredCtrl = TextEditingController();
  XFile? resultPhoto;
  bool isSaving = false;
  bool showAll = false;

  final List<String> allParties = ['A','AA','AAC','ADC','ADP','APC','APGA','APM','APP','BP','LP','NNPP','NRM','PDP','PRP','SDP','YPP','ZLP'];
  Map<String, TextEditingController> ctrls = {};

  @override
  void initState(){
    super.initState();
    for(var p in allParties){ ctrls[p]=TextEditingController(); }
  }

  Future<void> pickPhoto() async {
    final p = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 65);
    if(p!=null) setState(()=>resultPhoto=p);
  }

  Future<void> saveResult() async {
    if (!_formKey.currentState!.validate()) return;
    if (resultPhoto == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('📸 Take photo of EC8A sheet first')));
      return;
    }
    setState(()=>isSaving=true);

    Map<String,int> results = {};
    for(var k in allParties){ results[k]=int.tryParse(ctrls[k]!.text)??0; }

    var result = ElectionResult(
      puCode: widget.pu['pu_code'].toString(),
      lga: widget.pu['lga'].toString(),
      ward: widget.pu['ward'].toString(),
      stateCode: widget.stateCode,
      accredited: int.tryParse(accredCtrl.text)??0,
      parties: results,
      photoPath: resultPhoto!.path,
      timestamp: DateTime.now(),
    );

    var box = await Hive.openBox('results');
    await box.add(result.toJson());

    setState(()=>isSaving=false);
    if(mounted){
      int total = results.values.fold(0,(a,b)=>a+b);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ ${widget.pu['pu_code']} saved: $total votes counted'), backgroundColor: Colors.green[800]));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> visible = showAll? allParties : ['APC','PDP','LP'];
    return Scaffold(
      appBar: AppBar(title: Text(widget.pu['pu_code'].toString()), backgroundColor: Colors.green[800]),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${widget.pu['pu_name']}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('${widget.pu['lga']}, ${widget.pu['ward']} - ${widget.stateName}', style: TextStyle(color: Colors.grey[700])),
            SizedBox(height: 16),
            Text('Result Sheet Photo (EC8A)', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            GestureDetector(
              onTap: pickPhoto,
              child: Container(
                height: 180, width: double.infinity,
                decoration: BoxDecoration(border: Border.all(), borderRadius: BorderRadius.circular(12)),
                child: resultPhoto == null
                ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.camera_alt, size: 40), Text('Tap to snap result sheet')])
                  : Image.file(File(resultPhoto!.path), fit: BoxFit.cover),
              ),
            ),
            SizedBox(height: 16),
            TextFormField(controller: accredCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Accredited Voters *', border: OutlineInputBorder()), validator: (v)=>v!.isEmpty?'Required':null),
            SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Party Scores', style: TextStyle(fontWeight: FontWeight.bold)),
              TextButton(onPressed: ()=>setState(()=>showAll=!showAll), child: Text(showAll?'Show Less ↑':'Show All 18 Parties ↓')),
            ]),
            GridView.builder(
              shrinkWrap: true, physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 2.3, crossAxisSpacing: 8, mainAxisSpacing: 8),
              itemCount: visible.length,
              itemBuilder: (_,i){
                var p = visible[i];
                return TextFormField(controller: ctrls[p], keyboardType: TextInputType.number, decoration: InputDecoration(labelText: p, border: OutlineInputBorder(), contentPadding: EdgeInsets.all(8)));
              },
            ),
            if(showAll) Padding(padding: EdgeInsets.only(top: 8), child: Text('A=Action Alliance etc. Full INEC list. Enter 0 if no vote.', style: TextStyle(fontSize: 11, color: Colors.grey[600]))),
            SizedBox(height: 24),
            SizedBox(width: double.infinity, height: 50, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.green[800]), onPressed: isSaving?null:saveResult, child: isSaving?CircularProgressIndicator(color: Colors.white):Text('SAVE RESULT 📴 (Offline)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
          ]),
        ),
      ),
    );
  }
}
