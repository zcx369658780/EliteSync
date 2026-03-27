class AuthMock {
  static const loginHappy = {
    'ok': true,
    'token': 'mock_access_token_001',
    'refresh_token': 'mock_refresh_token_001',
    'user': {
      'id': 10001,
      'phone': '13800000022',
      'nickname': '星语者',
      'city': '南阳市',
      'verified': true,
    },
  };

  static const loginError = {
    'ok': false,
    'code': 'AUTH_INVALID_CREDENTIALS',
    'message': '账号或密码错误',
  };

  static const registerHappy = {'ok': true, 'message': '注册成功'};

  static const registerError = {
    'ok': false,
    'code': 'AUTH_PHONE_EXISTS',
    'message': '手机号已注册',
  };
}
