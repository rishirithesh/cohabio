from typing import Dict, Any, List

class RoommateMatcher:
    """
    Production-grade compatibility algorithm for roommate discovery.
    Evaluates:
    - Budget Overlap (25%)
    - Cleanliness Alignment (20%)
    - Lifestyle & Schedule (20%) (Sleep, Work)
    - Habits (15%) (Smoking, Drinking, Pets)
    - Food Preference (10%)
    - Shared Interests & Affinity (10%)
    """

    @staticmethod
    def calculate_compatibility(p1: Dict[str, Any], p2: Dict[str, Any]) -> int:
        score = 0.0

        # 1. Budget Overlap Check (25 Points)
        b1_min, b1_max = p1.get("budget_min", 0), p1.get("budget_max", 50000)
        b2_min, b2_max = p2.get("budget_min", 0), p2.get("budget_max", 50000)

        overlap_start = max(b1_min, b2_min)
        overlap_end = min(b1_max, b2_max)

        if overlap_start <= overlap_end:
            score += 25.0
        else:
            # Distance penalty
            diff = overlap_start - overlap_end
            if diff <= 5000:
                score += 15.0
            elif diff <= 10000:
                score += 5.0

        # 2. Cleanliness (20 Points)
        c1 = p1.get("cleanliness_rating", 3)
        c2 = p2.get("cleanliness_rating", 3)
        diff_c = abs(c1 - c2)
        if diff_c == 0:
            score += 20.0
        elif diff_c == 1:
            score += 14.0
        elif diff_c == 2:
            score += 7.0

        # 3. Lifestyle & Schedule (20 Points)
        if p1.get("sleep_schedule") == p2.get("sleep_schedule"):
            score += 10.0
        elif "flexible" in [p1.get("sleep_schedule"), p2.get("sleep_schedule")]:
            score += 7.0

        if p1.get("work_schedule") == p2.get("work_schedule"):
            score += 10.0
        elif "flexible" in [p1.get("work_schedule"), p2.get("work_schedule")]:
            score += 7.0

        # 4. Habits: Smoking, Drinking, Pets (15 Points)
        if p1.get("smoking") == p2.get("smoking"):
            score += 5.0
        if p1.get("drinking") == p2.get("drinking"):
            score += 5.0
        if p1.get("pets") == p2.get("pets"):
            score += 5.0

        # 5. Food Preference (10 Points)
        f1, f2 = p1.get("food_pref", "any"), p2.get("food_pref", "any")
        if f1 == f2 or f1 == "any" or f2 == "any":
            score += 10.0
        elif (f1 == "vegetarian" and f2 == "vegan") or (f1 == "vegan" and f2 == "vegetarian"):
            score += 8.0
        else:
            score += 4.0

        # 6. Shared Interests (10 Points)
        i1 = set(p1.get("interests", []))
        i2 = set(p2.get("interests", []))
        if i1 and i2:
            common = i1.intersection(i2)
            ratio = len(common) / max(len(i1), len(i2))
            score += min(10.0, ratio * 15.0)

        return min(100, max(0, int(score)))

    @staticmethod
    def get_compatibility_breakdown(p1: Dict[str, Any], p2: Dict[str, Any]) -> Dict[str, Any]:
        match_percentage = RoommateMatcher.calculate_compatibility(p1, p2)
        matching_tags = []

        if p1.get("food_pref") == p2.get("food_pref"):
            matching_tags.append(f"Same food pref ({p1.get('food_pref')})")
        if p1.get("sleep_schedule") == p2.get("sleep_schedule"):
            matching_tags.append("Matching sleep routine")
        if p1.get("cleanliness_rating") == p2.get("cleanliness_rating"):
            matching_tags.append("Similar cleanliness standards")
        if p1.get("home_state") and p1.get("home_state") == p2.get("home_state"):
            matching_tags.append(f"Both from {p1.get('home_state')}")

        return {
            "match_score": match_percentage,
            "matching_tags": matching_tags,
            "summary": f"{match_percentage}% Match based on lifestyle, budget, and habits."
        }
