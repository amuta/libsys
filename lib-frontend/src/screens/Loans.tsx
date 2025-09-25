import { useMemo, useState } from "react";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { fetchLoans, returnLoan } from "../api/loans";
import { useOutletContext } from "react-router-dom";

const fmt = (d?: string) =>
  d ? new Date(d).toLocaleDateString(undefined, { year: "2-digit", month: "short", day: "2-digit" }) : "—";
const isOverdue = (l: any) => !l.returned_at && new Date(l.due_at) < new Date();
const displayMember = (l: any) =>
  l?.user_name || l?.user_email || (l?.user_id ? `Member #${l.user_id}` : "Unknown");

export default function Loans() {
  const { me } = (useOutletContext() as any) || { me: null };
  const isLib = me?.role === "librarian";
  const [scope, setScope] = useState<"library" | "mine">(isLib ? "library" : "mine");
  const { data: loans = [] } = useQuery({
    queryKey: ["loans", scope],
    queryFn: () => fetchLoans(scope === "mine"),
  });

  const qc = useQueryClient();
  const m = useMutation({ mutationFn: (id: number) => returnLoan(id), onSuccess: () => qc.invalidateQueries({ queryKey: ["loans"] }) });

  if (!isLib) return <MemberLoans loans={loans} />;

  return (
    <div className="space-y-4">
      <div className="join">
        <button className={`btn btn-sm join-item ${scope === "library" ? "btn-primary" : ""}`} onClick={() => setScope("library")}>Library loans</button>
        <button className={`btn btn-sm join-item ${scope === "mine" ? "btn-primary" : ""}`} onClick={() => setScope("mine")}>My loans</button>
      </div>
      <LibrarianLoans loans={loans} onReturn={(id) => m.mutate(id)} loading={m.isPending} />
    </div>
  );

}

/* ----- Member view ----- */
function MemberLoans({ loans }: { loans: any[] }) {
  return (
    <div>
      <h1 className="text-xl font-semibold mb-4">My Loans</h1>
      <div className="overflow-x-auto bg-base-200 rounded-box p-2">
        <table className="table">
          <thead><tr><th>Title</th><th>Borrowed</th><th>Due</th><th>Status</th></tr></thead>
          <tbody>
            {loans.map((l: any) => {
              const borrowedAt = l.borrowed_at || l.created_at;
              const status = l.returned_at ? "Returned" : (isOverdue(l) ? "Overdue" : "Active");
              return (
                <tr key={l.id}>
                  <td className="max-w-[28ch] truncate">{l.loanable_title || l.title}</td>
                  <td>{fmt(borrowedAt)}</td>
                  <td>{fmt(l.due_at)}</td>
                  <td className={status === "Overdue" ? "text-error" : undefined}>{status}</td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>
    </div>
  );
}

/* ----- Librarian view ----- */
function LibrarianLoans({
  loans,
  onReturn,
  loading
}: {
  loans: any[];
  onReturn: (id: number) => void;
  loading: boolean;
}) {
  const [tab, setTab] = useState<"active" | "overdue" | "dueToday" | "returned">("active");
  const [q, setQ] = useState("");

  const today0 = useMemo(() => { const d = new Date(); d.setHours(0, 0, 0, 0); return d.getTime(); }, []);
  const tomorrow0 = today0 + 86400000;

  const filtered = useMemo(() => {
    let xs = loans.slice();
    if (tab === "active") xs = xs.filter(l => !l.returned_at);
    if (tab === "overdue") xs = xs.filter(l => isOverdue(l));
    if (tab === "dueToday") xs = xs.filter(l => {
      if (l.returned_at) return false;
      const t = new Date(l.due_at).getTime(); return t >= today0 && t < tomorrow0;
    });
    if (tab === "returned") xs = xs.filter(l => !!l.returned_at);
    if (q) {
      const qq = q.toLowerCase();
      xs = xs.filter(l => {
        const title = (l.loanable_title || l.title || "").toLowerCase();
        const who = displayMember(l).toLowerCase();
        return title.includes(qq) || who.includes(qq);
      });
    }
    return xs.sort((a, b) => new Date(b.created_at || b.borrowed_at || b.due_at).getTime() - new Date(a.created_at || a.borrowed_at || a.due_at).getTime());
  }, [loans, tab, q, today0, tomorrow0]);

  // group by borrower and compute overdue flags
  const groups = useMemo(() => {
    const m = new Map<string, { key: string, rows: any[], overdueCount: number }>();
    for (const l of filtered) {
      const key = displayMember(l);
      if (!m.has(key)) m.set(key, { key, rows: [], overdueCount: 0 });
      const g = m.get(key)!;
      g.rows.push(l);
      if (isOverdue(l)) g.overdueCount += 1;
    }
    return Array.from(m.values()).sort((a, b) => a.key.localeCompare(b.key));
  }, [filtered]);

  // build unique overdue members list from ALL loans (ignores tab/filter)
  const overdueMembers = useMemo(() => {
    const set = new Map<string, number>(); // name -> count
    for (const l of loans) if (isOverdue(l)) {
      const key = displayMember(l);
      set.set(key, (set.get(key) || 0) + 1);
    }
    return Array.from(set.entries()).sort((a, b) => b[1] - a[1]);
  }, [loans]);

  const counts = {
    total: loans.length,
    active: loans.filter(l => !l.returned_at).length,
    overdue: loans.filter(isOverdue).length,
    dueToday: loans.filter(l => {
      if (l.returned_at) return false;
      const t = new Date(l.due_at).getTime(); return t >= today0 && t < tomorrow0;
    }).length,
    returned: loans.filter(l => !!l.returned_at).length,
  };

  return (
    <div className="space-y-4">
      <h1 className="text-xl font-semibold">Loans — Librarian</h1>

      <div className="flex flex-wrap gap-2">
        <button className={`btn btn-sm ${tab === "active" ? "btn-primary" : ""}`} onClick={() => setTab("active")}>
          Active <span className="badge ml-2">{counts.active}</span>
        </button>
        <button className={`btn btn-sm ${tab === "overdue" ? "btn-primary" : ""}`} onClick={() => setTab("overdue")}>
          Overdue <span className="badge ml-2">{counts.overdue}</span>
        </button>
        <button className={`btn btn-sm ${tab === "dueToday" ? "btn-primary" : ""}`} onClick={() => setTab("dueToday")}>
          Due Today <span className="badge ml-2">{counts.dueToday}</span>
        </button>
        <button className={`btn btn-sm ${tab === "returned" ? "btn-primary" : ""}`} onClick={() => setTab("returned")}>
          Returned <span className="badge ml-2">{counts.returned}</span>
        </button>
        <div className="ml-auto">
          <input className="input input-bordered input-sm bg-base-200" placeholder="Search title or member…" value={q} onChange={e => setQ(e.target.value)} />
        </div>
      </div>

      {/* Overdue members panel */}
      {overdueMembers.length > 0 && (
        <div className="bg-base-200 rounded-box p-3">
          <div className="mb-2 font-medium">Overdue members</div>
          <div className="flex flex-wrap gap-2">
            {overdueMembers.map(([name, count]) => (
              <span key={name} className="badge badge-outline">
                {name} <span className="ml-1 text-error">({count})</span>
              </span>
            ))}
          </div>
        </div>
      )}

      {groups.length === 0 ? (
        <div className="alert"><span>No loans match.</span></div>
      ) : (
        <div className="space-y-4">
          {groups.map(g => (
            <div key={g.key} className="bg-base-200 rounded-box p-3">
              <div className="flex items-center justify-between mb-2">
                <div className="font-medium flex items-center gap-2">
                  <span className="truncate max-w-[32ch]">{g.key}</span>
                  {g.overdueCount > 0 && <span className="badge badge-outline text-error">Overdue {g.overdueCount}</span>}
                </div>
                <div className="text-sm opacity-70">{g.rows.filter((r: any) => !r.returned_at).length} active</div>
              </div>

              <div className="overflow-x-auto">
                {/* fixed layout keeps headers and cells aligned across all groups */}
                <table className="table table-sm table-fixed w-full">
                  <colgroup>
                    <col style={{ width: "45%" }} />
                    <col style={{ width: "16%" }} />
                    <col style={{ width: "16%" }} />
                    <col style={{ width: "12%" }} />
                    <col style={{ width: "10%" }} />
                  </colgroup>
                  <thead>
                    <tr>
                      <th>Title</th>
                      <th>Borrowed</th>
                      <th>Due</th>
                      <th>Status</th>
                      <th></th>
                    </tr>
                  </thead>
                  <tbody>
                    {g.rows.map((l: any) => {
                      const borrowedAt = l.borrowed_at || l.created_at;
                      const status = l.returned_at ? "Returned" : (isOverdue(l) ? "Overdue" : "Active");
                      return (
                        <tr key={l.id}>
                          <td className="truncate">{l.loanable_title || l.title}</td>
                          <td className="truncate">{fmt(borrowedAt)}</td>
                          <td className="truncate">{fmt(l.due_at)}</td>
                          <td className={`truncate ${status === "Overdue" ? "text-error" : ""}`}>{status}</td>
                          <td className="truncate">
                            {!l.returned_at && (
                              <button className="btn btn-xs" onClick={() => onReturn(l.id)} disabled={loading}>
                                Return
                              </button>
                            )}
                          </td>
                        </tr>
                      );
                    })}
                  </tbody>
                </table>
              </div>
            </div>
          ))}
        </div>
      )}


    </div>
  );
}
