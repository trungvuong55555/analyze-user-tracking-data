from utilities import random_milliseconds, write_list_file
from datetime import datetime
import random
import argparse

parser = argparse.ArgumentParser(description="generate tracking data")
parser.add_argument('-f', "--file", type=str, help="name file")
parser.add_argument('-n', "--number", type=int, help="number insert to file")
parser.add_argument('-s', "--start_date", type=str, help="start date format %d-%m-%Y")
parser.add_argument('-e', "--end_date", type=str, help="end date format %d-%m-%Y")

args = parser.parse_args()
sql_file = args.file
number = args.number
start_date_str = args.start_date
end_date_str = args.end_date

start_date = datetime.strptime(start_date_str, "%d-%m-%Y").date()
end_date = datetime.strptime(end_date_str, "%d-%m-%Y").date()

list_tracking = []

for i in range(0, number):
    random_time = random_milliseconds(start_date, end_date)
    user_id = random.randrange(1, 1001, 1)
    lat = random.randrange(-5000, 5001, 1)
    lon = random.randrange(-5000, 5001, 1)

    insert_query = "insert into tracking (user_id, lat, lon, millisecond) " \
                   "values(" + str(user_id) + ", " + str(lat) + ", " + str(lon) + ", " + str(random_time) + ");"

    list_tracking.append(insert_query)

write_list_file(sql_file, list_tracking)

print("Done!")
