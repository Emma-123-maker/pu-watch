// lib/models/election_result.dart - GENERIC FOR ALL ELECTIONS

enum ElectionType {
  presidential,
  senatorial,
  houseOfReps,
  governorship,
  stateAssembly,
  chairmanship,
  councillorship,
}

extension ElectionTypeLabel on ElectionType {
  String get label {
    switch (this) {
      case ElectionType.presidential: return "Presidential";
      case ElectionType.senatorial: return "Senatorial";
      case ElectionType.houseOfReps: return "House of Reps";
      case ElectionType.governorship: return "Governorship";
      case ElectionType.stateAssembly: return "State Assembly";
      case ElectionType.chairmanship: return "LGA Chairmanship";
      case ElectionType.councillorship: return "Councillorship";
    }
  }
}

class ElectionResult {
  String puCode;
  String lga;
  String ward;
  String stateCode;
  ElectionType electionType; // NEW - which election is this?
  int accredited;
  Map<String, int> partyVotes; // NEW - generic, no hardcoded apc/adc
  int others;
  String photoPath;
  DateTime timestamp;
  bool synced;

  ElectionResult({
    required this.puCode,
    required this.lga,
    required this.ward,
    required this.stateCode,
    this.electionType = ElectionType.presidential,
    this.accredited = 0,
    Map<String, int>? partyVotes,
    this.others = 0,
    required this.photoPath,
    required this.timestamp,
    this.synced = false,
  }) : partyVotes = partyVotes ?? { for (var p in allParties) p: 0 };

  // All 18 INEC parties - NO CANDIDATE NAMES
  static const List<String> allParties = [
    "AA","AAC","ADC","ADP","APC","APGA","APM","APP","A",
    "BP","LP","NNPP","NDC","NRM","PDP","PRP","SDP","YPP","ZLP"
  ];

  // For UI - just party code, no name
  static const Map<String, String> partyLabels = {
    for (var p in allParties) p: p
  };

  int get totalCounted => partyVotes.values.fold(0, (s, v) => s + v) + others;

  Map<String, dynamic> toJson() => {
    'puCode': puCode,
    'lga': lga,
    'ward': ward,
    'stateCode': stateCode,
    'electionType': electionType.name,
    'accredited': accredited,
    'partyVotes': partyVotes,
    'others': others,
    'photoPath': photoPath,
    'timestamp': timestamp.toIso8601String(),
    'synced': synced,
  };

  factory ElectionResult.fromJson(Map json) => ElectionResult(
    puCode: json['puCode'] ?? '',
    lga: json['lga'] ?? '',
    ward: json['ward'] ?? '',
    stateCode: json['stateCode'] ?? '',
    electionType: ElectionType.values.firstWhere(
      (e) => e.name == json['electionType'], 
      orElse: () => ElectionType.presidential
    ),
    accredited: json['accredited'] ?? 0,
    partyVotes: Map<String, int>.from(json['partyVotes'] ?? {}),
    others: json['others'] ?? 0,
    photoPath: json['photoPath'] ?? '',
    timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    synced: json['synced'] ?? false,
  );
}
