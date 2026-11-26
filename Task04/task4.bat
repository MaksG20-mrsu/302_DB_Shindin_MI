#!/bin/bash
chcp 65001

sqlite3 movies_rating.db < db_init.sql

echo "1. Найти все пары пользователей, оценивших один и тот же фильм. Устранить дубликаты, проверить отсутствие пар с самим собой. Для каждой пары должны быть указаны имена пользователей и название фильма, который они ценили. В списке оставить первые 100 записей."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT DISTINCT u1.name AS user1, u2.name AS user2, m.title FROM ratings r1 JOIN ratings r2 ON r2.movie_id = r1.movie_id AND r1.user_id < r2.user_id JOIN users u1 ON u1.id = r1.user_id JOIN users u2 ON u2.id = r2.user_id JOIN movies m ON m.id = r1.movie_id ORDER BY u1.name, u2.name, m.title LIMIT 100;"
echo " "

echo "2. Найти 10 самых свежих оценок от разных пользователей, вывести названия фильмов, имена пользователей, оценку, дату отзыва в формате ГГГГ-ММ-ДД."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "WITH ranked AS (SELECT r.user_id, r.movie_id, r.rating, r.timestamp, ROW_NUMBER() OVER (PARTITION BY r.user_id ORDER BY r.timestamp DESC, r.id DESC) AS rn FROM ratings r) SELECT m.title, u.name, ranked.rating, date(ranked.timestamp, 'unixepoch') AS rating_date FROM ranked JOIN users u ON u.id = ranked.user_id JOIN movies m ON m.id = ranked.movie_id WHERE ranked.rn = 1 ORDER BY ranked.timestamp DESC LIMIT 10;"
echo " "

echo "3. Вывести в одном списке все фильмы с максимальным средним рейтингом и все фильмы с минимальным средним рейтингом. Общий список отсортировать по году выпуска и названию фильма. В зависимости от рейтинга в колонке «Рекомендуем» для фильмов должно быть написано «Да» или «Нет»."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "WITH avg_r AS (SELECT m.id, m.title, m.year, AVG(r.rating) AS avg_rating FROM movies m JOIN ratings r ON r.movie_id = m.id GROUP BY m.id, m.title, m.year) SELECT title, year, ROUND(avg_rating, 2) AS avg_rating, CASE WHEN avg_rating = (SELECT MAX(avg_rating) FROM avg_r) THEN 'Да' ELSE 'Нет' END AS 'Рекомендуем' FROM avg_r WHERE avg_rating = (SELECT MAX(avg_rating) FROM avg_r) OR avg_rating = (SELECT MIN(avg_rating) FROM avg_r) ORDER BY year NULLS LAST, title;"
echo " "

echo "4. Вычислить количество оценок и среднюю оценку, которую дали фильмам пользователи-женщины в период с 2010 по 2012 год."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT COUNT(*) AS ratings_count, ROUND(AVG(r.rating), 2) AS avg_rating FROM ratings r JOIN users u ON u.id = r.user_id WHERE u.gender = 'female' AND CAST(strftime('%Y', r.timestamp, 'unixepoch') AS INTEGER) BETWEEN 2010 AND 2012;"
echo " "

echo "5. Составить список фильмов с указанием их средней оценки и места в рейтинге по средней оценке. Полученный список отсортировать по году выпуска и названиям фильмов. В списке оставить первые 20 записей."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "WITH avg_r AS (SELECT m.id, m.title, m.year, AVG(r.rating) AS avg_rating FROM movies m JOIN ratings r ON r.movie_id = m.id GROUP BY m.id, m.title, m.year) SELECT title, year, ROUND(avg_rating, 2) AS avg_rating, RANK() OVER (ORDER BY avg_rating DESC) AS rating_rank FROM avg_r ORDER BY year NULLS LAST, title LIMIT 20;"
echo " "

echo "6. Вывести список из 10 последних зарегистрированных пользователей в формате «Фамилия Имя|Дата регистрации» (сначала фамилия, потом имя)."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT substr(name, instr(name, ' ') + 1) || ' ' || substr(name, 1, instr(name, ' ') - 1) || '|' || register_date AS 'Фамилия Имя|Дата регистрации' FROM users ORDER BY register_date DESC, id DESC LIMIT 10;"
echo " "

echo "7. С помощью рекурсивного CTE составить таблицу умножения для чисел от 1 до 10. Должен получиться один столбец следующего вида: 1x1=1, 1x2=2, ..., 10x9=90, 10x10=100."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "WITH RECURSIVE a(n) AS (SELECT 1 UNION ALL SELECT n + 1 FROM a WHERE n < 10), b(m) AS (SELECT 1 UNION ALL SELECT m + 1 FROM b WHERE m < 10) SELECT n || 'x' || m || '=' || (n * m) AS multiplication_table FROM a, b ORDER BY n, m;"
echo " "

echo "8. С помощью рекурсивного CTE выделить все жанры фильмов, имеющиеся в таблице movies (каждый жанр в отдельной строке)."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "WITH RECURSIVE split(genre, rest) AS (SELECT '', genres || '|' FROM movies UNION ALL SELECT substr(rest, 1, instr(rest, '|') - 1), substr(rest, instr(rest, '|') + 1) FROM split WHERE rest <> '') SELECT DISTINCT genre FROM split WHERE genre <> '' ORDER BY genre;"
echo " "
