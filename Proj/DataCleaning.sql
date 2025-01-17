-- Data Cleaning

SELECT * 
FROM layoffs;


-- remove duplicates

CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT * FROM layoffs_staging;

SELECT * 
FROM layoffs;

INSERT layoffs_staging
SELECT * 
FROM layoffs;

SELECT * ,
ROW_NUMBER() OVER(
PARTITION BY company,industry,total_laid_off,percentage_laid_off,'date') AS row_num
FROM layoffs_staging;

WITH duplicate_cte AS
(
SELECT * ,
ROW_NUMBER() OVER(
PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,'date',stage,country,funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num>1;

SELECT * 
FROM layoffs_staging
WHERE company='Casper';


CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT * FROM layoffs_staging2;

INSERT INTO layoffs_staging2
SELECT * ,
ROW_NUMBER() OVER(
PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,'date',stage,country,funds_raised_millions) AS row_num
FROM layoffs_staging;

SELECT * FROM layoffs_staging2 WHERE row_num>1;
SET SQL_SAFE_UPDATES = 0;


DELETE 
FROM layoffs_staging2
WHERE row_num>1;

SELECT * FROM layoffs_staging2 WHERE row_num>1;
SELECT * FROM layoffs_staging2 ;

SELECT * FROM layoffs_staging;

SELECT * ,
ROW_NUMBER() OVER(
PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,'date',stage,country,funds_raised_millions) AS row_num
FROM layoffs_staging ;

SELECT * FROM layoffs_staging2 WHERE company='Olist';

-- Standardizing data
SELECT company,TRIM(company)
FROM  layoffs_staging2;

UPDATE layoffs_staging2
SET company=trim(company);

SELECT DISTINCT industry
FROM layoffs_staging2
order by 1;

SELECT * FROM
layoffs_staging2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging2
SET industry='Crypto'
WHERE industry LIKE 'Crypto%';

SELECT DISTINCT location
FROM layoffs_staging2
ORDER BY 1;

SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;

SELECT DISTINCT country
FROM layoffs_staging2
WHERE country LIKE 'United States%'
Order By 1;

UPDATE layoffs_staging2
SET country='United States'
WHERE country LIKE 'United States%';

SELECT `date`,
STR_TO_DATE(`date`,'%m/%d/%Y')As set_date
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date`=STR_TO_DATE(`date`,'%m/%d/%Y');

SELECT `date`
FROM layoffs_staging2;

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

SELECT *
FROM layoffs_staging2;

SELECT * FROM layoffs_staging2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

SELECT * FROM layoffs_staging2
WHERE industry IS NULL OR industry='';

SELECT * FROM layoffs_staging2
WHERE company='Airbnb';

SELECT t1.industry,t2.industry 
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
ON t1.company=t2.company
WHERE (t1.industry IS NULL OR t1.industry='')
AND t2.industry IS NOT NULL;


UPDATE layoffs_staging2
SET industry=NULL
WHERE industry ='';

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
ON t1.company=t2.company
SET t1.industry=t2.industry
WHERE (t1.industry IS NULL OR t1.industry='')
AND t2.industry IS NOT NULL ;


SELECT * FROM
layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE FROM
layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT * FROM layoffs_staging2;
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;


-- exploratory data analysing

SELECT * FROM layoffs_staging2;

SELECT MAX(total_laid_off),MAX(percentage_laid_off)
FROM layoffs_staging2;

SELECT * FROM layoffs_staging2 WHERE percentage_laid_off=1 ORDER BY total_laid_off DESC;

SELECT company,SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

SELECT MIN(`date`),MAX(`date`)
FROM layoffs_staging2;

SELECT industry,SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
Order By 2 DESC;

SELECT `date`,SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY `date`
Order By 2 DESC;

SELECT YEAR(`date`),SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
Order By 2 DESC;

SELECT stage,SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
Order By 2 DESC;

SELECT COUNT(*) AS row_count FROM layoffs_staging2;
SELECT * FROM layoffs_staging2;

SELECT company,SUM(percentage_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

SELECT SUBSTRING(`date`,6,2) AS `month`,SUM(total_laid_off)AS monthly_laid_off
FROM layoffs_staging2
GROUP BY SUBSTRING(`date`,6,2)
Order By 1 ;


-- special*******************************************************
WITH Rolling_total AS(
SELECT SUBSTRING(`date`,1,7) AS `month`,SUM(total_laid_off)AS monthly_laid_off
FROM layoffs_staging2
GROUP BY SUBSTRING(`date`,1,7)
Order By 1 
)
SELECT `month`,monthly_laid_off,SUM(monthly_laid_off) OVER(ORDER BY(`month`))AS rolling_total
FROM Rolling_total WHERE `month` IS NOT NULL;

SELECT company,YEAR(`date`),SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY  company,YEAR(`date`)
ORDER BY 3 DESC;

WITH Company_Year(company,years,total_laid_off) As
(
SELECT company,YEAR(`date`),SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY  company,YEAR(`date`)
)
SELECT* ,DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
FROM Company_Year
WHERE years IS NOT NULL;

WITH Company_Year(company,years,total_laid_off) As
(
SELECT company,YEAR(`date`),SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY  company,YEAR(`date`)
), Company_year_rank AS
(SELECT* ,DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
FROM Company_Year
WHERE years IS NOT NULL)
SELECT * FROM Company_year_rank ;