#!/usr/bin/env python3
"""Utility script for generating an ASCII directory tree."""

from pathlib import Path

_DEFAULT_IGNORE: frozenset[str] = frozenset(
    {
        ".git",
        "__pycache__",
        "node_modules",
        ".venv",
        ".DS_Store",
        ".mypy_cache",
        ".pytest_cache",
        ".coverage",
        "allure-results",
    }
)

_DEFAULT_IGNORE_SUFFIXES: frozenset[str] = frozenset({".egg-info"})


def _is_ignored(
    name: str,
    ignore_list: frozenset[str] | set[str],
    ignore_suffixes: frozenset[str] | set[str],
) -> bool:
    """Return True if *name* matches any exact name or suffix rule.

    Args:
        name: The file or directory name to test.
        ignore_list: Exact names to ignore.
        ignore_suffixes: Suffixes whose presence causes a match (e.g. ``".egg-info"``).

    Returns:
        True when the name should be excluded from the tree.
    """
    if name in ignore_list:
        return True
    return any(name.endswith(suffix) for suffix in ignore_suffixes)


def generate_tree(
    root_dir: str | Path,
    indent: str = "",
    ignore_list: frozenset[str] | set[str] | None = None,
    ignore_suffixes: frozenset[str] | set[str] | None = None,
) -> str:
    """Generate an ASCII directory tree for *root_dir*.

    Args:
        root_dir: Path to the directory to render.
        indent: Leading indentation string (used internally for recursion).
        ignore_list: Directory/file names to exclude exactly.  Defaults to a
            standard set that hides version-control and cache artefacts.
        ignore_suffixes: Name suffixes to exclude (e.g. ``".egg-info"``).
            Defaults to ``{".egg-info"}``.

    Returns:
        A multi-line string representing the directory tree, or an empty
        string when the directory cannot be read.
    """
    if ignore_list is None:
        ignore_list = _DEFAULT_IGNORE
    if ignore_suffixes is None:
        ignore_suffixes = _DEFAULT_IGNORE_SUFFIXES

    root_path = Path(root_dir)

    try:
        all_items = sorted(
            root_path.iterdir(),
            key=lambda x: (x.is_file(), x.name.lower()),
        )
    except PermissionError:
        return ""

    # Filter ignored items *before* computing is_last so connectors are correct.
    visible_items = [
        item
        for item in all_items
        if not _is_ignored(item.name, ignore_list, ignore_suffixes)
    ]

    tree_str = ""
    last_index = len(visible_items) - 1

    for i, item in enumerate(visible_items):
        is_last = i == last_index
        connector = "└── " if is_last else "├── "
        tree_str += f"{indent}{connector}{item.name}\n"

        if item.is_dir():
            extension = "    " if is_last else "│   "
            tree_str += generate_tree(item, indent + extension, ignore_list, ignore_suffixes)

    return tree_str


if __name__ == "__main__":
    import sys

    target_path = Path(sys.argv[1]) if len(sys.argv) > 1 else Path.cwd()
    print(f"Project Tree for: {target_path}")
    print(".\n" + generate_tree(target_path))
