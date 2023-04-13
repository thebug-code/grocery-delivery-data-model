from faker import Faker
import os
import random
import csv

# Initialize Faker with 'en_US' locale
fake = Faker('en_US')

# Get the base directory where this Python script is located
basedir = os.path.abspath(os.path.dirname(__file__))

def generate_address():
    """
    Genera direciones aleatorias que corresponden a las 20 ciudades mas
    pobladas de Estados Unidos y las guarda en un archivo CSV
    """
    # Obtiene los nombres de las 20 ciudades mas pobladas de Estados Unidos
    cities = [
        'New York',
        'Los Angeles',
        'Chicago',
        'Houston',
        'Phoenix',
        'Philadelphia',
        'San Antonio',
        'San Diego',
        'Dallas',
        'San Jose',
        'Austin',
        'Fort Worth',
        'Jacksonville',
        'Columbus',
        'San Francisco',
        'Charlotte',
        'Indianapolis',
        'Seattle',
        'Denver',
        'Washington'
    ]
    
    # Define la poblacion de las 20 ciudades mas pobladas de Estados Unidos
    # (fuente: US Census Bureau, 2020)
    populations = [
        8336817,
        3970219,
        2693976,
        2320268,
        1680992,
        1584064,
        1550864,
        1423851,
        1343573, 
        1035317,
        1002668,
        927720,
        911507,
        898553,
        883305,
        875538,
        876384,
        769714,
        727211,
        693972
    ]
    
    # Define los estados de las 20 ciudades mas pobladas de Estados Unidos
    states = [
        'NY',
        'CA',
        'IL',
        'TX',
        'AZ',
        'PA',
        'TX',
        'CA',
        'TX',
        'CA',
        'TX',
        'TX',
        'FL',
        'OH',
        'CA',
        'NC',
        'IN',
        'WA',
        'CO',
        'DC'
    ]

    # Calcula la poblacion total
    total_population = sum(populations)

    # Calcula la poblacion relativa
    relative_populations = [population / total_population for population in populations]

    # Encabezados del archivo CSV
    # headers = ['Name', 'Street Address', 'City', 'State', 'Zip Code']
    headers = ['Street Address', 'City', 'State', 'Zip Code']

    # Numero minimo y maximo de direcciones a generar para cada ciudad
    min_addresses = 100
    max_addresses = 1000

    # Este archivo se guardara en la misma carpeta que este script
    file_path = os.path.join(basedir, 'us_address_data.csv')
    
    # Abre un nuevo archivo CSV en modo de escritura y escribe los encabezados
    with open(file_path, 'w', newline='') as f:
        writer = csv.writer(f)
        writer.writerow(headers)
    
        # Genera un numero aleatorio de direcciones para cada ciudad, con el
        # numero de direcciones siendo proporcional a la poblacion de la ciudad
        for i, city in enumerate(cities):
            # Calcula el numero de direcciones a generar para esta ciudad
            if i == 0:
                # Genera mas direcciones para la ciudad mas grande
                num_addresses = int(relative_populations[i] * (max_addresses - min_addresses) + min_addresses)  
            else:
                # Genera menos direcciones para las ciudades mas pequeñas
                num_addresses = int(relative_populations[i] * min_addresses)

            # Genera el numero especificado de direcciones para esta ciudad
            for j in range(num_addresses):
                # Nombre aleatorio para el destinatario
                # name = fake.name()

                # Dirección aleatoria (incluyendo el numero de apartamento o suite)
                street_address = str(random.randint(1, 9999)) + ' ' + fake.street_name() + ' ' + fake.secondary_address()

                # Obtiene el nombre de la ciudad de la lista de ciudades
                city_name = city

                # Generate a random state abbreviation
                state = states[i]

                # Zip code aleatorio
                zip_code = fake.zipcode()
    
                # Escribe la direccion en el archivo CSV
                writer.writerow([street_address, city_name, state, zip_code])

if __name__ == '__main__':
    generate_address()
