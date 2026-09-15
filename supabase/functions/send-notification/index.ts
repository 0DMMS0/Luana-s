import { serve } from 'https://deno.land/std@0.224.0/http/server.ts'

type Payload={channel:'email'|'whatsapp';to:string;subject?:string;message:string}
serve(async req=>{
  const headers={'Access-Control-Allow-Origin':'*','Access-Control-Allow-Headers':'authorization, x-client-info, apikey, content-type','Content-Type':'application/json'}
  if(req.method==='OPTIONS') return new Response('ok',{headers})
  if(req.method!=='POST') return new Response('Method not allowed',{status:405})
  let body:Payload
  try{body=await req.json() as Payload}catch{return new Response(JSON.stringify({error:'Invalid JSON'}),{status:400,headers})}
  if(!body?.to||!body?.message||!['email','whatsapp'].includes(body.channel)) return new Response(JSON.stringify({error:'Invalid notification payload'}),{status:400,headers})
  if(body.channel==='email'){
    const apiKey=Deno.env.get('RESEND_API_KEY')
    if(!apiKey) return new Response(JSON.stringify({error:'RESEND_API_KEY is not configured'}),{status:503,headers})
    const r=await fetch('https://api.resend.com/emails',{method:'POST',headers:{Authorization:`Bearer ${Deno.env.get('RESEND_API_KEY')}`,'Content-Type':'application/json'},body:JSON.stringify({from:Deno.env.get('MAIL_FROM')??'Ikigai <onboarding@resend.dev>',to:[body.to],subject:body.subject??'Mensaje de Ikigai',text:body.message})})
    return new Response(await r.text(),{status:r.status,headers})
  }
  const token=Deno.env.get('WHATSAPP_TOKEN'),phone=Deno.env.get('WHATSAPP_PHONE_NUMBER_ID')
  if(!token||!phone) return new Response(JSON.stringify({error:'WhatsApp secrets are not configured'}),{status:503,headers})
  const r=await fetch(`https://graph.facebook.com/v20.0/${phone}/messages`,{method:'POST',headers:{Authorization:`Bearer ${token}`,'Content-Type':'application/json'},body:JSON.stringify({messaging_product:'whatsapp',to:body.to,type:'text',text:{body:body.message}})})
  return new Response(await r.text(),{status:r.status,headers})
})
