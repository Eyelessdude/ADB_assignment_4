# Insertions to DB
from math import floor

from faker import Faker
import random

fake = Faker("en_US")

shoesStyle = [
    "boots",
    "high-heels",
    "flats",
    "sandals",
    "trainers",
    "elegant",
    "sneakers",
    "oxfords",
    "chelsea",
]
months = ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"]
year = ["2020", "2021", "2022", "2023", "2025", "2026"]
card = ["visa", "mastercard", "discover", "amex"]
state_names = [
    "Alaska",
    "Alabama",
    "Arkansas",
    "American Samoa",
    "Arizona",
    "California",
    "Colorado",
    "Connecticut",
    "District ",
    "of Columbia",
    "Delaware",
    "Florida",
    "Georgia",
    "Guam",
    "Hawaii",
    "Iowa",
    "Idaho",
    "Illinois",
    "Indiana",
    "Kansas",
    "Kentucky",
    "Louisiana",
    "Massachusetts",
    "Maryland",
    "Maine",
    "Michigan",
    "Minnesota",
    "Missouri",
    "Mississippi",
    "Montana",
    "North Carolina",
    "North Dakota",
    "Nebraska",
    "New Hampshire",
    "New Jersey",
    "New Mexico",
    "Nevada",
    "New York",
    "Ohio",
    "Oklahoma",
    "Oregon",
    "Pennsylvania",
    "Puerto Rico",
    "Rhode Island",
    "South Carolina",
    "South Dakota",
    "Tennessee",
    "Texas",
    "Utah",
    "Virginia",
    "Virgin Islands",
    "Vermont",
    "Washington",
    "Wisconsin",
    "West Virginia",
    "Wyoming",
]

NUMBER_OF_PRODUCTS = 80000
NUMBER_OF_CLIENTS = 96000
NUMBER_OF_SPECIAL_OFFERS = 35000
NUMBER_OF_PAYMENTS = floor(NUMBER_OF_CLIENTS * 1.1)
NUMBER_OF_REVIEWS = floor(NUMBER_OF_PRODUCTS * 1.1)
NUMBER_OF_ORDERS = 125000


def insert_product():
    f = open("demofile2.txt", "a")
    for _ in range(NUMBER_OF_PRODUCTS):
        f.write(
            'INSERT INTO PRODUCT(PRODUCTID, EAN, TITLE, "size", DESCRIPTION, STYLE, PRICE) VALUES ('
            + str(_ + 1)
            + ", "
            + str(random.randint(1000000000000, 9999999999999))
            + ", '"
            + fake.text(20)
            + "', "
            + str(random.randint(0, 9))
            + ", '"
            + fake.text(30)
            + "', '"
            + shoesStyle[random.randint(0, len(shoesStyle) - 1)]
            + "', "
            + str(random.randint(9, 999))
            + ");\n"
        )
    f.close()


def insert_client():
    f = open("demofile2.txt", "a")
    for _ in range(NUMBER_OF_CLIENTS):
        f.write(
            "INSERT INTO CLIENT(CLIENTID, FIRSTNAME, LASTNAME, PHONE, EMAIL, PASSWORD) VALUES("
            + str(_ + 1)
            + ", '"
            + fake.first_name()
            + "', "
            + "'"
            + fake.last_name()
            + "', '"
            + str(random.randint(1000000000, 9999999999))
            + "', "
            + "'"
            + fake.email()
            + "', "
            + "'"
            + fake.md5()
            + "');\n"
        )
    f.close()


def insert_special_offer():
    f = open("demofile2.txt", "a")
    for _ in range(NUMBER_OF_SPECIAL_OFFERS):
        f.write(
            "INSERT INTO SPECIALOFFER(OFFERID, NAME, DESCRIPTION, STARTDATE, ENDDATE, PERCENTDISCOUNT) VALUES ("
            + str(_ + 1)
            + ", '"
            + fake.text(50)
            + "', "
            + "'"
            + fake.text(20)
            + "', '"
            + str(fake.past_datetime())
            + "', '"
            + str(fake.future_datetime())
            + "', "
            + str(random.randint(5, 95))
            + ");\n"
        )
    f.close()


def insert_payment():
    f = open("demofile2.txt", "a")
    for _ in range(NUMBER_OF_PAYMENTS):
        f.write(
            "INSERT INTO PAYMENT(PAYMENTID, CARDNUMBER, EXPMONTH, EXPYEAR, CARDTYPE, CLIENTID, ADDRESSID) VALUES ("
            + str(_ + 1)
            + ", "
            + str(random.randint(1000000000000000, 9999999999999999))
            + ", "
            + months[random.randint(0, 11)]
            + ", "
            + year[random.randint(0, 5)]
            + ", '"
            + card[random.randint(0, 3)]
            + "', "
            + str(random.randint(1, NUMBER_OF_CLIENTS))
            + ", "
            + str(random.randint(1, NUMBER_OF_PAYMENTS))
            + ");\n"
        )
    f.close()


def insert_address():
    f = open("demofile2.txt", "a")
    for _ in range(NUMBER_OF_PAYMENTS):
        f.write(
            "INSERT INTO ADDRESS(ADDRESSID, LINE1, LINE2, CITY, STATE, POSTALCODE, CLIENTID) VALUES ("
            + str(_ + 1)
            + ", '"
            + fake.street_name()
            + "', '"
            + fake.building_number()
            + "', '"
            + fake.city()
            + "', '"
            + state_names[random.randint(0, len(state_names) - 1)]
            + "', "
            + str(fake.postalcode())
            + ", "
            + str(random.randint(1, NUMBER_OF_CLIENTS))
            + ");\n"
        )
    f.close()


def insert_review():
    f = open("demofile2.txt", "a")
    for _ in range(NUMBER_OF_REVIEWS):
        f.write(
            "INSERT INTO REVIEW(REVIEWID, TITLE, REVIEWDATE, STARS, TEXT, CLIENTID, PRODUCTID) VALUES ("
            + str(_ + 1)
            + ", '"
            + fake.text(50)
            + "', '"
            + str(fake.past_datetime())
            + "', "
            + str(random.randint(0, 5))
            + ", '"
            + fake.text(30)
            + "', "
            + str(random.randint(1, NUMBER_OF_CLIENTS))
            + ", "
            + str(random.randint(1, NUMBER_OF_PRODUCTS))
            + ");\n"
        )
    f.close()


def insert_order():
    f = open("demofile2.txt", "a")
    for _ in range(NUMBER_OF_ORDERS):
        f.write(
            'INSERT INTO "Order"(ORDERID, ORDERDATE, DUEDATE, STATUS, SUBTOTAL, TOTAL, CLIENTID, PAYMENTID) VALUES ('
            + str(_ + 1)
            + ", '"
            + str(fake.past_datetime())
            + "', '"
            + str(fake.future_datetime())
            + "', "
            + str(random.randint(0, 1))
            + ", "
            + str(random.randint(1, 1000))
            + ", "
            + str(random.randint(0, 5000))
            + ", "
            + str(random.randint(1, NUMBER_OF_CLIENTS))
            + ", "
            + str(random.randint(1, NUMBER_OF_PAYMENTS))
            + ");\n"
        )
    f.close()


def insert_product_order():
    f = open("demofile2.txt", "a")
    for _ in range(NUMBER_OF_ORDERS):
        f.write(
            "INSERT INTO PRODUCT_ORDER(PRODUCTID, ORDERID) VALUES ("
            + str(random.randint(1, NUMBER_OF_PRODUCTS))
            + ", "
            + str(random.randint(1, NUMBER_OF_ORDERS))
            + ");\n"
        )
    f.close()


def insert_product_special_offer():
    f = open("demofile2.txt", "a")
    for _ in range(NUMBER_OF_PRODUCTS):
        f.write(
            "INSERT INTO PRODUCT_SPECIALOFFER(PRODUCTID, SPECIALOFFERID) VALUES ("
            + str(random.randint(1, NUMBER_OF_PRODUCTS))
            + ", "
            + str(random.randint(1, NUMBER_OF_SPECIAL_OFFERS))
            + ");\n"
        )
    f.close()


if __name__ == "__main__":

    insert_product()
    insert_client()
    insert_special_offer()
    insert_address()
    insert_payment()
    insert_review()
    insert_order()
    insert_product_order()
    insert_product_special_offer()