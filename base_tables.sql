DROP TABLE IF EXISTS US_CITIES;
DROP TABLE IF EXISTS US_ADDRESSES;
DROP TABLE IF EXISTS US_FIRST_NAMES;
DROP TABLE IF EXISTS US_LAST_NAMES;
DROP TABLE IF EXISTS US_AREA_CODES;
DROP TABLE IF EXISTS US_STATUS;
DROP TABLE IF EXISTS PRODUCT_NAMES;
DROP TABLE IF EXISTS PRODUCT_DESCRIPTIONS;
DROP TABLE IF EXISTS PRODUCT_IMAGE_URLS;
DROP TABLE IF EXISTS PRODUCT_PRICES;
DROP TABLE IF EXISTS US_UNITS;

CREATE TABLE US_CITIES (
    city varchar(128),
    postal_code varchar(5) PRIMARY KEY,
    state varchar(3),
    population integer
);

CREATE TABLE US_ADDRESSES (
    id SERIAL PRIMARY KEY,
    street varchar(128),
    city varchar(128),
    state varchar(3),
    postal_code varchar(5),
    CONSTRAINT fk_us_addresses_postal_code FOREIGN KEY(postal_code) REFERENCES us_cities(postal_code)
);

CREATE TABLE US_FIRST_NAMES (
    first_name varchar(128)
);

CREATE TABLE US_LAST_NAMES (
    last_name varchar(128)
);

CREATE TABLE US_AREA_CODES (
  id SERIAL PRIMARY KEY,
  area_code Varchar(3),
  postal_code VARCHAR(50),
  CONSTRAINT fk_area_code_postal_code FOREIGN KEY(postal_code) REFERENCES us_cities(postal_code)
);

CREATE TABLE PRODUCT_NAMES (
  id SERIAL PRIMARY KEY,
  name varchar(255)
);

CREATE TABLE PRODUCT_DESCRIPTIONS (
  id SERIAL PRIMARY KEY,
  description text
);

CREATE TABLE PRODUCT_IMAGE_URLS (
  id SERIAL PRIMARY KEY,
  image_url text
);

CREATE TABLE PRODUCT_PRICES (
  id SERIAL PRIMARY KEY,
  price decimal(10,2)
);

CREATE TABLE US_STATUS (
  status_name VARCHAR(150)
);

CREATE TABLE US_UNITS (
    unit_name varchar(64),
    unit_short varchar(8)
);
