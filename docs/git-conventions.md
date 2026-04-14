# Git Conventions

This document outlines the standardized branch naming conventions and commit message formats for the Paytm Wallet project.

---

## Branch Naming Convention

All branches should follow a structured naming pattern to maintain consistency and clarity across the repository.

### Format

```bash
<type>/<short-description>
```

### Branch Types

| Branch Type | Purpose | Example |
|------------|---------|---------|
| `feature/*` | New features or enhancements | `feature/add-payment-gateway` |
| `fix/*` | Bug fixes for existing functionality | `fix/transaction-timeout-error` |
| `chore/*` | Maintenance tasks, dependency/configurations, refactoring | `chore/update-dependencies` |
| `hotfix/*` | Critical production fixes that need immediate deployment | `hotfix/security-patch` |
| `docs/*` | Documentation updates or additions | `docs/api-reference` |

### Naming Guidelines

- Use **lowercase** letters only
- Use **hyphens** (`-`) to separate words, not underscores or spaces
- Keep descriptions **short and descriptive** (2-4 words)
- Use **present tense** verbs (e.g., `add`, `fix`, `update`)

### Examples

✅ **Good:**

- `feature/wallet-balance-display`
- `fix/login-validation-error`
- `chore/refactor-auth-service`
- `hotfix/payment-processing-crash`
- `docs/setup-instructions`

❌ **Bad:**

- `Feature/WalletBalance` (incorrect casing)
- `fix_login_error` (underscores instead of hyphens)
- `feature/this-is-a-very-long-branch-name-that-describes-everything` (too long)
- `bugfix/issue` (use `fix/*` instead of `bugfix/*`)

---

## Commit Message Format

Commit messages should be clear, concise, and follow a consistent structure to maintain a readable git history.

### Format

```bash
<type>(<scope>): <subject>
```

### Components

#### 1. Type (Required)

The type describes the nature of the change:

| Type | Description | Example |
|------|-------------|---------|
| `feat` | A new feature | `feat(wallet): add transaction history filter` |
| `fix` | A bug fix | `fix(auth): resolve token expiration issue` |
| `docs` | Documentation changes | `docs(readme): update installation steps` |
| `style` | Code style changes (formatting, missing semicolons, etc.) | `style(components): format button component` |
| `refactor` | Code refactoring without changing functionality | `refactor(services): simplify payment service logic` |
| `perf` | Performance improvements | `perf(api): optimize database queries` |
| `test` | Adding or updating tests | `test(auth): add unit tests for login` |
| `chore` | Maintenance tasks, dependency updates | `chore(deps): update flutter to 3.x` |
| `build` | Changes to build system or dependencies | `build(gradle): update android build config` |
| `ci` | CI/CD configuration changes | `ci(github): add automated testing workflow` |
| `revert` | Reverting a previous commit | `revert: revert "feat(wallet): add feature X"` |

#### 2. Scope (Optional)

The scope specifies the area of the codebase affected (e.g., `auth`, `wallet`, `api`, `ui`).

#### 3. Subject (Required)

- Use **imperative mood** ("add" not "added" or "adds")
- **Lowercase** first letter
- **No period** at the end
- Keep it **under 50 characters**

#### Sample Commit

```bash
feat(wallet): add balance refresh button
```

---
