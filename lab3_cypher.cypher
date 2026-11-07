Jake Mandel 
lab3 cypher scripts

// ==========================================
// LOAD DATA SCRIPT
// ==========================================

// Step 0: Start from an empty database
MATCH (n) DETACH DELETE n;

// Step 1: Uniqueness constraints
CREATE CONSTRAINT disease_name IF NOT EXISTS FOR (d: Disease) REQUIRE d.name IS UNIQUE;
CREATE CONSTRAINT country_id IF NOT EXISTS FOR (c: Country) REQUIRE c.id IS UNIQUE;
CREATE CONSTRAINT state_id IF NOT EXISTS FOR (s: State) REQUIRE s.id IS UNIQUE;
CREATE CONSTRAINT city_id IF NOT EXISTS FOR (c: City) REQUIRE c.id IS UNIQUE;

// Step 2: Disease nodes
MERGE (d: Disease {name: 'Malaria'})
SET d.pathogen = 'Plasmodium parasite', d.vector = 'Anopheles mosquito';
MERGE (d: Disease {name: 'Dengue'})
SET d.pathogen = 'Dengue virus', d.vector = 'Aedes mosquito';
MERGE (d: Disease {name: 'Chikungunya'})
SET d.pathogen = 'Chikungunya virus', d.vector = 'Aedes mosquito';
MERGE (d: Disease {name: 'Zika'})
SET d.pathogen = 'Zika virus', d.vector = 'Aedes mosquito';

// Step 3: Country nodes
MERGE (c: Country {id: 'IN'}) SET c.name = 'India', c.admin_level = 0;
MERGE (c: Country {id: 'BR'}) SET c.name = 'Brazil', c.admin_level = 0;
MERGE (c: Country {id: 'NG'}) SET c.name = 'Nigeria', c.admin_level = 0;

// Step 4: State nodes, linked to their country
MATCH (c: Country {id: 'IN'})
MERGE (s: State {id: 'IN-TN'}) SET s.name = 'Tamil Nadu', s.admin_level = 1
MERGE (s)-[:IS_PART_OF]->(c);

MATCH (c: Country {id: 'BR'})
MERGE (s: State {id: 'BR-SP'}) SET s.name = 'São Paulo', s.admin_level = 1
MERGE (s)-[:IS_PART_OF]->(c);

MATCH (c: Country {id: 'BR'})
MERGE (s: State {id: 'BR-RJ'}) SET s.name = 'Rio de Janeiro', s.admin_level = 1
MERGE (s)-[:IS_PART_OF]->(c);

MATCH (c: Country {id: 'NG'})
MERGE (s: State {id: 'NG-LA'}) SET s.name = 'Lagos', s.admin_level = 1
MERGE (s)-[:IS_PART_OF]->(c);

// Step 5: City nodes, linked to their state
MATCH (s: State {id: 'IN-TN'})
MERGE (c: City {id: 'IN-TN-CHE'}) SET c.name = 'Chennai', c.admin_level = 2
MERGE (c)-[:IS_PART_OF]->(s);

MATCH (s: State {id: 'IN-TN'})
MERGE (c: City {id: 'IN-TN-CBE'}) SET c.name = 'Coimbatore', c.admin_level = 2
MERGE (c)-[:IS_PART_OF]->(s);

MATCH (s: State {id: 'BR-SP'})
MERGE (c: City {id: 'BR-SP-SAO'}) SET c.name = 'São Paulo', c.admin_level = 2
MERGE (c)-[:IS_PART_OF]->(s);

MATCH (s: State {id: 'BR-RJ'})
MERGE (c: City {id: 'BR-RJ-RIO'}) SET c.name = 'Rio de Janeiro', c.admin_level = 2
MERGE (c)-[:IS_PART_OF]->(s);

MATCH (s: State {id: 'NG-LA'})
MERGE (c: City {id: 'NG-LA-IKJ'}) SET c.name = 'Ikeja', c.admin_level = 2
MERGE (c)-[:IS_PART_OF]->(s);

// Step 6: Case reports
MATCH (c: City {id: 'IN-TN-CHE'}), (d: Disease {name: 'Dengue'})
MERGE (c)-[r: HAS_CASES_OF {date_reported: date('2026-09-30')}]->(d)
SET r.case_count = 500;

MATCH (c: City {id: 'IN-TN-CHE'}), (d: Disease {name: 'Malaria'})
MERGE (c)-[r: HAS_CASES_OF {date_reported: date('2026-09-30')}]->(d)
SET r.case_count = 180;

MATCH (c: City {id: 'IN-TN-CBE'}), (d: Disease {name: 'Malaria'})
MERGE (c)-[r: HAS_CASES_OF {date_reported: date('2026-09-30')}]->(d)
SET r.case_count = 250;

MATCH (c: City {id: 'BR-SP-SAO'}), (d: Disease {name: 'Chikungunya'})
MERGE (c)-[r: HAS_CASES_OF {date_reported: date('2026-09-30')}]->(d)
SET r.case_count = 120;

MATCH (c: City {id: 'BR-SP-SAO'}), (d: Disease {name: 'Dengue'})
MERGE (c)-[r: HAS_CASES_OF {date_reported: date('2026-09-30')}]->(d)
SET r.case_count = 650;

MATCH (c: City {id: 'BR-RJ-RIO'}), (d: Disease {name: 'Dengue'})
MERGE (c)-[r: HAS_CASES_OF {date_reported: date('2026-09-30')}]->(d)
SET r.case_count = 800;

MATCH (c: City {id: 'NG-LA-IKJ'}), (d: Disease {name: 'Malaria'})
MERGE (c)-[r: HAS_CASES_OF {date_reported: date('2026-09-30')}]->(d)
SET r.case_count = 1500;

MATCH (c: City {id: 'NG-LA-IKJ'}), (d: Disease {name: 'Dengue'})
MERGE (c)-[r: HAS_CASES_OF {date_reported: date('2026-09-30')}]->(d)
SET r.case_count = 90;


// ==========================================
// PART 5: GRADED ANSWERS SCRIPT
// ==========================================

// Question 1: Total cases per country
MATCH (country: Country)<-[:IS_PART_OF*1..3]-(city: City)-[r: HAS_CASES_OF]->(:Disease)
RETURN country.name AS country, sum(r.case_count) AS total_cases
ORDER BY total_cases DESC;

// Question 2: Diseases across borders
MATCH (country: Country)<-[:IS_PART_OF*1..3]-(city: City)-[r: HAS_CASES_OF]->(d: Disease)
RETURN d.name AS disease,
       count(DISTINCT country) AS num_countries,
       collect(DISTINCT country.name) AS countries,
       sum(r.case_count) AS total_cases
ORDER BY total_cases DESC;

// Question 3: The single worst outbreak
MATCH (country: Country)<-[:IS_PART_OF]-(state: State)<-[:IS_PART_OF]-(city: City)-[r: HAS_CASES_OF]->(d: Disease)
RETURN city.name AS city,
       state.name AS state,
       country.name AS country,
       d.name AS disease,
       r.case_count AS cases
ORDER BY cases DESC
LIMIT 1;

// Question 4: Dengue share (6000 level)
MATCH (country: Country)<-[:IS_PART_OF*1..3]-(city: City)-[r: HAS_CASES_OF]->(d: Disease)
WITH country,
     sum(CASE WHEN d.name = 'Dengue' THEN r.case_count ELSE 0 END) AS dengue_cases,
     sum(r.case_count) AS all_cases
RETURN country.name AS country,
       dengue_cases,
       all_cases,
       round(100.0 * dengue_cases / all_cases, 1) AS dengue_percentage
ORDER BY dengue_percentage DESC;
