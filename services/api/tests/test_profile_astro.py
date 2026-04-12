import uuid

from fastapi.testclient import TestClient

from app.main import app


client = TestClient(app)


def _auth_headers() -> dict[str, str]:
    phone = f"139{uuid.uuid4().int % 100000000:08d}"
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
    assert saved.json()['profile']['route_mode'] == 'standard'

    res = client.get('/api/v1/profile/astro?route_mode=modern', headers=hdr)
    assert res.status_code == 200
    payload = res.json()
    assert payload['exists'] is True
    profile = payload['profile']
    assert 'natal_chart_svg' not in profile
    assert isinstance(profile['chart_data'], dict)
    assert isinstance(profile['planets_data'], list) and profile['planets_data']
    assert isinstance(profile['aspects_data'], list)
    assert isinstance(profile['houses_data'], list) and len(profile['houses_data']) == 12
    assert profile['route_mode'] == 'modern'
    assert profile['engine_info']['engine_name'] == 'kerykeion'
    assert profile['engine_info']['schema_version'] == 'astro_engine_mvp_v1'
    assert profile['metadata']['schema_version'] == 'astro_engine_mvp_v1'
    assert 'canonical' in profile['metadata']['field_roles']
    assert profile['metadata']['route_context']['route_mode'] == 'modern'
    assert 'route_mode' in profile['metadata']['field_roles']['display_only']


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
            'route_mode': 'classical',
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
    assert profile['route_mode'] == 'classical'
    assert profile['engine_info']['engine_name'] == 'kerykeion'
    assert profile['engine_info']['schema_version'] == 'astro_engine_mvp_v1'
    assert profile['metadata']['route_context']['route_mode'] == 'classical'


def test_profile_astro_pair_returns_advanced_context():
    hdr = _auth_headers()

    res = client.post(
        '/api/v1/profile/astro/pair',
        headers=hdr,
        json={
            'pair_mode': 'synastry',
            'route_mode': 'standard',
            'first': {
                'name': 'Alice',
                'birthday': '1990-01-01',
                'birth_time': '12:30',
                'birth_place': '北京',
                'birth_lat': 39.9042,
                'birth_lng': 116.4074,
                'tz_str': 'Asia/Shanghai',
                'nation': 'CN',
            },
            'second': {
                'name': 'Bob',
                'birthday': '1992-06-15',
                'birth_time': '14:30',
                'birth_place': '上海',
                'birth_lat': 31.2304,
                'birth_lng': 121.4737,
                'tz_str': 'Asia/Shanghai',
                'nation': 'CN',
            },
        },
    )
    assert res.status_code == 200
    payload = res.json()
    assert payload['ok'] is True
    profile = payload['profile']
    assert profile['advanced_mode'] == 'pair'
    assert profile['pair_mode'] == 'synastry'
    assert profile['metadata']['advanced_context']['mode'] == 'pair'
    assert profile['metadata']['advanced_context']['pair_mode'] == 'synastry'
    assert isinstance(profile['chart_data'], dict)
    assert profile['primary_subject']['name'] == 'Alice'
    assert profile['secondary_subject']['name'] == 'Bob'
    assert isinstance(profile['primary_planets_data'], list)
    assert isinstance(profile['secondary_planets_data'], list)
    assert isinstance(profile['aspects_data'], list)


def test_profile_astro_transit_returns_advanced_context():
    hdr = _auth_headers()

    res = client.post(
        '/api/v1/profile/astro/transit',
        headers=hdr,
        json={
            'route_mode': 'modern',
            'natal': {
                'name': 'Natal',
                'birthday': '1990-01-01',
                'birth_time': '12:30',
                'birth_place': '北京',
                'birth_lat': 39.9042,
                'birth_lng': 116.4074,
                'tz_str': 'Asia/Shanghai',
                'nation': 'CN',
            },
            'transit': {
                'name': 'Transit',
                'birthday': '2026-04-12',
                'birth_time': '08:00',
                'birth_place': '北京',
                'birth_lat': 39.9042,
                'birth_lng': 116.4074,
                'tz_str': 'Asia/Shanghai',
                'nation': 'CN',
            },
        },
    )
    assert res.status_code == 200
    payload = res.json()
    assert payload['ok'] is True
    profile = payload['profile']
    assert profile['advanced_mode'] == 'transit'
    assert profile['metadata']['advanced_context']['mode'] == 'transit'
    assert profile['route_mode'] == 'modern'
    assert profile['primary_subject']['name'] == 'Natal'
    assert profile['secondary_subject']['name'] == 'Transit'


def test_profile_astro_return_returns_advanced_context():
    hdr = _auth_headers()

    res = client.post(
        '/api/v1/profile/astro/return',
        headers=hdr,
        json={
            'route_mode': 'classical',
            'return_year': 2026,
            'return_type': 'Lunar',
            'natal': {
                'name': 'Natal',
                'birthday': '1990-01-01',
                'birth_time': '12:30',
                'birth_place': '北京',
                'birth_lat': 39.9042,
                'birth_lng': 116.4074,
                'tz_str': 'Asia/Shanghai',
                'nation': 'CN',
            },
        },
    )
    assert res.status_code == 200
    payload = res.json()
    assert payload['ok'] is True
    profile = payload['profile']
    assert profile['advanced_mode'] == 'return'
    assert profile['metadata']['advanced_context']['mode'] == 'return'
    assert profile['metadata']['advanced_context']['return_type'] == 'Lunar'
    assert profile['metadata']['advanced_context']['return_year'] == 2026
    assert profile['route_mode'] == 'classical'
    assert profile['primary_subject']['name'] == 'Natal'
    assert profile['secondary_subject']['name'].endswith('Return')
