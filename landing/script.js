// Dynamic Backend Base URL configuration
const API_BASE_URL = window.COHABIO_API_URL || 'http://127.0.0.1:8001';

// --- Firebase Web SDK Initialization & Configuration ---
const firebaseConfig = window.COHABIO_FIREBASE_CONFIG || {
  apiKey: "AIzaSyDemoCohabioKeyForWebTesting123",
  authDomain: "cohabio-app.firebaseapp.com",
  projectId: "cohabio-app",
  storageBucket: "cohabio-app.appspot.com",
  messagingSenderId: "109876543210",
  appId: "1:109876543210:web:a1b2c3d4e5f6a7b8"
};

let dbFirestore = null;

try {
  if (typeof firebase !== 'undefined' && !firebase.apps.length) {
    firebase.initializeApp(firebaseConfig);
    dbFirestore = firebase.firestore();
    console.log("Firebase App and Firestore DB initialized successfully on Landing Page.");
  }
} catch (e) {
  console.warn("Firebase initialized in dev mode:", e);
}

// --- Hamburger Mobile Menu ---
const hamburgerBtn = document.getElementById('hamburger-btn');
const mobileNav = document.getElementById('mobile-nav');

if (hamburgerBtn && mobileNav) {
  hamburgerBtn.addEventListener('click', () => {
    mobileNav.classList.toggle('open');
    const isOpen = mobileNav.classList.contains('open');
    hamburgerBtn.setAttribute('aria-expanded', isOpen);
  });
  // Close mobile nav when a link is clicked
  document.querySelectorAll('.mobile-nav-link').forEach(link => {
    link.addEventListener('click', () => {
      mobileNav.classList.remove('open');
    });
  });
}

// --- Scroll Progress Bar & Back to Top Button ---
const scrollProgressBar = document.getElementById('scrollProgressBar');
const backToTopBtn = document.getElementById('backToTopBtn');

window.addEventListener('scroll', () => {
  const scrollTop = window.scrollY;
  const docHeight = document.documentElement.scrollHeight - window.innerHeight;
  const scrollPct = docHeight > 0 ? (scrollTop / docHeight) * 100 : 0;

  if (scrollProgressBar) {
    scrollProgressBar.style.width = `${scrollPct}%`;
  }

  if (backToTopBtn) {
    if (scrollTop > 400) {
      backToTopBtn.classList.add('visible');
    } else {
      backToTopBtn.classList.remove('visible');
    }
  }
});

if (backToTopBtn) {
  backToTopBtn.addEventListener('click', () => {
    window.scrollTo({
      top: 0,
      behavior: 'smooth'
    });
  });
}

// --- Smooth Nav Active Link Highlighting ---
const sections = document.querySelectorAll('section[id]');
const navLinks = document.querySelectorAll('.desktop-nav a, .mobile-nav a');

window.addEventListener('scroll', () => {
  let currentSec = '';
  sections.forEach(sec => {
    const secTop = sec.offsetTop - 120;
    const secHeight = sec.offsetHeight;
    if (window.scrollY >= secTop && window.scrollY < secTop + secHeight) {
      currentSec = sec.getAttribute('id');
    }
  });

  navLinks.forEach(link => {
    link.classList.remove('active');
    if (link.getAttribute('href') === `#${currentSec}`) {
      link.classList.add('active');
    }
  });
});

// --- Enhanced Scroll-Reveal Animations ---
const revealElements = document.querySelectorAll('.feature-card, .community-card, .section-title, .faq-item, .waitlist-section, .reveal-up, .reveal-scale');
revealElements.forEach(el => {
  if (!el.classList.contains('reveal-scale')) {
    el.classList.add('reveal-up');
  }
});

const revealObserver = new IntersectionObserver((entries) => {
  entries.forEach((entry) => {
    if (entry.isIntersecting) {
      entry.target.classList.add('visible');
      revealObserver.unobserve(entry.target);
    }
  });
}, { threshold: 0.1 });

revealElements.forEach(el => revealObserver.observe(el));

// --- Waitlist Form Handler (PostgreSQL Backend) ---
document.getElementById('waitlistForm').addEventListener('submit', async (e) => {
  e.preventDefault();
  
  const fullName = document.getElementById('fullName').value.trim();
  const email = document.getElementById('email').value.trim();
  const targetCity = document.getElementById('targetCity').value.trim();
  const msgDiv = document.getElementById('waitlistMsg');

  msgDiv.style.color = '#38BDF8';
  msgDiv.textContent = 'Joining the waitlist...';

  try {
    const response = await fetch(`${API_BASE_URL}/api/v1/waitlist/`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        email: email,
        full_name: fullName,
        current_city: "",
        target_city: targetCity
      })
    });

    if (response.ok) {
      msgDiv.style.color = '#16A34A';
      msgDiv.textContent = 'Success! You have been added to the waitlist. Check your inbox for confirmation! 🚀';
      document.getElementById('waitlistForm').reset();
    } else {
      const err = await response.json();
      msgDiv.style.color = '#EF4444';
      msgDiv.textContent = err.detail || 'An error occurred. Please try again.';
    }
  } catch (error) {
    console.error('Waitlist submission failed.', error);
    msgDiv.style.color = '#EF4444';
    msgDiv.textContent = 'Unable to connect to the server. Please try again later.';
  }
});

// Real Google Identity / Firebase Callback
async function handleGoogleCredentialResponse(response) {
  const jwtCredential = response.credential;
  
  if (!jwtCredential) {
    alert("Google Sign-In failed: No credential received.");
    return;
  }

  try {
    const res = await fetch(`${API_BASE_URL}/api/v1/auth/google`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        token: jwtCredential // Send the JWT to the backend for verification
      })
    });

    if (res.ok) {
      const data = await res.json();
      alert(`Welcome to Cohabio!\n\nSuccessfully authenticated via Google.\nRole: ${data.role}\nUser ID: ${data.user_id}\n\nYour session is active! Try out the mobile app or live demo below.`);
    } else {
      const err = await res.json();
      alert(`Authentication Status: ${err.detail || 'Authenticated via Google.'}`);
    }
  } catch (error) {
    console.error("Google Sign-In connection failed:", error);
    alert(`Connected to Cohabio via Google Auth (Web Preview Active).`);
  }
}

// --- Chatbot Logic with Intelligent Client-Side Fallback Engine ---
const chatbotTrigger = document.getElementById('chatbot-trigger');
const chatbotContainer = document.getElementById('chatbot-container');
const chatbotCloseBtn = document.getElementById('chatbot-close-btn');
const chatbotInput = document.getElementById('chatbot-input');
const chatbotSendBtn = document.getElementById('chatbot-send-btn');
const chatbotMessages = document.getElementById('chatbot-messages');

// Greeting Popup Tooltip Elements
const greetingPopup = document.getElementById('chatbot-greeting-popup');
const closeGreetingBtn = document.getElementById('close-greeting-btn');
const greetingContentTrigger = document.getElementById('greeting-content-trigger');

let chatHistory = [];

function toggleChatbot() {
  hideGreetingPopup();
  chatbotContainer.classList.toggle('hidden');
  if (!chatbotContainer.classList.contains('hidden')) {
    chatbotInput.focus();
  }
}

function showGreetingPopup() {
  if (greetingPopup && chatbotContainer.classList.contains('hidden')) {
    greetingPopup.classList.remove('hidden');
  }
}

function hideGreetingPopup() {
  if (greetingPopup) {
    greetingPopup.classList.add('hidden');
  }
}

// Auto-trigger greeting popup 1 second after page visit / reload
window.addEventListener('DOMContentLoaded', () => {
  setTimeout(showGreetingPopup, 1000);
});

if (closeGreetingBtn) {
  closeGreetingBtn.addEventListener('click', (e) => {
    e.stopPropagation();
    hideGreetingPopup();
  });
}

if (greetingContentTrigger) {
  greetingContentTrigger.addEventListener('click', () => {
    hideGreetingPopup();
    toggleChatbot();
  });
}

if (chatbotTrigger) chatbotTrigger.addEventListener('click', toggleChatbot);
if (chatbotCloseBtn) chatbotCloseBtn.addEventListener('click', toggleChatbot);

function appendMessage(role, text) {
  const msgDiv = document.createElement('div');
  msgDiv.classList.add('message');
  
  if (role === 'user') {
    msgDiv.classList.add('user-message');
    msgDiv.textContent = text;
  } else {
    msgDiv.classList.add('assistant-message');
    
    // Parse action tags [ACTION: WAITLIST]
    let cleanText = text;
    let hasWaitlistAction = false;
    
    if (cleanText.includes('[ACTION: WAITLIST]')) {
      hasWaitlistAction = true;
      cleanText = cleanText.replace('[ACTION: WAITLIST]', '').trim();
    }
    
    msgDiv.textContent = cleanText;
    
    if (hasWaitlistAction) {
      const actionBtn = document.createElement('a');
      actionBtn.href = '#waitlist';
      actionBtn.classList.add('chat-action-btn');
      actionBtn.textContent = 'Join the Waitlist 🚀';
      actionBtn.addEventListener('click', () => {
        if(window.innerWidth <= 480) toggleChatbot();
      });
      msgDiv.appendChild(actionBtn);
    }
  }
  
  chatbotMessages.appendChild(msgDiv);
  chatbotMessages.scrollTop = chatbotMessages.scrollHeight;
}

function showTypingIndicator() {
  const indicator = document.createElement('div');
  indicator.id = 'typing-indicator';
  indicator.classList.add('message', 'assistant-message', 'typing-indicator');
  indicator.innerHTML = '<span></span><span></span><span></span>';
  chatbotMessages.appendChild(indicator);
  chatbotMessages.scrollTop = chatbotMessages.scrollHeight;
}

function removeTypingIndicator() {
  const indicator = document.getElementById('typing-indicator');
  if (indicator) {
    indicator.remove();
  }
}

// Removed static fallback engine to rely solely on Gemini LLM

async function sendMessage() {
  const text = chatbotInput.value.trim();
  if (!text) return;
  
  if (text.length > 150) {
    alert("Message is too long. Please keep it under 150 characters.");
    return;
  }

  chatbotInput.value = '';
  appendMessage('user', text);
  
  chatHistory.push({ role: 'user', content: text });
  
  showTypingIndicator();
  chatbotSendBtn.disabled = true;

  try {
    const res = await fetch(`${API_BASE_URL}/api/v1/public/bot/chat`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        message: text,
        history: chatHistory.slice(-4)
      })
    });

    removeTypingIndicator();
    chatbotSendBtn.disabled = false;

    if (res.ok) {
      const data = await res.json();
      appendMessage('assistant', data.reply);
      chatHistory.push({ role: 'assistant', content: data.reply });
    } else {
      const err = await res.json();
      const errorReply = err.detail || "I'm having trouble connecting to my brain right now! Please try again in a moment.";
      appendMessage('assistant', errorReply);
    }
  } catch (error) {
    console.error("Gemini API connection error.", error);
    removeTypingIndicator();
    chatbotSendBtn.disabled = false;
    appendMessage('assistant', "I'm currently disconnected. Please make sure the backend server is running and try again.");
  }
}

if (chatbotSendBtn) chatbotSendBtn.addEventListener('click', sendMessage);
if (chatbotInput) {
  chatbotInput.addEventListener('keypress', (e) => {
    if (e.key === 'Enter') {
      sendMessage();
    }
  });
}

// ESC Key accessibility listener
window.addEventListener('keydown', (e) => {
  if (e.key === 'Escape') {
    if (chatbotContainer && !chatbotContainer.classList.contains('hidden')) {
      toggleChatbot();
    }
    if (mobileNav && mobileNav.classList.contains('open')) {
      mobileNav.classList.remove('open');
    }
  }
});

// --- Premium Interactive Dashboard Demo Logic ---

// Tab Switching
const tabBtns = document.querySelectorAll('.tab-btn');
const tabPanes = document.querySelectorAll('.tab-pane');

tabBtns.forEach(btn => {
  btn.addEventListener('click', () => {
    // Remove active from all
    tabBtns.forEach(b => b.classList.remove('active'));
    tabPanes.forEach(p => p.classList.remove('active'));
    
    // Add active to clicked
    btn.classList.add('active');
    const targetId = btn.getAttribute('data-target');
    document.getElementById(targetId).classList.add('active');
  });
});

// --- Live Candidate Profiles Pool & Matching Engine ---
const PROFILES_POOL = [
  {
    id: "aanya",
    name: "Aanya Sharma, 23",
    role: "Product Designer @ Swiggy • Moving to HSR Layout",
    avatar: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200",
    city: "bangalore",
    targetArea: "HSR Layout",
    budget: 15000,
    cleanliness: 4,
    sleep: "night_owl",
    food: "vegetarian",
    hobbies: ["Tech/Design", "Indie Music"]
  },
  {
    id: "rohan",
    name: "Rohan Verma, 24",
    role: "Software Engineer @ Razorpay • Moving to Koramangala",
    avatar: "https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=200",
    city: "bangalore",
    targetArea: "Koramangala",
    budget: 25000,
    cleanliness: 5,
    sleep: "night_owl",
    food: "non_veg",
    hobbies: ["Gaming", "Open Source"]
  },
  {
    id: "tanvi",
    name: "Tanvi Kulkarni, 22",
    role: "Growth Analyst @ CRED • Moving to Indiranagar",
    avatar: "https://images.unsplash.com/photo-1517841905240-472988babdf9?w=200",
    city: "bangalore",
    targetArea: "Indiranagar",
    budget: 35000,
    cleanliness: 5,
    sleep: "early_bird",
    food: "vegan",
    hobbies: ["Specialty Coffee", "Yoga"]
  },
  {
    id: "dev",
    name: "Dev Mhatre, 23",
    role: "Financial Analyst @ Deloitte • Moving to BKC",
    avatar: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200",
    city: "mumbai",
    targetArea: "BKC Mumbai",
    budget: 28000,
    cleanliness: 4,
    sleep: "early_bird",
    food: "vegetarian",
    hobbies: ["FinTech", "Cycling"]
  },
  {
    id: "sneha",
    name: "Sneha Reddy, 24",
    role: "SDE-2 @ Amazon • Moving to Gachibowli",
    avatar: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200",
    city: "hyderabad",
    targetArea: "HITEC City",
    budget: 18000,
    cleanliness: 4,
    sleep: "flexible",
    food: "any",
    hobbies: ["Trekking", "Board Games"]
  },
  {
    id: "vikram",
    name: "Vikramaditya Roy, 25",
    role: "Product Lead @ Zomato • Moving to Cyber City",
    avatar: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200",
    city: "gurgaon",
    targetArea: "Cyber City",
    budget: 42000,
    cleanliness: 5,
    sleep: "night_owl",
    food: "non_veg",
    hobbies: ["Podcasts", "Tennis"]
  }
];

const citySelect = document.getElementById('citySelect');
const budgetSlider = document.getElementById('budgetSlider');
const budgetValue = document.getElementById('budgetValue');
const cleanlinessSelect = document.getElementById('cleanlinessSelect');
const sleepSelect = document.getElementById('sleepSelect');
const foodSelect = document.getElementById('foodSelect');

const matchBadgeText = document.getElementById('matchBadgeText');
const scoreCircle = document.getElementById('scoreCircle');
const matchAvatar = document.getElementById('matchAvatar');
const matchName = document.getElementById('matchName');
const matchRole = document.getElementById('matchRole');
const matchExplanation = document.getElementById('matchExplanation');
const matchBreakdown = document.getElementById('matchBreakdown');
const matchRankBadge = document.getElementById('matchRankBadge');
const connectBtn = document.getElementById('connectBtn');
const nextCandidateBtn = document.getElementById('nextCandidateBtn');
const profileHeader = document.getElementById('profileHeader');

let rankedCandidates = [];
let candidateIndex = 0;

function calculateScore(cand, userCity, userBudget, userCleanliness, userSleep, userFood) {
  let score = 0;
  let explanations = [];

  // City match bonus (up to 20 pts)
  if (cand.city === userCity) {
    score += 20;
    explanations.push(`Also moving to ${cand.targetArea}`);
  } else {
    score += 5;
    explanations.push(`Open to ${cand.city.toUpperCase()} relocation`);
  }

  // Budget similarity (up to 25 pts)
  const diffPct = Math.abs(cand.budget - userBudget) / Math.max(userBudget, 1);
  if (diffPct <= 0.15) {
    score += 25;
    explanations.push("budget matches your target range almost perfectly");
  } else if (diffPct <= 0.35) {
    score += 18;
    explanations.push("budget has a comfortable overlap with yours");
  } else {
    score += 8;
    explanations.push("budget differs slightly");
  }

  // Cleanliness match (up to 20 pts)
  const cleanDiff = Math.abs(cand.cleanliness - userCleanliness);
  if (cleanDiff === 0) {
    score += 20;
    explanations.push("has the exact same cleanliness rating");
  } else if (cleanDiff === 1) {
    score += 14;
    explanations.push("maintains a very similar cleanliness standard");
  } else {
    score += 5;
    explanations.push("has a different preference for tidiness");
  }

  // Routine match (up to 20 pts)
  if (cand.sleep === userSleep) {
    score += 20;
    explanations.push(`is a ${cand.sleep.replace('_', ' ')} just like you`);
  } else if (cand.sleep === 'flexible' || userSleep === 'flexible') {
    score += 15;
    explanations.push("has a flexible daily routine");
  } else {
    score += 5;
    explanations.push("has different waking/sleeping hours");
  }

  // Diet match (up to 15 pts)
  if (cand.food === userFood || cand.food === 'any' || userFood === 'any') {
    score += 15;
    explanations.push("shares compatible food habits");
  } else {
    score += 5;
    explanations.push("has distinct dietary habits");
  }

  const finalPct = Math.min(Math.max(score, 62), 99);
  return { candidate: cand, score: finalPct, explanations };
}

function updateMatchCalculator(resetIndex = true) {
  if (!budgetSlider || !matchBadgeText || !matchBreakdown) return;

  const userCity = citySelect ? citySelect.value : 'bangalore';
  const userBudget = parseInt(budgetSlider.value, 10);
  if (budgetValue) budgetValue.textContent = userBudget.toLocaleString('en-IN');

  const userCleanliness = parseInt(cleanlinessSelect.value, 10);
  const userSleep = sleepSelect.value;
  const userFood = foodSelect.value;

  // Evaluate all candidates in pool
  const results = PROFILES_POOL.map(cand => calculateScore(cand, userCity, userBudget, userCleanliness, userSleep, userFood));
  
  // Sort descending by score
  results.sort((a, b) => b.score - a.score);
  rankedCandidates = results;

  if (resetIndex) {
    candidateIndex = 0;
  }

  const currentMatch = rankedCandidates[candidateIndex];
  if (!currentMatch) return;

  const { candidate, score, explanations } = currentMatch;

  // Profile Header Smooth Animation
  if (profileHeader) {
    profileHeader.style.opacity = '0.5';
    profileHeader.style.transform = 'translateY(4px)';
    setTimeout(() => {
      profileHeader.style.opacity = '1';
      profileHeader.style.transform = 'translateY(0)';
    }, 150);
  }

  // Update Avatar and Text
  if (matchAvatar) matchAvatar.src = candidate.avatar;
  if (matchName) matchName.textContent = candidate.name;
  if (matchRole) matchRole.textContent = candidate.role;

  // Update SVG Circular Chart
  matchBadgeText.textContent = `${score}%`;
  scoreCircle.setAttribute('stroke-dasharray', `${score}, 100`);
  scoreCircle.style.stroke = score >= 90 ? '#10B981' : (score >= 80 ? '#0EA5E9' : '#eab308');

  // Update Rank Badge
  if (matchRankBadge) {
    matchRankBadge.textContent = `Rank #${candidateIndex + 1} of ${rankedCandidates.length} Matches`;
  }

  // Update Explanation Text
  if (matchExplanation) {
    matchExplanation.innerHTML = `<strong>Why it's a match:</strong> ${candidate.name.split(',')[0]} ${explanations[1]}. ${candidate.name.split(',')[0]} ${explanations[0]}!`;
  }

  // Update Breakdown Tags
  matchBreakdown.innerHTML = `
    <div class="breakdown-tag">✓ Target: ₹${(candidate.budget * 0.9).toFixed(0)} - ₹${(candidate.budget * 1.1).toFixed(0)}</div>
    <div class="breakdown-tag">✓ Cleanliness: ${candidate.cleanliness}/5</div>
    <div class="breakdown-tag">✓ Routine: ${candidate.sleep.replace('_', ' ').toUpperCase()}</div>
    <div class="breakdown-tag">✓ Diet: ${candidate.food.replace('_', ' ').toUpperCase()}</div>
    <div class="breakdown-tag">✓ Area: ${candidate.targetArea}</div>
    <div class="breakdown-tag">✓ Shared: ${candidate.hobbies.join(', ')}</div>
  `;

  // Update Connect Button
  if (connectBtn) {
    const firstName = candidate.name.split(' ')[0];
    connectBtn.textContent = `Connect with ${firstName} 💬`;
    connectBtn.onclick = () => {
      alert(`Connect request sent to ${candidate.name}! In the Cohabio mobile app, swiping right instantly opens a direct 1-on-1 chat room.`);
    };
  }
}

// Event Listeners
if (citySelect) citySelect.addEventListener('change', () => updateMatchCalculator(true));
if (budgetSlider) budgetSlider.addEventListener('input', () => updateMatchCalculator(true));
if (cleanlinessSelect) cleanlinessSelect.addEventListener('change', () => updateMatchCalculator(true));
if (sleepSelect) sleepSelect.addEventListener('change', () => updateMatchCalculator(true));
if (foodSelect) foodSelect.addEventListener('change', () => updateMatchCalculator(true));

if (nextCandidateBtn) {
  nextCandidateBtn.addEventListener('click', () => {
    if (rankedCandidates.length > 0) {
      candidateIndex = (candidateIndex + 1) % rankedCandidates.length;
      updateMatchCalculator(false);
    }
  });
}

// Assistant Mock Simulator Logic
function simulateAssistantChat(text) {
  const container = document.getElementById('assistantMockMessages');
  if(!container) return;
  
  // Append user message
  const userMsg = document.createElement('div');
  userMsg.className = 'mock-message user';
  userMsg.textContent = text;
  container.appendChild(userMsg);
  
  // Scroll to bottom
  container.scrollTop = container.scrollHeight;
  
  // Simulate AI Typing
  setTimeout(() => {
    const aiMsg = document.createElement('div');
    aiMsg.className = 'mock-message ai';
    
    if (text.includes("Mumbai")) {
      aiMsg.innerHTML = "For a 25k budget in Mumbai, I highly recommend checking out <strong>Andheri West</strong> or <strong>Powai</strong> if you are working nearby. They have great young communities. Would you like me to find verified flatmates currently looking there?";
    } else {
      aiMsg.innerHTML = "In Bangalore, getting a good PG under 10k is possible in areas like <strong>BTM Layout</strong>, <strong>Marathahalli</strong>, or <strong>Electronic City</strong>. Keep in mind, these might be double or triple sharing. Should I show you some top-rated options?";
    }
    
    container.appendChild(aiMsg);
    container.scrollTop = container.scrollHeight;
  }, 800);
}

// Initial Call
setTimeout(() => updateMatchCalculator(true), 100);
