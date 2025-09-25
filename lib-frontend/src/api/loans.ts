import { api } from "./client";
export const fetchLoans = (mine=false) => api.get("/api/v1/loans", { params: mine ? { mine: 1 } : {} }).then(r=>r.data);
export const returnLoan = (id:number) => api.patch(`/api/v1/loans/${id}/return`);
