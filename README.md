# Service Hub

A Rails/PostgreSQL service marketplace with customer, provider, and admin roles.

## Setup

```sh
bin/setup
bin/rails db:seed
bin/dev
```

The app uses PostgreSQL. Configure its connection in `config/database.yml` (or
with `DATABASE_URL`) before running migrations.

## Included workflow

- Customers browse active services by text and category, book an available time,
  cancel bookings, and review completed appointments.
- Providers manage services and weekly availability, then confirm, reject, or
  complete their own bookings.
- Administrators have dashboard statistics and management views for users,
  services, bookings, and reviews.

Booking creation is transactional and is protected both in Rails and PostgreSQL:
the provider availability is checked, and a PostgreSQL exclusion constraint
prevents overlapping non-cancelled appointments under concurrent requests.

`UpcomingBookingReminderJob` is scheduled hourly in production through Solid
Queue. It creates one reminder per confirmed appointment about a day ahead.

## Verification

```sh
bin/rails db:migrate
bin/rails test
```
## Screenshot
<img width="1000" height="7022" alt="landing page" src="https://github.com/user-attachments/assets/f1d60f91-3b68-496d-b56a-cca8308e2564" />
