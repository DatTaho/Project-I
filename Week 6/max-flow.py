
from collections import deque

class FlowEdge:
    def __init__(self, v, flow, cap, rev):
        self.v = v
        self.flow = flow
        self.cap = cap
        self.rev = rev

class FlowGraph:
    def __init__(self, V):
        self.adj = [[] for _ in range(V)]
        self.level = [0 for _ in range(V)]
        self.V = V

    def addEdge(self, u, v, capacity):
        # Forward edge
        a = FlowEdge(v, 0, capacity, len(self.adj[v]))
        # Reverse edge
        b = FlowEdge(u, 0, 0, len(self.adj[u]))
        self.adj[u].append(a)
        self.adj[v].append(b)

    # Finds if more flow can be sent from source to target
    def bfsFindFlow(self, source, target):
        for i in range(self.V):
            self.level[i] = -1

        # Level of source vertex
        self.level[source] = 0

        # Traverse from source to target
        q = deque([])
        q.append(source)
        while q:
            u = q.popleft()
            for i, edge in enumerate(self.adj[u]):
                if self.level[edge.v] < 0 and edge.flow < edge.cap:
                    # Level of current vertex = level of parent + 1
                    self.level[edge.v] = self.level[u]+1
                    # Continue traversal
                    q.append(edge.v)

        # Return True if reach target (target level >= 0)
        return self.level[target] >= 0

    def dfsSendFlow(self, source, flow, target, start_idx):
        # Target reached
        if source == target:
            return flow

        # Traverse all adjacent edges
        while start_idx[source] < len(self.adj[source]):

            # Pick next edge from adjacency list of source
            edge = self.adj[source][start_idx[source]]
            if self.level[edge.v] == self.level[source]+1 and edge.flow < edge.cap:

                # Find minimum flow from source to target
                currFlow = min(flow, edge.cap-edge.flow)
                tempFlow = self.dfsSendFlow(edge.v, currFlow, target, start_idx)

                # When flow is greater than zero
                if tempFlow is not None and tempFlow > 0:

                    # Add flow to current edge
                    edge.flow += tempFlow

                    # Subtract flow from reverse edge
                    self.adj[edge.v][edge.rev].flow -= tempFlow
                    return tempFlow
            
            # Go to next edge
            start_idx[source] += 1

    # Returns maximum flow in graph using Dinic's algorithm
    def MaxFlow(self, source, target):
        max_flow = 0
        while self.bfsFindFlow(source, target) == True:
            start_idx = [0]*(self.V+1)
            while True:
                flow = self.dfsSendFlow(source, float('inf'), target, start_idx)
                if flow is None:
                    break
                max_flow += flow
        return max_flow

if __name__ == "__main__":
    V, E = map(int, input().split())

    source, sink = map(int, input().split())
    source, sink = source -1, sink-1

    graph = FlowGraph(V)
    for _ in range(E):
        u, v, cap = map(int, input().split())
        graph.addEdge(u-1, v-1, cap)

    print(graph.MaxFlow(source, sink))
