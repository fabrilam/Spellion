#!/usr/bin/env python3
"""
Inventory Slot Mapper - Click to define slots on the inventory backdrop.
Left click: mark slot top-left -> drag to bottom-right -> release marks slot.
Right click on a slot: remove it.
Saves to _inventory_layout.json
"""

import tkinter as tk
from PIL import Image, ImageTk
import json, os

BASE = os.path.normpath(os.path.join(os.path.dirname(__file__), ".."))
IMG_PATH = os.path.join(BASE, "assets", "saved_references", "inventory.png")
OUT_PATH = os.path.join(BASE, "assets", "textures", "items", "_inventory_layout.json")

class SlotMapper:
    def __init__(self):
        self.root = tk.Tk()
        self.root.title("Inventory Slot Mapper")

        self.img = Image.open(IMG_PATH).convert("RGBA")
        self.tk_img = ImageTk.PhotoImage(self.img)
        self.scale = 1.0
        self.slots = []  # [(x1,y1,x2,y2,type)]
        self.dragging = False
        self.drag_start = None
        self.drag_type = "grid"

        # Load existing if any
        if os.path.exists(OUT_PATH):
            try:
                with open(OUT_PATH) as f:
                    self.slots = json.load(f)
            except:
                self.slots = []

        canvas_frame = tk.Frame(self.root)
        canvas_frame.pack(side="left", fill="both", expand=True)

        self.canvas = tk.Canvas(canvas_frame, cursor="crosshair")
        self.canvas.pack(fill="both", expand=True)
        self.canvas.create_image(0, 0, image=self.tk_img, anchor="nw")

        # Controls
        ctrl = tk.Frame(self.root, width=200)
        ctrl.pack(side="right", fill="y", padx=5, pady=5)

        tk.Label(ctrl, text="Slot Type:", font=("Arial", 10, "bold")).pack(anchor="w", pady=(0, 5))
        self.type_var = tk.StringVar(value="equip")
        for t in ["equip", "grid", "inventory"]:
            tk.Radiobutton(ctrl, text=t.title(), variable=self.type_var, value=t).pack(anchor="w")

        tk.Label(ctrl, text="", pady=10).pack()
        tk.Label(ctrl, text="Slots:", font=("Arial", 9, "bold")).pack(anchor="w")
        self.slot_listbox = tk.Listbox(ctrl, height=15, width=25)
        self.slot_listbox.pack(fill="both", expand=True, pady=5)
        self._update_listbox()

        tk.Button(ctrl, text="Delete Selected", command=self._delete_selected, bg="#6a3a3a", fg="white").pack(fill="x", pady=2)
        tk.Button(ctrl, text="Clear All", command=self._clear_all, bg="#3a3a3a", fg="white").pack(fill="x", pady=2)
        tk.Button(ctrl, text="Save JSON", command=self._save, bg="#3a6a3a", fg="white").pack(fill="x", pady=(10, 2))

        self.status = tk.Label(self.root, text="Drag to mark slots. Right-click on canvas to remove nearest.", bg="#222", fg="#aaa", anchor="w")
        self.status.pack(fill="x")

        # Bind events
        self.canvas.bind("<Button-1>", self._on_mouse_down)
        self.canvas.bind("<B1-Motion>", self._on_mouse_drag)
        self.canvas.bind("<ButtonRelease-1>", self._on_mouse_up)
        self.canvas.bind("<Button-3>", self._on_right_click)
        self.slot_listbox.bind("<<ListboxSelect>>", self._on_listbox_select)

        self._redraw()
        self.root.mainloop()

    def _on_mouse_down(self, event):
        self.dragging = True
        self.drag_start = (event.x, event.y)

    def _on_mouse_drag(self, event):
        if self.dragging and self.drag_start:
            self._redraw()
            x1, y1 = self.drag_start
            x2, y2 = event.x, event.y
            self.canvas.create_rectangle(x1, y1, x2, y2, outline="#ff0", width=2, dash=(4, 4))

    def _on_mouse_up(self, event):
        if not self.dragging or not self.drag_start:
            return
        self.dragging = False
        x1, y1 = self.drag_start
        x2, y2 = event.x, event.y
        if abs(x2 - x1) < 5 or abs(y2 - y1) < 5:
            return
        # Normalize
        rx1, rx2 = min(x1, x2), max(x1, x2)
        ry1, ry2 = min(y1, y2), max(y1, y2)
        slot_type = self.type_var.get()

        # Check for nearby existing to snap
        for s in self.slots:
            sx1, sy1, sx2, sy2, st = s
            if abs(rx1 - sx1) < 8 and abs(ry1 - sy1) < 8 and abs(rx2 - sx2) < 8 and abs(ry2 - sy2) < 8:
                self.status.config(text=f"Slot overlaps with existing at ({sx1},{sy1})")
                return

        self.slots.append([rx1, ry1, rx2, ry2, slot_type])
        self.status.config(text=f"Added {slot_type} slot: ({rx1},{ry1})-({rx2},{ry2}) size={rx2-rx1}x{ry2-ry1}")
        self._update_listbox()
        self._redraw()

    def _on_right_click(self, event):
        # Find nearest slot
        ex, ey = event.x, event.y
        best_dist = 20
        best_idx = -1
        for i, s in enumerate(self.slots):
            cx = (s[0] + s[2]) / 2
            cy = (s[1] + s[3]) / 2
            dist = ((cx - ex) ** 2 + (cy - ey) ** 2) ** 0.5
            if dist < best_dist:
                best_dist = dist
                best_idx = i
        if best_idx >= 0:
            removed = self.slots.pop(best_idx)
            self.status.config(text=f"Removed slot at ({removed[0]},{removed[1]})")
            self._update_listbox()
            self._redraw()

    def _delete_selected(self):
        sel = self.slot_listbox.curselection()
        if sel:
            self.slots.pop(sel[0])
            self._update_listbox()
            self._redraw()

    def _clear_all(self):
        self.slots = []
        self._update_listbox()
        self._redraw()
        self.status.config(text="Cleared all slots")

    def _update_listbox(self):
        self.slot_listbox.delete(0, tk.END)
        for s in self.slots:
            t = s[4]
            self.slot_listbox.insert(tk.END, f"[{t}] ({s[0]},{s[1]})-({s[2]},{s[3]})")

    def _on_listbox_select(self, event):
        self._redraw()

    def _redraw(self):
        self.canvas.delete("all")
        self.canvas.create_image(0, 0, image=self.tk_img, anchor="nw")
        sel = self.slot_listbox.curselection()
        for i, s in enumerate(self.slots):
            color = "#4a8" if s[4] == "equip" else "#84a" if s[4] == "grid" else "#a84"
            outline = "#ff0" if sel and i == sel[0] else color
            w = 3 if sel and i == sel[0] else 2
            self.canvas.create_rectangle(s[0], s[1], s[2], s[3], outline=outline, width=w)
            # Label
            mx = (s[0] + s[2]) // 2
            my = (s[1] + s[3]) // 2
            self.canvas.create_text(mx, my, text=s[4][0].upper(), fill=color, font=("Arial", 8, "bold"))

    def _save(self):
        rel_backdrop = os.path.relpath(IMG_PATH, BASE).replace("\\", "/")
        data = {
            "backdrop": "res://" + rel_backdrop,
            "backdrop_size": [self.img.width, self.img.height],
            "slots": self.slots,
        }
        with open(OUT_PATH, "w") as f:
            json.dump(data, f, indent=2)
        self.status.config(text=f"Saved {len(self.slots)} slots to {OUT_PATH}")


if __name__ == "__main__":
    SlotMapper()
