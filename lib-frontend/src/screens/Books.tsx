import { useState } from "react";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { listBooks, deleteBook, addCopy, borrow } from "../api/books";
import { Link, useOutletContext } from "react-router-dom";
export default function Books(){
  const [q,setQ]=useState(""); const qc=useQueryClient();
  const { data:books } = useQuery({ queryKey:["books",q], queryFn:()=>listBooks(q) });
  const me = (useOutletContext() as any)?.me; const isLib = me?.role==="librarian";
  const mDel=useMutation({ mutationFn:(id:number)=>deleteBook(id), onSuccess:()=>qc.invalidateQueries({queryKey:["books"]}) });
  const mCopy=useMutation({ mutationFn:({id,barcode}:{id:number,barcode:string})=>addCopy(id,barcode), onSuccess:()=>qc.invalidateQueries({queryKey:["books"]}) });
  const mBorrow=useMutation({ mutationFn:(id:number)=>borrow(id), onSuccess:()=>qc.invalidateQueries({queryKey:["books"]}) });
  return (
    <div className="p-6 space-y-4">
      <div className="flex gap-2">
        <input className="border p-2 flex-1" placeholder="Search title/author/genre" value={q} onChange={e=>setQ(e.target.value)} />
        {isLib && <Link to="/books/new" className="px-3 py-2 bg-black text-white">New</Link>}
      </div>
      <table className="w-full text-sm">
        <thead><tr className="text-left">
          <th className="p-2">Title</th><th className="p-2">ISBN</th><th className="p-2">Genres</th><th className="p-2">Avail</th><th className="p-2"></th>
        </tr></thead>
        <tbody>
          {books?.map((b:any)=>(
            <tr key={b.id} className="border-t">
              <td className="p-2">{b.title}</td>
              <td className="p-2">{b.isbn}</td>
              <td className="p-2">{b.genres?.map((g:any)=>g.name).join(", ")}</td>
              <td className="p-2">{b.available_copies}</td>
              <td className="p-2 flex gap-2">
                {!isLib && <button className="px-2 py-1 border" onClick={()=>mBorrow.mutate(b.id)}>Borrow</button>}
                {isLib && <>
                  <Link to={`/books/${b.id}/edit`} className="px-2 py-1 border">Edit</Link>
                  <button className="px-2 py-1 border" onClick={()=>{ const barcode=prompt("Barcode?"); if(barcode) mCopy.mutate({id:b.id,barcode}); }}>Add Copy</button>
                  <button className="px-2 py-1 border" onClick={()=>mDel.mutate(b.id)}>Delete</button>
                </>}
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
