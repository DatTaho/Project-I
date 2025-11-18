from collections import namedtuple


def convertTime(text) -> int:
    # Convert to timestamp instaed of datetime
    h, m, s = map(int, text.split(":"))
    return h * 3600 + m * 60 + s


Order = namedtuple("Order", ["CustomerID", "ProductID", "Price", "ShopID", "TimePoint"])


class Database:
    def __init__(self):
        self.data: list[Order] = []
        self.totalRevenue = 0

    def addOrder(self, customerID, productID, price, shopID, timePoint):
        self.data.append(
            Order(
                customerID,
                productID,
                int(price),
                shopID,
                convertTime(timePoint),
            )
        )
        self.totalRevenue += int(price)

    # Return the total revenue the e-commerce company gets
    @property
    def orderCount(self):
        return len(self.data)

    # Return the total revenue the shop <ShopID> gets
    def revenueByShop(self, shopID):
        revenue = 0
        for order in self.data:
            if order.ShopID == shopID:
                revenue += order.Price
        return revenue

    # Return the total revenue the shop <ShopID> sells products to customer <CustomerID>
    def totalConsumeOfCustomerByShop(self, customerID, shopID):
        revenue = 0
        for order in self.data:
            if order.CustomerID == customerID and order.ShopID == shopID:
                revenue += order.Price
        return revenue

    # Return the total revenue the e-commerce gets of the period from <from_time> to <to_time> (inclusive)
    def totalRevenueInPeriod(self, fromTime, toTime):
        fromTime, toTime = convertTime(fromTime), convertTime(toTime)
        revenue = 0
        for order in self.data:
            if order.TimePoint >= fromTime and order.TimePoint <= toTime:
                revenue += order.Price
        return revenue


if __name__ == "__main__":
    db = Database()
    # Add order
    while (order := input()) != "#":
        db.addOrder(*order.split())
    # Query
    while (query := input()) != "#":
        args = query.split()
        if args[0] == "?total_number_orders":
            print(db.orderCount)
        elif args[0] == "?total_revenue":
            print(db.totalRevenue)
        elif args[0] == "?revenue_of_shop":
            print(db.revenueByShop(args[1]))
        elif args[0] == "?total_consume_of_customer_shop":
            print(db.totalConsumeOfCustomerByShop(args[1], args[2]))
        elif args[0] == "?total_revenue_in_period":
            print(db.totalRevenueInPeriod(args[1], args[2]))
