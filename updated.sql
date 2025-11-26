-- row_num 8557558
-- 1. claim based rate
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = '8245440'
    AND NETWORK_ID = '00248'
    AND PLACE_OF_SERVICE_CD = '11'
    AND SERVICE_CD = '90837'
    AND SERVICE_TYPE_CD = 'CPT4';
-- 2. provider info when SPECIALTY_CD
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR, PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = '8245440'
    AND NETWORK_ID = '00248'
    AND SERVICE_LOCATION_NBR = '4575795'
    AND (
        SPECIALTY_CD = '' 
        OR (
            SPECIALTY_CD IS NULL 
            AND NOT EXISTS (
                SELECT 1
                FROM CET_PROVIDERS 
                WHERE 
                    PROVIDER_IDENTIFICATION_NBR = '8245440' 
                    AND NETWORK_ID = '00248' 
                    AND SERVICE_LOCATION_NBR = '4575795' 
                    AND SPECIALTY_CD = ''
            )
        )
    );
-- 3. provider info when PROVIDER_TYPE_CD
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = '8245440'
    AND NETWORK_ID = '00248'
    AND SERVICE_LOCATION_NBR = '4575795'
    AND PROVIDER_TYPE_CD = 'LPC';
-- 4. provider info when no specialty or provider type
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = '8245440'
    AND NETWORK_ID = '00248'
    AND SERVICE_LOCATION_NBR = '4575795';
-- 5. Standard rate
SELECT Max(RATE) AS RATE
FROM CET_RATES
WHERE
    RATE_SYSTEM_CD = ""
    AND SERVICE_CD = '90837'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND GEOGRAPHIC_AREA_CD = ""
    AND PLACE_OF_SERVICE_CD = '11'
    AND (PRODUCT_CD = "" OR PRODUCT_CD = 'ALL');
-- 6. Non-standard rate when SPECIALTY_CD
WITH base AS (
  SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    specialty_cd,
    rate
  FROM CET_RATES
  WHERE
    SERVICE_CD = '90837'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND PLACE_OF_SERVICE_CD = '11'
    AND PRODUCT_CD IN ("", 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST([])
    AND CONTRACT_TYPE IN ('C', 'N')
),
flag AS (
  SELECT EXISTS (SELECT 1 FROM base WHERE specialty_cd = '') AS has_providerspecialtycode
)
SELECT
  b.payment_method_cd,
  b.service_group_changed_ind,
  b.service_grouping_priority_nbr,
  MAX(b.rate) AS rate
FROM base b
CROSS JOIN flag f
WHERE b.specialty_cd = CASE WHEN f.has_providerspecialtycode THEN '' ELSE '' END
GROUP BY
  b.payment_method_cd,
  b.service_group_changed_ind,
  b.service_grouping_priority_nbr;
-- 7. Non-standard rate when PROVIDER_TYPE_CD
WITH base AS (
  SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    specialty_cd,
    rate
  FROM CET_RATES
  WHERE
    SERVICE_CD = '90837'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND PLACE_OF_SERVICE_CD = '11'
    AND PRODUCT_CD IN ("", 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST([])
    AND CONTRACT_TYPE IN ('C', 'N')
),
flag AS (
  SELECT EXISTS (SELECT 1 FROM base WHERE specialty_cd = 'LPC') AS has_providertype
)
SELECT
  b.payment_method_cd,
  b.service_group_changed_ind,
  b.service_grouping_priority_nbr,
  MAX(b.rate) AS rate
FROM base b
CROSS JOIN flag f 
WHERE b.specialty_cd = CASE WHEN f.has_providertype THEN 'LPC' ELSE '' END
GROUP BY
  b.payment_method_cd,
  b.service_group_changed_ind,
  b.service_grouping_priority_nbr;
-- 8. Non standard rate when no specialty or provider type
SELECT
  payment_method_cd,
  service_group_changed_ind,
  service_grouping_priority_nbr,
  max(rate) AS rate
FROM CET_RATES
WHERE
  SERVICE_CD = '90837'
  AND SERVICE_TYPE_CD = 'CPT4'
  AND PLACE_OF_SERVICE_CD = '11'
  AND (PRODUCT_CD = "" OR PRODUCT_CD = 'ALL')
  AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST([])
  AND CONTRACT_TYPE IN ('C', 'N')
GROUP BY payment_method_cd, service_group_changed_ind, service_grouping_priority_nbr;
-- 9. Default rate when SPECIALTY_CD
WITH base AS (
  SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    specialty_cd,
    rate
  FROM CET_RATES
  WHERE
    SERVICE_CD = '90837'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND PLACE_OF_SERVICE_CD = '11'
    AND PRODUCT_CD IN ("", 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST([])
    AND CONTRACT_TYPE = 'D'
),
flag AS (
  SELECT EXISTS (SELECT 1 FROM base WHERE specialty_cd = '') AS has_providerspecialtycode
)
SELECT
  b.payment_method_cd,
  b.service_group_changed_ind,
  b.service_grouping_priority_nbr,
  MAX(b.rate) AS rate
FROM base b
CROSS JOIN flag f
WHERE b.specialty_cd = CASE WHEN f.has_providerspecialtycode THEN '' ELSE '' END
GROUP BY
  b.payment_method_cd,
  b.service_group_changed_ind,
  b.service_grouping_priority_nbr;
-- 10. Default rate when PROVIDER_TYPE_CD
WITH base AS (
  SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    specialty_cd,
    rate
  FROM CET_RATES
  WHERE
    SERVICE_CD = '90837'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND PLACE_OF_SERVICE_CD = '11'
    AND PRODUCT_CD IN ("", 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST([])
    AND CONTRACT_TYPE = 'D'
),
flag AS (
  SELECT EXISTS (SELECT 1 FROM base WHERE specialty_cd = 'LPC') AS has_providertype
)
SELECT
  b.payment_method_cd,
  b.service_group_changed_ind,
  b.service_grouping_priority_nbr,
  MAX(b.rate) AS rate
FROM base b
CROSS JOIN flag f
WHERE b.specialty_cd = CASE WHEN f.has_providertype THEN 'LPC' ELSE '' END
GROUP BY
  b.payment_method_cd,
  b.service_group_changed_ind,
  b.service_grouping_priority_nbr;
-- 11. Default rate when no specialty or provider type
SELECT
  payment_method_cd,
  service_group_changed_ind,
  service_grouping_priority_nbr,
  max(rate) AS rate
FROM CET_RATES
WHERE
  SERVICE_CD = '90837'
  AND SERVICE_TYPE_CD = 'CPT4'
  AND PLACE_OF_SERVICE_CD = '11'
  AND (PRODUCT_CD = "" OR PRODUCT_CD = 'ALL')
  AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST([])
  AND CONTRACT_TYPE = 'D' 
GROUP BY payment_method_cd, service_group_changed_ind, service_grouping_priority_nbr;

-- row_num 6015239
-- 1. claim based rate
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = '4308728'
    AND NETWORK_ID = '02825'
    AND PLACE_OF_SERVICE_CD = '11'
    AND SERVICE_CD = '90837'
    AND SERVICE_TYPE_CD = 'CPT4';
-- 2. provider info when SPECIALTY_CD
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR, PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = 4308728
    AND NETWORK_ID = '02825'
    AND SERVICE_LOCATION_NBR = 3246162
    AND (
        SPECIALTY_CD = '' 
        OR (
            SPECIALTY_CD IS NULL 
            AND NOT EXISTS (
                SELECT 1
                FROM CET_PROVIDERS 
                WHERE 
                    PROVIDER_IDENTIFICATION_NBR = '4308728' 
                    AND NETWORK_ID = '02825' 
                    AND SERVICE_LOCATION_NBR = '3246162' 
                    AND SPECIALTY_CD = ''
            )
        )
    );
-- 3. provider info when PROVIDER_TYPE_CD
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = '4308728'
    AND NETWORK_ID = '02825'
    AND SERVICE_LOCATION_NBR = '3246162'
    AND PROVIDER_TYPE_CD = 'SW';
-- 4. provider info when no specialty or provider type
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = '4308728'
    AND NETWORK_ID = '02825'
    AND SERVICE_LOCATION_NBR = '3246162';
-- 5. Standard rate
SELECT Max(RATE) AS RATE
FROM CET_RATES
WHERE
    RATE_SYSTEM_CD = ""
    AND SERVICE_CD = '90837'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND GEOGRAPHIC_AREA_CD = ""
    AND PLACE_OF_SERVICE_CD = '11'
    AND (PRODUCT_CD = "" OR PRODUCT_CD = 'ALL');
-- 6. Non-standard rate when SPECIALTY_CD
WITH base AS (
  SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    specialty_cd,
    rate
  FROM CET_RATES
  WHERE
    SERVICE_CD = '90837'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND PLACE_OF_SERVICE_CD = '11'
    AND PRODUCT_CD IN ("", 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST([])
    AND CONTRACT_TYPE IN ('C', 'N')
),
flag AS (
  SELECT EXISTS (SELECT 1 FROM base WHERE specialty_cd = '') AS has_providerspecialtycode
)
SELECT
  b.payment_method_cd,
  b.service_group_changed_ind,
  b.service_grouping_priority_nbr,
  MAX(b.rate) AS rate
FROM base b
CROSS JOIN flag f
WHERE b.specialty_cd = CASE WHEN f.has_providerspecialtycode THEN '' ELSE '' END
GROUP BY
  b.payment_method_cd,
  b.service_group_changed_ind,
  b.service_grouping_priority_nbr;
-- 7. Non-standard rate when PROVIDER_TYPE_CD
WITH base AS (
  SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    specialty_cd,
    rate
  FROM CET_RATES
  WHERE
    SERVICE_CD = '90837'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND PLACE_OF_SERVICE_CD = '11'
    AND PRODUCT_CD IN ("", 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST([])
    AND CONTRACT_TYPE IN ('C', 'N')
),
flag AS (
  SELECT EXISTS (SELECT 1 FROM base WHERE specialty_cd = 'SW') AS has_providertype
)
SELECT
  b.payment_method_cd,
  b.service_group_changed_ind,
  b.service_grouping_priority_nbr,
  MAX(b.rate) AS rate
FROM base b
CROSS JOIN flag f 
WHERE b.specialty_cd = CASE WHEN f.has_providertype THEN 'SW' ELSE '' END
GROUP BY
  b.payment_method_cd,
  b.service_group_changed_ind,
  b.service_grouping_priority_nbr;
-- 8. Non standard rate when no specialty or provider type
SELECT
  payment_method_cd,
  service_group_changed_ind,
  service_grouping_priority_nbr,
  max(rate) AS rate
FROM CET_RATES
WHERE
  SERVICE_CD = '90837'
  AND SERVICE_TYPE_CD = 'CPT4'
  AND PLACE_OF_SERVICE_CD = '11'
  AND (PRODUCT_CD = "" OR PRODUCT_CD = 'ALL')
  AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST([])
  AND CONTRACT_TYPE IN ('C', 'N')
GROUP BY payment_method_cd, service_group_changed_ind, service_grouping_priority_nbr;
-- 9. Default rate when SPECIALTY_CD
WITH base AS (
  SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    specialty_cd,
    rate
  FROM CET_RATES
  WHERE
    SERVICE_CD = '90837'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND PLACE_OF_SERVICE_CD = '11'
    AND PRODUCT_CD IN ("", 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST([])
    AND CONTRACT_TYPE = 'D'
),
flag AS (
  SELECT EXISTS (SELECT 1 FROM base WHERE specialty_cd = '') AS has_providerspecialtycode
)
SELECT
  b.payment_method_cd,
  b.service_group_changed_ind,
  b.service_grouping_priority_nbr,
  MAX(b.rate) AS rate
FROM base b
CROSS JOIN flag f
WHERE b.specialty_cd = CASE WHEN f.has_providerspecialtycode THEN '' ELSE '' END
GROUP BY
  b.payment_method_cd,
  b.service_group_changed_ind,
  b.service_grouping_priority_nbr;
-- 10. Default rate when PROVIDER_TYPE_CD
WITH base AS (
  SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    specialty_cd,
    rate
  FROM CET_RATES
  WHERE
    SERVICE_CD = '90837'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND PLACE_OF_SERVICE_CD = '11'
    AND PRODUCT_CD IN ("", 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST([])
    AND CONTRACT_TYPE = 'D'
),
flag AS (
  SELECT EXISTS (SELECT 1 FROM base WHERE specialty_cd = 'SW') AS has_providertype
)
SELECT
  b.payment_method_cd,
  b.service_group_changed_ind,
  b.service_grouping_priority_nbr,
  MAX(b.rate) AS rate
FROM base b
CROSS JOIN flag f
WHERE b.specialty_cd = CASE WHEN f.has_providertype THEN 'SW' ELSE '' END
GROUP BY
  b.payment_method_cd,
  b.service_group_changed_ind,
  b.service_grouping_priority_nbr;
-- 11. Default rate when no specialty or provider type
SELECT
  payment_method_cd,
  service_group_changed_ind,
  service_grouping_priority_nbr,
  max(rate) AS rate
FROM CET_RATES
WHERE
  SERVICE_CD = '90837'
  AND SERVICE_TYPE_CD = 'CPT4'
  AND PLACE_OF_SERVICE_CD = '11'
  AND (PRODUCT_CD = "" OR PRODUCT_CD = 'ALL')
  AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST([])
  AND CONTRACT_TYPE = 'D' 
GROUP BY payment_method_cd, service_group_changed_ind, service_grouping_priority_nbr;

-- row_num 326015
-- 1. claim based rate
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = '6490398'
    AND NETWORK_ID = '02321'
    AND PLACE_OF_SERVICE_CD = '11'
    AND SERVICE_CD = '90837'
    AND SERVICE_TYPE_CD = 'CPT4';
-- 2. provider info when SPECIALTY_CD
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR, PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = '6490398'
    AND NETWORK_ID = '02321'
    AND SERVICE_LOCATION_NBR = '2365709'
    AND (
        SPECIALTY_CD = '' 
        OR (
            SPECIALTY_CD IS NULL 
            AND NOT EXISTS (
                SELECT 1
                FROM CET_PROVIDERS 
                WHERE 
                    PROVIDER_IDENTIFICATION_NBR = '6490398' 
                    AND NETWORK_ID = '02321' 
                    AND SERVICE_LOCATION_NBR = '2365709' 
                    AND SPECIALTY_CD = ''
            )
        )
    );
-- 3. provider info when PROVIDER_TYPE_CD
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = '6490398'
    AND NETWORK_ID = '02321'
    AND SERVICE_LOCATION_NBR = '2365709'
    AND PROVIDER_TYPE_CD = 'LPC';
-- 4. provider info when no specialty or provider type
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = '6490398'
    AND NETWORK_ID = '02321'
    AND SERVICE_LOCATION_NBR = '2365709';
-- 5. Standard rate
SELECT Max(RATE) AS RATE
FROM CET_RATES
WHERE
    RATE_SYSTEM_CD = ""
    AND SERVICE_CD = '90837'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND GEOGRAPHIC_AREA_CD = ""
    AND PLACE_OF_SERVICE_CD = '11'
    AND (PRODUCT_CD = "" OR PRODUCT_CD = 'ALL');
-- 6. Non-standard rate when SPECIALTY_CD
WITH base AS (
  SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    specialty_cd,
    rate
  FROM CET_RATES
  WHERE
    SERVICE_CD = '90837'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND PLACE_OF_SERVICE_CD = '11'
    AND PRODUCT_CD IN ("", 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST([])
    AND CONTRACT_TYPE IN ('C', 'N')
),
flag AS (
  SELECT EXISTS (SELECT 1 FROM base WHERE specialty_cd = '') AS has_providerspecialtycode
)
SELECT
  b.payment_method_cd,
  b.service_group_changed_ind,
  b.service_grouping_priority_nbr,
  MAX(b.rate) AS rate
FROM base b
CROSS JOIN flag f
WHERE b.specialty_cd = CASE WHEN f.has_providerspecialtycode THEN '' ELSE '' END
GROUP BY
  b.payment_method_cd,
  b.service_group_changed_ind,
  b.service_grouping_priority_nbr;
-- 7. Non-standard rate when PROVIDER_TYPE_CD
WITH base AS (
  SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    specialty_cd,
    rate
  FROM CET_RATES
  WHERE
    SERVICE_CD = '90837'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND PLACE_OF_SERVICE_CD = '11'
    AND PRODUCT_CD IN ("", 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST([])
    AND CONTRACT_TYPE IN ('C', 'N')
),
flag AS (
  SELECT EXISTS (SELECT 1 FROM base WHERE specialty_cd = 'LPC') AS has_providertype
)
SELECT
  b.payment_method_cd,
  b.service_group_changed_ind,
  b.service_grouping_priority_nbr,
  MAX(b.rate) AS rate
FROM base b
CROSS JOIN flag f 
WHERE b.specialty_cd = CASE WHEN f.has_providertype THEN 'LPC' ELSE '' END
GROUP BY
  b.payment_method_cd,
  b.service_group_changed_ind,
  b.service_grouping_priority_nbr;
-- 8. Non standard rate when no specialty or provider type
SELECT
  payment_method_cd,
  service_group_changed_ind,
  service_grouping_priority_nbr,
  max(rate) AS rate
FROM CET_RATES
WHERE
  SERVICE_CD = '90837'
  AND SERVICE_TYPE_CD = 'CPT4'
  AND PLACE_OF_SERVICE_CD = '11'
  AND (PRODUCT_CD = "" OR PRODUCT_CD = 'ALL')
  AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST([])
  AND CONTRACT_TYPE IN ('C', 'N')
GROUP BY payment_method_cd, service_group_changed_ind, service_grouping_priority_nbr;
-- 9. Default rate when SPECIALTY_CD
WITH base AS (
  SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    specialty_cd,
    rate
  FROM CET_RATES
  WHERE
    SERVICE_CD = '90837'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND PLACE_OF_SERVICE_CD = '11'
    AND PRODUCT_CD IN ("", 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST([])
    AND CONTRACT_TYPE = 'D'
),
flag AS (
  SELECT EXISTS (SELECT 1 FROM base WHERE specialty_cd = '') AS has_providerspecialtycode
)
SELECT
  b.payment_method_cd,
  b.service_group_changed_ind,
  b.service_grouping_priority_nbr,
  MAX(b.rate) AS rate
FROM base b
CROSS JOIN flag f
WHERE b.specialty_cd = CASE WHEN f.has_providerspecialtycode THEN '' ELSE '' END
GROUP BY
  b.payment_method_cd,
  b.service_group_changed_ind,
  b.service_grouping_priority_nbr;
-- 10. Default rate when PROVIDER_TYPE_CD
WITH base AS (
  SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    specialty_cd,
    rate
  FROM CET_RATES
  WHERE
    SERVICE_CD = '90837'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND PLACE_OF_SERVICE_CD = '11'
    AND PRODUCT_CD IN ("", 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST([])
    AND CONTRACT_TYPE = 'D'
),
flag AS (
  SELECT EXISTS (SELECT 1 FROM base WHERE specialty_cd = 'LPC') AS has_providertype
)
SELECT
  b.payment_method_cd,
  b.service_group_changed_ind,
  b.service_grouping_priority_nbr,
  MAX(b.rate) AS rate
FROM base b
CROSS JOIN flag f
WHERE b.specialty_cd = CASE WHEN f.has_providertype THEN 'LPC' ELSE '' END
GROUP BY
  b.payment_method_cd,
  b.service_group_changed_ind,
  b.service_grouping_priority_nbr;
-- 11. Default rate when no specialty or provider type
SELECT
  payment_method_cd,
  service_group_changed_ind,
  service_grouping_priority_nbr,
  max(rate) AS rate
FROM CET_RATES
WHERE
  SERVICE_CD = '90837'
  AND SERVICE_TYPE_CD = 'CPT4'
  AND PLACE_OF_SERVICE_CD = '11'
  AND (PRODUCT_CD = "" OR PRODUCT_CD = 'ALL')
  AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST([])
  AND CONTRACT_TYPE = 'D' 
GROUP BY payment_method_cd, service_group_changed_ind, service_grouping_priority_nbr;

-- row_num 3459247
-- 1. claim based rate
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = '8356378'
    AND NETWORK_ID = '02159'
    AND PLACE_OF_SERVICE_CD = '11'
    AND SERVICE_CD = '90837'
    AND SERVICE_TYPE_CD = 'CPT4';
-- 2. provider info when SPECIALTY_CD
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR, PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = '8356378'
    AND NETWORK_ID = '02159'
    AND SERVICE_LOCATION_NBR = '6497183'
    AND (
        SPECIALTY_CD = '' 
        OR (
            SPECIALTY_CD IS NULL 
            AND NOT EXISTS (
                SELECT 1
                FROM CET_PROVIDERS 
                WHERE 
                    PROVIDER_IDENTIFICATION_NBR = '8356378' 
                    AND NETWORK_ID = '02159' 
                    AND SERVICE_LOCATION_NBR = '6497183' 
                    AND SPECIALTY_CD = ''
            )
        )
    );
-- 3. provider info when PROVIDER_TYPE_CD
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = '8356378'
    AND NETWORK_ID = '02159'
    AND SERVICE_LOCATION_NBR = '6497183'
    AND PROVIDER_TYPE_CD = 'SW';
-- 4. provider info when no specialty or provider type
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = '8356378'
    AND NETWORK_ID = '02159'
    AND SERVICE_LOCATION_NBR = '6497183';
-- 5. Standard rate
SELECT Max(RATE) AS RATE
FROM CET_RATES
WHERE
    RATE_SYSTEM_CD = ""
    AND SERVICE_CD = '90837'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND GEOGRAPHIC_AREA_CD = ""
    AND PLACE_OF_SERVICE_CD = '11'
    AND (PRODUCT_CD = "" OR PRODUCT_CD = 'ALL');
-- 6. Non-standard rate when SPECIALTY_CD
WITH base AS (
  SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    specialty_cd,
    rate
  FROM CET_RATES
  WHERE
    SERVICE_CD = '90837'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND PLACE_OF_SERVICE_CD = '11'
    AND PRODUCT_CD IN ("", 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST([])
    AND CONTRACT_TYPE IN ('C', 'N')
),
flag AS (
  SELECT EXISTS (SELECT 1 FROM base WHERE specialty_cd = '') AS has_providerspecialtycode
)
SELECT
  b.payment_method_cd,
  b.service_group_changed_ind,
  b.service_grouping_priority_nbr,
  MAX(b.rate) AS rate
FROM base b
CROSS JOIN flag f
WHERE b.specialty_cd = CASE WHEN f.has_providerspecialtycode THEN '' ELSE '' END
GROUP BY
  b.payment_method_cd,
  b.service_group_changed_ind,
  b.service_grouping_priority_nbr;
-- 7. Non-standard rate when PROVIDER_TYPE_CD
WITH base AS (
  SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    specialty_cd,
    rate
  FROM CET_RATES
  WHERE
    SERVICE_CD = '90837'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND PLACE_OF_SERVICE_CD = '11'
    AND PRODUCT_CD IN ("", 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST([])
    AND CONTRACT_TYPE IN ('C', 'N')
),
flag AS (
  SELECT EXISTS (SELECT 1 FROM base WHERE specialty_cd = 'SW') AS has_providertype
)
SELECT
  b.payment_method_cd,
  b.service_group_changed_ind,
  b.service_grouping_priority_nbr,
  MAX(b.rate) AS rate
FROM base b
CROSS JOIN flag f 
WHERE b.specialty_cd = CASE WHEN f.has_providertype THEN 'SW' ELSE '' END
GROUP BY
  b.payment_method_cd,
  b.service_group_changed_ind,
  b.service_grouping_priority_nbr;
-- 8. Non standard rate when no specialty or provider type
SELECT
  payment_method_cd,
  service_group_changed_ind,
  service_grouping_priority_nbr,
  max(rate) AS rate
FROM CET_RATES
WHERE
  SERVICE_CD = '90837'
  AND SERVICE_TYPE_CD = 'CPT4'
  AND PLACE_OF_SERVICE_CD = '11'
  AND (PRODUCT_CD = "" OR PRODUCT_CD = 'ALL')
  AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST([])
  AND CONTRACT_TYPE IN ('C', 'N')
GROUP BY payment_method_cd, service_group_changed_ind, service_grouping_priority_nbr;
-- 9. Default rate when SPECIALTY_CD
WITH base AS (
  SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    specialty_cd,
    rate
  FROM CET_RATES
  WHERE
    SERVICE_CD = '90837'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND PLACE_OF_SERVICE_CD = '11'
    AND PRODUCT_CD IN ("", 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST([])
    AND CONTRACT_TYPE = 'D'
),
flag AS (
  SELECT EXISTS (SELECT 1 FROM base WHERE specialty_cd = '') AS has_providerspecialtycode
)
SELECT
  b.payment_method_cd,
  b.service_group_changed_ind,
  b.service_grouping_priority_nbr,
  MAX(b.rate) AS rate
FROM base b
CROSS JOIN flag f
WHERE b.specialty_cd = CASE WHEN f.has_providerspecialtycode THEN '' ELSE '' END
GROUP BY
  b.payment_method_cd,
  b.service_group_changed_ind,
  b.service_grouping_priority_nbr;
-- 10. Default rate when PROVIDER_TYPE_CD
WITH base AS (
  SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    specialty_cd,
    rate
  FROM CET_RATES
  WHERE
    SERVICE_CD = '90837'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND PLACE_OF_SERVICE_CD = '11'
    AND PRODUCT_CD IN ("", 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST([])
    AND CONTRACT_TYPE = 'D'
),
flag AS (
  SELECT EXISTS (SELECT 1 FROM base WHERE specialty_cd = 'SW') AS has_providertype
)
SELECT
  b.payment_method_cd,
  b.service_group_changed_ind,
  b.service_grouping_priority_nbr,
  MAX(b.rate) AS rate
FROM base b
CROSS JOIN flag f
WHERE b.specialty_cd = CASE WHEN f.has_providertype THEN 'SW' ELSE '' END
GROUP BY
  b.payment_method_cd,
  b.service_group_changed_ind,
  b.service_grouping_priority_nbr;
-- 11. Default rate when no specialty or provider type
SELECT
  payment_method_cd,
  service_group_changed_ind,
  service_grouping_priority_nbr,
  max(rate) AS rate
FROM CET_RATES
WHERE
  SERVICE_CD = '90837'
  AND SERVICE_TYPE_CD = 'CPT4'
  AND PLACE_OF_SERVICE_CD = '11'
  AND (PRODUCT_CD = "" OR PRODUCT_CD = 'ALL')
  AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST([])
  AND CONTRACT_TYPE = 'D' 
GROUP BY payment_method_cd, service_group_changed_ind, service_grouping_priority_nbr;

-- row_num 9106650
-- 1. claim based rate
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = '9120425'
    AND NETWORK_ID = '07864'
    AND PLACE_OF_SERVICE_CD = '11'
    AND SERVICE_CD = '90837'
    AND SERVICE_TYPE_CD = 'CPT4';
-- 2. provider info when SPECIALTY_CD
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR, PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = '9120425'
    AND NETWORK_ID = '07864'
    AND SERVICE_LOCATION_NBR = '7397373'
    AND (
        SPECIALTY_CD = '' 
        OR (
            SPECIALTY_CD IS NULL 
            AND NOT EXISTS (
                SELECT 1
                FROM CET_PROVIDERS 
                WHERE 
                    PROVIDER_IDENTIFICATION_NBR = '9120425' 
                    AND NETWORK_ID = '07864' 
                    AND SERVICE_LOCATION_NBR = '7397373' 
                    AND SPECIALTY_CD = ''
            )
        )
    );
-- 3. provider info when PROVIDER_TYPE_CD
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = '9120425'
    AND NETWORK_ID = '07864'
    AND SERVICE_LOCATION_NBR = '7397373'
    AND PROVIDER_TYPE_CD = 'MT';
-- 4. provider info when no specialty or provider type
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = '9120425'
    AND NETWORK_ID = '07864'
    AND SERVICE_LOCATION_NBR = '7397373';
-- 5. Standard rate
SELECT Max(RATE) AS RATE
FROM CET_RATES
WHERE
    RATE_SYSTEM_CD = ""
    AND SERVICE_CD = '90837'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND GEOGRAPHIC_AREA_CD = ""
    AND PLACE_OF_SERVICE_CD = '11'
    AND (PRODUCT_CD = "" OR PRODUCT_CD = 'ALL');
-- 6. Non-standard rate when SPECIALTY_CD
WITH base AS (
  SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    specialty_cd,
    rate
  FROM CET_RATES
  WHERE
    SERVICE_CD = '90837'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND PLACE_OF_SERVICE_CD = '11'
    AND PRODUCT_CD IN ("", 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST([])
    AND CONTRACT_TYPE IN ('C', 'N')
),
flag AS (
  SELECT EXISTS (SELECT 1 FROM base WHERE specialty_cd = '') AS has_providerspecialtycode
)
SELECT
  b.payment_method_cd,
  b.service_group_changed_ind,
  b.service_grouping_priority_nbr,
  MAX(b.rate) AS rate
FROM base b
CROSS JOIN flag f
WHERE b.specialty_cd = CASE WHEN f.has_providerspecialtycode THEN '' ELSE '' END
GROUP BY
  b.payment_method_cd,
  b.service_group_changed_ind,
  b.service_grouping_priority_nbr;
-- 7. Non-standard rate when PROVIDER_TYPE_CD
WITH base AS (
  SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    specialty_cd,
    rate
  FROM CET_RATES
  WHERE
    SERVICE_CD = '90837'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND PLACE_OF_SERVICE_CD = '11'
    AND PRODUCT_CD IN ("", 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST([])
    AND CONTRACT_TYPE IN ('C', 'N')
),
flag AS (
  SELECT EXISTS (SELECT 1 FROM base WHERE specialty_cd = 'MT') AS has_providertype
)
SELECT
  b.payment_method_cd,
  b.service_group_changed_ind,
  b.service_grouping_priority_nbr,
  MAX(b.rate) AS rate
FROM base b
CROSS JOIN flag f 
WHERE b.specialty_cd = CASE WHEN f.has_providertype THEN 'MT' ELSE '' END
GROUP BY
  b.payment_method_cd,
  b.service_group_changed_ind,
  b.service_grouping_priority_nbr;
-- 8. Non standard rate when no specialty or provider type
SELECT
  payment_method_cd,
  service_group_changed_ind,
  service_grouping_priority_nbr,
  max(rate) AS rate
FROM CET_RATES
WHERE
  SERVICE_CD = '90837'
  AND SERVICE_TYPE_CD = 'CPT4'
  AND PLACE_OF_SERVICE_CD = '11'
  AND (PRODUCT_CD = "" OR PRODUCT_CD = 'ALL')
  AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST([])
  AND CONTRACT_TYPE IN ('C', 'N')
GROUP BY payment_method_cd, service_group_changed_ind, service_grouping_priority_nbr;
-- 9. Default rate when SPECIALTY_CD
WITH base AS (
  SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    specialty_cd,
    rate
  FROM CET_RATES
  WHERE
    SERVICE_CD = '90837'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND PLACE_OF_SERVICE_CD = '11'
    AND PRODUCT_CD IN ("", 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST([])
    AND CONTRACT_TYPE = 'D'
),
flag AS (
  SELECT EXISTS (SELECT 1 FROM base WHERE specialty_cd = '') AS has_providerspecialtycode
)
SELECT
  b.payment_method_cd,
  b.service_group_changed_ind,
  b.service_grouping_priority_nbr,
  MAX(b.rate) AS rate
FROM base b
CROSS JOIN flag f
WHERE b.specialty_cd = CASE WHEN f.has_providerspecialtycode THEN '' ELSE '' END
GROUP BY
  b.payment_method_cd,
  b.service_group_changed_ind,
  b.service_grouping_priority_nbr;
-- 10. Default rate when PROVIDER_TYPE_CD
WITH base AS (
  SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    specialty_cd,
    rate
  FROM CET_RATES
  WHERE
    SERVICE_CD = '90837'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND PLACE_OF_SERVICE_CD = '11'
    AND PRODUCT_CD IN ("", 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST([])
    AND CONTRACT_TYPE = 'D'
),
flag AS (
  SELECT EXISTS (SELECT 1 FROM base WHERE specialty_cd = 'MT') AS has_providertype
)
SELECT
  b.payment_method_cd,
  b.service_group_changed_ind,
  b.service_grouping_priority_nbr,
  MAX(b.rate) AS rate
FROM base b
CROSS JOIN flag f
WHERE b.specialty_cd = CASE WHEN f.has_providertype THEN 'MT' ELSE '' END
GROUP BY
  b.payment_method_cd,
  b.service_group_changed_ind,
  b.service_grouping_priority_nbr;
-- 11. Default rate when no specialty or provider type
SELECT
  payment_method_cd,
  service_group_changed_ind,
  service_grouping_priority_nbr,
  max(rate) AS rate
FROM CET_RATES
WHERE
  SERVICE_CD = '90837'
  AND SERVICE_TYPE_CD = 'CPT4'
  AND PLACE_OF_SERVICE_CD = '11'
  AND (PRODUCT_CD = "" OR PRODUCT_CD = 'ALL')
  AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST([])
  AND CONTRACT_TYPE = 'D' 
GROUP BY payment_method_cd, service_group_changed_ind, service_grouping_priority_nbr;

-- row_num 2114404
-- 1. claim based rate
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = '8023504'
    AND NETWORK_ID = '09511'
    AND PLACE_OF_SERVICE_CD = '11'
    AND SERVICE_CD = '90837'
    AND SERVICE_TYPE_CD = 'CPT4';
-- 2. provider info when SPECIALTY_CD
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR, PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = '8023504'
    AND NETWORK_ID = '09511'
    AND SERVICE_LOCATION_NBR = '5467381'
    AND (
        SPECIALTY_CD = '' 
        OR (
            SPECIALTY_CD IS NULL 
            AND NOT EXISTS (
                SELECT 1
                FROM CET_PROVIDERS 
                WHERE 
                    PROVIDER_IDENTIFICATION_NBR = '8023504' 
                    AND NETWORK_ID = '09511' 
                    AND SERVICE_LOCATION_NBR = '5467381' 
                    AND SPECIALTY_CD = ''
            )
        )
    );
-- 3. provider info when PROVIDER_TYPE_CD
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = '8023504'
    AND NETWORK_ID = '09511'
    AND SERVICE_LOCATION_NBR = '5467381'
    AND PROVIDER_TYPE_CD = 'SW';
-- 4. provider info when no specialty or provider type
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = '8023504'
    AND NETWORK_ID = '09511'
    AND SERVICE_LOCATION_NBR = '5467381';
-- 5. Standard rate
SELECT Max(RATE) AS RATE
FROM CET_RATES
WHERE
    RATE_SYSTEM_CD = ""
    AND SERVICE_CD = '90837'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND GEOGRAPHIC_AREA_CD = ""
    AND PLACE_OF_SERVICE_CD = '11'
    AND (PRODUCT_CD = "" OR PRODUCT_CD = 'ALL');
-- 6. Non-standard rate when SPECIALTY_CD
WITH base AS (
  SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    specialty_cd,
    rate
  FROM CET_RATES
  WHERE
    SERVICE_CD = '90837'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND PLACE_OF_SERVICE_CD = '11'
    AND PRODUCT_CD IN ("", 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST([])
    AND CONTRACT_TYPE IN ('C', 'N')
),
flag AS (
  SELECT EXISTS (SELECT 1 FROM base WHERE specialty_cd = '') AS has_providerspecialtycode
)
SELECT
  b.payment_method_cd,
  b.service_group_changed_ind,
  b.service_grouping_priority_nbr,
  MAX(b.rate) AS rate
FROM base b
CROSS JOIN flag f
WHERE b.specialty_cd = CASE WHEN f.has_providerspecialtycode THEN '' ELSE '' END
GROUP BY
  b.payment_method_cd,
  b.service_group_changed_ind,
  b.service_grouping_priority_nbr;
-- 7. Non-standard rate when PROVIDER_TYPE_CD
WITH base AS (
  SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    specialty_cd,
    rate
  FROM CET_RATES
  WHERE
    SERVICE_CD = '90837'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND PLACE_OF_SERVICE_CD = '11'
    AND PRODUCT_CD IN ("", 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST([])
    AND CONTRACT_TYPE IN ('C', 'N')
),
flag AS (
  SELECT EXISTS (SELECT 1 FROM base WHERE specialty_cd = 'SW') AS has_providertype
)
SELECT
  b.payment_method_cd,
  b.service_group_changed_ind,
  b.service_grouping_priority_nbr,
  MAX(b.rate) AS rate
FROM base b
CROSS JOIN flag f 
WHERE b.specialty_cd = CASE WHEN f.has_providertype THEN 'SW' ELSE '' END
GROUP BY
  b.payment_method_cd,
  b.service_group_changed_ind,
  b.service_grouping_priority_nbr;
-- 8. Non standard rate when no specialty or provider type
SELECT
  payment_method_cd,
  service_group_changed_ind,
  service_grouping_priority_nbr,
  max(rate) AS rate
FROM CET_RATES
WHERE
  SERVICE_CD = '90837'
  AND SERVICE_TYPE_CD = 'CPT4'
  AND PLACE_OF_SERVICE_CD = '11'
  AND (PRODUCT_CD = "" OR PRODUCT_CD = 'ALL')
  AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST([])
  AND CONTRACT_TYPE IN ('C', 'N')
GROUP BY payment_method_cd, service_group_changed_ind, service_grouping_priority_nbr;
-- 9. Default rate when SPECIALTY_CD
WITH base AS (
  SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    specialty_cd,
    rate
  FROM CET_RATES
  WHERE
    SERVICE_CD = '90837'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND PLACE_OF_SERVICE_CD = '11'
    AND PRODUCT_CD IN ("", 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST([])
    AND CONTRACT_TYPE = 'D'
),
flag AS (
  SELECT EXISTS (SELECT 1 FROM base WHERE specialty_cd = '') AS has_providerspecialtycode
)
SELECT
  b.payment_method_cd,
  b.service_group_changed_ind,
  b.service_grouping_priority_nbr,
  MAX(b.rate) AS rate
FROM base b
CROSS JOIN flag f
WHERE b.specialty_cd = CASE WHEN f.has_providerspecialtycode THEN '' ELSE '' END
GROUP BY
  b.payment_method_cd,
  b.service_group_changed_ind,
  b.service_grouping_priority_nbr;
-- 10. Default rate when PROVIDER_TYPE_CD
WITH base AS (
  SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    specialty_cd,
    rate
  FROM CET_RATES
  WHERE
    SERVICE_CD = '90837'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND PLACE_OF_SERVICE_CD = '11'
    AND PRODUCT_CD IN ("", 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST([])
    AND CONTRACT_TYPE = 'D'
),
flag AS (
  SELECT EXISTS (SELECT 1 FROM base WHERE specialty_cd = 'SW') AS has_providertype
)
SELECT
  b.payment_method_cd,
  b.service_group_changed_ind,
  b.service_grouping_priority_nbr,
  MAX(b.rate) AS rate
FROM base b
CROSS JOIN flag f
WHERE b.specialty_cd = CASE WHEN f.has_providertype THEN 'SW' ELSE '' END
GROUP BY
  b.payment_method_cd,
  b.service_group_changed_ind,
  b.service_grouping_priority_nbr;
-- 11. Default rate when no specialty or provider type
SELECT
  payment_method_cd,
  service_group_changed_ind,
  service_grouping_priority_nbr,
  max(rate) AS rate
FROM CET_RATES
WHERE
  SERVICE_CD = '90837'
  AND SERVICE_TYPE_CD = 'CPT4'
  AND PLACE_OF_SERVICE_CD = '11'
  AND (PRODUCT_CD = "" OR PRODUCT_CD = 'ALL')
  AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST([])
  AND CONTRACT_TYPE = 'D' 
GROUP BY payment_method_cd, service_group_changed_ind, service_grouping_priority_nbr;

-- row_num 9959567
-- 1. claim based rate
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = '8006400'
    AND NETWORK_ID = '01449'
    AND PLACE_OF_SERVICE_CD = '11'
    AND SERVICE_CD = '90837'
    AND SERVICE_TYPE_CD = 'CPT4';
-- 2. provider info when SPECIALTY_CD
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR, PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = '8006400'
    AND NETWORK_ID = '01449'
    AND SERVICE_LOCATION_NBR = '591039'
    AND (
        SPECIALTY_CD = '' 
        OR (
            SPECIALTY_CD IS NULL 
            AND NOT EXISTS (
                SELECT 1
                FROM CET_PROVIDERS 
                WHERE 
                    PROVIDER_IDENTIFICATION_NBR = '8006400' 
                    AND NETWORK_ID = '01449' 
                    AND SERVICE_LOCATION_NBR = '591039' 
                    AND SPECIALTY_CD = ''
            )
        )
    );
-- 3. provider info when PROVIDER_TYPE_CD
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = '8006400'
    AND NETWORK_ID = '01449'
    AND SERVICE_LOCATION_NBR = '591039'
    AND PROVIDER_TYPE_CD = 'LPC';
-- 4. provider info when no specialty or provider type
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = '8006400'
    AND NETWORK_ID = '01449'
    AND SERVICE_LOCATION_NBR = '591039';
-- 5. Standard rate
SELECT Max(RATE) AS RATE
FROM CET_RATES
WHERE
    RATE_SYSTEM_CD = ""
    AND SERVICE_CD = '90837'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND GEOGRAPHIC_AREA_CD = ""
    AND PLACE_OF_SERVICE_CD = '11'
    AND (PRODUCT_CD = "" OR PRODUCT_CD = 'ALL');
-- 6. Non-standard rate when SPECIALTY_CD
WITH base AS (
  SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    specialty_cd,
    rate
  FROM CET_RATES
  WHERE
    SERVICE_CD = '90837'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND PLACE_OF_SERVICE_CD = '11'
    AND PRODUCT_CD IN ("", 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST([])
    AND CONTRACT_TYPE IN ('C', 'N')
),
flag AS (
  SELECT EXISTS (SELECT 1 FROM base WHERE specialty_cd = '') AS has_providerspecialtycode
)
SELECT
  b.payment_method_cd,
  b.service_group_changed_ind,
  b.service_grouping_priority_nbr,
  MAX(b.rate) AS rate
FROM base b
CROSS JOIN flag f
WHERE b.specialty_cd = CASE WHEN f.has_providerspecialtycode THEN '' ELSE '' END
GROUP BY
  b.payment_method_cd,
  b.service_group_changed_ind,
  b.service_grouping_priority_nbr;
-- 7. Non-standard rate when PROVIDER_TYPE_CD
WITH base AS (
  SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    specialty_cd,
    rate
  FROM CET_RATES
  WHERE
    SERVICE_CD = '90837'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND PLACE_OF_SERVICE_CD = '11'
    AND PRODUCT_CD IN ("", 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST([])
    AND CONTRACT_TYPE IN ('C', 'N')
),
flag AS (
  SELECT EXISTS (SELECT 1 FROM base WHERE specialty_cd = 'LPC') AS has_providertype
)
SELECT
  b.payment_method_cd,
  b.service_group_changed_ind,
  b.service_grouping_priority_nbr,
  MAX(b.rate) AS rate
FROM base b
CROSS JOIN flag f 
WHERE b.specialty_cd = CASE WHEN f.has_providertype THEN 'LPC' ELSE '' END
GROUP BY
  b.payment_method_cd,
  b.service_group_changed_ind,
  b.service_grouping_priority_nbr;
-- 8. Non standard rate when no specialty or provider type
SELECT
  payment_method_cd,
  service_group_changed_ind,
  service_grouping_priority_nbr,
  max(rate) AS rate
FROM CET_RATES
WHERE
  SERVICE_CD = '90837'
  AND SERVICE_TYPE_CD = 'CPT4'
  AND PLACE_OF_SERVICE_CD = '11'
  AND (PRODUCT_CD = "" OR PRODUCT_CD = 'ALL')
  AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST([])
  AND CONTRACT_TYPE IN ('C', 'N')
GROUP BY payment_method_cd, service_group_changed_ind, service_grouping_priority_nbr;
-- 9. Default rate when SPECIALTY_CD
WITH base AS (
  SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    specialty_cd,
    rate
  FROM CET_RATES
  WHERE
    SERVICE_CD = '90837'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND PLACE_OF_SERVICE_CD = '11'
    AND PRODUCT_CD IN ("", 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST([])
    AND CONTRACT_TYPE = 'D'
),
flag AS (
  SELECT EXISTS (SELECT 1 FROM base WHERE specialty_cd = '') AS has_providerspecialtycode
)
SELECT
  b.payment_method_cd,
  b.service_group_changed_ind,
  b.service_grouping_priority_nbr,
  MAX(b.rate) AS rate
FROM base b
CROSS JOIN flag f
WHERE b.specialty_cd = CASE WHEN f.has_providerspecialtycode THEN '' ELSE '' END
GROUP BY
  b.payment_method_cd,
  b.service_group_changed_ind,
  b.service_grouping_priority_nbr;
-- 10. Default rate when PROVIDER_TYPE_CD
WITH base AS (
  SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    specialty_cd,
    rate
  FROM CET_RATES
  WHERE
    SERVICE_CD = '90837'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND PLACE_OF_SERVICE_CD = '11'
    AND PRODUCT_CD IN ("", 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST([])
    AND CONTRACT_TYPE = 'D'
),
flag AS (
  SELECT EXISTS (SELECT 1 FROM base WHERE specialty_cd = 'LPC') AS has_providertype
)
SELECT
  b.payment_method_cd,
  b.service_group_changed_ind,
  b.service_grouping_priority_nbr,
  MAX(b.rate) AS rate
FROM base b
CROSS JOIN flag f
WHERE b.specialty_cd = CASE WHEN f.has_providertype THEN 'LPC' ELSE '' END
GROUP BY
  b.payment_method_cd,
  b.service_group_changed_ind,
  b.service_grouping_priority_nbr;
-- 11. Default rate when no specialty or provider type
SELECT
  payment_method_cd,
  service_group_changed_ind,
  service_grouping_priority_nbr,
  max(rate) AS rate
FROM CET_RATES
WHERE
  SERVICE_CD = '90837'
  AND SERVICE_TYPE_CD = 'CPT4'
  AND PLACE_OF_SERVICE_CD = '11'
  AND (PRODUCT_CD = "" OR PRODUCT_CD = 'ALL')
  AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST([])
  AND CONTRACT_TYPE = 'D' 
GROUP BY payment_method_cd, service_group_changed_ind, service_grouping_priority_nbr;

-- row_num 5746151
-- 1. claim based rate
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = '8766387'
    AND NETWORK_ID = '00582'
    AND PLACE_OF_SERVICE_CD = '11'
    AND SERVICE_CD = '90837'
    AND SERVICE_TYPE_CD = 'CPT4';
-- 2. provider info when SPECIALTY_CD
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR, PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = '8766387'
    AND NETWORK_ID = '00582'
    AND SERVICE_LOCATION_NBR = '5506343'
    AND (
        SPECIALTY_CD = '' 
        OR (
            SPECIALTY_CD IS NULL 
            AND NOT EXISTS (
                SELECT 1
                FROM CET_PROVIDERS 
                WHERE 
                    PROVIDER_IDENTIFICATION_NBR = '8766387' 
                    AND NETWORK_ID = '00582' 
                    AND SERVICE_LOCATION_NBR = '5506343' 
                    AND SPECIALTY_CD = ''
            )
        )
    );
-- 3. provider info when PROVIDER_TYPE_CD
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = '8766387'
    AND NETWORK_ID = '00582'
    AND SERVICE_LOCATION_NBR = '5506343'
    AND PROVIDER_TYPE_CD = 'SW';
-- 4. provider info when no specialty or provider type
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = '8766387'
    AND NETWORK_ID = '00582'
    AND SERVICE_LOCATION_NBR = '5506343';
-- 5. Standard rate
SELECT Max(RATE) AS RATE
FROM CET_RATES
WHERE
    RATE_SYSTEM_CD = ""
    AND SERVICE_CD = '90837'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND GEOGRAPHIC_AREA_CD = ""
    AND PLACE_OF_SERVICE_CD = '11'
    AND (PRODUCT_CD = "" OR PRODUCT_CD = 'ALL');
-- 6. Non-standard rate when SPECIALTY_CD
WITH base AS (
  SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    specialty_cd,
    rate
  FROM CET_RATES
  WHERE
    SERVICE_CD = '90837'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND PLACE_OF_SERVICE_CD = '11'
    AND PRODUCT_CD IN ("", 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST([])
    AND CONTRACT_TYPE IN ('C', 'N')
),
flag AS (
  SELECT EXISTS (SELECT 1 FROM base WHERE specialty_cd = '') AS has_providerspecialtycode
)
SELECT
  b.payment_method_cd,
  b.service_group_changed_ind,
  b.service_grouping_priority_nbr,
  MAX(b.rate) AS rate
FROM base b
CROSS JOIN flag f
WHERE b.specialty_cd = CASE WHEN f.has_providerspecialtycode THEN '' ELSE '' END
GROUP BY
  b.payment_method_cd,
  b.service_group_changed_ind,
  b.service_grouping_priority_nbr;
-- 7. Non-standard rate when PROVIDER_TYPE_CD
WITH base AS (
  SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    specialty_cd,
    rate
  FROM CET_RATES
  WHERE
    SERVICE_CD = '90837'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND PLACE_OF_SERVICE_CD = '11'
    AND PRODUCT_CD IN ("", 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST([])
    AND CONTRACT_TYPE IN ('C', 'N')
),
flag AS (
  SELECT EXISTS (SELECT 1 FROM base WHERE specialty_cd = 'SW') AS has_providertype
)
SELECT
  b.payment_method_cd,
  b.service_group_changed_ind,
  b.service_grouping_priority_nbr,
  MAX(b.rate) AS rate
FROM base b
CROSS JOIN flag f 
WHERE b.specialty_cd = CASE WHEN f.has_providertype THEN 'SW' ELSE '' END
GROUP BY
  b.payment_method_cd,
  b.service_group_changed_ind,
  b.service_grouping_priority_nbr;
-- 8. Non standard rate when no specialty or provider type
SELECT
  payment_method_cd,
  service_group_changed_ind,
  service_grouping_priority_nbr,
  max(rate) AS rate
FROM CET_RATES
WHERE
  SERVICE_CD = '90837'
  AND SERVICE_TYPE_CD = 'CPT4'
  AND PLACE_OF_SERVICE_CD = '11'
  AND (PRODUCT_CD = "" OR PRODUCT_CD = 'ALL')
  AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST([])
  AND CONTRACT_TYPE IN ('C', 'N')
GROUP BY payment_method_cd, service_group_changed_ind, service_grouping_priority_nbr;
-- 9. Default rate when SPECIALTY_CD
WITH base AS (
  SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    specialty_cd,
    rate
  FROM CET_RATES
  WHERE
    SERVICE_CD = '90837'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND PLACE_OF_SERVICE_CD = '11'
    AND PRODUCT_CD IN ("", 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST([])
    AND CONTRACT_TYPE = 'D'
),
flag AS (
  SELECT EXISTS (SELECT 1 FROM base WHERE specialty_cd = '') AS has_providerspecialtycode
)
SELECT
  b.payment_method_cd,
  b.service_group_changed_ind,
  b.service_grouping_priority_nbr,
  MAX(b.rate) AS rate
FROM base b
CROSS JOIN flag f
WHERE b.specialty_cd = CASE WHEN f.has_providerspecialtycode THEN '' ELSE '' END
GROUP BY
  b.payment_method_cd,
  b.service_group_changed_ind,
  b.service_grouping_priority_nbr;
-- 10. Default rate when PROVIDER_TYPE_CD
WITH base AS (
  SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    specialty_cd,
    rate
  FROM CET_RATES
  WHERE
    SERVICE_CD = '90837'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND PLACE_OF_SERVICE_CD = '11'
    AND PRODUCT_CD IN ("", 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST([])
    AND CONTRACT_TYPE = 'D'
),
flag AS (
  SELECT EXISTS (SELECT 1 FROM base WHERE specialty_cd = 'SW') AS has_providertype
)
SELECT
  b.payment_method_cd,
  b.service_group_changed_ind,
  b.service_grouping_priority_nbr,
  MAX(b.rate) AS rate
FROM base b
CROSS JOIN flag f
WHERE b.specialty_cd = CASE WHEN f.has_providertype THEN 'SW' ELSE '' END
GROUP BY
  b.payment_method_cd,
  b.service_group_changed_ind,
  b.service_grouping_priority_nbr;
-- 11. Default rate when no specialty or provider type
SELECT
  payment_method_cd,
  service_group_changed_ind,
  service_grouping_priority_nbr,
  max(rate) AS rate
FROM CET_RATES
WHERE
  SERVICE_CD = '90837'
  AND SERVICE_TYPE_CD = 'CPT4'
  AND PLACE_OF_SERVICE_CD = '11'
  AND (PRODUCT_CD = "" OR PRODUCT_CD = 'ALL')
  AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST([])
  AND CONTRACT_TYPE = 'D' 
GROUP BY payment_method_cd, service_group_changed_ind, service_grouping_priority_nbr;

-- row_num 10190575
-- 1. claim based rate
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = '8784158'
    AND NETWORK_ID = '00582'
    AND PLACE_OF_SERVICE_CD = '11'
    AND SERVICE_CD = '90837'
    AND SERVICE_TYPE_CD = 'CPT4';
-- 2. provider info when SPECIALTY_CD
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR, PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = '8784158'
    AND NETWORK_ID = '00582'
    AND SERVICE_LOCATION_NBR = '4996320'
    AND (
        SPECIALTY_CD = '' 
        OR (
            SPECIALTY_CD IS NULL 
            AND NOT EXISTS (
                SELECT 1
                FROM CET_PROVIDERS 
                WHERE 
                    PROVIDER_IDENTIFICATION_NBR = '8784158' 
                    AND NETWORK_ID = '00582' 
                    AND SERVICE_LOCATION_NBR = '4996320' 
                    AND SPECIALTY_CD = ''
            )
        )
    );
-- 3. provider info when PROVIDER_TYPE_CD
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = '8784158'
    AND NETWORK_ID = '00582'
    AND SERVICE_LOCATION_NBR = '4996320'
    AND PROVIDER_TYPE_CD = 'SW';
-- 4. provider info when no specialty or provider type
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = '8784158'
    AND NETWORK_ID = '00582'
    AND SERVICE_LOCATION_NBR = '4996320';
-- 5. Standard rate
SELECT Max(RATE) AS RATE
FROM CET_RATES
WHERE
    RATE_SYSTEM_CD = ""
    AND SERVICE_CD = '90837'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND GEOGRAPHIC_AREA_CD = ""
    AND PLACE_OF_SERVICE_CD = '11'
    AND (PRODUCT_CD = "" OR PRODUCT_CD = 'ALL');
-- 6. Non-standard rate when SPECIALTY_CD
WITH base AS (
  SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    specialty_cd,
    rate
  FROM CET_RATES
  WHERE
    SERVICE_CD = '90837'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND PLACE_OF_SERVICE_CD = '11'
    AND PRODUCT_CD IN ("", 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST([])
    AND CONTRACT_TYPE IN ('C', 'N')
),
flag AS (
  SELECT EXISTS (SELECT 1 FROM base WHERE specialty_cd = '') AS has_providerspecialtycode
)
SELECT
  b.payment_method_cd,
  b.service_group_changed_ind,
  b.service_grouping_priority_nbr,
  MAX(b.rate) AS rate
FROM base b
CROSS JOIN flag f
WHERE b.specialty_cd = CASE WHEN f.has_providerspecialtycode THEN '' ELSE '' END
GROUP BY
  b.payment_method_cd,
  b.service_group_changed_ind,
  b.service_grouping_priority_nbr;
-- 7. Non-standard rate when PROVIDER_TYPE_CD
WITH base AS (
  SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    specialty_cd,
    rate
  FROM CET_RATES
  WHERE
    SERVICE_CD = '90837'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND PLACE_OF_SERVICE_CD = '11'
    AND PRODUCT_CD IN ("", 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST([])
    AND CONTRACT_TYPE IN ('C', 'N')
),
flag AS (
  SELECT EXISTS (SELECT 1 FROM base WHERE specialty_cd = 'SW') AS has_providertype
)
SELECT
  b.payment_method_cd,
  b.service_group_changed_ind,
  b.service_grouping_priority_nbr,
  MAX(b.rate) AS rate
FROM base b
CROSS JOIN flag f 
WHERE b.specialty_cd = CASE WHEN f.has_providertype THEN 'SW' ELSE '' END
GROUP BY
  b.payment_method_cd,
  b.service_group_changed_ind,
  b.service_grouping_priority_nbr;
-- 8. Non standard rate when no specialty or provider type
SELECT
  payment_method_cd,
  service_group_changed_ind,
  service_grouping_priority_nbr,
  max(rate) AS rate
FROM CET_RATES
WHERE
  SERVICE_CD = '90837'
  AND SERVICE_TYPE_CD = 'CPT4'
  AND PLACE_OF_SERVICE_CD = '11'
  AND (PRODUCT_CD = "" OR PRODUCT_CD = 'ALL')
  AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST([])
  AND CONTRACT_TYPE IN ('C', 'N')
GROUP BY payment_method_cd, service_group_changed_ind, service_grouping_priority_nbr;
-- 9. Default rate when SPECIALTY_CD
WITH base AS (
  SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    specialty_cd,
    rate
  FROM CET_RATES
  WHERE
    SERVICE_CD = '90837'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND PLACE_OF_SERVICE_CD = '11'
    AND PRODUCT_CD IN ("", 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST([])
    AND CONTRACT_TYPE = 'D'
),
flag AS (
  SELECT EXISTS (SELECT 1 FROM base WHERE specialty_cd = '') AS has_providerspecialtycode
)
SELECT
  b.payment_method_cd,
  b.service_group_changed_ind,
  b.service_grouping_priority_nbr,
  MAX(b.rate) AS rate
FROM base b
CROSS JOIN flag f
WHERE b.specialty_cd = CASE WHEN f.has_providerspecialtycode THEN '' ELSE '' END
GROUP BY
  b.payment_method_cd,
  b.service_group_changed_ind,
  b.service_grouping_priority_nbr;
-- 10. Default rate when PROVIDER_TYPE_CD
WITH base AS (
  SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    specialty_cd,
    rate
  FROM CET_RATES
  WHERE
    SERVICE_CD = '90837'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND PLACE_OF_SERVICE_CD = '11'
    AND PRODUCT_CD IN ("", 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST([])
    AND CONTRACT_TYPE = 'D'
),
flag AS (
  SELECT EXISTS (SELECT 1 FROM base WHERE specialty_cd = 'SW') AS has_providertype
)
SELECT
  b.payment_method_cd,
  b.service_group_changed_ind,
  b.service_grouping_priority_nbr,
  MAX(b.rate) AS rate
FROM base b
CROSS JOIN flag f
WHERE b.specialty_cd = CASE WHEN f.has_providertype THEN 'SW' ELSE '' END
GROUP BY
  b.payment_method_cd,
  b.service_group_changed_ind,
  b.service_grouping_priority_nbr;
-- 11. Default rate when no specialty or provider type
SELECT
  payment_method_cd,
  service_group_changed_ind,
  service_grouping_priority_nbr,
  max(rate) AS rate
FROM CET_RATES
WHERE
  SERVICE_CD = '90837'
  AND SERVICE_TYPE_CD = 'CPT4'
  AND PLACE_OF_SERVICE_CD = '11'
  AND (PRODUCT_CD = "" OR PRODUCT_CD = 'ALL')
  AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST([])
  AND CONTRACT_TYPE = 'D' 
GROUP BY payment_method_cd, service_group_changed_ind, service_grouping_priority_nbr;

-- row_num 9342733
-- 1. claim based rate
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = '8334859'
    AND NETWORK_ID = '00243'
    AND PLACE_OF_SERVICE_CD = '11'
    AND SERVICE_CD = '90837'
    AND SERVICE_TYPE_CD = 'CPT4';
-- 2. provider info when SPECIALTY_CD
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR, PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = '8334859'
    AND NETWORK_ID = '00243'
    AND SERVICE_LOCATION_NBR = '4477376'
    AND (
        SPECIALTY_CD = '' 
        OR (
            SPECIALTY_CD IS NULL 
            AND NOT EXISTS (
                SELECT 1
                FROM CET_PROVIDERS 
                WHERE 
                    PROVIDER_IDENTIFICATION_NBR = '8334859' 
                    AND NETWORK_ID = '00243' 
                    AND SERVICE_LOCATION_NBR = '4477376' 
                    AND SPECIALTY_CD = ''
            )
        )
    );
-- 3. provider info when PROVIDER_TYPE_CD
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = '8334859'
    AND NETWORK_ID = '00243'
    AND SERVICE_LOCATION_NBR = '4477376'
    AND PROVIDER_TYPE_CD = 'LPC';
-- 4. provider info when no specialty or provider type
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = '8334859'
    AND NETWORK_ID = '00243'
    AND SERVICE_LOCATION_NBR = '4477376';
-- 5. Standard rate
SELECT Max(RATE) AS RATE
FROM CET_RATES
WHERE
    RATE_SYSTEM_CD = ""
    AND SERVICE_CD = '90837'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND GEOGRAPHIC_AREA_CD = ""
    AND PLACE_OF_SERVICE_CD = '11'
    AND (PRODUCT_CD = "" OR PRODUCT_CD = 'ALL');
-- 6. Non-standard rate when SPECIALTY_CD
WITH base AS (
  SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    specialty_cd,
    rate
  FROM CET_RATES
  WHERE
    SERVICE_CD = '90837'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND PLACE_OF_SERVICE_CD = '11'
    AND PRODUCT_CD IN ("", 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST([])
    AND CONTRACT_TYPE IN ('C', 'N')
),
flag AS (
  SELECT EXISTS (SELECT 1 FROM base WHERE specialty_cd = '') AS has_providerspecialtycode
)
SELECT
  b.payment_method_cd,
  b.service_group_changed_ind,
  b.service_grouping_priority_nbr,
  MAX(b.rate) AS rate
FROM base b
CROSS JOIN flag f
WHERE b.specialty_cd = CASE WHEN f.has_providerspecialtycode THEN '' ELSE '' END
GROUP BY
  b.payment_method_cd,
  b.service_group_changed_ind,
  b.service_grouping_priority_nbr;
-- 7. Non-standard rate when PROVIDER_TYPE_CD
WITH base AS (
  SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    specialty_cd,
    rate
  FROM CET_RATES
  WHERE
    SERVICE_CD = '90837'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND PLACE_OF_SERVICE_CD = '11'
    AND PRODUCT_CD IN ("", 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST([])
    AND CONTRACT_TYPE IN ('C', 'N')
),
flag AS (
  SELECT EXISTS (SELECT 1 FROM base WHERE specialty_cd = 'LPC') AS has_providertype
)
SELECT
  b.payment_method_cd,
  b.service_group_changed_ind,
  b.service_grouping_priority_nbr,
  MAX(b.rate) AS rate
FROM base b
CROSS JOIN flag f 
WHERE b.specialty_cd = CASE WHEN f.has_providertype THEN 'LPC' ELSE '' END
GROUP BY
  b.payment_method_cd,
  b.service_group_changed_ind,
  b.service_grouping_priority_nbr;
-- 8. Non standard rate when no specialty or provider type
SELECT
  payment_method_cd,
  service_group_changed_ind,
  service_grouping_priority_nbr,
  max(rate) AS rate
FROM CET_RATES
WHERE
  SERVICE_CD = '90837'
  AND SERVICE_TYPE_CD = 'CPT4'
  AND PLACE_OF_SERVICE_CD = '11'
  AND (PRODUCT_CD = "" OR PRODUCT_CD = 'ALL')
  AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST([])
  AND CONTRACT_TYPE IN ('C', 'N')
GROUP BY payment_method_cd, service_group_changed_ind, service_grouping_priority_nbr;
-- 9. Default rate when SPECIALTY_CD
WITH base AS (
  SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    specialty_cd,
    rate
  FROM CET_RATES
  WHERE
    SERVICE_CD = '90837'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND PLACE_OF_SERVICE_CD = '11'
    AND PRODUCT_CD IN ("", 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST([])
    AND CONTRACT_TYPE = 'D'
),
flag AS (
  SELECT EXISTS (SELECT 1 FROM base WHERE specialty_cd = '') AS has_providerspecialtycode
)
SELECT
  b.payment_method_cd,
  b.service_group_changed_ind,
  b.service_grouping_priority_nbr,
  MAX(b.rate) AS rate
FROM base b
CROSS JOIN flag f
WHERE b.specialty_cd = CASE WHEN f.has_providerspecialtycode THEN '' ELSE '' END
GROUP BY
  b.payment_method_cd,
  b.service_group_changed_ind,
  b.service_grouping_priority_nbr;
-- 10. Default rate when PROVIDER_TYPE_CD
WITH base AS (
  SELECT
    payment_method_cd,
    service_group_changed_ind,
    service_grouping_priority_nbr,
    specialty_cd,
    rate
  FROM CET_RATES
  WHERE
    SERVICE_CD = '90837'
    AND SERVICE_TYPE_CD = 'CPT4'
    AND PLACE_OF_SERVICE_CD = '11'
    AND PRODUCT_CD IN ("", 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST([])
    AND CONTRACT_TYPE = 'D'
),
flag AS (
  SELECT EXISTS (SELECT 1 FROM base WHERE specialty_cd = 'LPC') AS has_providertype
)
SELECT
  b.payment_method_cd,
  b.service_group_changed_ind,
  b.service_grouping_priority_nbr,
  MAX(b.rate) AS rate
FROM base b
CROSS JOIN flag f
WHERE b.specialty_cd = CASE WHEN f.has_providertype THEN 'LPC' ELSE '' END
GROUP BY
  b.payment_method_cd,
  b.service_group_changed_ind,
  b.service_grouping_priority_nbr;
-- 11. Default rate when no specialty or provider type
SELECT
  payment_method_cd,
  service_group_changed_ind,
  service_grouping_priority_nbr,
  max(rate) AS rate
FROM CET_RATES
WHERE
  SERVICE_CD = '90837'
  AND SERVICE_TYPE_CD = 'CPT4'
  AND PLACE_OF_SERVICE_CD = '11'
  AND (PRODUCT_CD = "" OR PRODUCT_CD = 'ALL')
  AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST([])
  AND CONTRACT_TYPE = 'D' 
GROUP BY payment_method_cd, service_group_changed_ind, service_grouping_priority_nbr;

-- row_num 7105555
-- 1. claim based rate
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = '8161818'
    AND NETWORK_ID = '00482'
    AND PLACE_OF_SERVICE_CD = '11'
    AND SERVICE_CD = '90837'
    AND SERVICE_TYPE_CD = 'CPT4';
-- 2. provider info when SPECIALTY_CD
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR, PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = '8161818'
    AND NETWORK_ID = '00482'
    AND SERVICE_LOCATION_NBR = '4166556'
    AND
