CREATE OR REPLACE PROCEDURE spCreateTestData(number_of_customers INTEGER, number_of_orders INTEGER, number_of_items INTEGER, avg_items_per_order NUMERIC(10,2)) 
LANGUAGE plpgsql
AS $$
DECLARE 
        -- Variables de control
        i INTEGER;
        j INTEGER;

        -- Variables para generar unidades
        unit_names VARCHAR[];
        unit_shorts VARCHAR[];
        product_unit_id INTEGER;

        -- Variables para generar productos
        product_name VARCHAR(255);
        product_description TEXT;
        product_image_url TEXT;
        product_price DECIMAL(10,2);

        -- Variables para generar empleados
        employee_code VARCHAR(32);
        employee_firstname VARCHAR(64);
        employee_lastname VARCHAR(64);

        -- Variables para generar clientes
		customer_firstname VARCHAR(50);
		customer_lastname VARCHAR(50);
	  	customer_user varchar(64);
	  	customer_password varchar(50);
        customer_time_inserted timestamp;
        customer_confirmation_code integer;
        customer_time_confirmed timestamp;
		customer_email VARCHAR(120);
	  	customer_phone varchar(12);
        customer_address varchar(255);

        total_population INTEGER;
        relative_populations FLOAT[];
		city_names varchar[];
        city_min_customers INTEGER;
        city_max_customers INTEGER;
        ith_postal_code VARCHAR;

        -- Variables para generar pedidos
        customer_id INTEGER;
        customer_city_id INTEGER;
        order_address VARCHAR(255);
        days_offset INTEGER;
        order_time_placed TIMESTAMP;

        -- Variables para generar order_items
        placed_order_row RECORD;
        item_row RECORD;
        order_quantity INTEGER;
        item_price DECIMAL(10,2);

        -- Variables para generar deliverys
        delivery_employee_id INTEGER;
        delivery_time_desired TIMESTAMP;
        delivery_time_actual TIMESTAMP;
		
		--variables par agenerar las box
		delivery_row RECORD;
		box_code VARCHAR(32);
		box_employee_id INTEGER;


BEGIN
    
    -- SECCION 1

    -- Genera las unidades
    unit_names  := ARRAY['Kilogram', 'Gram', 'Liter', 'Milliliter', 'Ounce', 'Pound', 'Pint', 'Quart', 'Gallon', 'Dozen', 'Package', 'Carton'];
    unit_shorts := ARRAY['Kg', 'g', 'L', 'mL', 'oz', 'lb', 'pt', 'qt', 'gal', 'dz', 'pkg', 'ctn'];

    -- Insertar las unidades en la tabla
    FOR i IN 1..array_upper(unit_names, 1) LOOP
        INSERT INTO UNIT (unit_name, unit_short) VALUES (unit_names[i], unit_shorts[i]);
    END LOOP;

    -- Generar <number_of_items> productos (items)
    FOR i IN 1..number_of_items LOOP
        -- Selecciona un nombre aleatorio
        SELECT name
        INTO product_name
        FROM product_names
        ORDER BY RANDOM()
        LIMIT 1;
        
        -- Selecciona una descripción aleatoria
        SELECT description
        INTO product_description
        FROM product_descriptions
        ORDER BY RANDOM()
        LIMIT 1;

        -- Selecciona una url de imagen aleatoria
        SELECT image_url
        INTO product_image_url
        FROM product_image_urls
        ORDER BY RANDOM()
        LIMIT 1;

        -- Genera un precio aleatorio
        product_price := (random() * 100)::DECIMAL(10,2);

        -- Seleciona una unidad aleatoria
        SELECT id as unit_id
        INTO product_unit_id
        FROM unit
        ORDER BY RANDOM()
        LIMIT 1;

        -- Inserta el ítem en la tabla
        INSERT INTO ITEM (unit_id, item_name, price, item_photo, description)
        VALUES (product_unit_id, product_name, product_price, product_image_url, product_description);
    END LOOP;


    -- SECCION 2
    
    -- Genera un codigo aletorio para el empleado
    SELECT SUBSTRING(md5(random()::text), 1, 6) INTO employee_code;

    -- Selecciona un nombre y apellido aleatorio
    SELECT first_name
    INTO employee_firstname
    FROM us_first_names
    ORDER BY RANDOM()
    LIMIT 1;
    
    SELECT last_name
    INTO employee_lastname
    FROM us_last_names
    ORDER BY RANDOM()
    LIMIT 1;

    -- Inserta los valores en la tabla
	INSERT INTO EMPLOYEE (employee_code, first_name, last_name) 
    VALUES (employee_code, employee_firstname, employee_lastname);

    -- Inserta la ciudades de la tabla base en el modelo
	INSERT INTO city(city_name, postal_code)
	SELECT city, postal_code FROM us_cities;
    
    -- Genera clientes tomando en cuenta la poblacion de las ciudades

    -- Calcula la poblacion total de las ciudades
    SELECT SUM(population) INTO total_population FROM us_cities;

    -- Calcula la poblacion relativa de cada ciudad
    SELECT ARRAY_AGG(population / total_population) INTO relative_populations FROM us_cities;
	 -- Crea un arreglo con los nombres de la ciudad 
	SELECT array_agg(city) INTO city_names FROM us_cities;

    FOR i IN 1..array_upper(relative_populations, 1) LOOP
        -- Calcula el número mínimo y máximo de clientes para esta ciudad
        IF i = 1 THEN
            -- La ciudad más poblada tendrá un número máximo de clientes
            -- igual a la mitad del número total de clientes a generar
            city_min_customers := 1;
            city_max_customers := (number_of_customers / 2)::INTEGER;
        ELSE
            -- Las otras ciudades tendrán un número mínimo y máximo
            city_min_customers := (number_of_customers * relative_populations[i])::INTEGER;
            city_max_customers := ((number_of_customers * relative_populations[i]) * 2)::INTEGER;
        END IF;
        
        -- Selecciona el código postal de esta ciudad
        SELECT postal_code INTO ith_postal_code FROM us_cities WHERE city = city_names[i];

        -- Genera un número aleatorio de clientes para esta ciudad
        FOR j IN 1..(random() * (city_max_customers - city_min_customers + 1) + city_min_customers)::INTEGER LOOP
            -- Selecciona un nombre y apellido aleatorio
	        SELECT first_name INTO customer_firstname
            FROM us_first_names
            ORDER BY RANDOM()
            LIMIT 1;

   	        SELECT last_name INTO customer_lastname
            FROM us_last_names
            ORDER BY RANDOM()
            LIMIT 1;

            -- Crea el nombre de usuario y contraseña
	        customer_user := CONCAT(LEFT(customer_firstname,2),'',LEFT(customer_lastname, 2),'', CAST(RANDOM() * 100 AS INTEGER));
	        customer_password := MD5(RANDOM()::TEXT);

            -- Genera un código de confirmación de 5 digitos aleatorio
            customer_confirmation_code := floor(random() * (99999 - 10000 + 1)) + 10000;
    
            -- Genera una fecha y hora aleatoria para time_inserted
            customer_time_inserted := CURRENT_TIMESTAMP - INTERVAL '1 hour' * FLOOR(RANDOM() * 24)
                                                - INTERVAL '1 minute' * FLOOR(RANDOM() * 60);

  			 -- Genera una fecha y hora aleatoria para time_confirmed
  			 customer_time_confirmed := DATE_TRUNC('hour', customer_time_inserted)
                            + INTERVAL '1 hour' * FLOOR(RANDOM() * 48)
                            + INTERVAL '1 minute' * FLOOR(RANDOM() * 60);
	        
	        -- Crea el correo electrónico
	        customer_email := CONCAT(customer_firstname, '.', customer_lastname, '@correo.com');

	        -- Genera el número de teléfono
            SELECT generate_phone_number(ith_postal_code) INTO customer_phone;

            -- Genera la dirección
            SELECT generate_address(ith_postal_code, customer_firstname, customer_lastname) INTO customer_address;

	        -- Insertar los datos en la tabla personas
	        INSERT INTO CUSTOMER (city_id, delivery_city_id, first_name, last_name, user_name ,password, time_inserted, confirmation_code, time_confirmed, contact_email, contact_phone, address, delivery_address)
	        VALUES (i, i, customer_firstname, customer_lastname, customer_user, customer_password, customer_time_inserted, customer_confirmation_code, customer_time_confirmed, customer_email, customer_phone, customer_address, customer_address);
        END LOOP;
    END LOOP;

    -- SECCION 3

    -- Generar <number_of_orders> pedidos
    FOR i IN 1..number_of_orders LOOP
        -- Selecciona un cliente al azar
        SELECT id, time_confirmed, city_id, delivery_address
        INTO customer_id, customer_time_confirmed, customer_city_id, order_address
        FROM customer
        ORDER BY RANDOM()
        LIMIT 1;

        -- Generar la fecha de colocación del pedido (entre 0 y 30 días después de la confirmación)
        days_offset := random() * 30;
		order_time_placed := date_trunc('second', customer_time_confirmed) + days_offset * interval '1 day';

        -- Inserta el pedido
        INSERT INTO PLACED_ORDER (customer_id, delivery_city_id, time_placed, details, delivery_address, grade_customer, grade_employee)
        VALUES (customer_id, customer_city_id, order_time_placed, 'Order details', order_address, NULL, NULL);
    END LOOP;

    -- Generar los item orders deacuerdo al promedio de productos por pedido
        
    -- Itera para cada placed_order
    FOR placed_order_row IN SELECT * FROM placed_order LOOP
        
        -- Genera la cantidad de productos que se incluirán en la orden
        order_quantity := ROUND(RANDOM() * (avg_items_per_order * 2) + (avg_items_per_order / 2));
        
        -- Itera para cada producto en la orden
        FOR i IN 1..order_quantity LOOP
            -- Seleciona aleatoriamente un producto y su preciro
            SELECT *
            INTO item_row
            FROM item
            ORDER BY RANDOM()
            LIMIT 1;

            item_price := item_row.price;
            
            -- Inserta la fila en la tabla ORDER_ITEM
            INSERT INTO order_item (placed_order_id, item_id, quantity, price)
            VALUES (placed_order_row.id, item_row.id, ROUND(RANDOM() * 10) + 1, item_price);
        END LOOP;
    END LOOP;
    
    -- Generar datos para tabla de delivery

    -- Itera para cada placed_order
    FOR placed_order_row IN SELECT * FROM placed_order LOOP
        -- Seleccciona un empleado al azar
        SELECT id
        INTO delivery_employee_id
        FROM employee
        ORDER BY RANDOM()
        LIMIT 1;

        -- Genera el tiempo de entrega deseado por el cliente en un rango de
        -- 1.5 a 2.5 horas después del tiempo de colocación del pedido (timed_placed)
        delivery_time_desired := placed_order_row.time_placed + INTERVAL '1 hour' * ROUND(RANDOM() * 2 + 0.5) + INTERVAL '15 minutes' * ROUND(RANDOM() * 4 + 1);

        -- Genera el tiempo de entrega actual agregando un tiempo aleatorio al tiempo de entrega planeado
        delivery_time_actual := delivery_time_desired + INTERVAL '10 minutes' * ROUND(RANDOM() * 12 + 1) +  INTERVAL '1 hour' * ROUND(RANDOM() * 2 + 0.5);

        -- Inserta la fila en la tabla DELIVERY
        INSERT INTO delivery (placed_order_id, employee_id, delivery_time_planned, delivery_time_actual, notes)
        VALUES (placed_order_row.id, delivery_employee_id, delivery_time_desired, delivery_time_actual, 'Delivery notes');
    END LOOP;
	
	 -- Generar datos para tabla box
	 FOR delivery_row IN SELECT * FROM delivery LOOP
        -- Seleccciona un empleado al azar
        SELECT id
        INTO box_employee_id
        FROM employee
        ORDER BY RANDOM()
        LIMIT 1;
		
		SELECT SUBSTRING(md5(random()::text), 1, 10) INTO box_code;
	
        -- Inserta la fila en la tabla DELIVERY
        INSERT INTO box (delivery_id, employee_id, box_code)
        VALUES (delivery_row.id,box_employee_id,box_code);
    END LOOP;
	
	
    
END;
$$; 

-- Dado el nombre y apellido de una persona y el codigo postal de la ciudad donde reside
-- genera una direccion
CREATE OR REPLACE FUNCTION generate_address(customer_postal_code VARCHAR, first_name VARCHAR, last_name VARCHAR)
RETURNS VARCHAR
LANGUAGE plpgsql
AS $$
DECLARE
    street_address VARCHAR;
    city VARCHAR;
    state VARCHAR;
    postal_code VARCHAR;

BEGIN
    SELECT street, us_cities.city, us_cities.state, us_cities.postal_code
    INTO street_address, city, state, postal_code
    FROM us_addresses
    NATURAL JOIN us_cities 
    ORDER BY RANDOM() 
    LIMIT 1;

    RETURN first_name || ' ' || last_name || ', ' || street_address || ', ' || city || ', ' || state || ' ' || postal_code;
END;
$$;



-- Dado el codigo postal de una ciudad general un numero de telefono
CREATE OR REPLACE FUNCTION generate_phone_number(postal_code VARCHAR)
RETURNS VARCHAR
LANGUAGE plpgsql
AS $$
DECLARE
    area_codee VARCHAR;
    prefix VARCHAR;
    line_number VARCHAR;
BEGIN
    -- Selecciona un area code aleatorio asociado al postal code
    SELECT area_code
    INTO area_codee
    FROM area_codes as ac
    WHERE ac.postal_code = generate_phone_number.postal_code
    ORDER BY RANDOM()
    LIMIT 1;

    -- Genera un número de teléfono aleatorio
    prefix := LPAD(FLOOR(RANDOM() * 1000)::text, 3, '0');
    line_number := LPAD(FLOOR(RANDOM() * 10000)::text, 4, '0');

    -- Retorna el número de teléfono generado
    RETURN area_codee || '-' || prefix || '-' || line_number;
END;
$$

SELECT * FROM CITY
INSERT INTO city(city_name, postal_code)
SELECT city, postal_code FROM us_cities;

DELETE FROM City

CALL spCreateTestData(10, 50, 50, 5);

SELECT * FROM CUSTOMER
SELECT * FROM CITY
SELECT * FROM ITEM
