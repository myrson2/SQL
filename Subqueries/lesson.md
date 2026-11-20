# Title: Subqueries in MySQL

---

## Definitions:

A **subquery** (also referred to as an *inner query*, *nested query*, or *sub-SELECT*) is a `SELECT` statement embedded inside another SQL statement (such as `SELECT`, `INSERT`, `UPDATE`, `DELETE`, or `SET`). The containing statement is referred to as the **outer query** (or *parent query*).

### 1. Classification by Output Structure

* **Scalar Subquery**: Returns exactly **one row and one column** (a single literal value). It can be used anywhere a single value or expression is valid (e.g., comparison operators like `=`, `>`, `<`).
* **Column / Multi-Row Subquery**: Returns **multiple rows of a single column**. Commonly evaluated with set operators such as `IN`, `NOT IN`, `ANY` / `SOME`, or `ALL`.
* **Row Subquery**: Returns **a single row with multiple columns** (evaluated in MySQL using row constructors: `(col1, col2) = (SELECT ...)`.
* **Table Subquery / Derived Table**: Returns **multiple rows and multiple columns**. Placed in the `FROM` clause and acts as a temporary inline view. **In MySQL, every derived table MUST have an alias.**

### 2. Classification by Dependency

* **Non-Correlated (Independent) Subquery**: The inner query does not reference any columns from the outer query. MySQL evaluates the subquery once, and its result is reused by the outer query.
* **Correlated Subquery**: The inner query references one or more columns from the outer query (e.g., `WHERE inner.id = outer.id`). The subquery depends on the outer row and is conceptually evaluated once for each candidate row processed by the outer query.

### 3. Classification by SQL Clause

* **In `WHERE` Clause**: Filters outer rows based on inner calculation results or existence checks (`IN`, `EXISTS`).
* **In `FROM` Clause**: Serves as a derived table / inline virtual table.
* **In `SELECT` Clause**: Evaluates scalar column-level calculations per row.
* **In `HAVING` Clause**: Filters aggregated groups using subquery comparisons.

---

## Real World Examples:

1. **Academic Performance & Benchmarking (Examinee Analysis)**:
   * Finding all students who scored higher than the national exam average.
   * Identifying examinees whose scores exceed the average score of their specific school (school-level percentile benchmarking).
2. **E-Commerce Inactive User & Cart Abandonment Detection**:
   * Identifying registered customers who have never placed an order (`WHERE NOT EXISTS (...)` or `WHERE customer_id NOT IN (...)`).
   * Flagging accounts whose total lifetime spend is in the top 5% of all customers.
3. **Latest State & Event Tracking**:
   * Retrieving the most recent status update or highest historical test score for each candidate across repeated attempts.
4. **Multi-Stage Reporting & Aggregation of Aggregates**:
   * First calculating total sales per store, then querying the average store sales across regions using a derived table in `FROM`.

---

## Code examples:

The following examples utilize a typical academic examination database (such as the `Examinee` table with columns: `ExamineeID`, `Name`, `School`, `Status`, `Graduated`, `Score`).

### 1. Scalar Subquery in `WHERE` (Above-Average Scorers)
*Filters examinees whose score is strictly greater than the overall class average.*

```sql
SELECT 
    ExamineeID,
    Name,
    School,
    Score
FROM Examinee
WHERE Score > (
    -- Scalar subquery returning a single average score
    SELECT AVG(Score) 
    FROM Examinee
)
ORDER BY Score DESC;
```

---

### 2. Multi-Row Subquery with `IN` (Top-Tier School Candidates)
*Retrieves examinees who attend schools that have produced at least one student scoring 95 or higher.*

```sql
SELECT 
    ExamineeID,
    Name,
    School,
    Score
FROM Examinee
WHERE School IN (
    -- Returns a list of distinct schools meeting the criteria
    SELECT DISTINCT School 
    FROM Examinee 
    WHERE Score >= 95
)
ORDER BY School, Score DESC;
```

---

### 3. Correlated Subquery (Outperforming School Peers)
*Retrieves examinees who scored higher than the average score of **their own school**.*

```sql
SELECT 
    e.ExamineeID,
    e.Name,
    e.School,
    e.Score
FROM Examinee AS e
WHERE e.Score > (
    -- Correlated subquery: references outer row's 'e.School'
    SELECT AVG(sub.Score)
    FROM Examinee AS sub
    WHERE sub.School = e.School
)
ORDER BY e.School, e.Score DESC;
```

---

### 4. Existence Check with `EXISTS` and `NOT EXISTS`
*Retrieves schools that have candidates with an 'IR' (Irregular) status.*

```sql
SELECT DISTINCT 
    e1.School
FROM Examinee AS e1
WHERE EXISTS (
    -- Returns TRUE as soon as a matching record is encountered
    SELECT 1 
    FROM Examinee AS e2
    WHERE e2.School = e1.School 
      AND e2.Status = 'IR'
);
```

*Finding examinees who do not have any repeated or duplicate records under the same contact number:*

```sql
SELECT 
    e1.ExamineeID, 
    e1.Name, 
    e1.ContactNo
FROM Examinee AS e1
WHERE NOT EXISTS (
    SELECT 1 
    FROM Examinee AS e2
    WHERE e2.ContactNo = e1.ContactNo 
      AND e2.ExamineeID <> e1.ExamineeID
);
```

---

### 5. Subquery in `FROM` Clause (Derived Table / Aggregate of Aggregates)
*Finds the average and maximum of school average scores.*
*(Note: MySQL requires an alias `school_stats` for every derived table).*

```sql
SELECT 
    ROUND(AVG(school_stats.avg_score), 2) AS overall_school_mean,
    MAX(school_stats.avg_score)           AS highest_school_mean
FROM (
    -- Derived Table: must have an explicit alias in MySQL
    SELECT 
        School, 
        AVG(Score) AS avg_score,
        COUNT(*)   AS student_count
    FROM Examinee
    GROUP BY School
) AS school_stats;
```

---

### 6. Scalar Subquery in `SELECT` (Side-by-Side Context)
*Displays each student's score alongside the overall highest score and their deviation from it.*

```sql
SELECT 
    Name,
    School,
    Score,
    (SELECT MAX(Score) FROM Examinee) AS highest_exam_score,
    (SELECT MAX(Score) FROM Examinee) - Score AS points_below_top
FROM Examinee
ORDER BY Score DESC;
```

---

## FInal Verdict:

Subqueries are an essential, intuitive SQL tool that allow developers to break down multi-step logic into self-contained building blocks. However, in production MySQL database administration and software engineering, they must be used judiciously:

1. **Readability vs. Complexity**:
   * **Strength**: Independent scalar subqueries and `WHERE col IN (SELECT ...)` are readable and easy to construct during exploratory data analysis.
   * **Pitfall**: Deeply nested subqueries (subqueries within subqueries) rapidly degrade into "SQL spaghetti," making queries difficult to debug and maintain.

2. **Performance in MySQL**:
   * **Correlated Subqueries**: Because correlated subqueries can trigger row-by-row re-evaluation (`O(N * M)` cost), they can create severe CPU and I/O bottlenecks on large datasets without appropriate indexing.
   * **`NOT IN` with NULLs**: If the inner query of a `NOT IN` returns even a single `NULL` value, MySQL evaluates the entire condition to `UNKNOWN`/`FALSE`, returning zero rows. Prefer `NOT EXISTS` or a `LEFT JOIN ... WHERE right.id IS NULL`, which handle `NULL` safely and allow the optimizer to short-circuit.
   * **Derived Tables in MySQL 5.7 vs 8.0**: Modern MySQL engines (8.0+) employ optimizer transformations like subquery unnesting, semi-join, anti-join, and derived table merging. However, complex derived tables can still result in temporary materialization tables on disk if memory limits are exceeded.

3. **Modern Alternatives (MySQL 8.0+)**:
   * When comparing rows against group aggregates (e.g., student score vs. school average), **Window Functions** (`AVG(Score) OVER(PARTITION BY School)`) generally offer superior performance and cleaner syntax compared to correlated subqueries.
   * When subquery logic needs to be reused or structured hierarchically, refactor into **Common Table Expressions (CTEs)** using the `WITH` clause to boost maintainability and execution clarity.

**Verdict Rule of Thumb:** 
Use subqueries for simple scalar lookups, inline filters, and short-circuit existence checks (`EXISTS`). For high-throughput reporting, large tables, and multi-level data dependencies, prefer **`JOIN`s**, **Window Functions**, or **CTEs**.
