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
