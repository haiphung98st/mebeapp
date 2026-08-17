class FormulaMilk {
  const FormulaMilk({
    required this.brand,
    required this.name,
    required this.stage,
    this.typicalServingMl = 150,
  });

  final String brand;
  final String name;
  final String stage;
  final double typicalServingMl;

  String get displayName => '$brand $name';
}

/// Barcode → FormulaMilk lookup (Vietnamese market, global brands)
const Map<String, FormulaMilk> formulaDatabase = {
  // Aptamil
  '4008976009900': FormulaMilk(brand: 'Aptamil', name: 'Stage 1 (0-6 tháng)', stage: '1', typicalServingMl: 120),
  '4008976010425': FormulaMilk(brand: 'Aptamil', name: 'Stage 2 (6-12 tháng)', stage: '2', typicalServingMl: 150),
  '4008976010517': FormulaMilk(brand: 'Aptamil', name: 'Stage 3 (12-24 tháng)', stage: '3', typicalServingMl: 180),
  '4008976011323': FormulaMilk(brand: 'Aptamil', name: 'Profutura Stage 1', stage: '1', typicalServingMl: 120),
  '4008976012139': FormulaMilk(brand: 'Aptamil', name: 'Profutura Stage 2', stage: '2', typicalServingMl: 150),

  // Similac
  '070074555046':  FormulaMilk(brand: 'Similac', name: 'Stage 1 (0-6 tháng)', stage: '1', typicalServingMl: 120),
  '070074555053':  FormulaMilk(brand: 'Similac', name: 'Stage 2 (6-12 tháng)', stage: '2', typicalServingMl: 150),
  '070074555060':  FormulaMilk(brand: 'Similac', name: 'Stage 3 (12-24 tháng)', stage: '3', typicalServingMl: 180),
  '070074560002':  FormulaMilk(brand: 'Similac', name: 'Advance', stage: '1', typicalServingMl: 120),
  '070074560019':  FormulaMilk(brand: 'Similac', name: 'Total Comfort', stage: '1', typicalServingMl: 120),
  '070074580727':  FormulaMilk(brand: 'Similac', name: 'Pro-Advance', stage: '1', typicalServingMl: 120),

  // NAN (Nestle)
  '7613037440700': FormulaMilk(brand: 'NAN', name: 'Optipro 1 (0-6 tháng)', stage: '1', typicalServingMl: 120),
  '7613037440717': FormulaMilk(brand: 'NAN', name: 'Optipro 2 (6-12 tháng)', stage: '2', typicalServingMl: 150),
  '7613037440724': FormulaMilk(brand: 'NAN', name: 'Optipro 3 (12-24 tháng)', stage: '3', typicalServingMl: 180),
  '7613037440731': FormulaMilk(brand: 'NAN', name: 'Comfort 1', stage: '1', typicalServingMl: 120),
  '7613037440748': FormulaMilk(brand: 'NAN', name: 'Comfort 2', stage: '2', typicalServingMl: 150),
  '7613287070456': FormulaMilk(brand: 'NAN', name: 'Pedia Grow 3+', stage: '3', typicalServingMl: 200),

  // Enfa (Meadjohnson)
  '075826103015':  FormulaMilk(brand: 'Enfamil', name: 'NeuroPro Stage 1', stage: '1', typicalServingMl: 120),
  '075826103022':  FormulaMilk(brand: 'Enfamil', name: 'NeuroPro Stage 2', stage: '2', typicalServingMl: 150),
  '075826103039':  FormulaMilk(brand: 'Enfamil', name: 'Gentlease', stage: '1', typicalServingMl: 120),
  '075826103046':  FormulaMilk(brand: 'Enfagrow', name: 'Premium (1-3 tuổi)', stage: '3', typicalServingMl: 200),
  '075826107617':  FormulaMilk(brand: 'Enfamil', name: 'A+2 (6-12 tháng)', stage: '2', typicalServingMl: 150),

  // Friso (FrieslandCampina)
  '8718117600083': FormulaMilk(brand: 'Friso', name: 'Gold 1 (0-6 tháng)', stage: '1', typicalServingMl: 120),
  '8718117600090': FormulaMilk(brand: 'Friso', name: 'Gold 2 (6-12 tháng)', stage: '2', typicalServingMl: 150),
  '8718117600106': FormulaMilk(brand: 'Friso', name: 'Gold 3 (1-3 tuổi)', stage: '3', typicalServingMl: 180),
  '8718117600113': FormulaMilk(brand: 'Friso', name: 'Gold 4 (2-6 tuổi)', stage: '4', typicalServingMl: 200),
  '8718117605255': FormulaMilk(brand: 'Frisolac', name: 'Gold (0-6 tháng)', stage: '1', typicalServingMl: 120),

  // Glico Icreo
  '4901340700006': FormulaMilk(brand: 'Glico', name: 'Icreo Balance Milk 0+', stage: '1', typicalServingMl: 120),
  '4901340700013': FormulaMilk(brand: 'Glico', name: 'Icreo Follow Up Milk', stage: '2', typicalServingMl: 150),

  // Meiji
  '4902705000612': FormulaMilk(brand: 'Meiji', name: 'Hohoemi (0-12 tháng)', stage: '1', typicalServingMl: 120),
  '4902705000629': FormulaMilk(brand: 'Meiji', name: 'Step (9-36 tháng)', stage: '2', typicalServingMl: 160),

  // Snow (Yili)
  '6902265101019': FormulaMilk(brand: 'Yili', name: 'Ying Yang Zhen Niu 1', stage: '1', typicalServingMl: 120),
  '6902265101026': FormulaMilk(brand: 'Yili', name: 'Ying Yang Zhen Niu 2', stage: '2', typicalServingMl: 150),

  // S-26 (Wyeth)
  '8850006300051': FormulaMilk(brand: 'S-26', name: 'Gold 1 (0-6 tháng)', stage: '1', typicalServingMl: 120),
  '8850006300068': FormulaMilk(brand: 'S-26', name: 'Gold 2 (6-12 tháng)', stage: '2', typicalServingMl: 150),
  '8850006300075': FormulaMilk(brand: 'S-26', name: 'Progress Gold 3', stage: '3', typicalServingMl: 180),
  '8850006300082': FormulaMilk(brand: 'S-26', name: 'Promise Gold 4', stage: '4', typicalServingMl: 200),

  // Nutifood
  '8934588000014': FormulaMilk(brand: 'Nutifood', name: 'NutiIQ 1 (0-6 tháng)', stage: '1', typicalServingMl: 120),
  '8934588000021': FormulaMilk(brand: 'Nutifood', name: 'NutiIQ 2 (6-12 tháng)', stage: '2', typicalServingMl: 150),
  '8934588000038': FormulaMilk(brand: 'Nutifood', name: 'GrowPLUS+ 0-1', stage: '1', typicalServingMl: 120),
  '8934588000045': FormulaMilk(brand: 'Nutifood', name: 'GrowPLUS+ 1-2', stage: '2', typicalServingMl: 150),
  '8934588000052': FormulaMilk(brand: 'Nutifood', name: 'GrowPLUS+ 2-6', stage: '3', typicalServingMl: 200),

  // Vinamilk
  '8936085000001': FormulaMilk(brand: 'Vinamilk', name: 'Dielac Alpha 1 (0-6 tháng)', stage: '1', typicalServingMl: 120),
  '8936085000018': FormulaMilk(brand: 'Vinamilk', name: 'Dielac Alpha 2 (6-12 tháng)', stage: '2', typicalServingMl: 150),
  '8936085000025': FormulaMilk(brand: 'Vinamilk', name: 'Dielac Alpha 3 (1-2 tuổi)', stage: '3', typicalServingMl: 180),
  '8936085000032': FormulaMilk(brand: 'Vinamilk', name: 'Dielac Alpha 4 (2-6 tuổi)', stage: '4', typicalServingMl: 200),
  '8936085000049': FormulaMilk(brand: 'Vinamilk', name: 'Dielac Optimum', stage: '1', typicalServingMl: 120),

  // Abbott (Gain)
  '8850006100022': FormulaMilk(brand: 'Similac Gain', name: 'Plus 3 (1-3 tuổi)', stage: '3', typicalServingMl: 180),
  '8850006100039': FormulaMilk(brand: 'Similac Gain', name: 'School 4 (3-7 tuổi)', stage: '4', typicalServingMl: 200),

  // HiPP
  '4062300195950': FormulaMilk(brand: 'HiPP', name: 'Combiotic 1 (0-6 tháng)', stage: '1', typicalServingMl: 120),
  '4062300196063': FormulaMilk(brand: 'HiPP', name: 'Combiotic 2 (6-12 tháng)', stage: '2', typicalServingMl: 150),
  '4062300196070': FormulaMilk(brand: 'HiPP', name: 'Combiotic 3 (12-24 tháng)', stage: '3', typicalServingMl: 180),

  // Kabrita (goat milk)
  '8713904001201': FormulaMilk(brand: 'Kabrita', name: 'Stage 1 (0-6 tháng, sữa dê)', stage: '1', typicalServingMl: 120),
  '8713904001218': FormulaMilk(brand: 'Kabrita', name: 'Stage 2 (6-12 tháng, sữa dê)', stage: '2', typicalServingMl: 150),
  '8713904001225': FormulaMilk(brand: 'Kabrita', name: 'Stage 3 (12+ tháng, sữa dê)', stage: '3', typicalServingMl: 180),

  // Bubs (Australian)
  '9349090000070': FormulaMilk(brand: 'Bubs', name: 'Stage 1 (0-6 tháng)', stage: '1', typicalServingMl: 120),
  '9349090000087': FormulaMilk(brand: 'Bubs', name: 'Stage 2 (6-12 tháng)', stage: '2', typicalServingMl: 150),
  '9349090000094': FormulaMilk(brand: 'Bubs', name: 'Stage 3 (12+ tháng)', stage: '3', typicalServingMl: 180),
};

FormulaMilk? lookupBarcode(String barcode) => formulaDatabase[barcode];
