// 20 primary teeth definitions with Vietnamese names and typical eruption ranges.
class ToothDef {
  const ToothDef({
    required this.id,
    required this.nameVi,
    required this.jaw,
    required this.orderFromCenter,
    required this.eruptMonthMin,
    required this.eruptMonthMax,
  });

  final String id;
  final String nameVi;
  final ToothJaw jaw;
  final int orderFromCenter; // 1=central, 2=lateral, 3=canine, 4=first molar, 5=second molar
  final int eruptMonthMin;
  final int eruptMonthMax;
}

enum ToothJaw { upper, lower }

const upperTeeth = [
  // Right side (from midline outward: R1..R5)
  ToothDef(id: 'ur1', nameVi: 'Cửa giữa trên phải', jaw: ToothJaw.upper, orderFromCenter: 1, eruptMonthMin: 8, eruptMonthMax: 12),
  ToothDef(id: 'ur2', nameVi: 'Cửa bên trên phải', jaw: ToothJaw.upper, orderFromCenter: 2, eruptMonthMin: 9, eruptMonthMax: 13),
  ToothDef(id: 'ur3', nameVi: 'Nanh trên phải', jaw: ToothJaw.upper, orderFromCenter: 3, eruptMonthMin: 16, eruptMonthMax: 22),
  ToothDef(id: 'ur4', nameVi: 'Hàm 1 trên phải', jaw: ToothJaw.upper, orderFromCenter: 4, eruptMonthMin: 13, eruptMonthMax: 19),
  ToothDef(id: 'ur5', nameVi: 'Hàm 2 trên phải', jaw: ToothJaw.upper, orderFromCenter: 5, eruptMonthMin: 25, eruptMonthMax: 33),
  // Left side (from midline outward: L1..L5)
  ToothDef(id: 'ul1', nameVi: 'Cửa giữa trên trái', jaw: ToothJaw.upper, orderFromCenter: 1, eruptMonthMin: 8, eruptMonthMax: 12),
  ToothDef(id: 'ul2', nameVi: 'Cửa bên trên trái', jaw: ToothJaw.upper, orderFromCenter: 2, eruptMonthMin: 9, eruptMonthMax: 13),
  ToothDef(id: 'ul3', nameVi: 'Nanh trên trái', jaw: ToothJaw.upper, orderFromCenter: 3, eruptMonthMin: 16, eruptMonthMax: 22),
  ToothDef(id: 'ul4', nameVi: 'Hàm 1 trên trái', jaw: ToothJaw.upper, orderFromCenter: 4, eruptMonthMin: 13, eruptMonthMax: 19),
  ToothDef(id: 'ul5', nameVi: 'Hàm 2 trên trái', jaw: ToothJaw.upper, orderFromCenter: 5, eruptMonthMin: 25, eruptMonthMax: 33),
];

const lowerTeeth = [
  // Right side
  ToothDef(id: 'lr1', nameVi: 'Cửa giữa dưới phải', jaw: ToothJaw.lower, orderFromCenter: 1, eruptMonthMin: 6, eruptMonthMax: 10),
  ToothDef(id: 'lr2', nameVi: 'Cửa bên dưới phải', jaw: ToothJaw.lower, orderFromCenter: 2, eruptMonthMin: 10, eruptMonthMax: 16),
  ToothDef(id: 'lr3', nameVi: 'Nanh dưới phải', jaw: ToothJaw.lower, orderFromCenter: 3, eruptMonthMin: 17, eruptMonthMax: 23),
  ToothDef(id: 'lr4', nameVi: 'Hàm 1 dưới phải', jaw: ToothJaw.lower, orderFromCenter: 4, eruptMonthMin: 14, eruptMonthMax: 18),
  ToothDef(id: 'lr5', nameVi: 'Hàm 2 dưới phải', jaw: ToothJaw.lower, orderFromCenter: 5, eruptMonthMin: 23, eruptMonthMax: 31),
  // Left side
  ToothDef(id: 'll1', nameVi: 'Cửa giữa dưới trái', jaw: ToothJaw.lower, orderFromCenter: 1, eruptMonthMin: 6, eruptMonthMax: 10),
  ToothDef(id: 'll2', nameVi: 'Cửa bên dưới trái', jaw: ToothJaw.lower, orderFromCenter: 2, eruptMonthMin: 10, eruptMonthMax: 16),
  ToothDef(id: 'll3', nameVi: 'Nanh dưới trái', jaw: ToothJaw.lower, orderFromCenter: 3, eruptMonthMin: 17, eruptMonthMax: 23),
  ToothDef(id: 'll4', nameVi: 'Hàm 1 dưới trái', jaw: ToothJaw.lower, orderFromCenter: 4, eruptMonthMin: 14, eruptMonthMax: 18),
  ToothDef(id: 'll5', nameVi: 'Hàm 2 dưới trái', jaw: ToothJaw.lower, orderFromCenter: 5, eruptMonthMin: 23, eruptMonthMax: 31),
];

const allTeeth = [...upperTeeth, ...lowerTeeth];

String toothTypeName(int order) {
  switch (order) {
    case 1: return 'Răng cửa giữa';
    case 2: return 'Răng cửa bên';
    case 3: return 'Răng nanh';
    case 4: return 'Răng hàm 1';
    case 5: return 'Răng hàm 2';
    default: return '';
  }
}
