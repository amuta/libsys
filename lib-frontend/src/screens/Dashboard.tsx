import { useQuery } from "@tanstack/react-query";
import { listBooks } from "../api/books";
import { fetchLoans } from "../api/loans";
import { useOutletContext } from "react-router-dom";

const sod=(d:Date)=>{const x=new Date(d);x.setHours(0,0,0,0);return x;}
export default function Dashboard(){
  const { me } = (useOutletContext() as any) || { me:null };
const isLib = me?.role === "librarian";
const { data:books=[] } = useQuery({ queryKey:["books",""], queryFn:()=>listBooks("") });
const { data:loans=[] } = useQuery({
  queryKey:["loans", isLib ? "library" : "mine"],
  queryFn: () => fetchLoans(!isLib), // librarians see all, members see mine
});

  const active=loans.filter((l:any)=>!l.returned_at);
  const dueToday=active.filter((l:any)=>{const t=new Date(l.due_at).getTime();return t>=t0&&t<t1;});
  const overdue=active.filter((l:any)=> new Date(l.due_at).getTime()<now.getTime());
  return (
    <div className="p-6 space-y-6">
      <h1 className="text-xl font-semibold">Dashboard</h1>
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <Card title="Total books" value={books.length}/>
        <Card title="Borrowed (active)" value={active.length}/>
        <Card title="Due today" value={dueToday.length}/>
        <Card title="Overdue" value={overdue.length}/>
      </div>
    </div>
  );
}
function Card({title,value}:{title:string;value:number}){
  return <div className="stats shadow"><div className="stat"><div className="stat-title">{title}</div><div className="stat-value">{value}</div></div></div>;
}
