class QuestionnaireMock {
  static const meta = {'version': 'q_v1', 'total': 20, 'estimated_minutes': 6};

  static const questions = [
    {
      'id': 1,
      'title': '面对冲突时，你更倾向？',
      'options': ['先冷静再沟通', '立即表达情绪', '先避免冲突', '寻找第三方建议'],
    },
    {
      'id': 2,
      'title': '你更重视关系中的哪项？',
      'options': ['安全感', '激情', '成长', '陪伴'],
    },
  ];

  static const draftSaved = {'ok': true, 'message': '草稿已保存'};

  static const submitHappy = {'ok': true, 'message': '问卷提交成功'};

  static const submitError = {
    'ok': false,
    'code': 'QUESTIONNAIRE_SUBMIT_ERROR',
    'message': '问卷提交失败',
  };
}
