import sys
import os
import uuid
from datetime import datetime, timedelta
from decimal import Decimal

# Ensure python knows where backend is
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app.db.session import SessionLocal, engine, Base
from app.core.security import get_password_hash
from app.models.models import (
    User, Profile, LifestylePreference, Community, 
    Post, Comment, Like, Property, PropertyImage, 
    PropertyAmenity, Event, event_rsvps, Bookmark, 
    ChatRoom, chat_participants, Message, Waitlist,
    RoommateMatch
)

def seed_database():
    print("Ensuring tables are created...")
    Base.metadata.create_all(bind=engine)
    db = SessionLocal()
    try:
        print("Cleaning old tables...")
        # Clean existing data
        db.query(Waitlist).delete()
        db.query(Bookmark).delete()
        db.query(Message).delete()
        db.query(chat_participants).delete()
        db.query(ChatRoom).delete()
        db.query(event_rsvps).delete()
        db.query(Event).delete()
        db.query(PropertyAmenity).delete()
        db.query(PropertyImage).delete()
        db.query(Property).delete()
        db.query(Like).delete()
        db.query(Comment).delete()
        db.query(Post).delete()
        # Delete associations using raw execute or let CASCADE handle it
        db.execute(Base.metadata.tables['community_members'].delete())
        db.query(Community).delete()
        db.query(LifestylePreference).delete()
        db.query(Profile).delete()
        db.query(User).delete()
        db.commit()

        print("Seeding demo logins...")
        # Demo Logins
        demo_accounts = [
            {"email": "admin@cohabio.com", "password": "Admin@123", "role": "admin", "name": "System Administrator", "status": "verified"},
            {"email": "ceo@cohabio.com", "password": "Ceo@123", "role": "admin", "name": "CEO Admin", "status": "verified"},
            {"email": "manager@cohabio.com", "password": "Manager@123", "role": "admin", "name": "Manager Admin", "status": "verified"},
            {"email": "moderator@cohabio.com", "password": "Moderator@123", "role": "moderator", "name": "Content Moderator", "status": "verified"},
            {"email": "student@cohabio.com", "password": "Student@123", "role": "user", "name": "Rohan (Student) Sharma", "status": "verified"},
            {"email": "owner@cohabio.com", "password": "Owner@123", "role": "owner", "name": "Mr. Murthy (Owner)", "status": "verified"},
        ]

        users_dict = {}
        for acc in demo_accounts:
            user = User(
                email=acc["email"],
                hashed_password=get_password_hash(acc["password"]),
                role=acc["role"],
                is_verified=True
            )
            db.add(user)
            db.flush()
            
            profile = Profile(
                user_id=user.id,
                full_name=acc["name"],
                age=22 if acc["role"] == "user" else 45,
                gender="Male",
                occupation="Student" if acc["role"] == "user" else "Property Owner" if acc["role"] == "owner" else "Staff",
                current_city="Bangalore",
                budget_max=Decimal("15000.00"),
                verification_status=acc["status"]
            )
            db.add(profile)
            db.flush()
            
            lifestyle = LifestylePreference(
                profile_id=profile.id,
                cleanliness_rating=4,
                sleep_schedule="flexible",
                work_schedule="flexible",
                interests=["Tech", "Books", "Hiking"] if acc["role"] == "user" else []
            )
            db.add(lifestyle)
            users_dict[acc["email"]] = user
        
        db.commit()

        print("Seeding 10 additional users & roommate profiles...")
        # 10 Additional Students
        students_data = [
            ("aanya@cohabio.com", "Aanya Iyer", 23, "Female", "SRM University", "Amazon", "Chennai", "Bangalore", 12000, 18000, 5, "early", "standard_9_5", False, "never", "yes", "any", ["Music", "Reading", "Hiking"], "Incoming data analyst at Amazon. Super tidy."),
            ("vikram@cohabio.com", "Vikram Sen", 24, "Male", "IIT Kharagpur", "PhonePe", "Kolkata", "Bangalore", 10000, 16000, 3, "night_owl", "remote", True, "socially", "no", "non-veg", ["Gaming", "Coding", "Cricket"], "SDE-1 at PhonePe. Looking for roommates who are chill with late night coding sessions."),
            ("priya@cohabio.com", "Priya Nair", 22, "Female", "VIT Vellore", "Goldman Sachs", "Kochi", "Bangalore", 15000, 22000, 4, "early", "flexible", False, "socially", "friendly", "vegetarian", ["Baking", "Yoga", "Travel"], "Moving for Goldman internship. Love baking cupcakes!"),
            ("karan@cohabio.com", "Karan Mehta", 25, "Male", "NMIMS Mumbai", "PwC", "Mumbai", "Bangalore", 12000, 20000, 4, "flexible", "standard_9_5", False, "socially", "no", "any", ["Finance", "Gym", "Football"], "Consultant at PwC. Looking for flatmates near Indiranagar."),
            ("sneha@cohabio.com", "Sneha Rao", 21, "Female", "PES University", "Accenture", "Mangalore", "Bangalore", 8000, 14000, 5, "night_owl", "flexible", False, "never", "no", "vegetarian", ["Painting", "Series", "Coffee"], "PES final year. Looking for pg roomie."),
            ("aditya@cohabio.com", "Aditya Verma", 23, "Male", "BITS Pilani", "Microsoft", "Delhi", "Bangalore", 15000, 25000, 3, "night_owl", "flexible", True, "regularly", "yes", "any", ["Tech", "Parties", "Anime"], "Microsoft SDE. Chill guy, loves anime."),
            ("pooja@cohabio.com", "Pooja Patel", 22, "Female", "NIFT Bangalore", "Myntra", "Ahmedabad", "Bangalore", 9000, 15000, 4, "flexible", "flexible", False, "never", "friendly", "vegetarian", ["Fashion", "Design", "Foodie"], "Myntra designer. Down to earth, veg prefer."),
            ("rahul@cohabio.com", "Rahul Reddy", 24, "Male", "RV College", "Infosys", "Hyderabad", "Bangalore", 7000, 12000, 3, "flexible", "standard_9_5", False, "socially", "no", "any", ["Movies", "Foodie", "Tea"], "Infosys associate. Simple guy, budget roomie."),
            ("meera@cohabio.com", "Meera Joshi", 23, "Female", "DU Delhi", "Flipkart", "Pune", "Bangalore", 11000, 17000, 5, "early", "standard_9_5", False, "never", "no", "any", ["Trekking", "Writing", "Cycling"], "Flipkart manager. Organized and love outdoor runs."),
            ("kabir@cohabio.com", "Kabir Roy", 25, "Male", "IIIT Bangalore", "Intel", "Lucknow", "Bangalore", 13000, 19000, 4, "night_owl", "remote", False, "socially", "friendly", "non-veg", ["Gaming", "Gym", "Music"], "Intel intern. Hardcore gamer.")
        ]

        student_users = []
        for index, item in enumerate(students_data):
            email, name, age, gen, college, company, h_city, c_city, b_min, b_max, clean, sleep, work, smoke, drink, pets, food, interests, bio = item
            
            u = User(
                email=email,
                hashed_password=get_password_hash("Password@123"),
                role="user",
                is_verified=True
            )
            db.add(u)
            db.flush()
            student_users.append(u)
            
            prof = Profile(
                user_id=u.id,
                full_name=name,
                age=age,
                gender=gen,
                occupation="Intern" if "Intern" in company or "intern" in company else "Professional",
                college=college,
                company=company,
                languages=["English", "Hindi"],
                home_state=h_city + " State",
                home_city=h_city,
                current_city=c_city,
                budget_min=Decimal(str(b_min)),
                budget_max=Decimal(str(b_max)),
                bio=bio,
                avatar_url=f"https://images.unsplash.com/photo-{1500000000000 + index*5000}?auto=format&fit=crop&w=150&q=80",
                verification_status="verified"
            )
            db.add(prof)
            db.flush()
            
            life = LifestylePreference(
                profile_id=prof.id,
                food_pref=food,
                smoking=smoke,
                drinking=drink,
                pets=pets,
                sleep_schedule=sleep,
                work_schedule=work,
                cleanliness_rating=clean,
                interests=interests
            )
            db.add(life)
            users_dict[email] = u

        db.commit()

        print("Seeding 5 communities...")
        # 5 Communities
        communities_data = [
            ("Bangalore Techies & Interns", "blr-tech", "Official space for engineers relocating to Bengaluru.", "city", "https://images.unsplash.com/photo-1596176530529-78163a4f7af2?auto=format&fit=crop&w=150&q=80", "Bangalore"),
            ("Kannada Language & Culture Club", "kannada-club", "Mingle with native speakers and pick up local Kannada phrases.", "language", "https://images.unsplash.com/photo-1608958416719-f81d11ca72aa?auto=format&fit=crop&w=150&q=80", "Bangalore"),
            ("PES University Relocation Hub", "pes-hub", "Connecting students and alumni for rooms and roommate shares.", "college", "https://images.unsplash.com/photo-1541339907198-e08756dedf3f?auto=format&fit=crop&w=150&q=80", "Bangalore"),
            ("Indiranagar Roomies Club", "indiranagar-roomies", "Exclusive group for finding house shares in Indiranagar/HSR.", "interest", "https://images.unsplash.com/photo-1568605114967-8130f3a36994?auto=format&fit=crop&w=150&q=80", "Bangalore"),
            ("Sports & Trekking Bengaluru", "blr-trekking", "Weekend football meetups and trekking getaways near Bangalore.", "interest", "https://images.unsplash.com/photo-1551632811-561732d1e306?auto=format&fit=crop&w=150&q=80", "Bangalore")
        ]

        communities = []
        for name, slug, desc, cat, icon, city in communities_data:
            c = Community(
                name=name,
                slug=slug,
                description=desc,
                category=cat,
                icon_url=icon,
                city_name=city,
                member_count=12,
                is_verified=True
            )
            db.add(c)
            db.flush()
            communities.append(c)

            # Add all seeded users to communities
            for u in users_dict.values():
                db.execute(Base.metadata.tables['community_members'].insert().values(
                    community_id=c.id,
                    user_id=u.id,
                    role="member"
                ))
        db.commit()

        print("Seeding 20 properties...")
        # 20 Housing Listings
        owner = users_dict["owner@cohabio.com"]
        property_list = [
            ("Cozy 1BHK near HSR Layout", "Fully furnished apartment ideal for single professionals. High-speed wifi included.", 14000, 30000, "Sector 4, HSR Layout", "Bangalore", 12.9141, 77.6413, "single_room", 1),
            ("Spacious 2BHK in Indiranagar", "Great shared apartment with modular kitchen and modular wardrobe. Friendly owner.", 22000, 50000, "12th Main Road, Indiranagar", "Bangalore", 12.9719, 77.6412, "shared_room", 2),
            ("Premium PG for Girls near VIT", "Fully secure PG with laundry, meals thrice a day, and 24/7 security guard.", 9500, 15000, "Katpadi Road, Vellore", "Vellore", 12.9692, 79.1559, "PG", 4),
            ("Modern Studio near Koramangala 5th Block", "AC, washing machine, fridge, geyser all fitted. Walkable distance to major pubs.", 17500, 40000, "Koramangala 5th Block", "Bangalore", 12.9348, 77.6189, "full_apartment", 1),
            ("Student Flatshare in HSR Sector 2", "Fully set up 3BHK flat. Looking for roommates. High speed fiber.", 10000, 20000, "Sector 2, HSR Layout", "Bangalore", 12.9100, 77.6450, "shared_room", 3),
            ("Luxury Penthouse, Whitefield", "Close to ITPL. Private terrace, pool access, gym, power backup.", 32000, 80000, "ECC Road, Whitefield", "Bangalore", 12.9698, 77.7500, "full_apartment", 2),
            ("Budget Single Room near PES University", "Clean room for students. Shared bathroom. Rent includes water bill.", 5500, 10000, "Hosakerehalli, Banashankari", "Bangalore", 12.9340, 77.5340, "single_room", 1),
            ("Co-living Space near Manyata Tech Park", "Double sharing with food, gym, indoor sports. Cleaning service every day.", 11000, 22000, "Hebbal Outer Ring Rd", "Bangalore", 13.0300, 77.6200, "PG", 2),
            ("Unfurnished 2BHK, Jayanagar 4th Block", "Family friendly but students allowed if quiet. Close to metro station.", 18000, 60000, "Jayanagar 4th Block", "Bangalore", 12.9280, 77.5830, "full_apartment", 2),
            ("Modern 1BHK in Domlur", "Furnished with smart TV, bed, washing machine, fridge, microwave.", 16000, 35000, "Domlur Stage 2", "Bangalore", 12.9610, 77.6380, "single_room", 1),
            ("Shared PG for Men in Electronic City", "Walkable to Infosys. WiFi, food, power backup.", 8000, 15000, "Phase 1, Electronic City", "Bangalore", 12.8450, 77.6630, "PG", 2),
            ("Lavish 3BHK near Silk Board", "High floor, spacious balconies. Good transit links to HSR and Koramangala.", 26000, 70000, "Madiwala", "Bangalore", 12.9180, 77.6220, "full_apartment", 3),
            ("Chic Loft Room, Indiranagar", "Unique rooftop room, open garden terrace, fully loaded kitchen.", 19000, 45000, "Hal 2nd Stage, Indiranagar", "Bangalore", 12.9650, 77.6440, "single_room", 1),
            ("Student PG near Christ University", "Double sharing PG. Strictly veg food, clean washrooms.", 8500, 17000, "SG Palya", "Bangalore", 12.9360, 77.6090, "PG", 2),
            ("Fully Serviced 1BHK, Bellandur", "Includes cleaning, laundry, wifi, DTH. Close to EcoSpace.", 23000, 50000, "Green Glen Layout, Bellandur", "Bangalore", 12.9260, 77.6780, "single_room", 1),
            ("Cozy Studio near BTM Lake", "Near parks and eateries. Power backup, security camera.", 11500, 25000, "BTM Layout 2nd Stage", "Bangalore", 12.9120, 77.6020, "full_apartment", 1),
            ("Spacious Penthouse, Indiranagar 100ft Road", "Huge private deck, bar cabinet, luxury bathrooms, parking.", 45000, 120000, "100 Feet Road, Indiranagar", "Bangalore", 12.9750, 77.6390, "full_apartment", 2),
            ("Double Sharing Room, PG Road", "Clean room, study table, balcony. Security guard.", 7000, 14000, "Koramangala 8th Block", "Bangalore", 12.9390, 77.6250, "shared_room", 2),
            ("Compact 1BHK, Kalyan Nagar", "Near restaurants. Ideal for freelancers. Peaceful neighborhood.", 13000, 30000, "Kalyan Nagar HRBR Layout", "Bangalore", 13.0220, 77.6490, "single_room", 1),
            ("3BHK Duplex Flat, HSR Sector 3", "Lush green lane. Semi-furnished, modular closets, double parking space.", 35000, 90000, "Sector 3, HSR Layout", "Bangalore", 12.9150, 77.6490, "full_apartment", 3)
        ]

        amenities_samples = ["Wifi", "AC", "Power Backup", "Geyser", "Washing Machine", "Gym", "Security Guard", "Kitchen"]

        for idx, item in enumerate(property_list):
            title, desc, price, dep, addr, city, lat, lng, rtype, max_occ = item
            prop = Property(
                owner_id=owner.id,
                title=title,
                description=desc,
                price_per_month=Decimal(str(price)),
                deposit=Decimal(str(dep)),
                address=addr,
                city=city,
                location_lat=lat,
                location_lng=lng,
                room_type=rtype,
                max_occupancy=max_occ,
                status="available"
            )
            db.add(prop)
            db.flush()

            # Add property image
            db.add(PropertyImage(
                property_id=prop.id,
                image_url=f"https://images.unsplash.com/photo-{1564013799919 + idx*10000}?auto=format&fit=crop&w=400&q=80",
                display_order=0
            ))

            # Add some amenities
            prop_amenities = [amenities_samples[i % len(amenities_samples)] for i in range(idx, idx + 4)]
            for am in set(prop_amenities):
                db.add(PropertyAmenity(property_id=prop.id, amenity_name=am))
        
        db.commit()

        print("Seeding 5 community events...")
        # 5 Events
        community_id = communities[0].id
        events_data = [
            ("Saturday Football Meetup", "Weekend friendly football match. Everyone welcome!", "PlayArena HSR Layout", 12.9128, 77.6698, datetime.utcnow() + timedelta(days=2)),
            ("Tech Intern Networking Mixer", "Meet fellow interns from Google, Amazon, Microsoft, and startups.", "Indiranagar Social", 12.9719, 77.6412, datetime.utcnow() + timedelta(days=5)),
            ("Local Kannada Learning Class", "Learn basic conversational Kannada for daily life.", "PES University Campus", 12.9340, 77.5340, datetime.utcnow() + timedelta(days=3)),
            ("HSR Layout Food Walk", "Exploring the famous food outlets and street food joints in HSR.", "HSR Sector 1 BDA Complex", 12.9100, 77.6450, datetime.utcnow() + timedelta(days=1)),
            ("Nandi Hills Sunrise Ride", "Cycling / riding group to Nandi hills on Sunday morning.", "Nandi Hills Bangalore", 13.3702, 77.6835, datetime.utcnow() + timedelta(days=6))
        ]

        events = []
        for title, desc, loc, lat, lng, time in events_data:
            ev = Event(
                community_id=community_id,
                organizer_id=users_dict["student@cohabio.com"].id,
                title=title,
                description=desc,
                location_name=loc,
                lat=lat,
                lng=lng,
                start_time=time,
                rsvp_count=3
            )
            db.add(ev)
            db.flush()
            events.append(ev)

            # Add RSVPs
            for u in list(users_dict.values())[:3]:
                db.execute(event_rsvps.insert().values(
                    event_id=ev.id,
                    user_id=u.id,
                    status="going"
                ))

        db.commit()

        print("Seeding roommate match swipes and mutual likes...")
        # Roommate Matches
        student1 = users_dict["student@cohabio.com"]
        student2 = users_dict["aanya@cohabio.com"] # Aanya Iyer
        student3 = users_dict["vikram@cohabio.com"] # Vikram Sen

        # Mutual Like -> Matched
        u1, u2 = min(student1.id, student2.id), max(student1.id, student2.id)
        db.add(RoommateMatch(user1_id=u1, user2_id=u2, match_score=94, status="matched"))
        
        # Single Like
        u1_3, u2_3 = min(student1.id, student3.id), max(student1.id, student3.id)
        db.add(RoommateMatch(user1_id=u1_3, user2_id=u2_3, match_score=82, status="liked"))

        # Create chat room for matched pair
        chat_room = ChatRoom(type="direct")
        db.add(chat_room)
        db.flush()

        db.execute(chat_participants.insert().values(room_id=chat_room.id, user_id=student1.id))
        db.execute(chat_participants.insert().values(room_id=chat_room.id, user_id=student2.id))

        # Seed Chat Messages
        db.add(Message(room_id=chat_room.id, sender_id=student2.id, content="Hey! I saw we matched. You are moving to Bangalore soon as well?", is_read=True))
        db.add(Message(room_id=chat_room.id, sender_id=student1.id, content="Hey Aanya! Yes, moving this May for my Google internship. Budget matches too. Looking at HSR Layout.", is_read=True))
        db.add(Message(room_id=chat_room.id, sender_id=student2.id, content="Awesome, I am joining Amazon nearby. Let's find a flat share together!", is_read=False))

        db.commit()

        print("Seeding waitlist...")
        # Landing Page Waitlist entries
        db.add(Waitlist(email="raj.patel@gmail.com", full_name="Raj Patel", current_city="Ahmedabad", target_city="Bangalore"))
        db.add(Waitlist(email="kavya.nair@outlook.com", full_name="Kavya Nair", current_city="Kochi", target_city="Bangalore"))
        db.add(Waitlist(email="abhishek.s@gmail.com", full_name="Abhishek Sharma", current_city="Pune", target_city="Mumbai"))
        
        db.commit()
        print("Database seeded successfully with all required MVP records!")

    except Exception as e:
        db.rollback()
        print(f"Error seeding database: {e}")
        raise e
    finally:
        db.close()

if __name__ == "__main__":
    seed_database()
