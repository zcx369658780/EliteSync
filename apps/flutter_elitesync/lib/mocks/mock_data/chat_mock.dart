class ChatMock {
  static const conversationsHappy = [
    {
      'id': 'c001',
      'name': '晨雾',
      'avatar': null,
      'last_message': '今晚有空聊聊你的旅行清单吗？',
      'last_time': '10:18',
      'unread': 2,
    },
    {
      'id': 'c002',
      'name': '九紫瑶瑶',
      'avatar': null,
      'last_message': '我也喜欢慢节奏散步。',
      'last_time': '昨天',
      'unread': 0,
    },
  ];

  static const conversationsEmpty = <Map<String, Object?>>[];

  static const conversationsError = {
    'ok': false,
    'code': 'CHAT_LIST_ERROR',
    'message': '会话列表加载失败',
  };

  static const messagesHappy = [
    {'id': 'm001', 'mine': false, 'text': '你好呀，看到你也喜欢看展。', 'time': '10:15'},
    {'id': 'm002', 'mine': true, 'text': '是的，我最近在看摄影展。', 'time': '10:16'},
  ];
}
