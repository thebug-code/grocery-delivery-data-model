CREATE FUNCTION spCreateTestData(number_of_customers INTEGER, number_of_orders INTEGER,number_of_items INTEGER, avg_items_per_order varchar(10,2) ) 
RETURNS VOID AS $$
DECLARE 
		city_numbers CONSTANT INT :=15;
		customer_firstname VARCHAR(50);
		customer_lastname VARCHAR(50);
		customer_email VARCHAR(120);
	  	customer_phone varchar(12);
	  	area_code varchar(3);
	 	central_number varchar(3);
	  	final_number varchar(4);
	  	customer_user varchar(100);
	  	customer_paswword varchar(50);

BEGIN
--INSERTA LAS CIUDADES DE LA TABLA BASE CON MAS DATOS A LA DEL MODELO
	INSERT INTO CITY (city_name,postal_code)
  	SELECT city, postal_code FROM city_base_table
  
--INSERTA EL NUMERO DE CLIENTES
  	FOR i IN 1..number_of_customers LOOP
		SELECT first_name INTO people_firstname FROM us_first_names ORDER BY RANDOM() LIMIT 1;
   		SELECT las_name INTO people_lastname FROM us_last_names ORDER BY RANDOM() LIMIT 1;
		

		-- Crear el correo electrónico
		customer_email := CONCAT(people_firstname, '.', people_lastname, '@correo.com');

		-- Generar el número de teléfono
		SELECT ac.area_code INTO area_code FROM area_codes as ac ORDER BY RANDOM() LIMIT 1;
		central_number := LPAD(FLOOR(RANDOM() * 1000)::TEXT, 3, '0');
		final_number := LPAD(FLOOR(RANDOM() * 10000)::TEXT, 4, '0');
		customer_phone := CONCAT(area_code, '-', central_number, '-', final_number);

		-- Crear el nombre de usuario y contraseña
		customer_user := CONCAT(customer_firstname, LEFT(customer_lastname, 1), FLOOR(RANDOM() * 100));
		customer_password := MD5(RANDOM()::TEXT);
		
		 -- Insertar los datos en la tabla personas
		INSERT INTO CUSTOMER (nombre, apellido, correo, telefono, usuario, password) 
		VALUES (nombre_persona, apellido_persona, correo_persona, telefono_persona, usuario_persona, contrasena_persona);

END;
$$ LANGUAGE plpgsql;





CREATE TABLE AREA_CODES (
  id SERIAL PRIMARY KEY,
  area_code VARCHAR(3),
  postal_code VARCHAR(50),
  CONSTRAINT fk_area_code_postal_code FOREIGN KEY(postal_code) REFERENCES us_cities(postal_code)
);


SELECT *
from us_cities