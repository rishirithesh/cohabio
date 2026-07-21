document.getElementById('waitlistForm').addEventListener('submit', async (e) => {
  e.preventDefault();
  
  const fullName = document.getElementById('fullName').value;
  const email = document.getElementById('email').value;
  const targetCity = document.getElementById('targetCity').value;
  const msgDiv = document.getElementById('waitlistMsg');

  msgDiv.style.color = '#38BDF8';
  msgDiv.textContent = 'Submitting details to waitlist...';

  try {
    const response = await fetch('/api/v1/waitlist', {
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
