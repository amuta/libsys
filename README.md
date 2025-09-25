# Library Management System

Rails API + React frontend. Auth with cookies. Roles: Librarian and Member. Books with copies, loans, search, and dashboards.

## Prerequisites
- Ruby 3.2+ and Rails 8
- Node 20+ and npm 10+
- PostgreSQL 14+


## Quickstart



```bash
# Backend
bin/setup            # installs gems, creates DB, runs migrations
bin/rails db:seed    # demo data and accounts
bin/rails s          # http://localhost:3000

# Frontend
### lib-frontend/.env.example
VITE_API_URL=http://localhost:3000

cd lib-frontend
cp .env.example .env
npm install  
npm run dev          # http://localhost:5173
```

### Demo accounts (from seeds)

```
librarian: librarian@example.com / password123
member:    member@example.com    / password123
```

## Features

- Registration, login, logout (cookie session).
- Roles via Pundit: Librarian can create/update/delete books and copies, return loans. Member borrows and views own loans.
- Books: title, ISBN, language, authors, genres. Search by title/author/genre.
- Copies per book. Availability from copies.
- Loans: 14-day due, active/returned, overdue calculation.
- Dashboards:
  - Librarian: totals, due today, overdue members list, library loans grouped by member.
  - Member: my loans with due dates and status.
- React UI with TanStack Query, Tailwind/DaisyUI.

## Architecture

- Models: `User`, `Book`, `Copy`, `Loan`, `Genre`, `Person`, `Contribution`.
- Concerns: `Loanable`, `Catalogable`, `Book::Searchable`, `Loan::Defaults`, `Loan::Rules`.
- Services (PORO): `Loan::Create`, `Loan::Return`, `Book::Create`.
- Policies: `BookPolicy`, `CopyPolicy`, `LoanPolicy`.
- Controllers (JSON only):
  - `Api::V1::SessionsController` (`create/show/destroy`)
  - `Api::V1::RegistrationsController#create`
  - `Api::V1::BooksController` (index/show/create/update/destroy, `borrow`, `copies`)
  - `Api::V1::LoansController` (index, `return`)
  - Lookups: `PeopleController#search`, `GenresController#search`
- Views: Jbuilder partials. Librarian context includes member fields on loans.

## API (summary)

All responses JSON. Cookie `session_token` set on login/registration.

```
POST   /api/v1/registration                         # create user + session
POST   /api/v1/session                              # login
GET    /api/v1/session                              # whoami
DELETE /api/v1/session                              # logout

GET    /api/v1/books?q=...                          # list/search
GET    /api/v1/books/:id
POST   /api/v1/books                                # librarian
PATCH  /api/v1/books/:id                            # librarian
DELETE /api/v1/books/:id                            # librarian
POST   /api/v1/books/:id/borrow                     # member borrow
POST   /api/v1/books/:id/copies { barcode }         # librarian add copy

GET    /api/v1/loans?mine=1                         # member: own; librarian: all
PATCH  /api/v1/loans/:id/return                     # librarian

GET    /api/v1/people/search?q=...
GET    /api/v1/genres/search?q=...
```

### Status codes

- 200 OK, 201 Created, 204 No Content.
- 401 Unauthorized, 403 Forbidden, 404 Not Found.
- 409 Conflict (`already_borrowed`).
- 422 Unprocessable Entity (`validation_failed`, `not_available`).

## Frontend

- `lib-frontend/` Vite + React + TS.
- Auth stored via cookie. `withCredentials: true`.
- Screens: Login, Books (CRUD, borrow), BookForm, Loans (member and librarian tabs), Dashboard.
- Env: `.env` set `VITE_API_URL`.

## Testing

```bash
bin/rspec
```

Covers requests for auth, books CRUD, loans borrow/return, unhappy paths; policies; model rules.

## How this evolved (AI/Codegen)

### Original idea (pre-AI)
- Considered generic `Item` with STI (`Book < Item`) to support non-book assets.
- Services for loan create/return. Person/Genre as separate models. One dashboard with role-gated actions.

### V1 design (hand-written)
- Concrete models: `User`, `Item/Book`, `Copy`, `Loan`.
- Pundit for roles. Cookie session. React frontend with query-driven state.
- DB constraints for barcodes and one active loan per copy.

### AI-assisted deltas adopted
- Extracted book creation into `Book::Create` service to keep controllers slim.
- Normalized 422 status symbol (`:unprocessable_entity`).
- Fixed cookie key mismatches; removed unused frameworks (ActionCable, Active Job, Mailers) and limited railties.
- Stabilized loan JSON to include both `title` and `loanable_title` for UI.

### Current state
- Cookie session with `Current.session` and `Current.user`.
- Pundit policies enforced across controllers.
- Loan invariants and 14-day default encapsulated in concerns/services.
- React UI wired to REST endpoints with optimistic UX for borrow/return.

## Local commands

```bash
# DB reset
bin/rails db:drop db:create db:migrate db:seed

# Lint (if RuboCop configured)
bundle exec rubocop

# Remove unused frameworks (already applied)
bin/rails zeitwerk:check
bin/rails routes
```

## Notes

- Session cookie: `cookies.encrypted[:session_token]`.
- Search is SQL LIKE on title/author/genre with safe sanitization.
- Overdue = `due_at < Time.current` on active loans.
