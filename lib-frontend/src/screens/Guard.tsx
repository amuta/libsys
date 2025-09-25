import { useEffect } from "react";
import { useNavigate, useLocation } from "react-router-dom";
import { useSession } from "../auth/useSession";
import Layout from "../components/Layout";

export default function Guard(){
  const { data, isLoading } = useSession();
  const nav = useNavigate(); const loc = useLocation();
  useEffect(()=>{
    if(!isLoading && data === null){
      nav("/login?next="+encodeURIComponent(loc.pathname));
    }
  },[isLoading, data, loc.pathname, nav]);

  if (isLoading) return <div className="p-6">Loading…</div>;
  return <Layout />;
}
