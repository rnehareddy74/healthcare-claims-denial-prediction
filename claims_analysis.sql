-- ============================================================
-- Healthcare Claim Denial Prediction — SQL Analysis
-- Table: healthcare_claims
-- ============================================================

-- Q1. Overall denial rate and financial exposure
SELECT
    COUNT(*)                                                      AS total_claims,
    SUM(is_denied)                                                AS denied_claims,
    ROUND(AVG(is_denied) * 100, 2)                                AS denial_rate_pct,
    ROUND(SUM(billed_amount) / 1000000.0, 1)                      AS total_billed_M,
    ROUND(SUM(CASE WHEN is_denied = 1
              THEN billed_amount ELSE 0 END) / 1000000.0, 1)      AS denied_value_M
FROM healthcare_claims;


-- Q2. Denial rate by payer
SELECT
    payer,
    COUNT(*)                                                      AS total_claims,
    SUM(is_denied)                                                AS denied_claims,
    ROUND(AVG(is_denied) * 100, 2)                                AS denial_rate_pct,
    ROUND(SUM(CASE WHEN is_denied = 1
              THEN billed_amount ELSE 0 END) / 1000000.0, 2)      AS denied_value_M
FROM healthcare_claims
GROUP BY payer
ORDER BY denial_rate_pct DESC;


-- Q3. Denial rate by claim type
SELECT
    claim_type,
    COUNT(*)                            AS total_claims,
    SUM(is_denied)                      AS denied_claims,
    ROUND(AVG(is_denied) * 100, 2)      AS denial_rate_pct,
    ROUND(AVG(billed_amount), 0)        AS avg_billed
FROM healthcare_claims
GROUP BY claim_type
ORDER BY denial_rate_pct DESC;


-- Q4. Denial rate by diagnosis group
SELECT
    diagnosis_group,
    COUNT(*)                            AS total_claims,
    SUM(is_denied)                      AS denied_claims,
    ROUND(AVG(is_denied) * 100, 2)      AS denial_rate_pct,
    ROUND(AVG(billed_amount), 0)        AS avg_billed,
    ROUND(AVG(paid_amount), 0)          AS avg_paid
FROM healthcare_claims
GROUP BY diagnosis_group
ORDER BY denial_rate_pct DESC;


-- Q5. Top denial reasons by volume and revenue impact
SELECT
    denial_reason,
    COUNT(*)                                          AS denied_claims,
    ROUND(COUNT(*) * 100.0 /
          SUM(COUNT(*)) OVER (), 1)                   AS pct_of_denials,
    ROUND(SUM(billed_amount) / 1000000.0, 2)          AS denied_value_M,
    ROUND(AVG(billed_amount), 0)                      AS avg_billed_per_denial
FROM healthcare_claims
WHERE is_denied = 1
  AND denial_reason IS NOT NULL
GROUP BY denial_reason
ORDER BY denied_claims DESC;


-- Q6. Payer x diagnosis — highest-risk combinations
SELECT
    payer,
    diagnosis_group,
    COUNT(*)                            AS total_claims,
    SUM(is_denied)                      AS denied_claims,
    ROUND(AVG(is_denied) * 100, 2)      AS denial_rate_pct,
    ROUND(AVG(billed_amount), 0)        AS avg_billed
FROM healthcare_claims
GROUP BY payer, diagnosis_group
HAVING COUNT(*) >= 50
ORDER BY denial_rate_pct DESC
LIMIT 15;


-- Q7. Denial rate by patient age group
SELECT
    CASE
        WHEN patient_age BETWEEN 0  AND 18  THEN '0-18'
        WHEN patient_age BETWEEN 19 AND 35  THEN '19-35'
        WHEN patient_age BETWEEN 36 AND 50  THEN '36-50'
        WHEN patient_age BETWEEN 51 AND 65  THEN '51-65'
        ELSE '65+'
    END                                     AS age_group,
    COUNT(*)                                AS total_claims,
    ROUND(AVG(is_denied) * 100, 2)          AS denial_rate_pct,
    ROUND(AVG(billed_amount), 0)            AS avg_billed,
    ROUND(AVG(paid_amount), 0)              AS avg_paid,
    ROUND(AVG(los), 2)                      AS avg_los,
    ROUND(AVG(is_readmission) * 100, 2)     AS readmission_rate_pct
FROM healthcare_claims
GROUP BY age_group
ORDER BY age_group;


-- Q8. Processing time by payer (equity check)
SELECT
    payer,
    ROUND(AVG(processing_days), 1)      AS avg_processing_days,
    MIN(processing_days)                AS min_days,
    MAX(processing_days)                AS max_days,
    COUNT(*)                            AS total_claims
FROM healthcare_claims
GROUP BY payer
ORDER BY avg_processing_days DESC;


-- Q9. Provider risk ranking by denial rate (min 50 claims)
SELECT
    provider_id,
    COUNT(*)                            AS total_claims,
    SUM(is_denied)                      AS denied_claims,
    ROUND(AVG(is_denied) * 100, 2)      AS denial_rate_pct,
    ROUND(AVG(billed_amount), 0)        AS avg_billed,
    ROUND(AVG(processing_days), 1)      AS avg_processing_days
FROM healthcare_claims
GROUP BY provider_id
HAVING COUNT(*) >= 50
ORDER BY denial_rate_pct DESC
LIMIT 20;


-- Q10. State-level denial performance
SELECT
    state,
    COUNT(*)                            AS total_claims,
    ROUND(AVG(is_denied) * 100, 2)      AS denial_rate_pct,
    ROUND(AVG(billed_amount), 0)        AS avg_billed,
    ROUND(AVG(processing_days), 1)      AS avg_processing_days
FROM healthcare_claims
GROUP BY state
ORDER BY denial_rate_pct DESC;
