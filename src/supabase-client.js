import { createClient } from '@supabase/supabase-js'

const url = import.meta.env.VITE_SUPABASE_URL
const publishableKey = import.meta.env.VITE_SUPABASE_PUBLISHABLE_KEY

function createLocalClient() {
  let session = null
  const listeners = new Set()
  const notify = () => listeners.forEach((listener) => listener('SIGNED_IN', session))
  const query = () => {
    const builder = {
      select: () => builder,
      insert: () => builder,
      upsert: () => builder,
      update: () => builder,
      delete: () => builder,
      eq: () => builder,
      neq: () => builder,
      gte: () => builder,
      lte: () => builder,
      order: () => builder,
      limit: () => builder,
      single: async () => ({ data: null, error: null }),
      then: (resolve) => Promise.resolve({ data: [], count: 0, error: null }).then(resolve),
    }
    return builder
  }
  return {
    auth: {
      async getSession() { return { data: { session } } },
      async getUser() { return { data: { user: session?.user ?? null } } },
      onAuthStateChange(callback) { listeners.add(callback); return { data: { subscription: { unsubscribe: () => listeners.delete(callback) } } } },
      async signInWithPassword({ email, password }) {
        if (!email || !password) return { error: { message: 'Ingresa correo y contraseña.' } }
        session = { user: { id: 'local-demo-user', email } }
        notify()
        return { data: { session }, error: null }
      },
      async signOut() { session = null; listeners.forEach((listener) => listener('SIGNED_OUT', null)); return { error: null } },
    },
    from: query,
    channel: () => {
      const realtime = { on: () => realtime, subscribe: () => realtime }
      return realtime
    },
    removeChannel: () => true,
    storage: { from: () => ({ upload: async () => ({ data: null, error: null }), remove: async () => ({ error: null }), getPublicUrl: (path) => ({ data: { publicUrl: path } }) }) },
  }
}

export const supabase = url && publishableKey
  ? createClient(url, publishableKey)
  : createLocalClient()
