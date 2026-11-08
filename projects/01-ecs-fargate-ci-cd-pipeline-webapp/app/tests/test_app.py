from app import app


def test_health():
    client = app.test_client()
    response = client.get("/health")
    assert response.status_code == 200
    assert response.get_json()["status"] == "ok"


def test_hello_does_not_leak_hostname():
    client = app.test_client()
    response = client.get("/api/hello")
    assert response.status_code == 200
    payload = response.get_json()
    assert "instance" not in payload
    assert "message" in payload
