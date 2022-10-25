SELECT p1.country_code,
       p1.size AS size2010, 
       p2.size AS size2015,
       -- 1. calculate growth_perc
       ((p2.size - p1.size)/p1.size * 100.0) AS growth_perc 
-- 2. From populations (alias as p1)
FROM populations AS p1
  -- 3. Join to itself (alias as p2)
  INNER JOIN populations AS p2
    -- 4. Match on country code
    ON p1.country_code = p2.country_code
        -- 5. and year (with calculation)
        AND p1.year = p2.year - 5;

SELECT DISTINCT name
FROM languages
WHERE code IN
  (SELECT code
   FROM countries
   WHERE region = 'Middle East')
ORDER BY name

-- Select fields
SELECT *
  -- From populations
  FROM populations 
-- Where life_expectancy is greater than
WHERE life_expectancy >
  -- 1.15 * subquery
  1.15*(SELECT AVG(life_expectancy)
  -- From populations
  FROM populations
-- Where year is 2015
WHERE YEAR = 2015)
  AND year = 2015;

  /*
SELECT countries.name AS country, COUNT(*) AS cities_num
  FROM cities
    INNER JOIN countries
    ON countries.code = cities.country_code
GROUP BY country
ORDER BY cities_num DESC, country
LIMIT 9;
*/
 
SELECT name AS country,
  (SELECT COUNT(*)
   FROM cities
   WHERE countries.code = cities.country_code) AS cities_num
FROM countries
ORDER BY cities_num DESC, country

LIMIT 9;


-- Select fields
SELECT countries.local_name,subquery.lang_num
  -- From countries
  FROM countries,
  	-- Subquery (alias as subquery)
  	(SELECT code,COUNT(*) as lang_num
  -- From languages
  FROM languages
-- Group by code
GROUP BY code) AS subquery
  -- Where codes match
WHERE countries.code = subquery.code
-- Order by descending number of languages
ORDER BY lang_num DESC;

-- Select fields
SELECT name, continent,inflation_rate
  -- From countries
  FROM countries
  	-- Join to economies
  	LEFT JOIN economies
    -- Match on code
    ON countries.code = economies.code
-- Where year is 2015
WHERE year = 2015
AND inflation_rate IN (
-- Select fields
SELECT MAX(inflation_rate) as max_inf
  -- Subquery using FROM (alias as subquery)
  FROM (
-- Select fields
SELECT name, continent,inflation_rate
  -- From countries
  FROM countries
  	-- Join to economies
  	INNER JOIN economies
    -- Match on code
    USING(code)
-- Where year is 2015
WHERE year = 2015) AS  subquery
-- Group by continent
GROUP BY continent)


-- Select fields
SELECT DISTINCT c.name, e.total_investment, e.imports
  -- From table (with alias)
  FROM countries AS c
    -- Join with table (with alias)
    LEFT JOIN economies AS e
      -- Match on code
      ON (c.code = e.code
      -- and code in Subquery
        AND c.code IN (
          SELECT l.code
          FROM languages AS l
          WHERE official = 'true'
        ) )
  -- Where region and year are correct
  WHERE region = 'Central America' AND year = '2015'
-- Order by field
ORDER BY c.name ASC;


-- Select fields
SELECT name, country_code,city_proper_pop, metroarea_pop,  
      -- Calculate city_perc
    city_proper_pop/  metroarea_pop * 100 AS city_perc
  -- From appropriate table
  FROM cities
  -- Where 
  WHERE name IN
    -- Subquery
    (SELECT capital
     FROM countries
     WHERE (continent = 'Europe'
        OR continent LIKE '%America'))
       AND metroarea_pop IS NOT NULL
-- Order appropriately
ORDER BY city_perc DESC
-- Limit amount
LIMIT 10;