class MatchMock {
  static const countdown = {
    'status': 'waiting_drop',
    'reveal_at': '2026-03-31T21:00:00+08:00',
    'hint': '资料完成度越高，匹配解释会更精准。',
  };

  static const resultHappy = {
    'status': 'matched',
    'match_id': '1703',
    'headline': '你们在沟通与情绪节奏上较契合',
    'score': 86,
    'confidence': 88,
    'tags': ['同城', '高匹配', '节奏接近'],
    'highlights': [
      {'title': '依恋安全感', 'value': 51, 'desc': '都倾向稳定关系'},
      {'title': '冲突修复倾向', 'value': 48, 'desc': '冲突后愿意重建沟通'},
    ],
  };

  static const resultNoMatch = {
    'status': 'no_match',
    'message': '暂无匹配或未到 Drop',
  };

  static const resultError = {
    'ok': false,
    'code': 'MATCH_RESULT_ERROR',
    'message': '匹配结果获取失败',
  };
}
