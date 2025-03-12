--查询示例
--查看商品库存
SELECT Product_ID, Name, Stock_Quantity 
FROM Product;

--查询某商品进货记录
SELECT pr.Purchase_Time, s.Name AS Supplier, e.Name AS Employee, pr.Quantity, pr.Purchase_Price
FROM Purchase_Record pr
JOIN Supplier s ON pr.Supplier_ID = s.Supplier_ID
JOIN Employee e ON pr.Employee_ID = e.Employee_ID
WHERE pr.Product_ID = 1;  -- 查询纯牛奶的进货记录

--查询某员工销售记录
SELECT sr.Sale_Time, p.Name AS Product, sr.Quantity, sr.Sale_Price
FROM Sale_Record sr
JOIN Product p ON sr.Product_ID = p.Product_ID
WHERE sr.Employee_ID = 2;  -- 查询李四的销售记录
