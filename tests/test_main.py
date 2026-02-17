import pytest
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_root():
    response = client.get("/")
    assert response.status_code == 200
    assert "Hello from AWS Python Sample!" in response.json()["message"]

def test_health_check():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json()["status"] == "healthy"

def test_get_items():
    response = client.get("/items")
    assert response.status_code == 200
    assert len(response.json()) == 2

def test_create_item():
    item_data = {
        "name": "Test Item",
        "description": "A test item",
        "price": 19.99
    }
    response = client.post("/items", json=item_data)
    assert response.status_code == 200
    assert response.json()["name"] == "Test Item"

def test_get_item():
    response = client.get("/items/0")
    assert response.status_code == 200
    assert response.json()["name"] == "Sample Item 1"

def test_get_item_not_found():
    response = client.get("/items/999")
    assert response.status_code == 404