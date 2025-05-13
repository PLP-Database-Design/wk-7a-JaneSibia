-- Assuming we need to insert data into a normalized 1NF table (ProductDetail_1NF)
CREATE TABLE ProductDetail_1NF (
    OrderID INT,
    CustomerName VARCHAR(100),
    Product VARCHAR(100)
);

-- Insert data into the new table where each row represents a single product per order
INSERT INTO ProductDetail_1NF (OrderID, CustomerName, Product)
SELECT OrderID, CustomerName, TRIM(product)
FROM (
    SELECT OrderID, CustomerName, REGEXP_SUBSTR(Products, '[^,]+', 1, n) AS product
    FROM ProductDetail
-- CROSS JOIN (SELECT LEVEL AS n FROM dual CONNECT BY LEVEL <= LENGTH(Products) - LENGTH(REPLACE(Products, ',', '')) + 1)
) AS split_products;

-- Create the Orders table to remove partial dependencies (storing OrderID and CustomerName)
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerName VARCHAR(100)
);

-- Insert the distinct orders into the Orders table
INSERT INTO Orders (OrderID, CustomerName)
SELECT DISTINCT OrderID, CustomerName FROM OrderDetails;

-- Create the OrderDetails table to store the order details (OrderID, Product, Quantity)
CREATE TABLE OrderDetails (
    OrderID INT,
    Product VARCHAR(100),
    Quantity INT,
    PRIMARY KEY (OrderID, Product),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);

-- Insert data into the normalized OrderDetails table
INSERT INTO OrderDetails (OrderID, Product, Quantity)
SELECT OrderID, Product, Quantity FROM OrderDetails;
