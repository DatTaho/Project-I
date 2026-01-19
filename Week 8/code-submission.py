from collections import namedtuple


def asTimestamp(timePoint):
    h, m, s = map(int, timePoint.split(":"))
    return h * 3600 + m * 60 + s

COLUMNS = ["UserID", "ProblemID", "Timestamp", "Status", "Point"]
Submission = namedtuple("Submission", COLUMNS)

class DataBase:
    def __init__(self):
        self.data : list[Submission] = []
        self.colmap = {k: v for v, k in enumerate(COLUMNS)}
        self.problems = set()

    def finalize(self):
        # Sort by UserID > ProblemID > TimePoint
        self.data.sort(key=lambda x: (x[0], x[1], x[2]))
        self._finalized = True
    
    def __str__(self):
        out = "Submissions:"
        for t in self.data:
            out += "\n" + str(t)
        return out

    def __len__(self):
        return len(self.data)   
    
    def __getitem__(self, column):
        if isinstance(column, str):
            return [row[self.colmap[column]] for row in self.data]
        return {col: [row[self.colmap[col]] for row in self.data] for col in column}

    def addRow(self, userID, problemID, timePoint, status, point):
        self.data.append(Submission(
            userID,
            problemID,
            asTimestamp(timePoint),
            int(status == "OK"), # OK: 1, ERR: 0
            int(point),
        ))
        self.problems.add(problemID)


    def query(self, cmd):
        args = cmd.split(" ")
        if args[0] == "?total_number_submissions":
            print(len(self))
        elif args[0] == "?number_error_submision":
            print(len(self) - sum(self["Status"]))
        elif args[0] == "?number_error_submision_of_user":
            count = 0
            for row in self.data:
                user, status = row[0], row[3]
                if user == args[1]:
                    count += (1-status)
            print(count)
        elif args[0] == "?total_point_of_user":
            scores = {k: 0 for k in self.problems}
            for row in self.data:
                user, prob, _, status, point = row
                if user == args[1] and status == 1:
                    scores[prob] = max(scores[prob], point)
            print(sum(scores.values()))
        elif args[0] == "?number_submission_period":
            count = 0
            for row in self.data:
                ts = row[2]
                if (ts >= asTimestamp(args[1])) and (ts <= asTimestamp(args[2])):
                    count += 1
            print(count)

if __name__ == "__main__":
    db = DataBase()
    # Update database
    while (cmd := input()) != "#":
        db.addRow(*cmd.split(" "))
    db.finalize()
    # Query database
    while (cmd := input()) != "#":
        db.query(cmd)