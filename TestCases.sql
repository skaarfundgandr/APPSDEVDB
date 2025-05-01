BEGIN TRANSACTION testcases

-- Insert sample products
INSERT INTO products (productName, productDesc, productCategory, productPrice) VALUES
('Orange Juice', 'Freshly squeezed orange juice', 'Beverages', 3.99),
('Chocolate Bar', 'Milk chocolate bar', 'Snacks', 1.50),
('Sandwich', 'Ham and cheese sandwich', 'Food', 4.25),
('Water Bottle', '500ml bottled water', 'Beverages', 1.00),
('Apple', 'Fresh red apple', 'Fruits', 0.75),
('Banana', 'Organic banana', 'Fruits', 0.60),
('Cookies', 'Pack of 10 chocolate chip cookies', 'Snacks', 2.99),
('Soda Can', '330ml soda can', 'Beverages', 1.20),
('Chips', 'Potato chips 150g', 'Snacks', 2.50),
('Energy Drink', 'Energy boost drink 250ml', 'Beverages', 2.75);

-- Insert inventory entries for the products
INSERT INTO inventory (productID, quantity, units, latestRestock) VALUES
(1, 100, 'bottles', GETDATE()),
(2, 200, 'bars', GETDATE()),
(3, 50, 'units', GETDATE()),
(4, 300, 'bottles', GETDATE()),
(5, 150, 'pieces', GETDATE()),
(6, 180, 'pieces', GETDATE()),
(7, 120, 'packs', GETDATE()),
(8, 250, 'cans', GETDATE()),
(9, 130, 'bags', GETDATE()),
(10, 90, 'cans', GETDATE());

-- Insert kiosk users
INSERT INTO kiosks (username, [password]) VALUES
('kiosk_001', 'pass123'),
('kiosk_002', 'secure456'),
('kiosk_003', 'admin789');

-- Insert sales records
INSERT INTO sales (amount, [date]) VALUES
(5, '2024-04-20'),
(3, '2024-04-21'),
(8, '2024-04-22'),
(2, '2024-04-23'),
(6, '2024-04-24');

-- Insert restock history
INSERT INTO restockHistory (inventoryID, amount, [date]) VALUES
(1, 50, '2024-04-10'),
(2, 100, '2024-04-11'),
(3, 30, '2024-04-12'),
(4, 80, '2024-04-13'),
(5, 60, '2024-04-14'),
(6, 90, '2024-04-15'),
(7, 40, '2024-04-16'),
(8, 70, '2024-04-17'),
(9, 65, '2024-04-18'),
(10, 45, '2024-04-19');

-- Insert sales details linking kiosks, inventory, and sales
INSERT INTO salesDetails (inventoryID, salesID, kioskID) VALUES
(1, 1, 1),
(2, 1, 1),
(3, 2, 2),
(4, 3, 2),
(5, 3, 3),
(6, 4, 3),
(7, 5, 1),
(8, 5, 2),
(9, 5, 3),
(10, 2, 1);
