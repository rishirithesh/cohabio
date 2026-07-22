# Cohabio API Specification

Cohabio exposes REST and WebSocket APIs. The OpenAPI Interactive Swagger interface is available locally at: [http://localhost:8000/docs](http://localhost:8000/docs).

---

## 🔐 Authentication
- **`POST /api/v1/auth/signup`**: Registers a new account, generates profile records.
- **`POST /api/v1/auth/login`**: Verifies email/password and returns access/refresh JWT tokens.
- **`POST /api/v1/auth/refresh`**: Generates a new access token using a refresh token.
- **`POST /api/v1/auth/google` / `/apple`**: Simulated OAuth login endpoints.

---

## 👤 Profiles
- **`GET /api/v1/profiles/me`**: Retrieves the logged-in user's profile and lifestyle configurations.
- **`PUT /api/v1/profiles/me`**: Updates demographic data and preferences.

---

## 🤝 Roommate Discoveries
- **`GET /api/v1/roommates/recommendations`**: Returns matching roommates sorted by compatibility index.
- **`POST /api/v1/roommates/swipe`**: Sweeps a candidate profile (liked/disliked). Returns match indicators.

---

## 🏢 Communities
- **`GET /api/v1/communities/`**: Lists communities filtered by category.
- **`POST /api/v1/communities/{id}/join`**: Joins a community.
- **`GET /api/v1/communities/{id}/posts`**: Fetches community discussions feed.
- **`POST /api/v1/communities/posts/{post_id}/like`**: Likes/unlikes a post.

---

## 💬 Real-Time Messaging (WebSockets)
- **`GET /api/v1/chat/rooms`**: Returns all active chats.
- **`GET /api/v1/chat/rooms/{id}/messages`**: Retrieves chat logs.
- **`WS /api/v1/chat/ws/{room_id}?token={JWT}`**: Connects to the real-time chat channel.
  - *Payload format*:
    ```json
    {
      "type": "message",
      "content": "Hello roommate!"
    }
    ```
