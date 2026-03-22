import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
QB = ROOT / 'question_bank' / 'dating_question_bank_v_1.json'
BATCH_DIR = ROOT / 'question_bank' / 'batches_v2'


def validate_question(q):
    dims = q.get('measured_dimensions', [])
    if not (2 <= len(dims) <= 5):
        raise ValueError(f"{q.get('question_id')} dims count invalid")
    opts = q.get('options', [])
    if len(opts) != 4:
        raise ValueError(f"{q.get('question_id')} options != 4")

    vectors = []
    all_values = []
    for opt in opts:
        w = opt.get('dimension_weights', {})
        if set(w.keys()) != set(dims):
            raise ValueError(f"{q.get('question_id')} keys mismatch")
        vals = [round(float(w[d]), 3) for d in dims]
        if len(vals) != len(set(vals)):
            raise ValueError(f"{q.get('question_id')} option internal duplicate weights")
        vectors.append(tuple(vals))
        all_values.extend(vals)

    if len(vectors) != len(set(vectors)):
        raise ValueError(f"{q.get('question_id')} duplicated option vectors")
    if not (any(v > 0 for v in all_values) and any(v < 0 for v in all_values)):
        raise ValueError(f"{q.get('question_id')} not both positive and negative")


def load_existing():
    data = json.loads(QB.read_text(encoding='utf-8'))
    return data


def load_batches():
    items = []
    if not BATCH_DIR.exists():
        return items
    for p in sorted(BATCH_DIR.glob('q_rel_v2_*.json')):
        arr = json.loads(p.read_text(encoding='utf-8'))
        if not isinstance(arr, list):
            raise ValueError(f'{p} is not list')
        items.extend(arr)
    return items


def split_and_write(all_questions):
    total = len(all_questions)
    # keep bank mix close to questionnaire.bank_mix_ratio (core 50%, extended 30%, research 20%)
    core_n = int(total * 0.5)
    ext_n = int(total * 0.3)
    res_n = total - core_n - ext_n

    core = all_questions[:core_n]
    ext = all_questions[core_n:core_n + ext_n]
    res = all_questions[core_n + ext_n:core_n + ext_n + res_n]

    for q in core:
        q['recommended_bank'] = 'core'
    for q in ext:
        q['recommended_bank'] = 'extended'
    for q in res:
        q['recommended_bank'] = 'research'

    def payload(title, bank_id, qs):
        return {
            'schema_version': '2.0',
            'question_bank_id': bank_id,
            'title': {'zh': title, 'en': title},
            'description': {'zh': 'V2 多维联合测量题库', 'en': 'V2 multi-dimensional bank'},
            'categories': sorted({q['category'] for q in qs}),
            'default_importance_mapping': {'0': 0.0, '1': 0.33, '2': 0.66, '3': 1.0},
            'questions': qs,
        }

    qb_dir = ROOT / 'question_bank'
    (qb_dir / 'question_bank_core_v1.json').write_text(json.dumps(payload('慢约会题库 core v2','question_bank_core_v1',core), ensure_ascii=False, indent=2), encoding='utf-8')
    (qb_dir / 'question_bank_extended_v1.json').write_text(json.dumps(payload('慢约会题库 extended v2','question_bank_extended_v1',ext), ensure_ascii=False, indent=2), encoding='utf-8')
    (qb_dir / 'question_bank_research_v1.json').write_text(json.dumps(payload('慢约会题库 research v2','question_bank_research_v1',res), ensure_ascii=False, indent=2), encoding='utf-8')

    merged = {
        'schema_version': '2.0',
        'question_bank_id': 'dating_question_bank_v_1',
        'title': {'zh': '慢约会题库 v2', 'en': 'SlowDating Question Bank v2'},
        'description': {'zh': f'V2 多维题库（{total}题）', 'en': f'V2 bank ({total} questions)'},
        'categories': sorted({q['category'] for q in all_questions}),
        'default_importance_mapping': {'0': 0.0, '1': 0.33, '2': 0.66, '3': 1.0},
        'questions': all_questions,
    }
    (qb_dir / 'dating_question_bank_v_1.json').write_text(json.dumps(merged, ensure_ascii=False, indent=2), encoding='utf-8')


def main():
    data = load_existing()
    base_questions = data.get('questions', [])
    batches = load_batches()

    by_id = {q['question_id']: q for q in base_questions}
    for q in batches:
        validate_question(q)
        by_id[q['question_id']] = q

    all_questions = [by_id[k] for k in sorted(by_id.keys())]
    for q in all_questions:
        validate_question(q)

    split_and_write(all_questions)
    print(f'merged total={len(all_questions)} from batches={len(batches)}')


if __name__ == '__main__':
    main()
