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
            print("Not implemented")

if __name__ == "__main__":
    db = DataBase()
    # Update database
    while (cmd := input()) != "#":
        db.addRow(*cmd.split(" "))
    db.finalize()
    # Query database
    while (cmd := input()) != "#":
        db.query(cmd)