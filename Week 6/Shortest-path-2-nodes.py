from heapq import heapify, heappop, heappush

INF = float("inf")


class PriorityQueue:
    def __init__(self, *items):
        self.items = list(items)
        heapify(self.items)

    def pop(self):
        return heappop(self.items)

    def push(self, item):
        heappush(self.items, item)

    def not_empty(self):
        return bool(self.items)


if __name__ == "__main__":
    # Node count, edge count
    n, m = map(int, input().split())

    # Adjacentcy list
    edges = {v: dict() for v in range(n)}

    # Add edges
    for _ in range(m):
        n1, n2, w = map(int, input().split())
        edges[n1 - 1][n2 - 1] = w

    # Select start node and end node
    start, end = map(lambda x: int(x) - 1, input().split())

    # Keep track of distance and visited nodes
    dist = [INF] * n
    dist[start] = 0
    visited = [False] * n

    # Dijkstra's algorithm
    pq = PriorityQueue((0, start))  # weight, node

    while pq.not_empty():
        weight, node = pq.pop()

        # Stop when reach the source
        if node == end:
            break

        # Ignore visited node
        if visited[node] is True:
            continue
        visited[node] = True

        # Update distance to neighbors
        for neighbor in edges[node].keys():
            dist[neighbor] = min(dist[neighbor], dist[node] + edges[node][neighbor])
            pq.push((dist[neighbor], neighbor))

    # Print result
    print(dist[end])
