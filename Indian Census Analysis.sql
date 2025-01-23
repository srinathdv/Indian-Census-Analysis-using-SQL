-- Database Creation
CREATE DATABASE `Indian Census`;

USE `Indian Census`;

-- Tables Creation
CREATE TABLE data1(
	District VARCHAR(50),
    State VARCHAR(50),
    Growth FLOAT,
    Sex_Ratio INT,
    Literacy FLOAT
);

CREATE TABLE data2(
	District TEXT,
    State TEXT,
    Area_kms INT,
    Population INT
);

SELECT * FROM data1;
SELECT * FROM data2;

-- Data of Jharkhand and Bihar
SELECT d1.State,d1.District,d1.Growth,d1.Sex_Ratio,d1.Literacy,d2.Area_kms,d2.Population 
FROM data1 d1
JOIN data2 d2 ON d2.State=d1.State
WHERE d1.State IN ('Jharkhand','Bihar');

-- 1. Total Population of India
SELECT SUM(Population) AS 'Indian Population'
FROM data2;

-- 2. Average Growth Of India
SELECT AVG(Growth)*100 AS 'Average Growth' -- *100 bcz the Growth data is in decimal values
FROM data1;

-- 3. Avearge Sex Ratio Of Each State
SELECT State,ROUND(AVG(Sex_Ratio),0) AS 'Average Sex Ratio' -- ROUND to ignore the decimal point
FROM data1
GROUP BY State;

-- 4. Average Literacy Rate Of Each State
SELECT State, ROUND(AVG(Literacy),0) AS 'Average Literacy Rate'
FROM data1
GROUP BY State
ORDER BY ROUND(AVG(Literacy),0) DESC;

-- 5. Top 3 States Which have Highest Growth Ratio
SELECT State,ROUND(AVG(Growth)*100,0) AS 'Growth Ratio'
FROM data1
GROUP BY State
ORDER BY ROUND(AVG(Growth)*100,0) DESC LIMIT 3;

-- 6. Bottom 3 States with Lowest Sex Ratio
SELECT State, ROUND(AVG(Sex_Ratio),0) AS 'Sex Ratio'
FROM data1
GROUP BY State
ORDER BY ROUND(AVG(Sex_Ratio),0) ASC LIMIT 3;

-- 7. Top and Bottom 3 States in Literacy rate
	(SELECT State,ROUND(AVG(Literacy),0)
	FROM data1                                   
	GROUP BY State
	ORDER BY ROUND(AVG(Literacy),0) DESC LIMIT 3)   -- Top 3
UNION
	(SELECT State,ROUND(AVG(Literacy),0)
	FROM data1
	GROUP BY State
	ORDER BY ROUND(AVG(Literacy),0) ASC LIMIT 3);   -- Bottom 3
    
-- 8. States starting with Letter A
SELECT DISTINCT State
FROM data1
WHERE State LIKE 'A%' OR 'a%';

-- 9. Total Males and Females of Each District.
SELECT D.District,D.State,ROUND((D.Population/(D.Sex_Ratio +1)),0) AS Males,ROUND((D.Population-(D.Population/(D.Sex_Ratio+1))),0) AS Females -- --> Second
FROM (SELECT d1.District, d1.State, d1.Sex_Ratio/1000 AS Sex_Ratio,d2.Population FROM data1 d1 -- --> First
		INNER JOIN data2 d2 ON d1.District = d2.District) D;

-- 10. Total Males and Females Per Each State
SELECT	B.State,SUM(B.Males) AS 'Total_Males', SUM(B.Females) AS 'Total_Females' -- --> Third
FROM(SELECT D.District,D.State,ROUND((D.Population/(D.Sex_Ratio +1)),0) AS Males,ROUND((D.Population-(D.Population/(D.Sex_Ratio+1))),0) AS Females -- --> Second
		FROM (SELECT d1.District, d1.State, d1.Sex_Ratio/1000 AS Sex_Ratio,d2.Population -- --> First
				FROM data1 d1
				INNER JOIN data2 d2 ON d1.District = d2.District) D) B
GROUP BY B.State;

-- 11. Total Liteacy Rate Of Each State
SELECT B.State, SUM(B.Literates) AS Literates,SUM(B.Illiterates) AS Illiterates -- --> Third
FROM (SELECT A.District,A.State,ROUND(A.Literacy_Ratio*A.Population,0) AS Literates, ROUND((1-A.Literacy_Ratio)*A.Population,0) AS Illiterates -- --> Second
		FROM (SELECT D1.District,D1.State,D1.Literacy/100 AS Literacy_Ratio,D2.Population -- --> First
				FROM data1 D1
				INNER JOIN data2 D2 ON D1.District = D2.District) A) B
GROUP BY B.State;

-- 12. Population in Previous Census Of States
SELECT B.State,SUM(B.Previous_Population) AS Previous_Population,SUM(B.Current_Population) AS Current_Population -- --> Third
FROM (SELECT A.District,A.State,ROUND(A.Population/(1+A.Growth),0) AS Previous_Population,A.Population AS Current_Population -- --> Second
		FROM (SELECT D1.District,D1.State,D1.Growth*100 AS Growth,D2.Population -- -->First
				FROM data1 D1
				INNER JOIN data2 D2 ON D1.District = D2.District) A) B
GROUP BY B.State;

-- 13. Population of India in Previous Census
SELECT SUM(C.Previous_Population) AS Previous_Census,SUM(C.Current_Population) AS Current_Census -- -->? Fourth
FROM (SELECT B.State,SUM(B.Previous_Population) AS Previous_Population,SUM(B.Current_Population) AS Current_Population -- --> Third
		FROM (SELECT A.District,A.State,ROUND(A.Population/(1+A.Growth),0) AS Previous_Population,A.Population AS Current_Population -- --> Second
				FROM (SELECT D1.District,D1.State,D1.Growth*100 AS Growth,D2.Population -- --> First
						FROM data1 D1
						INNER JOIN data2 D2 ON D1.District = D2.District) A) B 
		GROUP BY B.State) C;
        
-- 14. Top 3 Districts From Each State With Highest Literacy Rate
SELECT A.* -- --> Second
FROM (SELECT State,District,Literacy,RANK() OVER(PARTITION BY State ORDER BY Literacy DESC) AS RNK -- --> First
		FROM data1) A 
WHERE RNK IN (1,2,3)
ORDER BY A.State;
