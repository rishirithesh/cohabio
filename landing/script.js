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
