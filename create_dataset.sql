CREATE VIEW risk_mart AS
SELECT
    loan_grade,
    loan_intent,
    total_loans,
    total_portfolio,
    default_count,
    default_amount,
    ROUND((CAST(default_count AS FLOAT) / total_loans) * 100, 2) AS default_rate_pct,
    SUM(total_portfolio) OVER (ORDER BY loan_grade DESC) AS cumulative_portfolio,
    RANK() OVER (PARTITION BY loan_grade ORDER BY default_count DESC) AS risk_rank
FROM (
    SELECT
        loan_grade,
        loan_intent,
        COUNT(*) AS total_loans,
        SUM(loan_amnt) AS total_portfolio,
        SUM(CASE WHEN loan_status = 1 THEN 1 ELSE 0 END) AS default_count,
        SUM(CASE WHEN loan_status = 1 THEN loan_amnt ELSE 0 END) AS default_amount
    FROM loans
    GROUP BY loan_grade, loan_intent
) AS base_stats;
SELECT * FROM risk_mart;
