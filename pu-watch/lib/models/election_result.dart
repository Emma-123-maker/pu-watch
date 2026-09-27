class ElectionResult {
  String puCode;
  String lga;
  String ward;
  String stateCode;
  int accredited;
  int apc;
  int pdp;
  int lp;
  int others;
  String photoPath;
  DateTime timestamp;
  bool synced;

  ElectionResult({
    required this.puCode,
    required this.lga,
    required this.ward,
    required this.stateCode,
    required this.accredited,
    required this.apc,
    required this.pdp,
    required this.lp,
    required this.others,
    required this.photoPath,
    required this.timestamp,
    this.synced = false,
  });

  Map<String, dynamic> toJson() => {
    'puCode': puCode,
    'lga': lga,
    'ward': ward,
    'stateCode': stateCode,
    'accredited': accredited,
    'apc': apc,
    'pdp': pdp,
    'lp': lp,
    'others': others,
    'photoPath': photoPath,
    'timestamp': timestamp.toIso8601String(),
    'synced': synced,
  };
}
