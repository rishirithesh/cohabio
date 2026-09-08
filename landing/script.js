// Cohabio Enhanced Landing Page Script
// Real-Working Features mirrored from the Mobile Application:
// 1. Swipeable Roommate Discovery Cards & Match Celebration Modal
// 2. Verified Housing & PG Marketplace with Schedule Tour Modal
// 3. City Welcome Mixers & RSVP System
// 4. Roommate Living Agreement Generator
// 5. Gemini AI Relocation Copilot
// 6. Financial Relocation Cost Estimator & Checklist Planner
// 7. VIP Holographic Early Access Pass & Confetti Engine

const API_BASE_URL = window.COHABIO_API_URL || 'http://127.0.0.1:8001';

// ==========================================
// 1. FLUID CURSOR & MOTION ENGINES
// ==========================================
const cursorDot = document.getElementById('cursorDot');
const cursorAura = document.getElementById('cursorAura');

let mouseX = window.innerWidth / 2;
let mouseY = window.innerHeight / 2;
let auraX = mouseX;
let auraY = mouseY;

if (cursorDot && cursorAura && window.matchMedia('(pointer: fine)').matches) {
  window.addEventListener('mousemove', (e) => {
    mouseX = e.clientX;
    mouseY = e.clientY;
    cursorDot.style.left = `${mouseX}px`;
    cursorDot.style.top = `${mouseY}px`;
  });

  function renderCursor() {
    auraX += (mouseX - auraX) * 0.16;
    auraY += (mouseY - auraY) * 0.16;
    cursorAura.style.left = `${auraX}px`;
    cursorAura.style.top = `${auraY}px`;
    requestAnimationFrame(renderCursor);
  }
  requestAnimationFrame(renderCursor);

  const interactiveSelector = 'a, button, input, select, textarea, .tinder-card, .property-card, .event-main-card, .checklist-item, .community-card';
  document.addEventListener('mouseover', (e) => {
    if (e.target.closest(interactiveSelector)) cursorAura.classList.add('active');
  });
  document.addEventListener('mouseout', (e) => {
    if (e.target.closest(interactiveSelector)) cursorAura.classList.remove('active');
  });
}

// Spotlight Card Tracking
function initSpotlights() {
  document.querySelectorAll('[data-spotlight="true"]').forEach((el) => {
    el.addEventListener('mousemove', (e) => {
      const rect = el.getBoundingClientRect();
      el.style.setProperty('--spotlight-x', `${e.clientX - rect.left}px`);
      el.style.setProperty('--spotlight-y', `${e.clientY - rect.top}px`);
    });
  });
}
initSpotlights();

// 3D Tilt Parallax
function initTilts() {
  document.querySelectorAll('[data-tilt="true"]').forEach((el) => {
    el.addEventListener('mousemove', (e) => {
      const rect = el.getBoundingClientRect();
      const x = e.clientX - rect.left - rect.width / 2;
      const y = e.clientY - rect.top - rect.height / 2;
      const rotateX = -(y / (rect.height / 2)) * 6;
      const rotateY = (x / (rect.width / 2)) * 6;
      el.style.transform = `perspective(1000px) rotateX(${rotateX.toFixed(2)}deg) rotateY(${rotateY.toFixed(2)}deg)`;
    });
    el.addEventListener('mouseleave', () => {
      el.style.transform = 'perspective(1000px) rotateX(0deg) rotateY(0deg)';
    });
  });
}
initTilts();

// Magnetic Elements
function initMagnetics() {
  document.querySelectorAll('[data-magnet="true"]').forEach((el) => {
    el.addEventListener('mousemove', (e) => {
      const rect = el.getBoundingClientRect();
      const x = e.clientX - rect.left - rect.width / 2;
      const y = e.clientY - rect.top - rect.height / 2;
      el.style.transform = `translate(${x * 0.2}px, ${y * 0.2}px)`;
    });
    el.addEventListener('mouseleave', () => {
      el.style.transform = 'translate(0px, 0px)';
    });
  });
}
initMagnetics();

// Scroll Progress & Nav
const scrollProgressBar = document.getElementById('scrollProgressBar');
const backToTopBtn = document.getElementById('backToTopBtn');
const navLinks = document.querySelectorAll('.desktop-nav a, .mobile-nav a');
const sections = document.querySelectorAll('section[id]');

window.addEventListener('scroll', () => {
  const scrollTop = window.scrollY;
  const docHeight = document.documentElement.scrollHeight - window.innerHeight;
  const scrollPct = docHeight > 0 ? (scrollTop / docHeight) * 100 : 0;

  if (scrollProgressBar) scrollProgressBar.style.width = `${scrollPct}%`;

  if (backToTopBtn) {
    if (scrollTop > 400) backToTopBtn.classList.add('visible');
    else backToTopBtn.classList.remove('visible');
  }

  let currentSec = '';
  sections.forEach((sec) => {
    const secTop = sec.offsetTop - 150;
    if (scrollTop >= secTop && scrollTop < secTop + sec.offsetHeight) {
      currentSec = sec.getAttribute('id');
    }
  });

  navLinks.forEach((link) => {
    link.classList.remove('active');
    if (link.getAttribute('href') === `#${currentSec}`) link.classList.add('active');
  });
});

if (backToTopBtn) {
  backToTopBtn.addEventListener('click', () => {
    window.scrollTo({ top: 0, behavior: 'smooth' });
  });
}

// Mobile Hamburger
const hamburgerBtn = document.getElementById('hamburger-btn');
const mobileNav = document.getElementById('mobile-nav');

if (hamburgerBtn && mobileNav) {
  hamburgerBtn.addEventListener('click', () => mobileNav.classList.toggle('open'));
  document.querySelectorAll('.mobile-nav-link').forEach((l) => {
    l.addEventListener('click', () => mobileNav.classList.remove('open'));
  });
}

// ==========================================
// 2. CONFETTI PHYSICS ENGINE
// ==========================================
function triggerConfetti() {
  const canvas = document.getElementById('confettiCanvas');
  if (!canvas) return;
  const ctx = canvas.getContext('2d');
  canvas.width = window.innerWidth;
  canvas.height = window.innerHeight;

  const particles = [];
  const colors = ['#10B981', '#38BDF8', '#8B5CF6', '#F59E0B', '#EC4899', '#FFFFFF'];

  for (let i = 0; i < 110; i++) {
    particles.push({
      x: canvas.width / 2,
      y: canvas.height / 2,
      vx: (Math.random() - 0.5) * 16,
      vy: (Math.random() - 0.8) * 16,
      size: Math.random() * 8 + 4,
      color: colors[Math.floor(Math.random() * colors.length)],
      rotation: Math.random() * 360,
      rSpeed: (Math.random() - 0.5) * 10,
      opacity: 1
    });
  }

  function renderConfetti() {
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    let alive = false;
    particles.forEach((p) => {
      p.x += p.vx;
      p.y += p.vy;
      p.vy += 0.35; // Gravity
      p.vx *= 0.98;
      p.rotation += p.rSpeed;
      p.opacity -= 0.012;

      if (p.opacity > 0) {
        alive = true;
        ctx.save();
        ctx.translate(p.x, p.y);
        ctx.rotate((p.rotation * Math.PI) / 180);
        ctx.fillStyle = p.color;
        ctx.globalAlpha = Math.max(p.opacity, 0);
        ctx.fillRect(-p.size / 2, -p.size / 2, p.size, p.size);
        ctx.restore();
      }
    });

    if (alive) requestAnimationFrame(renderConfetti);
    else ctx.clearRect(0, 0, canvas.width, canvas.height);
  }
  requestAnimationFrame(renderConfetti);
}

// ==========================================
// 3. REAL FEATURE 1: SWIPEABLE ROOMMATE DISCOVERY (MOBILE APP MIRROR)
// ==========================================
const SWIPE_ROOMMATES = [
  {
    id: "aanya",
    name: "Aanya Iyer",
    age: 23,
    role: "Data Analyst @ Amazon • Delhi ➔ Bangalore",
    targetArea: "HSR Layout Sector 2",
    city: "bangalore",
    budget: 15000,
    avatar: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=500",
    compat: 96,
    tags: ["🌙 Night Owl", "🥗 Vegetarian", "✨ Clean: 5/5", "☕ Coffee Lover"],
    bio: "Moving to Bangalore for my role at Amazon. Super clean, loves quiet weekdays and board games on weekends!"
  },
  {
    id: "rohan",
    name: "Rohan Verma",
    age: 24,
    role: "Software Engineer @ Razorpay • Mumbai ➔ Bangalore",
    targetArea: "Koramangala 4th Block",
    city: "bangalore",
    budget: 22000,
    avatar: "https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=500",
    compat: 94,
    tags: ["🎮 Gamer", "🍗 Non-Veg", "✨ Clean: 5/5", "💻 Open Source"],
    bio: "SDE working in Koramangala. Looking for a flatmate to share a 2BHK. High-speed internet is a must!"
  },
  {
    id: "tanvi",
    name: "Tanvi Kulkarni",
    age: 22,
    role: "Growth Analyst @ CRED • Pune ➔ Bangalore",
    targetArea: "Indiranagar 100ft Rd",
    city: "bangalore",
    budget: 28000,
    avatar: "https://images.unsplash.com/photo-1517841905240-472988babdf9?w=500",
    compat: 92,
    tags: ["☀️ Early Bird", "🌱 Vegan", "🧘 Yoga & Fitness", "📚 Bookworm"],
    bio: "Incoming analyst at CRED. Early riser, love calm mornings, house plants, and aesthetic spaces."
  },
  {
    id: "dev",
    name: "Dev Mhatre",
    age: 23,
    role: "Financial Analyst @ Deloitte • Delhi ➔ Mumbai",
    targetArea: "BKC / Bandra East",
    city: "mumbai",
    budget: 26000,
    avatar: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=500",
    compat: 95,
    tags: ["📈 FinTech", "🥗 Vegetarian", "🚴 Cyclist", "🏎️ Formula 1"],
    bio: "Working at Deloitte BKC. Looking for a friendly roomie to split a furnished 2BHK."
  },
  {
    id: "sneha",
    name: "Sneha Reddy",
    age: 24,
    role: "SDE-2 @ Amazon • Chennai ➔ Hyderabad",
    targetArea: "Gachibowli / HITEC City",
    city: "hyderabad",
    budget: 18000,
    avatar: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=500",
    compat: 93,
    tags: ["⚡ Flexible", "🍗 Foodie", "🏔️ Trekker", "🎲 Board Games"],
    bio: "Relocating to Hyderabad. Looking for a neat flatmate in a gated society with gym & power backup."
  },
  {
    id: "vikram",
    name: "Vikramaditya Roy",
    age: 25,
    role: "Product Lead @ Zomato • Kolkata ➔ Gurgaon",
    targetArea: "Cyber City / DLF Phase 2",
    city: "gurgaon",
    budget: 35000,
    avatar: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=500",
    compat: 91,
    tags: ["🌙 Night Owl", "🍗 Non-Veg", "🎾 Tennis", "🎙️ Podcasts"],
    bio: "Product guy at Zomato. Easygoing, love cooking weekend meals and exploring good coffee spots."
  }
];

let activeSwipeIndex = 0;
let swipeHistory = [];

const cardAvatar = document.getElementById('cardAvatar');
const cardNameAge = document.getElementById('cardNameAge');
const cardBudget = document.getElementById('cardBudget');
const cardRole = document.getElementById('cardRole');
const cardTags = document.getElementById('cardTags');
const deckCompatBadge = document.getElementById('deckCompatBadge');
const swipeCityFilter = document.getElementById('swipeCityFilter');

const swipeLikeBtn = document.getElementById('swipeLikeBtn');
const swipePassBtn = document.getElementById('swipePassBtn');
const swipeSuperlikeBtn = document.getElementById('swipeSuperlikeBtn');
const swipeRewindBtn = document.getElementById('swipeRewindBtn');

// Modals for matching
const matchCelebrationModal = document.getElementById('matchCelebrationModal');
const matchModalAvatar = document.getElementById('matchModalAvatar');
const matchModalCandidateName = document.getElementById('matchModalCandidateName');
const matchModalScoreText = document.getElementById('matchModalScoreText');
const closeMatchModalBtn = document.getElementById('closeMatchModalBtn');
const keepSwipingBtn = document.getElementById('keepSwipingBtn');
const openChatFromMatchBtn = document.getElementById('openChatFromMatchBtn');

function getFilteredRoommates() {
  const city = swipeCityFilter ? swipeCityFilter.value : 'all';
  if (city === 'all') return SWIPE_ROOMMATES;
  return SWIPE_ROOMMATES.filter(r => r.city === city);
}

function updateSwipeCard() {
  const pool = getFilteredRoommates();
  if (pool.length === 0) return;
  const curr = pool[activeSwipeIndex % pool.length];

  const card = document.getElementById('activeSwipeCard');
  if (card) {
    card.style.opacity = '0.5';
    card.style.transform = 'scale(0.96)';
    setTimeout(() => {
      card.style.opacity = '1';
      card.style.transform = 'scale(1)';
    }, 120);
  }

  if (cardAvatar) cardAvatar.src = curr.avatar;
  if (cardNameAge) cardNameAge.textContent = `${curr.name}, ${curr.age}`;
  if (cardBudget) cardBudget.textContent = `₹${curr.budget.toLocaleString('en-IN')}/mo`;
  if (cardRole) cardRole.textContent = curr.role;
  if (deckCompatBadge) deckCompatBadge.textContent = `${curr.compat}% Match`;

  if (cardTags) {
    cardTags.innerHTML = curr.tags.map(t => `<span class="m-tag">${t}</span>`).join('');
  }
}

function handleSwipe(action) {
  const pool = getFilteredRoommates();
  if (pool.length === 0) return;
  const currentPerson = pool[activeSwipeIndex % pool.length];
  swipeHistory.push(activeSwipeIndex);

  if (action === 'like' || action === 'superlike') {
    // Trigger It's a Match Celebration Modal!
    triggerConfetti();
    if (matchCelebrationModal && matchModalAvatar && matchModalCandidateName && matchModalScoreText) {
      matchModalAvatar.src = currentPerson.avatar;
      matchModalCandidateName.textContent = currentPerson.name.split(' ')[0];
      matchModalScoreText.textContent = `${currentPerson.compat}%`;
      matchCelebrationModal.classList.remove('hidden');
    }
  }

  activeSwipeIndex = (activeSwipeIndex + 1) % pool.length;
  updateSwipeCard();
}

if (swipeLikeBtn) swipeLikeBtn.addEventListener('click', () => handleSwipe('like'));
if (swipeSuperlikeBtn) swipeSuperlikeBtn.addEventListener('click', () => handleSwipe('superlike'));
if (swipePassBtn) swipePassBtn.addEventListener('click', () => handleSwipe('pass'));
if (swipeRewindBtn) {
  swipeRewindBtn.addEventListener('click', () => {
    if (swipeHistory.length > 0) {
      activeSwipeIndex = swipeHistory.pop();
      updateSwipeCard();
    }
  });
}

if (swipeCityFilter) {
  swipeCityFilter.addEventListener('change', () => {
    activeSwipeIndex = 0;
    updateSwipeCard();
  });
}

if (closeMatchModalBtn) closeMatchModalBtn.addEventListener('click', () => matchCelebrationModal.classList.add('hidden'));
if (keepSwipingBtn) keepSwipingBtn.addEventListener('click', () => matchCelebrationModal.classList.add('hidden'));
if (openChatFromMatchBtn) {
  openChatFromMatchBtn.addEventListener('click', () => {
    matchCelebrationModal.classList.add('hidden');
    const pool = getFilteredRoommates();
    const matchedPerson = pool[(activeSwipeIndex - 1 + pool.length) % pool.length];
    openDirectConnectModal(matchedPerson);
  });
}

// ==========================================
// 4. REAL FEATURE 2: VERIFIED HOUSING MARKETPLACE
// ==========================================
const HOUSING_LISTINGS = [
  {
    id: "h1",
    title: "Green Glen 2BHK Luxury Flatshare",
    location: "Bellandur, Bangalore",
    distance: "0.9 km to RMZ Ecospace • 1 Flatmate Slot",
    price: 14500,
    type: "flat_share",
    city: "bangalore",
    image: "https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=500",
    amenities: ["📶 200 Mbps Wifi", "⚡ Power Backup", "❄️ AC", "🏋️ Gym Access"],
    landlord: "Verified Landlord (Direct Lease)"
  },
  {
    id: "h2",
    title: "HSR Sector 2 Premium Co-Living PG",
    location: "HSR Layout, Bangalore",
    distance: "Near Sony World Signal • 2 Sharing Room",
    price: 11000,
    type: "pg_shared",
    city: "bangalore",
    image: "https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=500",
    amenities: ["🍱 3-Times Food", "🧹 Daily Cleaning", "🚿 Geyser", "🔒 Biometric Lock"],
    landlord: "Roomie Verified Property"
  },
  {
    id: "h3",
    title: "Powai Lake View 3BHK Master Bed",
    location: "Powai, Mumbai",
    distance: "1.2 km to Hiranandani Gardens • Private Bath",
    price: 22000,
    type: "flat_share",
    city: "mumbai",
    image: "https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=500",
    amenities: ["🏊 Swimming Pool", "❄️ Air Conditioner", "🍳 Modular Kitchen", "🌅 Lake View"],
    landlord: "Verified Owner"
  },
  {
    id: "h4",
    title: "HITEC Cyber Towers Studio Suite",
    location: "Gachibowli, Hyderabad",
    distance: "0.5 km to Metro Station • 1 BHK Solo",
    price: 16500,
    type: "private",
    city: "hyderabad",
    image: "https://images.unsplash.com/photo-1536376072261-38c75010e6c9?w=500",
    amenities: ["⚡ 24/7 Power", "🅿️ Covered Parking", "📶 High-Speed Wifi", "🛋️ Furnished"],
    landlord: "Direct Owner Lease"
  },
  {
    id: "h5",
    title: "DLF Cyber City Executive Room",
    location: "DLF Phase 2, Gurgaon",
    distance: "Walk to Rapid Metro • Gated Society",
    price: 18000,
    type: "flat_share",
    city: "gurgaon",
    image: "https://images.unsplash.com/photo-1502005229762-ee1b2da9730d?w=500",
    amenities: ["❄️ 1.5 Ton AC", "📺 43\" Smart TV", "🧹 Maid Included", "🔒 Gated Security"],
    landlord: "Verified Co-Living"
  },
  {
    id: "h6",
    title: "Indiranagar 100ft Road Boutique PG",
    location: "Indiranagar, Bangalore",
    distance: "2 min walk to 12th Main • Single Room",
    price: 19000,
    type: "private",
    city: "bangalore",
    image: "https://images.unsplash.com/photo-1493809842364-78817add7ffb?w=500",
    amenities: ["☕ Cafe on Terrace", "📶 300 Mbps Wifi", "🍱 Gourmet Breakfast", "🧺 Laundry"],
    landlord: "Cohabio Curated Space"
  }
];

const housingStream = document.getElementById('housingStream');
const mainHousingGrid = document.getElementById('mainHousingGrid');
const housingCitySelect = document.getElementById('housingCitySelect');
const housingTypeSelect = document.getElementById('housingTypeSelect');

// Schedule Visit Modal
const scheduleVisitModal = document.getElementById('scheduleVisitModal');
const closeVisitModalBtn = document.getElementById('closeVisitModalBtn');
const visitPropertySummary = document.getElementById('visitPropertySummary');
const visitForm = document.getElementById('visitForm');

let selectedVisitProperty = null;

function renderHousingListings() {
  const city = housingCitySelect ? housingCitySelect.value : 'bangalore';
  const type = housingTypeSelect ? housingTypeSelect.value : 'all';

  const filtered = HOUSING_LISTINGS.filter(h => {
    const matchCity = (city === 'all' || h.city === city);
    const matchType = (type === 'all' || h.type === type);
    return matchCity && matchType;
  });

  // Render in Mobile Phone Stream
  if (housingStream) {
    housingStream.innerHTML = filtered.map(h => `
      <div class="mini-housing-card">
        <img src="${h.image}" alt="${h.title}" class="mini-h-img">
        <div class="mini-h-body">
          <div class="mini-h-title">${h.title}</div>
          <div class="mini-h-price">₹${h.price.toLocaleString('en-IN')}/month • Zero Brokerage</div>
          <div class="mini-h-amenities">
            ${h.amenities.slice(0, 3).map(a => `<span class="h-tag">${a}</span>`).join('')}
          </div>
          <button class="btn btn-primary btn-sm mini-h-btn" onclick="openScheduleVisitModal('${h.id}')">
            Schedule Free Visit 📅
          </button>
        </div>
      </div>
    `).join('');
  }

  // Render in Main Section Grid
  if (mainHousingGrid) {
    mainHousingGrid.innerHTML = HOUSING_LISTINGS.map(h => `
      <div class="property-card spotlight-card" data-spotlight="true" data-tilt="true">
        <img src="${h.image}" alt="${h.title}" class="property-card-img">
        <div class="property-card-body">
          <div class="property-price">₹${h.price.toLocaleString('en-IN')} <span style="font-size: 0.85rem; color: var(--neutral-400); font-weight: 500;">/ month</span></div>
          <h3 class="property-title">${h.title}</h3>
          <p class="property-distance">📍 ${h.location} • ${h.distance}</p>
          <div class="property-amenity-pills">
            ${h.amenities.map(a => `<span class="amenity-pill">${a}</span>`).join('')}
          </div>
          <button class="btn btn-primary btn-sm btn-shine" style="margin-top: auto;" onclick="openScheduleVisitModal('${h.id}')">
            Schedule Free Inspection Visit 🚀
          </button>
        </div>
      </div>
    `).join('');
    initSpotlights();
    initTilts();
  }
}

window.openScheduleVisitModal = function(id) {
  const prop = HOUSING_LISTINGS.find(h => h.id === id) || HOUSING_LISTINGS[0];
  selectedVisitProperty = prop;

  if (visitPropertySummary) {
    visitPropertySummary.innerHTML = `
      <strong>${prop.title}</strong><br>
      📍 ${prop.location} • Rent: <strong style="color: #10B981;">₹${prop.price.toLocaleString('en-IN')}/mo</strong>
    `;
  }

  if (scheduleVisitModal) scheduleVisitModal.classList.remove('hidden');
};

if (closeVisitModalBtn) closeVisitModalBtn.addEventListener('click', () => scheduleVisitModal.classList.add('hidden'));

if (visitForm) {
  visitForm.addEventListener('submit', (e) => {
    e.preventDefault();
    const date = document.getElementById('visitDate').value;
    const time = document.getElementById('visitTime').value;
    const phone = document.getElementById('visitPhone').value;

    triggerConfetti();
    alert(`🎉 Visit Confirmed!\n\nProperty: ${selectedVisitProperty.title}\nAppointment: ${date} at ${time}\nConfirmation sent to: ${phone}\n\nThe verified property manager will meet you on site. Zero brokerage!`);
    scheduleVisitModal.classList.add('hidden');
    visitForm.reset();
  });
}

if (housingCitySelect) housingCitySelect.addEventListener('change', renderHousingListings);
if (housingTypeSelect) housingTypeSelect.addEventListener('change', renderHousingListings);

// ==========================================
// 5. REAL FEATURE 3: CITY WELCOME MIXERS & EVENTS
// ==========================================
const CITY_EVENTS = [
  {
    id: "e1",
    title: "Bangalore Techies & Freshers Chai Mixer",
    date: "SAT, 5:00 PM",
    venue: "Third Wave Coffee, HSR Layout, Sector 4",
    attendees: 42,
    city: "bangalore",
    desc: "Incoming SDEs and interns moving to Bangalore. Discuss PGs, flatmate openings, and share referrals!",
    icon: "☕"
  },
  {
    id: "e2",
    title: "Powai & BKC Young Finance Professionals",
    date: "SUN, 6:00 PM",
    venue: "Bastian, Bandra / Powai Lake View",
    attendees: 28,
    city: "mumbai",
    desc: "Connect with analysts and associates in banking, fintech, and consulting looking for flatmates.",
    icon: "🌆"
  },
  {
    id: "e3",
    title: "Cyberabad Weekend Board Game & Trek Meetup",
    date: "SAT, 4:00 PM",
    venue: "Roastery Coffee House, Gachibowli",
    attendees: 35,
    city: "hyderabad",
    desc: "Casual meetup for freshers moving to Hyderabad to explore trekking groups and roommate matches.",
    icon: "🎲"
  },
  {
    id: "e4",
    title: "Indiranagar Sunday Coffee & Startup Jam",
    date: "SUN, 11:00 AM",
    venue: "Araku Coffee, 100ft Road, Indiranagar",
    attendees: 56,
    city: "bangalore",
    desc: "Meet designers, developers, and founders relocating to Bangalore. High-energy, warm networking.",
    icon: "🚀"
  }
];

const eventsStream = document.getElementById('eventsStream');
const mainEventsGrid = document.getElementById('mainEventsGrid');
const eventRsvps = JSON.parse(localStorage.getItem('cohabio_event_rsvps') || '{}');

function renderEventsListings() {
  if (eventsStream) {
    eventsStream.innerHTML = CITY_EVENTS.map(ev => {
      const isRsvp = eventRsvps[ev.id];
      return `
        <div class="mini-event-card">
          <div class="event-top-row">
            <span class="event-date-chip">${ev.date}</span>
            <span class="attendee-count">👥 ${ev.attendees + (isRsvp ? 1 : 0)} Going</span>
          </div>
          <h5>${ev.icon} ${ev.title}</h5>
          <p>📍 ${ev.venue}</p>
          <div class="event-footer-row">
            <button class="btn ${isRsvp ? 'btn-primary' : 'btn-outline-primary'} btn-sm" onclick="toggleEventRsvp('${ev.id}')">
              ${isRsvp ? '✓ RSVP Confirmed' : '+ RSVP Free Pass'}
            </button>
          </div>
        </div>
      `;
    }).join('');
  }

  if (mainEventsGrid) {
    mainEventsGrid.innerHTML = CITY_EVENTS.map(ev => {
      const isRsvp = eventRsvps[ev.id];
      return `
        <div class="event-main-card spotlight-card" data-spotlight="true" data-tilt="true">
          <div class="event-main-body">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 0.75rem;">
              <span class="event-date-chip" style="font-size: 0.8rem; padding: 4px 10px;">${ev.date}</span>
              <span style="font-size: 0.85rem; color: #10B981; font-weight: 700;">● Free Entry</span>
            </div>
            <h3 style="font-size: 1.25rem; color: #fff; margin-bottom: 0.5rem;">${ev.icon} ${ev.title}</h3>
            <p style="color: var(--neutral-400); font-size: 0.9rem; margin-bottom: 0.75rem;">📍 ${ev.venue}</p>
            <p style="color: var(--neutral-300); font-size: 0.88rem; line-height: 1.5; margin-bottom: 1.25rem;">${ev.desc}</p>
            <div style="display: flex; justify-content: space-between; align-items: center; margin-top: auto; padding-top: 1rem; border-top: 1px solid rgba(255,255,255,0.06);">
              <span style="font-size: 0.82rem; color: var(--neutral-400);">👥 ${ev.attendees + (isRsvp ? 1 : 0)} Relocators Going</span>
              <button class="btn ${isRsvp ? 'btn-primary' : 'btn-outline-primary'} btn-sm" onclick="toggleEventRsvp('${ev.id}')">
                ${isRsvp ? '✓ Pass Reserved' : 'Reserve Free Ticket 🎟️'}
              </button>
            </div>
          </div>
        </div>
      `;
    }).join('');
    initSpotlights();
    initTilts();
  }
}

window.toggleEventRsvp = function(id) {
  if (eventRsvps[id]) {
    delete eventRsvps[id];
  } else {
    eventRsvps[id] = true;
    triggerConfetti();
  }
  localStorage.setItem('cohabio_event_rsvps', JSON.stringify(eventRsvps));
  renderEventsListings();
};

// ==========================================
// 6. REAL FEATURE 4: ROOMMATE LIVING AGREEMENT GENERATOR
// ==========================================
const generateAgreementBtn = document.getElementById('generateAgreementBtn');
const agreementOutputBox = document.getElementById('agreementOutputBox');
const agreementTextDisplay = document.getElementById('agreementTextDisplay');
const copyAgreementBtn = document.getElementById('copyAgreementBtn');
const downloadAgreementBtn = document.getElementById('downloadAgreementBtn');

if (generateAgreementBtn) {
  generateAgreementBtn.addEventListener('click', () => {
    const cleaning = document.getElementById('agreeCleaning').value;
    const quiet = document.getElementById('agreeQuiet').value;
    const guests = document.getElementById('agreeGuests').value;
    const split = document.getElementById('agreeSplit').value;

    const cleaningMap = {
      weekly_rotation: "Rotational Weekly Cleaning for common kitchen & hall.",
      cook_maid: "Daily Maid & Cook hired with equal cost split at month end.",
      self_clean: "Individual room maintenance + Shared weekend cleanups."
    };

    const quietMap = {
      "11pm_7am": "Quiet hours observed between 11:00 PM and 7:00 AM.",
      "1am_9am": "Night Owl friendly. Headphones in common areas after 1:00 AM.",
      flexible: "Flexible routine with mutual respect for work meetings & sleep."
    };

    const guestsMap = {
      prior_heads_up: "24-hour advance notice in roommate WhatsApp group.",
      weekend_only: "Overnight stays permitted primarily on weekends.",
      flexible: "Guests welcome with prior courtesy notification."
    };

    const splitMap = {
      equal_split: "Equal 50/50 split for rent, electricity, and high-speed wifi.",
      pro_rata: "Pro-rata split based on room dimensions and AC usage.",
      individual: "Shared wifi & utility bills; groceries kept individual."
    };

    const agreementDoc = `COHABIO ROOMMATE LIVING CHARTER & AGREEMENT
==============================================
Date Created: ${new Date().toLocaleDateString('en-IN', { month: 'short', day: 'numeric', year: 'numeric' })}
Status: MUTUALLY AGREED

1. CHORES & CLEANLINESS:
   - ${cleaningMap[cleaning]}

2. QUIET HOURS & ROUTINE:
   - ${quietMap[quiet]}

3. OVERNIGHT GUEST POLICY:
   - ${guestsMap[guests]}

4. EXPENSE & BILL SHARING:
   - ${splitMap[split]}

5. CONFLICT RESOLUTION:
   - Immediate 1-on-1 open discussion within 24 hours of any concern.
   - 30 days written notice before vacating lease.
==============================================`;

    if (agreementTextDisplay && agreementOutputBox) {
      agreementTextDisplay.textContent = agreementDoc;
      agreementOutputBox.classList.remove('hidden');
      triggerConfetti();
    }
  });
}

if (copyAgreementBtn) {
  copyAgreementBtn.addEventListener('click', () => {
    if (agreementTextDisplay) {
      navigator.clipboard.writeText(agreementTextDisplay.textContent);
      copyAgreementBtn.textContent = '✓ Copied!';
      setTimeout(() => { copyAgreementBtn.textContent = '📋 Copy Text'; }, 1500);
    }
  });
}

if (downloadAgreementBtn) {
  downloadAgreementBtn.addEventListener('click', () => {
    triggerConfetti();
    downloadAgreementBtn.textContent = '✓ Agreement Saved!';
    setTimeout(() => { downloadAgreementBtn.textContent = '🎉 Save Agreement'; }, 1500);
  });
}

// ==========================================
// 7. REAL FEATURE 5: GEMINI AI COPILOT SIMULATOR
// ==========================================
const copilotMessages = document.getElementById('copilotMessages');
const copilotInput = document.getElementById('copilotInput');
const copilotSendBtn = document.getElementById('copilotSendBtn');

window.askCopilot = function(text) {
  if (!copilotMessages) return;

  const userMsg = document.createElement('div');
  userMsg.className = 'phone-msg user';
  userMsg.textContent = text;
  copilotMessages.appendChild(userMsg);
  copilotMessages.scrollTop = copilotMessages.scrollHeight;

  // AI Response
  setTimeout(() => {
    const aiMsg = document.createElement('div');
    aiMsg.className = 'phone-msg ai';

    if (text.includes("HSR") || text.includes("Bangalore")) {
      aiMsg.innerHTML = "In <strong>HSR Layout</strong> with ₹15k, you can comfortably get a shared 2BHK flatmate room in Sector 2 or 7, or a premium 2-sharing PG with all 3 meals included. Metro feeder buses run every 10 mins to Outer Ring Road tech parks!";
    } else if (text.includes("Deposit")) {
      aiMsg.innerHTML = "In <strong>Mumbai</strong>, security deposits range from 3 to 5 months of rent. In contrast, <strong>Hyderabad & Pune</strong> typically require only 1 to 2 months rent upfront, saving you ₹40,000+ in initial relocation capital!";
    } else {
      aiMsg.innerHTML = "I analyzed current listings for your query! I found 3 matching verified roommates and 2 zero-brokerage properties near your preferred commute zone. Would you like to schedule a virtual tour?";
    }

    copilotMessages.appendChild(aiMsg);
    copilotMessages.scrollTop = copilotMessages.scrollHeight;
  }, 600);
};

if (copilotSendBtn && copilotInput) {
  copilotSendBtn.addEventListener('click', () => {
    const v = copilotInput.value.trim();
    if (v) {
      window.askCopilot(v);
      copilotInput.value = '';
    }
  });
  copilotInput.addEventListener('keypress', (e) => {
    if (e.key === 'Enter' && copilotInput.value.trim()) {
      window.askCopilot(copilotInput.value.trim());
      copilotInput.value = '';
    }
  });
}

// App Switcher Tabs & Bottom Nav Synchronizer
const appTabBtns = document.querySelectorAll('.app-tab-btn');
const phoneNavItems = document.querySelectorAll('.phone-nav-item');
const screenViews = document.querySelectorAll('.screen-view');
const screenTitleText = document.getElementById('screenTitleText');

const SCREEN_TITLES = {
  'tab-swipe': 'Cohabio Match',
  'tab-housing-app': 'Housing Market',
  'tab-events-app': 'City Mixers',
  'tab-agreement-app': 'Living Charter',
  'tab-copilot-app': 'Gemini AI Copilot'
};

function switchAppScreen(targetTabId) {
  appTabBtns.forEach(b => {
    if (b.getAttribute('data-app-tab') === targetTabId) b.classList.add('active');
    else b.classList.remove('active');
  });

  phoneNavItems.forEach(n => {
    if (n.getAttribute('data-app-tab') === targetTabId) n.classList.add('active');
    else n.classList.remove('active');
  });

  screenViews.forEach(v => {
    if (v.id === targetTabId) v.classList.add('active');
    else v.classList.remove('active');
  });

  if (screenTitleText) screenTitleText.textContent = SCREEN_TITLES[targetTabId] || 'Cohabio';
}

appTabBtns.forEach(btn => {
  btn.addEventListener('click', () => switchAppScreen(btn.getAttribute('data-app-tab')));
});

phoneNavItems.forEach(item => {
  item.addEventListener('click', () => switchAppScreen(item.getAttribute('data-app-tab')));
});

// ==========================================
// 8. FINANCIAL RELOCATION COST ESTIMATOR
// ==========================================
const CITY_COST_DATA = {
  bangalore: {
    baseRent: { pg_shared: 9000, pg_single: 16000, flat_2bhk_share: 14000, flat_1bhk_solo: 22000 },
    depositMultiplier: 2.5,
    foodBase: 4500,
    utilitiesBase: 1200,
    neighborhoods: [
      { name: "HSR Layout", range: "₹14k - ₹18k" },
      { name: "Koramangala", range: "₹16k - ₹22k" },
      { name: "BTM Layout", range: "₹9k - ₹13k" },
      { name: "Bellandur", range: "₹15k - ₹20k" }
    ]
  },
  mumbai: {
    baseRent: { pg_shared: 14000, pg_single: 24000, flat_2bhk_share: 22000, flat_1bhk_solo: 35000 },
    depositMultiplier: 3.5,
    foodBase: 5500,
    utilitiesBase: 1500,
    neighborhoods: [
      { name: "Andheri West", range: "₹18k - ₹26k" },
      { name: "Powai", range: "₹19k - ₹28k" },
      { name: "BKC / Bandra", range: "₹25k - ₹38k" }
    ]
  },
  hyderabad: {
    baseRent: { pg_shared: 7500, pg_single: 13000, flat_2bhk_share: 11000, flat_1bhk_solo: 17000 },
    depositMultiplier: 2.0,
    foodBase: 4000,
    utilitiesBase: 1000,
    neighborhoods: [
      { name: "Gachibowli", range: "₹10k - ₹15k" },
      { name: "HITEC City", range: "₹13k - ₹18k" },
      { name: "Madhapur", range: "₹11k - ₹16k" }
    ]
  },
  gurgaon: {
    baseRent: { pg_shared: 11000, pg_single: 19000, flat_2bhk_share: 17000, flat_1bhk_solo: 26000 },
    depositMultiplier: 2.0,
    foodBase: 4800,
    utilitiesBase: 1400,
    neighborhoods: [
      { name: "Cyber City", range: "₹18k - ₹25k" },
      { name: "DLF Phase 2", range: "₹16k - ₹24k" },
      { name: "Golf Course", range: "₹20k - ₹30k" }
    ]
  },
  pune: {
    baseRent: { pg_shared: 7000, pg_single: 12000, flat_2bhk_share: 10000, flat_1bhk_solo: 16000 },
    depositMultiplier: 2.0,
    foodBase: 3800,
    utilitiesBase: 900,
    neighborhoods: [
      { name: "Hinjewadi", range: "₹8k - ₹13k" },
      { name: "Viman Nagar", range: "₹12k - ₹17k" },
      { name: "Baner", range: "₹11k - ₹16k" }
    ]
  }
};

const COMMUTE_COSTS = { metro_bus: 2000, bike: 1800, cab: 6500, walk: 0 };
const LIFESTYLE_MULTIPLIERS = {
  frugal: { food: 0.8, leisure: 1200 },
  moderate: { food: 1.0, leisure: 3000 },
  premium: { food: 1.5, leisure: 7500 }
};

const estCity = document.getElementById('estCity');
const estHousing = document.getElementById('estHousing');
const estCommute = document.getElementById('estCommute');
const estLifestyle = document.getElementById('estLifestyle');

const estTotalMonthly = document.getElementById('estTotalMonthly');
const estUpfrontDeposit = document.getElementById('estUpfrontDeposit');
const valRent = document.getElementById('valRent');
const valFood = document.getElementById('valFood');
const valCommute = document.getElementById('valCommute');
const valUtilities = document.getElementById('valUtilities');
const valLeisure = document.getElementById('valLeisure');
const neighborhoodChips = document.getElementById('neighborhoodChips');

function calculateRelocationCost() {
  if (!estCity || !estTotalMonthly) return;

  const cityData = CITY_COST_DATA[estCity.value] || CITY_COST_DATA.bangalore;
  const rent = cityData.baseRent[estHousing.value] || 12000;
  const deposit = Math.round(rent * cityData.depositMultiplier);
  const lifestyle = LIFESTYLE_MULTIPLIERS[estLifestyle.value];
  const food = Math.round(cityData.foodBase * lifestyle.food);
  const commute = COMMUTE_COSTS[estCommute.value] || 1800;
  const utilities = cityData.utilitiesBase;
  const leisure = lifestyle.leisure;

  const total = rent + food + commute + utilities + leisure;

  estTotalMonthly.innerHTML = `₹${total.toLocaleString('en-IN')} <span class="per-mo">/ month</span>`;
  if (estUpfrontDeposit) estUpfrontDeposit.textContent = `₹${deposit.toLocaleString('en-IN')}`;
  if (valRent) valRent.textContent = `₹${rent.toLocaleString('en-IN')}`;
  if (valFood) valFood.textContent = `₹${food.toLocaleString('en-IN')}`;
  if (valCommute) valCommute.textContent = `₹${commute.toLocaleString('en-IN')}`;
  if (valUtilities) valUtilities.textContent = `₹${utilities.toLocaleString('en-IN')}`;
  if (valLeisure) valLeisure.textContent = `₹${leisure.toLocaleString('en-IN')}`;

  if (neighborhoodChips) {
    neighborhoodChips.innerHTML = cityData.neighborhoods.map(n => `
      <span class="area-chip"><strong>${n.name}</strong> (${n.range})</span>
    `).join('');
  }
}

if (estCity) estCity.addEventListener('change', calculateRelocationCost);
if (estHousing) estHousing.addEventListener('change', calculateRelocationCost);
if (estCommute) estCommute.addEventListener('change', calculateRelocationCost);
if (estLifestyle) estLifestyle.addEventListener('change', calculateRelocationCost);

// ==========================================
// 9. RELOCATION CHECKLIST
// ==========================================
const DEFAULT_CHECKLIST = [
  { id: 'c1', phase: 't30', label: 'Match with verified roommates on Cohabio discovery', completed: true },
  { id: 'c2', phase: 't30', label: 'Set monthly budget & security deposit limit', completed: true },
  { id: 'c3', phase: 't30', label: 'Request notice period confirmation from current landlord', completed: false },
  { id: 'c4', phase: 't15', label: 'Video call matched roomies to finalize housing shortlist', completed: false },
  { id: 'c5', phase: 't15', label: 'Draft Roommate Living Charter on Cohabio builder', completed: false },
  { id: 'c6', phase: 't15', label: 'Book movers / luggage shipping service', completed: false },
  { id: 'c7', phase: 't7', label: 'Pack essential IDs, offer letter, and medicine kit', completed: false },
  { id: 'c8', phase: 't7', label: 'Confirm lease agreement & token payment with owner', completed: false },
  { id: 'c9', phase: 't0', label: 'Inspect room electricity, geyser, wifi, and door locks', completed: false },
  { id: 'c10', phase: 't0', label: 'RSVP to local Cohabio Chai & Tech Mixer', completed: false }
];

let checklistTasks = JSON.parse(localStorage.getItem('cohabio_checklist')) || DEFAULT_CHECKLIST;
let activePhaseFilter = 'all';

const checklistList = document.getElementById('checklistList');
const checkedTasksCount = document.getElementById('checkedTasksCount');
const totalTasksCount = document.getElementById('totalTasksCount');
const readinessPercent = document.getElementById('readinessPercent');
const readinessProgressFill = document.getElementById('readinessProgressFill');
const customTaskInput = document.getElementById('customTaskInput');
const customTaskPhase = document.getElementById('customTaskPhase');
const addCustomTaskBtn = document.getElementById('addCustomTaskBtn');
const resetChecklistBtn = document.getElementById('resetChecklistBtn');
const checklistTabs = document.querySelectorAll('.checklist-tab');

function renderChecklist() {
  if (!checklistList) return;
  const filtered = activePhaseFilter === 'all' ? checklistTasks : checklistTasks.filter(t => t.phase === activePhaseFilter);

  checklistList.innerHTML = filtered.map(t => {
    const phaseLabels = { t30: '30 Days', t15: '15 Days', t7: '7 Days', t0: 'Moving Day' };
    return `
      <div class="checklist-item ${t.completed ? 'completed' : ''}">
        <div class="custom-checkbox" onclick="toggleTask('${t.id}')">${t.completed ? '✓' : ''}</div>
        <span class="task-label" onclick="toggleTask('${t.id}')">${t.label}</span>
        <span class="task-phase-tag">${phaseLabels[t.phase] || t.phase}</span>
        <button class="delete-task-btn" onclick="deleteTask('${t.id}')">×</button>
      </div>
    `;
  }).join('');

  const total = checklistTasks.length;
  const completed = checklistTasks.filter(t => t.completed).length;
  const pct = total > 0 ? Math.round((completed / total) * 100) : 0;

  if (checkedTasksCount) checkedTasksCount.textContent = completed;
  if (totalTasksCount) totalTasksCount.textContent = total;
  if (readinessPercent) readinessPercent.textContent = `${pct}%`;
  if (readinessProgressFill) readinessProgressFill.style.width = `${pct}%`;
}

window.toggleTask = function(id) {
  checklistTasks = checklistTasks.map(t => t.id === id ? { ...t, completed: !t.completed } : t);
  localStorage.setItem('cohabio_checklist', JSON.stringify(checklistTasks));
  renderChecklist();
};

window.deleteTask = function(id) {
  checklistTasks = checklistTasks.filter(t => t.id !== id);
  localStorage.setItem('cohabio_checklist', JSON.stringify(checklistTasks));
  renderChecklist();
};

if (addCustomTaskBtn && customTaskInput) {
  addCustomTaskBtn.addEventListener('click', () => {
    const label = customTaskInput.value.trim();
    if (!label) return;
    checklistTasks.push({
      id: `task_${Date.now()}`,
      phase: customTaskPhase ? customTaskPhase.value : 't7',
      label: label,
      completed: false
    });
    customTaskInput.value = '';
    localStorage.setItem('cohabio_checklist', JSON.stringify(checklistTasks));
    renderChecklist();
  });
}

if (resetChecklistBtn) {
  resetChecklistBtn.addEventListener('click', () => {
    checklistTasks = [...DEFAULT_CHECKLIST];
    localStorage.setItem('cohabio_checklist', JSON.stringify(checklistTasks));
    renderChecklist();
  });
}

checklistTabs.forEach(tab => {
  tab.addEventListener('click', () => {
    checklistTabs.forEach(t => t.classList.remove('active'));
    tab.classList.add('active');
    activePhaseFilter = tab.getAttribute('data-phase');
    renderChecklist();
  });
});

// ==========================================
// 10. COMMUNITIES & HUBS
// ==========================================
const COMMUNITIES_LIST = [
  { id: "c1", title: "Bangalore Techies & Interns", meta: "1,420 Members • Active Today", desc: "Students and SDE interns moving to Bangalore. Share flat openings, commutes, and referrals.", cat: "tech", icon: "🏙️", baseCount: 1420 },
  { id: "c2", title: "IIT & IIM Freshers Network", meta: "840 Members • Very Active", desc: "Connect with incoming batch mates before the semester starts. Find accommodations & mentors.", cat: "college", icon: "🎓", baseCount: 840 },
  { id: "c3", title: "Mumbai Finance Professionals", meta: "620 Members • 18 Online", desc: "BKC, Lower Parel, Andheri — find verified flatmates working in banking, consulting, & fintech.", cat: "finance", icon: "🌆", baseCount: 620 },
  { id: "c4", title: "Designers & Creative Nomads", meta: "490 Members • Active", desc: "UI/UX designers, copywriters, and video editors looking for aesthetic studio apartments.", cat: "creatives", icon: "🎨", baseCount: 490 },
  { id: "c5", title: "Hyderabad Cyberabad Startups", meta: "710 Members • Active", desc: "HITEC City, Gachibowli, Madhapur relocators. Discover safe gated societies and easy commutes.", cat: "tech", icon: "🚀", baseCount: 710 },
  { id: "c6", title: "BITS & NIT Relocation Cell", meta: "560 Members • Active", desc: "Dedicated network for BITS Pilani, Goa, Hyderabad & NIT alumni relocating across metros.", cat: "college", icon: "📚", baseCount: 560 }
];

const communityGrid = document.getElementById('communityGrid');
const commCategoryBtns = document.querySelectorAll('.comm-tab-btn');
const joinedHubs = JSON.parse(localStorage.getItem('cohabio_joined_hubs') || '{}');

function renderCommunities(filter = 'all') {
  if (!communityGrid) return;
  const filtered = filter === 'all' ? COMMUNITIES_LIST : COMMUNITIES_LIST.filter(c => c.cat === filter);

  communityGrid.innerHTML = filtered.map(c => {
    const isJoined = joinedHubs[c.id];
    return `
      <div class="community-card spotlight-card" data-spotlight="true" data-tilt="true">
        <div class="community-card-icon">${c.icon}</div>
        <h3>${c.title}</h3>
        <p>${c.desc}</p>
        <div class="community-card-footer">
          <span class="community-meta">${(c.baseCount + (isJoined ? 1 : 0)).toLocaleString('en-IN')} Members • ${isJoined ? 'Joined' : 'Active'}</span>
          <button class="btn ${isJoined ? 'btn-primary' : 'btn-outline-primary'} btn-sm" onclick="toggleJoinCommunity('${c.id}')">
            ${isJoined ? '✓ Joined' : '+ Join Hub'}
          </button>
        </div>
      </div>
    `;
  }).join('');
  initSpotlights();
  initTilts();
}

window.toggleJoinCommunity = function(id) {
  if (joinedHubs[id]) {
    delete joinedHubs[id];
  } else {
    joinedHubs[id] = true;
    triggerConfetti();
  }
  localStorage.setItem('cohabio_joined_hubs', JSON.stringify(joinedHubs));
  renderCommunities();
};

commCategoryBtns.forEach(btn => {
  btn.addEventListener('click', () => {
    commCategoryBtns.forEach(b => b.classList.remove('active'));
    btn.classList.add('active');
    renderCommunities(btn.getAttribute('data-comm-filter'));
  });
});

// ==========================================
// 11. DIRECT CONNECT CHAT DIALOG
// ==========================================
const directConnectModal = document.getElementById('directConnectModal');
const closeDmModalBtn = document.getElementById('closeDmModalBtn');
const dmAvatar = document.getElementById('dmAvatar');
const dmCandidateName = document.getElementById('dmCandidateName');
const dmInitialGreeting = document.getElementById('dmInitialGreeting');
const dmChatMessages = document.getElementById('dmChatMessages');
const dmInput = document.getElementById('dmInput');
const dmSendBtn = document.getElementById('dmSendBtn');

let activeDmCandidate = null;

function openDirectConnectModal(cand) {
  activeDmCandidate = cand;
  if (dmAvatar) dmAvatar.src = cand.avatar;
  if (dmCandidateName) dmCandidateName.textContent = cand.name;
  if (dmInitialGreeting) {
    dmInitialGreeting.textContent = `Hey there! 👋 I saw we matched on Cohabio! Are you moving to ${cand.targetArea || cand.city} soon?`;
  }
  if (directConnectModal) directConnectModal.classList.remove('hidden');
  if (dmInput) dmInput.focus();
}

if (closeDmModalBtn) closeDmModalBtn.addEventListener('click', () => directConnectModal.classList.add('hidden'));

function sendDm() {
  const text = dmInput.value.trim();
  if (!text || !dmChatMessages) return;

  const u = document.createElement('div');
  u.className = 'dm-bubble user-bubble';
  u.textContent = text;
  dmChatMessages.appendChild(u);
  dmInput.value = '';
  dmChatMessages.scrollTop = dmChatMessages.scrollHeight;

  setTimeout(() => {
    const r = document.createElement('div');
    r.className = 'dm-bubble candidate-bubble';
    r.textContent = `Awesome! I'd love to team up for a flat. Let's exchange numbers once you claim your VIP Early Access badge! 🚀`;
    dmChatMessages.appendChild(r);
    dmChatMessages.scrollTop = dmChatMessages.scrollHeight;
  }, 600);
}

if (dmSendBtn) dmSendBtn.addEventListener('click', sendDm);
if (dmInput) dmInput.addEventListener('keypress', (e) => { if (e.key === 'Enter') sendDm(); });

// ==========================================
// 12. WAITLIST & 3D HOLOGRAPHIC VIP PASS
// ==========================================
const waitlistForm = document.getElementById('waitlistForm');
const waitlistMsg = document.getElementById('waitlistMsg');
const vipPassModal = document.getElementById('vipPassModal');
const closeVipModalBtn = document.getElementById('closeVipModalBtn');
const vipHolderName = document.getElementById('vipHolderName');
const vipDestination = document.getElementById('vipDestination');
const vipTicketNumber = document.getElementById('vipTicketNumber');
const copyVipLinkBtn = document.getElementById('copyVipLinkBtn');
const downloadPassBtn = document.getElementById('downloadPassBtn');

if (waitlistForm) {
  waitlistForm.addEventListener('submit', async (e) => {
    e.preventDefault();
    const fullName = document.getElementById('fullName').value.trim();
    const email = document.getElementById('email').value.trim();
    const targetCity = document.getElementById('targetCity').value.trim();

    if (waitlistMsg) {
      waitlistMsg.style.color = '#38BDF8';
      waitlistMsg.textContent = 'Generating VIP Ticket...';
    }

    try {
      await fetch(`${API_BASE_URL}/api/v1/waitlist/`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email, full_name: fullName, target_city: targetCity })
      });
    } catch (err) {
      console.log("Offline mode waitlist registration");
    }

    if (waitlistMsg) {
      waitlistMsg.style.color = '#10B981';
      waitlistMsg.textContent = '🎉 VIP Ticket Ready! See pass below.';
    }

    const ticketId = `#COHAB-${Math.floor(1000 + Math.random() * 9000)}`;
    if (vipHolderName) vipHolderName.textContent = fullName;
    if (vipDestination) vipDestination.textContent = `${targetCity || 'Metro Hub'}, IN`;
    if (vipTicketNumber) vipTicketNumber.textContent = ticketId;

    if (vipPassModal) {
      vipPassModal.classList.remove('hidden');
      triggerConfetti();
    }
  });
}

if (closeVipModalBtn) closeVipModalBtn.addEventListener('click', () => vipPassModal.classList.add('hidden'));

if (copyVipLinkBtn) {
  copyVipLinkBtn.addEventListener('click', () => {
    navigator.clipboard.writeText(window.location.href);
    copyVipLinkBtn.textContent = '✓ Link Copied!';
    setTimeout(() => { copyVipLinkBtn.textContent = '📋 Copy Share Link'; }, 2000);
  });
}

if (downloadPassBtn) {
  downloadPassBtn.addEventListener('click', () => {
    triggerConfetti();
    downloadPassBtn.textContent = '🎉 Celebrated!';
    setTimeout(() => { downloadPassBtn.textContent = '🎉 Celebrate'; }, 1500);
  });
}

// ==========================================
// 13. FLOATING AI CHATBOT
// ==========================================
const chatbotTrigger = document.getElementById('chatbot-trigger');
const chatbotContainer = document.getElementById('chatbot-container');
const chatbotCloseBtn = document.getElementById('chatbot-close-btn');
const chatbotInput = document.getElementById('chatbot-input');
const chatbotSendBtn = document.getElementById('chatbot-send-btn');
const chatbotMessages = document.getElementById('chatbot-messages');
const greetingPopup = document.getElementById('chatbot-greeting-popup');
const closeGreetingBtn = document.getElementById('close-greeting-btn');
const greetingContentTrigger = document.getElementById('greeting-content-trigger');

let chatHistory = [];

function toggleChatbot() {
  if (greetingPopup) greetingPopup.classList.add('hidden');
  if (chatbotContainer) {
    chatbotContainer.classList.toggle('hidden');
    if (!chatbotContainer.classList.contains('hidden') && chatbotInput) chatbotInput.focus();
  }
}

if (chatbotTrigger) chatbotTrigger.addEventListener('click', toggleChatbot);
if (chatbotCloseBtn) chatbotCloseBtn.addEventListener('click', toggleChatbot);
if (closeGreetingBtn) {
  closeGreetingBtn.addEventListener('click', (e) => {
    e.stopPropagation();
    if (greetingPopup) greetingPopup.classList.add('hidden');
  });
}
if (greetingContentTrigger) greetingContentTrigger.addEventListener('click', toggleChatbot);

setTimeout(() => {
  if (greetingPopup && chatbotContainer && chatbotContainer.classList.contains('hidden')) {
    greetingPopup.classList.remove('hidden');
  }
}, 1500);

function appendChatMessage(role, text) {
  if (!chatbotMessages) return;
  const msg = document.createElement('div');
  msg.className = `message ${role === 'user' ? 'user-message' : 'assistant-message'}`;
  msg.innerHTML = text;
  chatbotMessages.appendChild(msg);
  chatbotMessages.scrollTop = chatbotMessages.scrollHeight;
}

async function sendChatbotMessage() {
  const text = chatbotInput.value.trim();
  if (!text) return;
  chatbotInput.value = '';
  appendChatMessage('user', text);
  chatHistory.push({ role: 'user', content: text });

  try {
    const res = await fetch(`${API_BASE_URL}/api/v1/public/bot/chat`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ message: text, history: chatHistory.slice(-4) })
    });

    if (res.ok) {
      const data = await res.json();
      appendChatMessage('assistant', data.reply);
      chatHistory.push({ role: 'assistant', content: data.reply });
      return;
    }
  } catch (err) {
    console.log("Offline mode chatbot assistant fallback");
  }

  setTimeout(() => {
    let reply = "I'm your Cohabio AI assistant! All roommate profiles undergo a 2-level verification to ensure genuine matches. You can test our swipe match simulator, cost estimator, or housing marketplace above!";
    const lower = text.toLowerCase();
    if (lower.includes("bangalore")) {
      reply = "In <strong>Bangalore</strong>, prime hubs for tech freshers include <strong>HSR Layout</strong>, <strong>Bellandur</strong>, and <strong>Indiranagar</strong>. Average PG double sharing starts at ₹9k-₹12k, while 2BHK flat shares range from ₹14k-₹18k.";
    } else if (lower.includes("mumbai")) {
      reply = "In <strong>Mumbai</strong>, top areas include <strong>Andheri West</strong>, <strong>Powai</strong>, and <strong>BKC</strong>. Pairing with a verified flatmate on Cohabio helps you split high rental deposits easily!";
    } else if (lower.includes("cost") || lower.includes("budget")) {
      reply = "You can use our interactive <a href='#estimator' style='color: #10B981; text-decoration: underline;'>Relocation Cost Estimator</a> section to calculate your exact monthly rent, deposit, commute, and grocery costs!";
    }
    appendChatMessage('assistant', reply);
    chatHistory.push({ role: 'assistant', content: reply });
  }, 400);
}

if (chatbotSendBtn) chatbotSendBtn.addEventListener('click', sendChatbotMessage);
if (chatbotInput) chatbotInput.addEventListener('keypress', (e) => { if (e.key === 'Enter') sendChatbotMessage(); });

// ==========================================
// 14. REAL INTERACTIVE COMMAND PALETTE (CTRL+K / CMD+K)
// ==========================================
const commandPaletteModal = document.getElementById('commandPaletteModal');
const openCommandPaletteBtn = document.getElementById('openCommandPaletteBtn');
const closeCmdPaletteBtn = document.getElementById('closeCmdPaletteBtn');
const cmdInput = document.getElementById('cmdInput');
const cmdResultsList = document.getElementById('cmdResultsList');

const COMMAND_FEATURES = [
  {
    id: 'cmd-swipe',
    title: 'Roommate Match & Swipe Discovery',
    desc: 'Bumble/Tinder style verified roommate matching',
    icon: '🎴',
    badge: 'Mobile Feature',
    action: () => {
      switchAppScreen('tab-swipe');
      document.getElementById('mobile-app')?.scrollIntoView({ behavior: 'smooth' });
    }
  },
  {
    id: 'cmd-housing',
    title: 'Verified Housing Marketplace',
    desc: 'Zero-brokerage student & fresher apartments and PGs',
    icon: '🏡',
    badge: 'Marketplace',
    action: () => {
      document.getElementById('housing')?.scrollIntoView({ behavior: 'smooth' });
    }
  },
  {
    id: 'cmd-estimator',
    title: 'City Relocation Cost Estimator',
    desc: 'Calculate rent, deposits, commute, & lifestyle expenses',
    icon: '💰',
    badge: 'Financial Tool',
    action: () => {
      document.getElementById('estimator')?.scrollIntoView({ behavior: 'smooth' });
    }
  },
  {
    id: 'cmd-checklist',
    title: 'Interactive Moving Checklist',
    desc: 'Multi-phase relocation timeline with saved progress',
    icon: '📋',
    badge: 'Planner',
    action: () => {
      document.getElementById('checklist')?.scrollIntoView({ behavior: 'smooth' });
    }
  },
  {
    id: 'cmd-agreement',
    title: 'Roommate Living Charter & Agreement Builder',
    desc: 'Set custom household chores, quiet hours, & guest rules',
    icon: '📝',
    badge: 'Legal Draft',
    action: () => {
      switchAppScreen('tab-agreement-app');
      document.getElementById('mobile-app')?.scrollIntoView({ behavior: 'smooth' });
    }
  },
  {
    id: 'cmd-events',
    title: 'City Welcome Mixers & Meetups',
    desc: 'Free RSVP social meetups for incoming relocators',
    icon: '🎟️',
    badge: 'Community',
    action: () => {
      document.getElementById('events')?.scrollIntoView({ behavior: 'smooth' });
    }
  },
  {
    id: 'cmd-communities',
    title: 'College & City Alumni Hubs',
    desc: 'Bangalore, Mumbai, Techies & College networks',
    icon: '👥',
    badge: 'Social Groups',
    action: () => {
      document.getElementById('communities')?.scrollIntoView({ behavior: 'smooth' });
    }
  },
  {
    id: 'cmd-copilot',
    title: 'Gemini 1.5 AI Relocation Assistant',
    desc: 'Ask questions about rent budgets and area safety',
    icon: '🤖',
    badge: 'AI Copilot',
    action: () => {
      toggleChatbot();
    }
  },
  {
    id: 'cmd-waitlist',
    title: 'Join Early Access VIP Beta',
    desc: 'Claim your 3D Holographic Founding Member VIP pass',
    icon: '🚀',
    badge: 'Priority Access',
    action: () => {
      document.getElementById('waitlist')?.scrollIntoView({ behavior: 'smooth' });
    }
  }
];

let selectedCmdIndex = 0;

function openCommandPalette() {
  if (!commandPaletteModal) return;
  commandPaletteModal.classList.remove('hidden');
  if (cmdInput) {
    cmdInput.value = '';
    cmdInput.focus();
  }
  selectedCmdIndex = 0;
  renderCommandResults();
}

function closeCommandPalette() {
  if (commandPaletteModal) commandPaletteModal.classList.add('hidden');
}

function renderCommandResults(query = '') {
  if (!cmdResultsList) return;
  const q = query.toLowerCase().trim();
  const filtered = COMMAND_FEATURES.filter(f => 
    f.title.toLowerCase().includes(q) || 
    f.desc.toLowerCase().includes(q) || 
    f.badge.toLowerCase().includes(q)
  );

  if (filtered.length === 0) {
    cmdResultsList.innerHTML = `
      <div style="padding: 1.5rem; text-align: center; color: var(--neutral-400); font-size: 0.9rem;">
        No tools or features matching "<strong>${query}</strong>". Try searching for <em>Housing</em>, <em>Budget</em>, <em>Match</em>, or <em>Agreement</em>.
      </div>
    `;
    return;
  }

  cmdResultsList.innerHTML = filtered.map((item, idx) => `
    <div class="cmd-item ${idx === selectedCmdIndex ? 'selected' : ''}" data-cmd-id="${item.id}" onclick="executeCommand('${item.id}')">
      <div class="cmd-item-left">
        <span class="cmd-item-icon">${item.icon}</span>
        <div>
          <span class="cmd-item-title">${item.title}</span>
          <span class="cmd-item-desc">${item.desc}</span>
        </div>
      </div>
      <span class="cmd-item-badge">${item.badge}</span>
    </div>
  `).join('');
}

window.executeCommand = function(id) {
  const feat = COMMAND_FEATURES.find(f => f.id === id);
  if (feat) {
    closeCommandPalette();
    feat.action();
  }
};

if (openCommandPaletteBtn) openCommandPaletteBtn.addEventListener('click', openCommandPalette);
if (closeCmdPaletteBtn) closeCmdPaletteBtn.addEventListener('click', closeCommandPalette);

if (commandPaletteModal) {
  commandPaletteModal.addEventListener('click', (e) => {
    if (e.target === commandPaletteModal) closeCommandPalette();
  });
}

if (cmdInput) {
  cmdInput.addEventListener('input', (e) => {
    selectedCmdIndex = 0;
    renderCommandResults(e.target.value);
  });

  cmdInput.addEventListener('keydown', (e) => {
    const items = cmdResultsList ? cmdResultsList.querySelectorAll('.cmd-item') : [];
    if (e.key === 'ArrowDown') {
      e.preventDefault();
      selectedCmdIndex = (selectedCmdIndex + 1) % items.length;
      renderCommandResults(cmdInput.value);
    } else if (e.key === 'ArrowUp') {
      e.preventDefault();
      selectedCmdIndex = (selectedCmdIndex - 1 + items.length) % items.length;
      renderCommandResults(cmdInput.value);
    } else if (e.key === 'Enter') {
      e.preventDefault();
      const currentItem = items[selectedCmdIndex];
      if (currentItem) {
        const id = currentItem.getAttribute('data-cmd-id');
        window.executeCommand(id);
      }
    }
  });
}

// Global Keyboard Shortcut: Ctrl+K / Cmd+K / Escape
window.addEventListener('keydown', (e) => {
  if ((e.ctrlKey || e.metaKey) && e.key === 'k') {
    e.preventDefault();
    if (commandPaletteModal && !commandPaletteModal.classList.contains('hidden')) {
      closeCommandPalette();
    } else {
      openCommandPalette();
    }
  } else if (e.key === 'Escape') {
    if (commandPaletteModal && !commandPaletteModal.classList.contains('hidden')) {
      closeCommandPalette();
    }
  }
});

// ==========================================
// INITIAL INVOCATION
// ==========================================
document.addEventListener('DOMContentLoaded', () => {
  updateSwipeCard();
  renderHousingListings();
  renderEventsListings();
  calculateRelocationCost();
  renderChecklist();
  renderCommunities();
});

updateSwipeCard();
renderHousingListings();
renderEventsListings();
calculateRelocationCost();
renderChecklist();
renderCommunities();

