class Absensi {
  final int? idAbsensi;
  final DateTime tglHadir;
  final String kodePihak;

  Absensi({this.idAbsensi, required this.tglHadir, required this.kodePihak});

  factory Absensi.fromMap(Map<String, dynamic> map) => Absensi(
        idAbsensi: map['id_absensi'] as int?,
        tglHadir: DateTime.parse(map['tgl_hadir'] as String),
        kodePihak: map['kode_pihak'] as String,
      );

  Map<String, dynamic> toMap() => {
        'id_absensi': idAbsensi,
        'tgl_hadir': tglHadir.toIso8601String(),
        'kode_pihak': kodePihak,
      };
}
