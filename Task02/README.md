# Task02. ETL для БД movies_rating.db

Утилита `make_db_init.py` читает исходные данные из каталога `dataset/`,
генерирует SQL-скрипт `db_init.sql` и создаёт базу `movies_rating.db`.

## Требования к окружению

- **Python 3** (команда `python3`) — <https://www.python.org/downloads/>
- **SQLite 3** (команда `sqlite3` доступна в `PATH`) — <https://www.sqlite.org/download.html>
- **Bash** (Linux, macOS, WSL, Git Bash для Windows) — <https://git-scm.com/downloads>

## Состав каталога `dataset/`

| Файл            | Назначение                          |
|-----------------|-------------------------------------|
| `movies.csv`    | фильмы (id, title, genres)          |
| `ratings.csv`   | оценки (userId, movieId, rating, ts)|
| `tags.csv`      | теги (userId, movieId, tag, ts)     |
| `users.txt`     | пользователи (id, name, email, ...) |

## Запуск

Из каталога `Task02`:

```bash
chmod +x db_init.bat
./db_init.bat