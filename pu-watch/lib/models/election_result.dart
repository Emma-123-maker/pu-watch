class ElectionResult {
  String puCode; String lga; String ward; String stateCode;
  int accredited;
  // Final 18 INEC parties 2027
  int apc; // Tinubu
  int adc; // Atiku + Amaechi
  int ndc; // Peter Obi + Kwankwaso
  int apm; // Seyi Makinde + Daura
  int aac; // Sowore + Magashi
  int pdp; // Sandy Onor
  int aa; // Rufai Omo-Aje
  int adp; // Aliyu Abbas-Bin
  int app; // Kabiru Yusuf
  int bp; // Sunday Adenuga
  int dla; // Moses Adebisi
  int lp; // Sunday Okereke (not Obi anymore)
  int ndp; // Ada Okwori - female
  int nrm; // Nkem Okereke - female
  int prp; // Donald Duke
  int sdp; // Adebayo
  int ypp; // Peter Agada
  int zlp; // Daniel Nwanyanwu
  int others;
  String photoPath; DateTime timestamp; bool synced;

  ElectionResult({
    required this.puCode, required this.lga, required this.ward, required this.stateCode,
    required this.accredited,
    required this.apc, this.adc=0, this.ndc=0, this.apm=0, this.aac=0, required this.pdp,
    this.aa=0, this.adp=0, this.app=0, this.bp=0, this.dla=0, required this.lp, this.ndp=0, this.nrm=0,
    this.prp=0, this.sdp=0, this.ypp=0, this.zlp=0, required this.others,
    required this.photoPath, required this.timestamp, this.synced=false,
  });

  // Candidate map for UI labels
  static const candidates = {
    'APC': 'Tinubu', 'ADC': 'Atiku', 'NDC': 'Peter Obi', 'APM': 'Seyi Makinde',
    'AAC': 'Sowore', 'PDP': 'Sandy Onor', 'PRP': 'Donald Duke', 'SDP': 'Adebayo',
    'AA': 'Omo-Aje', 'ADP': 'Abbas-Bin', 'APP': 'Kabiru Yusuf', 'BP': 'Adenuga',
    'DLA': 'Moses Adebisi', 'LP': 'Okereke', 'NDP': 'Ada Okwori', 'NRM': 'Nkem Okereke',
    'YPP': 'Peter Agada', 'ZLP': 'Nwanyanwu',
  };

  Map<String,int> get allParties => {
    'AA':aa,'ADP':adp,'APP':app,'AAC':aac,'ADC':adc,'APC':apc,'APM':apm,'BP':bp,
    'DLA':dla,'LP':lp,'NDP':ndp,'NRM':nrm,'NDC':ndc,'PDP':pdp,'PRP':prp,'SDP':sdp,'YPP':ypp,'ZLP':zlp,
  };

  int get totalCounted => allParties.values.fold(0,(s,v)=>s+v)+others;

  Map<String,dynamic> toJson() => {
    'puCode':puCode,'lga':lga,'ward':ward,'stateCode':stateCode,'accredited':accredited,
    'apc':apc,'adc':adc,'ndc':ndc,'apm':apm,'aac':aac,'pdp':pdp,'aa':aa,'adp':adp,'app':app,'bp':bp,'dla':dla,'lp':lp,'ndp':ndp,'nrm':nrm,'prp':prp,'sdp':sdp,'ypp':ypp,'zlp':zlp,'others':others,
    'photoPath':photoPath,'timestamp':timestamp.toIso8601String(),'synced':synced,
  };

  factory ElectionResult.fromJson(Map json) => ElectionResult(
    puCode:json['puCode']??'', lga:json['lga']??'', ward:json['ward']??'', stateCode:json['stateCode']??'', accredited:json['accredited']??0,
    apc:json['apc']??0, adc:json['adc']??0, ndc:json['ndc']??0, apm:json['apm']??0, aac:json['aac']??0, pdp:json['pdp']??0,
    aa:json['aa']??0, adp:json['adp']??0, app:json['app']??0, bp:json['bp']??0, dla:json['dla']??0, lp:json['lp']??0, ndp:json['ndp']??0, nrm:json['nrm']??0,
    prp:json['prp']??0, sdp:json['sdp']??0, ypp:json['ypp']??0, zlp:json['zlp']??0, others:json['others']??0,
    photoPath:json['photoPath']??'', timestamp:DateTime.tryParse(json['timestamp']??'')??DateTime.now(), synced:json['synced']??false,
  );
}
