# База данных «Контроль домашних заданий»

## Описание
Проект для курсовой работы. База данных для учёта домашних заданий, сданных работ и оценок.

## Таблицы
- Students (ученики)
- Teachers (учителя)
- Subjects (предметы)
- Homeworks (задания)
- Submissions (сданные работы)
- Grades (оценки)

## SQL-скрипты создания таблиц

```sql
CREATE TABLE Students (
    student_id  SERIAL PRIMARY KEY,
    last_name   VARCHAR(50) NOT NULL,
    first_name  VARCHAR(50) NOT NULL,
    class_name  VARCHAR(20) NOT NULL
);

CREATE TABLE Teachers (
    teacher_id  SERIAL PRIMARY KEY,
    last_name   VARCHAR(50) NOT NULL,
    first_name  VARCHAR(50) NOT NULL
);

CREATE TABLE Subjects (
    subject_id  SERIAL PRIMARY KEY,
    name        VARCHAR(100) NOT NULL UNIQUE,
    teacher_id  INTEGER NOT NULL REFERENCES Teachers(teacher_id)
);

CREATE TABLE Homeworks (
    homework_id  SERIAL PRIMARY KEY,
    subject_id   INTEGER NOT NULL REFERENCES Subjects(subject_id),
    teacher_id   INTEGER NOT NULL REFERENCES Teachers(teacher_id),
    description  TEXT NOT NULL,
    issue_date   DATE DEFAULT CURRENT_DATE,
    due_date     DATE NOT NULL
);

CREATE TABLE Submissions (
    submission_id    SERIAL PRIMARY KEY,
    homework_id      INTEGER NOT NULL REFERENCES Homeworks(homework_id),
    student_id       INTEGER NOT NULL REFERENCES Students(student_id),
    submission_date  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    content          TEXT,
    UNIQUE (homework_id, student_id)
);

CREATE TABLE Grades (
    grade_id      SERIAL PRIMARY KEY,
    submission_id INTEGER NOT NULL UNIQUE REFERENCES Submissions(submission_id),
    grade         INTEGER NOT NULL CHECK (grade >= 1 AND grade <= 5),
    teacher_id    INTEGER NOT NULL REFERENCES Teachers(teacher_id),
    graded_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
## ABC-анализ успеваемости учеников

Проведён ABC-анализ учеников по сумме набранных баллов.

### Категории:
- **A** — лучшие 20% учеников
- **B** — средние 30% учеников
- **C** — отстающие 50% учеников

### SQL-скрипт анализа:

```sql
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
