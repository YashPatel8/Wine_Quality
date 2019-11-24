
DROP DATABASE IF EXISTS `final`;
CREATE DATABASE  IF NOT EXISTS `final`;
USE `final`;

--
-- PART 2
--

ALTER TABLE final.member MODIFY member_id VARCHAR(255);

ALTER TABLE final.member MODIFY member_gender_id VARCHAR(255);

ALTER TABLE final.member ADD PRIMARY KEY (member_id);

ALTER TABLE final.gender MODIFY member_gender_id VARCHAR(255);

ALTER TABLE final.gender ADD PRIMARY KEY (member_gender_id);

ALTER TABLE final.drugname MODIFY drug_ndc VARCHAR(255);

ALTER TABLE final.drugname MODIFY drug_form_code VARCHAR(255);

ALTER TABLE final.drugname MODIFY drug_brand_generic_code VARCHAR(255);

ALTER TABLE final.drugname ADD PRIMARY KEY (drug_ndc);

ALTER TABLE final.drugform MODIFY drug_form_code VARCHAR(255);

ALTER TABLE final.drugform ADD PRIMARY KEY (drug_form_code);

ALTER TABLE final.drugbrand MODIFY drug_brand_generic_code VARCHAR(255);

ALTER TABLE final.drugbrand ADD PRIMARY KEY (drug_brand_generic_code);

ALTER TABLE final.claim MODIFY member_id VARCHAR(255);

ALTER TABLE final.claim MODIFY drug_ndc VARCHAR(255);


ALTER TABLE final.member
ADD FOREIGN KEY member_member_gender_id_fk(member_gender_id)
REFERENCES final.gender(member_gender_id)
ON DELETE RESTRICT
ON UPDATE RESTRICT;

ALTER TABLE final.drugname
ADD FOREIGN KEY drugname_drug_form_code_fk(drug_form_code)
REFERENCES final.drugform(drug_form_code)
ON DELETE RESTRICT
ON UPDATE RESTRICT;

ALTER TABLE final.drugname
ADD FOREIGN KEY drugname_drug_brand_generic_code_fk(drug_brand_generic_code)
REFERENCES final.drugbrand(drug_brand_generic_code)
ON DELETE RESTRICT
ON UPDATE RESTRICT;

ALTER TABLE final.claim
ADD FOREIGN KEY claim_member_id_fk(member_id)
REFERENCES final.member(member_id)
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE final.claim
ADD FOREIGN KEY claim_drug_ndc_fk(drug_ndc)
REFERENCES final.drugname(drug_ndc)
ON DELETE RESTRICT
ON UPDATE RESTRICT;

--
-- Part 4
--

--
-- 4.1
--

SELECT d.drug_name, COUNT(a.fill_date) AS no_of_prescriptions
FROM drugname d
INNER JOIN claim a ON d.drug_ndc = a.drug_ndc
GROUP BY d.drug_name
ORDER BY d.drug_name;

--
-- 4.2
--

DROP TABLE IF EXISTS `f42`;

CREATE TABLE `f42` AS
SELECT  a.member_id, a.fill_date, a.copay, a.insurancepaid, f.member_age 
FROM claim a
INNER JOIN final.member f ON a.member_id = f.member_id;

SELECT COUNT(fill_date) AS total_prescreptions, COUNT(DISTINCT member_id) AS unique_members, SUM(copay)as total_copay, SUM(insurancepaid) as total_insurancepaid,
CASE
    WHEN member_age >= 65 THEN "age 65+"
    WHEN member_age < 65 THEN "age < 65"
END AS age 
FROM f42
group by age
order by age;

--
-- 4.3
--

DROP TABLE IF EXISTS `f43`;

CREATE TABLE `f43` AS
SELECT  f.member_id, f.member_first_name, f.member_last_name, d.drug_name, a.fill_date, a.insurancepaid
FROM final.member f
INNER JOIN claim a ON a.member_id = f.member_id
INNER JOIN drugname d ON d.drug_ndc = a.drug_ndc;

SELECT z.member_id, z.member_first_name, z.member_last_name, z.drug_name, z.mr_filldate, z.mr_insurancepaid
FROM (SELECT DISTINCT 	member_id,
						member_first_name,
                        member_last_name,
                        drug_name,
                        fill_date AS mr_filldate,
                        insurancepaid AS mr_insurancepaid,
                        ROW_NUMBER() OVER (PARTITION BY member_id  ORDER BY member_id, fill_date DESC) AS FLAG 
		FROM f43) AS z
WHERE FLAG = 1; 

--
--
--
