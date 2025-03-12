# Database-coursework
A simple supermarket inventory management system implemented in SQL.

---

## 目录
- [项目简介](#项目简介)
- [核心功能](#核心功能)
- [技术栈](#技术栈)
- [快速开始](#快速开始)
  - [环境要求](#环境要求)
  - [数据库部署](#数据库部署)
- [功能示例](#功能示例)
- [注意事项](#注意事项)
- [未来扩展](#未来扩展)
- [贡献指南](#贡献指南)
- [许可证](#许可证)

---

## 项目简介
本项目为小型超市设计的进销存管理系统，通过数据库实现以下功能：
- **库存动态更新**：进货时自动增加库存，销售时自动减少库存。
- **数据完整性保障**：通过外键约束、CHECK规则和触发器确保数据有效性。
- **多维度查询**：支持按时间、商品分类、供应商等条件生成报表。

---

## 核心功能
- **商品管理**：增删改查商品信息，实时跟踪库存。
- **供应商管理**：记录供应商合作历史与联系方式。
- **员工操作日志**：关联员工与进货/销售记录。
- **自动化规则**：
  - 库存不足时禁止销售（触发器拦截）。
  - 商品价格、数量非负约束。
- **查询与报表**：
  - 按时间范围统计销售额。
  - 分析供应商供货频率。

---

## 技术栈
- **数据库**：SQL Server 2012
- **核心特性**：
  - 触发器实现库存自动更新（`UpdateStockAfterPurchase`, `CheckStockBeforeSale`）。
  - 索引优化高频查询字段（商品名称、时间范围）。
  - 存储过程支持库存预警（`sp_CheckInventoryAlert`）。
- **数据安全**：外键级联更新、CHECK约束。

---

## 快速开始

### 环境要求
- SQL Server 2012或更高版本。
- SQL Server Management Studio (SSMS) 或类似工具。

### 数据库部署
1. **创建数据库**：
   ```sql
   CREATE DATABASE Supermarket;
   GO
   USE Supermarket;
   GO

2. **执行建表脚本**：  
   复制并运行[`schema.sql`](./schema.sql)中的SQL代码，创建表结构与约束。

3. **添加测试数据**：  
   运行[`sample_data.sql`](./sample_data.sql)插入示例数据。

4. **验证功能**：  
   - 测试进货与销售触发器：
     ```sql
     -- 进货测试
     INSERT INTO Purchase_Record (Quantity, Product_ID, Supplier_ID, Employee_ID) 
     VALUES (100, 1, 1, 1);

     -- 销售测试（库存不足时会报错）
     INSERT INTO Sale_Record (Quantity, Product_ID, Employee_ID) 
     VALUES (200, 1, 2);
     ```

---

## 功能示例
### 1. 查询某商品所有进货记录
```sql
SELECT pr.Purchase_Time, s.Name AS Supplier, pr.Quantity, pr.Purchase_Price
FROM Purchase_Record pr
JOIN Supplier s ON pr.Supplier_ID = s.Supplier_ID
WHERE pr.Product_ID = 1;
```

### 2. 生成月度销售报表
```sql
SELECT 
    FORMAT(Sale_Time, 'yyyy-MM') AS Month,
    p.Category,
    SUM(sr.Quantity) AS TotalSold,
    SUM(sr.Quantity * sr.Sale_Price) AS TotalRevenue
FROM Sale_Record sr
JOIN Product p ON sr.Product_ID = p.Product_ID
GROUP BY FORMAT(Sale_Time, 'yyyy-MM'), p.Category
ORDER BY Month;
```

---

## 注意事项
1. **数据库连接配置**：  
   - 确保SQL Server服务已启动，并在连接字符串中指定正确的服务器实例。
   - 示例连接字符串（适用于SSMS）：
     ```
     Server=localhost\SQLEXPRESS;Database=Supermarket;Integrated Security=True;
     ```

2. **触发器与事务**：  
   - 销售操作的库存校验在`INSTEAD OF INSERT`触发器中完成，确保事务原子性。

3. **性能优化**：  
   - 高频查询字段（如`Product.Name`、`Sale_Time`）已添加索引，如需扩展可调整索引策略。

4. **安全性建议**：  
   - 在生产环境中，建议为数据库用户分配最小权限（如仅允许读写指定表）。

---

## 未来扩展
- **前端界面**：使用C# WinForms或Web框架（如ASP.NET）开发可视化操作界面。
- **多仓库支持**：扩展表结构，支持分店库存调拨。
- **用户权限系统**：通过角色（如经理、收银员）控制操作权限。

---

## 贡献指南
欢迎提交Issue或Pull Request！  
1. Fork本仓库。
2. 创建分支（`git checkout -b feature/your-idea`）。
3. 提交修改（`git commit -m 'Add some feature'`）。
4. 推送分支（`git push origin feature/your-idea`）。
5. 发起Pull Request。

---
