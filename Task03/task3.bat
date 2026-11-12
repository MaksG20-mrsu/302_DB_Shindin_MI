#!/bin/bash
chcp 65001

sqlite3 movies_rating.db < db_init.sql

echo "1. Составить список фильмов, имеющих хотя бы одну оценку. Список фильмов отсортировать по году выпуска и по названиям. В списке оставить первые 10 фильмов."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT m.id, m.title, m.year FROM movies m WHERE EXISTS (SELECT 1 FROM ratings r WHERE r.movie_id = m.id) ORDER BY m.year, m.title LIMIT 10;"
echo " "

echo "2. Вывести список всех пользователей, фамилии (не имена!) которых начинаются на букву 'A'. Полученный список отсортировать по дате регистрации. В списке оставить первых 5 пользователей."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT * FROM users WHERE substr(name, instr(name, ' ') + 1) LIKE 'A%' ORDER BY register_date LIMIT 5;"
echo " "

echo "3. Написать запрос, возвращающий информацию о рейтингах в более читаемом формате: имя и фамилия эксперта, название фильма, год выпуска, оценка и дата оценки в формате ГГГГ-ММ-ДД. Отсортировать данные по имени эксперта, затем названию фильма и оценке. В списке оставить первые 50 записей."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT u.name, m.title, m.year, r.rating, strftime('%Y-%m-%d', r.timestamp, 'unixepoch') AS rating_date FROM ratings r JOIN users u ON r.user_id = u.id JOIN movies m ON r.movie_id = m.id ORDER BY u.name, m.title, r.rating LIMIT 50;"
echo " "

echo "4. Вывести список фильмов с указанием тегов, которые были им присвоены пользователями. Сортировать по году выпуска, затем по названию фильма, затем по тегу. В списке оставить первые 40 записей."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT m.title, m.year, t.tag FROM movies m JOIN tags t ON m.id = t.movie_id ORDER BY m.year, m.title, t.tag LIMIT 40;"
echo " "

echo "5. Вывести список самых свежих фильмов. В список должны войти все фильмы последнего года выпуска, имеющиеся в базе данных. Запрос должен быть универсальным, не зависящим от исходных данных (нужный год выпуска должен определяться в запросе, а не жестко задаваться)."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT id, title, year FROM movies WHERE year = (SELECT MAX(year) FROM movies) ORDER BY title;"
echo " "

echo "6. Найти все драмы, выпущенные после 2005 года, которые понравились женщинам (оценка не ниже 4.5). Для каждого фильма в этом списке вывести название, год выпуска и количество таких оценок. Результат отсортировать по году выпуска и названию фильма."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT m.title, m.year, COUNT(*) AS cnt FROM movies m JOIN ratings r ON m.id = r.movie_id JOIN users u ON r.user_id = u.id WHERE m.genres LIKE '%Drama%' AND m.year > 2005 AND u.gender = 'female' AND r.rating >= 4.5 GROUP BY m.id, m.title, m.year ORDER BY m.year, m.title;"
echo " "

echo "7. Провести анализ востребованности ресурса - вывести количество пользователей, регистрировавшихся на сайте в каждом году. Найти, в каких годах регистрировалось больше всего и меньше всего пользователей."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT substr(register_date, 1, 4) AS year, COUNT(*) AS user_count FROM users GROUP BY year ORDER BY year;"
echo "Год с максимальным количеством регистраций:"
sqlite3 movies_rating.db -box -echo "SELECT substr(register_date, 1, 4) AS year, COUNT(*) AS user_count FROM users GROUP BY year ORDER BY user_count DESC LIMIT 1;"
echo "Год с минимальным количеством регистраций:"
sqlite3 movies_rating.db -box -echo "SELECT substr(register_date, 1, 4) AS year, COUNT(*) AS user_count FROM users GROUP BY year ORDER BY user_count ASC LIMIT 1;"
echo " "