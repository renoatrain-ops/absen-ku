class Pihak {
  final int id;
  final String idPihak;
  final String tipe;
  final String nama;
  final String kodeUnik;
  final String kodeInduk;
  final String flag;
  final String grade;
  final int aktif;

  Pihak({required this.id, required this.idPihak, required this.tipe, required this.nama, required this.kodeUnik, required this.kodeInduk, required this.flag, required this.grade, required this.aktif});

  factory Pihak.fromMap(Map<String, dynamic> map) => Pihak(
        id: map['id'] as int,
        idPihak: map['id_pihak'] as String,
        tipe: map['tipe'] as String,
        nama: map['nama'] as String,
        kodeUnik: map['kode_unik'] as String,
        kodeInduk: map['kode_induk'] as String,
        flag: map['flag'] as String,
        grade: map['grade'] as String,
        aktif: map['aktif'] as int,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'id_pihak': idPihak,
        'tipe': tipe,
        'nama': nama,
        'kode_unik': kodeUnik,
        'kode_induk': kodeInduk,
        'flag': flag,
        'grade': grade,
        'aktif': aktif,
      };
}
