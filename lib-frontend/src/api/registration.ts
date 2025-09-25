import { api } from "./client";
export type RegInput = { email_address: string; password: string; password_confirmation?: string; name: string };
export const register = async (u: RegInput) =>
  (await api.post("/api/v1/registration", { user: u })).data;
