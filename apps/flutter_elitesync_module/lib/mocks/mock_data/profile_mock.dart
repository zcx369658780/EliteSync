class ProfileMock {
  static const summary = {
    'id': 10001,
    'nickname': '星语者',
    'city': '南阳市',
    'verified': true,
    'completion': 0.78,
    'birth_time': '09:30',
    'tags': ['ENFJ', '射手座', '生肖马', '出生时间已保存'],
  };

  static const detail = {
    'nickname': '星语者',
    'gender': 'female',
    'birthday': '1998-11-25',
    'birth_time': '09:30',
    'city': '南阳市',
    'target': '恋爱',
  };

  static const updateHappy = {'ok': true, 'message': '资料保存成功'};

  static const updateError = {
    'ok': false,
    'code': 'PROFILE_UPDATE_ERROR',
    'message': '资料保存失败',
  };

  static const birthPlaces = [
    {'label': '武汉大学', 'address': '湖北省武汉市武昌区八一路299号', 'city': '武汉市', 'district': '武昌区', 'lat': 30.5431, 'lng': 114.3628},
    {'label': '武汉市', 'address': '湖北省武汉市', 'city': '武汉市', 'district': '', 'lat': 30.5928, 'lng': 114.3055},
    {'label': '华中科技大学', 'address': '湖北省武汉市洪山区珞喻路1037号', 'city': '武汉市', 'district': '洪山区', 'lat': 30.5047, 'lng': 114.4287},
    {'label': '北京大学', 'address': '北京市海淀区颐和园路5号', 'city': '北京市', 'district': '海淀区', 'lat': 39.9927, 'lng': 116.3106},
  ];
}
