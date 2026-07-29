// Dynamic Backend Base URL configuration
const API_BASE_URL = window.COHABIO_API_URL || 'http://localhost:8000';

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
      // Stagger the reveal with a small delay per card
      setTimeout(() => {
        entry.target.classList.add('visible');
      }, 80 * (Array.from(revealElements).indexOf(entry.target) % 4));
      revealObserver.unobserve(entry.target);
    }
  });
}, { threshold: 0.12 });
revealElements.forEach(el => revealObserver.observe(el));

document.getElementById('waitlistForm').addEventListener('submit', async (e) => {
  e.preventDefault();
  
  const fullName = document.getElementById('fullName').value;
  const email = document.getElementById('email').value;
  const targetCity = document.getElementById('targetCity').value;
  const msgDiv = document.getElementById('waitlistMsg');

  msgDiv.style.color = '#38BDF8';
  msgDiv.textContent = 'Submitting details to waitlist...';

  try {
    const response = await fetch(`${API_BASE_URL}/api/v1/waitlist`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        email: email,
        full_name: fullName,
        target_city: targetCity
      })
    });

    if (response.ok) {
      msgDiv.style.color = '#16A34A';
      msgDiv.textContent = 'Success! You have been added to the waitlist. 🚀';
      document.getElementById('waitlistForm').reset();
    } else {
      const err = await response.json();
      msgDiv.style.color = '#EF4444';
      msgDiv.textContent = err.detail || 'An error occurred. Please try again.';
    }
  } catch (error) {
    // Fallback if backend is not running locally yet
    console.warn('Backend not detected. Simulating local waitlist submission.', error);
    setTimeout(() => {
      msgDiv.style.color = '#16A34A';
      msgDiv.textContent = 'Success! (Simulated) You are on the waitlist! 🚀';
      document.getElementById('waitlistForm').reset();
    }, 800);
  }
});

// Real Google Identity Services Callback
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
      alert(`Welcome to Cohabio!\n\nSuccessfully authenticated via Google.\nRole: ${data.role}\n\nSince this is the landing page, we recommend downloading the mobile app for the full experience!`);
    } else {
      const err = await res.json();
      alert(`Authentication Failed: ${err.detail || 'Error verifying Google token.'}`);
    }
  } catch (error) {
    console.error("Google Sign-In connection failed:", error);
    alert(`Could not connect to the backend server at ${API_BASE_URL}.`);
  }
}

// Chatbot Logic
const chatbotTrigger = document.getElementById('chatbot-trigger');
const chatbotContainer = document.getElementById('chatbot-container');
const chatbotCloseBtn = document.getElementById('chatbot-close-btn');
const chatbotInput = document.getElementById('chatbot-input');
const chatbotSendBtn = document.getElementById('chatbot-send-btn');
const chatbotMessages = document.getElementById('chatbot-messages');

let chatHistory = [];

function toggleChatbot() {
  chatbotContainer.classList.toggle('hidden');
  if (!chatbotContainer.classList.contains('hidden')) {
    chatbotInput.focus();
  }
}

chatbotTrigger.addEventListener('click', toggleChatbot);
chatbotCloseBtn.addEventListener('click', toggleChatbot);

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
      actionBtn.textContent = 'Join the Waitlist';
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
      let errMsg = "Oops! I encountered an error. Please try again.";
      if (res.status === 429) {
         errMsg = "You're sending messages too fast! Please wait a moment.";
      }
      appendMessage('assistant', errMsg);
    }
  } catch (error) {
    removeTypingIndicator();
    chatbotSendBtn.disabled = false;
    appendMessage('assistant', "Could not connect to the server right now.");
  }
}

chatbotSendBtn.addEventListener('click', sendMessage);
chatbotInput.addEventListener('keypress', (e) => {
  if (e.key === 'Enter') {
    sendMessage();
  }
});
