import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { myLoans, returnLoan } from "../api/loans";
import { useOutletContext } from "react-router-dom";
export default function Loans(){
  const { data:loans } = useQuery({ queryKey:["loans"], queryFn: myLoans });
  const me = (useOutletContext() as any)?.me; const isLib = me?.role==="librarian";
  const qc=useQueryClient(); const m = useMutation({ mutationFn:(id:number)=>returnLoan(id), onSuccess:()=>{ qc.invalidateQueries({queryKey:["loans"]}); }});
  return (
    <div className="p-6">
      <h1 className="text-xl font-semibold mb-4">Loans</h1>
      <table className="w-full text-sm">
        <thead><tr className="text-left"><th className="p-2">Title</th><th className="p-2">Due</th><th className="p-2">Status</th><th className="p-2"></th></tr></thead>
        <tbody>
          {loans?.map((l:any)=>(
            <tr key={l.id} className="border-t">
              <td className="p-2">{l.loanable_title}</td>
              <td className="p-2">{l.due_at}</td>
              <td className="p-2">{l.returned_at? "Returned" : (new Date(l.due_at) < new Date() ? "Overdue" : "Active")}</td>
              <td className="p-2">
                {isLib && !l.returned_at && <button className="px-2 py-1 border" onClick={()=>m.mutate(l.id)}>Return</button>}
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
