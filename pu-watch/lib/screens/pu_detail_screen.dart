import 'package:flutter/material.dart';
import '../models/election_result.dart';
import 'package:image_picker/image_picker.dart';

// CLASS NAME MUST BE PUDetailScreen - capital PU - to match pu_search_screen.dart
class PUDetailScreen extends StatefulWidget {
  final String puCode;
  final String lga;
  final String ward;
  final String stateCode;
  final String puName;

  const PUDetailScreen({
    super.key,
    required this.puCode,
    required this.lga,
    required this.ward,
    required this.stateCode,
    required this.puName,
  });

  @override
  State<PUDetailScreen> createState() => _PUDetailScreenState();
}

class _PUDetailScreenState extends State<PUDetailScreen> {
  ElectionType _selectedElection = ElectionType.presidential;
  final Map<String, TextEditingController> _controllers = {
    for (var p in ElectionResult.allParties) p: TextEditingController()
  };
  final _accreditedController = TextEditingController();
  final _othersController = TextEditingController();
  String? _imagePath;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    for (var c in _controllers.values) c.dispose();
    _accreditedController.dispose();
    _othersController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.camera, imageQuality: 70);
    if (file!= null) setState(() => _imagePath = file.path);
  }

  void _saveResult() {
    final Map<String, int> votes = {
      for (var p in ElectionResult.allParties)
        p: int.tryParse(_controllers[p]!.text)?? 0,
    };

    : _controllers[party],
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: party, border: const OutlineInputBorder(), isDense: true),
                  ),
                TextField(
                  controller: _othersController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Others / Invalid", border: OutlineInputBorder(), isDense: true),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.camera_alt),
                  label: Text(_imagePath == null? "Capture EC8 Photo" : "Retake Photo"),
                ),
                const SizedBox(width: 12),
                if (_imagePath!= null) const Icon(Icons.check_circle, color: Colors.green),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveResult,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
                child: const Text("SAVE RESULT (Offline)"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
