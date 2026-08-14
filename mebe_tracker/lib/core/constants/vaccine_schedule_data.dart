/// Hardcoded Vietnam national vaccination schedule (per Bộ Y tế VN),
/// expressed as days since birth used to compute each scheduled date.
class VaccineDef {
  const VaccineDef({
    required this.key,
    required this.nameVi,
    required this.offsetDays,
    this.descriptionVi = '',
    this.ageLabel = '',
    this.category = VaccineCategory.mandatory,
  });

  final String key;
  final String nameVi;
  final int offsetDays;
  final String descriptionVi;
  final String ageLabel;
  final VaccineCategory category;
}

enum VaccineCategory { mandatory, recommended }

const vaccineDefs = [
  VaccineDef(
    key: 'bcg',
    nameVi: 'BCG (Lao)',
    offsetDays: 0,
    ageLabel: 'Lúc sinh',
    descriptionVi:
        'Vắc xin BCG phòng bệnh lao. Tiêm một lần duy nhất vào trong 24 giờ sau sinh hoặc ngay khi trẻ đủ điều kiện sức khỏe.',
  ),
  VaccineDef(
    key: 'hep_b_1',
    nameVi: 'Viêm gan B liều 1',
    offsetDays: 0,
    ageLabel: 'Lúc sinh',
    descriptionVi:
        'Vắc xin phòng viêm gan B liều đầu tiên. Cần tiêm trong 24 giờ đầu sau sinh để đạt hiệu quả bảo vệ cao nhất.',
  ),
  VaccineDef(
    key: '5in1_1',
    nameVi: '5in1 liều 1',
    offsetDays: 60,
    ageLabel: '2 tháng',
    descriptionVi:
        'Vắc xin 5 trong 1 phòng bạch hầu, ho gà, uốn ván, viêm phổi do Hib và bại liệt. Liều đầu tiên.',
  ),
  VaccineDef(
    key: 'polio_1',
    nameVi: 'Bại liệt uống liều 1',
    offsetDays: 60,
    ageLabel: '2 tháng',
    descriptionVi:
        'Vắc xin bại liệt dạng uống (OPV). Phòng bệnh bại liệt gây liệt mềm cấp tính. Liều đầu tiên.',
  ),
  VaccineDef(
    key: 'rota_1',
    nameVi: 'Rota liều 1',
    offsetDays: 60,
    ageLabel: '2 tháng',
    descriptionVi:
        'Vắc xin Rotavirus phòng tiêu chảy cấp do Rotavirus. Dùng đường uống. Liều đầu tiên.',
    category: VaccineCategory.recommended,
  ),
  VaccineDef(
    key: '5in1_2',
    nameVi: '5in1 liều 2',
    offsetDays: 90,
    ageLabel: '3 tháng',
    descriptionVi:
        'Vắc xin 5 trong 1 liều thứ hai. Nhắc lại để tăng cường miễn dịch sau mũi đầu tiên.',
  ),
  VaccineDef(
    key: 'polio_2',
    nameVi: 'Bại liệt liều 2',
    offsetDays: 90,
    ageLabel: '3 tháng',
    descriptionVi:
        'Vắc xin bại liệt liều thứ hai, giúp tăng cường miễn dịch.',
  ),
  VaccineDef(
    key: 'rota_2',
    nameVi: 'Rota liều 2',
    offsetDays: 90,
    ageLabel: '3 tháng',
    descriptionVi:
        'Vắc xin Rotavirus liều thứ hai.',
    category: VaccineCategory.recommended,
  ),
  VaccineDef(
    key: '5in1_3',
    nameVi: '5in1 liều 3',
    offsetDays: 120,
    ageLabel: '4 tháng',
    descriptionVi:
        'Vắc xin 5 trong 1 liều thứ ba, hoàn thành chuỗi tiêm cơ bản.',
  ),
  VaccineDef(
    key: 'polio_3',
    nameVi: 'Bại liệt liều 3',
    offsetDays: 120,
    ageLabel: '4 tháng',
    descriptionVi:
        'Vắc xin bại liệt liều thứ ba, hoàn thành chuỗi cơ bản.',
  ),
  VaccineDef(
    key: 'rota_3',
    nameVi: 'Rota liều 3',
    offsetDays: 120,
    ageLabel: '4 tháng',
    descriptionVi:
        'Vắc xin Rotavirus liều thứ ba (chỉ với loại vắc xin 3 liều).',
    category: VaccineCategory.recommended,
  ),
  VaccineDef(
    key: 'hep_b_3',
    nameVi: 'Viêm gan B liều 3',
    offsetDays: 180,
    ageLabel: '6 tháng',
    descriptionVi:
        'Vắc xin viêm gan B liều thứ ba, hoàn thành chuỗi cơ bản. Cần kiểm tra hiệu giá kháng thể sau 1 tháng.',
  ),
  VaccineDef(
    key: 'flu_1',
    nameVi: 'Cúm liều 1',
    offsetDays: 180,
    ageLabel: '6 tháng',
    descriptionVi:
        'Vắc xin cúm mùa, tiêm nhắc hàng năm. Bảo vệ khỏi các chủng cúm phổ biến.',
    category: VaccineCategory.recommended,
  ),
  VaccineDef(
    key: 'measles',
    nameVi: 'Sởi đơn',
    offsetDays: 270,
    ageLabel: '9 tháng',
    descriptionVi:
        'Vắc xin sởi đơn trong chương trình tiêm chủng mở rộng. Phòng bệnh sởi nguy hiểm.',
  ),
  VaccineDef(
    key: 'mmr_1',
    nameVi: 'MMR (Sởi - Quai bị - Rubella)',
    offsetDays: 365,
    ageLabel: '12 tháng',
    descriptionVi:
        'Vắc xin phối hợp phòng 3 bệnh: sởi, quai bị, và rubella. Liều đầu tiên.',
  ),
  VaccineDef(
    key: 'jap_encephalitis',
    nameVi: 'Viêm não Nhật Bản',
    offsetDays: 365,
    ageLabel: '12 tháng',
    descriptionVi:
        'Vắc xin phòng viêm não Nhật Bản do virus gây ra, lây qua muỗi đốt. Tiêm 3 mũi theo phác đồ.',
  ),
  VaccineDef(
    key: 'dpt_booster',
    nameVi: 'DPT nhắc lại',
    offsetDays: 548,
    ageLabel: '18 tháng',
    descriptionVi:
        'Mũi nhắc lại vắc xin bạch hầu, ho gà, uốn ván sau chuỗi cơ bản 5in1.',
  ),
  VaccineDef(
    key: 'mmr_2',
    nameVi: 'MMR liều 2',
    offsetDays: 548,
    ageLabel: '18 tháng',
    descriptionVi:
        'Liều nhắc lại vắc xin MMR để tăng cường miễn dịch lâu dài.',
  ),
];

/// Group vaccines by age label for timeline display.
Map<String, List<VaccineDef>> get vaccineDefsByAge {
  final map = <String, List<VaccineDef>>{};
  for (final def in vaccineDefs) {
    map.putIfAbsent(def.ageLabel, () => []).add(def);
  }
  return map;
}
