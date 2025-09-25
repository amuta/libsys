import { useState } from "react";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { login } from "../api/session";
import { useNavigate, useSearchParams } from "react-router-dom";
export default function Login(){
  const [email,setE]=useState(""); const [pw,setP]=useState("");
  const qc=useQueryClient(); const nav=useNavigate(); const [sp]=useSearchParams();
  const m = useMutation({ mutationFn:()=>login(email,pw), onSuccess:()=>{ qc.invalidateQueries({queryKey:["me"]}); nav(sp.get("next")||"/books"); }});
  return (
    <div className="max-w-sm mx-auto p-6 space-y-4">
      <h1 className="text-xl font-semibold">Login</h1>
      <input className="w-full border p-2" placeholder="email" value={email} onChange={e=>setE(e.target.value)} />
      <input className="w-full border p-2" type="password" placeholder="password" value={pw} onChange={e=>setP(e.target.value)} />
      <button className="w-full bg-black text-white py-2" onClick={()=>m.mutate()} disabled={m.isPending}>Sign in</button>
      {m.error && <p className="text-red-600 text-sm">{(m.error as any).response?.data?.error||"Login failed"}</p>}
    </div>
  );
}
