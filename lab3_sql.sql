-- Jake Mandel
-- lab3 sql scripts

-- 1. Schema Definitions

CREATE TABLE Region (
    region_id VARCHAR(20) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    admin_level INT NOT NULL, 
    parent_id VARCHAR(20) REFERENCES Region(region_id)
);

CREATE TABLE Disease (
    disease_id VARCHAR(20) PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    pathogen VARCHAR(100),
    vector VARCHAR(100)
);

CREATE TABLE CaseReport (
    report_id SERIAL PRIMARY KEY,
    region_id VARCHAR(20) NOT NULL REFERENCES Region(region_id),
    disease_id VARCHAR(20) NOT NULL REFERENCES Disease(disease_id),
    case_count INT NOT NULL,
    date_reported DATE NOT NULL
);

-- 2. Recursive Query: Total cases per country

WITH RECURSIVE RegionHierarchy AS (
    SELECT 
        cr.case_count,
        r.region_id AS current_region_id,
        r.parent_id,
        r.admin_level,
        r.name AS current_name
    FROM CaseReport cr
    JOIN Region r ON cr.region_id = r.region_id

    UNION ALL

    SELECT 
        rh.case_count,
        parent.region_id AS current_region_id,
        parent.parent_id,
        parent.admin_level,
        parent.name AS current_name
    FROM RegionHierarchy rh
    JOIN Region parent ON rh.parent_id = parent.region_id
)
SELECT 
    current_name AS country,
    SUM(case_count) AS total_cases
FROM RegionHierarchy
WHERE admin_level = 0
GROUP BY current_region_id, current_name
ORDER BY total_cases DESC;
