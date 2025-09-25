import { useState } from "react";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { login } from "../api/session";
import { Link, useNavigate, useSearchParams } from "react-router-dom";

export default function Login() {
  const [email, setE] = useState(""); const [pw, setP] = useState("");
  const qc = useQueryClient(); const nav = useNavigate(); const [sp] = useSearchParams();
  const m = useMutation({ mutationFn: () => login(email, pw), onSuccess: () => { qc.invalidateQueries({ queryKey: ["me"] }); nav(sp.get("next") || "/dashboard"); } });
  return (
    <div className="min-h-screen flex items-center justify-center bg-base-100">
      <div className="card w-full max-w-sm bg-base-200 shadow">
        <div className="card-body gap-3">
          <h1 className="card-title">Login</h1>
          <input className="input input-bordered w-full" placeholder="email" value={email} onChange={e => setE(e.target.value)} />
          <input className="input input-bordered w-full" type="password" placeholder="password" value={pw} onChange={e => setP(e.target.value)} />
          <button className="btn btn-primary w-full" onClick={() => m.mutate()} disabled={m.isPending}>
            Sign in
          </button>

          <Link to="/register" className="btn btn-outline w-full">
            Create an account
          </Link>

          {m.error && <div className="alert alert-error text-sm">Login failed</div>}
        </div>
      </div>
    </div>
  );
}
