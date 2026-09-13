class Absensi {
  final int? idAbsensi;
  final DateTime tglHadir;
  final String kodeUnik;

  Absensi({this.idAbsensi, required this.tglHadir, required this.kodeUnik});

  factory Absensi.fromMap(Map<String, dynamic> map) => Absensi(
        idAbsensi: map['id_absensi'] as int?,
        tglHadir: DateTime.parse(map['tgl_hadir'] as String),
        kodeUnik: map['kode_unik'] as String,
      );

  Map<String, dynamic> toMap() => {
        'id_absensi': idAbsensi,
        'tgl_hadir': tglHadir.toIso8601String(),
        'kode_unik': kodeUnik,
      };
}
