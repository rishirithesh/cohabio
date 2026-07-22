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

async function handleGoogleSignIn() {
  const email = prompt("Simulating Google Sign-In:\nPlease enter your Google Account Email:", "student@cohabio.com");
  if (!email) return;

  try {
    const response = await fetch('http://localhost:8000/api/v1/auth/google', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        email: email,
        name: email.split('@')[0].toUpperCase() + " (Google)",
        picture: "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=150&q=80"
      })
    });

    if (response.ok) {
      const data = await response.json();
      alert(`Google Sign-In Successful!\n\nEmail: ${email}\nRole: ${data.role}\nUser ID: ${data.user_id}\n\nWelcome to Cohabio! 🚀`);
    } else {
      const err = await response.json();
      alert(`Google Sign-In Failed: ${err.detail || 'Error'}`);
    }
  } catch (error) {
    console.error("Google Sign-In connection failed:", error);
    alert(`Google Sign-In Simulated Successfully!\n\nLogged in as: ${email}`);
  }
}
