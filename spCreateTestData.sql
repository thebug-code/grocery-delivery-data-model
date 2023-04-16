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
	  	customer_phone_number varchar(12);
        customer_address varchar(255);

        total_population INTEGER;
        customer_city_id INTEGER;
        customer_city_population INTEGER;
        customer_city_name VARCHAR(128);
        customer_postal_code VARCHAR;
        city_min_customers INTEGER;
        city_max_customers INTEGER;

        -- Variables para generar pedidos
        customer_id INTEGER;
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
		
        -- Variables para generar boxes
        delivery_row RECORD;
        box_code VARCHAR(32);
        box_employee_id INTEGER;
        delivery_id INTEGER;
        box_row RECORD;
        order_item_row RECORD;
		
		--variable para los status
		status_name VARCHAR(50);
		status_row RECORD;
		status_time timestamp;
		random_seconds INTEGER;

BEGIN
    
    -- SECCION 1

    -- Insertar las unidades en la tabla
	INSERT INTO UNIT (unit_name, unit_short)
    SELECT unit_name, unit_short FROM us_units;

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
    
    -- Genera empleados
    FOR i IN 1..200 LOOP
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
    END LOOP;

    -- Inserta la ciudades de la tabla base en el modelo
	INSERT INTO CITY (city_name, postal_code)
  	SELECT city, postal_code FROM us_cities;
     
    -- Genera clientes tomando en cuenta la poblacion de las ciudades

    -- Calcula la poblacion total de las ciudades
    SELECT SUM(population) INTO total_population FROM us_cities;

    -- Genera los clientes
    FOR i IN 1..number_of_customers LOOP
        -- Selecciona una ciudad al azar, ponderando por la población relativa
        SELECT city
        FROM us_cities
        ORDER BY random() * population DESC
        LIMIT 1 INTO customer_city_name;
        
        -- Calcula el número mínimo y máximo de clientes para la ciudad seleccionada
        SELECT population
        FROM us_cities
        WHERE city = customer_city_name
        INTO customer_city_population;
        
        city_min_customers := (number_of_customers * (customer_city_population / total_population))::INTEGER;
        city_max_customers := ((number_of_customers * (customer_city_population / total_population)) * 2)::INTEGER;

        -- Selecciona el id y el código postal de esta ciudad
        SELECT id, postal_code
        INTO customer_city_id, customer_postal_code
        FROM city
        WHERE city_name = customer_city_name;

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
        customer_time_inserted := CURRENT_TIMESTAMP - (CAST(CAST(floor(random() * 24) AS TEXT) || ' hour' AS INTERVAL) + CAST(CAST(floor(random() * 60) AS TEXT) || ' minute' AS INTERVAL));

        -- Genera una fecha y hora aleatoria para time_confirmed
        customer_time_confirmed := date_trunc('hour', customer_time_inserted) + CAST(CAST(floor(random() * 48) AS TEXT) || ' hour' AS INTERVAL) + CAST(CAST(floor(random() * 60) AS TEXT) || ' minute' AS INTERVAL);
	    
	    -- Crea el correo electrónico
        customer_email := CONCAT(customer_firstname, '.', customer_lastname, '@correo.com');

	    -- Genera el número de teléfono
        SELECT generate_phone_number(customer_postal_code) INTO customer_phone_number;

        -- Genera la dirección
        SELECT generate_address(customer_postal_code, customer_firstname, customer_lastname) INTO customer_address;

	    -- Insertar los datos en la tabla personas
	    INSERT INTO CUSTOMER (city_id, delivery_city_id, first_name, last_name, user_name,password, time_inserted, confirmation_code, time_confirmed, contact_email, contact_phone, address, delivery_address)
	    VALUES (customer_city_id, customer_city_id, customer_firstname, customer_lastname, customer_user,customer_password,customer_time_inserted, customer_confirmation_code, customer_time_confirmed, customer_email, customer_phone_number, customer_address, customer_address);
    END LOOP;
    
    -- SECCION 3

	-- Generar datos para tabla Status
	INSERT INTO status_catalog(status_name)
	SELECT us_status.status_name FROM us_status;
	
    -- Generar <number_of_orders> pedidos
    FOR i IN 1..number_of_orders LOOP
        -- Selecciona un cliente al azar
        SELECT id, time_confirmed, city_id, delivery_address
        INTO customer_id, customer_time_confirmed, customer_city_id, order_address
        FROM customer
        ORDER BY RANDOM()
        LIMIT 1;

        -- Generar la fecha de colocación del pedido (entre 0 y 30 días después de la confirmación)
        days_offset := trunc(random() * 30);
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
    
	
    -- Itera para cada placed_order
    FOR placed_order_row IN SELECT * FROM placed_order LOOP
        -- Seleccciona un empleado al azar
        SELECT id
        INTO delivery_employee_id
        FROM employee
        ORDER BY RANDOM()
        LIMIT 1;

        -- Genera el tiempo de entrega deseado por el cliente en un rango de
        -- +20 Minutos y 1 hora maximo después del tiempo de colocación del pedido (timed_placed) 
       delivery_time_desired := placed_order_row.time_placed + INTERVAL '1 minute' * ROUND(RANDOM() * 60) + INTERVAL '20 minute' ;		
		
		--SELECCIONA UN STATUS
		SELECT * into status_row
		FROM status_catalog
		ORDER BY RANDOM()
		LIMIT 1;
			
		IF status_row.status_name = 'delivered' THEN
			
			-- Generar un número aleatorio entre 0 y 1 y multiplicarlo por la diferencia en segundos entre las dos fechas
  			random_seconds := trunc(random() * EXTRACT(EPOCH FROM (delivery_time_desired  - placed_order_row.time_placed)));

  			-- Sumar los segundos aleatorios al timestamp inicial para obtener el nuevo timestamp aleatorio
  			status_time :=  placed_order_row.time_placed + (random_seconds * INTERVAL '1 second');
			
			-- Genera el tiempo de entrega actual agregando un tiempo aleatorio al tiempo de entrega planeado
      		delivery_time_actual := status_time + INTERVAL '1 minute' * ROUND(RANDOM() * 60) + INTERVAL '5 minute' ;
			
			INSERT INTO order_status (placed_order_id,status_catalog_id,status_time)
			VALUES (placed_order_row.id,status_row.id,delivery_time_actual);
		ELSE
			--Esta en transito
			delivery_time_actual := NULL;
			
			-- Generar un número aleatorio entre 0 y 1 y multiplicarlo por la diferencia en segundos entre las dos fechas
  			random_seconds := trunc(random() * EXTRACT(EPOCH FROM (delivery_time_desired  - placed_order_row.time_placed)));

  			-- Sumar los segundos aleatorios al timestamp inicial para obtener el nuevo timestamp aleatorio
  			status_time :=  placed_order_row.time_placed + (random_seconds * INTERVAL '1 second');
			
			INSERT INTO order_status (placed_order_id,status_catalog_id,status_time)
			VALUES (placed_order_row.id,status_row.id,status_time);
		END IF;
		
        -- Inserta la fila en la tabla DELIVERY
        INSERT INTO delivery (placed_order_id, employee_id, delivery_time_planned, delivery_time_actual, notes)
        VALUES (placed_order_row.id, delivery_employee_id, delivery_time_desired, delivery_time_actual, 'Delivery notes');
		
    END LOOP;

    -- Generar entradas para la tabla box y item_in_box

    -- Itera para cada delivery
    FOR delivery_row IN SELECT * FROM delivery LOOP
        -- Obtiene el pedido correspondiente a esta entrega
        SELECT *
        INTO placed_order_row
        FROM placed_order
        WHERE id = delivery_row.placed_order_id;

        -- Seleciona un empleado al azar
        SELECT id
        INTO box_employee_id
        FROM employee WHERE id <> delivery_row.employee_id
        ORDER BY RANDOM()
        LIMIT 1;
        
        -- Itera para cada item_order de este pedido y se colócalo en una caja
        FOR order_item_row IN SELECT * FROM order_item WHERE placed_order_id = placed_order_row.id LOOP
            -- Genera un código único para la caja
            box_code := CONCAT('BOX-', delivery_row.id, '-', SUBSTRING(md5(random()::text), 1, 3));

            INSERT INTO box (delivery_id, employee_id, box_code) 
            VALUES (delivery_row.id, box_employee_id, box_code);

            -- Selecciona la fila recién creada
            SELECT *
            INTO box_row
            FROM box
            WHERE id = currval(pg_get_serial_sequence('box', 'id'));

            -- Inserta la fila en la tabla ITEM_IN_BOX
            INSERT INTO item_in_box (box_id, item_id, quantity, is_replacement)
            VALUES (box_row.id, order_item_row.item_id, order_item_row.quantity, FALSE);
        END LOOP;
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
    area_code VARCHAR;
    prefix VARCHAR;
    line_number VARCHAR;
BEGIN
    -- Selecciona un area code aleatorio asociado al postal code
    SELECT ac.area_code
    INTO area_code
    FROM us_area_codes ac
    WHERE ac.postal_code = generate_phone_number.postal_code
    ORDER BY RANDOM()
    LIMIT 1;

    -- Genera un número de teléfono aleatorio
    prefix := LPAD(FLOOR(RANDOM() * 1000)::text, 3, '0');
    line_number := LPAD(FLOOR(RANDOM() * 10000)::text, 4, '0');

    -- Retorna el número de teléfono generado
    RETURN area_code || '-' || prefix || '-' || line_number;
END;
$$
