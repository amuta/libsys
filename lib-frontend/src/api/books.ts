import { api } from "./client";
export const listBooks=(q="")=> api.get("/api/v1/books",{params:{q}}).then(r=>r.data);
export const getBook  =(id:number)=> api.get(`/api/v1/books/${id}`).then(r=>r.data);
export const createBook=(b:any)=> api.post("/api/v1/books",{book:b}).then(r=>r.data);
export const updateBook=(id:number,b:any)=> api.patch(`/api/v1/books/${id}`,{book:b});
export const deleteBook=(id:number)=> api.delete(`/api/v1/books/${id}`);
export const addCopy=(id:number,barcode:string)=> api.post(`/api/v1/books/${id}/copies`,{barcode}).then(r=>r.data);
export const borrow=(id:number)=> api.post(`/api/v1/books/${id}/borrow`).then(r=>r.data);
