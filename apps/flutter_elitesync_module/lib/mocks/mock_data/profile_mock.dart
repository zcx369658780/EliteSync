class ProfileMock {
  static const summary = {
    'id': 10001,
    'nickname': '星语者',
    'city': '南阳市',
    'verified': true,
    'completion': 0.78,
    'tags': ['ENFJ', '射手座', '生肖马'],
  };

  static const detail = {
    'nickname': '星语者',
    'gender': 'female',
    'birthday': '1998-11-25',
    'city': '南阳市',
    'target': '恋爱',
  };

  static const updateHappy = {'ok': true, 'message': '资料保存成功'};

  static const updateError = {
    'ok': false,
    'code': 'PROFILE_UPDATE_ERROR',
    'message': '资料保存失败',
  };
}
