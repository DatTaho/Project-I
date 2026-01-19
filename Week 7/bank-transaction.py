from collections import namedtuple


def asTimestamp(timePoint):
    h, m, s = map(int, timePoint.split(":"))
    return h * 3600 + m * 60 + s


Transaction = namedtuple("Transaction", ["FromAccount","ToAccount","Money","Timestamp","ATM"])

class DataBase:
    def __init__(self):
        self.data = []
        self.accounts = set()
        self.columns = {k: v for v, k in enumerate(["FromAccount","ToAccount","Money","Timestamp","ATM"])}
        self._finalized = False
    
    def finalize(self):
        # Sort by Timestamp > FromAccount > ToAccount
        self.data.sort(key=lambda x: (x[3], x[0], x[1]))
        self._finalized = True
    
    def __len__(self):
        return len(self.data)
    
    def __str__(self):
        out = "Bank's data:"
        for t in self.data:
            out += "\n" + str(t)
        return out
    
    def __getitem__(self, column):
        if isinstance(column, str):
            return [row[self.columns[column]] for row in self.data]
        return {col: [row[self.columns[col]] for row in self.data] for col in column}

    def addRow(self, fromAccount, toAccount, money, timePoint, atm):
        self.data.append(Transaction(
            fromAccount,
            toAccount,
            int(money),
            asTimestamp(timePoint),
            atm,
        ))
        self.accounts.add(fromAccount)
        self.accounts.add(toAccount)

    def getTransfersFromAccount(self, sourceAccount, startIndex=-1, firstOnly=True):
        if startIndex == -1:
            timestamp = -1
        else:
            timestamp = self["Timestamp"][startIndex]
        res = {"Index": [],"ToAccount": [], "Timestamp": []}
        firstFound = set()
        for i in range(startIndex + 1, len(self)):
            fromAcc, toAcc, _, ts, _ = self.data[i]
            if (fromAcc == sourceAccount) and (ts > timestamp):
                if firstOnly is True:
                    if toAcc in firstFound:
                        continue
                    firstFound.add(toAcc)
                res["Index"].append(i)
                res["ToAccount"].append(toAcc)
                res["Timestamp"].append(ts)
        return res

    def inspectCycle(self, sourceAccount, depth):
        transfers = self.getTransfersFromAccount(sourceAccount)
        stack = list(zip(transfers["ToAccount"], transfers["Index"]))
        visited = set([sourceAccount])
        cur_depth = 1
        print(stack)

        while stack:
            sender, index = stack[-1]

            if sender not in visited:
                cur_depth += 1
                visited.add(sender)

                transfers = self.getTransfersFromAccount(sender, index)
                print(transfers)
                if cur_depth == depth:
                    if sourceAccount in transfers["ToAccount"]:
                        return 1
                else:
                    for receiver, idx in zip(transfers["ToAccount"], transfers["Index"]):
                        if receiver not in visited:
                            stack.append((receiver, idx))
            else:
                cur_depth -= 1
                visited.remove(sender)
                stack.pop()
        else:
            return 0

    def query(self, cmd):
        if self._finalized is False:
            print("Please call finalize first!")
            return

        args = cmd.split(" ")

        # Print number of transactions
        if args[0] == "?number_transactions":
            print(len(self))
        
        # Print total amount of transactioned money
        if args[0] == "?total_money_transaction":
            print(sum(self["Money"]))
        
        # Print all accounts in sorted order
        if args[0] == "?list_sorted_accounts":
            print(*sorted(list(self.accounts)))
        
        # Print total amount of transactioned money from one account
        if args[0] == "?total_money_transaction_from":
            query = self["FromAccount", "Money"]
            total = 0
            for sender, money in zip(query["FromAccount"], query["Money"]):
                if sender == args[1]:
                    total += money
            print(total)
        
        # Inspect cycle
        if args[0] == "?inspect_cycle":
            print(self.inspectCycle(args[1], int(args[2])))

if __name__ == "__main__":
    db = DataBase()
    # Update database
    while (cmd := input()) != "#":
        db.addRow(*cmd.split(" "))
    db.finalize()
    # Query database
    while (cmd := input()) != "#":
        db.query(cmd)