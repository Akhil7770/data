WITH `Standard_zips` AS (
    SELECT DISTINCT
        t1.ZIP_CD,
        t1.RATING_SYSTEM_CD AS TIN_RATING_SYSTEM_CD,
        t1.GEOGRAPHIC_AREA_CD AS tin_GEOGRAPHIC_AREA_CD,
        t3.GEOGRAPHIC_AREA_CD,
        t3.OVERRIDE_RATE_SYSTEM_CD
    FROM `prv_ps_ce_hcb_dev.CET_EPDB_TAX_IDENTIFICATION_NUMBER_ADDRESS_DETAIL_VIEW` t1
    LEFT JOIN `prv_ps_ce_hcb_dev.CET_EPDB_CONTRACT_PROVIDER_BUSINESS_GROUP_VIEW` t2
    ON
        t1.provider_identification_nbr = t2.provider_identification_nbr
        AND t1.tax_identification_nbr = t2.tax_identification_nbr
        AND t1.service_location_nbr = t2.service_location_nbr
        AND t1.network_id = t2.network_id
      LEFT JOIN `prv_ps_ce_hcb_dev.CET_SCSR_RATE_OVERRIDE_VIEW` t3
    ON
        t1.ZIP_CD = t3.GEOGRAPHIC_AREA_CD
        AND t1.RATING_SYSTEM_CD = t3.RATE_SYSTEM_CD
    WHERE
        t2.provider_business_group_nbr IS NULL
        ANd t1.ZIP_CD='77079'
    --     AND t1.ZIP_CD IN (
    --     '77079', '99686', '72015', '89106', '67230', '84041', '08753', '43065', '43023', '60618',
    --     '28078', '84790', '32901', '60435', '11758', '60091', '33467', '60416', '84043', '61350',
    --     '67212', '08043', '39157', '19512', '44145', '82930'
    -- )
)

-- select * from Standard_zips
SELECT DISTINCT
    
    t4.RATE_SYSTEM_CD,
    -- scm.primary_svc_cd as SERVICE_CD,
    t4.SERVICE_TYPE_CD,
    '' AS SERVICE_GROUP_CD,
    '' AS SERVICE_GROUPING_PRIORITY_NBR,
    '' AS SERVICE_GROUP_CHANGED_IND,
    NULL AS PROVIDER_BUSINESS_GROUP_NBR,
    -- tsdc.PRODUCT_CD,
    -- trim(scm.supporting_pos_cd) AS PLACE_OF_SERVICE_CD,
    sp.tin_GEOGRAPHIC_AREA_CD AS GEOGRAPHIC_AREA_CD,
    t4.EXTENSION_CD,
    t4.EXTENSION_TYPE_CD,
    t4.SPECIALTY_CD,
    t4.SPECIALTY_TYPE_CD,
    '' AS PAYMENT_METHOD_CD,
    cast(t4.RATE_AMT as float64) as RATE,
    '' AS CNT_EFFTV_DT,
    '' AS CNT_TERMN_DT,
    'S' AS CONTRACT_TYPE,
    'STANDARD' AS LOGIC_TYPE
FROM Standard_zips sp
JOIN `prv_ps_ce_hcb_dev.CET_SCSR_RATE_DETAIL_VIEW` t4
  ON t4.RATE_SYSTEM_CD = sp.TIN_RATING_SYSTEM_CD
  AND t4.GEOGRAPHIC_AREA_CD = sp.tin_GEOGRAPHIC_AREA_CD
JOIN `prv_ps_ce_hcb_dev.CET_SCSR_DIFFERENTIATION_CRITERIA_VIEW` tsdc
  ON tsdc.differentiation_criteria_id = t4.differentiation_criteria_id
JOIN `prv_ps_ce_dec_hcb_dev.service_code_master` scm
  ON trim(scm.primary_svc_cd) = t4.SERVICE_CD
WHERE
    (sp.OVERRIDE_RATE_SYSTEM_CD = '' OR sp.OVERRIDE_RATE_SYSTEM_CD IS NULL)
    AND t4.EXTENSION_CD = ''
    AND scm.in_scope_ind = 1
    AND scm.trmn_dt > CURRENT_DATE()
    AND CAST(t4.RATE_AMT AS FLOAT64)=152.01
