import { useEffect, useState } from "react";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { createBook, getBook, updateBook } from "../api/books";
import { searchGenres, searchPeople } from "../api/lookups";
import { useNavigate, useParams } from "react-router-dom";

const LANGS = [
  { code: "en", label: "English" },
  { code: "pt", label: "Português" },
  { code: "es", label: "Español" },
];

type Opt = { id: number; name: string };

export default function BookForm({ mode }:{ mode:"create"|"edit" }){
  const { id } = useParams(); const nav=useNavigate(); const qc=useQueryClient();

  // fields
  const [title,setTitle]=useState(""); 
  const [isbn,setIsbn]=useState(""); 
  const [language,setLang]=useState("en");
  const [authors,setAuthors]=useState<Opt[]>([]);
  const [genres,setGenres]=useState<Opt[]>([]);

  // search
  const [authorQ,setAuthorQ]=useState(""); 
  const [genreQ,setGenreQ]=useState("");
  const { data:authorOpts=[] } = useQuery({ queryKey:["authors",authorQ], queryFn:()=>authorQ?searchPeople(authorQ):Promise.resolve([]) });
  const { data:genreOpts=[] }  = useQuery({ queryKey:["genres",genreQ],  queryFn:()=>genreQ?searchGenres(genreQ):Promise.resolve([]) });

  // load for edit
  const { data:book } = useQuery({ queryKey:["book",id], queryFn:()=>getBook(Number(id!)), enabled: mode==="edit" });
  useEffect(()=>{ 
    if(book){
      setTitle(book.title||""); setIsbn(book.isbn||""); setLang(book.language||"en");
      setAuthors((book.authors||[]).map((a:any)=>({id:a.id,name:a.name})));
      setGenres((book.genres||[]).map((g:any)=>({id:g.id,name:g.name})));
    }
  },[book]);

  // feedback state
  const [errors,setErrors]=useState<string[]>([]);
  const [ok,setOk]=useState(false);

  const payload = { title, isbn, language, author_ids: authors.map(a=>a.id), genre_ids: genres.map(g=>g.id) };

  const m = useMutation({
    mutationFn:()=> mode==="create" ? createBook(payload) : updateBook(Number(id), payload),
    onSuccess:()=>{ 
      setErrors([]); setOk(true);
      qc.invalidateQueries({queryKey:["books"]});
      setTimeout(()=>nav("/books"), 800);
    },
    onError:(e:any)=>{
      const msgs = e?.response?.data?.messages as string[] | undefined;
      setErrors(msgs?.length ? msgs : ["Save failed"]);
    }
  });

  const addAuthor = (opt: Opt) => { if(!authors.some(a=>a.id===opt.id)) setAuthors([...authors, opt]); setAuthorQ(""); };
  const removeAuthor = (i:number)=> setAuthors(authors.filter(a=>a.id!==i));
  const addGenre  = (opt: Opt) => { if(!genres.some(g=>g.id===opt.id)) setGenres([...genres, opt]); setGenreQ(""); };
  const removeGenre = (i:number)=> setGenres(genres.filter(g=>g.id!==i));

  return (
    <div className="max-w-xl mx-auto p-6 space-y-5">
      {ok && (
        <div className="toast toast-top toast-end z-50">
          <div className="alert alert-success"><span>Saved.</span></div>
        </div>
      )}
      {errors.length>0 && (
        <div className="alert alert-error">
          <div>
            <div className="font-semibold mb-1">Please fix:</div>
            <ul className="list-disc ml-5 text-sm">
              {errors.map((e,i)=><li key={i}>{e}</li>)}
            </ul>
          </div>
        </div>
      )}

      <h1 className="text-xl font-semibold">{mode==="create"?"New Book":"Edit Book"}</h1>

      <label className="form-control">
        <div className="label"><span className="label-text">Title</span></div>
        <input className={`input input-bordered w-full ${errors.find(x=>/Title/i.test(x))?"input-error":""}`}
               placeholder="Title" value={title} onChange={e=>setTitle(e.target.value)} />
      </label>

      <div className="grid sm:grid-cols-2 gap-4">
        <label className="form-control">
          <div className="label"><span className="label-text">ISBN</span></div>
          <input className={`input input-bordered w-full ${errors.find(x=>/ISBN/i.test(x))?"input-error":""}`}
                 placeholder="ISBN" value={isbn} onChange={e=>setIsbn(e.target.value)} />
        </label>

        <label className="form-control">
          <div className="label"><span className="label-text">Language</span></div>
          <select className="select select-bordered w-full" value={language} onChange={e=>setLang(e.target.value)}>
            {LANGS.map(l=> <option key={l.code} value={l.code}>{l.label}</option>)}
          </select>
        </label>
      </div>

      {/* Authors */}
      <section className="space-y-2">
        <div className="label"><span className="label-text">Authors</span></div>
        <div className="flex flex-wrap gap-2">
          {authors.map(a=>(
            <div key={a.id} className="badge badge-outline gap-2">
              {a.name}
              <button className="btn btn-ghost btn-xs" onClick={()=>removeAuthor(a.id)}>✕</button>
            </div>
          ))}
          {authors.length===0 && <div className="text-sm opacity-60">None selected</div>}
        </div>
        <input className="input input-bordered w-full bg-base-200" placeholder="Search authors…" value={authorQ} onChange={e=>setAuthorQ(e.target.value)} />
        {!!authorQ && authorOpts.length>0 && (
          <div className="mt-2 flex flex-wrap gap-2">
            {authorOpts.map((o:any)=>(
              <button key={o.id} type="button"
                className={`btn btn-outline btn-sm ${authors.some(a=>a.id===o.id)?"btn-active":""}`}
                onClick={()=>addAuthor({id:o.id,name:o.name})}>
                {o.name}
              </button>
            ))}
          </div>
        )}
      </section>

      {/* Genres */}
      <section className="space-y-2">
        <div className="label"><span className="label-text">Genres</span></div>
        <div className="flex flex-wrap gap-2">
          {genres.map(g=>(
            <div key={g.id} className="badge badge-outline gap-2">
              {g.name}
              <button className="btn btn-ghost btn-xs" onClick={()=>removeGenre(g.id)}>✕</button>
            </div>
          ))}
          {genres.length===0 && <div className="text-sm opacity-60">None selected</div>}
        </div>
        <input className="input input-bordered w-full bg-base-200" placeholder="Search genres…" value={genreQ} onChange={e=>setGenreQ(e.target.value)} />
        {!!genreQ && genreOpts.length>0 && (
          <div className="mt-2 flex flex-wrap gap-2">
            {genreOpts.map((o:any)=>(
              <button key={o.id} type="button"
                className={`btn btn-outline btn-sm ${genres.some(g=>g.id===o.id)?"btn-active":""}`}
                onClick={()=>addGenre({id:o.id,name:o.name})}>
                {o.name}
              </button>
            ))}
          </div>
        )}
      </section>

      <div className="flex gap-2">
        <button className={`btn btn-primary ${m.isPending?"loading":""}`} onClick={()=>m.mutate()} disabled={m.isPending}>
          {mode==="create"?"Create":"Save"}
        </button>
        <button className="btn btn-ghost" onClick={()=>nav(-1)} disabled={m.isPending}>Cancel</button>
      </div>
    </div>
  );
}
