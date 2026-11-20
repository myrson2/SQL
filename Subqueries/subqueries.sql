Select * FROM examinee;

-- 1. List the name and school of the first 5 students who got who scored higher than the average score?

SELECT Name, School
FROM examinee
WHERE Score > (SELECT AVG(Score) FROM examinee)
LIMIt 5;

-- 2. List the name and school of the examinees from Manila who got the 3 lowest scores.

-- Lowest Scores: 70, 75, 80
SELECT Score FROM examinee
GROUP BY Score
ORDER BY Score ASC
LIMIT 3;

SELECT Name, School FROM examinee AS e
JOIN (
	SELECT Score FROM examinee
	GROUP BY Score
	ORDER BY Score ASC
	LIMIT 3
) AS lowest_scores 
ON e.Score = lowest_scores.Score
WHERE Address LIKE '%Manila%';

-- 3. How many schools made it to the top 3 (distinct schools)?

SELECT DISTINCT Score FROM examinee
ORDER BY Score DESC
LIMIT 3;

SELECT COUNT(DISTINCT e.School) AS top_3_distinct_schools
FROM examinee AS e
JOIN (
    SELECT DISTINCT Score
    FROM examinee
    ORDER BY Score DESC
    LIMIT 3
) AS top_3
  ON e.Score = top_3.Score;

-- 4. Count the number of students per school who made it to the top 3 e.g. UP 3, ADMU 3, PUP 2, UST 2.

SELECT School, COUNT(e.Name) as 'student_who_made_in_top3' 
FROM examinee as e
JOIN ( 
	SELECT DISTINCT Score FROM examinee
	ORDER BY Score DESC
	LIMIT 3
) as top3 
ON e.Score = top3.Score
GROUP BY School
ORDER BY student_who_made_in_top3 DESC, e.School ASC;  

-- 5. Name all examinees who got the 3rd highest score (Research on OFFSET to be used with LIMIT)

SELECT DISTINCT Score FROM examinee
ORDER BY Score DESC
LIMIT 1 OFFSET 2;

SELECT * FROM examinee 
WHERE Score = (
	SELECT DISTINCT Score FROM examinee
	ORDER BY Score DESC
	LIMIT 1 OFFSET 2
);




