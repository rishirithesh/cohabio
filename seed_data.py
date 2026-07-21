"""
Cohabio Seed Script
Seeds sample accounts, communities, roommate profiles, and housing listings.
"""

SAMPLE_ACCOUNTS = [
    {
        "email": "rohan.sharma@example.com",
        "full_name": "Rohan Sharma",
        "age": 22,
        "occupation": "Software Engineer Intern @ Google",
        "college": "BITS Pilani",
        "home_city": "Delhi",
        "current_city": "Bangalore",
        "budget_min": 8000,
        "budget_max": 15000,
        "cleanliness_rating": 4,
        "sleep_schedule": "night_owl",
        "work_schedule": "flexible",
        "smoking": False,
        "drinking": "socially",
        "pets": "no",
        "food_pref": "vegetarian",
        "interests": ["Coding", "Gaming", "Football"],
        "bio": "Moving to Bangalore for summer internship. Looking for a neat flatmate."
    },
    {
        "email": "aanya.iyer@example.com",
        "full_name": "Aanya Iyer",
        "age": 23,
        "occupation": "Data Analyst @ Amazon",
        "college": "SRM University",
        "home_city": "Chennai",
        "current_city": "Bangalore",
        "budget_min": 10000,
        "budget_max": 18000,
        "cleanliness_rating": 5,
        "sleep_schedule": "early",
        "work_schedule": "standard_9_5",
        "smoking": False,
        "drinking": "never",
        "pets": "yes",
        "food_pref": "any",
        "interests": ["Music", "Reading", "Hiking"],
        "bio": "Joining Amazon full-time. Extremely clean and organized."
    }
]

SAMPLE_COMMUNITIES = [
    {"name": "Bangalore Techies & Interns", "category": "city", "slug": "blr-tech"},
    {"name": "Kannada Language & Culture Club", "category": "language", "slug": "kannada-club"},
    {"name": "PES University Relocation Hub", "category": "college", "slug": "pes-hub"}
]

if __name__ == "__main__":
    print(f"Cohabio Seed Data Ready.")
    print(f"Accounts: {len(SAMPLE_ACCOUNTS)}")
    print(f"Communities: {len(SAMPLE_COMMUNITIES)}")
