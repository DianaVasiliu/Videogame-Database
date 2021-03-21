CREATE SEQUENCE notification_seq
INCREMENT BY 1
START WITH 6;

-------------------------------------
------ SPECIFICATIA PACHETULUI ------
-------------------------------------
CREATE OR REPLACE
    PACKAGE extra_package
AS

    TYPE    t_games     IS TABLE OF         games.game_id%TYPE INDEX BY BINARY_INTEGER;
    TYPE    arr_games   IS VARRAY(3) OF     games.game_id%TYPE;
    
    FUNCTION get_publisher_id ( v_publisher_name   publishers.publisher_name%TYPE )
    RETURN publishers.publisher_id%TYPE;

    PROCEDURE change_price ( v_publisher_name   publishers.publisher_name%TYPE,
                             v_percentage       NUMBER );
                             
    FUNCTION calculate_price_per_publisher ( v_publisher_name   publishers.publisher_name%TYPE )
    RETURN NUMBER;
    
    PROCEDURE notify_clients ( v_text    notifications.text%TYPE );
    
    PROCEDURE show_top3_cheapest_games ( v_publisher_name   publishers.publisher_name%TYPE );
    
    CURSOR c_customer_id IS 
        SELECT customer_id
        FROM customers
        ORDER BY customer_id;
    
    CURSOR c_top3_game_id ( v_publisher_name   publishers.publisher_name%TYPE ) IS 
        SELECT game_id
        FROM ( SELECT DISTINCT game_id, price
               FROM games
               JOIN game_publisher_platform USING (game_id)
               JOIN publishers USING (publisher_id)
               WHERE LOWER(publisher_name) = LOWER(v_publisher_name)              
               ORDER BY price )
        WHERE ROWNUM <= 3;
    
    e_no_games          EXCEPTION;
    e_wrong_percentage  EXCEPTION;

END extra_package;
/


-------------------------------------
--------- CORPUL PACHETULUI ---------
-------------------------------------
CREATE OR REPLACE PACKAGE BODY extra_package
AS
    FUNCTION get_publisher_id ( v_publisher_name   publishers.publisher_name%TYPE )
    RETURN publishers.publisher_id%TYPE
    AS
        v_id            publishers.publisher_id%TYPE;
    BEGIN
        
        SELECT publisher_id
        INTO v_id
        FROM publishers
        WHERE LOWER(publisher_name) = LOWER(v_publisher_name);
        
        RETURN v_id;
        
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            dbms_output.put_line('Nu exista publisher-ul cerut!');
            RETURN -20001;
        WHEN OTHERS THEN
            dbms_output.put_line('Alta eroare! - ' || SQLERRM);
            RETURN -20000;
    END get_publisher_id;
    
    FUNCTION calculate_price_per_publisher ( v_publisher_name   publishers.publisher_name%TYPE )
    RETURN NUMBER
    AS
        v_publisher_id      publishers.publisher_id%TYPE;
        v_price             NUMBER;
    BEGIN
        v_publisher_id := extra_package.get_publisher_id(v_publisher_name);
        
        SELECT SUM(price)
        INTO v_price
        FROM games
        JOIN game_publisher_platform USING (game_id)
        WHERE publisher_id = v_publisher_id;
        
        RETURN v_price;
        
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            dbms_output.put_line('Publisher fara jocuri publicate!');
            RETURN -1;
        WHEN OTHERS THEN
            dbms_output.put_line('Alta eroare! - ' || SQLERRM);
            RETURN -20005;        
    END calculate_price_per_publisher;
    
    PROCEDURE change_price ( v_publisher_name   publishers.publisher_name%TYPE,
                             v_percentage       NUMBER )
    AS
        v_game_id           t_games;
        v_publisher_id      publishers.publisher_id%TYPE;
        v_old_sum           NUMBER;
        v_new_sum           NUMBER;
        v_notif_text        notifications.text%TYPE;
    BEGIN
    
        IF v_percentage < -1 OR v_percentage > 1 OR v_percentage = 0 THEN
            RAISE e_wrong_percentage;    
        END IF;
        
        v_publisher_id := extra_package.get_publisher_id(v_publisher_name);
        
        SELECT DISTINCT game_id
        BULK COLLECT INTO v_game_id
        FROM game_publisher_platform
        WHERE publisher_id = v_publisher_id;
    
        IF v_game_id.COUNT != 0 THEN
        
            v_old_sum := extra_package.calculate_price_per_publisher(v_publisher_name);
            
            FOR i IN v_game_id.FIRST .. v_game_id.LAST LOOP 
            
                UPDATE games
                SET price = price + v_percentage * price
                WHERE game_id = v_game_id(i);
                
            END LOOP;
            
            v_new_sum := extra_package.calculate_price_per_publisher(v_publisher_name);
            
            IF v_new_sum < v_old_sum THEN
                v_notif_text := 'Publisher ' || UPPER(v_publisher_name) || 
                                ' has changed prices of all their games! ' ||
                                'If you buy all the games you would save $' ||
                                (v_old_sum - v_new_sum) || '!';
            ELSE
                v_notif_text := 'Publisher ' || UPPER(v_publisher_name) || 
                                ' has changed prices of all their games! ' ||
                                'Guess the sale is over...';
            END IF;
        
            extra_package.notify_clients(v_notif_text);
        ELSE 
            RAISE e_no_games;
        END IF;

    EXCEPTION
        WHEN e_no_games THEN
            dbms_output.put_line('Nu exista jocuri cu publisher-ul dorit!');
        WHEN e_wrong_percentage THEN
            dbms_output.put_line('Procent invalid!');
        WHEN OTHERS THEN
            dbms_output.put_line('Alta eroare! - ' || SQLERRM);  
    END change_price;
    
    PROCEDURE notify_clients ( v_text    notifications.text%TYPE )
    AS
    BEGIN
        FOR customer IN extra_package.c_customer_id LOOP
        
            INSERT INTO notifications VALUES
            ( notification_seq.NEXTVAL,
              customer.customer_id,
              v_text,
              TO_CHAR(SYSDATE, 'DD-MON-YY'),
              0
            );
        
        END LOOP;
    END notify_clients;
        
    PROCEDURE show_top3_cheapest_games ( v_publisher_name   publishers.publisher_name%TYPE )
    AS
        v_games             arr_games := arr_games();
        v_publisher_id      publishers.publisher_id%TYPE;
        v_game_allinfo      games%ROWTYPE;
        v_temp              games.game_id%TYPE;
        v_number            NUMBER;
    BEGIN
        v_publisher_id := extra_package.get_publisher_id(v_publisher_name);
        
        OPEN extra_package.c_top3_game_id(v_publisher_name);
        
            LOOP
                FETCH extra_package.c_top3_game_id INTO v_temp;
                EXIT WHEN extra_package.c_top3_game_id%NOTFOUND;
                v_games.EXTEND;
                v_games(v_games.COUNT) := v_temp;
            END LOOP;   
        
        CLOSE extra_package.c_top3_game_id;
        
        dbms_output.put_line('------- TOP 3 CELE MAI IEFTINE -------');
        dbms_output.put_line('------- ' || UPPER(v_publisher_name) || ' -------');
        
        FOR i IN 1..3 LOOP
        
            SELECT *
            INTO v_game_allinfo
            FROM games
            WHERE game_id = v_games(i);
            
            SELECT COUNT(DISTINCT game_id)
            INTO v_number
            FROM order_game
            WHERE game_id = v_games(i);
            
            dbms_output.put_line('***************************************');
            dbms_output.put_line(v_game_allinfo.title);
            dbms_output.put_line(' -->  PRET: $' || v_game_allinfo.price);
            dbms_output.put_line(' --> NOTA: ' || v_game_allinfo.review);
            dbms_output.put_line(' --> NR. COMENZI: ' || v_number);
            dbms_output.new_line;

        END LOOP;
        
    END show_top3_cheapest_games;
    
END extra_package;
/
    


------------------------------------------
--------- VERIFICAREA PACHETULUI ---------
------------------------------------------
SELECT title, price
FROM games
JOIN game_publisher_platform USING (game_id)
JOIN publishers USING (publisher_id)
WHERE publisher_id = 2
GROUP BY title, price
ORDER BY title;

SELECT * FROM notifications;

BEGIN    
    dbms_output.put_line('Pretul tuturor jocurilor publicate de Activision: ' ||
                         extra_package.calculate_price_per_publisher('Activision'));
    
    extra_package.change_price('EA', -0.1);

    extra_package.show_top3_cheapest_games('EA');
END;
/

SELECT title, price
FROM games
JOIN game_publisher_platform USING (game_id)
JOIN publishers USING (publisher_id)
WHERE publisher_id = 2
GROUP BY title, price
ORDER BY title;

SELECT * FROM notifications;

