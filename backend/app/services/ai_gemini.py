import google.generativeai as genai
from typing import Dict, Any, List
import json
from app.core.config import settings

class GeminiRelocationAssistant:
    """
    Integrates with Google Gemini API to offer personalized relocation recommendations,
    natural language search parsing, and dynamic moving checklists.
    """

    def __init__(self):
        if settings.GEMINI_API_KEY and settings.GEMINI_API_KEY != "gemini-api-key-placeholder":
            genai.configure(api_key=settings.GEMINI_API_KEY)
            self.model = genai.GenerativeModel('gemini-1.5-flash')
        else:
            self.model = None

    def get_relocation_advice(self, current_city: str, target_city: str, budget: float, preferences: List[str]) -> str:
        """
        Generates customized neighborhood recommendations, cost of living advice, and relocation steps.
        """
        if not self.model:
            return (
                f"Welcome to Cohabio Relocation Assistant! Moving from {current_city} to {target_city} "
                f"with a monthly budget of ₹{budget:.2f} is an exciting journey.\n\n"
                f"Mock Advice: We suggest looking at budget-friendly areas with good transit links. "
                f"Verify PG options near colleges or work hubs."
            )

        prompt = (
            f"You are the Cohabio AI Relocation Assistant.\n"
            f"Provide a structured relocation guide for a young professional/student moving from "
            f"{current_city} to {target_city} with a monthly rent budget of ₹{budget:.2f}.\n"
            f"Include:\n"
            f"1. Top 3 recommended areas to live within this budget and their distance to major tech hubs/colleges.\n"
            f"2. Local transit options and monthly cost estimation.\n"
            f"3. Practical moving timeline checklist.\n"
            f"Keep the output clean, modern, and in clear sections."
        )

        try:
            response = self.model.generate_content(prompt)
            return response.text
        except Exception as e:
            return f"Error connecting to Gemini API: {str(e)}"

    def parse_natural_language_search(self, query: str) -> Dict[str, Any]:
        """
        Parses natural language requests like 'I am moving to Bangalore with 12000 budget'
        into structured parameters.
        """
        default_response = {
            "city": "Bangalore",
            "budget_max": 12000.0,
            "category": "all"
        }

        if not self.model:
            return default_response

        prompt = (
            f"Extract structured parameters from this natural language relocation query: '{query}'.\n"
            f"Respond ONLY with a valid JSON object containing:\n"
            f"- 'city': string (the destination city mentioned, default null if not found)\n"
            f"- 'budget_max': float (maximum monthly rent budget, default null if not found)\n"
            f"- 'preferences': list of strings (lifestyle keywords or priorities)\n"
            f"No markdown blocks, no prefix, just pure JSON."
        )

        try:
            response = self.model.generate_content(prompt)
            clean_text = response.text.replace("```json", "").replace("```", "").strip()
            return json.loads(clean_text)
        except Exception:
            return default_response
