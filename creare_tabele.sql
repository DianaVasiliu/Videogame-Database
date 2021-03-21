CREATE TABLE games (
    game_id             NUMBER(5),
    title               VARCHAR2(100),
    esrb_rating         VARCHAR2(4),
    series_id           NUMBER(5),
    review              NUMBER(3,2),
    price               NUMBER(4,2),
    description         VARCHAR2(1500)
);

CREATE TABLE game_genre (
    game_id             NUMBER(5),
    genre_id            NUMBER(5)
);

CREATE TABLE genres (
    genre_id            NUMBER(5),
    genre_name          VARCHAR2(50)    NOT NULL
);

CREATE TABLE series (
    series_id           NUMBER(5),
    series_name         VARCHAR2(40)    NOT NULL,
    release_year        NUMBER(4,0)
);

CREATE TABLE game_mode (
    game_id             NUMBER(5),
    mode_id             NUMBER(5)
);

CREATE TABLE modes (
    mode_id             NUMBER(5),
    mode_name           VARCHAR2(20)    NOT NULL
);

CREATE TABLE game_developer (
    game_id             NUMBER(5),
    developer_id        NUMBER(5)
); 

CREATE TABLE developers (
    developer_id        NUMBER(5),
    developer_name      VARCHAR2(50)    NOT NULL,
    website             VARCHAR2(50)
);

CREATE TABLE game_publisher_platform (
    game_id             NUMBER(5),
    publisher_id        NUMBER(5),
    platform_id         NUMBER(5),
    release_year        NUMBER(4,0)
);

CREATE TABLE publishers (
    publisher_id        NUMBER(5),
    publisher_name      VARCHAR2(50)    NOT NULL,
    website             VARCHAR2(50)
);

CREATE TABLE platforms (
    platform_id         NUMBER(5),
    platform_name       VARCHAR2(50)    NOT NULL
);

CREATE TABLE returns (
    return_id           NUMBER(5),
    return_date         DATE            DEFAULT SYSDATE,
    cashback            NUMBER(5,2),
    description         VARCHAR2(500),
    customer_id         NUMBER(5),
    employee_id         NUMBER(5)
);

CREATE TABLE orders (
    order_id            NUMBER(5),
    total_price         NUMBER(10,2)    NOT NULL,
    order_date          DATE            DEFAULT SYSDATE,
    customer_id         NUMBER(5),
    employee_id         NUMBER(5),
    payment_id          NUMBER(5)
);

CREATE TABLE order_game (
    order_id            NUMBER(5),
    game_id             NUMBER(5),
    platform_id         NUMBER(5),
    quantity            NUMBER(2)       NOT NULL,
    discount            NUMBER(5,2)
);

CREATE TABLE employees (
    employee_id         NUMBER(5),
    first_name          VARCHAR2(30),
    last_name           VARCHAR2(30),
    email               VARCHAR2(30)    NOT NULL,
    phone_number        VARCHAR2(20)    NOT NULL
);

CREATE TABLE customers (
    customer_id         NUMBER(5),
    first_name          VARCHAR2(30),
    last_name           VARCHAR2(30),
    join_date           DATE            DEFAULT SYSDATE,
    email               VARCHAR2(30)    NOT NULL,
    phone_number        VARCHAR2(20)    NOT NULL,
    address_id          NUMBER(5)
);

CREATE TABLE address (
    address_id          NUMBER(5),
    street              VARCHAR2(50),
    nr                  VARCHAR2(10),
    city                VARCHAR2(50),
    state_province      VARCHAR2(30),
    country             VARCHAR2(50)
);

CREATE TABLE payments (
    payment_id          NUMBER(5),
    card_number         VARCHAR2(16),
    valid               NUMBER(1)
);

CREATE TABLE notifications (
    notification_id     NUMBER(5),
    customer_id         NUMBER(5),
    text                VARCHAR2(500),
    date_created        DATE,
    seen                NUMBER(1,0)     DEFAULT 0
);