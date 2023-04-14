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

# Define los codigos postales de las 20 ciudades mas pobladas de Estados Unidos
postal_code = [
    '10001',
    '90001',
    '60601',
    '77001',
    '85001',
    '19101',
    '78201',
    '92101',
    '75201',
    '95101',
    '78701',
    '76101',
    '32201',
    '43201',
    '94101',
    '28201',
    '46201',
    '98101',
    '80201',
    '20001'
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
    headers = ['street_address', 'city', 'state', 'postal_code']

    # Rango minimo y maximo de direcciones a generar para cada ciudad
    min_addresses = 150
    max_addresses = 3000

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
                # Genera mas direcciones para la ciudad mas grande, pero limitado a 3000
                num_addresses = int(min(relative_populations[i] * max_addresses, max_addresses))
                # Genera mas direcciones para la ciudad mas grande
                # num_addresses = int(relative_populations[i] * (max_addresses - min_addresses) + min_addresses)  
            else:
                # Genera menos direcciones para las ciudades mas pequeñas
                # num_addresses = int(relative_populations[i] * min_addresses)
                # Genera menos direcciones para las ciudades mas pequeñas, pero limitado a 150
                num_addresses = int(max(relative_populations[i] * min_addresses, min_addresses))

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
                zip_code = postal_code[i]
    
                # Escribe la direccion en el archivo CSV
                writer.writerow([street_address, city_name, state, zip_code])

def build_cvs_city():
    """
    Contruye el archivo CSV con las 20 ciudades mas pobladas de Estados Unidos
    """
    # Encabezados del archivo CSV
    headers = ['city', 'postal_code', 'state', 'population']

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

            # Zip code aleatorio
            zip_code = postal_code[i]

            # Obtiene la poblacion de la ciudad de la lista de poblaciones
            population = populations[i]

            # Escribe la direccion en el archivo CSV
            writer.writerow([city_name, zip_code, state, population])
        
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
    headers = ['name']

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
        writer.writerow(['surname'])
    
        for surname in surnames:
            writer.writerow([surname])


def rebuild_csv_products():
    """
    Reconstruye el archivo CSV con los productos del dataset BigBasket Products
    """
    # Establece los nombres de archivo de entrada y salida
    input_file_path = os.path.join(basedir, 'us_data_base', 'BigBasket.csv')
    output_file_path_n = os.path.join(basedir, 'us_data', 'product_names.csv')
    output_file_path_d = os.path.join(basedir, 'us_data', 'product_brands.csv')
    output_file_path_p = os.path.join(basedir, 'us_data', 'product_prices.csv')
    output_file_path_u = os.path.join(basedir, 'us_data', 'product_image_urls.csv')
    
    # Carga el dataset de productos
    products = pd.read_csv(input_file_path)
    
    # Extrae los nombres de los productos
    product_names = products['ProductName'].unique()
    
    # Crea un archivo CSV con los nombres de los productos
    pd.DataFrame(product_names, columns=['name']).to_csv(output_file_path_n, index=False)
    
    # Extrae las descripciones de los productos
    product_descrips = products['Brand'].unique()
    
    # Crea un archivo CSV con las descripciones de los productos
    pd.DataFrame(product_descrips, columns=['brand']).to_csv(output_file_path_d, index=False)
    
    # Extrae los precios de los productos
    product_prices = products['DiscountPrice'].unique()
    
    # Crea un archivo CSV con los precios de los productos
    pd.DataFrame(product_prices, columns=['price']).to_csv(output_file_path_p, index=False)
    
    # Extrae las URLs de las imágenes de los productos
    product_image_urls = products['Image_Url'].unique()

    # Crea un archivo CSV con las URLs de las imágenes de los productos
    pd.DataFrame(product_image_urls, columns=['image_url']).to_csv(output_file_path_u, index=False)


def buid_csv_area_codes():
    """
    Construye el archivo CSV con los codigos de area de las 20 ciudades mas pobladas de Estados Unidos
    """
    area_codes = [
        ['212', '332', '646', '917'],
        ['213', '310', '323', '661', '747', '818'],
        ['312', '773', '872'],
        ['281', '346', '713', '832'],
        ['480', '602', '623', '928'],
        ['215', '267', '445', '484', '610', '717', '835', '878'],
        ['210', '726'],
        ['619', '858'],
        ['214', '469', '972'],
        ['408', '669'],
        ['512', '737'],
        ['904', '386'],
        ['682', '817'],
        ['614'],
        ['415', '628'],
        ['704', '980'],
        ['317'],
        ['206', '253', '360', '425', '564'],
        ['303', '720'],
        ['202']
    ]

    # Create a list of tuples with the area code and postal code for each city
    city_data = []
    for i, codes in enumerate(area_codes):
        zip_code = postal_code[i]
        for code in codes:
            city_data.append((code, zip_code))
    
    output_file_path = os.path.join(basedir, 'us_data', 'us_area_codes.csv')
    # Write the data to a CSV file
    with open(output_file_path, mode='w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(['area_code', 'postal_code'])
        for data in city_data:
            writer.writerow(data)
    
    
if __name__ == '__main__':
    generate_address()
    #build_cvs_city()
    #build_surnames_csv()
    rebuild_csv_products()
    #rebuild_csv_name()
    #buid_csv_area_codes()
