#!/usr/bin/env python3
"""
Editor del archivo hosts de Windows.
Se re-lanza automáticamente como Administrador si es necesario.
"""

import os, sys, shutil, subprocess, ctypes
from pathlib import Path

HOSTS = Path(r"C:\Windows\System32\drivers\etc\hosts")
BACKUP = HOSTS.with_suffix(".hosts.backup")


def is_admin() -> bool:
    try:
        return ctypes.windll.shell32.IsUserAnAdmin() != 0
    except:
        return False


def elevate() -> None:
    script = Path(__file__).resolve()
    subprocess.run(
        ["powershell", "-Command",
         f'Start-Process python -ArgumentList "{script}" -Verb RunAs'],
        shell=True
    )
    sys.exit(0)


def read_lines() -> list[str]:
    if not HOSTS.exists():
        input("❌ No se encuentra el archivo hosts. Enter para salir.")
        sys.exit(1)
    with open(HOSTS, "r", encoding="utf-8") as f:
        return f.readlines()


def write_lines(lines: list[str]) -> None:
    shutil.copy2(HOSTS, BACKUP)
    with open(HOSTS, "w", encoding="utf-8") as f:
        f.writelines(lines)
    print(f"\n✅ Guardado. Backup en: {BACKUP}")
    input("Enter para continuar.")


def list_lines(lines: list[str], filtered: list[int] | None = None, title: str = "") -> None:
    os.system("cls" if os.name == "nt" else "clear")
    print(f"=== hosts {'(' + title + ')' if title else ''}" .ljust(60, "="))
    print()
    for i, line in enumerate(lines, 1):
        if filtered is not None and i not in filtered:
            continue
        icon = "●" if line.strip() and not line.strip().startswith("#") else " "
        num = f"{i:>4}"
        print(f"  {icon} {num}: {line}", end="")
    print()


def menu() -> str:
    print("\n┌──────────────────────────────┐")
    print("│  1  Listar todo              │")
    print("│  2  Buscar                   │")
    print("│  3  Comentar líneas          │")
    print("│  4  Descomentar línea        │")
    print("│  5  Salir                    │")
    print("└──────────────────────────────┘")
    return input("> ").strip()


def cmd_list(lines: list[str]) -> None:
    search = input("Filtrar por texto (Enter = todo): ").strip().lower()
    if search:
        filtered = [i for i, l in enumerate(lines, 1) if search in l.lower()]
        list_lines(lines, filtered, f'coincidencias: "{search}"')
    else:
        list_lines(lines)
    input("Enter para volver.")


def cmd_comment(lines: list[str]) -> list[str]:
    text = input("Comentar líneas que contengan: ").strip().lower()
    if not text:
        return lines
    modified = False
    for i, line in enumerate(lines):
        if not line.strip().startswith("#") and text in line.lower():
            lines[i] = "# " + line
            modified = True
            print(f"  Comentada línea {i+1}")
    if modified:
        write_lines(lines)
    else:
        print("Ninguna línea coincide.")
        input("Enter para continuar.")
    return read_lines()


def cmd_uncomment(lines: list[str]) -> list[str]:
    nums = input("Números de línea a descomentar (ej: 5 o 5,12,23): ").strip()
    modified = False
    for part in nums.replace(",", " ").split():
        try:
            n = int(part)
            if 1 <= n <= len(lines):
                stripped = lines[n - 1].strip()
                if stripped.startswith("#"):
                    lines[n - 1] = stripped.lstrip("# ") + "\n"
                    modified = True
                    print(f"  Descomentada línea {n}")
            else:
                print(f"  Línea {n} fuera de rango.")
        except ValueError:
            print(f"  '{part}' no es válido.")
    if modified:
        write_lines(lines)
    else:
        input("Nada que descomentar. Enter para continuar.")
    return read_lines()


if __name__ == "__main__":
    if not is_admin():
        print("🔁 Solicitando permisos de Administrador...")
        elevate()

    lines = read_lines()
    while True:
        list_lines(lines)
        match menu():
            case "1": cmd_list(lines)
            case "2": cmd_list(lines)
            case "3": lines = cmd_comment(lines)
            case "4": lines = cmd_uncomment(lines)
            case "5": break
            case _: pass



