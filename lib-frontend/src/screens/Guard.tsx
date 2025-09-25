import { Outlet, useNavigate, useLocation } from "react-router-dom";
import { useEffect } from "react";
import { useSession } from "../auth/useSession";
export default function Guard(){
  const { data, isLoading } = useSession(); // retry:false already set
  const nav = useNavigate(); const loc = useLocation();
  useEffect(()=>{
    if(!isLoading && data === null){
      nav("/login?next="+encodeURIComponent(loc.pathname));
    }
  },[isLoading, data, loc.pathname, nav]);
  if(isLoading) return <div className="p-6">Loading…</div>;
  return <Outlet context={{ me: data }} />;
}
