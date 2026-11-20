# SQL Learning Journey

> A personal log of my SQL journey — lessons, exercises, datasets, and the thinking behind every query.

This repository is where I collect everything I learn about SQL: the concepts I study, the problems I solve, the datasets I practice on, and the mistakes worth remembering. It is less a portfolio of perfect queries and more a record of how my understanding grows over time.

## What's inside

- **Lessons** — concept notes and worked examples for each topic.
- **Exercises** — practice problems, from warm-ups to tricky ones.
- **Datasets** — the CSV files and sample tables used in each session.
- **Notes** — observations, gotchas, and "aha" moments.

## Repository layout

```text
SQL/
├── README.md
└── Subqueries/
    └── 24OCT2026-Subqueries/
        └── Examinee.csv
```

Each topic gets its own folder, and each study session gets a dated subfolder inside it. This keeps a topic's history together while making it obvious when something was practiced.

### Naming conventions

| Item | Convention | Example |
| --- | --- | --- |
| Topic folder | `PascalCase` | `Subqueries/`, `WindowFunctions/` |
| Session folder | `DDMMMYYYY-Topic` | `24OCT2026-Subqueries/` |
| Lesson notes | `notes.sql` | `notes.sql` |
| Practice problems | `exercises.sql` | `exercises.sql` |
| My answers | `solutions.sql` | `solutions.sql` |
| Datasets | Keep original name | `Examinee.csv` |

A typical session folder will look like this:

```text
Joins/
└── 05DEC2026-Joins/
    ├── notes.sql
    ├── exercises.sql
    ├── solutions.sql
    └── employees.csv
```

## Learning log

| Date | Topic | Folder | What I worked on |
| --- | --- | --- | --- |
| 24 Oct 2026 | Subqueries | [Subqueries/24OCT2026-Subqueries](Subqueries/24OCT2026-Subqueries) | Practiced subqueries against the `Examinee` dataset |

## Datasets

### `Examinee.csv`

A table of exam takers used for subquery practice.

| Column | Description |
| --- | --- |
| `ExamineeID` | Unique ID for each examinee |
| `Name` | Examinee's full name |
| `School` | School the examinee came from |
| `Status` | Status code (e.g., `IR`, `R`) |
| `ContactNo` | Contact number |
| `Address` | Home address |
| `Graduated` | Year graduated |
| `Score` | Exam score |

The data includes repeated names, shared schools, and a mix of scores — useful for scalar subqueries, correlated subqueries, `IN`, `EXISTS`, and comparisons against aggregates.

## Roadmap

Topics I want to cover, in rough order:

- [x] Subqueries
- [ ] Joins
- [ ] Aggregation and `GROUP BY`
- [ ] Common table expressions (CTEs)
- [ ] Window functions
- [ ] Set operations (`UNION`, `INTERSECT`, `EXCEPT`)
- [ ] DDL and schema design
- [ ] DML and transactions
- [ ] Indexes and query performance
- [ ] Views, stored procedures, and functions
- [ ] Triggers
- [ ] A small end-to-end project

## How I add a new session

1. Create the topic folder if it doesn't exist.
2. Add a dated session folder: `Topic/DDMMMYYYY-Topic/`.
3. Drop in the dataset, then write `notes.sql`, `exercises.sql`, and `solutions.sql`.
4. Add a row to the learning log above.
5. Tick off the roadmap when a topic feels solid.

## Note-taking rules

- Write the question before the answer — future me needs the context.
- Comment the *why*, not just the *what*.
- Keep the wrong attempts. They show how the solution was reached.
- Note the SQL dialect when syntax differs between engines.

## Tools

SQL dialect and tools are noted per session when they matter. Datasets are plain CSV so they can be loaded into any database.

---

*Started October 2026. Updated as I learn.*
