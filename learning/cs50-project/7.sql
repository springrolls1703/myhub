SELECT
title,
rating
FROM
movies
LEFT JOIN
ratings
ON movies.id = ratings.movie_id
WHERE YEAR = 2010 AND rating IS NOT NULL
ORDER BY rating DESC, title ASC