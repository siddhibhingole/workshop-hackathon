from database import Neo4jConnection

print("Testing Neo4j connection...")
try:
    db = Neo4jConnection()
    result = db.execute_query("RETURN 1 AS test")
    print("✅ Neo4j Connection Successful!", result)
    db.close()
except Exception as e:
    print("❌ Neo4j Connection Failed:", e)