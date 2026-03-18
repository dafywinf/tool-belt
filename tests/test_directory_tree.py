"""Tests for scripts/directory_tree.py."""

import stat
import subprocess
import sys
from pathlib import Path

import allure
import pytest

from scripts.directory_tree import _DEFAULT_IGNORE, generate_tree

FIXTURE_DIR = Path(__file__).parent / "fixtures" / "sample_dir"


@allure.feature("directory_tree")
@allure.story("generate_tree function")
class TestGenerateTree:
    """Unit tests for the generate_tree() function."""

    @allure.title("Returns a non-empty string for a valid directory")
    @allure.description("Verify generate_tree returns a non-empty string for the fixture dir.")
    def test_returns_string_for_valid_dir(self) -> None:
        result = generate_tree(FIXTURE_DIR)
        assert isinstance(result, str)
        assert len(result) > 0

    @allure.title("Top-level visible items appear in output")
    @allure.description("dir_a, dir_b, and file_a.txt must be present; ignored names must not.")
    def test_visible_items_present(self) -> None:
        result = generate_tree(FIXTURE_DIR)
        assert "dir_a" in result
        assert "dir_b" in result
        assert "file_a.txt" in result

    @allure.title("Default ignored directories are excluded")
    @allure.description("__pycache__ and .git must not appear in the default output.")
    def test_default_ignored_dirs_excluded(self) -> None:
        result = generate_tree(FIXTURE_DIR)
        assert "__pycache__" not in result
        assert ".git" not in result

    @allure.title("Directories sort before files at same level")
    @allure.description("dir_a and dir_b must appear before file_a.txt in the output.")
    def test_directories_before_files(self) -> None:
        result = generate_tree(FIXTURE_DIR)
        lines = [ln.strip() for ln in result.splitlines() if ln.strip()]
        names = [ln.split(" ")[-1] for ln in lines if ln.startswith(("├──", "└──"))]
        dir_names = {"dir_a", "dir_b"}
        file_names = {"file_a.txt"}
        dir_indices = [i for i, n in enumerate(names) if n in dir_names]
        file_indices = [i for i, n in enumerate(names) if n in file_names]
        assert all(d < f for d in dir_indices for f in file_indices)

    @allure.title("Last visible item uses └── connector")
    @allure.description(
        "After filtering, the last visible top-level item must use └── not ├──."
    )
    def test_last_item_uses_end_connector(self) -> None:
        result = generate_tree(FIXTURE_DIR)
        top_level_lines = [
            ln for ln in result.splitlines() if ln.startswith(("├── ", "└── "))
        ]
        assert top_level_lines, "Expected top-level tree lines"
        assert top_level_lines[-1].startswith("└── "), (
            f"Last top-level line should use └──, got: {top_level_lines[-1]!r}"
        )

    @allure.title("Subdirectory contents are rendered recursively")
    @allure.description("file_c.txt nested in dir_a/subdir_a1 must appear in output.")
    def test_recursive_rendering(self) -> None:
        result = generate_tree(FIXTURE_DIR)
        assert "subdir_a1" in result
        assert "file_c.txt" in result

    @allure.title("Custom ignore_list overrides the default")
    @allure.description("Passing a custom set hides the specified names and shows the rest.")
    def test_custom_ignore_list(self) -> None:
        result = generate_tree(FIXTURE_DIR, ignore_list={"dir_b"})
        assert "dir_b" not in result
        # __pycache__ and .git should now be visible with custom ignore
        assert "dir_a" in result

    @allure.title("Empty ignore_list shows hidden dirs")
    @allure.description("Passing an empty set causes hidden directories to appear in the output.")
    def test_empty_ignore_list_shows_all(self) -> None:
        result = generate_tree(FIXTURE_DIR, ignore_list=set())
        assert ".hidden_dir" in result

    @allure.title("Returns empty string for unreadable directory")
    @allure.description("PermissionError on iterdir() must return empty string, not raise.")
    def test_permission_error_returns_empty_string(self, tmp_path: Path) -> None:
        locked_dir = tmp_path / "locked"
        locked_dir.mkdir()
        locked_dir.chmod(stat.S_IWRITE)  # remove read/execute bits
        try:
            result = generate_tree(locked_dir)
            assert result == ""
        finally:
            locked_dir.chmod(stat.S_IRWXU)  # restore so tmp_path cleanup works

    @allure.title("Default ignore_list constant contains expected names")
    @allure.description("_DEFAULT_IGNORE must cover the standard artefact directories.")
    def test_default_ignore_constant(self) -> None:
        expected = {".git", "__pycache__", "node_modules", ".venv", ".DS_Store"}
        assert expected.issubset(_DEFAULT_IGNORE)

    @allure.title("Accepts a string path as well as a Path object")
    @allure.description("generate_tree must work when root_dir is passed as a plain string.")
    def test_accepts_string_path(self) -> None:
        result = generate_tree(str(FIXTURE_DIR))
        assert "dir_a" in result


@allure.feature("directory_tree")
@allure.story("CLI entry point")
class TestCLI:
    """Integration tests that invoke directory_tree.py as a subprocess."""

    @allure.title("Script exits with code 0")
    @allure.description("Running the script as __main__ must not raise an error.")
    def test_exit_code(self) -> None:
        result = subprocess.run(
            [sys.executable, "scripts/directory_tree.py"],
            capture_output=True,
            text=True,
        )
        assert result.returncode == 0

    @allure.title("Script prints 'Project Tree for:' header")
    @allure.description("The CLI output must include the path header line.")
    def test_header_in_output(self) -> None:
        result = subprocess.run(
            [sys.executable, "scripts/directory_tree.py"],
            capture_output=True,
            text=True,
        )
        assert "Project Tree for:" in result.stdout

    @allure.title("Script outputs at least one tree line")
    @allure.description("The CLI must render at least one ├── or └── connector line.")
    def test_tree_lines_in_output(self) -> None:
        result = subprocess.run(
            [sys.executable, "scripts/directory_tree.py"],
            capture_output=True,
            text=True,
        )
        assert "──" in result.stdout
