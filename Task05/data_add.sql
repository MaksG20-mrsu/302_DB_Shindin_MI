-- Лабораторная работа 5. Добавление новых данных.
-- Запуск (после db_init.sql): sqlite3 movies_rating.db < data_add.sql
-- Идентификаторы нигде не заданы вручную: первичные ключи присваиваются базой,
-- а связи находятся подзапросами по e-mail, названию и году.

PRAGMA foreign_keys = ON;

BEGIN TRANSACTION;

-- 1. Пять новых пользователей: я и четыре ближайших соседа по списку группы.
--    Дата регистрации берётся из системного времени (date('now')).
--    TODO: замените имя, фамилию, e-mail и пол на реальные данные
--    (строки с Name1..Name4 / Surname1..Surname4 — это заглушки).
INSERT INTO users (first_name, last_name, email, gender, register_date, occupation_id)
VALUES ('Mikhail', 'Mekhontsev', 'mekhontsev.mv@example.com', 'male', date('now'),
        (SELECT id FROM occupations WHERE name = 'student'));

INSERT INTO users (first_name, last_name, email, gender, register_date, occupation_id)
VALUES ('Name1', 'Surname1', 'neighbor1@example.com', 'male', date('now'),
        (SELECT id FROM occupations WHERE name = 'student'));

INSERT INTO users (first_name, last_name, email, gender, register_date, occupation_id)
VALUES ('Name2', 'Surname2', 'neighbor2@example.com', 'male', date('now'),
        (SELECT id FROM occupations WHERE name = 'student'));

INSERT INTO users (first_name, last_name, email, gender, register_date, occupation_id)
VALUES ('Name3', 'Surname3', 'neighbor3@example.com', 'female', date('now'),
        (SELECT id FROM occupations WHERE name = 'student'));

INSERT INTO users (first_name, last_name, email, gender, register_date, occupation_id)
VALUES ('Name4', 'Surname4', 'neighbor4@example.com', 'female', date('now'),
        (SELECT id FROM occupations WHERE name = 'student'));

-- 2. Три новых фильма разных жанров.
INSERT INTO movies (title, year) VALUES ('Dune', 2021);
INSERT INTO movies (title, year) VALUES ('Soul', 2020);
INSERT INTO movies (title, year) VALUES ('Midsommar', 2019);

-- Жанры новых фильмов (идентификаторы фильмов и жанров определяются запросом).
INSERT INTO movie_genres (movie_id, genre_id)
SELECT m.id, g.id
FROM movies m
JOIN genres g ON g.name IN ('Adventure', 'Drama', 'Sci-Fi')
WHERE m.title = 'Dune' AND m.year = 2021;

INSERT INTO movie_genres (movie_id, genre_id)
SELECT m.id, g.id
FROM movies m
JOIN genres g ON g.name IN ('Animation', 'Children', 'Comedy', 'Fantasy')
WHERE m.title = 'Soul' AND m.year = 2020;

INSERT INTO movie_genres (movie_id, genre_id)
SELECT m.id, g.id
FROM movies m
JOIN genres g ON g.name IN ('Drama', 'Horror', 'Mystery')
WHERE m.title = 'Midsommar' AND m.year = 2019;

-- 3. Три отзыва о добавленных фильмах от меня.
--    Время оценки проставляется по умолчанию (текущее системное время).
INSERT INTO ratings (user_id, movie_id, rating)
VALUES ((SELECT id FROM users  WHERE email = 'mekhontsev.mv@example.com'),
        (SELECT id FROM movies WHERE title = 'Dune' AND year = 2021),
        4.5);

INSERT INTO ratings (user_id, movie_id, rating)
VALUES ((SELECT id FROM users  WHERE email = 'mekhontsev.mv@example.com'),
        (SELECT id FROM movies WHERE title = 'Soul' AND year = 2020),
        4.0);

INSERT INTO ratings (user_id, movie_id, rating)
VALUES ((SELECT id FROM users  WHERE email = 'mekhontsev.mv@example.com'),
        (SELECT id FROM movies WHERE title = 'Midsommar' AND year = 2019),
        3.5);

COMMIT;
