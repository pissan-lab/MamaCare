# MamaCare (Pregnancy Management App)

MamaCare is a Flutter-based mobile application designed to help expectant
mothers track their pregnancy, share information with doctors, and manage
personal data in a secure, privacy-aware way.  It includes a simple local
SQLite backend today but is architected so that it can communicate with a
remote API server when available.

---

## Key Features

1. **Authentication & Authorization**
   - Email/password sign‑in with **multifactor authentication (MFA)** support.
   - Three user roles: **admin**, **doctor**, and **patient**.
     - Admins can view audit logs and manage accounts.
     - Doctors see only the patients assigned to them.
     - Patients can enter and review their personal health data.
   - Role checks enforced in services and screens.

2. **User Control & Privacy**
   - Consent management: users choose what categories of personal or health
data the app may collect (stored in the `preferences` field).
   - Data portability: users can **download/export** all their stored
information in JSON format.
   - Right to be forgotten: users can **delete all their data and account**.
   - All data modifications are logged via the audit trail (`system_logs`).

3. **Backend API Communication**
   - `ApiService` wrapper for RESTful HTTP calls allows the front end to talk
     to a server (placeholder `https://api.mamacare.com` by default).
   - This separation makes it easy to switch between the local database and a
     remote backend.

4. **Audit & Penetration Considerations**
   - Admins can inspect who logged in, changed, or viewed records.
   - The app code is structured with security in mind; sensitive data is
     encrypted with a device-specific key.
   - Penetration testing should target both the mobile client and any
     backend API (ensure JWTs, HTTPS, rate limiting, etc.).

---

## 🛠️ Project Structure

- `lib/services/` – contains business logic: authentication, database access,
  API client, and system logging.
- `lib/models/` – simple Dart classes representing users, profiles,
  assignments, and logs.
- `lib/screens/` – UI pages partitioned by role (admin/doctor/patient) and
  feature area.
- `main.dart` – app entry point with routing and theme information.

---

## 🚀 Getting Started

1. Install Flutter and ensure your environment is set up.
2. Run `flutter pub get` to fetch dependencies.
3. Start the app with `flutter run` on a connected device or simulator.

Default administrator credentials (created on first launch):

```
email: admin@mamacare.com
password: admin123
```


---

*This README will evolve as the project grows; please refer to the `lib/`
directory for implementation details and additional documentation.*
