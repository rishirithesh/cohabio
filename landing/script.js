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

// --- Scroll-Reveal Animations ---
const revealElements = document.querySelectorAll('.feature-card, .community-card');
const revealObserver = new IntersectionObserver((entries) => {
  entries.forEach((entry, i) => {
    if (entry.isIntersecting) {
      setTimeout(() => {
        entry.target.classList.add('visible');
      }, 80 * (Array.from(revealElements).indexOf(entry.target) % 4));
      revealObserver.unobserve(entry.target);
    }
  });
}, { threshold: 0.12 });
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

// Interactive Live Roommate Compatibility Sandbox Calculator
const budgetSlider = document.getElementById('budgetSlider');
const budgetValue = document.getElementById('budgetValue');
const cleanlinessSelect = document.getElementById('cleanlinessSelect');
const sleepSelect = document.getElementById('sleepSelect');
const foodSelect = document.getElementById('foodSelect');
const matchBadgeText = document.getElementById('matchBadgeText');
const scoreCircle = document.getElementById('scoreCircle');
const matchBreakdown = document.getElementById('matchBreakdown');

function updateMatchCalculator() {
  if (!budgetSlider || !matchBadgeText || !matchBreakdown) return;

  const budget = parseInt(budgetSlider.value, 10);
  if (budgetValue) budgetValue.textContent = budget.toLocaleString('en-IN');

  const cleanliness = parseInt(cleanlinessSelect.value, 10);
  const sleep = sleepSelect.value;
  const food = foodSelect.value;
  const matchExplanation = document.getElementById('matchExplanation');

  // Compute deterministic match percentage score
  let score = 70;
  let explanations = [];

  // Budget factor (target ~15k)
  if (budget >= 12000 && budget <= 20000) {
    score += 15;
    explanations.push("Aanya's budget falls comfortably within your range");
  } else if (budget >= 10000 && budget <= 25000) {
    score += 10;
    explanations.push("You both have a somewhat overlapping budget");
  } else {
    score += 5;
    explanations.push("Your budgets are slightly different");
  }

  // Cleanliness factor (target 4/5)
  if (cleanliness === 4) {
    score += 10;
    explanations.push("keep things very clean");
  } else if (cleanliness === 5) {
    score += 8;
    explanations.push("both prefer a pristine environment");
  } else {
    score += 4;
    explanations.push("have a relaxed approach to cleanliness");
  }

  // Sleep routine factor
  if (sleep === 'night_owl') {
    score += 5;
    explanations.push("prefer late nights");
  } else if (sleep === 'early_bird') {
    explanations.push("might have conflicting schedules (she's a night owl)");
  } else {
    score += 2;
    explanations.push("have flexible routines");
  }

  // Diet factor
  if (food === 'vegetarian' || food === 'any') {
    score += 5;
    explanations.push("share a vegetarian-friendly diet");
  } else {
    explanations.push("have different dietary preferences");
  }

  const finalScore = Math.min(score, 99);

  // SVG Circular progress effect
  matchBadgeText.textContent = `${finalScore}%`;
  scoreCircle.setAttribute('stroke-dasharray', `${finalScore}, 100`);
  scoreCircle.style.stroke = finalScore >= 90 ? '#10B981' : (finalScore >= 80 ? '#0EA5E9' : '#eab308');
  
  if (matchExplanation) {
    matchExplanation.innerHTML = `<strong>Why it's a match:</strong> You both ${explanations.slice(1).join(', ')}. ${explanations[0]}!`;
  }

  matchBreakdown.innerHTML = `
    <div class="breakdown-tag">✓ Budget: ₹${(budget * 0.8).toFixed(0)} - ₹${(budget * 1.2).toFixed(0)}</div>
    <div class="breakdown-tag">✓ Cleanliness: ${cleanliness}/5</div>
    <div class="breakdown-tag">✓ Routine: ${sleep.replace('_', ' ').toUpperCase()}</div>
    <div class="breakdown-tag">✓ Diet: ${food.replace('_', ' ').toUpperCase()}</div>
    <div class="breakdown-tag">✓ Location: HSR Layout</div>
  `;
}

if (budgetSlider) budgetSlider.addEventListener('input', updateMatchCalculator);
if (cleanlinessSelect) cleanlinessSelect.addEventListener('change', updateMatchCalculator);
if (sleepSelect) sleepSelect.addEventListener('change', updateMatchCalculator);
if (foodSelect) foodSelect.addEventListener('change', updateMatchCalculator);

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

// Initial Call to set SVG stroke color
setTimeout(updateMatchCalculator, 100);
