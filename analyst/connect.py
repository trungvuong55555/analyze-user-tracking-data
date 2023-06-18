import psycopg2
import config
import pandas as pd


class DAL:
    def __init__(self, database=config.database, user=config.user, password=config.password, host=config.host,
                 port=config.port, encoding=config.encoding):
        self.user = user
        self.database = database
        self.password = password
        self.host = host
        self.port = port
        self.encoding = encoding

    def __connect(self):
        try:
            conn = psycopg2.connect(dbname=self.database, user=self.user, password=self.password,
                                    host=self.host, port=self.port)
            conn.set_client_encoding(self.encoding)
            return conn
        except psycopg2.Error as error:
            print(error)
            return None

    def get_connect(self):
        return self.__connect()

    def get_table(self, query):
        try:
            conn = self.__connect()
            df_ora = pd.io.sql.read_sql_query(query, conn)
            conn.close()
            return df_ora
        except psycopg2.Error as error:
            print(error)
            return None

    def execute_sql(self, query):
        try:
            conn = self.__connect()
            cursor = conn.cursor()
            cursor.execute(query)
            conn.commit()
            conn.close()
        except psycopg2.Error as error:
            print(error)
            return None
