import { supabase } from './supabase-client.js'

export async function uploadGalleryImage(file, oldPath) {
  const safe = file.name.toLowerCase().replace(/[^a-z0-9.-]/g,'-')
  const path = `${crypto.randomUUID()}-${safe}`
  const uploaded = await supabase.storage.from('ikigai-gallery').upload(path,file,{upsert:false,contentType:file.type})
  if(uploaded.error) throw uploaded.error
  if(oldPath) await supabase.storage.from('ikigai-gallery').remove([oldPath])
  return {path, url:supabase.storage.from('ikigai-gallery').getPublicUrl(path).data.publicUrl}
}
