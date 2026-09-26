from database import Neo4jConnection


def retrieve_user_context(user_id="siddhi", user_prompt=""):
    """
    Queries Neo4j to fetch relevant user preferences, tasks, 
    and past decisions to provide context for the LLM/Agent.
    """
    db = Neo4jConnection()
    
    # Cypher query to fetch the user's connected preferences, tasks, and decisions
    query = """
    MATCH (u:User {id: $user_id})
    OPTIONAL MATCH (u)-[:HAS_PREFERENCE]->(p:Preference)
    OPTIONAL MATCH (u)-[:MADE_DECISION]->(d:Decision)-[:BASED_ON]->(r:Reason)
    RETURN 
        u.id AS user,
        collect(DISTINCT p.value) AS preferences,
        [] AS tasks,
        collect(DISTINCT {decision: d.choice, reason: r.description}) AS decisions
    """
    
    try:
        results = db.execute_query(query, {"user_id": user_id})
        db.close()
        
        if results:
            record = results[0]
            return {
                "user": record.get("user"),
                "preferences": record.get("preferences", []),
                "tasks": record.get("tasks", []),
                "decisions": record.get("decisions", [])
            }
        return {"user": user_id, "preferences": [], "tasks": [], "decisions": []}
        
    except Exception as e:
        print(f"❌ Error retrieving context from Neo4j: {e}")
        db.close()
        return None

# Alias to support imports looking for get_user_context
get_user_context = retrieve_user_context