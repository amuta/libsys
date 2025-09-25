## Models

* **User**: `email`, `password_digest`, `role` enum `{librarian, member}`, `category` enum `{adult, teen, child, staff}`.
* **Item (STI base)**: columns `type`, `title`, `code` (prefixed: `ISBN:…`), `language`, `metadata:jsonb`.

  * **Book < Item**: normalizes and validates `code` as ISBN.
* **Copy**: `item:references`, `barcode` uniq, `status` enum `{available, loaned, lost, repair, hold}`.
* **Loan**: `copy:references`, `user:references`, `borrowed_at`, `due_at`, `returned_at`, `status` enum `{active, returned, overdue}`.

## Relations

* `Item has_many :copies`.
* `Copy has_one :active_loan`.
* `Loan belongs_to :copy, :user`.

## Concerns (37signals style)

* `Item::Loanable` → `loan_to!(user)`, `return!(loan, librarian:)` (delegates to POROs `Item::Loaning::Create/Return`).
* `Item::Searchable` → `.search(q)` on `title`, optional filters.

## Services (POROs)

* **Create**: lock first available copy, ensure none active, compute `due_at = 14.days`, create loan, flip copy to `loaned`.
* **Return**: set `returned_at`, mark `returned`, flip copy to `available`.

## Auth

* **AuthN**: Devise + Devise-JWT.
* **AuthZ**: Pundit.

  * `ItemPolicy`: CRUD only for librarian; read for authenticated.
  * `LoanPolicy`: create for member; return/update for librarian; index own vs all for librarian.

## API

* Per-type endpoints:

  * `GET/POST/PATCH/DELETE /api/v1/books` (via `Items::BooksController < Items::BaseController`).
* Loans:

  * `POST /api/v1/loans` `{ copy_id }` → borrow.
  * `PATCH /api/v1/loans/:id/return` → return.
  * `GET /api/v1/loans` → member sees own; librarian sees all.

## Invariants

* Availability = `copies.available.count`.
* One active loan per copy.
* Member cannot borrow without available copy.

## DB constraints / indexes

* `items`: partial unique on `LOWER(code)` where `type='Book' AND code ILIKE 'ISBN:%'`.
* `copies.barcode` unique.
* `loans(copy_id)` unique partial where `status = 0` (active).

## Scopes

* `Loan.due_today`, `Loan.overdue`.
* `Book.by_isbn(v)` finder (uses normalized `ISBN:` code).

## Dashboards

* **Librarian**: total items/copies, active loans, due today, overdue members.
* **Member**: my active loans, due dates, overdues.

## Testing (RSpec)

* Models: STI, code normalization/validation, availability math.
* Policies: Pundit rules per role.
* Requests: books CRUD, loans borrow/return, auth and 422 paths.
* Services: transaction + locking behavior.

## Seeds

* 1 librarian, 2–3 members.
* 20–30 books, 1–5 copies each.
* A few active and one overdue loan.

## Frontend

* React + Vite + TS, TanStack Query, Router, Tailwind.
* Views: login, `/books` list + CRUD (librarian), borrow/return buttons, dashboards.
* JWT via interceptor. Query-driven state.
