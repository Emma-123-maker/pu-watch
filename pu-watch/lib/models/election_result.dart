import 'package:hive/hive.dart';
part 'election_result.g.dart';

@HiveType(typeId: 2)
class ElectionResult extends HiveObject {
  @HiveField(0) String puCode;
  @HiveField(1) String lga;
  @HiveField(2) String ward;
  @HiveField(3) String stateCode;
  @HiveField(4) int accredited;
  @HiveField(5) int apc;
  @HiveField(6) int pdp;
  @HiveField(7) int lp;
  @HiveField(8) int others;
  @HiveField(9) String photoPath;
  @HiveField(10) DateTime timestamp;
  @HiveField(11) bool synced;

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
}
