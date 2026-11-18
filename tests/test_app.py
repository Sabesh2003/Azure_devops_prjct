import sqlite3
import app as attendance_app


def setup_database(monkeypatch, tmp_path):
    database = tmp_path / "test-attendance.db"
    monkeypatch.setattr(attendance_app, "DB_PATH", str(database))
    attendance_app.init_db()
    return database


def test_health_endpoint():
    client = attendance_app.app.test_client()
    response = client.get("/health")
    assert response.status_code == 200
    assert response.get_json() == {"status": "healthy"}


def test_home_page_renders(monkeypatch, tmp_path):
    setup_database(monkeypatch, tmp_path)
    client = attendance_app.app.test_client()
    response = client.get("/")
    assert response.status_code == 200
    assert b"Attendance System" in response.data


def test_mark_attendance_and_view_records(monkeypatch, tmp_path):
    database = setup_database(monkeypatch, tmp_path)
    client = attendance_app.app.test_client()

    response = client.post(
        "/",
        data={
            "name": "Test Employee",
            "employee_id": "EMP001",
            "status": "Present",
        },
        follow_redirects=True,
    )
    assert response.status_code == 200
    assert b"Attendance marked for Test Employee" in response.data

    records_response = client.get("/records")
    assert records_response.status_code == 200
    assert b"Test Employee" in records_response.data
    assert b"EMP001" in records_response.data

    with sqlite3.connect(database) as connection:
        count = connection.execute("SELECT COUNT(*) FROM attendance").fetchone()[0]
    assert count == 1
