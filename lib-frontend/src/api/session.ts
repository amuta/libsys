import { api } from "./client";
export const whoami = async () => {
  try {
    const res = await api.get("/api/v1/session");
    return res.data?.user ?? null;   // null, not undefined
  } catch (e: any) {
    if (e?.response?.status === 401) return null;
    throw e;
  }
};
export const login  = async(e:string,p:string)=> (await api.post("/api/v1/session",{ email_address:e, password:p })).data.user;
export const logout = async()=> { await api.delete("/api/v1/session"); };
