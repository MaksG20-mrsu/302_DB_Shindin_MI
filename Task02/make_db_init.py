#!/usr/bin/env python3
import csv
import re
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent
DATASET_DIR = BASE_DIR / "dataset"
SQL_FILE = BASE_DIR / "db_init.sql"


def sql_value(v):
    if v is None:
        return "NULL"
    if isinstance(v, (int, float)):
        return str(v)
    s = str(v).strip()
    if s == "":
        return "NULL"
    return "'" + s.replace("'", "''") + "'"


def detect_delimiter(path: Path) -> str:
    with path.open("r", encoding="utf-8", errors="replace") as f:
        first = f.readline()
    for d in ("\t", "|", ",", ";"):
        if d in first:
            return d
    return ","


def read_rows(path: Path):
    if not path.exists():
        raise FileNotFoundError(f"Не найден файл: {path}")
    delim = detect_delimiter(path)
    with path.open("r", encoding="utf-8", errors="replace", newline="") as f:
        reader = csv.reader(f, delimiter=delim)
        rows = [r for r in reader if r and any(c.strip() for c in r)]
    return rows


def drop_header_if_present(rows, expected_keys):
    if not rows:
        return rows
    header = [h.strip().lower() for h in rows[0]]
    if any(k in header for k in expected_keys):
        return rows[1:]
    return rows


def parse_title_year(raw_title: str):
    m = re.match(r"^(.*)\s+\((\d{4})\)\s*$", raw_title.strip())
    if m:
        return m.group(1).strip(), int(m.group(2))
    return raw_title.strip(), None


def parse_movies():
    rows = read_rows(DATASET_DIR / "movies.csv")
    rows = drop_header_if_present(rows, ("title", "movieid", "movie_id"))
    out = []
    for r in rows:
        if len(r) < 3:
            continue
        movie_id = int(r[0])
        title, year = parse_title_year(r[1])
        genres = r[2].strip()
        out.append((movie_id, title, year, genres))
    return out


def parse_ratings():
    rows = read_rows(DATASET_DIR / "ratings.csv")
    rows = drop_header_if_present(rows, ("userid", "user_id", "rating"))
    out = []
    for i, r in enumerate(rows, start=1):
        if len(r) < 4:
            continue
        out.append((i, int(r[0]), int(r[1]), float(r[2]), int(r[3])))
    return out


def parse_tags():
    rows = read_rows(DATASET_DIR / "tags.csv")
    rows = drop_header_if_present(rows, ("userid", "user_id", "tag"))
    out = []
    for i, r in enumerate(rows, start=1):
        if len(r) < 4:
            continue
        out.append((i, int(r[0]), int(r[1]), r[2].strip(), int(r[3])))
    return out


def parse_users():
    path = DATASET_DIR / "users.txt"
    rows = read_rows(path)
    rows = drop_header_if_present(
        rows, ("name", "email", "gender", "id", "user_id", "userid")
    )
    out = []
    for r in rows:
        if len(r) >= 6:
            out.append((
                int(r[0]),
                r[1].strip(),
                r[2].strip(),
                r[3].strip(),
                r[4].strip(),
                r[5].strip(),
            ))
        elif len(r) == 5:
            # fallback: id|gender|...|occupation (movielens users.dat)
            out.append((int(r[0]), None, None, r[1].strip(), None, r[3].strip()))
    return out


DDL = """
CREATE TABLE movies (
    id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    year INTEGER,
    genres TEXT
);

CREATE TABLE ratings (
    id INTEGER PRIMARY KEY,
    user_id INTEGER NOT NULL,
    movie_id INTEGER NOT NULL,
    rating REAL NOT NULL,
    timestamp INTEGER NOT NULL
);

CREATE TABLE tags (
    id INTEGER PRIMARY KEY,
    user_id INTEGER NOT NULL,
    movie_id INTEGER NOT NULL,
    tag TEXT,
    timestamp INTEGER NOT NULL
);

CREATE TABLE users (
    id INTEGER PRIMARY KEY,
    name TEXT,
    email TEXT,
    gender TEXT,
    register_date TEXT,
    occupation TEXT
);
""".strip()


def build_sql() -> str:
    lines = ["PRAGMA foreign_keys = OFF;", "BEGIN TRANSACTION;"]
    for t in ("tags", "ratings", "movies", "users"):
        lines.append(f"DROP TABLE IF EXISTS {t};")
    lines.append(DDL)
    lines.append("")

    for row in parse_movies():
        lines.append(
            "INSERT INTO movies (id, title, year, genres) VALUES "
            f"({sql_value(row[0])}, {sql_value(row[1])}, "
            f"{sql_value(row[2])}, {sql_value(row[3])});"
        )
    for row in parse_ratings():
        lines.append(
            "INSERT INTO ratings (id, user_id, movie_id, rating, timestamp) VALUES "
            f"({sql_value(row[0])}, {sql_value(row[1])}, "
            f"{sql_value(row[2])}, {sql_value(row[3])}, {sql_value(row[4])});"
        )
    for row in parse_tags():
        lines.append(
            "INSERT INTO tags (id, user_id, movie_id, tag, timestamp) VALUES "
            f"({sql_value(row[0])}, {sql_value(row[1])}, "
            f"{sql_value(row[2])}, {sql_value(row[3])}, {sql_value(row[4])});"
        )
    for row in parse_users():
        lines.append(
            "INSERT INTO users (id, name, email, gender, register_date, occupation) VALUES "
            f"({sql_value(row[0])}, {sql_value(row[1])}, {sql_value(row[2])}, "
            f"{sql_value(row[3])}, {sql_value(row[4])}, {sql_value(row[5])});"
        )

    lines.append("COMMIT;")
    return "\n".join(lines) + "\n"


def main():
    SQL_FILE.write_text(build_sql(), encoding="utf-8")
    print(f"OK: {SQL_FILE}")


if __name__ == "__main__":
    main()