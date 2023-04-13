from faker import Faker
import os
import random
import requests
import csv
import pandas as pd

# Initialize Faker with 'en_US' locale
fake = Faker('en_US')

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

# Get the base directory where this Python script is located
basedir = os.path.abspath(os.path.dirname(__file__))

def generate_address():
    """
    Genera direciones aleatorias que corresponden a las 20 ciudades mas
    pobladas de Estados Unidos y las guarda en un archivo CSV
    """
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

    # Este archivo se guardara en la carpeta us_data
    file_path = os.path.join(basedir, 'us_data', 'us_addresses.csv')
    
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

def build_cvs_city():
    """
    Contruye el archivo CSV con las 20 ciudades mas pobladas de Estados Unidos
    """
    # Encabezados del archivo CSV
    headers = ['City', 'State', 'Population']

    # Este archivo se guardara en la carpeta us_data
    file_path = os.path.join(basedir, 'us_data', 'us_cities.csv')
    
    # Abre un nuevo archivo CSV en modo de escritura y escribe los encabezados
    with open(file_path, 'w', newline='') as f:
        writer = csv.writer(f)
        writer.writerow(headers)

        for i, city in enumerate(cities):
            # Obtiene el nombre de la ciudad de la lista de ciudades
            city_name = city

            # Generate a random state abbreviation
            state = states[i]

            # Obtiene la poblacion de la ciudad de la lista de poblaciones
            population = populations[i]

            # Escribe la direccion en el archivo CSV
            writer.writerow([city_name, state, population])
        
def rebuild_csv_name():
    """
    Recontruye el archivo CSV babynames-clean.csv con los nombres mas comunes
    de bebes nacidos en Estados Unidos
    """
    # Lee el archivo CSV con los datos
    df = pd.read_csv('https://query.data.world/s/abwjmshzgnttjwnowziip2h2srni6k?dws=00000')
    data = df.values
    
    # Extrae los nombres y los guarda en una lista
    names = [name[0] for name in data]

    # Encabezados del archivo CSV
    headers = ['Name']

    # Output file path
    file_path = os.path.join(basedir, 'us_data', 'us_names.csv')

    # Escribir los nombres en el archivo CSV
    with open(file_path, 'w', newline='') as f:
        writer = csv.writer(f)
        writer.writerow(headers)

        # Escribe los nombres en el archivo CSV
        for name in names:
            writer.writerow([name])


def build_surnames_csv():
    """
    Construye el archivo CSV con los 1000 apellidos mas comunes en Estados Unidos
    """
    # Set the API endpoint URL
    url = 'https://api.census.gov/data/2010/surname'
    api_key = '2a11f280de217a1af0066795ea6e5345f4e0e758'


    # Set the query parameters
    params = {
        'get': 'NAME,COUNT',
        'RANK': '1:1000',
        'key': api_key
    }
    
    # Send an HTTP GET request to the API endpoint with the specified parameters
    response = requests.get(url, params=params)
    
    # Pasea la respuesta JSON y extrae los apellidos
    data = response.json()
    surnames = [row[0] for row in data[1:]]
    
    # Este archivo se guardara en la misma carpeta us_data
    file_path = os.path.join(basedir, 'us_data', 'us_surnames.csv')
    
    # Escribe los apellidos en el archivo CSV
    with open(file_path, 'w', newline='') as f:
        writer = csv.writer(f)
        writer.writerow(['Surname'])
    
        for surname in surnames:
            writer.writerow([surname])


def rebuild_csv_products():
    """
    Reconstruye el archivo CSV con los productos del dataset BigBasket Products
    """
    # Establece los nombres de archivo de entrada y salida
    input_file_path = os.path.join(basedir, 'us_data_base', 'BigBasket.csv')
    output_file_path = os.path.join(basedir, 'us_data', 'products.csv')
    
    # Extract the 'Product Name', 'Discounted Price', 'Image url', and 'Category' columns
    columns_to_extract = [0, 3, 4, 6]
    
    # Lee el archivo CSV de entrada como una lista de listas
    with open(input_file_path, 'r', newline='') as csvfile:
        reader = csv.reader(csvfile)
        data = [row for row in reader]
    
    # Extrae las columnas deseadas en una nueva lista de listas
    new_data = [[row[i] for i in columns_to_extract] for row in data]
    
    # Escriba la nueva lista de listas en el archivo CSV de salida
    with open(output_file_path, 'w', newline='') as csvfile:
        writer = csv.writer(csvfile)
        writer.writerows(new_data)
    
    
if __name__ == '__main__':
    #generate_address()
    #build_cvs_city()
    #build_surnames_csv()
    #rebuild_csv_products()
    rebuild_csv_name()
