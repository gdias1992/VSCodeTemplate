---
applyTo: '**/*.js, **/*.jsx, **/*.ts, **/*.tsx'
---
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

## � Toast Notifications

Use Sonner for displaying toast notifications to provide feedback on system actions.

### When to Use Toasts

| Use Case | Toast Type | Example |
| :--- | :--- | :--- |
| Successful mutation (create, update, delete) | `toast.success()` | "Profile saved successfully" |
| API or validation error | `toast.error()` | "Failed to save profile" |
| Important informational message | `toast.info()` | "Session expires in 5 minutes" |
| Non-critical warning | `toast.warning()` | "Some fields are incomplete" |

### When NOT to Use Toasts

- Loading states — use loading spinners or skeletons instead
- Form validation errors — display inline near the field
- Critical errors that block the user — use error boundaries or error pages
- Confirmations that require user decision — use modals or dialogs

### Usage Pattern

```tsx
import { toast } from 'sonner';

// ✅ Show toast after async operations
const handleSubmit = async (data: FormData) => {
  try {
    await updateProfile.mutateAsync(data);
    toast.success('Profile saved successfully');
  } catch {
    toast.error('Failed to save profile');
  }
};

// ✅ With descriptions for more context
toast.success('Changes saved', {
  description: 'Your profile has been updated.',
});

// ✅ With action buttons
toast.error('Failed to delete', {
  action: {
    label: 'Retry',
    onClick: () => handleDelete(),
  },
});
```

### Toast Guidelines

- Keep messages concise (3-7 words)
- Use sentence case, not title case
- Avoid technical jargon — write for users, not developers
- Don't stack multiple toasts for related actions

---

## 🚨 Handling HTTP 422 Validation Errors

When a form submission fails server-side validation, Laravel returns an HTTP 422 (Unprocessable Entity) response. Handle these errors by mapping them to the correct form fields for inline display.

### Laravel 422 Response Structure

Laravel validation errors follow a consistent structure:

```json
{
  "message": "The given data was invalid.",
  "errors": {
    "email": ["The email field is required.", "The email must be a valid email address."],
    "password": ["The password must be at least 8 characters."],
    "profile.phone": ["The phone format is invalid."]
  }
}
```

### TypeScript Types for Validation Errors

```tsx
// ✅ Define types for API error responses
interface ValidationErrorResponse {
  message: string;
  errors: Record<string, string[]>;
}

interface ApiError {
  response?: {
    status: number;
    data: ValidationErrorResponse;
  };
}

// Type guard to check for validation errors
function isValidationError(error: unknown): error is ApiError {
  return (
    typeof error === 'object' &&
    error !== null &&
    'response' in error &&
    (error as ApiError).response?.status === 422
  );
}
```

### Mapping Errors to React Hook Form

Use `setError` from react-hook-form to display server validation errors inline:

```tsx
import { useForm } from 'react-hook-form';
import { toast } from 'sonner';

interface ProfileFormData {
  email: string;
  full_name: string;
  profile: {
    phone: string;
  };
}

function ProfileForm() {
  const { register, handleSubmit, setError, formState: { errors } } = useForm<ProfileFormData>();

  const onSubmit = async (data: ProfileFormData) => {
    try {
      await updateProfile.mutateAsync(data);
      toast.success('Profile saved');
    } catch (error) {
      if (isValidationError(error)) {
        // Map each server error to the corresponding form field
        const serverErrors = error.response.data.errors;
        Object.entries(serverErrors).forEach(([field, messages]) => {
          // Handle nested fields like "profile.phone" → ["profile", "phone"]
          const fieldPath = field.split('.').join('.') as keyof ProfileFormData;
          setError(fieldPath, {
            type: 'server',
            message: messages[0], // Show first error message
          });
        });
      } else {
        // Non-validation error — show toast
        toast.error('Failed to save profile');
      }
    }
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <Input {...register('email')} error={errors.email?.message} />
      <Input {...register('full_name')} error={errors.full_name?.message} />
      <Input {...register('profile.phone')} error={errors.profile?.phone?.message} />
      <Button type="submit">Save</Button>
    </form>
  );
}
```

### Reusable Error Mapping Utility

Extract validation error handling into a reusable helper:

```tsx
// utils/form-errors.ts
import { UseFormSetError, FieldValues, Path } from 'react-hook-form';

/**
 * Maps Laravel 422 validation errors to react-hook-form fields.
 * Returns true if errors were mapped, false otherwise.
 */
export function mapServerErrorsToForm<T extends FieldValues>(
  error: unknown,
  setError: UseFormSetError<T>
): boolean {
  if (!isValidationError(error)) {
    return false;
  }

  const serverErrors = error.response.data.errors;
  
  Object.entries(serverErrors).forEach(([field, messages]) => {
    setError(field as Path<T>, {
      type: 'server',
      message: messages[0],
    });
  });

  return true;
}

// Usage in component
const onSubmit = async (data: FormData) => {
  try {
    await mutation.mutateAsync(data);
    toast.success('Saved successfully');
  } catch (error) {
    if (!mapServerErrorsToForm(error, setError)) {
      toast.error('An unexpected error occurred');
    }
  }
};
```

### Integration with TanStack Query Mutations

```tsx
// ✅ Handle validation errors in mutation callbacks
const updateProfile = useMutation({
  mutationFn: (data: ProfileFormData) => api.put('/profile', data),
  onError: (error) => {
    if (!mapServerErrorsToForm(error, setError)) {
      toast.error('Failed to update profile');
    }
  },
  onSuccess: () => {
    toast.success('Profile updated');
    queryClient.invalidateQueries({ queryKey: ['profile'] });
  },
});
```

### Displaying Field Errors

```tsx
// ✅ Input component with error display
interface InputProps extends React.ComponentProps<'input'> {
  label: string;
  error?: string;
}

function Input({ label, error, ...props }: InputProps) {
  return (
    <div className="field">
      <label>{label}</label>
      <input {...props} aria-invalid={!!error} />
      {error && <span className="field-error">{error}</span>}
    </div>
  );
}
```

### 422 Error Handling Guidelines

| Scenario | Approach |
| :--- | :--- |
| Field-specific validation error | Map to form field with `setError`, display inline |
| Multiple errors on one field | Show only the first message to avoid clutter |
| Nested field errors (`profile.phone`) | Parse dot notation to match form structure |
| Non-validation API error (500, 403, etc.) | Show toast notification |
| Network error | Show toast with retry option |

### What NOT to Do

```tsx
// ❌ Don't show validation errors as toasts
catch (error) {
  if (isValidationError(error)) {
    toast.error(error.response.data.message); // Bad: no field context
  }
}

// ❌ Don't ignore server validation errors
catch (error) {
  toast.error('Something went wrong'); // Bad: user doesn't know what to fix
}

// ❌ Don't block form submission on client-side only
// Always handle server-side validation as the source of truth
```

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

## 📂 Folder Structure

See [STRUCTURE_FRONTEND.md](../../STRUCTURE_FRONTEND.md) for full details.

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
- [ ] Pages are thin composition layers (no business logic)
- [ ] Features never import from other features
- [ ] Toast notifications used for async operation feedback (success/error)
- [ ] HTTP 422 validation errors mapped to form fields (not shown as toasts)