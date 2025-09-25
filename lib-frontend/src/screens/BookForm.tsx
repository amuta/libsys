import { useEffect, useState } from "react";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { createBook, getBook, updateBook } from "../api/books";
import { searchGenres, searchPeople } from "../api/lookups";
import { useNavigate, useParams } from "react-router-dom";
export default function BookForm({ mode }:{ mode:"create"|"edit" }){
  const { id } = useParams(); const nav=useNavigate(); const qc=useQueryClient();
  const [title,setTitle]=useState(""); const [isbn,setIsbn]=useState(""); const [language,setLang]=useState("");
  const [authorIds,setAuthorIds]=useState<number[]>([]); const [genreIds,setGenreIds]=useState<number[]>([]);
  const { data:book } = useQuery({ queryKey:["book",id], queryFn:()=>getBook(Number(id!)), enabled: mode==="edit" });
  useEffect(()=>{ if(book){ setTitle(book.title); setIsbn(book.isbn||""); setLang(book.language||""); setAuthorIds(book.authors?.map((a:any)=>a.id)||[]); setGenreIds(book.genres?.map((g:any)=>g.id)||[]); }},[book]);
  const m = useMutation({
    mutationFn:()=> mode==="create"
      ? createBook({ title, isbn, language, author_ids:authorIds, genre_ids:genreIds })
      : updateBook(Number(id), { title, isbn, language, author_ids:authorIds, genre_ids:genreIds }),
    onSuccess:()=>{ qc.invalidateQueries({queryKey:["books"]}); nav("/books"); }
  });
  const [authorQ,setAuthorQ]=useState(""); const [genreQ,setGenreQ]=useState("");
  const { data:authorOpts } = useQuery({ queryKey:["authors",authorQ], queryFn:()=>authorQ?searchPeople(authorQ):Promise.resolve([]) });
  const { data:genreOpts }  = useQuery({ queryKey:["genres",genreQ],  queryFn:()=>genreQ?searchGenres(genreQ):Promise.resolve([]) });
  const toggle=(arr:number[],id:number)=> arr.includes(id)?arr.filter(x=>x!==id):[...arr,id];
  return (
    <div className="max-w-xl mx-auto p-6 space-y-4">
      <h1 className="text-xl font-semibold">{mode==="create"?"New Book":"Edit Book"}</h1>
      <input className="w-full border p-2" placeholder="Title" value={title} onChange={e=>setTitle(e.target.value)} />
      <input className="w-full border p-2" placeholder="ISBN" value={isbn} onChange={e=>setIsbn(e.target.value)} />
      <input className="w-full border p-2" placeholder="Language" value={language} onChange={e=>setLang(e.target.value)} />
      <div>
        <label className="block text-sm mb-1">Authors</label>
        <input className="w-full border p-2 mb-2" placeholder="Search authors…" value={authorQ} onChange={e=>setAuthorQ(e.target.value)} />
        <div className="flex flex-wrap gap-2">
          {authorOpts?.map((a:any)=>(
            <button key={a.id} type="button" className={`px-2 py-1 border ${authorIds.includes(a.id)?"bg-black text-white":""}`} onClick={()=>setAuthorIds(toggle(authorIds,a.id))}>{a.name}</button>
          ))}
        </div>
      </div>
      <div>
        <label className="block text-sm mb-1">Genres</label>
        <input className="w-full border p-2 mb-2" placeholder="Search genres…" value={genreQ} onChange={e=>setGenreQ(e.target.value)} />
        <div className="flex flex-wrap gap-2">
          {genreOpts?.map((g:any)=>(
            <button key={g.id} type="button" className={`px-2 py-1 border ${genreIds.includes(g.id)?"bg-black text-white":""}`} onClick={()=>setGenreIds(toggle(genreIds,g.id))}>{g.name}</button>
          ))}
        </div>
      </div>
      <button className="px-3 py-2 bg-black text-white" onClick={()=>m.mutate()} disabled={m.isPending}>{mode==="create"?"Create":"Save"}</button>
      {m.error && <p className="text-red-600 text-sm">Save failed</p>}
    </div>
  );
}
