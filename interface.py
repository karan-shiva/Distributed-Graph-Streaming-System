from neo4j import GraphDatabase

uri = "neo4j://localhost:7687"
username = "neo4j"
password = "project1phase1"

class Interface:
    def __init__(self, uri, user, password):
        self._driver = GraphDatabase.driver(uri, auth=(user, password), encrypted=False)
        self._driver.verify_connectivity()

    def close(self):
        self._driver.close()

    def createProjectIfNotExist(self):
        check_query = """
        CALL gds.graph.exists('TripProj') YIELD exists
        RETURN exists
        """
        query = """CALL gds.graph.project(
                    'TripProj',
                    'Location',
                    'TRIP',
                    {
                        relationshipProperties: 'distance'
                    }
                    )
                    """
        with self._driver.session() as session:
            exists = session.run(check_query).single()["exists"]
            if not exists:
                print("Creating GDS Graph Project...")
                session.run(query)
            else:
                print("GDS Graph Project already exists")

    def bfs(self, start_node, last_node):
        # TODO: Implement this method
        self.createProjectIfNotExist()

        query = """
            MATCH (s:Location{name: $start_node}), (l:Location{name: $last_node})
            WITH id(s) AS source, [id(l)] AS targetNodes
            CALL gds.bfs.stream('TripProj', {
            sourceNode: source,
            targetNodes: targetNodes
            })
            YIELD path
            RETURN path
        """
        
        with self._driver.session() as session:
            result = session.run(query,
                                 start_node = start_node,
                                 last_node = last_node)
            records = result.data()
        
        return records

    def pagerank(self, max_iterations, weight_property):
        # TODO: Implement this method
        self.createProjectIfNotExist()

        query = """
            CALL gds.pageRank.stream('TripProj', {
            maxIterations: $max_iterations,
            dampingFactor: 0.85,
            relationshipWeightProperty: $weight_property
            })
            YIELD nodeId, score
            RETURN gds.util.asNode(nodeId).name AS name, score
            ORDER BY score DESC, name ASC
        """

        records = None
        with self._driver.session() as session:
            result = session.run(query,
                                 max_iterations = max_iterations,
                                 weight_property = weight_property)
            records = result.data()

        if records:
            maxScore = records[0]
            minScore = records[-1]
            return maxScore, minScore
        else:
            return None, None
