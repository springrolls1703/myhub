-- P1: Triangle problems
-- P2: Draw the triangles
-- P3: Set using @
-- P4: Binary tree - CASE WHEN EXIST - Check if a record exist in a table

-- P1
-- Write a query identifying the type of each record in the TRIANGLES table using its three side lengths. Output one of the following statements for each record in the table:
-- Equilateral: It's a triangle with  sides of equal length.
-- Isosceles: It's a triangle with  sides of equal length.
-- Scalene: It's a triangle with  sides of differing lengths.
-- Not A Triangle: The given values of A, B, and C don't form a triangle.

SELECT CASE
        WHEN A = B AND B = C THEN 'Equilateral'
        WHEN (A = B AND ABS(A - B) < C AND C < (A + B)) OR (A = C AND ABS(A - B) < C AND C < (A + B)) OR (C = B AND ABS(A - B) < C AND C < (A + B)) THEN 'Isosceles'
        WHEN ABS(A - B) < C AND C < (A + B) THEN 'Scalene'
        ElSE 'Not A Triangle'
        END
FROM TRIANGLES

-- P2
-- P(R) represents a pattern drawn by Julia in R rows. The following pattern represents P(5).
-- Write a query to print the pattern P(20).

SELECT REPEAT('* ', @NUMBER := @NUMBER - 1) 
FROM information_schema.tables, 
(SELECT @NUMBER:=21) t LIMIT 20
    

-- P3
set @r1=0, @r2=0, @r3=0, @r4=0;
select min(Doctor), min(Professor), min(Singer), min(Actor)
from(
  select case when Occupation='Doctor' then (@r1:=@r1+1)
            when Occupation='Professor' then (@r2:=@r2+1)
            when Occupation='Singer' then (@r3:=@r3+1)
            when Occupation='Actor' then (@r4:=@r4+1) end as RowNumber,
    case when Occupation='Doctor' then Name end as Doctor,
    case when Occupation='Professor' then Name end as Professor,
    case when Occupation='Singer' then Name end as Singer,
    case when Occupation='Actor' then Name end as Actor
  from OCCUPATIONS
  order by Name
) Temp
group by RowNumber

-- P4
SELECT N , 
        CASE 
        WHEN P IS NULL THEN 'Root' 
        WHEN EXISTS (SELECT P FROM BST B WHERE A.N=B.P) THEN 'Inner' 
        ELSE 'Leaf' END  
FROM BST A ORDER BY N

