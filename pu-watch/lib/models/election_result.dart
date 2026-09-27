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
      case ElectionType.presidential: return "Presidential";
      case ElectionType.senatorial: return "Senatorial";
      case ElectionType.houseOfReps: return "House of Reps";
      case ElectionType.governorship: return "Governorship";
      case ElectionType.stateAssembly: return "State House of Assembly";
      case ElectionType.chairmanship: return "LGA Chairmanship";
      case ElectionType.councillorship: return "Ward Councillorship";
    }
  }
  String get ecForm {
    switch (this) {
      case ElectionType.presidential: return "EC8A";
      case ElectionType.senatorial: return "EC8A(II) - Senate";
      case ElectionType.houseOfReps: return "EC8A(III) - HoR";
      case ElectionType.governorship: return "EC8B - Governorship";
      case ElectionType.stateAssembly: return "EC8B(II) - Assembly";
      case ElectionType.chairmanship: return "EC8C - Chairmanship";
      case ElectionType.councillorship: return "EC8C(II) - Councillorship";
    }
  }
}

class ElectionResult {
  String puCode; String lga; String ward; String stateCode;
  ElectionType electionType; int accredited;
  Map<String, int> partyVotes; int others;
  String photoPath; DateTime timestamp; bool synced;
  static const List<String> allParties = [
    "AA","AAC","ADC","ADP","APC","APGA","APM","APP","A",
    "BP","LP","NNPP","NDC","NRM","PDP","PRP","SDP","YPP","ZLP"
  ];
  ElectionResult({
    required this.puCode, required this.lga, required this.ward,
    required this.stateCode,
    this.electionType = ElectionType.presidential,
    this.accredited = 0, Map<String, int>? partyVotes,
    this.others = 0, required this.photoPath,
    required this.timestamp, this.synced = false,
  }) : partyVotes = partyVotes!= null? partyVotes : {for (var p in allParties) p: 0};

  int get totalCounted {
    int sum = 0; partyVotes.forEach((k,v){ sum += v; }); return sum + others;
  }
  Map<String, dynamic> toJson() {
    return {
      'puCode': puCode, 'lga': lga, 'ward': ward, 'stateCode': stateCode,
      'electionType': electionType.name, 'accredited': accredited,
      'partyVotes': partyVotes, 'others': others,
      'photoPath': photoPath, 'timestamp': timestamp.toIso8601String(), 'synced': synced,
    };
  }
  factory ElectionResult.fromJson(Map json) {
    String typeName = json['electionType']!= null? json['electionType'] as String : 'presidential';
    ElectionType type = ElectionType.presidential;
    for (var e in ElectionType.values) { if (e.name == typeName) type = e; }
    Map<String, int> votes = {};
    if (json['partyVotes']!= null) { votes = Map<String, int>.from(json['partyVotes']); }
    else { for (var p in allParties) { var key = p.toLowerCase(); votes[p] = json[key]!= null? json[key] as int : 0; } }
    return ElectionResult(
      puCode: json['puCode']!= null? json['puCode'] as String : '',
      lga: json['lga']!= null? json['lga'] as String : '',
      ward: json['ward']!= null? json['ward'] as String : '',
      stateCode: json['stateCode']!= null? json['stateCode'] as String : '',
      electionType: type,
      accredited: json['accredited']!= null? json['accredited'] as int : 0,
      partyVotes: votes,
      others: json['others']!= null? json['others'] as int : 0,
      photoPath: json['photoPath']!= null? json['photoPath'] as String : '',
      timestamp: json['timestamp']!= null? DateTime.tryParse(json['timestamp'])?? DateTime.now() : DateTime.now(),
      synced: json['synced']!= null? json['synced'] as bool : false,
    );
  }
}
