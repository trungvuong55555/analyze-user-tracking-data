import random
import datetime


def write_list_file(file_name, lists):
    with open(file_name, 'w', encoding="utf8") as fp:
        for item in lists:
            fp.write("%s\n" % item)


def random_date(start, end):
    return start + datetime.timedelta(
        seconds=random.randint(0, int((end - start).total_seconds()))
    )


def random_milliseconds(start, end):
    return random.randint(0, int((end - start).total_seconds() * 1000))
