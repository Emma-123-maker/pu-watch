import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hive/hive.dart';
import '../models/election_result.dart';
import '../services/offline_queue.dart';

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
  final apcCtrl = TextEditingController();
  final pdpCtrl = TextEditingController();
  final lpCtrl = TextEditingController();
  final othersCtrl = TextEditingController();
  XFile? resultPhoto;
  bool isSaving = false;

  Future<void> pickPhoto() async {
    final p = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 70);
    if (p != null) setState(() => resultPhoto = p);
  }

  Future<void> saveResult() async {
    if (!_formKey.currentState!.validate()) return;
    if (resultPhoto == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Take photo of result sheet')));
      return;
    }
    setState(() => isSaving = true);
    
    var result = ElectionResult(
      puCode: widget.pu['pu_code'].toString(),
      lga: widget.pu['lga'].toString(),
      ward: widget.pu['ward'].toString(),
      stateCode: widget.stateCode,
      accredited: int.parse(accredCtrl.text),
      apc: int.parse(apcCtrl.text.isEmpty ? '0' : apcCtrl.text),
      pdp: int.parse(pdpCtrl.text.isEmpty ? '0' : pdpCtrl.text),
      lp: int.parse(lpCtrl.text.isEmpty ? '0' : lpCtrl.text),
      others: int.parse(othersCtrl.text.isEmpty ? '0' : othersCtrl.text),
      photoPath: resultPhoto!.path,
      timestamp: DateTime.now(),
    );

    // save offline
    var box = await Hive.openBox<ElectionResult>('results');
    await box.add(result);
    
    // add to sync queue
    await OfflineQueue.instance.enqueueResult(result);

    setState(() => isSaving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ Result saved offline for ${widget.pu['pu_code']}'), backgroundColor: Colors.green[800]));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.pu['pu_code']), backgroundColor: Colors.green[800]),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${widget.pu['pu_name']}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('${widget.pu['lga']}, ${widget.pu['ward']} - ${widget.stateName}', style: TextStyle(color: Colors.grey[700])),
            SizedBox(height: 20),
            Text('Result Sheet Photo', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            GestureDetector(
              onTap: pickPhoto,
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(border: Border.all(), borderRadius: BorderRadius.circular(12)),
                child: resultPhoto == null
                  ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.camera_alt, size: 40), Text('Tap to snap result sheet')])
                  : Image.file(File(resultPhoto!.path), fit: BoxFit.cover),
              ),
            ),
            SizedBox(height: 20),
            TextFormField(controller: accredCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Accredited Voters *', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Required' : null),
            SizedBox(height: 12),
            Row(children: [
              Expanded(child: TextFormField(controller: apcCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'APC', border: OutlineInputBorder()))),
              SizedBox(width: 8),
              Expanded(child: TextFormField(controller: pdpCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'PDP', border: OutlineInputBorder()))),
            ]),
            SizedBox(height: 12),
            Row(children: [
              Expanded(child: TextFormField(controller: lpCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'LP', border: OutlineInputBorder()))),
              SizedBox(width: 8),
              Expanded(child: TextFormField(controller: othersCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Others', border: OutlineInputBorder()))),
            ]),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green[800]),
                onPressed: isSaving ? null : saveResult,
                child: isSaving ? CircularProgressIndicator(color: Colors.white) : Text('SAVE RESULT 📴 (Offline)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
