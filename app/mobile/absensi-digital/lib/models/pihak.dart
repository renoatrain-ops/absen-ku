class Pihak {
  final int? idPihak;
  final String namaLengkap;
  final String namaAlias;
  final String kodePihak;
  final bool flagAktif;

  Pihak({this.idPihak, required this.namaLengkap, required this.namaAlias, required this.kodePihak, required this.flagAktif});

  factory Pihak.fromMap(Map<String, dynamic> map) => Pihak(
        idPihak: map['id_pihak'] as int?,
        namaLengkap: map['nama_lengkap'] as String? ?? '',
        namaAlias: map['nama_alias'] as String? ?? '',
        kodePihak: map['kode_pihak'] as String,
        flagAktif: (map['flag_aktif'] as int) == 1,
      );

  Map<String, dynamic> toMap() => {
        'id_pihak': idPihak,
        'nama_lengkap': namaLengkap,
        'nama_alias': namaAlias,
        'kode_pihak': kodePihak,
        'flag_aktif': flagAktif ? 1 : 0,
      };
}
