-- Example Queries for Cafe Restaurant Customer Orders and Management System

-- Find all the orders made by a particular customer
SELECT
    *
FROM
    "Orders"
WHERE
    "customer_id" = (
        SELECT
            "id"
        FROM
            "Customers"
        WHERE
            "first_name" = 'Ankito'
            AND "last_name" = 'Kalita'
    );

-- Find all the available non-veg starters
SELECT
    "item_name",
    "description",
    "unit_price"
FROM
    "MenuItems"
WHERE
    "category" = 'Starters'
    AND "diet_type" = 'Non-Veg'
    AND "availability_status" = 'Available';

-- Find the reservation for a given customer on the most recent date.
SELECT
    *
FROM
    "Reservations"
WHERE
    "reservation_datetime" = (
        SELECT
            MAX(DATE("reservation_datetime"))
        FROM "Reservations"
    )
    AND "customer_id" = (
        SELECT
            "id"
        FROM
            "Customers"
        WHERE
            "first_name" = 'Ava'
            AND "Last_name" = 'Anderson'
    );

-- Find the summary of order details for the latest date including item names, quantities, and total prices.
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
WHERE
    DATE("order_datetime") = (
        SELECT
            MAX(DATE("order_datetime"))
        FROM
            "Orders"
    );

-- Find the order details for a specific order, given the customer name and the date.
SELECT
    *
FROM
    "OrderDetails"
WHERE
    "order_id" = (
        SELECT
            "id"
        FROM
            "Orders"
        WHERE
            "customer_id" = (
                SELECT
                    "id"
                FROM
                    "Customers"
                WHERE
                    "first_name" = 'Ankito'
                    AND "last_name" = 'Kalita'
            )
            AND "order_datetime" LIKE '2024-08-10%'
    );

-- Find the total quantity sold and revenue generated for a specific menu item on a particular date.
SELECT
    "menu_item_id",
    SUM("quantity"),
    SUM("total_price")
FROM
    "OrderDetails"
JOIN
    "Orders" ON "OrderDetails"."order_id" = "Orders"."id"
WHERE
    "menu_item_id" = (
        SELECT
            "id"
        FROM
            "MenuItems"
        WHERE
            "item_name" = 'Garlic Bread'
    )
    AND "order_datetime" LIKE '2024-08-10%';

-- Add a new customer
INSERT INTO "Customers" ("first_name", "last_name", "phone_no", "email_id")
VALUES ('Jack', 'Smith', '572-849-1637', 'randomuser7584@example.com');

-- Add a new menu item
INSERT INTO "MenuItems" ("item_name", "description", "category", "diet_type", "unit_price", "availability_status")
VALUES ('Margherita Pizza', 'Classic Margherita Pizza with fresh tomatoes', 'Main Courses', 'Veg', 8.99, 'Available');

-- Add a new order
INSERT INTO "Orders" ("customer_id", "order_type", "total_amount", "payment_status", "payment_method")
VALUES (1,'Dine-in', 17.98, 'Paid', 'Cash');

-- Add new order details
INSERT INTO "OrderDetails" ("order_id", "menu_item_id", "quantity", "total_price")
VALUES (1, 1, 2, 17.98);

-- Add a new reservation
INSERT INTO "Reservations" ("customer_id", "reservation_datetime", "number_of_guests")
VALUES (1, '2024-09-10 19:30:00', 4);

-- Add a new customer rating
INSERT INTO "CustomerRatings" ("customer_id", "rating", "review")
VALUES (1, 5, 'Excellent service and delicious food!');
