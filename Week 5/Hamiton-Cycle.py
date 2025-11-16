def hamiltonian_check(n, edges):
    stack = [0]
    length = 0
    traversed = [False] * n

    while stack:
        # print([i + 1 for i in stack])
        edge = stack[-1]
        if traversed[edge] is True:
            traversed[edge] = False
            length -= 1
            stack.pop()
            continue
        else:
            traversed[edge] = True
            length += 1
            if length == n and 0 in edges[edge]:
                return 1
            for v in edges[edge]:
                if traversed[v] is False:
                    stack.append(v)
    return 0


if __name__ == "__main__":
    graph_count = int(input())
    for _ in range(graph_count):
        n, m = map(int, input().split())  # Nodes, Edges
        edges = {i: list() for i in range(n)}
        for _ in range(m):
            u, v = map(int, input().split())
            edges[u - 1].append(v - 1)
            edges[v - 1].append(u - 1)
        print(hamiltonian_check(n, edges))
