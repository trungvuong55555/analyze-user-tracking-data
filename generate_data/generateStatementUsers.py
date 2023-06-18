from faker import Faker
import random
from utilities import write_list_file

fake = Faker()
sql_file = "users.sql"
list_users = []

for i in range(1, 1001):
    name = fake.name()
    email = fake.email()
    address = str(fake.address()).replace("\n", "")
    phone = fake.phone_number()
    age = random.randrange(20, 50, 1)
    weight = random.randrange(40, 100, 1)
    high = random.randrange(150, 195, 1)

    query_insert = "insert into users (user_id, name, email ,address, phone_number, age, weight, high) " \
                   "values(" + str(i) + ", '" + name + "', '" + email + "', '" + address + "', '" + phone + "', " + str(age) + ", " + str(weight) + ", " + str(high) + ");"

    list_users.append(query_insert)

write_list_file(sql_file, list_users)
