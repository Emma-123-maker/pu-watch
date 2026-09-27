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
      case ElectionType.senatorial: return "EC8A - Senate";
      case ElectionType.houseOfReps: return "EC8A - HoR";
      case ElectionType.governorship: return "EC8B";
      case ElectionType.stateAssembly: return "EC8B - Assembly";
      default: return "EC8A";
    }
  }
}

const List<String> allParties = [
  "APC","PDP","ADC","LP","NNPP","NDC","APM","AAC",
  "APGA","SDP","YPP","PRP","ZLP","BP","A","AA","ADP","APP"
];
