class HomeShortcutEntity {
  const HomeShortcutEntity({
    required this.key,
    required this.title,
    this.action,
    this.target,
  });
  final String key;
  final String title;
  final String? action;
  final String? target;
}
