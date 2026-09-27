import 'dart:collection';

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
      case ElectionType.presidential:
        return "Presidential";
      case ElectionType.senatorial:
        return "Senatorial";
      case ElectionType.houseOfReps:
        return "House of Reps";
      case ElectionType.governorship:
        return "Governorship";
      case ElectionType.stateAssembly:
        return "State House of Assembly";
      case ElectionType.chairmanship:
        return "LGA Chairmanship";
      case ElectionType.councillorship:
        return "Ward Councillorship";
    }
  }

  String get ecForm {
    switch (this) {
      case ElectionType.presidential:
        return "EC8A";
      case ElectionType.senatorial:
        return "EC8A(II) - Senate";
      case ElectionType.houseOfReps:
        return "EC8A(III) - HoR";
      case ElectionType.governorship:
        return "EC8B - Governorship";
      case ElectionType.stateAssembly:
        return "EC8B(II) - Assembly";
      case ElectionType.chairmanship:
        return "EC8C - Chairmanship";
      case ElectionType.councillorship:
        return "EC8C(II) - Councillorship";
    }
  }
}

class ElectionResult {
  String puCode;
  String lga;
  String ward;
  String stateCode;
  ElectionType electionType;
  int accredited;
  Map<String, int> partyVotes;
  int others;
  String photoPath;
  DateTime timestamp;
  bool synced;

  static const List<String> allParties = [
    "AA",
    "AAC",
    "ADC",
    "ADP",
    "APC",
    "APGA",
    "APM",
    "APP",
    "A",
    "BP",
    "LP",
    "NNPP",
    "NDC",
    "NRM",
    "PDP",
    "PRP",
    "SDP",
    "YPP",
    "ZLP"
  ];

  static Map<String, String> get partyLabels {
    return {for (var p in allParties) p: p};
  }

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
  }) : partyVotes = partyVotes?? {for (var p in allParties) p: 0};

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

  factory ElectionResult.fromJson(Map json) {
    final String typeName = json['electionType']?? 'presidential';
    final ElectionType type = ElectionType.values.firstWhere(
      (e) => e.name == typeName,
      orElse: () => ElectionType.presidential,
    );
    Map<String, int> votes = {};
    if (json['partyVotes']!= null) {
      votes = Map<String, int>.from(json['partyVotes']);
    } else {
      // backward compat for old apc, adc fields
      for (var p in allParties) {
        votes[p] = json[p.toLowerCase()]?? 0;
      }
    }
    return ElectionResult(
      puCode: json['puCode']?? '',
      lga: json['lga']?? '',
      ward: json['ward']?? '',
      stateCode: json['stateCode']?? '',
      electionType: type,
      accredited: json['accredited']?? 0,
      partyVotes: votes,
      others: json['others']?? 0,
      photoPath: json['photoPath']?? '',
      timestamp:
          DateTime.tryParse(json['timestamp']?? '')?? DateTime.now(),
      synced: json['synced']?? false,
    );
  }
}
