import { useState } from "react";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { listBooks, deleteBook, addCopy, borrow } from "../api/books";
import { Link, useOutletContext, useNavigate } from "react-router-dom";

export default function Books(){
  const [q,setQ]=useState("");
  const [msg,setMsg]=useState<string|null>(null);
  const [borrowedIds,setBorrowedIds]=useState<Set<number>>(new Set());
  const qc=useQueryClient(); const nav = useNavigate();
  const { data:books=[] } = useQuery({ queryKey:["books",q], queryFn:()=>listBooks(q) });
  const me = (useOutletContext() as any)?.me; const isLib = me?.role==="librarian";

  const mDel=useMutation({ mutationFn:(id:number)=>deleteBook(id), onSuccess:()=>qc.invalidateQueries({queryKey:["books"]}) });
  const mCopy=useMutation({ mutationFn:({id,barcode}:{id:number,barcode:string})=>addCopy(id,barcode), onSuccess:()=>qc.invalidateQueries({queryKey:["books"]}) });
  const mBorrow=useMutation({
    mutationFn:(id:number)=>borrow(id),
    onSuccess:(data, id)=>{
      setBorrowedIds(prev=>new Set(prev).add(id as number));
      setMsg("Borrowed. View it on Loans.");
      qc.invalidateQueries({queryKey:["books"]});
      qc.invalidateQueries({queryKey:["loans"]});
    },
    onError:(e:any)=>{
      const code = e?.response?.status;
      const err  = e?.response?.data?.error;
      if(code===422 && err==="not_available") setMsg("Not available right now.");
      else if(code===409 && err==="already_borrowed") setMsg("You already borrowed this title.");
      else setMsg("Borrow failed.");
    }
  });

  const canBorrow = (b:any)=> !isLib && b.available_copies>0 && !borrowedIds.has(b.id);

  const Avail = ({n}:{n:number}) => (
    n>0
      ? <span className="font-semibold text-primary">{n}</span>
      : <span className="badge badge-outline text-error">Out</span>
  );

  return (
    <div className="p-6 space-y-4">
      {msg && (
        <div className="toast toast-top toast-end z-50">
          <div className="alert alert-info">
            <span>{msg}</span>
            <button className="btn btn-xs" onClick={()=>{ setMsg(null); nav("/loans"); }}>Go to Loans</button>
            <button className="btn btn-xs btn-ghost" onClick={()=>setMsg(null)}>Close</button>
          </div>
        </div>
      )}

      <div className="flex gap-2">
        <input className="input input-bordered flex-1 bg-base-200" placeholder="Search title/author/genre" value={q} onChange={e=>setQ(e.target.value)} />
        {isLib && <Link to="/books/new" className="btn btn-primary">New</Link>}
      </div>

      {/* Mobile cards */}
      <div className="md:hidden grid grid-cols-1 gap-3">
        {books.map((b:any)=>(
          <div key={b.id} className="card bg-base-200 shadow">
            <div className="card-body gap-2">
              <h2 className="card-title">{b.title}</h2>
              <div className="text-sm opacity-70">ISBN: {b.isbn || "—"}</div>
              <div className="text-sm">{b.genres?.map((g:any)=>g.name).join(", ")}</div>
              <div className="flex items-center gap-2">
                <Avail n={b.available_copies}/>
              </div>
              <div className="card-actions justify-end">
                {!isLib && (
                  <button
                    className="btn btn-sm"
                    disabled={!canBorrow(b) || mBorrow.isPending}
                    onClick={()=>mBorrow.mutate(b.id)}
                  >
                    {borrowedIds.has(b.id) ? "Borrowed" : "Borrow"}
                  </button>
                )}
                {isLib && (
                  <>
                    <Link to={`/books/${b.id}/edit`} className="btn btn-sm">Edit</Link>
                    <button className="btn btn-sm" onClick={()=>{ const barcode=prompt("Barcode?"); if(barcode) mCopy.mutate({id:b.id,barcode}); }}>Add Copy</button>
                    <button className="btn btn-sm btn-error" onClick={()=>mDel.mutate(b.id)}>Delete</button>
                  </>
                )}
              </div>
            </div>
          </div>
        ))}
      </div>

      {/* Desktop table */}
      <div className="hidden md:block overflow-x-auto bg-base-200 rounded-box p-2">
        <table className="table table-zebra">
          <thead><tr><th>Title</th><th>ISBN</th><th>Genres</th><th>Avail</th><th></th></tr></thead>
          <tbody>
            {books.map((b:any)=>(
              <tr key={b.id}>
                <td>{b.title}</td>
                <td>{b.isbn}</td>
                <td>{b.genres?.map((g:any)=>g.name).join(", ")}</td>
                <td><Avail n={b.available_copies}/></td>
                <td className="flex gap-2">
                  {!isLib && (
                    <button
                      className="btn btn-sm"
                      disabled={!canBorrow(b) || mBorrow.isPending}
                      onClick={()=>mBorrow.mutate(b.id)}
                    >
                      {borrowedIds.has(b.id) ? "Borrowed" : "Borrow"}
                    </button>
                  )}
                  {isLib && <>
                    <Link to={`/books/${b.id}/edit`} className="btn btn-sm">Edit</Link>
                    <button className="btn btn-sm" onClick={()=>{ const barcode=prompt("Barcode?"); if(barcode) mCopy.mutate({id:b.id,barcode}); }}>Add Copy</button>
                    <button className="btn btn-sm btn-error" onClick={()=>mDel.mutate(b.id)}>Delete</button>
                  </>}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
