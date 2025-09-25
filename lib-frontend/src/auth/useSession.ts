import { useQuery } from "@tanstack/react-query";
import { whoami } from "../api/session";
export function useSession(){
  return useQuery({ queryKey:["me"], queryFn: whoami, retry:false });
}
