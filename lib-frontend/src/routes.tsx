import Login from "./screens/Login";
import Books from "./screens/Books";
import BookForm from "./screens/BookForm";
import Loans from "./screens/Loans";
import Guard from "./screens/Guard";
import Dashboard from "./screens/Dashboard";
import Register from "./screens/Register";
import { Navigate } from "react-router-dom";
export default [
  { path:"/login", element:<Login/> },
  { path:"/register", element:<Register/> },
  { path:"/", element:<Guard/>, children:[
    { index:true, element:<Navigate to="/dashboard" replace /> },
    { path:"/dashboard", element:<Dashboard/> },
    { path:"/books", element:<Books/> },
    { path:"/books/new", element:<BookForm mode="create"/> },
    { path:"/books/:id/edit", element:<BookForm mode="edit"/> },
    { path:"/loans", element:<Loans/> },
    { path:"*", element:<Navigate to="/dashboard" replace /> },
  ]},
];
