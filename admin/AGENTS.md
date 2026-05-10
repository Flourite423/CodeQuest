# Admin — Agent Knowledge Base

**Scope:** Vue 3 + Element Plus + Pinia management dashboard
**Pattern:** Composition API + `<script setup>` + SCSS

## STRUCTURE

```
admin/src/
├── main.ts           # Entry: createApp → router → pinia → mount
├── App.vue           # Root component
├── api/
│   └── index.ts      # Axios instance with interceptors
├── router/
│   └── index.ts      # Route definitions + auth guards
├── stores/
│   ├── auth.ts       # Auth state (token, user)
│   └── app.ts        # App state (sidebar, theme)
├── layouts/
│   └── default.vue   # Sidebar + topbar layout
├── views/
│   ├── login/        # Admin login
│   ├── dashboard/    # Stats overview
│   ├── courses/      # Course CRUD
│   ├── challenges/   # Challenge CRUD
│   ├── users/        # User management
│   ├── leaderboard/  # Rankings
│   ├── moderation/   # Content review
│   ├── settings/     # System config
│   └── error/        # 404 page
└── styles/
    ├── global.scss
    └── variables.scss
```

## WHERE TO LOOK

| Task | Location | Notes |
|------|----------|-------|
| Add page | `src/views/{name}/` | Create directory + SFC |
| Add route | `src/router/index.ts` | Register with auth meta |
| API call | `src/api/index.ts` | Add method, use in store/component |
| Add store | `src/stores/` | Pinia store with `defineStore` |
| Layout change | `src/layouts/default.vue` | Sidebar/topbar structure |

## CONVENTIONS

1. **Composition API** — Always use `<script setup>`
2. **TypeScript** — Type annotations on props, refs, function params
3. **Pinia** — All shared state in stores, never prop drilling
4. **Element Plus** — Use component library, avoid custom CSS when possible
5. **SCSS scoped** — Component styles with `scoped` attribute
6. **API centralization** — All HTTP through `src/api/index.ts`

## ANTI-PATTERNS

- **Never** call axios directly — use `src/api/index.ts`
- **Never** mutate store state outside actions
- **Never** use Options API — Composition API only
- **Never** hardcode colors — use Element Plus theme vars

## COMMANDS

```bash
npm run dev        # localhost:3000
npm run build      # vue-tsc + vite build
npm run lint       # ESLint --fix
npm run format     # Prettier
```

## NOTES

- Vite proxy: `/api` → `http://localhost:8080`
- Auth guard redirects unauthenticated to `/login`
- All management pages require authentication
