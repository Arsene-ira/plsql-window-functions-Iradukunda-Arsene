
-- =========================================================
-- MySQL Window Functions Mastery Project
-- Business: Subscription-based Online Video Platform
-- Script: create schema + sample data + analytic queries
-- =========================================================

-- ---------------------------------------------------------
-- CLEANUP (run if re-running script)
-- ---------------------------------------------------------
DROP TABLE IF EXISTS watch_history;
DROP TABLE IF EXISTS subscriptions;
DROP TABLE IF EXISTS videos;
DROP TABLE IF EXISTS customers;

-- ---------------------------------------------------------
-- 1. CREATE TABLES
-- ---------------------------------------------------------
CREATE TABLE customers (
  customer_id    INT PRIMARY KEY,
  full_name      VARCHAR(100),
  region         VARCHAR(50),
  signup_date    DATE
);

CREATE TABLE videos (
  video_id       INT PRIMARY KEY,
  title          VARCHAR(200),
  category       VARCHAR(50),
  release_date   DATE
);

CREATE TABLE subscriptions (
  sub_id         INT PRIMARY KEY,
  customer_id    INT,
  start_date     DATE,
  end_date       DATE,
  amount         DECIMAL(8,2),
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE watch_history (
  watch_id       INT PRIMARY KEY,
  customer_id    INT,
  video_id       INT,
  watch_date     DATE,
  hours_watched  DECIMAL(5,2),
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
  FOREIGN KEY (video_id) REFERENCES videos(video_id)
);

-- ---------------------------------------------------------
-- 2. INSERT SAMPLE DATA
-- ---------------------------------------------------------
INSERT INTO customers VALUES 
(1001, 'Alice Mwangi', 'East Africa', '2023-03-15'),
(1002, 'John Doe', 'North America', '2024-01-10'),
(1003, 'Fatima Diallo', 'West Africa', '2024-02-20'),
(1004, 'Chen Wei', 'Asia', '2023-11-01'),
(1005, 'Maria Silva', 'South America', '2024-05-05'),
(1006, 'Mohammed Ali', 'Middle East', '2023-12-12'),
(1007, 'Tom Brown', 'North America', '2024-03-02'),
(1008, 'Grace Nshimiyimana', 'East Africa', '2024-06-12'),
(1009, 'Sofia Rossi', 'Europe', '2024-04-01'),
(1010, 'Paul Okoro', 'West Africa', '2024-01-30');

INSERT INTO videos VALUES 
(2001, 'Planet Voices', 'Documentary', '2023-11-01'),
(2002, 'Street Runners', 'Action', '2024-02-15'),
(2003, 'Kitchen Tales', 'Reality', '2024-01-10'),
(2004, 'Code & Coffee', 'Educational', '2023-09-05'),
(2005, 'Love Across Cities', 'Drama', '2024-03-20'),
(2006, 'History Shorts', 'Documentary', '2023-07-01'),
(2007, 'Soccer Legends', 'Sport', '2024-05-15'),
(2008, 'Space Oddity', 'Sci-Fi', '2024-06-01');

INSERT INTO subscriptions VALUES 
(3001, 1001, '2024-01-01', '2024-01-31', 9.99),
(3002, 1002, '2024-01-05', '2024-01-31', 12.99),
(3003, 1003, '2024-01-10', '2024-01-31', 7.99),
(3004, 1004, '2024-02-01', '2024-02-29', 10.99),
(3005, 1001, '2024-02-01', '2024-02-29', 9.99),
(3006, 1005, '2024-02-15', '2024-02-29', 8.99),
(3007, 1006, '2024-03-01', '2024-03-31', 11.99),
(3008, 1007, '2024-03-05', '2024-03-31', 12.99),
(3009, 1008, '2024-04-01', '2024-04-30', 9.99),
(3010, 1009, '2024-04-10', '2024-04-30', 10.99),
(3011, 1010, '2024-05-01', '2024-05-31', 7.99),
(3012, 1002, '2024-05-03', '2024-05-31', 12.99),
(3013, 1003, '2024-06-01', '2024-06-30', 7.99),
(3014, 1004, '2024-06-10', '2024-06-30', 10.99),
(3015, 1001, '2024-07-01', '2024-07-31', 9.99);

INSERT INTO watch_history VALUES 
(4001, 1001, 2001, '2024-01-20', 3.0),
(4002, 1002, 2002, '2024-01-21', 2.5),
(4003, 1003, 2003, '2024-01-22', 1.0),
(4004, 1001, 2004, '2024-02-02', 2.0),
(4005, 1005, 2001, '2024-02-16', 4.0),
(4006, 1006, 2006, '2024-03-05', 1.5),
(4007, 1007, 2002, '2024-03-10', 3.0),
(4008, 1002, 2007, '2024-04-20', 2.0),
(4009, 1008, 2005, '2024-05-14', 2.5),
(4010, 1009, 2004, '2024-04-12', 1.0),
(4011, 1010, 2001, '2024-05-01', 5.0),
(4012, 1003, 2001, '2024-06-03', 3.0),
(4013, 1004, 2008, '2024-06-15', 2.0),
(4014, 1001, 2002, '2024-07-05', 2.5),
(4015, 1002, 2001, '2024-07-10', 3.0);

-- ---------------------------------------------------------
-- 3. Analytic Queries (Debugged)
-- ---------------------------------------------------------

-- 1) Top 5 videos per region per quarter
SELECT *
FROM (
  SELECT c.region,
         CONCAT(YEAR(w.watch_date), '-Q', QUARTER(w.watch_date)) AS quarter,
         w.video_id,
         v.title,
         COUNT(*) AS watch_sessions,
         RANK() OVER (
           PARTITION BY c.region, YEAR(w.watch_date), QUARTER(w.watch_date)
           ORDER BY COUNT(*) DESC
         ) AS video_rank
  FROM watch_history w
  JOIN customers c ON w.customer_id = c.customer_id
  JOIN videos v ON w.video_id = v.video_id
  GROUP BY c.region, w.video_id, v.title, quarter
) AS ranked_videos
WHERE video_rank <= 5
ORDER BY region, quarter, video_rank;

-- 2) Running monthly subscription revenue totals
WITH monthly_revenue AS (
  SELECT DATE_FORMAT(start_date, '%Y-%m') AS ym,
         SUM(amount) AS revenue
  FROM subscriptions
  GROUP BY ym
)
SELECT ym AS month,
       revenue,
       SUM(revenue) OVER (ORDER BY ym) AS running_total
FROM monthly_revenue
ORDER BY ym;

-- 3) Month-over-month growth in subscription revenue
WITH monthly_revenue AS (
  SELECT DATE_FORMAT(start_date, '%Y-%m') AS ym,
         SUM(amount) AS revenue
  FROM subscriptions
  GROUP BY ym
),
lagged AS (
  SELECT ym,
         revenue,
         LAG(revenue) OVER (ORDER BY ym) AS prev_revenue
  FROM monthly_revenue
)
SELECT ym AS month,
       revenue,
       prev_revenue,
       CASE
         WHEN prev_revenue IS NULL OR prev_revenue = 0 THEN NULL
         ELSE ROUND((revenue - prev_revenue) / prev_revenue * 100, 2)
       END AS growth_pct
FROM lagged
ORDER BY ym;

-- 4) Customer quartiles by total watch hours
SELECT customer_id,
       total_hours_watched,
       NTILE(4) OVER (ORDER BY total_hours_watched DESC) AS quartile
FROM (
  SELECT customer_id,
         SUM(hours_watched) AS total_hours_watched
  FROM watch_history
  GROUP BY customer_id
) AS watch_summary
ORDER BY total_hours_watched DESC;

-- 5) 3-month moving average of subscription revenue
WITH monthly_revenue AS (
  SELECT DATE
