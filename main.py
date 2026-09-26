from agent_response import run_step_5_contextual_response
from database import Neo4jConnection
from retrieval import retrieve_user_context

USER_ID = "siddhi"
user_prompt = "Help me plan my week."

db = Neo4jConnection()
print("🚀 Starting Mini-Hack Agent Flow...\n")

print("Step 3: Storing memory into Neo4j...")
store_query = """
MERGE (u:User {id: $user_id})
CREATE (p:Preference {type: 'schedule', value: 'morning'})
CREATE (d:Decision {topic: 'Presentation Prep', choice: 'Monday'})
CREATE (r:Reason {description: 'Client meeting is on Wednesday'})
MERGE (u)-[:HAS_PREFERENCE]->(p)
MERGE (u)-[:MADE_DECISION]->(d)
MERGE (d)-[:BASED_ON]->(r)
"""
db.execute_query(store_query, {"user_id": USER_ID})
print("✅ Memory saved to graph!\n")

print("Step 4: Retrieving memory from Neo4j graph...")
context_data = retrieve_user_context(user_id=USER_ID, user_prompt=user_prompt)
print(f"✅ Retrieved Context: {context_data}")

final_answer = run_step_5_contextual_response(user_prompt, context_data)

print("\n--- Agent Final Response ---")
print(final_answer)