# Todo Service Integration Guide

## Overview

The TodoService provides a QML singleton for managing todo items with both online (Supabase) and offline (SQLite) synchronization.

## Setup

### 1. Start the Bun API Server

```bash
cd bunservice
bun run dev
```

The server will start on http://localhost:3001

### 2. Import TodoService in QML

```qml
import qs.services

// TodoService is now available as a singleton
```

## API Reference

### getAllTodos(callback)

Retrieves all todos from both online and offline sources.

**Callback receives:**

```javascript
{
    online: [...],    // Todos from Supabase
    offline: [...],   // Todos from SQLite
    unsynced: [...]   // Todos pending sync to Supabase
}
```

**Example:**

```qml
TodoService.getAllTodos(function(response, error) {
    if (error) {
        console.error("Error:", error);
        return;
    }

    var onlineTodos = response.online || [];
    var offlineTodos = response.offline || [];
    console.log("Loaded", onlineTodos.length, "online todos");
});
```

### createTodo(todoData, callback)

Creates a new todo item.

**Parameters:**

```javascript
todoData = {
  title: "Required string",
  description: "Optional string",
  status: "pending|ongoing|completed|archived", // optional, defaults to "pending"
  is_completed: false, // optional, defaults to false
};
```

**Example:**

```qml
var newTodo = {
    title: "Buy groceries",
    description: "Milk, bread, eggs",
    status: "pending"
};

TodoService.createTodo(newTodo, function(response, error) {
    if (error) {
        console.error("Create failed:", error);
        return;
    }
    console.log("Created todo:", response.id);
});
```

### updateTodo(id, todoData, callback)

Updates an existing todo item.

**Parameters:**

- `id`: String UUID of the todo to update
- `todoData`: Object with fields to update (same as createTodo)

**Example:**

```qml
var updates = {
    is_completed: true,
    status: "completed"
};

TodoService.updateTodo(todoId, updates, function(response, error) {
    if (error) {
        console.error("Update failed:", error);
        return;
    }
    console.log("Updated todo:", response.id);
});
```

### deleteTodo(id, callback)

Deletes a todo item by ID.

**Example:**

```qml
TodoService.deleteTodo(todoId, function(response, error) {
    if (error) {
        console.error("Delete failed:", error);
        return;
    }
    console.log("Deleted todo:", todoId);
});
```

### nukeAllTodos(callback)

**⚠️ WARNING:** Deletes ALL todos from both online and offline databases.

**Example:**

```qml
TodoService.nukeAllTodos(function(response, error) {
    if (error) {
        console.error("Nuke failed:", error);
        return;
    }
    console.log("All todos deleted");
});
```

## Data Structure

### Todo Object

```javascript
{
    id: "uuid-string",           // Auto-generated UUID
    title: "string",             // Required
    description: "string",       // Optional
    status: "pending|ongoing|completed|archived", // Default: "pending"
    is_completed: false,         // Boolean, default: false
    created_at: "2024-01-01T00:00:00.000Z", // ISO timestamp
    updated_at: "2024-01-01T00:00:00.000Z"  // ISO timestamp
}
```

## Error Handling

All callbacks follow the pattern: `function(response, error)`

**On Success:**

- `response`: Contains the result data
- `error`: null

**On Error:**

- `response`: null
- `error`: String describing the error

## Database Synchronization

The service automatically handles:

1. **Online First**: Attempts to use Supabase when available
2. **Offline Fallback**: Uses SQLite when Supabase is unavailable
3. **Auto Sync**: Syncs offline changes to Supabase when reconnected
4. **Conflict Resolution**: Last-write-wins for conflicting updates

## Environment Variables

Create `bunservice/.env`:

```
SUPABASE_URL=your_supabase_url
SUPABASE_KEY=your_supabase_anon_key
PORT=3001
```

## Troubleshooting

### Service Not Available

- Ensure the Bun server is running on port 3001
- Check that TodoService.qml is in the services/ directory
- Verify qs.services import is registered

### Database Connection Issues

- Check Supabase credentials in .env
- Verify network connectivity
- Check server logs for detailed errors

### QML Import Errors

- Ensure QtQuick and QtQuick.Controls are available
- Check that XMLHttpRequest is accessible in your QML environment

## Example Usage

See `examples/TodoExample.qml` for a complete working example with:

- Todo creation form
- Todo list display
- Update/delete operations
- Status indicators
- Error handling
