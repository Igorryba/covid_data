from sqlalchemy import create_engine
import pandas as pd
import os

covid_deaths = pd.read_excel("covid_deaths.xlsx")
covid_vaccinations = pd.read_excel("covid_vaccinations.xlsx")

engine = create_engine("postgresql+psycopg2://postgres:123456789@localhost:1234/covid_info")

covid_deaths.to_sql("covid_deaths", engine)
covid_vaccinations.to_sql("covid_vaccinations", engine)


files_path = []

directory = "./covid_tables_csv"

for filename in os.scandir(directory):
    files_path.append(os.path.split(filename))

for nr in range(0, len(files_path)):
    splitted_file = files_path[nr][1].split(".")
    data_frame = (pd.read_csv(f"{directory}/{files_path[nr][1]}"))
    data_frame.to_excel(f"{splitted_file[0]}.xlsx", index=False)



