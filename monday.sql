-- row 1
WITH Standard_zips AS (
    SELECT DISTINCT
        t1.ZIP_CD,
        t1.RATING_SYSTEM_CD AS TIN_RATING_SYSTEM_CD,
        t1.GEOGRAPHIC_AREA_CD AS tin_GEOGRAPHIC_AREA_CD,
        t3.GEOGRAPHIC_AREA_CD,
        t3.OVERRIDE_RATE_SYSTEM_CD
    FROM `prv_ps_ce_hcb_dev.CET_EPDB_TAX_IDENTIFICATION_NUMBER_ADDRESS_DETAIL_VIEW` t1
    LEFT JOIN `prv_ps_ce_hcb_dev.CET_EPDB_CONTRACT_PROVIDER_BUSINESS_GROUP_VIEW` t2
      ON t1.provider_identification_nbr = t2.provider_identification_nbr
     AND t1.tax_identification_nbr     = t2.tax_identification_nbr
     AND t1.service_location_nbr       = t2.service_location_nbr
     AND t1.network_id                 = t2.network_id
    LEFT JOIN `prv_ps_ce_hcb_dev.CET_SCSR_RATE_OVERRIDE_VIEW` t3
      ON t1.ZIP_CD          = t3.GEOGRAPHIC_AREA_CD
     AND t1.RATING_SYSTEM_CD = t3.RATE_SYSTEM_CD
    WHERE t2.provider_business_group_nbr IS NULL
      AND t1.ZIP_CD = '77079'
      AND (t3.OVERRIDE_RATE_SYSTEM_CD = '' OR t3.OVERRIDE_RATE_SYSTEM_CD IS NULL)  -- TIN path only
)

SELECT DISTINCT
    t4.RATE_SYSTEM_CD,
    t4.SERVICE_CD,
    t4.SERVICE_TYPE_CD,
    sp.tin_GEOGRAPHIC_AREA_CD AS GEOGRAPHIC_AREA_CD,
    t4.SPECIALTY_CD,
    t4.SPECIALTY_TYPE_CD,
    CAST(t4.RATE_AMT AS FLOAT64) AS RATE
FROM Standard_zips sp
JOIN `prv_ps_ce_hcb_dev.CET_SCSR_RATE_DETAIL_VIEW` t4
  ON t4.RATE_SYSTEM_CD     = sp.TIN_RATING_SYSTEM_CD
 AND t4.GEOGRAPHIC_AREA_CD = sp.tin_GEOGRAPHIC_AREA_CD
JOIN `prv_ps_ce_hcb_dev.CET_SCSR_DIFFERENTIATION_CRITERIA_VIEW` tsdc
  ON tsdc.differentiation_criteria_id = t4.differentiation_criteria_id
JOIN `prv_ps_ce_dec_hcb_dev.service_code_master` scm
  ON TRIM(scm.primary_svc_cd) = t4.SERVICE_CD
WHERE t4.EXTENSION_CD = ''
  AND scm.in_scope_ind = 1
  AND scm.trmn_dt > CURRENT_DATE()
  AND scm.primary_svc_cd = '90837'       -- focus on psychotherapy
ORDER BY RATE DESC;


SELECT max(rate) as rate
FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
WHERE
    RATE_SYSTEM_CD = "REF"
    AND SERVICE_CD = "90837" --
    AND SERVICE_TYPE_CD = "CPT4" --
    AND GEOGRAPHIC_AREA_CD = "TX03"
    AND PLACE_OF_SERVICE_CD = "11" --
    AND CONTRACT_TYPE='S'
    and SPECIALTY_CD="LPC";




-- row 2
WITH Standard_zips AS (
    SELECT DISTINCT
        t1.ZIP_CD,
        t1.RATING_SYSTEM_CD AS TIN_RATING_SYSTEM_CD,
        t1.GEOGRAPHIC_AREA_CD AS tin_GEOGRAPHIC_AREA_CD,
        t3.GEOGRAPHIC_AREA_CD,
        t3.OVERRIDE_RATE_SYSTEM_CD
    FROM `prv_ps_ce_hcb_dev.CET_EPDB_TAX_IDENTIFICATION_NUMBER_ADDRESS_DETAIL_VIEW` t1
    LEFT JOIN `prv_ps_ce_hcb_dev.CET_EPDB_CONTRACT_PROVIDER_BUSINESS_GROUP_VIEW` t2
      ON t1.provider_identification_nbr = t2.provider_identification_nbr
     AND t1.tax_identification_nbr     = t2.tax_identification_nbr
     AND t1.service_location_nbr       = t2.service_location_nbr
     AND t1.network_id                 = t2.network_id
    LEFT JOIN `prv_ps_ce_hcb_dev.CET_SCSR_RATE_OVERRIDE_VIEW` t3
      ON t1.ZIP_CD          = t3.GEOGRAPHIC_AREA_CD
     AND t1.RATING_SYSTEM_CD = t3.RATE_SYSTEM_CD
    WHERE t2.provider_business_group_nbr IS NULL
      AND t1.ZIP_CD = '99686'
      AND (t3.OVERRIDE_RATE_SYSTEM_CD = '' OR t3.OVERRIDE_RATE_SYSTEM_CD IS NULL)  -- TIN path only
)
SELECT DISTINCT
    t4.RATE_SYSTEM_CD,
    t4.SERVICE_CD,
    t4.SERVICE_TYPE_CD,
    sp.tin_GEOGRAPHIC_AREA_CD AS GEOGRAPHIC_AREA_CD,
    t4.SPECIALTY_CD,
    t4.SPECIALTY_TYPE_CD,
    CAST(t4.RATE_AMT AS FLOAT64) AS RATE
FROM Standard_zips sp
JOIN `prv_ps_ce_hcb_dev.CET_SCSR_RATE_DETAIL_VIEW` t4
  ON t4.RATE_SYSTEM_CD     = sp.TIN_RATING_SYSTEM_CD
 AND t4.GEOGRAPHIC_AREA_CD = sp.tin_GEOGRAPHIC_AREA_CD
JOIN `prv_ps_ce_hcb_dev.CET_SCSR_DIFFERENTIATION_CRITERIA_VIEW` tsdc
  ON tsdc.differentiation_criteria_id = t4.differentiation_criteria_id
JOIN `prv_ps_ce_dec_hcb_dev.service_code_master` scm
  ON TRIM(scm.primary_svc_cd) = t4.SERVICE_CD
WHERE t4.EXTENSION_CD = ''
  AND scm.in_scope_ind = 1
  AND scm.trmn_dt > CURRENT_DATE()
  AND scm.primary_svc_cd = '90837'       -- focus on psychotherapy
  and t4.SPECIALTY_CD="SW"
ORDER BY RATE DESC;


SELECT rate, SPECIALTY_CD, SPECIALTY_TYPE_CD
FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
WHERE
    RATE_SYSTEM_CD = "REF"
    AND SERVICE_CD = "90837" --
    AND SERVICE_TYPE_CD = "CPT4" --
    AND GEOGRAPHIC_AREA_CD = "AK01"
    AND PLACE_OF_SERVICE_CD = "11" --
    AND CONTRACT_TYPE='S'
    and SPECIALTY_CD="SW";



-- row 3
WITH Standard_zips AS (
    SELECT DISTINCT
        t1.ZIP_CD,
        t1.RATING_SYSTEM_CD AS TIN_RATING_SYSTEM_CD,
        t1.GEOGRAPHIC_AREA_CD AS tin_GEOGRAPHIC_AREA_CD,
        t3.GEOGRAPHIC_AREA_CD,
        t3.OVERRIDE_RATE_SYSTEM_CD
    FROM `prv_ps_ce_hcb_dev.CET_EPDB_TAX_IDENTIFICATION_NUMBER_ADDRESS_DETAIL_VIEW` t1
    LEFT JOIN `prv_ps_ce_hcb_dev.CET_EPDB_CONTRACT_PROVIDER_BUSINESS_GROUP_VIEW` t2
      ON t1.provider_identification_nbr = t2.provider_identification_nbr
     AND t1.tax_identification_nbr     = t2.tax_identification_nbr
     AND t1.service_location_nbr       = t2.service_location_nbr
     AND t1.network_id                 = t2.network_id
    LEFT JOIN `prv_ps_ce_hcb_dev.CET_SCSR_RATE_OVERRIDE_VIEW` t3
      ON t1.ZIP_CD          = t3.GEOGRAPHIC_AREA_CD
     AND t1.RATING_SYSTEM_CD = t3.RATE_SYSTEM_CD
    WHERE t2.provider_business_group_nbr IS NULL
      AND t1.ZIP_CD = '72015'
      AND (t3.OVERRIDE_RATE_SYSTEM_CD = '' OR t3.OVERRIDE_RATE_SYSTEM_CD IS NULL)  -- TIN path only
)

SELECT DISTINCT
    t4.RATE_SYSTEM_CD,
    t4.SERVICE_CD,
    t4.SERVICE_TYPE_CD,
    sp.tin_GEOGRAPHIC_AREA_CD AS GEOGRAPHIC_AREA_CD,
    t4.SPECIALTY_CD,
    t4.SPECIALTY_TYPE_CD,
    CAST(t4.RATE_AMT AS FLOAT64) AS RATE
FROM Standard_zips sp
JOIN `prv_ps_ce_hcb_dev.CET_SCSR_RATE_DETAIL_VIEW` t4
  ON t4.RATE_SYSTEM_CD     = sp.TIN_RATING_SYSTEM_CD
 AND t4.GEOGRAPHIC_AREA_CD = sp.tin_GEOGRAPHIC_AREA_CD
JOIN `prv_ps_ce_hcb_dev.CET_SCSR_DIFFERENTIATION_CRITERIA_VIEW` tsdc
  ON tsdc.differentiation_criteria_id = t4.differentiation_criteria_id
JOIN `prv_ps_ce_dec_hcb_dev.service_code_master` scm
  ON TRIM(scm.primary_svc_cd) = t4.SERVICE_CD
WHERE t4.EXTENSION_CD = ''
  AND scm.in_scope_ind = 1
  AND scm.trmn_dt > CURRENT_DATE()
  AND scm.primary_svc_cd = '90837'       -- focus on psychotherapy
ORDER BY RATE DESC;


SELECT max(rate) as rate
FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
WHERE
    RATE_SYSTEM_CD = "REF"
    AND SERVICE_CD = "90837" --
    AND SERVICE_TYPE_CD = "CPT4" --
    AND GEOGRAPHIC_AREA_CD = "AR01"
    AND PLACE_OF_SERVICE_CD = "11" --
    AND CONTRACT_TYPE='S'
    and SPECIALTY_CD="LPC"


-- row 4
WITH Standard_zips AS (
    SELECT DISTINCT
        t1.ZIP_CD,
        t1.RATING_SYSTEM_CD AS TIN_RATING_SYSTEM_CD,
        t1.GEOGRAPHIC_AREA_CD AS tin_GEOGRAPHIC_AREA_CD,
        t3.GEOGRAPHIC_AREA_CD,
        t3.OVERRIDE_RATE_SYSTEM_CD
    FROM `prv_ps_ce_hcb_dev.CET_EPDB_TAX_IDENTIFICATION_NUMBER_ADDRESS_DETAIL_VIEW` t1
    LEFT JOIN `prv_ps_ce_hcb_dev.CET_EPDB_CONTRACT_PROVIDER_BUSINESS_GROUP_VIEW` t2
      ON t1.provider_identification_nbr = t2.provider_identification_nbr
     AND t1.tax_identification_nbr     = t2.tax_identification_nbr
     AND t1.service_location_nbr       = t2.service_location_nbr
     AND t1.network_id                 = t2.network_id
    LEFT JOIN `prv_ps_ce_hcb_dev.CET_SCSR_RATE_OVERRIDE_VIEW` t3
      ON t1.ZIP_CD          = t3.GEOGRAPHIC_AREA_CD
     AND t1.RATING_SYSTEM_CD = t3.RATE_SYSTEM_CD
    WHERE t2.provider_business_group_nbr IS NULL
      AND t1.ZIP_CD = '89106'
      AND (t3.OVERRIDE_RATE_SYSTEM_CD = '' OR t3.OVERRIDE_RATE_SYSTEM_CD IS NULL)  -- TIN path only
)

SELECT DISTINCT
    t4.RATE_SYSTEM_CD,
    t4.SERVICE_CD,
    t4.SERVICE_TYPE_CD,
    sp.tin_GEOGRAPHIC_AREA_CD AS GEOGRAPHIC_AREA_CD,
    t4.SPECIALTY_CD,
    t4.SPECIALTY_TYPE_CD,
    CAST(t4.RATE_AMT AS FLOAT64) AS RATE
FROM Standard_zips sp
JOIN `prv_ps_ce_hcb_dev.CET_SCSR_RATE_DETAIL_VIEW` t4
  ON t4.RATE_SYSTEM_CD     = sp.TIN_RATING_SYSTEM_CD
 AND t4.GEOGRAPHIC_AREA_CD = sp.tin_GEOGRAPHIC_AREA_CD
JOIN `prv_ps_ce_hcb_dev.CET_SCSR_DIFFERENTIATION_CRITERIA_VIEW` tsdc
  ON tsdc.differentiation_criteria_id = t4.differentiation_criteria_id
JOIN `prv_ps_ce_dec_hcb_dev.service_code_master` scm
  ON TRIM(scm.primary_svc_cd) = t4.SERVICE_CD
WHERE t4.EXTENSION_CD = ''
  AND scm.in_scope_ind = 1
  AND scm.trmn_dt > CURRENT_DATE()
  AND scm.primary_svc_cd = '90837'       -- focus on psychotherapy
ORDER BY RATE DESC;


SELECT max(rate) as rate
FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
WHERE
    RATE_SYSTEM_CD = "REF"
    AND SERVICE_CD = "90837" --
    AND SERVICE_TYPE_CD = "CPT4" --
    AND GEOGRAPHIC_AREA_CD = "NV01"
    AND PLACE_OF_SERVICE_CD = "11" --
    AND CONTRACT_TYPE='S'
    and SPECIALTY_CD="SW"



-- row 5
WITH Standard_zips AS (
    SELECT DISTINCT
        t1.ZIP_CD,
        t1.RATING_SYSTEM_CD AS TIN_RATING_SYSTEM_CD,
        t1.GEOGRAPHIC_AREA_CD AS tin_GEOGRAPHIC_AREA_CD,
        t3.GEOGRAPHIC_AREA_CD,
        t3.OVERRIDE_RATE_SYSTEM_CD
    FROM `prv_ps_ce_hcb_dev.CET_EPDB_TAX_IDENTIFICATION_NUMBER_ADDRESS_DETAIL_VIEW` t1
    LEFT JOIN `prv_ps_ce_hcb_dev.CET_EPDB_CONTRACT_PROVIDER_BUSINESS_GROUP_VIEW` t2
      ON t1.provider_identification_nbr = t2.provider_identification_nbr
     AND t1.tax_identification_nbr     = t2.tax_identification_nbr
     AND t1.service_location_nbr       = t2.service_location_nbr
     AND t1.network_id                 = t2.network_id
    LEFT JOIN `prv_ps_ce_hcb_dev.CET_SCSR_RATE_OVERRIDE_VIEW` t3
      ON t1.ZIP_CD          = t3.GEOGRAPHIC_AREA_CD
     AND t1.RATING_SYSTEM_CD = t3.RATE_SYSTEM_CD
    WHERE t2.provider_business_group_nbr IS NULL
      AND t1.ZIP_CD = '67230'
      AND (t3.OVERRIDE_RATE_SYSTEM_CD = '' OR t3.OVERRIDE_RATE_SYSTEM_CD IS NULL)  -- TIN path only
)

SELECT DISTINCT
    t4.RATE_SYSTEM_CD,
    t4.SERVICE_CD,
    t4.SERVICE_TYPE_CD,
    sp.tin_GEOGRAPHIC_AREA_CD AS GEOGRAPHIC_AREA_CD,
    t4.SPECIALTY_CD,
    t4.SPECIALTY_TYPE_CD,
    CAST(t4.RATE_AMT AS FLOAT64) AS RATE
FROM Standard_zips sp
JOIN `prv_ps_ce_hcb_dev.CET_SCSR_RATE_DETAIL_VIEW` t4
  ON t4.RATE_SYSTEM_CD     = sp.TIN_RATING_SYSTEM_CD
 AND t4.GEOGRAPHIC_AREA_CD = sp.tin_GEOGRAPHIC_AREA_CD
JOIN `prv_ps_ce_hcb_dev.CET_SCSR_DIFFERENTIATION_CRITERIA_VIEW` tsdc
  ON tsdc.differentiation_criteria_id = t4.differentiation_criteria_id
JOIN `prv_ps_ce_dec_hcb_dev.service_code_master` scm
  ON TRIM(scm.primary_svc_cd) = t4.SERVICE_CD
WHERE t4.EXTENSION_CD = ''
  AND scm.in_scope_ind = 1
  AND scm.trmn_dt > CURRENT_DATE()
  AND scm.primary_svc_cd = '90837'       -- focus on psychotherapy
ORDER BY RATE DESC;


SELECT max(rate) as rate
FROM `prv_ps_ce_dec_hcb_dev.CET_RATES`
WHERE
    RATE_SYSTEM_CD = "REF"
    AND SERVICE_CD = "90837" --
    AND SERVICE_TYPE_CD = "CPT4" --
    AND GEOGRAPHIC_AREA_CD = "KS02"
    AND PLACE_OF_SERVICE_CD = "11" --
    AND CONTRACT_TYPE='S'
    and SPECIALTY_CD="MT"

