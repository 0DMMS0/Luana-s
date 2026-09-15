import { supabase } from './supabase-client.js'
export async function sendNotification(payload){const {data,error}=await supabase.functions.invoke('send-notification',{body:payload});if(error)throw error;return data}
