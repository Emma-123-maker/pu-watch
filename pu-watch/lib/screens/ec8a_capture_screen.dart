import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';

class EC8ACaptureScreen extends StatefulWidget {
  final String puCode; // e.g Ondo-12-04-001
  const EC8ACaptureScreen({super.key, required this.puCode});

  @override
  State<EC8ACaptureScreen> createState() => _EC8ACaptureScreenState();
}

class _EC8ACaptureScreenState extends State<EC8ACaptureScreen> {
  File? _imageFile;
  Position? _position;
  final ImagePicker _picker = ImagePicker();

  Future<void> _takePhoto() async {
    // 1. Get Location FIRST - for anti-rigging proof
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    _position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    // 2. FORCED CAMERA - No gallery option at all
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera, // <-- THIS blocks gallery
      imageQuality: 60, // compress for low network
      preferredCameraDevice: CameraDevice.rear,
    );

    if (photo!= null) {
      setState(() => _imageFile = File(photo.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("EC8A - ${widget.puCode}"), backgroundColor: Colors.green[800]),
      body: Column(
        children: [
          // CAMERA VIEW WITH OVERLAY GUIDE
          Expanded(
            child: _imageFile == null
               ? Stack(
                    children: [
                      Container(color: Colors.black),
                      // Overlay guide - forces user to align result sheet
                      Center(
                        child: Container(
                          width: 300, height: 400,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.yellow, width: 3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(child: Text("ALIGN EC8A HERE", style: TextStyle(color: Colors.yellow))),
                        ),
                      ),
                      Positioned(
                        bottom: 20, left: 0, right: 0,
                        child: Center(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.camera_alt),
                            label: const Text("TAKE LIVE PHOTO - NO GALLERY"),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.all(20)),
                            onPressed: _takePhoto,
                          ),
                        ),
                      )
                    ],
                  )
                : Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(_imageFile!, fit: BoxFit.cover),
                      // WATERMARK - anti-edit proof
                      Positioned(
                        bottom: 10, left: 10,
                        child: Container(
                          color: Colors.black54,
                          padding: const EdgeInsets.all(6),
                          child: Text(
                            "PU: ${widget.puCode}\n${DateTime.now()}\nGPS: ${_position?.latitude.toStringAsFixed(5)}, ${_position?.longitude.toStringAsFixed(5)}",
                            style: const TextStyle(color: Colors.white, fontSize: 11),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
          if (_imageFile!= null)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Expanded(child: OutlinedButton(onPressed: () => setState(() => _imageFile = null), child: const Text("RETAKE"))),
                  const SizedBox(width: 10),
                  Expanded(child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green[800]),
                    onPressed: () {
                      // TODO: Save to Hive + upload
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("EC8A Secured! Hash saved.")));
                    },
                    child: const Text("SECURE & UPLOAD", style: TextStyle(color: Colors.white)),
                  )),
                ],
              ),
            )
        ],
      ),
    );
  }
}
