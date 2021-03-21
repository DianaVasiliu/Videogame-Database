--------------------
--  DROP FK CONS  --
--------------------
ALTER TABLE games
    DROP CONSTRAINT fk_games_series;
    
ALTER TABLE game_mode
    DROP CONSTRAINT fk_game_mode_games;

ALTER TABLE game_mode
    DROP CONSTRAINT fk_game_mode_modes;

ALTER TABLE game_genre
    DROP CONSTRAINT fk_game_genre_games;

ALTER TABLE game_genre
    DROP CONSTRAINT fk_game_genre_genres;

ALTER TABLE game_developer
    DROP CONSTRAINT fk_game_developer_games;

ALTER TABLE game_developer
    DROP CONSTRAINT fk_game_developer_developers;

ALTER TABLE game_publisher_platform
    DROP CONSTRAINT fk_gpp_games;

ALTER TABLE game_publisher_platform
    DROP CONSTRAINT fk_gpp_publishers;
    
ALTER TABLE game_publisher_platform
    DROP CONSTRAINT fk_gpp_platforms;

ALTER TABLE order_game
    DROP CONSTRAINT fk_order_game_games;
     
ALTER TABLE order_game
    DROP CONSTRAINT fk_order_game_orders;
    
ALTER TABLE order_game
    DROP CONSTRAINT fk_order_game_platform;

ALTER TABLE orders
    DROP CONSTRAINT fk_orders_customers; 
    
ALTER TABLE orders
    DROP CONSTRAINT fk_orders_employees;
    
ALTER TABLE orders
    DROP CONSTRAINT fk_orders_payments;
    
ALTER TABLE customers
    DROP CONSTRAINT fk_customers_address;

ALTER TABLE returns
    DROP CONSTRAINT fk_returns_customers;
    
ALTER TABLE returns
    DROP CONSTRAINT fk_returns_employees;
 
 ALTER TABLE notifications
    DROP CONSTRAINT fk_notif_customer;
    
---------------------
-- DROP CHECK CONS --
---------------------
ALTER TABLE games
    DROP CONSTRAINT chk_games_esrb;

ALTER TABLE games
    DROP CONSTRAINT chk_games_review;    
        
ALTER TABLE customers
    DROP CONSTRAINT chk_customers_phone;
    
ALTER TABLE employees
    DROP CONSTRAINT chk_employees_phone;

ALTER TABLE payments
    DROP CONSTRAINT chk_payments_card_number;    

ALTER TABLE payments
    DROP CONSTRAINT chk_payments_valid;    
    
ALTER TABLE notifications
    DROP CONSTRAINT chk_seen;
    
----------------------
-- DROP UNIQUE CONS --
----------------------
ALTER TABLE genres
    DROP CONSTRAINT u_genre_name;

ALTER TABLE series
    DROP CONSTRAINT u_series_name;    

ALTER TABLE modes
    DROP CONSTRAINT u_modes;    

ALTER TABLE developers
    DROP CONSTRAINT u_developers;    

ALTER TABLE platforms
    DROP CONSTRAINT u_platforms;    

ALTER TABLE publishers
    DROP CONSTRAINT u_publisher_name;    

ALTER TABLE customers
    DROP CONSTRAINT u_customer_email;    

ALTER TABLE customers
    DROP CONSTRAINT u_customer_phone;    

ALTER TABLE employees
    DROP CONSTRAINT u_employee_email;    

ALTER TABLE employees
    DROP CONSTRAINT u_employee_phone;    

ALTER TABLE payments
    DROP CONSTRAINT u_card_number; 

---------------------------------------------
--------- STERGEREA DECLANSATORILOR ---------
---------------------------------------------
DROP TRIGGER create_trigger;
DROP TRIGGER games_trigger;
DROP TRIGGER show_number_of_customers_trigger;

---------------------
---- DROP TABLES ----
---------------------
DROP TABLE games;
DROP TABLE game_genre;
DROP TABLE genres;
DROP TABLE series;
DROP TABLE game_mode;
DROP TABLE modes;
DROP TABLE game_developer;
DROP TABLE developers;
DROP TABLE game_publisher_platform;
DROP TABLE publishers;
DROP TABLE platforms;
DROP TABLE returns;
DROP TABLE orders;
DROP TABLE order_game;
DROP TABLE employees;
DROP TABLE customers;
DROP TABLE address;
DROP TABLE payments;
DROP TABLE notifications;

----------------------------------------------------
--------- STERGEREA SUBPROGRAMELOR STOCATE ---------
----------------------------------------------------
DROP PROCEDURE game_developer_list;
DROP PROCEDURE show_modes_game_list;
DROP FUNCTION nr_clients_country_orderval;
DROP PROCEDURE show_ordered_games_country;

----------------------------------------
--------- STERGEREA PACHETELOR ---------
----------------------------------------
DROP PACKAGE games_package;
DROP PACKAGE extra_package;

-----------------------------------------
--------- STERGEREA SECVENTELOR ---------
-----------------------------------------
DROP SEQUENCE notification_seq;

---------------------------------------
--------- GOLIRE COS DE GUNOI ---------
---------------------------------------
PURGE RECYCLEBIN;




    