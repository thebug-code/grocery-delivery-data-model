--UML TABLAS el Modelo.

DROP TABLE IF EXISTS ORDER_ITEM;
DROP TABLE IF EXISTS ITEM_IN_BOX;
DROP TABLE IF EXISTS BOX;
DROP TABLE IF EXISTS DELIVERY;
DROP TABLE IF EXISTS NOTES;
DROP TABLE IF EXISTS ORDER_STATUS;
DROP TABLE IF EXISTS STATUS_CATALOG;
DROP TABLE IF EXISTS PLACED_ORDER;
DROP TABLE IF EXISTS CUSTOMER;
DROP TABLE IF EXISTS CITY;
DROP TABLE IF EXISTS ITEM;
DROP TABLE IF EXISTS EMPLOYEE;
DROP TABLE IF EXISTS UNIT;


--SECCION 1
CREATE TABLE UNIT  (
	id serial PRIMARY KEY,
	unit_name varchar(64),
	unit_short varchar(8)
);

CREATE TABLE ITEM (
	id serial PRIMARY KEY,
	unit_id int,
	item_name varchar(255),
	price decimal(10,2),
	item_photo text,
	description text,
	CONSTRAINT fk_item_unit_id FOREIGN KEY (unit_id) REFERENCES unit(id)
);


--SECCION 2
CREATE TABLE EMPLOYEE (
	id serial PRIMARY KEY,
	employe_code varchar(32),
	first_name varchar(64),
	last_name varchar(64)
);

CREATE TABLE CITY (
	id serial PRIMARY KEY,
	city_name varchar(128),
	postal_code varchar(16)
);

CREATE TABLE CUSTOMER (
	id SERIAL PRIMARY KEY,
	city_id int,
	delivery_city_id int,
	first_name varchar(64),
	last_name varchar(64),
	user_name varchar(64),
	password varchar(64),
	time_inserted timestamp,
	confirmation_code varchar(255),
	time_confirmed timestamp,
	contact_email varchar(255),
	contact_phone varchar(255),
	address varchar(255),
	delivery_address varchar(255),
	CONSTRAINT fk_customer_city_id FOREIGN KEY (city_id) REFERENCES city(id),
	CONSTRAINT fk_customer_delivery_city_id FOREIGN KEY (delivery_city_id) REFERENCES city(id)
);


--SECCION 3
CREATE TABLE PLACED_ORDER(
	id SERIAL PRIMARY KEY,
	customer_id int,
	delivery_city_id int,
	time_placed timestamp,
	details text,
	delivery_addres varchar(255),
	grade_customer int,
	grade_employee int,
	CONSTRAINT fk_placed_order_customer_id FOREIGN KEY (customer_id) REFERENCES customer(id),
	CONSTRAINT fk_placed_order_delivery_city_id FOREIGN KEY (delivery_city_id) REFERENCES city(id)
);

CREATE TABLE ORDER_ITEM(
	id SERIAL PRIMARY KEY,
	placed_order_id int,
	item_id int,
	quantity decimal(10,3),
	price decimal(10,2),
	CONSTRAINT fk_order_item_placed_order_id FOREIGN KEY(placed_order_id) REFERENCES placed_order(id),
	CONSTRAINT fk_order_item_item_id FOREIGN KEY(item_id) REFERENCES item(id)
);

CREATE TABLE DELIVERY(
	id SERIAL PRIMARY KEY,
	placed_order_id int,
	employee_id int,
	delivery_time_planned timestamp,
	delivery_time_actual timestamp,
	notes text,
	CONSTRAINT fk_delivery_placed_order_id FOREIGN KEY(placed_order_id) REFERENCES placed_order(id),
	CONSTRAINT fk_delivery_employee_id FOREIGN KEY(employee_id) REFERENCES employee(id)
	
);

CREATE TABLE BOX(
	id SERIAL PRIMARY KEY,
	delivery_id int,
	employee_id int,
	box_code varchar(32),
	CONSTRAINT fk_box_delivery_id FOREIGN KEY(delivery_id) REFERENCES delivery(id),
	CONSTRAINT fk_box_employee_id FOREIGN KEY(employee_id) REFERENCES employee(id)
);

CREATE TABLE ITEM_IN_BOX(
	id SERIAL PRIMARY KEY,
	box_id int,
	item_id int,
	quantity decimal(10,3),
	is_remplacement bool,
	CONSTRAINT fk_item_in_box_box_id FOREIGN KEY(box_id) REFERENCES box(id),
	CONSTRAINT fk_item_in_box_item_id FOREIGN KEY(item_id) REFERENCES item(id)
);

CREATE TABLE STATUS_CATALOG(
	id SERIAL PRIMARY KEY,
	status_name varchar(128)
);

CREATE TABLE ORDER_STATUS(
	id SERIAL PRIMARY KEY,
	placed_order_id int,
	status_catalog_id int,
	status_time timestamp,
	details text,
	CONSTRAINT fk_order_status_placed_order_id FOREIGN KEY(placed_order_id) REFERENCES placed_order(id),
	CONSTRAINT fk_status_catalog_id FOREIGN KEY(status_catalog_id) REFERENCES status_catalog(id)
);

CREATE TABLE NOTES(
	id SERIAL PRIMARY KEY,
	placed_order_id int,
	employee_id int,
	customer_id int,
	note_time timestamp,
	note_text text,
	CONSTRAINT fk_notes_placed_order_id FOREIGN KEY(placed_order_id) REFERENCES placed_order(id),
	CONSTRAINT fk_notes_employee_id FOREIGN KEY(employee_id) REFERENCES employee(id),
	CONSTRAINT fk_notes_customer_id FOREIGN KEY(customer_id) REFERENCES customer(id)
);
