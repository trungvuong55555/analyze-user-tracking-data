import random
import datetime
from datetime import timedelta


def write_list_file(file_name, lists):
    with open(file_name, 'w', encoding="utf8") as fp:
        for item in lists:
            fp.write("%s\n" % item)


def random_date(start, end):
    return start + datetime.timedelta(
        seconds=random.randint(0, int((end - start).total_seconds()))
    )


def random_date(start, end):
    delta = end - start
    int_delta = (delta.days * 24 * 60 * 60) + delta.seconds
    random_second = random.randrange(int_delta)
    return start + timedelta(seconds=random_second)


def random_milliseconds(start, end):
    return int(random_date(start, end).timestamp() * 1000)
