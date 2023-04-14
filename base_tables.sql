DROP TABLE IF EXISTS US_CITIES;
DROP TABLE IF EXISTS US_ADDRESSES;
DROP TABLE IF EXISTS US_FIRST_NAMES;
DROP TABLE IF EXISTS US_LAST_NAMES;

CREATE TABLE US_CITIES (
    city varchar(128),
    zip_code varchar(5),
    state varchar(3),
    population integer
);

CREATE TABLE US_ADDRESSES (
    street varchar(128),
    city varchar(128),
    state varchar(3),
    zip_code varchar(5)
);

CREATE TABLE US_FIRST_NAMES (
    first_name varchar(128)
);

CREATE TABLE US_LAST_NAMES (
    last_name varchar(128)
);
