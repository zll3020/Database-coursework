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
