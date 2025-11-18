INF = float("inf")


if __name__ == "__main__":
    # Node count, edge count
    n, m = map(int, input().split())

    # Cost matrix
    costs = [[INF] * n for _ in range(n)]
    for i in range(n):
        costs[i][i] = 0

    # Add edges
    for _ in range(m):
        n1, n2, w = map(int, input().split())
        costs[n1 - 1][n2 - 1] = w

    # Floyd-Warshall algorithm
    for k in range(n):
        for i in range(n):
            for j in range(n):
                costs[i][j] = min(costs[i][j], costs[i][k] + costs[k][j])

    # Print result
    for i in range(n):
        print(*map(lambda v: v if isinstance(v, int) else -1, costs[i]))
