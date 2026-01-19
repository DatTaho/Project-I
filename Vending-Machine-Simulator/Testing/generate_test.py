import os, csv
from random import randrange
from datetime import datetime, timedelta

DATA_FOLDER = "Testing/.data"
RESULT_FOLDER = "Testing/.result"

DATE_FORMAT = r"%Y-%m-%d %H:%M:%S"
START_DATE = datetime.strptime("2020-01-01 00:00:00", DATE_FORMAT)
END_DATE = datetime.strptime("2025-12-31 23:59:59", DATE_FORMAT)

DATA_SIZES = [1_000, 10_000, 100_000]
TEST_COUNTS = [100, 100, 100]
FILTER_COUNT = 100

COLUMNS = ["timestamp", "itemID", "name", "price"]
ITEMS = [
    ("P001", "Lovie", 5),
    ("P002", "Camta", 10),
    ("P003", "Stung", 12),
]


def rand_date(start=START_DATE, end=END_DATE):
    diff = end - start
    diff_seconds = (diff.days * 86400) + diff.seconds
    random_seconds = randrange(diff_seconds)
    random_date: datetime = start + timedelta(seconds=random_seconds)
    return random_date


def main():
    # Test data
    print("Creating test data")
    for size, count in zip(DATA_SIZES, TEST_COUNTS):
        test_dir = DATA_FOLDER + f"/s{size}"
        res_dir = RESULT_FOLDER + f"/s{size}"
        if os.path.isdir(test_dir) is False:
            os.makedirs(test_dir)
        if os.path.isdir(res_dir) is False:
            os.makedirs(res_dir)
        for i in range(count):
            with open(test_dir + f"/t{i+1}.csv", "w") as file:
                writer = csv.DictWriter(file, COLUMNS)
                writer.writeheader()
                for j in range(size):
                    date = rand_date().strftime(DATE_FORMAT)
                    row = (date,) + ITEMS[randrange(0, 3)]
                    writer.writerow(dict(zip(COLUMNS, row)))
                    print(
                        f"Size: {size} - File: t{i+1}/{count} - Prog: {(j+1)/size:.2%}",
                        end="\r",
                    )
        print()

    # Filters
    print("Creating filters")
    cols = ["start", "end", "itemID"]
    with open(DATA_FOLDER + "/filters.csv", "w") as file:
        writer = csv.DictWriter(file, cols)
        writer.writeheader()
        for i in range(FILTER_COUNT):
            start, end = rand_date(), rand_date()
            if start > end:
                start, end = end, start
            if (item_idx := randrange(0, 4)) == 3:
                item = "None"
            else:
                item = ITEMS[item_idx][0]
            row = (start.strftime(DATE_FORMAT), end.strftime(DATE_FORMAT), item)
            writer.writerow(dict(zip(cols, row)))
    print("Done")


if __name__ == "__main__":
    main()
