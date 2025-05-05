# DoomList ☠️  

**A terminal-based Todo List with a sense of urgency... because unfinished tasks = DOOM!**  

## Features  
**Priority levels** (Higher number = More important)  
**Deadline tracking** (Auto-priority boost when time's running out!)  
**Color-coded tasks** (Red = OVERDUE, Yellow = URGENT, Green = Chill)  
**Simple deletion** (Slay your tasks one by one)  

## Quick Start  
1. **Add a task**:  
   ```bash
   ./doomlist.sh add "Conquer the world" -p 3 -d "2025-12-31 23:59"
   ```
   - `-p`: Priority (default=1)  
   - `-d`: Deadline (e.g., "tomorrow 9AM")  

2. **View doom approaching**:  
   ```bash
   ./doomlist.sh view
   ```

3. **Delete a finished task** (to survive another day):  
   ```bash
   ./doomlist.sh delete 42
   ```

## Pro Tip  
> Use `watch -n 10 ./doomlist.sh view` to watch your doom in real-time!  

---  
**Your productivity apocalypse starts now.** 🔥  

*(Data saved in `~/.todolist` – no cloud, no fluff.)*
