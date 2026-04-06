enum MasjidStatus {
  pending,
  active,
  rejected;

  static MasjidStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return MasjidStatus.active;
      case 'rejected':
        return MasjidStatus.rejected;
      default:
        return MasjidStatus.pending;
    }
  }
}

class Masjid {
  final int id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final MasjidStatus status;
  final String? maslak;
  final String fajr;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;
  final String jummah;
  final List<String> documentUrls;

  Masjid({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.status,
    this.maslak,
    required this.fajr,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.jummah,
    required this.documentUrls,
  });

  factory Masjid.fromJson(Map<String, dynamic> json) {
    return Masjid(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      status: MasjidStatus.fromString(json['status'] ?? 'pending'),
      maslak: json['maslak'],
      fajr: json['fajr'] ?? '',
      dhuhr: json['dhuhr'] ?? '',
      asr: json['asr'] ?? '',
      maghrib: json['maghrib'] ?? '',
      isha: json['isha'] ?? '',
      jummah: json['jummah'] ?? '',
      documentUrls: List<String>.from(json['document_urls'] ?? []),
    );
  }
}
