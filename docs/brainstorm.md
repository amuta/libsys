Library Management System


# Models
## User
We have 2 types ->  Librarian and Member
The difference is that librarians should be able to add/edit/delete books

## Book? 
I think using books as a model might be a bad choice, I would Think that a Library would have other things that are not Books that would be needed to be managed too (equipment, rooms?, )

So I think a good approach would be to have Items and Book be a type of it, the book defines 
.... but maybe not... maybe books can be borrowable

-> related models

## Store? Storageable?
how about it? The concern of books or other things that are storable (multiple instances...)
With some other details? (like a book can have a publish date and a printed date right?, editiions?)

## Person -> (can be author of books)
Necessary so we can add more information about a specific person and be able to have things like pen-names, etc... So a book can have its author name as Joshua and that actually point to person:55 (John -> aliases: ... )

## Genre  -> (genre type that can be used for books)
This might be good to have a model for it on its own, so we can easily reason and maybe build something like recommendations by genre, most popular... etc, without having to overload other models

## Behaviors?
Users Act on Book 


....
# Interface

Its an dashboard, with two interfaces (or we can think of two dashboards with some shared behavior)
Notes:
 - To make things simple I think just one dashboard, and enabled behavior (API+Front) for Librarians 

