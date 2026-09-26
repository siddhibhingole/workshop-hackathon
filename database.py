import os
from neo4j import GraphDatabase
from dotenv import load_dotenv

load_dotenv()

class Neo4jConnection:
    def __init__(self):
        username = os.getenv("NEO4J_USERNAME") or os.getenv("NEO4J_USER", "neo4j")
        database = os.getenv("NEO4J_DATABASE", "neo4j")
        self.driver = GraphDatabase.driver(
            os.getenv("NEO4J_URI"),
            auth=(username, os.getenv("NEO4J_PASSWORD"))
        )
        self.database = database

    def close(self):
        self.driver.close()

    def execute_query(self, query, parameters=None):
        with self.driver.session(database=self.database) as session:
            return session.run(query, parameters).data()