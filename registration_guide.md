# Registration and Login Flow Guide

This document outlines the step-by-step process for registering a new user and logging into the application.

## Overview
The authentication flow consists of three main steps:
1.  **Registration Initiation**: Submit user details and receive a One-Time Password (OTP).
2.  **OTP Verification**: Verify the email address to create the account.
3.  **Login**: Authenticate with credentials to receive a JSON Web Token (JWT) for accessing protected endpoints.

---

## Step 1: Initiate Registration
**Endpoint**: `POST /api/v1/auth/register`

Send the user's details to this endpoint. The server will validate the information, temporarily store it, and send an OTP to the provided email address.

### Request Body (`application/json`)
```json
{
  "firstName": "John",
  "lastName": "Doe",
  "email": "john.doe@example.com",
  "phoneNumber": "+1234567890",
  "password": "SecurePassword123!"
}
```

### Response (201 Created)
```json
{
  "success": true,
  "message": "Success",
  "data": {
    "message": "An OTP has been sent to your email"
  }
}
```

---

## Step 2: Verify OTP (Complete Registration)
**Endpoint**: `POST /api/v1/auth/verify_otp`

Submit the OTP received via email to verify the account and finalize the user creation process.

### Request Body (`application/json`)
```json
{
  "email": "john.doe@example.com",
  "otp": "123456"
}
```

### Response (200 OK)
On successful verification, the user account is created.
```json
{
  "success": true,
  "message": "OTP verified successfully",
  "data": {
    "id": 1,
    "firstName": "John",
    "lastName": "Doe",
    "email": "john.doe@example.com",
    "phoneNumber": "+1234567890",
    "role": "USER"
  }
}
```
*Note: This step creates the user but does **not** return an access token. You must proceed to login.*

---

## Step 2.5: Resend OTP (Optional)
**Endpoint**: `POST /api/v1/auth/generate_otp`

If the OTP has expired or was not received, use this endpoint to request a new one.

### Request Body (`application/json`)
```json
{
  "email": "john.doe@example.com"
}
```

### Response (200 OK)
```json
{
  "success": true,
  "message": "OTP generated successfully",
  "data": "123456" 
}
```
*Note: The OTP is also sent to the user's email.*

---

## Step 3: Login (Get Access Token)
**Endpoint**: `POST /api/v1/auth/login`

Authenticate using the email and password to receive a JWT access token and a refresh token.

### Request Body (`application/json`)
```json
{
  "email": "john.doe@example.com",
  "password": "SecurePassword123!",
  "deviceToken": "optional-device-token-for-notifications"
}
```

### Response (200 OK)
```json
{
  "success": true,
  "message": "Login successfully",
  "data": {
    "user": {
      "id": 1,
      "firstName": "John",
      "lastName": "Doe",
      "email": "john.doe@example.com",
      "phoneNumber": "+1234567890",
      "role": "USER"
    },
    "token": "eyJhbGciOiJIUzI1NiJ9...",
    "refreshToken": "uuid-refresh-token..."
  }
}
```

## Using the Token
Include the `token` from the login response in the `Authorization` header for subsequent requests to protected endpoints:

`Authorization: Bearer <your_access_token>`
