class HomeBannerDto {
  const HomeBannerDto({required this.title, required this.subtitle, required this.cta});
  final String title;
  final String subtitle;
  final String cta;

  factory HomeBannerDto.fromJson(Map<String, dynamic> json) {
    return HomeBannerDto(
      title: (json['title'] ?? '').toString(),
      subtitle: (json['subtitle'] ?? '').toString(),
      cta: (json['cta'] ?? '').toString(),
    );
  }
}
