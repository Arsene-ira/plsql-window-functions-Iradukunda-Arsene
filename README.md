# plsql-window-functions-Iradukunda-Arsene

**Course:** Database Development with PL/SQL (INSY 8311)  
**Instructor:** Eric Maniraguha  
**Assignment:** Individual Assignment I — PL/SQL Window Functions (Mastery Project)    

---

##  Business problem (one sentence)
A subscription-based online video platform needs to identify top-performing content by region, measure subscription revenue trends, and segment customers by engagement to improve retention and monetization.


---

## Database schema
Tables:
- `customers(customer_id PK, full_name, region, signup_date)`
- `videos(video_id PK, title, category, release_date)`
- `subscriptions(sub_id PK, customer_id FK, start_date, end_date, amount)`
- `watch_history(watch_id PK, customer_id FK, video_id FK, watch_date, hours_watched)`

##ER diagram:
+-------------+      +---------------+     +-----------------+
|  customers  |1----<| subscriptions |     |  watch_history  |
|-------------|      |---------------|     |-----------------|
| customer_id |      | sub_id (PK)   |     | watch_id (PK)   |
| full_name   |      | customer_id FK|---->| customer_id FK  |
| region      |      | start_date    |     | video_id  FK    |
| signup_date |      | end_date      |     | watch_date      |
+-------------+      | amount        |     | hours_watched   |
                     +---------------+     +-----------------+
                             ^
                             |
                             |
                        +---------+
                        | videos  |
                        |---------|
                        | video_id|
                        | title   |
                        | category|
                        +---------+ 

---

## Success criteria (exactly five measurable goals)
1. Top 5 videos per region/quarter using `RANK()`:
   This ranks videos in each region-quarter by the number of watch sessions. High-ranked videos show which content performs best regionally, so marketing and content acquisition can be prioritized per region.
2. Running monthly subscription revenue totals using `SUM() OVER()`:
   The query shows month-by-month revenue and the cumulative running total. It helps leadership understand how revenue builds over time and spot seasonal or acquisition-driven changes.  
3. Month-over-month subscription revenue growth using `LAG()` / `LEAD()`:
   Using LAG gives the prior month’s revenue to compute percentage growth. This highlights accelerating or decelerating subscription momentum and flags months that need attention.  
4. Customer quartiles by total watch hours using `NTILE(4)`:
   Customers are segmented into four groups by watch hours; quartile 1 are top watchers. Useful to target retention campaigns at light watchers and rewards for heavy watchers. 
5. 3-month moving average of subscription revenue using `AVG() OVER()`:
   The 3-month moving average smooths short-term volatility to show the underlying revenue trend. This helps when deciding if a change is a blip or a persistent trend.  

---
---

## Results analysis
### Descriptive
- Top videos differ by region; documentaries and local dramas perform strongly in East and West Africa while action and documentaries lead in North America in our sample. Monthly revenue shows steady growth from Jan–May with slight flattening in Jun–Jul.

### Diagnostic (why)
- Regional preferences explain top video differences; localized content and time-zone release scheduling drive engagement. Revenue dips align with months where fewer new signups were recorded in the sample data.

### Prescriptive (what next)
- Invest in proven regional categories and local originals. Stagger new releases across months to reduce subscription churn right after bingeable releases. Target low-quartile viewers with free-trial content and personalized recommendations to increase engagement.

---

## 8. References
- https://www.youtube.com/watch?v=rIcB4zMYMas
- https://www.youtube.com/watch?v=7NBt0V8ebGk
- https://www.youtube.com/watch?v=nHEEyX_yDvo
- https://www.youtube.com/watch?v=Ww71knvhQ-s
- https://www.youtube.com/watch?v=cXhv4kmIzFw
- https://docs.oracle.com/en/database/oracle/oracle-database/19/lnpls/database-pl-sql-language-reference.pdf
- https://www.geeksforgeeks.org/plsql/pl-sql-tutorial/
- https://dev.mysql.com/doc/refman/8.4/en/window-functions.html
- https://www.freecodecamp.org/news/window-functions-in-sql/
- https://mode.com/sql-tutorial/sql-window-functions
