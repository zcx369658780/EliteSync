import time

from fastapi.testclient import TestClient

from app.main import app


client = TestClient(app)


def _auth_headers() -> dict[str, str]:
    phone = f"139{int(time.time())%100000000:08d}"
    reg = client.post('/api/v1/auth/register', json={'phone': phone, 'password': 'pass123'})
    assert reg.status_code == 200
    token = reg.json()['access_token']
    return {'Authorization': f'Bearer {token}'}


def test_profile_astro_returns_structured_chart_data():
    hdr = _auth_headers()

    saved = client.post(
        '/api/v1/profile/astro',
        headers=hdr,
        json={
            'birthday': '1990-01-01',
            'birth_time': '12:30',
            'birth_place': '北京',
            'birth_lat': 39.9042,
            'birth_lng': 116.4074,
            'tz_str': 'Asia/Shanghai',
        },
    )
    assert saved.status_code == 200
    assert saved.json()['ok'] is True

    res = client.get('/api/v1/profile/astro', headers=hdr)
    assert res.status_code == 200
    payload = res.json()
    assert payload['exists'] is True
    profile = payload['profile']
    assert 'natal_chart_svg' not in profile
    assert isinstance(profile['chart_data'], dict)
    assert isinstance(profile['planets_data'], list) and profile['planets_data']
    assert isinstance(profile['aspects_data'], list)
    assert isinstance(profile['houses_data'], list) and len(profile['houses_data']) == 12


def test_profile_astro_render_returns_chart_data():
    res = client.post(
        '/api/v1/profile/astro/render',
        json={
            'name': 'EliteSync',
            'birthday': '1990-01-01',
            'birth_time': '12:30',
            'birth_place': '北京',
            'birth_lat': 39.9042,
            'birth_lng': 116.4074,
            'tz_str': 'Asia/Shanghai',
        },
    )
    assert res.status_code == 200
    data = res.json()
    assert data['ok'] is True
    profile = data['profile']
    assert 'natal_chart_svg' not in profile
    assert isinstance(profile['chart_data'], dict)
    assert isinstance(profile['planets_data'], list)
    assert isinstance(profile['houses_data'], list)
    assert isinstance(profile['aspects_data'], list)
