/// Hardcoded Vietnam national vaccination schedule (per Bộ Y tế VN),
/// expressed as days since birth used to compute each scheduled date.
class VaccineDef {
  const VaccineDef({required this.key, required this.nameVi, required this.offsetDays});

  final String key;
  final String nameVi;
  final int offsetDays;
}

const vaccineDefs = [
  VaccineDef(key: 'bcg', nameVi: 'BCG (Lao)', offsetDays: 0),
  VaccineDef(key: 'hep_b_1', nameVi: 'Viêm gan B liều 1', offsetDays: 0),
  VaccineDef(key: '5in1_1', nameVi: '5in1 liều 1', offsetDays: 60),
  VaccineDef(key: 'polio_1', nameVi: 'Bại liệt uống liều 1', offsetDays: 60),
  VaccineDef(key: 'rota_1', nameVi: 'Rota liều 1', offsetDays: 60),
  VaccineDef(key: '5in1_2', nameVi: '5in1 liều 2', offsetDays: 90),
  VaccineDef(key: 'polio_2', nameVi: 'Bại liệt liều 2', offsetDays: 90),
  VaccineDef(key: 'rota_2', nameVi: 'Rota liều 2', offsetDays: 90),
  VaccineDef(key: '5in1_3', nameVi: '5in1 liều 3', offsetDays: 120),
  VaccineDef(key: 'polio_3', nameVi: 'Bại liệt liều 3', offsetDays: 120),
  VaccineDef(key: 'rota_3', nameVi: 'Rota liều 3', offsetDays: 120),
  VaccineDef(key: 'hep_b_3', nameVi: 'Viêm gan B liều 3', offsetDays: 180),
  VaccineDef(key: 'flu_1', nameVi: 'Cúm liều 1', offsetDays: 180),
  VaccineDef(key: 'measles', nameVi: 'Sởi đơn', offsetDays: 270),
  VaccineDef(key: 'mmr_1', nameVi: 'MMR (Sởi - Quai bị - Rubella)', offsetDays: 365),
  VaccineDef(key: 'jap_encephalitis', nameVi: 'Viêm não Nhật Bản', offsetDays: 365),
  VaccineDef(key: 'dpt_booster', nameVi: 'DPT nhắc lại', offsetDays: 548),
  VaccineDef(key: 'mmr_2', nameVi: 'MMR liều 2', offsetDays: 548),
];
