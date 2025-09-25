# Library Management System

Rails API + React frontend. Auth with cookies. Roles: Librarian and Member. Books with copies, loans, search, and dashboards.

## Prerequisites
- Ruby 3.2+ and Rails 8
- Node 20+ and npm 10+
- PostgreSQL 14+

## Quickstart

Start the Postgres database
```bash
# Make sure you have postgres running and set the your own database env vars
# or just use the docker compose to create a new local postgres container 
export PGUSER=libsys PGPASSWORD=password PGHOST=localhost PGPORT=5432
# Start Postgres (same env vars)
docker compose up -d
```

Start the Rails server 
```bash
# Start Rails Backend
bundle install                # install gems
bin/rails db:setup db:seed    # demo data and accounts 
bin/rails s -d                # http://localhost:3000
```

Start Frontend
```bash
## lib-frontend/.env.example
VITE_API_URL=http://localhost:3000

## Enter Front-end sub directory, copy .env file and run vite 
cd lib-frontend
cp .env.example .env
npm install  
npm run dev # http://localhost:5173
```
Then access the front-end at: http://localhost:5173

### Demo accounts (from seeds)
```
librarian: librarian@example.com / password
member:    member@example.com    / password
```

## Testing

```bash
bundle exec rspec
```

Covers requests for auth, books CRUD, loans borrow/return, unhappy paths; policies; model rules.

## How this evolved (AI/Codegen)

I saved two initial files related to my starting point, one `docs/brainstorm.md` is my original sketch before using AI at all (its a sketch for myself testing my ideas, so very unstructured). Also `docs/first_plan.md` is one of the first plans created from my prompt (+ some iterations), which is very close to our final system.

### Original idea (pre-AI)
- Considered generic `Item` with STI (`Book < Item`) to support non-book assets.
- Services for loan create/return. Person/Genre as separate models. One dashboard with role-gated actions.

### V1 design (hand-written)
- Concrete models: `User`, `Item/Book`, `Copy`, `Loan`.
- Pundit for roles. Cookie session. React frontend with query-driven state.
- DB constraints for barcodes and one active loan per copy.

### AI-assisted deltas adopted
- Extracted book creation into `Book::Create` service to keep controllers slim.
- Fixed cookie key mismatches; removed unused frameworks (ActionCable, Active Job, Mailers) and limited railties.
- Stabilized loan JSON to include both `title` and `loanable_title` for UI.
- Writing Specs and Iterating quickly on ideas.


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
- Screens: Login, Registration, Books (CRUD, borrow), BookForm, Loans (member and librarian tabs), Dashboard.
- Env: `.env` set `VITE_API_URL`.

## Notes

- Session cookie: `cookies.encrypted[:session_token]`.
- Search is SQL LIKE on title/author/genre with safe sanitization.
- Overdue = `due_at < Time.current` on active loans.

## Deferred due time (limited test to max of 6 hours)

- Unit/model and frontend tests (focused on request specs)
- Detailed API reference and extended docs (README only)
- extra polish and edge UX states

