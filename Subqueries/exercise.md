# Exercise: MySQL Subqueries Practice

> **Session Dates:** 24 Oct 2026 & 31 Oct 2026  
> **Topic:** Subqueries (Scalar, Multi-row with `IN`, Derived Tables, and `OFFSET`)  
> **Dataset:** [`Examinee.csv`](Examinee.csv)  
> **Target Table:** `Examinee`

---

## Dataset Overview

The queries in this practice session run against the `Examinee` table:

| Column | Type | Description |
| :--- | :--- | :--- |
| `ExamineeID` | `INT` | Unique identifier for each examinee |
| `Name` | `VARCHAR(100)` | Full name of the candidate |
| `School` | `VARCHAR(50)` | School or university attended |
| `Status` | `VARCHAR(10)` | Candidate status (`IR` = Irregular, `R` = Regular) |
| `ContactNo` | `VARCHAR(20)` | Contact phone number |
| `Address` | `VARCHAR(255)` | Candidate residential address |
| `Graduated` | `INT` | Graduation year |
| `Score` | `INT` | Examination test score |

---

## Practice Problems

### Problem 1: Top 5 Performers Above Class Average
**Task:**  
List the `Name`, `School`, and `Score` of the first 5 examinees who scored strictly higher than the overall average score across all examinees. Order the results by `Score` descending, then by `Name` ascending.

* **Subquery Focus:** Scalar subquery in the `WHERE` clause using an aggregate function (`AVG()`).
* **Expected Columns:** `Name`, `School`, `Score`
* **Hint:** Compute the class average inside `WHERE Score > (SELECT AVG(...) FROM Examinee)`.

<details>
<summary>💡 View Solution Query</summary>

```sql
SELECT 
    Name, 
    School, 
    Score
FROM Examinee
WHERE Score > (
    SELECT AVG(Score) 
    FROM Examinee
)
ORDER BY Score DESC, Name ASC
LIMIT 5;
```
</details>

---

### Problem 2: Lowest Performers in Manila
**Task:**  
List the `Name`, `School`, `Address`, and `Score` of the examinees residing in Manila who obtained the 3 lowest scores among Manila residents. Order the results by `Score` ascending.

* **Subquery Focus:** Filtering text patterns (`LIKE '%Manila%'`) combined with subquery-based score thresholds or rank filtering.
* **Expected Columns:** `Name`, `School`, `Address`, `Score`
* **Hint:** Ensure address matching captures variations (e.g., `'Sampaloc Manila'`, `'Tondo, Manila'`).

<details>
<summary>💡 View Solution Query</summary>

```sql
SELECT 
    Name, 
    School, 
    Address, 
    Score
FROM Examinee
WHERE Address LIKE '%Manila%'
ORDER BY Score ASC
LIMIT 3;
```

*Alternative using subquery to handle score ties:*
```sql
SELECT 
    Name, 
    School, 
    Address, 
    Score
FROM Examinee
WHERE Address LIKE '%Manila%'
  AND Score IN (
      SELECT Score FROM (
          SELECT DISTINCT Score 
          FROM Examinee 
          WHERE Address LIKE '%Manila%'
          ORDER BY Score ASC 
          LIMIT 3
      ) AS lowest_scores
  )
ORDER BY Score ASC, Name ASC;
```
</details>

---

### Problem 3: Distinct Schools in the Top 3 Score Tiers
**Task:**  
Find how many distinct schools produced examinees whose scores belong to the **top 3 highest scores** (the top 3 distinct score values: 97, 95, and 93).

* **Subquery Focus:** Multi-row subquery using `IN` with a derived table, or an inline `SELECT COUNT(DISTINCT ...)`.
* **Expected Output:** A single scalar count (e.g. `total_top_schools`).
* **Note on MySQL:** In MySQL, when applying `LIMIT` inside an `IN (...)` subquery, you must wrap the inner query in a derived table alias: `FROM (SELECT DISTINCT Score ... LIMIT 3) AS t`.

<details>
<summary>💡 View Solution Query</summary>

```sql
SELECT 
    COUNT(DISTINCT School) AS total_top_schools
FROM Examinee
WHERE Score IN (
    SELECT Score FROM (
        SELECT DISTINCT Score 
        FROM Examinee 
        ORDER BY Score DESC 
        LIMIT 3
    ) AS top_3_scores
);
```
</details>

---

### Problem 4: Students per School in Top 3 Score Tiers
**Task:**  
Count the number of examinees per school who made it into the top 3 highest distinct score tiers. Display the `School` and the count (`top_students_count`), ordered by the count in descending order, then by school name alphabetically.

* **Subquery Focus:** `WHERE ... IN (subquery)` combined with `GROUP BY` and `ORDER BY`.
* **Expected Columns:** `School`, `top_students_count`
* **Example Target:** `UP: 2`, `PUP: 1`, `BSU: 1`, `FEU: 1`, `ADMU: 1`

<details>
<summary>💡 View Solution Query</summary>

```sql
SELECT 
    School, 
    COUNT(*) AS top_students_count
FROM Examinee
WHERE Score IN (
    SELECT Score FROM (
        SELECT DISTINCT Score 
        FROM Examinee 
        ORDER BY Score DESC 
        LIMIT 3
    ) AS top_scores
)
GROUP BY School
ORDER BY top_students_count DESC, School ASC;
```
</details>

---

### Problem 5: Examinees with the 3rd Highest Score (Ties Handled)
**Task:**  
Retrieve all examinees who achieved the **exact 3rd highest unique score** in the dataset.  
*(Make sure to research and use `LIMIT 1 OFFSET 2` inside a subquery so that if multiple candidates are tied for the 3rd highest score, all of them are returned!)*

* **Subquery Focus:** Scalar subquery using `LIMIT` and `OFFSET` to identify an N-th rank value, used in a comparison (`Score = (...)`).
* **Why Subqueries are Required Here:** A simple `LIMIT 1 OFFSET 2` on the outer query would only pick a single arbitrary student (row #3). A subquery isolates the **3rd unique score value** (93) first, allowing the outer query to return every student sharing that score.
* **Expected Columns:** `ExamineeID`, `Name`, `School`, `Score`

<details>
<summary>💡 View Solution Query</summary>

```sql
SELECT 
    ExamineeID,
    Name, 
    School, 
    Score
FROM Examinee
WHERE Score = (
    -- Finds the 3rd unique score by skipping the top 2
    SELECT DISTINCT Score 
    FROM Examinee 
    ORDER BY Score DESC 
    LIMIT 1 OFFSET 2
);
```
</details>

---

## Key Learning Takeaways

1. **Handling Ties in Ranking:**
   * Never rely on outer `LIMIT 1 OFFSET (N-1)` when looking for the N-th highest performer; multiple rows can share identical values. Isolate the target value inside a subquery, then match on it in the outer query.
2. **MySQL Derived Table Requirement with `LIMIT` inside `IN`:**
   * MySQL versions prior to 8.0.22 do not support `WHERE col IN (SELECT ... LIMIT n)` directly without nesting it inside a derived table: `FROM (SELECT ... LIMIT n) AS temp`.
3. **Filtering vs. Aggregating:**
   * Notice the progression from Problem 1 (filtering on an aggregate), to Problems 3 & 4 (filtering groups on top tiers), to Problem 5 (pinpointing an exact rank offset).
