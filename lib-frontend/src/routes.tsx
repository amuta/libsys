import Login from "./screens/Login";
import Books from "./screens/Books";
import BookForm from "./screens/BookForm";
import Loans from "./screens/Loans";
import Guard from "./screens/Guard";
export default [
  { path:"/login", element:<Login/> },
  { path:"/", element:<Guard/>, children:[
    { path:"/books", element:<Books/> },
    { path:"/books/new", element:<BookForm mode="create"/> },
    { path:"/books/:id/edit", element:<BookForm mode="edit"/> },
    { path:"/loans", element:<Loans/> },
    { path:"*", element:<Books/> },
  ]},
];
