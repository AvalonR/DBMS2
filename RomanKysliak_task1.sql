USE CRA;
GO

-- 1. Number of records in the City table
SELECT COUNT(*) FROM City;

-- 2. Plans that include an internet data plan (with data plan + operator details)
SELECT p.planName, p.price, idp.internetDataPlanName, idp.dataAllowanceMB, idp.price, mno.operatorName
FROM [Plan] p
JOIN InternetDataPlan idp ON p.internetDataPlanID = idp.internetDataPlanID
JOIN MobileNetworkOperator mno ON idp.operatorID = mno.operatorID
WHERE p.internetDataPlanID IS NOT NULL;

-- 3. Operators and plans with at least 100 free minutes to LT networks
SELECT mno.operatorName, p.planName, p.price, d.quantity AS freeMin
FROM MobileNetworkOperator mno
JOIN [PLAN] p ON mno.operatorID = p.operatorID
JOIN PlanBundle pb ON p.planID = pb.planID AND pb.serviceID = 1
JOIN Discount d ON pb.bundleID = d.bundleID
WHERE d.price = 0 AND d.quantity >= 100;

-- 4. Number of users in each city
SELECT COUNT(*) AS [Number of Users], c.cityName AS City
FROM Person p
JOIN City c ON p.cityID = c.cityID
GROUP BY c.cityName;

-- 5. Cities with no users
SELECT c.cityName AS City
FROM City c
LEFT JOIN Person p ON p.cityID = c.cityID
WHERE p.personID IS NULL;

-- 6.1 Average users per city (excluding empty cities)
SELECT AVG(CAST(cnt AS decimal(10,2))) AS [Avg users per city]
FROM (SELECT COUNT(*) AS cnt FROM Person GROUP BY cityID) AS perCity;

-- 6.2 Average users per city (including empty cities)
SELECT AVG(CAST(cnt AS decimal(10,2)))
FROM (SELECT COUNT(p.personID) AS cnt FROM City c LEFT JOIN Person p ON p.cityID = c.cityID GROUP BY c.cityID) AS perCity;

-- 7. Operator offering the most plans (with ties)
SELECT TOP (1) WITH TIES operatorName AS [Operator Name], cnt AS [Number of Plans]
FROM (SELECT mno.operatorName, COUNT(*) AS cnt
      FROM MobileNetworkOperator mno
      LEFT JOIN [PLAN] p ON mno.operatorID = p.operatorID
      GROUP BY mno.operatorName) AS perOperator
ORDER BY cnt DESC;

-- 8. People who subscribed to any plan Jan 3-10, 2025
SELECT p.firstName, p.lastName, [Plan].planName, s.contractStartDate
FROM Person p
JOIN Subscriber s ON p.personID = s.personID
JOIN [Plan] ON s.planID = [Plan].planID
WHERE s.contractStartDate >= '2025-01-03' AND s.contractStartDate <= '2025-01-10';

-- 9. Average plan price per operator, sorted descending
SELECT mno.operatorName, AVG(p.price) AS avgPrice
FROM MobileNetworkOperator mno
JOIN [Plan] p ON mno.operatorID = p.operatorID
GROUP BY mno.operatorName
ORDER BY avgPrice DESC;

-- 10. Number of additional services per operator
SELECT mno.operatorName, COUNT(*) AS [Number of Additional Services]
FROM MobileNetworkOperator mno
JOIN OperatorAdditionalService oas ON mno.operatorID = oas.operatorID
GROUP BY mno.operatorID, mno.operatorName;