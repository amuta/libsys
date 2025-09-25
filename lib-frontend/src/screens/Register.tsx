import { useState } from "react";
import { useMutation } from "@tanstack/react-query";
import { register } from "../api/registration";
import { Link, useNavigate } from "react-router-dom";

export default function Register(){
  const [name, setN] = useState("");
  const [email, setE] = useState("");
  const [pw, setP] = useState("");
  const [pw2, setP2] = useState("");
  const nav = useNavigate();

  const valid = name.trim().length>0 && email.trim().length>0 && pw.length>=6 && pw===pw2;

  const m = useMutation({
    mutationFn: () => register({ name, email_address: email, password: pw, password_confirmation: pw2 }),
    onSuccess: () => nav("/login"),
  });

  return (
    <div className="min-h-screen flex items-center justify-center bg-base-100">
      <div className="card w-full max-w-sm bg-base-200 shadow">
        <div className="card-body gap-3">
          <h1 className="card-title">Create account</h1>

          <input
            className={`input input-bordered w-full ${name.trim() ? "" : "input-error"}`}
            placeholder="Full name"
            value={name}
            onChange={e=>setN(e.target.value)}
            required
          />

          <input
            className={`input input-bordered w-full ${email.trim() ? "" : "input-error"}`}
            placeholder="Email"
            value={email}
            onChange={e=>setE(e.target.value)}
            required
          />

          <input
            className={`input input-bordered w-full ${(pw.length>=6 || pw.length===0) ? "" : "input-error"}`}
            type="password"
            placeholder="Password (min 6)"
            value={pw}
            onChange={e=>setP(e.target.value)}
            required
          />

          <input
            className={`input input-bordered w-full ${pw2 && pw2!==pw ? "input-error" : ""}`}
            type="password"
            placeholder="Confirm password"
            value={pw2}
            onChange={e=>setP2(e.target.value)}
            required
          />

          {(!name.trim() || !email.trim() || (pw && pw.length<6) || (pw2 && pw2!==pw)) && (
            <div className="text-xs opacity-70">
              Name and email are required. Password must be at least 6 characters and match confirmation.
            </div>
          )}

          {m.error && (
            <div className="alert alert-error text-sm">
              <span>{(m as any).error?.response?.data?.messages?.join?.(", ") || "Registration failed"}</span>
            </div>
          )}

          <button
            className={`btn btn-primary w-full ${m.isPending?"loading":""}`}
            onClick={()=>m.mutate()}
            disabled={!valid || m.isPending}
          >
            Register
          </button>

          <div className="text-sm opacity-75">
            Already have an account? <Link to="/login" className="link">Sign in</Link>
          </div>
        </div>
      </div>
    </div>
  );
}
