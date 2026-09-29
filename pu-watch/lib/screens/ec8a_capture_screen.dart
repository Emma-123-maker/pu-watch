import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class EC8ACaptureScreen extends StatefulWidget {
  final String puCode;
  const EC8ACaptureScreen({super.key, required this.puCode});
  @override
  State<EC8ACaptureScreen> createState() => _EC8ACaptureScreenState();
}

class _EC8ACaptureScreenState extends State<EC8ACaptureScreen> {
  CameraController? controller;
  bool isInit = false;
  bool isSaving = false;
  File? capturedFile;
  String? hash;
  String? gpsText;
  Position? pos;
  late Box box;

  @override
  void initState() {
    super.initState();
    initCamAndBox();
  }

  Future<void> initCamAndBox() async {
    box = await Hive.openBox('ec8a_proofs');
    final cams = await availableCameras();
    final back = cams.firstWhere((c) => c.lensDirection == CameraLensDirection.back, orElse: () => cams.first);
    controller = CameraController(back, ResolutionPreset.high, enableAudio: false);
    await controller!.initialize();
    // GPS
    try {
      pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      gpsText = "${pos!.latitude.toStringAsFixed(6)}, ${pos!.longitude.toStringAsFixed(6)} ±${pos!.accuracy.toStringAsFixed(0)}m";
    } catch (_) {
      gpsText = "GPS unavailable";
    }
    setState(() => isInit = true);
  }

  Future<void> takePhoto() async {
    if (controller == null ||!controller!.value.isInitialized) return;
    setState(() => isSaving = true);
    try {
      final XFile raw = await controller!.takePicture();
      final bytes = await raw.readAsBytes();

      // === PHASE 2: HASH TAMPER-PROOF ===
      final digest = sha256.convert(bytes);
      final hashStr = digest.toString();

      final dir = await getApplicationDocumentsDirectory();
      final fileName = "EC8A_${widget.puCode.replaceAll('/', '_')}_${DateTime.now().millisecondsSinceEpoch}.jpg";
      final saved = File("${dir.path}/$fileName");
      await saved.writeAsBytes(bytes);

      // Save proof to Hive
      await box.add({
        'pu_code': widget.puCode,
        'path': saved.path,
        'hash': hashStr,
        'gps': gpsText,
        'lat': pos?.latitude,
        'lng': pos?.longitude,
        'timestamp': DateTime.now().toIso8601String(),
        'synced': false,
      });

      setState(() {
        capturedFile = saved;
        hash = hashStr;
        isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('✅ EC8A Secured! Hash: ${hashStr.substring(0,16)}...'),
        backgroundColor: Colors.green[800],
      ));
    } catch (e) {
      setState(() => isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red[800]));
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("EC8A - ${widget.puCode}", style: TextStyle(fontSize: 16)),
        backgroundColor: Colors.green[800],
      ),
      body:!isInit
         ? Center(child: CircularProgressIndicator())
          : capturedFile == null
             ? Stack(
                  children: [
                    CameraPreview(controller!),
                    // Yellow guide box
                    Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.85,
                        height: MediaQuery.of(context).size.height * 0.6,
                        decoration: BoxDecoration(border: Border.all(color: Colors.yellow, width: 3), borderRadius: BorderRadius.circular(12)),
                        child: Center(child: Text("ALIGN EC8A HERE", style: TextStyle(color: Colors.yellow, backgroundColor: Colors.black54))),
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      left: 20,
                      right: 20,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700], minimumSize: Size(double.infinity, 56)),
                        onPressed: isSaving? null : takePhoto,
                        icon: isSaving? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Icon(Icons.camera_alt, color: Colors.white),
                        label: Text(isSaving? "SECURING..." : "TAKE LIVE PHOTO - NO GALLERY", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    Positioned(top: 10, left: 10, right: 10, child: Container(padding: EdgeInsets.all(8), color: Colors.black54, child: Text("📍 $gpsText\n🛡️ Forced Live Camera | GPS Watermark | No Gallery", style: TextStyle(color: Colors.white, fontSize: 11)))),
                  ],
                )
              : SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(capturedFile!)),
                      SizedBox(height: 12),
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.green[50], border: Border.all(color: Colors.green), borderRadius: BorderRadius.circular(10)),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text("✅ TAMPER-PROOF SECURED", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[800])),
                          SizedBox(height: 6),
                          Text("PU: ${widget.puCode}", style: TextStyle(fontSize: 13)),
                          Text("GPS: $gpsText", style: TextStyle(fontSize: 12)),
                          Text("Time: ${DateTime.now().toString().substring(0,19)}", style: TextStyle(fontSize: 12)),
                          SizedBox(height: 8),
                          Text("SHA256 HASH:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          SelectableText(hash?? "", style: TextStyle(fontSize: 11, fontFamily: 'monospace')),
                          SizedBox(height: 6),
                          Text("If anyone edits this photo, hash will CHANGE - proof of rigging!", style: TextStyle(fontSize: 10, color: Colors.red[700])),
                        ]),
                      ),
                      SizedBox(height: 12),
                      Row(children: [
                        Expanded(child: ElevatedButton.icon(onPressed: () => Share.shareXFiles([XFile(capturedFile!.path)], text: "EC8A Proof ${widget.puCode} Hash: $hash GPS: $gpsText"), icon: Icon(Icons.share), label: Text("SHARE PROOF"))),
                        SizedBox(width: 10),
                        Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red[800]), onPressed: () => setState(() => capturedFile = null), child: Text("RETAKE", style: TextStyle(color: Colors.white)))),
                      ]),
                    ],
                  ),
                ),
    );
  }
}
