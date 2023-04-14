CREATE FUNCTION spCreateTestData(number_of_customers INTEGER, number_of_orders INTEGER, number_of_items INTEGER, avg_items_per_order varchar(10,2)) 
RETURNS VOID AS $$
DECLARE 
		customer_firstname VARCHAR(50);
		customer_lastname VARCHAR(50);
	  	customer_user varchar(100);
	  	customer_paswword varchar(50);
		customer_email VARCHAR(120);
	  	customer_phone varchar(12);
        customer_address varchar(255);
        total_population INTEGER;
        relative_populations FLOAT[];
        city_min_customers INTEGER;
        city_max_customers INTEGER;

BEGIN

    --Inserta la ciudades de la tabla base en el modelo
	INSERT INTO CITY (city_name, postal_code)
  	SELECT city, postal_code FROM city_base_table

    -- Calcula la poblacion total de las ciudades
    SELECT SUM(population) INTO total_population FROM us_cities;

    -- Calcula la poblacion relativa de cada ciudad
    SELECT ARRAY_AGG(population / total_population) INTO relative_populations FROM us_cities;

    FOR i IN 1..array_upper(relative_populations, 1) LOOP
        -- Calcula el número mínimo y máximo de clientes para esta ciudad
        IF i = 1 THEN
            -- La ciudad más poblada tendrá un número máximo de clientes
            -- igual a la mitad del número total de clientes a generar
            city_min_customers := 1;
            city_max_customers := (num_customers / 2)::INTEGER;
        ELSE
            -- Las otras ciudades tendrán un número mínimo y máximo
            -- de clientes proporcional a su población relativa
            city_min_customers := (num_customers * relative_populations[i])::INTEGER;
            city_max_customers := ((num_customers * relative_populations[i]) * 2)::INTEGER;
        END IF;

        -- Genera un número aleatorio de clientes para esta ciudad
        FOR j IN 1..(random() * (city_max_customers - city_min_customers + 1) + city_min_customers)::INTEGER LOOP
            -- Crear nombre de la persona
	        SELECT first_name INTO customer_firstname FROM us_first_names ORDER BY RANDOM() LIMIT 1;
   	        SELECT las_name INTO customer_lastname FROM us_last_names ORDER BY RANDOM() LIMIT 1;

            -- Crear el nombre de usuario y contraseña
	        customer_user := CONCAT(customer_firstname, LEFT(customer_lastname, 1), FLOOR(RANDOM() * 100));
	        customer_password := MD5(RANDOM()::TEXT);
	        
	        -- Crear el correo electrónico
	        customer_email := CONCAT(customer_firstname, '.', customer_lastname, '@correo.com');

	        -- Generar el número de teléfono
            SELECT generate_phone_number(postal_code) INTO customer_phone;

            -- Generar la dirección
            SELECT generate_address(postal_code, customer_firstname, customer_lastname) INTO customer_address;

            -- i es la ciudad actual
	        
	         -- Insertar los datos en la tabla personas
	        -- INSERT INTO CUSTOMER (nombre, apellido, correo, telefono, usuario, password) 
	        -- VALUES (nombre_persona, apellido_persona, correo_persona, telefono_persona, usuario_persona, contrasena_persona);

END;
$$ LANGUAGE plpgsql;

-- Dado el nombre y apellido de una persona y el codigo postal de la ciudad donde reside
-- genera una direccion
CREATE OR REPLACE FUNCTION generate_address(customer_postal_code VARCHAR, first_name VARCHAR, last_name VARCHAR)
RETURNS VARCHAR AS $$
DECLARE
    street_address VARCHAR;
    city VARCHAR;
    state VARCHAR;
    postal_code VARCHAR;

BEGIN
    SELECT street, us_cities.city, us_cities.state, us_cities.postal_code
    INTO street_address, city, state, postal_code
    FROM us_addresses
    JOIN us_cities ON us_cities.postal_code == us_addresses.postal_code
    ORDER BY RANDOM() 
    LIMIT 1;

    RETURN first_name || ' ' || last_name || ', ' || street_address || ', ' || city || ', ' || state || ' ' || postal_code;
END;
$$ LANGUAGE plpgsql;


-- Dado el codigo postal de una ciudad general un numero de telefono
CREATE OR REPLACE FUNCTION generate_phone_number(postal_code VARCHAR)
RETURNS VARCHAR AS $$
DECLARE
    area_code VARCHAR;
    prefix VARCHAR;
    line_number VARCHAR;
BEGIN
    -- Selecciona un area code aleatorio asociado al postal code
    SELECT area_code
    INTO area_code
    FROM us_area_codes
    WHERE postal_code = generate_phone_number.postal_code
    ORDER BY RANDOM()
    LIMIT 1;

    -- Genera un número de teléfono aleatorio
    prefix := LPAD(FLOOR(RANDOM() * 1000)::text, 3, '0');
    line_number := LPAD(FLOOR(RANDOM() * 10000)::text, 4, '0');

    -- Retorna el número de teléfono generado
    RETURN area_code || '-' || prefix || '-' || line_number;
END;
$$ LANGUAGE plpgsql;
