# Pytest is a lightweight testing framework that lets you verify your Flask app's routes and responses automatically.
# Think of it as Postman for developers — but fully automated and CI/CD-friendly.

import pytest
from app import app

@pytest.fixture
def client():
    app.config["TESTING"] = True
    with app.test_client() as client:
        yield client

def test_home(client):
    rv = client.get("/")
    assert rv.status_code == 200
    assert b"ECS Fargate" in rv.data

def test_health(client):
    rv = client.get("/health")
    assert rv.status_code == 200
    assert rv.json == {"status": "ok"}


# To run the tests locally, use the following command:
# pip install -r requirements.txt pytest
# pytest app/tests/