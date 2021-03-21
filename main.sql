SET SERVEROUTPUT ON
SET VERIFY OFF

-- problema 6
CREATE OR REPLACE
    PROCEDURE game_developer_list ( v_genre_name  genres.genre_name%TYPE )
AS
    TYPE    t_game_id   IS TABLE OF     games.game_id%TYPE;
    TYPE    t_title     IS TABLE OF     games.title%TYPE;
    TYPE    t_developer IS TABLE OF     developers.developer_name%TYPE;
    v_genre_id          game_genre.genre_id%TYPE;
    v_game_id           t_game_id       := t_game_id();
    v_title             t_title         := t_title();
    v_devname           t_developer     := t_developer();
    e_no_games          EXCEPTION;
BEGIN

    dbms_output.put_line('---------- ' || UPPER(v_genre_name) || ' ----------');
    
    SELECT genre_id
    INTO v_genre_id
    FROM genres
    WHERE genre_name = INITCAP(v_genre_name);
           
    SELECT game_id
    BULK COLLECT INTO v_game_id
    FROM game_genre
    WHERE genre_id = v_genre_id;
    
    IF v_game_id.COUNT != 0 THEN
        FOR i IN v_game_id.FIRST .. v_game_id.LAST LOOP
        
            SELECT title, developer_name
            BULK COLLECT INTO v_title, v_devname
            FROM games 
            JOIN game_developer USING (game_id)
            JOIN developers USING (developer_id)
            WHERE game_id = v_game_id(i);
            
            FOR j IN v_devname.FIRST .. v_devname.LAST LOOP
                dbms_output.put_line(v_title(j) || '  -  ' || v_devname(j));
            END LOOP;
            
        END LOOP;
    ELSE 
        RAISE e_no_games;
    END IF;

    dbms_output.new_line;
EXCEPTION
    WHEN e_no_games THEN
        dbms_output.put_line('Nu exista jocuri cu genul dorit!');
        dbms_output.new_line;
    WHEN NO_DATA_FOUND THEN
        dbms_output.put_line('Gen inexistent!');
        dbms_output.new_line;
    WHEN OTHERS THEN
        dbms_output.put_line('Alta eroare! - ' || SQLERRM);
        dbms_output.new_line;
END game_developer_list;
/

BEGIN
    game_developer_list('Christian');
    game_developer_list('Actiune');
    game_developer_list('Action');
    game_developer_list('&p_gen');
END;
/


-- problema 7
CREATE OR REPLACE
    PROCEDURE show_modes_game_list
AS
    v_pos       NUMBER;
    v_number    NUMBER;
BEGIN
    
    FOR v_mode IN ( SELECT mode_id, mode_name
                    FROM modes 
                    ORDER BY mode_name )
    LOOP
        dbms_output.put_line('--------- ' || UPPER(v_mode.mode_name) || ' ---------');
        
        SELECT COUNT(*)
        INTO v_number
        FROM game_mode
        WHERE mode_id = v_mode.mode_id;
        
        dbms_output.put_line('--------- Numar de jocuri: ' || v_number);
        
        v_pos := 1;
        FOR v_title IN ( SELECT title
                         FROM games
                         JOIN game_mode USING (game_id)
                         WHERE mode_id = v_mode.mode_id )
        LOOP
            dbms_output.put_line(v_pos || '. ' || v_title.title);   
            v_pos := v_pos + 1;
        END LOOP;
        
        dbms_output.new_line;
    END LOOP;
END show_modes_game_list;
/

BEGIN
    show_modes_game_list;
    
END;
/

-- problema 8
CREATE OR REPLACE
    FUNCTION nr_clients_country_orderval ( v_country_name   address.country%TYPE,
                                           v_over           VARCHAR2 )
    RETURN NUMBER
AS
    TYPE    t_customer_id   IS TABLE OF customers.customer_id%TYPE;
    v_customer_id       t_customer_id   := t_customer_id();
    v_order_nr          NUMBER;
    v_number            NUMBER          := 0;
    v_limit             orders.total_price%TYPE;
    e_no_country        EXCEPTION;
BEGIN

    v_limit := TO_NUMBER(v_over);
    
    SELECT customer_id
    BULK COLLECT INTO v_customer_id
    FROM customers
    WHERE address_id IN ( SELECT address_id
                          FROM address
                          WHERE LOWER(country) = LOWER(v_country_name) );

    IF v_customer_id.COUNT = 0 THEN
        RAISE e_no_country;
    END IF;
    
    FOR i IN v_customer_id.FIRST .. v_customer_id.LAST LOOP
            
        SELECT COUNT(DISTINCT customer_id)
        INTO v_order_nr
        FROM orders
        WHERE customer_id = v_customer_id(i)
        AND total_price >= v_limit;
        
        v_number := v_number + v_order_nr;
    END LOOP;
    
    RETURN v_number;
    
EXCEPTION
    WHEN e_no_country THEN
        dbms_output.put_line('Nu exista clienti cu locuinta in ' || v_country_name || '!');
        RETURN -1;
    WHEN VALUE_ERROR THEN
        dbms_output.put_line('Format gresit pentru valoarea ''' || v_over || '''!');
        RETURN -6502;
    WHEN OTHERS THEN
        dbms_output.put_line('Alta eroare! - ' || SQLERRM || ' - ' || SQLCODE);
        RETURN -20005;
        
END nr_clients_country_orderval;
/

DECLARE
    v_return_val    NUMBER;
    v_tara          VARCHAR2(200) := '&p_tara';
    v_val           VARCHAR2(200) := '&p_val';
BEGIN
    -- test 1
    v_return_val := nr_clients_country_orderval ('Germany', 'a');
    IF v_return_val >= 0 THEN
        dbms_output.put_line('Numarul de clienti din Germany care au efectuat '
                             || 'comenzi cu o valoare mai mare decat 10 este: ' 
                             || v_return_val);
    END IF;
    
    -- test 2           
    v_return_val := nr_clients_country_orderval ('Romania', 100);
    IF v_return_val >= 0 THEN
        dbms_output.put_line('Numarul de clienti din Romania care au efectuat '
                             || 'comenzi cu o valoare mai mare decat 100 este: ' 
                             || v_return_val);
    END IF;
    
    -- test 3           
    v_return_val := nr_clients_country_orderval (v_tara, v_val);
    IF v_return_val >= 0 THEN
        dbms_output.put_line('Numarul de clienti din ' || initcap(v_tara) || ' care au efectuat '
                             || 'comenzi cu o valoare mai mare decat ' || v_val || ' este: ' 
                             || v_return_val);
    END IF;
    
    -- test 4
    v_return_val := nr_clients_country_orderval ('Germany', 10);
    IF v_return_val >= 0 THEN
        dbms_output.put_line('Numarul de clienti din Germany care au efectuat '
                             || 'comenzi cu o valoare mai mare decat 10 este: ' 
                             || v_return_val);
    END IF;
END;
/

-- problema 9
CREATE OR REPLACE
    PROCEDURE show_ordered_games_country ( v_country_name     address.country%TYPE )
AS
    TYPE    t_customers     IS TABLE OF     customers.customer_id%TYPE;
    TYPE    t_games         IS TABLE OF     games.game_id%TYPE;
    TYPE    t_orders        IS TABLE OF     orders.order_id%TYPE;
    TYPE    t_price         IS TABLE OF     orders.total_price%TYPE;
    v_customer_id           t_customers     := t_customers();
    v_game_temp             t_games         := t_games();
    v_game_id               t_games         := t_games();
    v_order_temp            t_orders        := t_orders();
    v_order_id              t_orders        := t_orders();
    v_price                 t_price         := t_price();
    v_title                 games.title%TYPE;
    v_profit                NUMBER;
    e_no_country            EXCEPTION;
    e_no_orders             EXCEPTION;
BEGIN

    dbms_output.put_line('------- ' || UPPER(v_country_name) || ' -------');
    
    SELECT customer_id
    BULK COLLECT INTO v_customer_id
    FROM customers
    WHERE address_id IN ( SELECT address_id
                          FROM address
                          WHERE LOWER(country) = LOWER(v_country_name));
    
    IF v_customer_id.COUNT = 0 THEN
        RAISE e_no_country;
    END IF;
    
    v_profit := 0;
    
    FOR i IN v_customer_id.FIRST .. v_customer_id.LAST LOOP
        SELECT order_id, total_price
        BULK COLLECT INTO v_order_temp, v_price
        FROM orders
        WHERE customer_id = v_customer_id(i);
        
        IF v_order_temp.COUNT != 0 THEN
            FOR j IN v_order_temp.FIRST .. v_order_temp.LAST LOOP
                v_order_id.EXTEND;
                v_order_id( v_order_id.COUNT ) := v_order_temp(j);
                v_profit := v_profit + v_price(j);
            END LOOP;
        END IF;
        
        SELECT cashback
        BULK COLLECT INTO v_price
        FROM returns
        WHERE customer_id = v_customer_id(i);
        
        IF v_price.COUNT != 0 THEN
            FOR j IN v_price.FIRST .. v_price.LAST LOOP
                v_profit := v_profit - v_price(j);
            END LOOP;
        END IF;
    END LOOP;
    
    IF v_order_id.COUNT = 0 THEN
        RAISE e_no_orders;
    END IF;
    
    dbms_output.put_line('PROFIT: '  || v_profit);
    
    FOR i IN v_order_id.FIRST .. v_order_id.LAST LOOP
        
        SELECT game_id
        BULK COLLECT INTO v_game_temp
        FROM order_game
        WHERE order_id = v_order_id(i);
        
        FOR j IN v_game_temp.FIRST .. v_game_temp.LAST LOOP
            v_game_id.EXTEND;
            v_game_id( v_game_id.COUNT ) := v_game_temp(j);
        END LOOP;
        
    END LOOP;
        
    v_game_id := SET(v_game_id);
    
    FOR i IN v_game_id.FIRST .. v_game_id.LAST LOOP        
        SELECT title
        INTO v_title
        FROM games
        WHERE game_id = v_game_id(i);
        
        dbms_output.put_line(v_title);        
    END LOOP;   
    
    dbms_output.new_line;
    
EXCEPTION
    WHEN e_no_country THEN
        dbms_output.put_line('Nu exista clienti care locuiesc in ' || INITCAP(v_country_name) || '!');
        dbms_output.new_line;
    WHEN e_no_orders THEN
        dbms_output.put_line('Niciun client din ' || INITCAP(v_country_name) || ' nu a efectuat comenzi!');
        dbms_output.new_line;
    WHEN OTHERS THEN
        dbms_output.put_line('Alta eroare! - ' || SQLERRM);  
        dbms_output.new_line;

END show_ordered_games_country;
/

BEGIN
    show_ordered_games_country('France');
    show_ordered_games_country('UK');
    show_ordered_games_country('Romania');
    show_ordered_games_country('Germany');
END;
/


-- problema 10
CREATE OR REPLACE   
    TRIGGER show_number_of_customers_trigger
AFTER INSERT OR UPDATE OR DELETE ON customers
DECLARE
    v_nr        NUMBER;
BEGIN

    SELECT COUNT(*)
    INTO v_nr
    FROM customers;
    
    IF INSERTING THEN
        dbms_output.put_line('Numarul de clienti dupa inserare: ' || v_nr);
    ELSIF UPDATING THEN
        dbms_output.put_line('Numarul de clienti neschimbat! A ramas ' || v_nr);
    ELSIF DELETING THEN
        dbms_output.put_line('Numarul de clienti dupa stergere: ' || v_nr);
    END IF;
END;
/

BEGIN
    INSERT INTO customers VALUES
    (1031, 'Alan', 'Turing', '06-MAY-2019', 'alanturing@gmail.com', '074 2356 9920', 21);
    
    UPDATE customers
    SET phone_number = '0782 9242 1823'
    WHERE customer_id = 1031;
    
    DELETE FROM customers
    WHERE customer_id = 1031;
END;
/

-- problema 11
CREATE OR REPLACE 
    TRIGGER games_trigger
BEFORE INSERT OR UPDATE OR DELETE ON games
FOR EACH ROW
DECLARE
    v_nr     NUMBER;
BEGIN

    IF INSERTING THEN
        IF :NEW.price < 0.00 THEN 
            RAISE_APPLICATION_ERROR(-20005, 'Pretul nu poate fi mai mic decat 0!');
        END IF;   
        
        IF UPPER(:NEW.esrb_rating) NOT IN ('E','E10+','T','M','AO','RP') THEN
            RAISE_APPLICATION_ERROR(-20010, 'ESRB invalid!');        
        END IF;  
        
        SELECT COUNT(*)
        INTO v_nr
        FROM series
        WHERE series_id = :NEW.series_id;
        
        IF v_nr = 0 AND :NEW.series_id IS NOT NULL THEN
            RAISE_APPLICATION_ERROR(-20015, 'Serie inexistenta!');
        END IF;
        
    ELSIF UPDATING ('price') THEN
        IF :NEW.price < 0.00 THEN 
            RAISE_APPLICATION_ERROR(-20020, 'Pretul nu poate fi mai mic decat 0!');
        END IF;
        
    ELSIF UPDATING ('esrb_rating') THEN
        IF UPPER(:NEW.esrb_rating) NOT IN ('E','E10+','T','M','AO','RP') THEN
            RAISE_APPLICATION_ERROR(-20025, 'ESRB invalid!');        
        END IF;
        
    ELSIF UPDATING ('series_id') THEN
        SELECT COUNT(*)
        INTO v_nr
        FROM series
        WHERE series_id = :NEW.series_id;
    
        IF v_nr = 0 OR :NEW.series_id IS NOT NULL THEN
            RAISE_APPLICATION_ERROR(-20030, 'Serie inexistenta!');        
        END IF;
        
    ELSIF DELETING THEN
        SELECT COUNT(*)
        INTO v_nr
        FROM order_game
        WHERE game_id = :OLD.game_id;

        IF v_nr != 0 THEN
            RAISE_APPLICATION_ERROR(-20035, 'Nu este permisa stergerea unui joc care a fost comandat!');
        END IF;
    END IF;
END;
/

INSERT INTO games VALUES 
(47, 'game', 'E', null, 4.50, -9.99, '');
INSERT INTO games VALUES 
(47, 'game', 'ESRB', null, 4.50, 9.99, '');
INSERT INTO games VALUES 
(47, 'game', 'E', 1000, 4.50, 9.99, '');

UPDATE games
SET price = -10.00
WHERE game_id = 46;
    
UPDATE games
SET esrb_rating = 'ESRB'
WHERE game_id = 46;

UPDATE games
SET series_id = 1000
WHERE game_id = 46;

DELETE FROM games
WHERE game_id IN (10, 30);

DELETE FROM games
WHERE game_id = 35;


-- problema 12
CREATE OR REPLACE
    TRIGGER create_trigger
BEFORE CREATE ON SCHEMA
DECLARE
    v_table_name     user_tables.table_name%TYPE;
BEGIN
    
    SELECT ora_dict_obj_name
    INTO v_table_name
    FROM DUAL;

    IF LENGTH(v_table_name) > 50 THEN
        RAISE_APPLICATION_ERROR(-20010, 'Nume prea lung pentru obiect!');
    END IF;
    
    IF UPPER(SUBSTR(v_table_name, 1, 1)) = 'Z' THEN
        RAISE_APPLICATION_ERROR(-20005, 'Numele pentru obiect nu poate sa inceapa cu ''z''!');
    END IF;    
    
END;
/

CREATE TABLE extremely_long_name_for_a_table_made_to_execute_trigger (
    colname NUMBER
);

CREATE TABLE ztable (
    colname NUMBER
);

-------------------------------------
------ SPECIFICATIA PACHETULUI ------
-------------------------------------

CREATE OR REPLACE PACKAGE games_package
AS

    e_no_games          EXCEPTION;
    e_no_country        EXCEPTION;
    e_no_orders         EXCEPTION;
    
    TYPE    t_orders        IS TABLE OF     orders.order_id%TYPE;
    TYPE    t_game_id       IS TABLE OF     games.game_id%TYPE;
    TYPE    t_title         IS TABLE OF     games.title%TYPE;
    TYPE    t_developer     IS TABLE OF     developers.developer_name%TYPE;
    TYPE    t_customer_id   IS TABLE OF     customers.customer_id%TYPE;
    TYPE    t_price         IS TABLE OF     orders.total_price%TYPE;
    
-- problema 6
    PROCEDURE game_developer_list ( v_genre_name  genres.genre_name%TYPE );

-- problema 7
    PROCEDURE show_modes_game_list;

-- problema 8
    FUNCTION nr_clients_country_orderval ( v_country_name   address.country%TYPE,
                                           v_over           VARCHAR2 )
    RETURN NUMBER;

-- problema 9
    PROCEDURE show_ordered_games_country ( v_country_name     address.country%TYPE );
        
END games_package;
/


-------------------------------------
--------- CORPUL PACHETULUI ---------
-------------------------------------

CREATE OR REPLACE PACKAGE BODY games_package
AS
-- problema 6
-- Afisati toate titlurile de jocuri video 
-- si numele developer-ului fiecaruia care au un gen specificat de catre user.
    PROCEDURE game_developer_list ( v_genre_name  genres.genre_name%TYPE )
    AS
        v_genre_id          game_genre.genre_id%TYPE;
        v_game_id           t_game_id       := t_game_id();
        v_title             t_title         := t_title();
        v_devname           t_developer     := t_developer();
    BEGIN
    
        dbms_output.put_line('---------- ' || UPPER(v_genre_name) || ' ----------');
        
        SELECT genre_id
        INTO v_genre_id
        FROM genres
        WHERE genre_name = INITCAP(v_genre_name);
               
        SELECT game_id
        BULK COLLECT INTO v_game_id
        FROM game_genre
        WHERE genre_id = v_genre_id;
        
        IF v_game_id.COUNT != 0 THEN
            FOR i IN v_game_id.FIRST .. v_game_id.LAST LOOP
            
                SELECT title, developer_name
                BULK COLLECT INTO v_title, v_devname
                FROM games 
                JOIN game_developer USING (game_id)
                JOIN developers USING (developer_id)
                WHERE game_id = v_game_id(i);
                
                FOR j IN v_devname.FIRST .. v_devname.LAST LOOP
                    dbms_output.put_line(v_title(j) || '  -  ' || v_devname(j));
                END LOOP;
                
            END LOOP;
        ELSE 
            RAISE e_no_games;
        END IF;
    
        dbms_output.new_line;
    
    EXCEPTION
        WHEN e_no_games THEN
            dbms_output.put_line('Nu exista jocuri cu genul dorit!');
            dbms_output.new_line;
        WHEN NO_DATA_FOUND THEN
            dbms_output.put_line('Gen inexistent!');
            dbms_output.new_line;
        WHEN OTHERS THEN
            dbms_output.put_line('Alta eroare - ' || SQLERRM);
            dbms_output.new_line;
    END game_developer_list;


-- problema 7
-- Pentru fiecare mod, afisati, in ordine alfabetica, numele modului
-- si o lista cu toate jocurile care dispun de acest mod
    PROCEDURE show_modes_game_list
    AS
        v_pos       NUMBER;
        v_number    NUMBER;
    BEGIN
        
        FOR v_mode IN ( SELECT mode_id, mode_name
                        FROM modes 
                        ORDER BY mode_name )
        LOOP
            dbms_output.put_line('--------- ' || UPPER(v_mode.mode_name) || ' ---------');
            
            SELECT COUNT(*)
            INTO v_number
            FROM game_mode
            WHERE mode_id = v_mode.mode_id;
            
            dbms_output.put_line('--------- Numar de jocuri: ' || v_number);
            
            v_pos := 1;
            FOR v_title IN ( SELECT title
                             FROM games
                             JOIN game_mode USING (game_id)
                             WHERE mode_id = v_mode.mode_id )
            LOOP
                dbms_output.put_line(v_pos || '. ' || v_title.title);   
                v_pos := v_pos + 1;
            END LOOP;
            
            dbms_output.new_line;
        END LOOP;
    END show_modes_game_list;

-- problema 8
-- Calculati numarul total de clienti care traiesc intr-o tara specificata
-- si care au plasat comenzi cu o valoare totala mai mare decat o valoare data
    FUNCTION nr_clients_country_orderval ( v_country_name   address.country%TYPE,
                                           v_over           VARCHAR2 )
    RETURN NUMBER
    AS
        v_customer_id       t_customer_id   := t_customer_id();
        v_order_nr          NUMBER;
        v_number            NUMBER          := 0;
        v_limit             orders.total_price%TYPE;
    BEGIN
    
        v_limit := TO_NUMBER(v_over);
        
        SELECT customer_id
        BULK COLLECT INTO v_customer_id
        FROM customers
        WHERE address_id IN ( SELECT address_id
                              FROM address
                              WHERE LOWER(country) = LOWER(v_country_name) );
    
        IF v_customer_id.COUNT = 0 THEN
            RAISE e_no_country;
        END IF;
        
        FOR i IN v_customer_id.FIRST .. v_customer_id.LAST LOOP
                
            SELECT COUNT(DISTINCT customer_id)
            INTO v_order_nr
            FROM orders
            WHERE customer_id = v_customer_id(i)
            AND total_price >= v_limit;
            
            v_number := v_number + v_order_nr;
        END LOOP;
        
        RETURN v_number;
        
    EXCEPTION
        WHEN e_no_country THEN
            dbms_output.put_line('Nu exista clienti cu locuinta in ' || v_country_name || '!');
            RETURN -1;
        WHEN VALUE_ERROR THEN
            dbms_output.put_line('Format gresit pentru valoarea ''' || v_over || '''!');
            RETURN -6502;
        WHEN OTHERS THEN
            dbms_output.put_line('Alta eroare! - ' || SQLERRM || ' - ' || SQLCODE);
            RETURN -20005;
            
    END nr_clients_country_orderval;

-- problema 9
-- Afisati toate jocurile (titlul lor) care au fost cumparate de clienti 
-- care traiesc intr-o tara specificata si castigurile din acea tara.
    PROCEDURE show_ordered_games_country ( v_country_name     address.country%TYPE )
    AS
        v_customer_id           t_customer_id   := t_customer_id();
        v_game_temp             t_game_id       := t_game_id();
        v_game_id               t_game_id       := t_game_id();
        v_order_temp            t_orders        := t_orders();
        v_order_id              t_orders        := t_orders();
        v_price                 t_price         := t_price();
        v_title                 games.title%TYPE;
        v_profit                NUMBER;
    BEGIN
    
        dbms_output.put_line('------- ' || UPPER(v_country_name) || ' -------');
        
        SELECT customer_id
        BULK COLLECT INTO v_customer_id
        FROM customers
        WHERE address_id IN ( SELECT address_id
                              FROM address
                              WHERE LOWER(country) = LOWER(v_country_name));
        
        IF v_customer_id.COUNT = 0 THEN
            RAISE e_no_country;
        END IF;
        
        v_profit := 0;
        
        FOR i IN v_customer_id.FIRST .. v_customer_id.LAST LOOP
            SELECT order_id, total_price
            BULK COLLECT INTO v_order_temp, v_price
            FROM orders
            WHERE customer_id = v_customer_id(i);
            
            IF v_order_temp.COUNT != 0 THEN
                FOR j IN v_order_temp.FIRST .. v_order_temp.LAST LOOP
                    v_order_id.EXTEND;
                    v_order_id( v_order_id.COUNT ) := v_order_temp(j);
                    v_profit := v_profit + v_price(j);
                END LOOP;
            END IF;
            
            SELECT cashback
            BULK COLLECT INTO v_price
            FROM returns
            WHERE customer_id = v_customer_id(i);
            
            IF v_price.COUNT != 0 THEN
                FOR j IN v_price.FIRST .. v_price.LAST LOOP
                    v_profit := v_profit - v_price(j);
                END LOOP;
            END IF;
        END LOOP;
        
        IF v_order_id.COUNT = 0 THEN
            RAISE e_no_orders;
        END IF;
        
        dbms_output.put_line('PROFIT: '  || v_profit);
        
        FOR i IN v_order_id.FIRST .. v_order_id.LAST LOOP
            
            SELECT game_id
            BULK COLLECT INTO v_game_temp
            FROM order_game
            WHERE order_id = v_order_id(i);
            
            FOR j IN v_game_temp.FIRST .. v_game_temp.LAST LOOP
                v_game_id.EXTEND;
                v_game_id( v_game_id.COUNT ) := v_game_temp(j);
            END LOOP;
            
        END LOOP;
            
        v_game_id := SET(v_game_id);
        
        FOR i IN v_game_id.FIRST .. v_game_id.LAST LOOP        
            SELECT title
            INTO v_title
            FROM games
            WHERE game_id = v_game_id(i);
            
            dbms_output.put_line(v_title);        
        END LOOP;   
        
        dbms_output.new_line;
        
    EXCEPTION
        WHEN e_no_country THEN
            dbms_output.put_line('Nu exista clienti care locuiesc in ' || INITCAP(v_country_name) || '!');
            dbms_output.new_line;
        WHEN e_no_orders THEN
            dbms_output.put_line('Niciun client din ' || INITCAP(v_country_name) || ' nu a efectuat comenzi!');
            dbms_output.new_line;
        WHEN OTHERS THEN
            dbms_output.put_line('Alta eroare! - ' || SQLERRM);  
            dbms_output.new_line;
    
    END show_ordered_games_country;
    
END games_package;
/


------------------------------------------
--------- VERIFICAREA PACHETULUI ---------
------------------------------------------

-- problema 6
BEGIN
    games_package.game_developer_list('Christian');
    games_package.game_developer_list('Actiune');
    games_package.game_developer_list('Action');
    games_package.game_developer_list('&p_gen');
END;
/

-- problema 7
BEGIN
    games_package.show_modes_game_list;

END;
/

-- problema 8
DECLARE
    v_return_val    NUMBER;
    v_tara          VARCHAR2(200) := '&p_tara';
    v_val           VARCHAR2(200) := '&p_val';
BEGIN
    -- test 1
    v_return_val := games_package.nr_clients_country_orderval ('Germany', 'a');
    IF v_return_val >= 0 THEN
        dbms_output.put_line('Numarul de clienti din Germany care au efectuat '
                             || 'comenzi cu o valoare mai mare decat 10 este: ' 
                             || v_return_val);
    END IF;
    
    -- test 2           
    v_return_val := games_package.nr_clients_country_orderval ('Romania', 100);
    IF v_return_val >= 0 THEN
        dbms_output.put_line('Numarul de clienti din Romania care au efectuat '
                             || 'comenzi cu o valoare mai mare decat 100 este: ' 
                             || v_return_val);
    END IF;
    
    -- test 3           
    v_return_val := games_package.nr_clients_country_orderval (v_tara, v_val);
    IF v_return_val >= 0 THEN
        dbms_output.put_line('Numarul de clienti din ' || initcap(v_tara) || ' care au efectuat '
                             || 'comenzi cu o valoare mai mare decat ' || v_val || ' este: ' 
                             || v_return_val);
    END IF;
    
    -- test 4
    v_return_val := games_package.nr_clients_country_orderval ('Germany', 10);
    IF v_return_val >= 0 THEN
        dbms_output.put_line('Numarul de clienti din Germany care au efectuat '
                             || 'comenzi cu o valoare mai mare decat 10 este: ' 
                             || v_return_val);
    END IF;
END;
/

-- problema 9
BEGIN
    games_package.show_ordered_games_country('France');
    games_package.show_ordered_games_country('UK');
    games_package.show_ordered_games_country('Romania');
    games_package.show_ordered_games_country('Germany');
END;
/




