from datetime import datetime as dt
from collections import defaultdict

DT_FORMAT = "%Y-%m-%d"

def asDatetime(dateStr):
    return dt.strptime(dateStr, DT_FORMAT)

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

class MaximumIndependentSet:
    def __init__(self, childs, roots):
        self.childs = childs
        self.roots = roots
        self.dpMISInclude = {}
        self.dpMISExclude = {}
    
    def MISInclude(self, code):
        if len(self.childs[code]) == 0:
            return 1
        if code in self.dpMISInclude:
            return self.dpMISInclude[code]
        childs = self.childs[code]
        res = 1 + sum(self.MISExclude(c) for c in childs)
        self.dpMISInclude[code] = res
        return res
    
    def MISExclude(self, code):
        if len(self.childs[code]) == 0:
            return 0
        if code in self.dpMISExclude:
            return self.dpMISExclude[code]
        childs = self.childs[code]
        res = sum(self.MIS(c) for c in childs)
        self.dpMISExclude[code] = res
        return res

    def MIS(self, code):
        return max(self.MISInclude(code), self.MISExclude(code))
    
    def size(self):
        res = 0
        for code in self.roots:
            res += max(self.MISInclude(code), self.MISExclude(code))
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
            "DateOfBirth": asDatetime(dateOfBirth), 
            "FatherCode": fatherCode, 
            "MotherCode": motherCode, 
            "IsAlive": bool(isAlive == "Y"), 
            "RegionCode": regionCode,
        }
        self.person[code] = row
        self.data.append(row)

    def dateCount(self, date):
        date = asDatetime(date)
        first = self.dsearch.bsFirst(date)
        if first < 0:
            return 0
        last = self.dsearch.bsLast(date)
        return last - first + 1
    
    def dateRangeCount(self, lb, rb):
        lb = self.dsearch.bsFirstGE(asDatetime(lb))
        rb = self.dsearch.bsLastLE(asDatetime(rb))
        if (lb < 0) or (rb < 0) or (lb > rb):
            return 0
        return (rb - lb) + 1
    
    def ancestorDepth(self, code):
        if code == "0000000":
            return -1
        father = self.person[code]["FatherCode"]
        mother = self.person[code]["MotherCode"]
        return 1 + max(self.ancestorDepth(father), self.ancestorDepth(mother))
    
    def maxUnrelated(self):
        # Maximum Independent Set 
        if self.MIS is None:
            childs = defaultdict(list)
            roots = [] # roots

            for person, row in self.person.items():
                father, mother = row["FatherCode"], row["MotherCode"]
                if father == "0000000" and mother == "0000000":
                    roots.append(person)
                else:
                    if father != "0000000":
                        childs[father].append(person)
                    if mother != "0000000":
                        childs[mother].append(person)
            
            self.MIS = MaximumIndependentSet(childs, roots)
        return self.MIS.size()

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
            print(self.maxUnrelated())

if __name__ == "__main__":
    db = DataBase()
    while (cmd := input()) != "*":
        db.addRow(*cmd.split(" "))
    db.finalize()
    while (cmd := input()) != "***":
        db.query(cmd)