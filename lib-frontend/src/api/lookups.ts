import { api } from "./client";
export const searchPeople=(q:string)=> api.get("/api/v1/people/search",{params:{q}}).then(r=>r.data);
export const searchGenres=(q:string)=> api.get("/api/v1/genres/search",{params:{q}}).then(r=>r.data);
