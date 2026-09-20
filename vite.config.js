import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import path from 'node:path';
const source=path.resolve('src/main.jsx');
export default defineConfig({root:'redesign',envDir:path.resolve('.'),publicDir:path.resolve('public'),build:{outDir:path.resolve('dist'),emptyOutDir:true},plugins:[{name:'ikigai-source',resolveId(id){return id==='/src/main.jsx'?source:null} },react()],server:{fs:{allow:['..']}}});
