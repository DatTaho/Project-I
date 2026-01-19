class Date:
    def __init__(self, dateStr):
        self.year, self.month, self.day = map(int, dateStr.split("-"))
    
    def __lt__(self, other):
        if self.year < other.year:
            return True
        elif self.year == other.year:
            if self.month < other.month:
                return True
            elif self.month == other.month:
                if self.day < other.day:
                    return True
        return False
    
    def __eq__(self, other):
        return (self.year == other.year) and (self.month == other.month) and (self.day == other.day)
    
    def __le__(self, other):
        return (self < other) or (self == other)



class DateSearcher:
    def __init__(self, data):
        self.data = data
    
    def bsFirst(self, date):
        res = -1
        start, end = 0, len(self.data) - 1
        while start <= end:
            mid = (start + end) // 2
            if date == self.data[mid]["DateOfBirth"]:
                res = mid
                end = mid - 1
            elif date < self.data[mid]["DateOfBirth"]:
                end = mid - 1
            else:
                start = mid + 1
        return res

    def bsLast(self, date):
        res = -1
        start, end = 0, len(self.data) - 1
        while start <= end:
            mid = (start + end) // 2
            if date == self.data[mid]["DateOfBirth"]:
                res = mid
                start = mid + 1
            elif date < self.data[mid]["DateOfBirth"]:
                end = mid - 1
            else:
                start = mid + 1
        return res
    
    def bsFirstGE(self, date):
        res = -1
        start, end = 0, len(self.data) - 1
        while start <= end:
            mid = (start + end) // 2
            if date <= self.data[mid]["DateOfBirth"]:
                res = mid
                end = mid - 1
            else:
                start = mid + 1
        return res
    
    def bsLastLE(self, date):
        res = -1
        start, end = 0, len(self.data) - 1
        while start <= end:
            mid = (start + end) // 2
            if date >= self.data[mid]["DateOfBirth"]:
                res = mid
                start = mid + 1
            else:
                end = mid - 1
        return res


class DataBase:
    # Primary key: code (personalID)
    def __init__(self):
        self.data = []
        self.person = {}
        self.dsearch = None
        self.MIS = None
    
    def __len__(self):
        return len(self.data)
    
    def addRow(self, code, dateOfBirth, fatherCode, motherCode, isAlive, regionCode):
        row = {
            "Code": code,
            "DateOfBirth": Date(dateOfBirth), 
            "FatherCode": fatherCode, 
            "MotherCode": motherCode, 
            "IsAlive": bool(isAlive == "Y"), 
            "RegionCode": regionCode,
        }
        self.person[code] = row
        self.data.append(row)

    def dateCount(self, date):
        date = Date(date)
        first = self.dsearch.bsFirst(date)
        if first < 0:
            return 0
        last = self.dsearch.bsLast(date)
        return last - first + 1
    
    def dateRangeCount(self, lb, rb):
        lb = self.dsearch.bsFirstGE(Date(lb))
        rb = self.dsearch.bsLastLE(Date(rb))
        if (lb < 0) or (rb < 0) or (lb > rb):
            return 0
        return (rb - lb) + 1
    
    def ancestorDepth(self, code):
        if code == "0000000":
            return -1
        father = self.person[code]["FatherCode"]
        mother = self.person[code]["MotherCode"]
        return 1 + max(self.ancestorDepth(father), self.ancestorDepth(mother))

    def finalize(self):
        # Sort by DateOfBirth
        self.data.sort(key=lambda x: (x["DateOfBirth"], x["Code"]))
        # Create date searcher
        self.dsearch = DateSearcher(self.data)
    
    def query(self, cmd):
        args = cmd.split(" ")
        if args[0] == "NUMBER_PEOPLE":
            print(len(self))
        elif args[0] == "NUMBER_PEOPLE_BORN_AT":
            print(self.dateCount(args[1]))
        elif args[0] == "MOST_ALIVE_ANCESTOR":
            print(self.ancestorDepth(args[1]))
        elif args[0] == "NUMBER_PEOPLE_BORN_BETWEEN":
            print(self.dateRangeCount(args[1], args[2]))
        elif args[0] == "MAX_UNRELATED_PEOPLE":
            print("Not implemented")

if __name__ == "__main__":
    db = DataBase()
    while (cmd := input()) != "*":
        db.addRow(*cmd.split(" "))
    db.finalize()
    while (cmd := input()) != "***":
        db.query(cmd)