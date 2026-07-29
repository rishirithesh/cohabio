document.getElementById('waitlistForm').addEventListener('submit', async (e) => {
  e.preventDefault();
  
  const fullName = document.getElementById('fullName').value;
  const email = document.getElementById('email').value;
  const targetCity = document.getElementById('targetCity').value;
  const msgDiv = document.getElementById('waitlistMsg');

  msgDiv.style.color = '#38BDF8';
  msgDiv.textContent = 'Submitting details to waitlist...';

  try {
    const response = await fetch('http://localhost:8000/api/v1/waitlist', {
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
    const res = await fetch('http://localhost:8000/api/v1/auth/google', {
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
      // Future: Redirect to web app dashboard if applicable
    } else {
      const err = await res.json();
      alert(`Authentication Failed: ${err.detail || 'Error verifying Google token.'}`);
    }
  } catch (error) {
    console.error("Google Sign-In connection failed:", error);
    alert(`Could not connect to the backend server.\nMake sure the backend is running at localhost:8000.`);
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
        // If they click waitlist, close chat for better UX
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
  
  // Enforce Max Length Client-side
  if (text.length > 150) {
    alert("Message is too long. Please keep it under 150 characters.");
    return;
  }

  chatbotInput.value = '';
  appendMessage('user', text);
  
  // Add to internal history
  chatHistory.push({ role: 'user', content: text });
  
  showTypingIndicator();
  chatbotSendBtn.disabled = true;

  try {
    const res = await fetch('http://localhost:8000/api/v1/public/bot/chat', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        message: text,
        history: chatHistory.slice(-4) // Only send recent context to save tokens
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
