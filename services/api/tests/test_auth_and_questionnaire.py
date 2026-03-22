import time
from fastapi.testclient import TestClient
from app.main import app


client = TestClient(app)


def test_register_login_refresh_and_progress():
    phone = f"138{int(time.time())%100000000:08d}"
    reg = client.post('/api/v1/auth/register', json={'phone': phone, 'password': 'pass123'})
    assert reg.status_code == 200
    tokens = reg.json()
    assert 'access_token' in tokens

    login = client.post('/api/v1/auth/login', json={'phone': phone, 'password': 'pass123'})
    assert login.status_code == 200

    refreshed = client.post('/api/v1/auth/refresh', json={'refresh_token': tokens['refresh_token']})
    assert refreshed.status_code == 200

    hdr = {'Authorization': f"Bearer {tokens['access_token']}"}
    q = client.get('/api/v1/questions', headers=hdr)
    assert q.status_code == 200
    qid = q.json()[0]['id']

    saved = client.post('/api/v1/questions/answers', headers=hdr, json={'answers': [{'question_id': qid, 'answer': 'A', 'is_draft': False}]})
    assert saved.status_code == 200

    prog = client.get('/api/v1/questions/answers/progress', headers=hdr)
    assert prog.status_code == 200
    assert prog.json()['done'] >= 1
