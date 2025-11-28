WITH Standard_zips AS (
    SELECT DISTINCT
        t1.ZIP_CD,
        t1.RATING_SYSTEM_CD AS TIN_RATING_SYSTEM_CD,
        t1.GEOGRAPHIC_AREA_CD AS TIN_GEOGRAPHIC_AREA_CD,
        t3.GEOGRAPHIC_AREA_CD AS OVERRIDE_GEOGRAPHIC_AREA_CD,
        t3.OVERRIDE_RATE_SYSTEM_CD
    FROM {{ce_project}}.{{ce_dataset}}.{{cet_address_detail_view}} t1
    LEFT JOIN {{ce_project}}.{{ce_dataset}}.{{cet_business_group_view}} t2
        ON t1.provider_identification_nbr = t2.provider_identification_nbr
       AND t1.tax_identification_nbr = t2.tax_identification_nbr
       AND t1.service_location_nbr = t2.service_location_nbr
       AND t1.network_id = t2.network_id
    LEFT JOIN {{ce_project}}.{{ce_dataset}}.{{cet_scsr_rate_override_view}} t3
        ON t1.ZIP_CD = t3.GEOGRAPHIC_AREA_CD
       AND t1.RATING_SYSTEM_CD = t3.RATE_SYSTEM_CD
    WHERE t2.provider_business_group_nbr IS NULL
      AND t1.ZIP_CD = '77079'    -- 👈 CHANGE THIS TO YOUR CLAIM ZIP
)

SELECT DISTINCT
    t4.RATE_SYSTEM_CD,
    scm.primary_svc_cd AS SERVICE_CD,
    t4.SERVICE_TYPE_CD,
    tsdc.PRODUCT_CD,
    TRIM(scm.supporting_pos_cd) AS PIPELINE_POS,
    '11' AS CLAIM_POS, -- 👈 IF CLAIM POS IS 11 (your dataset shows this)
    sp.TIN_GEOGRAPHIC_AREA_CD AS PIPELINE_GA,
    t4.GEOGRAPHIC_AREA_CD AS RATE_GA,
    t4.SPECIALTY_CD,
    CAST(t4.RATE_AMT AS FLOAT64) AS RATE
FROM Standard_zips sp
JOIN {{ce_project}}.{{ce_dataset}}.{{cet_scsr_rate_detail_view}} t4
  ON t4.RATE_SYSTEM_CD = sp.OVERRIDE_RATE_SYSTEM_CD
 AND t4.GEOGRAPHIC_AREA_CD = 'NONE'  -- 👈 THIS IS WHY WRONG RATES ARE PICKED
JOIN {{ce_project}}.{{ce_dataset}}.{{cet_scsr_differentiation_criteria_view}} tsdc
  ON tsdc.differentiation_criteria_id = t4.differentiation_criteria_id
JOIN {{ce_project}}.{{ce_dec_dataset}}.{{ce_scm}} scm
  ON TRIM(scm.primary_svc_cd) = t4.SERVICE_CD
WHERE scm.primary_svc_cd = '90837'  -- 👈 CPT we are investigating
  AND t4.EXTENSION_CD = ''
  AND scm.in_scope_ind = 1
ORDER BY RATE DESC;
