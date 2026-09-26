import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StateDropdown extends StatefulWidget {
  final Function(String code, String name) onStateSelected;
  const StateDropdown({super.key, required this.onStateSelected});

  @override
  State<StateDropdown> createState() => _StateDropdownState();
}

class _StateDropdownState extends State<StateDropdown> {
  List<dynamic> states = [];
  String? selectedCode = '03';
  String? selectedName = 'Akwa Ibom';

  @override
  void initState() {
    super.initState();
    loadStates();
  }

  Future<void> loadStates() async {
    final data = await rootBundle.loadString('assets/data/states_index.json');
    setState(() {
      states = json.decode(data);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.green),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedCode,
          isExpanded: true,
          hint: Text("Select State"),
          items: states.map((s) {
            return DropdownMenuItem<String>(
              value: s['code'],
              child: Text("${s['code']} - ${s['name']}"),
            );
          }).toList(),
          onChanged: (code) {
            final state = states.firstWhere((e) => e['code'] == code);
            setState(() {
              selectedCode = code;
              selectedName = state['name'];
            });
            widget.onStateSelected(code!, state['name']);
          },
        ),
      ),
    );
  }
}
