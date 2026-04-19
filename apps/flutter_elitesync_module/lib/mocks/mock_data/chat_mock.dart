class ChatMock {
  static const conversationsHappy = [
    {
      'id': 'c001',
      'name': '晨雾',
      'avatar': null,
      'last_message': '图片消息',
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
    {
      'id': 'm001',
      'mine': false,
      'text': '你好呀，看到你也喜欢看展。',
      'time': '10:15',
    },
    {
      'id': 'm002',
      'mine': true,
      'text': '是的，我最近在看摄影展。',
      'time': '10:16',
    },
    {
      'id': 'm003',
      'mine': true,
      'text': '',
      'time': '10:17',
      'attachments': [
        {
          'id': 'a001',
          'attachment_type': 'image',
          'media_asset': {
            'id': '9001',
            'media_type': 'image',
            'public_url': 'file:///data/user/0/com.elitesync/files/4_2_demo_image.png',
            'status': 'ready',
            'mime_type': 'image/png',
            'size_bytes': 58241,
            'width': 1024,
            'height': 1024,
          },
        },
      ],
    },
  ];
}
