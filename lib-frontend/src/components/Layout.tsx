import { Link, Outlet, useNavigate } from "react-router-dom";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { logout } from "../api/session";
import { useSession } from "../auth/useSession";

export default function Layout(){
  const { data: me, isLoading } = useSession();
  const qc = useQueryClient();
  const nav = useNavigate();
  const m = useMutation({
    mutationFn: logout,
    onSuccess: () => { qc.clear(); nav("/login"); }
  });

  if (isLoading) return <div className="p-6">Loading…</div>;

  return (
    <div className="min-h-screen bg-base-300">
      <div className="navbar bg-base-200">
        <div className="navbar-start">
          <Link to="/dashboard" className="btn btn-ghost text-lg font-semibold">Library</Link>
        </div>
        <div className="navbar-center gap-2">
          <Link to="/books" className="btn btn-ghost btn-sm">Books</Link>
          <Link to="/loans" className="btn btn-ghost btn-sm">Loans</Link>
        </div>
        <div className="navbar-end gap-3">
          {me && (
            <>
              <span className="badge badge-outline">
                You: {me.email_address} {me.role === "librarian" ? "(librarian)" : "(member)"}
              </span>
              <button className="btn btn-sm btn-outline" onClick={()=>m.mutate()} disabled={m.isPending}>
                Logout
              </button>
            </>
          )}
        </div>
      </div>
      <div className="container mx-auto p-6">
        {/* Provide `me` to children */}
        <Outlet context={{ me }} />
      </div>
    </div>
  );
}
