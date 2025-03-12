CREATE DATABASE Supermarket;
GO

USE Supermarket;
GO

--员工表
CREATE TABLE Employee (
    Employee_ID      INT PRIMARY KEY IDENTITY(1,1),
    Name             VARCHAR(50) NOT NULL,
    Position         VARCHAR(50) NOT NULL,
    Phone            VARCHAR(20),
    Join_Date        DATE DEFAULT GETDATE()
);
GO

--商品表
CREATE TABLE Product (
    Product_ID        INT PRIMARY KEY IDENTITY(1,1),
    Name              VARCHAR(100) NOT NULL,
    Price             DECIMAL(10,2) NOT NULL CHECK (Price >= 0),
    Stock_Quantity    INT NOT NULL DEFAULT 0 CHECK (Stock_Quantity >= 0),
    Production_Date   DATE,
    Expiry_Date       DATE,
    Category          VARCHAR(50)
);
GO

--供货商表
CREATE TABLE Supplier (
    Supplier_ID      INT PRIMARY KEY IDENTITY(1,1),
    Name             VARCHAR(100) NOT NULL,
    Phone            VARCHAR(20),
    Address          VARCHAR(200)
);
GO

--进货记录表
CREATE TABLE Purchase_Record (
    Purchase_ID      INT PRIMARY KEY IDENTITY(1,1),
    Purchase_Time    DATETIME DEFAULT GETDATE(),
    Quantity         INT NOT NULL CHECK (Quantity > 0),
    Purchase_Price   DECIMAL(10,2) NOT NULL CHECK (Purchase_Price >= 0),
    Product_ID       INT NOT NULL,
    Supplier_ID      INT NOT NULL,
    Employee_ID      INT NOT NULL,
    -- 外键约束
    FOREIGN KEY (Product_ID) REFERENCES Product(Product_ID)
        ON DELETE NO ACTION
        ON UPDATE CASCADE,
    FOREIGN KEY (Supplier_ID) REFERENCES Supplier(Supplier_ID)
        ON DELETE NO ACTION
        ON UPDATE CASCADE,
    FOREIGN KEY (Employee_ID) REFERENCES Employee(Employee_ID)
        ON DELETE NO ACTION
        ON UPDATE CASCADE
);
GO

--销售记录表
CREATE TABLE Sale_Record (
    Sale_ID          INT PRIMARY KEY IDENTITY(1,1),
    Sale_Time        DATETIME DEFAULT GETDATE(),
    Quantity         INT NOT NULL CHECK (Quantity > 0),
    Sale_Price       DECIMAL(10,2) NOT NULL CHECK (Sale_Price >= 0),
    Product_ID       INT NOT NULL,
    Employee_ID      INT NOT NULL,
    -- 外键约束
    FOREIGN KEY (Product_ID) REFERENCES Product(Product_ID)
        ON DELETE NO ACTION
        ON UPDATE CASCADE,
    FOREIGN KEY (Employee_ID) REFERENCES Employee(Employee_ID)
        ON DELETE NO ACTION
        ON UPDATE CASCADE
);
GO

--进货触发器
CREATE TRIGGER UpdateStockAfterPurchase
ON Purchase_Record
AFTER INSERT
AS
BEGIN
    UPDATE Product
    SET Stock_Quantity = Stock_Quantity + i.Quantity
    FROM Product p
    INNER JOIN inserted i ON p.Product_ID = i.Product_ID;
END;
GO

--销售触发器（含库存检查）
CREATE TRIGGER UpdateStockAfterSale
ON Sale_Record
AFTER INSERT
AS
BEGIN
    -- 检查库存是否充足
    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN Product p ON i.Product_ID = p.Product_ID
        WHERE p.Stock_Quantity < i.Quantity
    )
    BEGIN
        RAISERROR('库存不足，无法完成销售！', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;

    -- 更新库存
    UPDATE Product
    SET Stock_Quantity = Stock_Quantity - i.Quantity
    FROM Product p
    INNER JOIN inserted i ON p.Product_ID = i.Product_ID;
END;
GO





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
