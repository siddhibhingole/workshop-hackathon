def run_step_5_contextual_response(user_prompt: str, context_data=None):
    """
    Step 5: Generate a personalized response using the retrieved Neo4j memory.
    """
    context_data = context_data or {}
    preferences = ", ".join(context_data.get("preferences", [])) or "none recorded"
    decisions = context_data.get("decisions", [])
    decision = decisions[0] if decisions else {}

    return (
        f"Mock Agent Response: Based on your graph memory regarding '{user_prompt}', "
        f"your preferences are '{preferences}', "
        f"you decided on '{decision.get('decision', 'no decision recorded')}', "
        f"because '{decision.get('reason', 'no reason recorded')}'."
    )