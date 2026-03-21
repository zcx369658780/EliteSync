import json
import random
import hashlib
from pathlib import Path

ROOT = Path('D:/EliteSync')
BATCH_DIR = ROOT / 'question_bank' / 'batches_v2'
BATCH_DIR.mkdir(parents=True, exist_ok=True)
OUT = BATCH_DIR / 'q_rel_v2_061_200_generated.json'

DIMS = [
    'attachment_security',
    'emotional_regulation',
    'communication_clarity',
    'conflict_repair',
    'reciprocity_investment',
    'commitment_readiness',
    'autonomy_boundary',
    'empathy_responsiveness',
    'planning_reliability',
    'openness_exploration',
    'rejection_resilience',
    'intimacy_disclosure',
    'social_initiative',
]

CONTEXTS = [
    ('communication', '聊天沟通'),
    ('lifestyle', '日常安排'),
    ('relationship_goals', '关系推进'),
    ('social_energy', '社交活动'),
    ('family', '家庭互动'),
    ('intimacy', '亲密表达'),
    ('communication', '冲突沟通'),
    ('lifestyle', '时间管理'),
    ('relationship_goals', '长期规划'),
    ('social_energy', '朋友圈层'),
    ('family', '节日协同'),
    ('intimacy', '边界感受'),
    ('communication', '反馈处理'),
    ('lifestyle', '消费习惯'),
    ('relationship_goals', '承诺节奏'),
    ('social_energy', '公开互动'),
    ('family', '原生家庭'),
    ('intimacy', '情绪接纳'),
    ('communication', '信息透明'),
    ('lifestyle', '习惯磨合'),
]

EVENTS = [
    '临时变化',
    '信息不够透明',
    '推进节奏偏快',
    '投入感不均衡',
    '期待存在分歧',
    '外部压力突然增加',
    '同类问题反复出现',
]

SCENE_PREFIX = [
    '你们正在讨论下一次见面安排时，',
    '在一次本来气氛不错的相处中，',
    '当你认真投入这段关系后，',
    '你准备把关系往前推进一点时，',
    '在一次需要共同决策的场景里，',
]

A_TMPL = [
    '我会先确认具体原因，再把自己的感受和安排说清楚，尽量一起找可行方案。',
    '我会先把事实和影响讲明白，然后和对方协商一个双方都能执行的做法。',
    '我会优先做一次清晰沟通，既表达边界，也给对方解释与调整的空间。',
]
B_TMPL = [
    '我会先保持弹性，观察一下，再找一个合适时机把这件事聊开。',
    '我会先不急着下结论，给彼此一点缓冲时间，再决定怎么沟通。',
    '我会先接受当下状态，但会在之后补上一轮更具体的对齐。',
]
C_TMPL = [
    '我可能会先压住不说，等情绪累积后再看要不要处理。',
    '我会先自己消化，但心里会不断复盘这件事是否值得继续投入。',
    '我多半不会立刻回应，容易在心里放大这件事的负面信号。',
]
D_TMPL = [
    '我会优先保护自己的边界，必要时降低投入强度。',
    '如果短期看不到改善，我会把关系节奏放慢，避免继续消耗。',
    '我会先把重心收回到自己身上，减少对这段关系的依赖。',
]

BASE = [
    [0.72, 0.61, 0.48, 0.33, 0.19],
    [0.36, 0.27, 0.14, 0.08, -0.11],
    [-0.14, -0.22, -0.31, -0.43, 0.17],
    [0.18, -0.09, -0.27, -0.36, -0.52],
]


def jitter(seed: str, idx: int) -> float:
    h = hashlib.sha1(f'{seed}:{idx}'.encode()).digest()
    raw = int(h[0]) / 255.0
    return round((raw - 0.5) * 0.14, 2)


def unique_values(vals):
    out = []
    seen = set()
    for i, v in enumerate(vals):
        x = round(v, 2)
        while x in seen:
            x = round(x + (0.01 if i % 2 == 0 else -0.01), 2)
        seen.add(x)
        out.append(x)
    return out


def make_weights(qid: str, dims, opt_idx: int):
    vals = []
    for i, _ in enumerate(dims):
        v = BASE[opt_idx][i] + jitter(f'{qid}:{opt_idx}', i)
        v = max(-0.85, min(0.85, v))
        vals.append(v)
    vals = unique_values(vals)
    return {d: vals[i] for i, d in enumerate(dims)}


def validate(q):
    dims = q['measured_dimensions']
    assert 2 <= len(dims) <= 5
    assert len(q['options']) == 4
    vectors = []
    all_vals = []
    for opt in q['options']:
        w = opt['dimension_weights']
        assert set(w.keys()) == set(dims)
        vals = [round(float(w[d]), 3) for d in dims]
        assert len(vals) == len(set(vals))
        vectors.append(tuple(vals))
        all_vals.extend(vals)
    assert len(vectors) == len(set(vectors))
    assert any(v > 0 for v in all_vals) and any(v < 0 for v in all_vals)


def main():
    out = []
    for n in range(61, 201):
        qid = f'Q_REL_V2_{n:03d}'
        cat, ctx = CONTEXTS[(n - 61) % len(CONTEXTS)]
        ev = EVENTS[(n - 61) % len(EVENTS)]
        prefix = SCENE_PREFIX[(n - 61) % len(SCENE_PREFIX)]

        rng = random.Random(n * 97)
        k = 2 + (n % 4)  # 2..5
        dims = rng.sample(DIMS, k)

        subtopic = f'v2_gen_{n:03d}'
        qtext = f'{prefix}{ctx}出现了“{ev}”的情况。你更可能怎么处理？'

        options = [
            {
                'option_id': 'A',
                'label': {'zh': A_TMPL[n % len(A_TMPL)]},
                'dimension_weights': make_weights(qid, dims, 0),
            },
            {
                'option_id': 'B',
                'label': {'zh': B_TMPL[n % len(B_TMPL)]},
                'dimension_weights': make_weights(qid, dims, 1),
            },
            {
                'option_id': 'C',
                'label': {'zh': C_TMPL[n % len(C_TMPL)]},
                'dimension_weights': make_weights(qid, dims, 2),
            },
            {
                'option_id': 'D',
                'label': {'zh': D_TMPL[n % len(D_TMPL)]},
                'dimension_weights': make_weights(qid, dims, 3),
            },
        ]

        q = {
            'question_id': qid,
            'category': cat,
            'subtopic': subtopic,
            'question_text': {'zh': qtext},
            'answer_type': 'single_choice',
            'acceptable_answer_logic': 'single_select',
            'measured_dimensions': dims,
            'options': options,
            'version': 2,
            'active': True,
        }
        validate(q)
        out.append(q)

    OUT.write_text(json.dumps(out, ensure_ascii=False), encoding='utf-8')
    print('generated', len(out), '->', OUT)


if __name__ == '__main__':
    main()
