class QuestionnaireMock {
  static const meta = {
    'version': 'q_v2',
    'bank_version': 'qb_v1',
    'attempt_version': 'qa_v1',
    'label': '非官方人格四维问卷',
    'non_official_notice': '仅用于产品内人格倾向参考，不代表官方 MBTI。',
    'total': 20,
    'estimated_minutes': 6,
  };

  static const questions = [
    {
      'id': 1,
      'title': '面对冲突时，你更倾向？',
      'options': ['先冷静再沟通', '立即表达情绪', '先避免冲突', '寻找第三方建议'],
      'question_version': 1,
    },
    {
      'id': 2,
      'title': '你更重视关系中的哪项？',
      'options': ['安全感', '激情', '成长', '陪伴'],
      'question_version': 1,
    },
  ];

  static const draftSaved = {'ok': true, 'message': '草稿已保存'};

  static const submitHappy = {
    'ok': true,
    'questionnaire_version': 'q_v2',
    'bank_version': 'qb_v1',
    'attempt_version': 'qa_v1',
    'profile': {
      'answered': 2,
      'total': 20,
      'complete': false,
      'vector': {'attachment_security': 56, 'communication_clarity': 63},
      'summary': {
        'label': '倾向：attachment_security + communication_clarity',
        'highlights': ['attachment_security 56', 'communication_clarity 63'],
      },
    },
  };

  static const submitError = {
    'ok': false,
    'code': 'QUESTIONNAIRE_SUBMIT_ERROR',
    'message': '问卷提交失败',
  };

  static const history = [
    {
      'id': 101,
      'questionnaire_version': 'q_v2',
      'bank_version': 'qb_v1',
      'attempt_version': 'qa_v1',
      'answers_count': 2,
      'total_count': 20,
      'result_label': '倾向：attachment_security + communication_clarity',
      'result_highlights': [
        'attachment_security 56',
        'communication_clarity 63',
      ],
      'profile_complete': false,
      'completed_at': '2026-04-18T09:10:00+08:00',
    },
    {
      'id': 100,
      'questionnaire_version': 'q_v2',
      'bank_version': 'qb_v1',
      'attempt_version': 'qa_v1',
      'answers_count': 20,
      'total_count': 20,
      'result_label': '倾向：social_initiative + openness_exploration',
      'result_highlights': ['social_initiative 82', 'openness_exploration 77'],
      'profile_complete': true,
      'completed_at': '2026-04-15T14:22:00+08:00',
    },
  ];
}
