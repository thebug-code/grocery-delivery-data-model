DROP TABLE IF EXISTS US_CITIES;
DROP TABLE IF EXISTS US_ADDRESSES;

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
