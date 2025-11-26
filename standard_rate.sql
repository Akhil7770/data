--261,648,805 records after joining with {{ce_scm}}

TRUNCATE TABLE `{{ce_project}}.{{ce_dec_dataset}}.{{ce_rates_table}}`;
INSERT INTO `{{ce_project}}.{{ce_dec_dataset}}.{{ce_rates_table}}` (
    
    RATE_SYSTEM_CD,
    SERVICE_CD,
    SERVICE_TYPE_CD,
    SERVICE_GROUP_CD,
    SERVICE_GROUPING_PRIORITY_NBR,
    SERVICE_GROUP_CHANGED_IND,
    PROVIDER_BUSINESS_GROUP_NBR,
    PRODUCT_CD,
    PLACE_OF_SERVICE_CD,
    GEOGRAPHIC_AREA_CD,
    EXTENSION_CD,
    EXTENSION_TYPE,
    SPECIALTY_CD,
    SPECIALTY_TYPE_CD,
    PAYMENT_METHOD_CD,
    RATE,
    CNT_EFFTV_DT,
    CNT_TERMN_DT,
    CONTRACT_TYPE,
    LOGIC_TYPE
)
WITH `Standard_zips` AS (
    SELECT DISTINCT
        t1.ZIP_CD,
        t1.RATING_SYSTEM_CD AS TIN_RATING_SYSTEM_CD,
        t1.GEOGRAPHIC_AREA_CD AS tin_GEOGRAPHIC_AREA_CD,
        t3.GEOGRAPHIC_AREA_CD,
        t3.OVERRIDE_RATE_SYSTEM_CD
    FROM
        {{ce_project}}.{{ce_dataset}}.{{cet_address_detail_view}} AS t1
    LEFT JOIN
        {{ce_project}}.{{ce_dataset}}.{{cet_business_group_view}} AS t2
    ON
        t1.provider_identification_nbr = t2.provider_identification_nbr
        AND t1.tax_identification_nbr = t2.tax_identification_nbr
        AND t1.service_location_nbr = t2.service_location_nbr
        AND t1.network_id = t2.network_id
    LEFT JOIN
        {{ce_project}}.{{ce_dataset}}.{{cet_scsr_rate_override_view}} AS t3
    ON
        t1.ZIP_CD = t3.GEOGRAPHIC_AREA_CD
        AND t1.RATING_SYSTEM_CD = t3.RATE_SYSTEM_CD
    WHERE
        t2.provider_business_group_nbr IS NULL
)
SELECT DISTINCT
    
    t4.RATE_SYSTEM_CD,
    scm.primary_svc_cd as SERVICE_CD,
    t4.SERVICE_TYPE_CD,
    '' AS SERVICE_GROUP_CD,
    '' AS SERVICE_GROUPING_PRIORITY_NBR,
    '' AS SERVICE_GROUP_CHANGED_IND,
    NULL AS PROVIDER_BUSINESS_GROUP_NBR,
    tsdc.PRODUCT_CD,
    trim(scm.supporting_pos_cd) AS PLACE_OF_SERVICE_CD,
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
FROM
    Standard_zips sp
JOIN
    {{ce_project}}.{{ce_dataset}}.{{cet_scsr_rate_detail_view}} t4
ON
    t4.RATE_SYSTEM_CD = sp.OVERRIDE_RATE_SYSTEM_CD
    AND t4.GEOGRAPHIC_AREA_CD = 'NONE'
JOIN
    {{ce_project}}.{{ce_dataset}}.{{cet_scsr_differentiation_criteria_view}} tsdc
ON
    tsdc.differentiation_criteria_id = t4.differentiation_criteria_id
JOIN
    {{ce_project}}.{{ce_dec_dataset}}.{{ce_scm}} scm
ON
    trim(scm.primary_svc_cd) = t4.SERVICE_CD
WHERE
    (sp.OVERRIDE_RATE_SYSTEM_CD != '' OR sp.OVERRIDE_RATE_SYSTEM_CD IS NOT NULL)
    AND t4.EXTENSION_CD = ''
    AND scm.in_scope_ind = 1
    AND scm.trmn_dt > CURRENT_DATE()

UNION ALL

SELECT DISTINCT
    
    t4.RATE_SYSTEM_CD,
    scm.primary_svc_cd as SERVICE_CD,
    t4.SERVICE_TYPE_CD,
    '' AS SERVICE_GROUP_CD,
    '' AS SERVICE_GROUPING_PRIORITY_NBR,
    '' AS SERVICE_GROUP_CHANGED_IND,
    NULL AS PROVIDER_BUSINESS_GROUP_NBR,
    tsdc.PRODUCT_CD,
    trim(scm.supporting_pos_cd) AS PLACE_OF_SERVICE_CD,
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
FROM
    Standard_zips sp
JOIN
    {{ce_project}}.{{ce_dataset}}.{{cet_scsr_rate_detail_view}} t4
ON
    t4.RATE_SYSTEM_CD = sp.TIN_RATING_SYSTEM_CD
    AND t4.GEOGRAPHIC_AREA_CD = sp.tin_GEOGRAPHIC_AREA_CD
JOIN
    {{ce_project}}.{{ce_dataset}}.{{cet_scsr_differentiation_criteria_view}} tsdc
ON
    tsdc.differentiation_criteria_id = t4.differentiation_criteria_id
JOIN
    {{ce_project}}.{{ce_dec_dataset}}.{{ce_scm}} scm
ON
    trim(scm.primary_svc_cd) = t4.SERVICE_CD
WHERE
    (sp.OVERRIDE_RATE_SYSTEM_CD = '' OR sp.OVERRIDE_RATE_SYSTEM_CD IS NULL)
    AND t4.EXTENSION_CD = ''
    AND scm.in_scope_ind = 1
    AND scm.trmn_dt > CURRENT_DATE()
