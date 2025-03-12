--插入测试数据
--添加供货商
INSERT INTO Supplier (Name, Phone, Address)
VALUES 
  ('光明食品厂', '13800138000', '上海市浦东新区'),
  ('清风日化', '13900139000', '杭州市西湖区');
GO

--添加员工
INSERT INTO Employee (Name, Position, Phone)
VALUES 
  ('张三', '采购员', '15012345678'),
  ('李四', '收银员', '15187654321');
GO

--添加商品
INSERT INTO Product (Name, Price, Category)
VALUES 
  ('纯牛奶', 5.00, '食品'),
  ('抽纸巾', 10.00, '日用品');
GO

--模拟进货
-- 从光明食品厂进货纯牛奶100盒
INSERT INTO Purchase_Record (Quantity, Purchase_Price, Product_ID, Supplier_ID, Employee_ID)
VALUES (100, 3.50, 1, 1, 1);

-- 从清风日化进货抽纸巾50包
INSERT INTO Purchase_Record (Quantity, Purchase_Price, Product_ID, Supplier_ID, Employee_ID)
VALUES (50, 7.00, 2, 2, 1);
GO

-- 验证库存是否更新
SELECT * FROM Product;

--模拟销售
-- 李四售出纯牛奶20盒（售价5元/盒）
INSERT INTO Sale_Record (Quantity, Sale_Price, Product_ID, Employee_ID)
VALUES (20, 5.00, 1, 2);

-- 尝试售出抽纸巾60包（库存不足，触发错误）
INSERT INTO Sale_Record (Quantity, Sale_Price, Product_ID, Employee_ID)
VALUES (60, 10.00, 2, 2);
GO

-- 验证库存和错误处理
SELECT * FROM Product;
