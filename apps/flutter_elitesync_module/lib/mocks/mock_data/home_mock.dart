class HomeMock {
  static const hero = {
    'title': '本周关系洞察已更新',
    'subtitle': '查看你的匹配节奏与沟通建议',
    'cta': '查看匹配',
  };

  static const shortcuts = [
    {'key': 'questionnaire', 'title': '继续问卷', 'action': 'route', 'target': '/questionnaire'},
    {'key': 'mbti', 'title': 'MBTI 测试', 'action': 'route', 'target': '/profile/mbti'},
    {'key': 'astro', 'title': '星盘画像', 'action': 'route', 'target': '/profile/astro'},
    {'key': 'profile', 'title': '完善资料', 'action': 'route', 'target': '/profile/edit'},
  ];

  static const feedHappy = [
    {
      'id': 'f001',
      'title': '如何判断关系中的安全感？',
      'summary': '用三步识别稳定连接的关键线索。',
      'author': '关系研究社',
      'likes': 218,
    },
    {
      'id': 'f002',
      'title': '沟通降温时，先修复节奏再谈结论',
      'summary': '冲突后 24 小时内最有效的沟通策略。',
      'author': '心流专栏',
      'likes': 176,
    },
  ];

  static const discoverFeed = [
    {
      'id': 'd001',
      'title': '周末桌游社交局',
      'summary': '同城 28 人感兴趣 · 线下活动',
      'author': '南阳活动组',
      'likes': 96,
    },
    {
      'id': 'd002',
      'title': '慢约会穿搭分享',
      'summary': '今日新增 16 条讨论 · 图文',
      'author': '穿搭研究社',
      'likes': 132,
    },
    {
      'id': 'd003',
      'title': '星盘兼容性答疑',
      'summary': '情感顾问在线 · 语音房',
      'author': '星图工作室',
      'likes': 88,
    },
    {
      'id': 'd004',
      'title': '城市漫步相遇计划',
      'summary': '本周 4 场活动可报名',
      'author': '同城运营',
      'likes': 74,
    },
  ];

  static const feedEmpty = <Map<String, Object>>[];

  static const feedError = {
    'ok': false,
    'code': 'HOME_FEED_ERROR',
    'message': '首页内容加载失败',
  };
}
