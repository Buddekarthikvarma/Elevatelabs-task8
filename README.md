

# 📦 Stored Procedures and Functions – SQL Reusability Project

## 🎯 Objective
Enhance your understanding of reusable SQL code blocks by creating and implementing **Stored Procedures** and **User-Defined Functions (UDFs)** using either MySQL Workbench or DB Browser for SQLite.

---

## 🛠️ Tools Used
- **MySQL Workbench** (preferred for stored procedures and functions)
- **DB Browser for SQLite** (limited support for procedures/functions)

---

## 📌 Deliverables
- ✅ **At least one stored procedure**  
- ✅ **At least one user-defined function**
- ✅ Clear test cases demonstrating both

---

## 📋 Example Snippets

### 🔁 Stored Procedure (MySQL)
```sql
DELIMITER //
CREATE PROCEDURE GetUserSpending (IN userId INT)
BEGIN
  SELECT category, SUM(amount) AS total_spent
  FROM transactions
  WHERE user_id = userId
  GROUP BY category;
END //
DELIMITER ;

CREATE FUNCTION ConvertToUSD(amount DECIMAL(10,2), rate DECIMAL(10,4))
RETURNS DECIMAL(10,2)
DETERMINISTIC
RETURN amount * rate;
