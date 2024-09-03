-- TABLES:
-- Represent customers of the cafe restaurant
CREATE TABLE "Customers"(
    "id" INTEGER,
    "first_name" TEXT NOT NULL,
    "middle_name" TEXT DEFAULT NULL,
    "last_name" TEXT NOT NULL,
    "phone_no" TEXT UNIQUE NOT NULL,
    "email_id" TEXT UNIQUE NULL,
    PRIMARY KEY("id") 
);

-- Represent menu items
CREATE TABLE "MenuItems"(
    "id" INTEGER,
    "item_name" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "category" TEXT CHECK("category" IN('Starters', 'Main Courses', 'Seafoods', 'Sides', 'Desserts', 'Beverages', 'Soups', 'Salads')) NOT NULL,
    "diet_type" TEXT CHECK("diet_type" IN('Veg', 'Non-Veg', 'Not Applicable')) DEFAULT 'Not Applicable' NOT NULL,
    "unit_price" REAL NOT NULL,
    "availability_status" TEXT CHECK("availability_status" IN('Available', 'Not Available')) DEFAULT 'Available' NOT NULL,
    PRIMARY KEY("id")
); 

-- Represent orders made by the customers
CREATE TABLE "Orders"(
    "id" INTEGER,
    "customer_id" INTEGER NOT NULL,
    "reservation_id" INTEGER DEFAULT NULL,
    "order_type" CHECK("order_type" IN('Dine-in', 'Takeaway', 'Delivery')) NOT NULL, 
    "order_datetime" DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "total_amount" REAL NOT NULL,
    "payment_status" TEXT CHECK("payment_status" IN('Paid', 'Pending')) NOT NULL,
    "payment_method" TEXT CHECK("payment_method" IN('Cash', 'Card', 'UPI')) NOT NULL,
    PRIMARY KEY("id"),
    FOREIGN KEY("customer_id") REFERENCES "Customers"("id"),
    FOREIGN KEY("reservation_id") REFERENCES "Reservations"("id")
);

-- Represent details of each item ordered by a customer
CREATE TABLE "OrderDetails"(
    "order_id" INTEGER,
    "menu_item_id" INTEGER,
    "quantity" INTEGER NOT NULL,
    "total_price" REAL NOT NULL,
    PRIMARY KEY("order_id", "menu_item_id"),
    FOREIGN KEY("order_id") REFERENCES "Orders"("id"),
    FOREIGN KEY("menu_item_id") REFERENCES "MenuItems"("id")
);

-- Represent reservations made by the customers  
CREATE TABLE "Reservations"(
    "id" INTEGER,
    "customer_id" INTEGER NOT NULL,
    "reservation_datetime" DATETIME NOT NULL,
    "number_of_guests" INTEGER NOT NULL,
    PRIMARY KEY("id"),
    FOREIGN KEY("customer_id") REFERENCES "Customers"("id")
);

-- Represent ratings provided by the customers
CREATE TABLE "CustomerRatings"(
    "id" INTEGER,
    "customer_id" INTEGER UNIQUE NOT NULL,
    "rating" INTEGER CHECK("rating" >= 1 AND "rating" <= 5) NOT NULL,
    "review" TEXT DEFAULT NULL,
    PRIMARY KEY("id"),
    FOREIGN KEY("customer_id") REFERENCES "Customers"("id")
);


-- VIEWS:
-- Represents orders made by each customers, including order details and payment status.
CREATE VIEW "CustomerOrders" AS
SELECT 
    "Customers"."id" AS "customer_id", 
    "first_name", 
    "middle_name", 
    "last_name",
    "phone_no",
    "Orders"."id" AS "order_id", 
    "order_datetime", 
    "total_amount",
    "payment_status", 
    "payment_method"
FROM 
    "Customers"
JOIN 
    "Orders" ON "Customers"."id" = "Orders"."customer_id"
ORDER BY 
    "order_datetime" DESC;

-- Represent a view on all reservations along with customer details
CREATE VIEW "ReservationDetails" AS
SELECT
    "Reservations"."id" AS "reservation_id",
    "Customers"."id" AS "customer_id",
    "first_name",
    "middle_name", 
    "last_name",
    "phone_no",
    "reservation_datetime",
    "number_of_guests"
FROM
    "Reservations"
JOIN 
    "Customers" ON "Reservations"."customer_id" = "Customers"."id"
ORDER BY 
    "reservation_datetime" DESC;

-- Represent a summary of order details for each order 
CREATE VIEW "OrderDetailsSummary" AS
SELECT
    "order_id",
    "order_datetime",
    "item_name",
    "quantity",
    "total_price" 
FROM 
    "OrderDetails"
JOIN 
    "Orders" ON "OrderDetails"."order_id" = "Orders"."id"     
JOIN      
    "MenuItems" ON "OrderDetails"."menu_item_id" = "MenuItems"."id"       
ORDER BY
    "order_datetime" DESC,
    "order_id" DESC;

-- Represent daily sales   
CREATE VIEW "DailySalesSummary" AS
SELECT
    DATE("order_datetime") AS "order_date",
    COUNT("id") AS "total_orders",
    SUM("total_amount") AS "total_revenue"
FROM
    "Orders"
WHERE
    "payment_status" = 'Paid'
GROUP BY "order_date"
ORDER BY "order_date" DESC;           

-- Represent pending orders
CREATE VIEW "PendingOrders" AS
SELECT
    "Orders"."id" AS "order_id",
    "order_datetime",
    "Customers"."id" AS "customer_id",
    "first_name",
    "middle_name", 
    "last_name",
    "phone_no",
    "total_amount",
    "payment_method"
FROM
    "Orders"    
JOIN 
    "Customers" ON "Orders"."customer_id" = "Customers"."id"
WHERE 
    "payment_status" = 'Pending'
ORDER BY 
    "order_datetime" DESC;    


-- INDEXES to speed common searches
CREATE INDEX "idx_customer_name" ON "Customers"("first_name", "middle_name", "last_name");
CREATE INDEX "idx_orders_customer_id" ON "Orders"("customer_id");
CREATE INDEX "idx_order_details_order_id" ON "OrderDetails"("order_id");
CREATE INDEX "idx_order_details_menu_item_id" ON "OrderDetails"("menu_item_id");
CREATE INDEX "idx_reservations_customer_id" ON "Reservations"("customer_id");


-- TRIGGERS
-- Trigger to automatically delete related OrderDetails when an Order is deleted.
CREATE TRIGGER "delete_order_details_after_order_deletion"
AFTER DELETE ON "Orders"
BEGIN
  DELETE FROM "OrderDetails"
  WHERE "order_id" = 'OLD'.'id';
END;
