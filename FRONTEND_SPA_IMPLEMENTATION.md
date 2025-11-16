# Frontend SPA Implementation Guide

This document contains the complete frontend code changes needed to convert marimo to a Single Page Application (SPA) with tab management.

## Overview

The frontend will be converted to use:
- **React Router** for client-side routing
- **Tab-based UI** for managing multiple notebooks
- **State preservation** for each notebook tab
- **Path-based URLs**: `/notebook/path/to/file.py`

## Architecture

```
App (with BrowserRouter)
├── Route: / → HomePage
└── Route: /notebook/* → NotebookRouter
    └── TabManager
        ├── Tab UI (clickable tabs)
        └── NotebookTab[] (one per open file)
            ├── Own Jotai Provider
            ├── Own WebSocket connection
            └── MarimoApp component
```

## Dependencies

Add to `package.json`:

```json
{
  "dependencies": {
    "react-router-dom": "^6.20.0"
  }
}
```

## File Structure

```
frontend/src/
├── App.tsx (NEW)
├── routes/
│   ├── HomePage.tsx (existing home-page.tsx)
│   └── NotebookRouter.tsx (NEW)
├── components/
│   ├── TabManager.tsx (NEW)
│   └── NotebookTab.tsx (NEW)
├── hooks/
│   └── useNotebookLoader.ts (NEW)
└── main.tsx (MODIFY)
```

## Implementation

### 1. Main Entry Point (`src/main.tsx`)

**MODIFY**: Change from direct mount to router-based app

```typescript
// src/main.tsx
import { createRoot } from "react-dom/client";
import { App } from "./App";

const container = document.getElementById("root");
if (!container) {
  throw new Error("Root element not found");
}

const root = createRoot(container);
root.render(<App />);
```

---

### 2. Root App Component (`src/App.tsx`)

**NEW FILE**

```typescript
// src/App.tsx
import { BrowserRouter, Routes, Route, Navigate } from "react-router-dom";
import { HomePage } from "./routes/HomePage";
import { NotebookRouter } from "./routes/NotebookRouter";
import { ThemeProvider } from "./theme/ThemeProvider";

export const App: React.FC = () => {
  // Read mount config from window (set by backend on initial load)
  const mountConfig = (window as any).__MARIMO_MOUNT_CONFIG__;

  if (!mountConfig) {
    return <div>Error: Mount configuration not found</div>;
  }

  return (
    <ThemeProvider config={mountConfig.config}>
      <BrowserRouter>
        <Routes>
          {/* Home page - workspace browser */}
          <Route path="/" element={<HomePage />} />

          {/* Notebook viewer/editor with tab management */}
          <Route path="/notebook/*" element={<NotebookRouter />} />

          {/* Catch-all redirect */}
          <Route path="*" element={<Navigate to="/" replace />} />
        </Routes>
      </BrowserRouter>
    </ThemeProvider>
  );
};
```

---

### 3. Home Page Route (`src/routes/HomePage.tsx`)

**RENAME** from `src/components/pages/home-page.tsx`

**MODIFY**: Update navigation to use React Router instead of `<a>` tags

```typescript
// src/routes/HomePage.tsx
import { useNavigate } from "react-router-dom";
// ... other imports

export const HomePage: React.FC = () => {
  const navigate = useNavigate();

  const handleOpenNotebook = (filePath: string) => {
    // Navigate to notebook route instead of opening new tab
    navigate(`/notebook/${filePath}`);
  };

  return (
    <div className="home-page">
      {/* Workspace files */}
      <div className="workspace-files">
        {files.map((file) => (
          <div
            key={file.path}
            className="file-item"
            onClick={() => handleOpenNotebook(file.path)}
          >
            {file.name}
          </div>
        ))}
      </div>

      {/* New notebook button */}
      <button onClick={() => handleOpenNotebook("__new__")}>
        New Notebook
      </button>
    </div>
  );
};
```

---

### 4. Notebook Router (`src/routes/NotebookRouter.tsx`)

**NEW FILE**: Manages routing and tab state

```typescript
// src/routes/NotebookRouter.tsx
import { useEffect, useState } from "react";
import { useLocation, useNavigate } from "react-router-dom";
import { TabManager } from "../components/TabManager";

export interface NotebookTab {
  id: string;           // Unique tab ID
  filePath: string;     // Path to notebook file
  title: string;        // Display name
  isActive: boolean;    // Currently visible
}

export const NotebookRouter: React.FC = () => {
  const location = useLocation();
  const navigate = useNavigate();
  const [tabs, setTabs] = useState<NotebookTab[]>([]);

  // Parse file path from URL: /notebook/path/to/file.py → path/to/file.py
  const currentFilePath = location.pathname.replace(/^\/notebook\//, "");

  useEffect(() => {
    if (!currentFilePath) {
      return;
    }

    // Check if tab already exists
    const existingTab = tabs.find((tab) => tab.filePath === currentFilePath);

    if (existingTab) {
      // Activate existing tab
      setTabs((prevTabs) =>
        prevTabs.map((tab) => ({
          ...tab,
          isActive: tab.id === existingTab.id,
        }))
      );
    } else {
      // Create new tab
      const newTab: NotebookTab = {
        id: `tab-${Date.now()}-${Math.random()}`,
        filePath: currentFilePath,
        title: extractFileName(currentFilePath),
        isActive: true,
      };

      setTabs((prevTabs) => [
        ...prevTabs.map((tab) => ({ ...tab, isActive: false })),
        newTab,
      ]);
    }
  }, [currentFilePath]);

  const handleTabClick = (tabId: string) => {
    const tab = tabs.find((t) => t.id === tabId);
    if (tab) {
      navigate(`/notebook/${tab.filePath}`);
    }
  };

  const handleTabClose = (tabId: string) => {
    const tabIndex = tabs.findIndex((t) => t.id === tabId);
    const closingActiveTab = tabs[tabIndex]?.isActive;

    const newTabs = tabs.filter((t) => t.id !== tabId);
    setTabs(newTabs);

    // Navigate to another tab or home
    if (closingActiveTab && newTabs.length > 0) {
      const nextTab = newTabs[Math.max(0, tabIndex - 1)];
      navigate(`/notebook/${nextTab.filePath}`);
    } else if (newTabs.length === 0) {
      navigate("/");
    }
  };

  return (
    <TabManager
      tabs={tabs}
      onTabClick={handleTabClick}
      onTabClose={handleTabClose}
    />
  );
};

function extractFileName(filePath: string): string {
  if (filePath.startsWith("__new__")) {
    return "New Notebook";
  }
  return filePath.split("/").pop() || filePath;
}
```

---

### 5. Tab Manager Component (`src/components/TabManager.tsx`)

**NEW FILE**: Renders tab UI and manages tab components

```typescript
// src/components/TabManager.tsx
import { NotebookTab as NotebookTabComponent } from "./NotebookTab";
import type { NotebookTab } from "../routes/NotebookRouter";
import "./TabManager.css";

interface Props {
  tabs: NotebookTab[];
  onTabClick: (tabId: string) => void;
  onTabClose: (tabId: string) => void;
}

export const TabManager: React.FC<Props> = ({
  tabs,
  onTabClick,
  onTabClose,
}) => {
  return (
    <div className="tab-manager">
      {/* Tab bar */}
      <div className="tab-bar">
        {tabs.map((tab) => (
          <div
            key={tab.id}
            className={`tab ${tab.isActive ? "active" : ""}`}
            onClick={() => onTabClick(tab.id)}
          >
            <span className="tab-title">{tab.title}</span>
            <button
              className="tab-close"
              onClick={(e) => {
                e.stopPropagation();
                onTabClose(tab.id);
              }}
            >
              ×
            </button>
          </div>
        ))}
      </div>

      {/* Tab content - ALL tabs are mounted, hidden ones use display: none */}
      <div className="tab-content">
        {tabs.map((tab) => (
          <div
            key={tab.id}
            className="tab-panel"
            style={{ display: tab.isActive ? "block" : "none" }}
          >
            <NotebookTabComponent filePath={tab.filePath} />
          </div>
        ))}
      </div>
    </div>
  );
};
```

**Styles (`src/components/TabManager.css`)**:

```css
/* src/components/TabManager.css */
.tab-manager {
  display: flex;
  flex-direction: column;
  height: 100vh;
}

.tab-bar {
  display: flex;
  gap: 2px;
  background: var(--gray-2);
  border-bottom: 1px solid var(--gray-4);
  padding: 4px;
  overflow-x: auto;
}

.tab {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 12px;
  background: var(--gray-3);
  border-radius: 4px 4px 0 0;
  cursor: pointer;
  user-select: none;
  white-space: nowrap;
  transition: background 0.15s;
}

.tab:hover {
  background: var(--gray-4);
}

.tab.active {
  background: var(--background);
  border: 1px solid var(--gray-4);
  border-bottom: none;
}

.tab-title {
  font-size: 13px;
  color: var(--text-color);
}

.tab-close {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 20px;
  height: 20px;
  border: none;
  background: transparent;
  border-radius: 4px;
  cursor: pointer;
  font-size: 18px;
  line-height: 1;
  color: var(--text-muted);
}

.tab-close:hover {
  background: var(--red-3);
  color: var(--red-11);
}

.tab-content {
  flex: 1;
  overflow: hidden;
}

.tab-panel {
  height: 100%;
  overflow: auto;
}
```

---

### 6. Notebook Tab Component (`src/components/NotebookTab.tsx`)

**NEW FILE**: Loads and renders a single notebook

```typescript
// src/components/NotebookTab.tsx
import { useEffect, useState } from "react";
import { Provider as JotaiProvider } from "jotai";
import { useNotebookLoader } from "../hooks/useNotebookLoader";
import { MarimoApp } from "../core/MarimoApp";
import { createStore } from "../core/store";
import { NetworkingClient } from "../core/network/NetworkingClient";

interface Props {
  filePath: string;
}

export const NotebookTab: React.FC<Props> = ({ filePath }) => {
  const { config, loading, error } = useNotebookLoader(filePath);
  const [store, setStore] = useState<any>(null);

  useEffect(() => {
    if (!config) return;

    // Create isolated store for this notebook
    const networkingClient = new NetworkingClient({
      version: config.version,
      serverToken: config.serverToken,
    });

    const notebookStore = createStore({
      networking: networkingClient,
      filename: config.filename,
      mode: config.mode,
      config: config.config,
      appConfig: config.appConfig,
    });

    setStore(notebookStore);

    // Cleanup on unmount
    return () => {
      // Close WebSocket when tab is truly unmounted (not just hidden)
      networkingClient.disconnect();
    };
  }, [config]);

  if (loading) {
    return <div className="loading">Loading notebook...</div>;
  }

  if (error) {
    return <div className="error">Error: {error}</div>;
  }

  if (!store || !config) {
    return null;
  }

  return (
    <JotaiProvider store={store}>
      <MarimoApp />
    </JotaiProvider>
  );
};
```

---

### 7. Notebook Loader Hook (`src/hooks/useNotebookLoader.ts`)

**NEW FILE**: Fetches notebook config from backend API

```typescript
// src/hooks/useNotebookLoader.ts
import { useEffect, useState } from "react";

interface NotebookConfig {
  filename: string;
  mode: "edit" | "read";
  version: string;
  serverToken: string;
  config: any;
  configOverrides: any;
  appConfig: any;
  view: any;
  fileKey: string;
}

interface UseNotebookLoaderResult {
  config: NotebookConfig | null;
  loading: boolean;
  error: string | null;
}

export function useNotebookLoader(filePath: string): UseNotebookLoaderResult {
  const [config, setConfig] = useState<NotebookConfig | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;

    const loadNotebook = async () => {
      setLoading(true);
      setError(null);

      try {
        // Call the new backend API endpoint
        const response = await fetch(`/api/notebook/load/${filePath}`);

        if (!response.ok) {
          throw new Error(`Failed to load notebook: ${response.statusText}`);
        }

        const data = await response.json();

        if (!cancelled) {
          setConfig(data);
          setLoading(false);
        }
      } catch (err) {
        if (!cancelled) {
          setError(err instanceof Error ? err.message : "Unknown error");
          setLoading(false);
        }
      }
    };

    loadNotebook();

    return () => {
      cancelled = true;
    };
  }, [filePath]);

  return { config, loading, error };
}
```

---

## State Preservation Strategy

### How It Works

1. **Each tab has its own Jotai store instance**
   - Isolated state per notebook
   - No interference between tabs

2. **Tabs remain mounted when inactive**
   - Use CSS `display: none` to hide
   - All state, WebSocket, and outputs preserved
   - Switching tabs is instant (just toggle visibility)

3. **WebSocket lifecycle**
   - One WebSocket per tab
   - Stays connected even when tab is hidden
   - Only disconnects when tab is closed (removed from `tabs` array)

4. **Memory management**
   - Consider limiting max number of tabs (e.g., 10)
   - Optionally implement "unload" feature for inactive tabs
   - Could add "reload" button for tabs with stale state

### Performance Considerations

- **Initial load**: Only loads config via API (fast)
- **Tab switching**: Instant (just CSS display toggle)
- **Memory**: Each tab holds full notebook state
- **Optimization**: Could implement lazy loading or tab unloading

---

## Backend Integration Points

### API Endpoints Used

1. **`GET /`**
   - Returns SPA shell with home page mount config
   - Frontend React Router handles all navigation

2. **`GET /api/notebook/load/{file_path:path}`**
   - Returns JSON with notebook configuration
   - Used by `useNotebookLoader` hook

3. **`WS /ws?session_id=...&file=...`**
   - Existing WebSocket endpoint (no changes needed)
   - Each tab creates its own connection

### Service Worker (Public Files)

The service worker injection needs to be handled per tab. You have two options:

**Option 1**: Inject on first load per tab (in `NotebookTab.tsx`)

```typescript
useEffect(() => {
  if ('serviceWorker' in navigator && config) {
    const notebookId = encodeURIComponent(config.fileKey);
    navigator.serviceWorker.register('./public-files-sw.js?v=2')
      .then(registration => {
        registration.active?.postMessage({ notebookId });
      });
  }
}, [config]);
```

**Option 2**: Modify service worker to support multiple notebooks

Update service worker to track multiple notebook IDs and route based on request context.

---

## Migration Checklist

### Backend (in marimo codebase)
- [x] Create `marimo/_server/api/endpoints/notebook.py`
- [x] Add `get_mount_config_dict()` to `templates.py`
- [x] Modify `GET /` in `assets.py` to always serve home page
- [x] Register notebook router in `api/router.py`
- [ ] Test API endpoint with curl/Postman
- [ ] Verify WebSocket still works with file parameter

### Frontend (in your separate project)
- [ ] Install `react-router-dom`
- [ ] Create `App.tsx` with routes
- [ ] Create `NotebookRouter.tsx` for tab management
- [ ] Create `TabManager.tsx` component
- [ ] Create `NotebookTab.tsx` component
- [ ] Create `useNotebookLoader.ts` hook
- [ ] Modify `main.tsx` entry point
- [ ] Update `HomePage.tsx` navigation
- [ ] Add CSS styles for tabs
- [ ] Test opening multiple notebooks
- [ ] Test tab switching preserves state
- [ ] Test closing tabs
- [ ] Test WebSocket connections
- [ ] Test service worker integration

---

## Testing Plan

### Unit Tests
- [ ] Test `useNotebookLoader` hook with mock API
- [ ] Test `NotebookRouter` tab creation/switching
- [ ] Test `TabManager` UI interactions

### Integration Tests
- [ ] Test full flow: home → open notebook → open second notebook
- [ ] Test tab switching preserves cell outputs
- [ ] Test WebSocket reconnection
- [ ] Test closing active tab navigates correctly

### E2E Tests
- [ ] Test opening notebooks from home page
- [ ] Test multiple tabs with different files
- [ ] Test tab state preservation
- [ ] Test browser back/forward navigation
- [ ] Test direct URL access: `/notebook/path/to/file.py`

---

## Future Enhancements

1. **Tab Persistence**
   - Save open tabs to localStorage
   - Restore on page reload

2. **Tab Reordering**
   - Drag-and-drop to reorder tabs
   - Keyboard shortcuts (Ctrl+Tab)

3. **Tab Context Menu**
   - Right-click: Close Others, Close to Right, etc.

4. **Split View**
   - Show multiple notebooks side-by-side

5. **Tab Groups**
   - Group related notebooks

6. **Performance**
   - Lazy load inactive tabs (unload from DOM)
   - Implement tab "hibernation" for memory savings

---

## Troubleshooting

### Issue: Tabs don't preserve state when switching

**Check:**
- Ensure `display: none` is used (not unmounting)
- Verify Jotai store is not being recreated
- Check WebSocket stays connected

### Issue: API returns 404

**Check:**
- Backend router registered correctly
- File path encoding (spaces, special chars)
- File exists and has correct permissions

### Issue: Multiple WebSocket connections fail

**Check:**
- Backend session manager supports multiple sessions
- Each tab uses unique session ID
- No connection limit on backend

---

## Example Usage

```typescript
// User flow:
// 1. Visit http://localhost:2718/
// 2. Click "data_analysis.py" → Navigates to /notebook/data_analysis.py
// 3. Click home, then "test.py" → Navigates to /notebook/test.py
// 4. Now has 2 tabs open
// 5. Click first tab → Navigates to /notebook/data_analysis.py
// 6. All state preserved, instant switch
// 7. Close tab → Removes from tabs array, navigates to remaining tab
```

---

## Summary

This implementation provides:
- ✅ True SPA architecture with React Router
- ✅ VS Code-style tab management
- ✅ State preservation for all open notebooks
- ✅ Path-based URLs: `/notebook/path/to/file.py`
- ✅ Clean separation of concerns
- ✅ Minimal backend changes
- ✅ No backward compatibility needed

The frontend code is provided in this document and can be integrated into your separate frontend project.
