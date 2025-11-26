-- 1. claim based rate
get claim based rate
SELECT MAX(RATE) AS RATE
FROM CET_CLAIM_BASED_AMOUNTS
WHERE
    PROVIDER_IDENTIFICATION_NBR = @provideridentificationnumber
    AND NETWORK_ID = @networkid
    AND PLACE_OF_SERVICE_CD = @placeofservice
    AND SERVICE_CD = @servicecd
    AND SERVICE_TYPE_CD = @servicetype

-- 2. provider info when SPECIALTY_CD
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR, PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = @provideridentificationnumber
    AND NETWORK_ID = @networkid
    AND SERVICE_LOCATION_NBR = @servicelocationnumber
    AND (
        SPECIALTY_CD = @providerspecialtycode
        OR (
            SPECIALTY_CD IS NULL 
            AND NOT EXISTS (
                SELECT 1 
                FROM CET_PROVIDERS 
                WHERE 
                    PROVIDER_IDENTIFICATION_NBR = @provideridentificationnumber 
                    AND NETWORK_ID = @networkid 
                    AND SERVICE_LOCATION_NBR = @servicelocationnumber  
                    AND SPECIALTY_CD = @providerspecialtycode
            )
        )
    );

-- 3. provider info when PROVIDER_TYPE_CD
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = @provideridentificationnumber
    AND NETWORK_ID = @networkid
    AND SERVICE_LOCATION_NBR = @servicelocationnumber
    AND PROVIDER_TYPE_CD = @providertype

-- 4. provider info when no specialty or provider type
SELECT DISTINCT PROVIDER_BUSINESS_GROUP_NBR, PROVIDER_BUSINESS_GROUP_SCORE_NBR, PROVIDER_IDENTIFICATION_NBR,PRODUCT_CD, SERVICE_LOCATION_NBR, NETWORK_ID, RATING_SYSTEM_CD, EPDB_GEOGRAPHIC_AREA_CD
FROM CET_PROVIDERS
WHERE
    PROVIDER_IDENTIFICATION_NBR = @provideridentificationnumber
    AND NETWORK_ID = @networkid
    AND SERVICE_LOCATION_NBR = @servicelocationnumber

-- 5. Standard rate
SELECT Max(RATE) AS RATE
FROM CET_RATES
WHERE
    RATE_SYSTEM_CD = @ratesystemcd
    AND SERVICE_CD = @servicecd
    AND SERVICE_TYPE_CD = @servicetype
    AND GEOGRAPHIC_AREA_CD = @geographicareacd
    AND PLACE_OF_SERVICE_CD = @placeofservice
    AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')

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
    SERVICE_CD = @servicecd
    AND SERVICE_TYPE_CD = @servicetype
    AND PLACE_OF_SERVICE_CD = @placeofservice
    AND PRODUCT_CD IN (@productcd, 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE IN ('C', 'N')
),
flag AS (
  SELECT EXISTS (SELECT 1 FROM base WHERE specialty_cd = @providerspecialtycode) AS has_providerspecialtycode
)
SELECT
  b.payment_method_cd,
  b.service_group_changed_ind,
  b.service_grouping_priority_nbr,
  MAX(b.rate) AS rate
FROM base b
CROSS JOIN flag f
WHERE b.specialty_cd = CASE WHEN f.has_providerspecialtycode THEN @providerspecialtycode ELSE '' END
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
    SERVICE_CD = @servicecd
    AND SERVICE_TYPE_CD = @servicetype
    AND PLACE_OF_SERVICE_CD = @placeofservice
    AND PRODUCT_CD IN (@productcd, 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE IN ('C', 'N')
),
flag AS (
  SELECT EXISTS (SELECT 1 FROM base WHERE specialty_cd = @providertype) AS has_providertype
)
SELECT
  b.payment_method_cd,
  b.service_group_changed_ind,
  b.service_grouping_priority_nbr,
  MAX(b.rate) AS rate
FROM base b
CROSS JOIN flag f 
WHERE b.specialty_cd = CASE WHEN f.has_providertype THEN @providertype ELSE '' END
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
  SERVICE_CD = @servicecd
  AND SERVICE_TYPE_CD = @servicetype
  AND PLACE_OF_SERVICE_CD = @placeofservice
  AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
  AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
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
    SERVICE_CD = @servicecd
    AND SERVICE_TYPE_CD = @servicetype
    AND PLACE_OF_SERVICE_CD = @placeofservice
    AND PRODUCT_CD IN (@productcd, 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE = 'D'
),
flag AS (
  SELECT EXISTS (SELECT 1 FROM base WHERE specialty_cd = @providerspecialtycode) AS has_providerspecialtycode
)
SELECT
  b.payment_method_cd,
  b.service_group_changed_ind,
  b.service_grouping_priority_nbr,
  MAX(b.rate) AS rate
FROM base b
CROSS JOIN flag f
WHERE b.specialty_cd = CASE WHEN f.has_providerspecialtycode THEN @providerspecialtycode ELSE '' END
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
    SERVICE_CD = @servicecd
    AND SERVICE_TYPE_CD = @servicetype
    AND PLACE_OF_SERVICE_CD = @placeofservice
    AND PRODUCT_CD IN (@productcd, 'ALL')
    AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
    AND CONTRACT_TYPE = 'D'
),
flag AS (
  SELECT EXISTS (SELECT 1 FROM base WHERE specialty_cd = @providertype) AS has_providertype
)
SELECT
  b.payment_method_cd,
  b.service_group_changed_ind,
  b.service_grouping_priority_nbr,
  MAX(b.rate) AS rate
FROM base b
CROSS JOIN flag f
WHERE b.specialty_cd = CASE WHEN f.has_providertype THEN @providertype ELSE '' END
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
  SERVICE_CD = @servicecd
  AND SERVICE_TYPE_CD = @servicetype
  AND PLACE_OF_SERVICE_CD = @placeofservice
  AND (PRODUCT_CD = @productcd OR PRODUCT_CD = 'ALL')
  AND PROVIDER_BUSINESS_GROUP_NBR IN UNNEST(@providerbusinessgroupnbr)
  AND CONTRACT_TYPE = 'D' 
GROUP BY payment_method_cd, service_group_changed_ind, service_grouping_priority_nbr;
