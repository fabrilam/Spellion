"""
Generate low-poly weapon meshes as Godot .tscn files.
PS1-style aesthetic: simple geometry, flat colors, no textures.
"""
import os
from collections import namedtuple
Vector3 = namedtuple("Vector3", "x y z")
Color = namedtuple("Color", "r g b")
def V3(x, y, z): return Vector3(x, y, z)

BASE = os.path.join(os.path.dirname(__file__), "..", "assets", "models", "weapons")
os.makedirs(BASE, exist_ok=True)

WEAPONS = {
    "hand_axe": {
        "parts": [
            ("handle", "CylinderMesh", 0.04, 0.5, V3(0, -0.05, 0), Color(0.45, 0.3, 0.15)),
            ("blade", "BoxMesh", 0.2, 0.25, V3(0.12, 0.25, 0), Color(0.5, 0.5, 0.5)),
        ]
    },
    "mace": {
        "parts": [
            ("handle", "CylinderMesh", 0.04, 0.5, V3(0, -0.05, 0), Color(0.4, 0.25, 0.12)),
            ("head", "SphereMesh", 0.1, 0.2, V3(0, 0.28, 0), Color(0.45, 0.45, 0.45)),
        ]
    },
    "flail": {
        "parts": [
            ("handle", "CylinderMesh", 0.04, 0.5, V3(0, -0.05, 0), Color(0.4, 0.25, 0.12)),
            ("chain", "CylinderMesh", 0.015, 0.15, V3(0, 0.28, 0), Color(0.4, 0.4, 0.4)),
            ("ball", "SphereMesh", 0.07, 0.14, V3(0, 0.38, 0), Color(0.5, 0.5, 0.5)),
        ]
    },
    "arrow": {
        "parts": [
            ("shaft", "CylinderMesh", 0.015, 0.6, V3(0, 0, 0), Color(0.5, 0.35, 0.15)),
            ("head", "BoxMesh", 0.03, 0.08, V3(0, 0.32, 0), Color(0.5, 0.5, 0.5)),
            ("fletch1", "BoxMesh", 0.02, 0.06, V3(-0.02, -0.25, 0), Color(0.6, 0.1, 0.1)),
            ("fletch2", "BoxMesh", 0.02, 0.06, V3(0.02, -0.25, 0), Color(0.6, 0.1, 0.1)),
        ]
    },
    "dagger": {
        "parts": [
            ("handle", "CylinderMesh", 0.03, 0.2, V3(0, -0.05, 0), Color(0.35, 0.2, 0.1)),
            ("blade", "BoxMesh", 0.04, 0.3, V3(0, 0.17, 0), Color(0.5, 0.5, 0.5)),
        ]
    },
}

def make_scene(name, parts):
    # First pass: build all sub-resources
    sub_lines = []
    node_lines = []
    node_lines.append(f'[node name="{name.capitalize()}" type="Node3D"]')
    node_lines.append("")

    for pi, (pname, mtype, p1, p2, pos, color) in enumerate(parts):
        sid = f"SM{pi}"
        mid = f"MM{pi}"

        if mtype == "CylinderMesh":
            sub_lines.append(f"[sub_resource type=\"CylinderMesh\" id=\"{mid}\"]")
            sub_lines.append(f"top_radius = {p1}")
            sub_lines.append(f"bottom_radius = {p1}")
            sub_lines.append(f"height = {p2}")
            sub_lines.append("")
        elif mtype == "BoxMesh":
            sub_lines.append(f"[sub_resource type=\"BoxMesh\" id=\"{mid}\"]")
            sub_lines.append(f"size = Vector3({p1}, {p2}, {p1})")
            sub_lines.append("")
        elif mtype == "SphereMesh":
            sub_lines.append(f"[sub_resource type=\"SphereMesh\" id=\"{mid}\"]")
            sub_lines.append(f"radius = {p1}")
            sub_lines.append(f"height = {p2}")
            sub_lines.append("")

        sub_lines.append(f"[sub_resource type=\"StandardMaterial3D\" id=\"{sid}\"]")
        r = color.r
        g = color.g
        b = color.b
        sub_lines.append(f"albedo_color = Color({r}, {g}, {b}, 1)")
        sub_lines.append("")

        node_lines.append(f"[node name=\"{pname.capitalize()}\" type=\"MeshInstance3D\" parent=\".\"]")
        node_lines.append(f"transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, {pos.x}, {pos.y}, {pos.z})")
        node_lines.append(f"mesh = SubResource(\"{mid}\")")
        node_lines.append(f"material_override = SubResource(\"{sid}\")")
        node_lines.append("")

    lines = ["[gd_scene format=3]", ""]
    lines.extend(sub_lines)
    lines.extend(node_lines)
    return "\n".join(lines)

for name, data in WEAPONS.items():
    tscn = make_scene(name, data["parts"])
    path = os.path.join(BASE, f"{name}.tscn")
    with open(path, "w") as f:
        f.write(tscn)
    print(f"Created: {name}.tscn")

# Also create a combined mesh for the existing sword
# The current sword is a .glb file, but we can add a fallback
print(f"\nDone! {len(WEAPONS)} weapons generated in {BASE}")
