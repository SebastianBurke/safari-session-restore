# Safari Session Restore

A lightweight background utility that makes Safari restore your tabs when you close the window with the **red X button** — just like ⌘Q does.

---

## The Problem

On macOS, the red X button **closes the window** but doesn't quit Safari. When you reopen Safari, it opens a blank new window instead of your previous tabs, because no real quit ever happened — so session restore never triggered.

This is a macOS-wide behaviour and not a bug in Safari, but it's frustrating if you're used to closing apps with the red X.

## The Solution

A small shell script runs silently in the background and:

1. **Saves your open tab URLs** every 0.5 seconds to a local backup file
2. **Detects when the last Safari window is closed** via the red X
3. **Sends Safari a proper quit signal** so the session is cleanly ended
4. **Restores your tabs** the next time you open Safari, skipping pinned tabs that Safari already restores on its own

It runs via **launchd** — macOS's built-in process manager — so it starts automatically at login and runs with zero noticeable impact on performance.

---

## Install

Paste this in Terminal:

```bash
curl -s https://raw.githubusercontent.com/sebastianburke/safari-session-restore/main/install.sh | bash
```

That's it. Open Safari, close it with the red X, reopen it — your tabs will be there.

---

## Uninstall

```bash
curl -s https://raw.githubusercontent.com/sebastianburke/safari-session-restore/main/uninstall.sh | bash
```

This removes all files and stops the background process completely.

---

## How It Works

The installer creates two files:

- `~/safari-watcher.sh` — the shell script that watches Safari
- `~/Library/LaunchAgents/com.user.safariwatcher.plist` — the launchd config that keeps it running

It also creates `~/safari-tabs-backup.txt` while Safari is running, which stores your current tab URLs. This file is removed on uninstall.

---

## Requirements

- macOS (tested on macOS Ventura and later)
- Safari
- Terminal access

---

## FAQ

**Does this affect Safari's performance?**
No. The script sleeps for 0.5 seconds between each check. CPU and memory usage are negligible.

**What about private tabs?**
Private tabs are not saved by Safari's APIs, so they won't be included in the backup.

**What if I have multiple windows open?**
The current version restores tabs from all windows into a single window. Multiple window support may be added in a future version.

**Will this survive a restart?**
Yes. The launchd agent is configured to start automatically at login.

---

## License

MIT — do whatever you want with it.
