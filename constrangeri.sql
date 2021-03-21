--------------------------------------
------------ PRIMARY KEYS ------------
--------------------------------------

ALTER TABLE games
ADD PRIMARY KEY (game_id);

ALTER TABLE game_genre
ADD PRIMARY KEY (game_id, genre_id);

ALTER TABLE genres
ADD PRIMARY KEY (genre_id);

ALTER TABLE series
ADD PRIMARY KEY (series_id);

ALTER TABLE game_mode
ADD PRIMARY KEY (game_id, mode_id);

ALTER TABLE modes
ADD PRIMARY KEY (mode_id);

ALTER TABLE game_developer
ADD PRIMARY KEY (game_id, developer_id);

ALTER TABLE developers
ADD PRIMARY KEY (developer_id);

ALTER TABLE game_publisher_platform
ADD PRIMARY KEY (game_id, publisher_id, platform_id);

ALTER TABLE publishers
ADD PRIMARY KEY (publisher_id);

ALTER TABLE platforms
ADD PRIMARY KEY (platform_id);

ALTER TABLE returns
ADD PRIMARY KEY (return_id);

ALTER TABLE orders
ADD PRIMARY KEY (order_id);

ALTER TABLE order_game
ADD PRIMARY KEY (order_id, game_id);

ALTER TABLE employees
ADD PRIMARY KEY (employee_id);

ALTER TABLE customers
ADD PRIMARY KEY (customer_id);

ALTER TABLE address
ADD PRIMARY KEY (address_id);

ALTER TABLE payments
ADD PRIMARY KEY (payment_id);

ALTER TABLE notifications
ADD PRIMARY KEY (notification_id);

--------------------------------------
------------ FOREIGN KEYS ------------
--------------------------------------
ALTER TABLE games
    ADD CONSTRAINT fk_games_series FOREIGN KEY (series_id)
        REFERENCES series (series_id);
        
        
ALTER TABLE game_mode
    ADD CONSTRAINT fk_game_mode_games FOREIGN KEY (game_id)
        REFERENCES games (game_id);
ALTER TABLE game_mode
    ADD CONSTRAINT fk_game_mode_modes FOREIGN KEY (mode_id)
        REFERENCES modes (mode_id);


ALTER TABLE game_genre
    ADD CONSTRAINT fk_game_genre_games FOREIGN KEY (game_id)
        REFERENCES games (game_id);
ALTER TABLE game_genre
    ADD CONSTRAINT fk_game_genre_genres FOREIGN KEY (genre_id)
        REFERENCES genres (genre_id);
        

ALTER TABLE game_developer
    ADD CONSTRAINT fk_game_developer_games FOREIGN KEY (game_id)
        REFERENCES games (game_id);
ALTER TABLE game_developer
    ADD CONSTRAINT fk_game_developer_developers FOREIGN KEY (developer_id)
        REFERENCES developers (developer_id);


ALTER TABLE game_publisher_platform
    ADD CONSTRAINT fk_gpp_games FOREIGN KEY (game_id)
        REFERENCES games (game_id);
ALTER TABLE game_publisher_platform
    ADD CONSTRAINT fk_gpp_publishers FOREIGN KEY (publisher_id)
        REFERENCES publishers (publisher_id);
ALTER TABLE game_publisher_platform
    ADD CONSTRAINT fk_gpp_platforms FOREIGN KEY (platform_id)
        REFERENCES platforms (platform_id);


ALTER TABLE order_game
    ADD CONSTRAINT fk_order_game_games FOREIGN KEY (game_id)
        REFERENCES games (game_id);
ALTER TABLE order_game
    ADD CONSTRAINT fk_order_game_orders FOREIGN KEY (order_id)
        REFERENCES orders (order_id);
ALTER TABLE order_game
    ADD CONSTRAINT fk_order_game_platform FOREIGN KEY (platform_id)
        REFERENCES platforms (platform_id);
        

ALTER TABLE orders
    ADD CONSTRAINT fk_orders_customers FOREIGN KEY (customer_id)
        REFERENCES customers (customer_id);
ALTER TABLE orders
    ADD CONSTRAINT fk_orders_employees FOREIGN KEY (employee_id)
        REFERENCES employees (employee_id);
ALTER TABLE orders
    ADD CONSTRAINT fk_orders_payments FOREIGN KEY (payment_id)
        REFERENCES payments (payment_id);


ALTER TABLE customers
    ADD CONSTRAINT fk_customers_address FOREIGN KEY (address_id)
        REFERENCES address (address_id);

ALTER TABLE returns
    ADD CONSTRAINT fk_returns_customers FOREIGN KEY (customer_id)
        REFERENCES customers (customer_id);

ALTER TABLE returns
    ADD CONSTRAINT fk_returns_employees FOREIGN KEY (employee_id)
        REFERENCES employees (employee_id);

ALTER TABLE notifications
    ADD CONSTRAINT fk_notif_customer FOREIGN KEY (customer_id)
        REFERENCES customers (customer_id);

-------------------------------------------
------------ OTHER CONSTRAINTS ------------
-------------------------------------------

-- E        = everyone
-- E10+     = everyone 10+
-- T        = teen
-- M        = mature 17+
-- AO       = adults only 18+
-- RP       = rating pending

-------------------------------------------
-- CHECK CONSTRAINTS
-------------------------------------------
ALTER TABLE games
    ADD CONSTRAINT chk_games_esrb
        CHECK (esrb_rating IN ('E','E10+','T','M','AO','RP'));

ALTER TABLE games
    ADD CONSTRAINT chk_games_review
        CHECK (review >= 0.00 AND review <= 5.00);
        
ALTER TABLE customers
    ADD CONSTRAINT chk_customers_phone
        CHECK (length(phone_number) > 0 AND length(phone_number) <= 18);

ALTER TABLE employees
    ADD CONSTRAINT chk_employees_phone
        CHECK (length(phone_number) > 0 AND length(phone_number) <= 18);

ALTER TABLE payments
    ADD CONSTRAINT chk_payments_card_number
        CHECK (length(card_number) = 16 AND (card_number LIKE '4%' OR card_number LIKE '5%'));

ALTER TABLE payments
    ADD CONSTRAINT chk_payments_valid
        CHECK (valid IN (0,1));
        
ALTER TABLE order_game
    ADD CONSTRAINT chk_discount
        CHECK (discount >= 0.00 AND discount <= 1.00);
        
ALTER TABLE notifications
    ADD CONSTRAINT chk_seen
        CHECK (seen IN (1,0));
        
-------------------------------------------
-- UNIQUE CONSTRAINTS
-------------------------------------------

ALTER TABLE genres
    ADD CONSTRAINT u_genre_name
        UNIQUE (genre_name);

ALTER TABLE series
    ADD CONSTRAINT u_series_name
        UNIQUE (series_name);
        
ALTER TABLE modes
    ADD CONSTRAINT u_modes
        UNIQUE (mode_name);

ALTER TABLE developers
    ADD CONSTRAINT u_developers
        UNIQUE (developer_name);

ALTER TABLE platforms
    ADD CONSTRAINT u_platforms
        UNIQUE (platform_name);

ALTER TABLE publishers
    ADD CONSTRAINT u_publisher_name
        UNIQUE (publisher_name);

ALTER TABLE customers
    ADD CONSTRAINT u_customer_email
        UNIQUE (email);

ALTER TABLE customers
    ADD CONSTRAINT u_customer_phone
        UNIQUE (phone_number);
        
ALTER TABLE employees
    ADD CONSTRAINT u_employee_email
        UNIQUE (email);
        
ALTER TABLE employees
    ADD CONSTRAINT u_employee_phone
        UNIQUE (phone_number);
        
ALTER TABLE payments
    ADD CONSTRAINT u_card_number
        UNIQUE (card_number);
        