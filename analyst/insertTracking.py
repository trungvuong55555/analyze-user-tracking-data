from connect import DAL
from generate_data.utilities import random_milliseconds
from datetime import datetime
import random

dal = DAL()

number = 100000
start_date = datetime.strptime('07/06/2023 00:00:00', "%d/%m/%Y %H:%M:%S")
end_date = datetime.strptime('08/06/2023 00:00:00', "%d/%m/%Y %H:%M:%S")

for i in range(0, number):
    random_time = random_milliseconds(start_date, end_date)
    user_id = random.randrange(1, 1001, 1)
    lat = random.randrange(-5000, 5001, 1)
    lon = random.randrange(-5000, 5001, 1)

    insert_query = "insert into tracking (user_id, lat, lon, millisecond) " \
                   "values(" + str(user_id) + ", " + str(lat) + ", " + str(lon) + ", " + str(random_time) + ");"

    dal.execute_sql(insert_query)

print("Done!")

