#!/usr/bin/env python3
"""
Item Organizer - Spellion
List view con nombre, categoría, descripción. Guarda todo a JSON.
"""

import tkinter as tk
from tkinter import ttk, messagebox, simpledialog
from PIL import Image, ImageTk
import os, json

ITEMS_DIR = os.path.normpath(os.path.join(os.path.dirname(__file__), "..", "assets", "textures", "items"))
DB_FILE = os.path.join(ITEMS_DIR, "_item_data.json")

CATEGORIES = [
    "Uncategorized", "Sword", "Axe", "Mace", "Bow", "Shield",
    "Helmet", "Armor", "Cloak", "Ring", "Amulet", "Potion",
    "Scroll", "Material", "Quest", "Misc"
]

PREVIEW_SIZE = 48

class ItemOrganizer:
    def __init__(self):
        self.root = tk.Tk()
        self.root.title("Spellion - Item Organizer")
        self.root.geometry("1100x700")
        self.root.configure(bg="#1a1a1a")

        self.items = []       # list of dicts: {file, name, category, desc}
        self.thumbnails = {}
        self.current_filter = "All"
        self.filtered_indices = []

        self._load_data()
        self._build_ui()
        self._apply_filter()
        self.root.protocol("WM_DELETE_WINDOW", self._on_close)
        self.root.mainloop()

    def _load_data(self):
        """Load PNG files and existing metadata"""
        if not os.path.isdir(ITEMS_DIR):
            messagebox.showerror("Error", f"Not found: {ITEMS_DIR}")
            self.root.destroy()
            return

        pngs = sorted(f for f in os.listdir(ITEMS_DIR) if f.lower().endswith(".png"))
        
        # Load existing DB
        db = {}
        if os.path.exists(DB_FILE):
            try:
                with open(DB_FILE) as fp:
                    db_data = json.load(fp)
                for entry in db_data:
                    db[entry["file"]] = entry
            except:
                pass

        self.items = []
        for f in pngs:
            info = db.get(f, {})
            self.items.append({
                "file": f,
                "name": info.get("name", f.replace(".png", "").replace("_", " ").title()),
                "category": info.get("category", "Uncategorized"),
                "desc": info.get("desc", ""),
            })

    def _thumb(self, f):
        if f not in self.thumbnails:
            try:
                img = Image.open(os.path.join(ITEMS_DIR, f)).convert("RGBA")
                img.thumbnail((PREVIEW_SIZE, PREVIEW_SIZE), Image.LANCZOS)
                # Square canvas
                canvas = Image.new("RGBA", (PREVIEW_SIZE, PREVIEW_SIZE), (30, 30, 40, 255))
                x = (PREVIEW_SIZE - img.width) // 2
                y = (PREVIEW_SIZE - img.height) // 2
                canvas.paste(img, (x, y), img)
                self.thumbnails[f] = ImageTk.PhotoImage(canvas)
            except:
                self.thumbnails[f] = None
        return self.thumbnails[f]

    def _build_ui(self):
        # ─── Top bar: filter + buttons ───
        top = tk.Frame(self.root, bg="#222", height=40)
        top.pack(fill="x")
        top.pack_propagate(False)

        tk.Label(top, text="Category:", fg="#aaa", bg="#222", font=("Segoe UI", 9)).pack(side="left", padx=(10, 5))

        self.filter_var = tk.StringVar(value="All")
        self.filter_menu = ttk.Combobox(top, textvariable=self.filter_var, values=["All"] + CATEGORIES,
                                         state="readonly", width=14)
        self.filter_menu.pack(side="left", padx=5)
        self.filter_menu.bind("<<ComboboxSelected>>", lambda e: self._apply_filter())

        tk.Button(top, text="Edit Selected", command=self._edit_selected,
                  bg="#3a5a8a", fg="white", relief="flat", padx=12).pack(side="right", padx=5)
        tk.Button(top, text="Move Up", command=self._move_up,
                  bg="#3a3a3a", fg="white", relief="flat", padx=10).pack(side="right", padx=2)
        tk.Button(top, text="Move Down", command=self._move_down,
                  bg="#3a3a3a", fg="white", relief="flat", padx=10).pack(side="right", padx=2)
        tk.Button(top, text="Save JSON", command=self._save_json,
                  bg="#4a6a3a", fg="white", relief="flat", padx=14).pack(side="right", padx=10)

        # ─── Treeview (list) ───
        tree_frame = tk.Frame(self.root, bg="#1a1a1a")
        tree_frame.pack(fill="both", expand=True, padx=8, pady=5)

        style = ttk.Style()
        style.theme_use("clam")
        style.configure("Treeview", background="#252530", foreground="#ddd", fieldbackground="#252530",
                        rowheight=54, font=("Segoe UI", 9))
        style.configure("Treeview.Heading", background="#333", foreground="#ccc", font=("Segoe UI", 9, "bold"))
        style.map("Treeview", background=[("selected", "#4a6a5a")])

        self.tree = ttk.Treeview(tree_frame, columns=("name", "category", "desc"), show="tree", selectmode="browse")
        self.tree.heading("#0", text="", anchor="w")
        self.tree.heading("name", text="Name", anchor="w")
        self.tree.heading("category", text="Category", anchor="w")
        self.tree.heading("desc", text="Description", anchor="w")

        self.tree.column("#0", width=PREVIEW_SIZE + 16, minwidth=PREVIEW_SIZE + 16, stretch=False)
        self.tree.column("name", width=200, minwidth=120)
        self.tree.column("category", width=120, minwidth=80)
        self.tree.column("desc", width=400, minwidth=100)

        vsb = ttk.Scrollbar(tree_frame, orient="vertical", command=self.tree.yview)
        self.tree.configure(yscrollcommand=vsb.set)
        self.tree.pack(side="left", fill="both", expand=True)
        vsb.pack(side="right", fill="y")

        self.tree.bind("<Double-1>", lambda e: self._edit_selected())
        self.tree.bind("<Up>", lambda e: self._on_key(e))
        self.tree.bind("<Down>", lambda e: self._on_key(e))

        # ─── Status bar ───
        self.status = tk.Label(self.root, text="", bg="#222", fg="#888", anchor="w", font=("Segoe UI", 8))
        self.status.pack(fill="x")

        # Global keys
        self.root.bind("<Control-s>", lambda e: self._save_json())
        self.root.bind("<Delete>", lambda e: self._delete_selected())

    def _apply_filter(self):
        self.current_filter = self.filter_var.get()
        # Clear tree
        for item in self.tree.get_children():
            self.tree.delete(item)

        self.filtered_indices = []
        for idx, item in enumerate(self.items):
            if self.current_filter == "All" or item["category"] == self.current_filter:
                self.filtered_indices.append(idx)
                thumb = self._thumb(item["file"])
                self.tree.insert("", "end", iid=str(idx),
                                 image=thumb if thumb else "",
                                 values=(item["name"], item["category"], item["desc"]))

        self.status.config(text=f"{len(self.filtered_indices)} items ({self.current_filter})  |  {len(self.items)} total")

    def _get_selected_idx(self):
        sel = self.tree.selection()
        if not sel:
            return None
        return int(sel[0])

    def _edit_selected(self):
        idx = self._get_selected_idx()
        if idx is None:
            return
        item = self.items[idx]
        dialog = EditDialog(self.root, item)
        if dialog.result:
            self.items[idx] = dialog.result
            self._apply_filter()

    def _move_up(self):
        sel = self._get_selected_idx()
        if sel is None:
            return
        # Find position in filtered list
        if sel in self.filtered_indices:
            pos = self.filtered_indices.index(sel)
            if pos > 0:
                other = self.filtered_indices[pos - 1]
                self.items[sel], self.items[other] = self.items[other], self.items[sel]
                self._apply_filter()
                self.tree.selection_set(str(sel))

    def _move_down(self):
        sel = self._get_selected_idx()
        if sel is None:
            return
        if sel in self.filtered_indices:
            pos = self.filtered_indices.index(sel)
            if pos < len(self.filtered_indices) - 1:
                other = self.filtered_indices[pos + 1]
                self.items[sel], self.items[other] = self.items[other], self.items[sel]
                self._apply_filter()
                self.tree.selection_set(str(sel))

    def _delete_selected(self):
        idx = self._get_selected_idx()
        if idx is None:
            return
        if messagebox.askyesno("Delete", f"Remove '{self.items[idx]['name']}' from project?"):
            f = self.items[idx]["file"]
            try:
                os.remove(os.path.join(ITEMS_DIR, f))
            except:
                pass
            self.items.pop(idx)
            self._apply_filter()

    def _on_key(self, event):
        sel = self._get_selected_idx()
        if sel is None:
            return
        if event.keysym == "Up":
            self._move_up()
        elif event.keysym == "Down":
            self._move_down()

    def _save_json(self):
        """Save all item metadata to JSON"""
        output = []
        for item in self.items:
            output.append({
                "file": item["file"],
                "name": item["name"],
                "category": item["category"],
                "desc": item["desc"],
            })
        try:
            with open(DB_FILE, "w", encoding="utf-8") as fp:
                json.dump(output, fp, indent=2, ensure_ascii=False)
            self.status.config(text=f"Saved {len(output)} items to _item_data.json")
            messagebox.showinfo("Saved", f"Item data saved to:\n{DB_FILE}")
        except Exception as e:
            messagebox.showerror("Error", str(e))

    def _on_close(self):
        if messagebox.askyesno("Exit", "Save changes?"):
            self._save_json()
        self.root.destroy()


class EditDialog:
    """Dialog for editing an item's name, category, description"""

    def __init__(self, parent, item):
        self.result = None
        dialog = tk.Toplevel(parent)
        dialog.title(f"Edit: {item['name']}")
        dialog.geometry("500x350")
        dialog.configure(bg="#222")
        dialog.transient(parent)
        dialog.grab_set()

        # Preview
        preview_frame = tk.Frame(dialog, bg="#222")
        preview_frame.pack(fill="x", padx=15, pady=10)

        try:
            img = Image.open(os.path.join(ITEMS_DIR, item["file"])).convert("RGBA")
            img.thumbnail((64, 64), Image.LANCZOS)
            canvas = Image.new("RGBA", (64, 64), (30, 30, 40, 255))
            x = (64 - img.width) // 2
            y = (64 - img.height) // 2
            canvas.paste(img, (x, y), img)
            photo = ImageTk.PhotoImage(canvas)
            tk.Label(preview_frame, image=photo, bg="#222").pack(side="left", padx=5)
            preview_frame.photo = photo
        except:
            pass

        tk.Label(preview_frame, text=item["file"], fg="#888", bg="#222", font=("Segoe UI", 8)).pack(side="left", padx=10)

        # Form
        form = tk.Frame(dialog, bg="#222")
        form.pack(fill="both", expand=True, padx=15, pady=5)

        def make_row(label, default, is_combo=False):
            tk.Label(form, text=label, fg="#ccc", bg="#222", font=("Segoe UI", 9), anchor="w").pack(fill="x", pady=(8, 2))

            if is_combo:
                var = tk.StringVar(value=default)
                widget = ttk.Combobox(form, textvariable=var, values=CATEGORIES, state="readonly")
                widget.pack(fill="x")
                return var, widget
            else:
                var = tk.StringVar(value=default)
                widget = tk.Entry(form, textvariable=var, bg="#333", fg="#ddd", insertbackground="#ddd",
                                  font=("Segoe UI", 9), relief="flat")
                widget.pack(fill="x", ipady=3)
                return var, widget

        name_var, _ = make_row("Name:", item["name"])
        cat_var, _ = make_row("Category:", item["category"], is_combo=True)

        tk.Label(form, text="Description:", fg="#ccc", bg="#222", font=("Segoe UI", 9), anchor="w").pack(fill="x", pady=(8, 2))
        desc_text = tk.Text(form, height=4, bg="#333", fg="#ddd", insertbackground="#ddd",
                            font=("Segoe UI", 9), relief="flat", wrap="word")
        desc_text.pack(fill="both", expand=True, ipady=2)
        desc_text.insert("1.0", item["desc"])

        # Buttons
        btn_frame = tk.Frame(dialog, bg="#222")
        btn_frame.pack(fill="x", padx=15, pady=10)

        def save():
            self.result = {
                "file": item["file"],
                "name": name_var.get().strip(),
                "category": cat_var.get(),
                "desc": desc_text.get("1.0", "end-1c").strip(),
            }
            dialog.destroy()

        def cancel():
            dialog.destroy()

        tk.Button(btn_frame, text="Save", command=save, bg="#4a6a3a", fg="white", relief="flat", padx=20).pack(side="right", padx=5)
        tk.Button(btn_frame, text="Cancel", command=cancel, bg="#3a3a3a", fg="white", relief="flat", padx=20).pack(side="right", padx=5)

        dialog.wait_window()


if __name__ == "__main__":
    ItemOrganizer()
