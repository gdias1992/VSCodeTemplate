# 🧹 Clean React — Best Practices & KISS Principles

> Guidelines for writing clean, maintainable, and simple React code.

---

## 🎯 Core Principles

| Principle | Description |
| :--- | :--- |
| **KISS** | Keep It Simple, Stupid. Favor simplicity over cleverness. |
| **DRY** | Don't Repeat Yourself. Extract reusable logic. |
| **SRP** | Single Responsibility. One component, one job. |
| **Composition** | Build complex UIs from small, focused pieces. |
| **Explicit > Implicit** | Code should be obvious, not clever. |

---

## 📦 Component Design

### Keep Components Small

```tsx
// ❌ Too much responsibility
function UserProfile({ user }) {
  const [isEditing, setIsEditing] = useState(false);
  const [formData, setFormData] = useState(user);
  // ... 200 lines of mixed concerns
}

// ✅ Split by responsibility
function UserProfile({ user }) {
  return (
    <div>
      <UserAvatar user={user} />
      <UserInfo user={user} />
      <UserActions userId={user.id} />
    </div>
  );
}
```

### One Component Per File

- Each component lives in its own file
- Name file same as component: `UserCard.tsx`
- Colocate related files: `UserCard.test.tsx`, `UserCard.module.css`

### Prefer Functional Components

```tsx
// ✅ Simple, readable, hooks-ready
function Button({ children, onClick }) {
  return <button onClick={onClick}>{children}</button>;
}
```

---

## 🏷️ Naming Conventions

| Type | Convention | Example |
| :--- | :--- | :--- |
| Components | PascalCase | `UserCard`, `LoginForm` |
| Hooks | camelCase with `use` prefix | `useAuth`, `useDebounce` |
| Event handlers | `handle` + Event | `handleClick`, `handleSubmit` |
| Booleans | `is`, `has`, `should` prefix | `isLoading`, `hasError` |
| Constants | SCREAMING_SNAKE_CASE | `MAX_RETRIES`, `API_URL` |

---

## 🎣 Hooks Best Practices

### Custom Hooks for Reusable Logic

```tsx
// ✅ Extract logic into custom hooks
function useToggle(initial = false) {
  const [value, setValue] = useState(initial);
  const toggle = useCallback(() => setValue(v => !v), []);
  return [value, toggle];
}

// Usage
const [isOpen, toggleOpen] = useToggle();
```

### Keep useEffect Simple

```tsx
// ❌ Multiple concerns in one effect
useEffect(() => {
  fetchUser();
  trackPageView();
  setupWebSocket();
}, []);

// ✅ Separate effects by concern
useEffect(() => { fetchUser(); }, [userId]);
useEffect(() => { trackPageView(); }, []);
useEffect(() => { return setupWebSocket(); }, []);
```

### Avoid Unnecessary Dependencies

```tsx
// ❌ Object recreated every render
useEffect(() => {
  doSomething(options);
}, [options]); // options = { a: 1 } recreated each render

// ✅ Use primitives or useMemo
const memoizedOptions = useMemo(() => ({ a: 1 }), []);
useEffect(() => {
  doSomething(memoizedOptions);
}, [memoizedOptions]);
```

---

## 🧩 Props & State

### Destructure Props

```tsx
// ❌ Repetitive
function Card(props) {
  return <div className={props.className}>{props.children}</div>;
}

// ✅ Clean
function Card({ className, children }) {
  return <div className={className}>{children}</div>;
}
```

### Keep State Close to Where It's Used

```tsx
// ❌ State lifted too high
function App() {
  const [searchQuery, setSearchQuery] = useState(''); // Only used in SearchBar
  return <SearchBar query={searchQuery} setQuery={setSearchQuery} />;
}

// ✅ State where it belongs
function SearchBar() {
  const [query, setQuery] = useState('');
  return <input value={query} onChange={e => setQuery(e.target.value)} />;
}
```

### Derive State, Don't Sync

```tsx
// ❌ Syncing derived state
const [items, setItems] = useState([]);
const [count, setCount] = useState(0);
useEffect(() => setCount(items.length), [items]);

// ✅ Derive during render
const [items, setItems] = useState([]);
const count = items.length; // Computed, not stored
```

---

## 🎨 JSX Patterns

### Early Returns for Conditional Rendering

```tsx
// ❌ Nested ternaries
function UserCard({ user, isLoading, error }) {
  return isLoading ? <Spinner /> : error ? <Error /> : <Card>{user.name}</Card>;
}

// ✅ Early returns
function UserCard({ user, isLoading, error }) {
  if (isLoading) return <Spinner />;
  if (error) return <Error message={error} />;
  return <Card>{user.name}</Card>;
}
```

### Avoid Inline Object/Array Literals in JSX

```tsx
// ❌ New object every render, breaks memoization
<Component style={{ margin: 10 }} items={[1, 2, 3]} />

// ✅ Define outside or memoize
const style = { margin: 10 };
const items = [1, 2, 3];
<Component style={style} items={items} />
```

### Use Fragments to Avoid Extra DOM Nodes

```tsx
// ❌ Unnecessary wrapper
return (
  <div>
    <Header />
    <Main />
  </div>
);

// ✅ Fragment
return (
  <>
    <Header />
    <Main />
  </>
);
```

---

## 🔄 Data Fetching

### Use TanStack Query (or Similar)

```tsx
// ✅ Declarative, handles loading/error/caching
function UserList() {
  const { data, isLoading, error } = useQuery({
    queryKey: ['users'],
    queryFn: fetchUsers,
  });

  if (isLoading) return <Spinner />;
  if (error) return <Error message={error.message} />;
  return <List items={data} />;
}
```

### Avoid Fetching in useEffect When Possible

```tsx
// ❌ Manual fetch with complex state
const [data, setData] = useState(null);
const [loading, setLoading] = useState(true);
const [error, setError] = useState(null);

useEffect(() => {
  fetchData()
    .then(setData)
    .catch(setError)
    .finally(() => setLoading(false));
}, []);

// ✅ Use a data-fetching library
const { data, isLoading, error } = useQuery({ queryKey: ['data'], queryFn: fetchData });
```

---

## ⚡ Performance

### Memoize Expensive Computations

```tsx
// ✅ Only recompute when dependencies change
const sortedItems = useMemo(
  () => items.sort((a, b) => a.name.localeCompare(b.name)),
  [items]
);
```

### Memoize Callbacks Passed to Children

```tsx
// ✅ Stable reference prevents child re-renders
const handleClick = useCallback(() => {
  doSomething(id);
}, [id]);

return <Button onClick={handleClick} />;
```

### Use React.memo Sparingly

```tsx
// ✅ Only for components that re-render often with same props
const ExpensiveList = memo(function ExpensiveList({ items }) {
  return items.map(item => <ExpensiveItem key={item.id} item={item} />);
});
```

> **Rule:** Profile first. Optimize only when there's a measurable problem.

---

## 🚫 Anti-Patterns to Avoid

| Anti-Pattern | Why It's Bad |
| :--- | :--- |
| Prop drilling 5+ levels | Use Context or state management |
| Giant monolithic components | Hard to test, maintain, reuse |
| Business logic in components | Extract to hooks or services |
| Mutating state directly | React won't detect changes |
| Index as key for dynamic lists | Causes rendering bugs |
| Premature optimization | Adds complexity without benefit |
| Over-abstracting too early | Creates unnecessary indirection |

---

## 📝 TypeScript Tips

### Define Props with Interfaces

```tsx
interface ButtonProps {
  variant: 'primary' | 'secondary';
  children: React.ReactNode;
  onClick?: () => void;
}

function Button({ variant, children, onClick }: ButtonProps) {
  return <button className={variant} onClick={onClick}>{children}</button>;
}
```

### Use `ComponentProps` for Extending Native Elements

```tsx
interface ButtonProps extends React.ComponentProps<'button'> {
  variant: 'primary' | 'secondary';
}

function Button({ variant, className, ...props }: ButtonProps) {
  return <button className={`${variant} ${className}`} {...props} />;
}
```

### Barrel Exports

```tsx
// components/ui/index.ts
export { Button } from './Button';
export { Input } from './Input';
export { Modal } from './Modal';
```

---

## ✅ Quick Checklist

- [ ] Component has single responsibility
- [ ] State is as close to usage as possible
- [ ] Derived values are computed, not synced
- [ ] Effects are separated by concern
- [ ] No prop drilling beyond 2-3 levels
- [ ] Event handlers are named `handleX`
- [ ] Expensive computations are memoized
- [ ] Keys are stable and unique (not index for dynamic lists)
- [ ] TypeScript types are explicit
- [ ] No commented-out code committed