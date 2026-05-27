-- ABC-анализ учеников по сумме баллов

WITH student_scores AS (
    SELECT 
        s.student_id,
        s.last_name,
        s.first_name,
        s.class_name,
        COALESCE(SUM(g.grade), 0) AS total_score
    FROM Students s
    LEFT JOIN Submissions sub ON s.student_id = sub.student_id
    LEFT JOIN Grades g ON sub.submission_id = g.submission_id
    GROUP BY s.student_id
),

total_sum AS (
    SELECT SUM(total_score) AS grand_total FROM student_scores
),

ranked AS (
    SELECT 
        student_id,
        last_name,
        first_name,
        class_name,
        total_score,
        ROW_NUMBER() OVER (ORDER BY total_score DESC) AS rn,
        COUNT(*) OVER () AS total_students
    FROM student_scores
)

SELECT 
    student_id,
    last_name,
    first_name,
    class_name,
    total_score,
    CASE 
        WHEN rn <= ROUND(total_students * 0.2, 0) THEN 'A'
        WHEN rn <= ROUND(total_students * 0.5, 0) THEN 'B'
        ELSE 'C'
    END AS abc_category
FROM ranked
ORDER BY total_score DESC;
