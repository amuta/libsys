import { api } from "./client";
export const myLoans=()=> api.get("/api/v1/loans").then(r=>r.data);
export const returnLoan=(id:number)=> api.patch(`/api/v1/loans/${id}/return`);
