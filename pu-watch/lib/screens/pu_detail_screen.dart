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

  // FINAL INEC 18 - Jan 16, 2027
  final List<String> allParties = ['AA','ADP','APP','AAC','ADC','APC','APM','BP','DLA','LP','NDP','NRM','NDC','PDP','PRP','SDP','YPP','ZLP'];

  final Map<String,String> candidateMap = {
    'AAC': 'Sowore',
    'ADC': 'Atiku',
    'APM': 'Seyi Makinde',
    'NDC': 'Peter Obi',
    'APC': 'Tinubu',
    'PDP': 'Sandy Onor',
    'PRP': 'Donald Duke',
    'SDP': 'Adebayo',
    'AA': 'Omo-Aje',
    'ADP': 'Abbas-Bin',
    'APP': 'Kabiru',
    'BP': 'Adenuga',
    'DLA': 'Adebisi',
    'LP': 'Okereke',
    'NDP': 'Ada Okwori',
    'NRM': 'Nkem Okereke',
    'YPP': 'Agada',
    'ZLP': 'Nwanyanwu',
  };

  Map<String, TextEditingController> ctrls = {};

  @override
  void initState(){
    super.initState();
    for(var p in allParties){ ctrls[p]=TextEditingController(text:'0'); }
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

    var result = ElectionResult(
      puCode: widget.pu['pu_code'].toString(),
      lga: widget.pu['lga'].toString(),
      ward: widget.pu['ward'].toString(),
      stateCode: widget.stateCode,
      accredited: int.tryParse(accredCtrl.text)??0,
      apc: int.tryParse(ctrls['APC']!.text)??0,
      adc: int.tryParse(ctrls['ADC']!.text)??0,
      ndc: int.tryParse(ctrls['NDC']!.text)??0,
      apm: int.tryParse(ctrls['APM']!.text)??0,
      aac: int.tryParse(ctrls['AAC']!.text)??0,
      pdp: int.tryParse(ctrls['PDP']!.text)??0,
      aa: int.tryParse(ctrls['AA']!.text)??0,
      adp: int.tryParse(ctrls['ADP']!.text)??0,
      app: int.tryParse(ctrls['APP']!.text)??0,
      bp: int.tryParse(ctrls['BP']!.text)??0,
      dla: int.tryParse(ctrls['DLA']!.text)??0,
      lp: int.tryParse(ctrls['LP']!.text)??0,
      ndp: int.tryParse(ctrls['NDP']!.text)??0,
      nrm: int.tryParse(ctrls['NRM']!.text)??0,
      prp: int.tryParse(ctrls['PRP']!.text)??0,
      sdp: int.tryParse(ctrls['SDP']!.text)??0,
      ypp: int.tryParse(ctrls['YPP']!.text)??0,
      zlp: int.tryParse(ctrls['ZLP']!.text)??0,
      others: 0,
      photoPath: resultPhoto!.path,
      timestamp: DateTime.now(),
    );

    var box = await Hive.openBox('results');
    await box.add(result.toJson());

    setState(()=>isSaving=false);
    if(mounted){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ ${widget.pu['pu_code']} saved: ${result.totalCounted} votes - NDC(Obi): ${result.ndc} | ADC(Atiku): ${result.adc} | APM(Makinde): ${result.apm}'), backgroundColor: Colors.green[800]));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> visible = showAll? allParties : ['APC','ADC','NDC','APM','AAC','PDP'];
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
              Text('Party Scores - 2027 Final', style: TextStyle(fontWeight: FontWeight.bold)),
              TextButton(onPressed: ()=>setState(()=>showAll=!showAll), child: Text(showAll?'Show Less ↑':'Show Top 6 + All 18 ↓')),
            ]),
            GridView.builder(
              shrinkWrap: true, physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 2.6, crossAxisSpacing: 8, mainAxisSpacing: 8),
              itemCount: visible.length,
              itemBuilder: (_,i){
                var p = visible[i];
                var cand = candidateMap[p]??'';
                return TextFormField(
                  controller: ctrls[p],
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: '$p - $cand',
                    labelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(10)
                  )
                );
              },
            ),
            if(showAll) Padding(padding: EdgeInsets.only(top: 8), child: Text('INEC Final Sept 2026: ADC=Atiku/Amaechi, NDC=Obi/Kwankwaso, APM=Makinde/Daura, AAC=Sowore. Enter 0 if no vote.', style: TextStyle(fontSize: 11, color: Colors.grey[600]))),
            SizedBox(height: 24),
            SizedBox(width: double.infinity, height: 50, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.green[800]), onPressed: isSaving?null:saveResult, child: isSaving?CircularProgressIndicator(color: Colors.white):Text('SAVE RESULT 📴 (Offline)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
          ]),
        ),
      ),
    );
  }
}
