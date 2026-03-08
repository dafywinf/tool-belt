# tool-belt

A collection of Python utility scripts.

## Getting Started

**Requirements:** Python 3.11+

1. Clone the repo and navigate into it:
   ```bash
   git clone <repo-url>
   cd tool-belt
   ```

2. Install dependencies:
   ```bash
   pip install -e ".[dev]"
   ```

3. Run the tests:
   ```bash
   pytest --alluredir=allure-results --cov=scripts --cov-report=term-missing
   ```

## Scripts

### `directory_tree.py`

Prints an ASCII directory tree of any path — useful for giving AI tools or colleagues a quick snapshot of a project layout.

**Run on the current directory:**
```bash
python scripts/directory_tree.py
```

**Import and use in your own code:**
```python
from scripts.directory_tree import generate_tree

tree = generate_tree("/path/to/project")
print(tree)
```

**Custom ignore rules:**
```python
from scripts.directory_tree import generate_tree

tree = generate_tree(
    ".",
    ignore_list={"dist", "build", ".venv"},
    ignore_suffixes={".egg-info"},
)
print(tree)
```

By default the following are hidden: `.git`, `__pycache__`, `node_modules`, `.venv`, `.DS_Store`, `.mypy_cache`, `.pytest_cache`, `.coverage`, `allure-results`, and anything ending in `.egg-info`.

**Example output (this repo):**
```
Project Tree for: /path/to/tool-belt
.
├── .claude
│   ├── skills
│   │   ├── python-expert
│   │   │   └── SKILL.md
│   │   └── python-qa
│   │       └── SKILL.md
│   ├── standards
│   │   ├── GIT_STANDARDS.md
│   │   └── PYTHON_STANDARDS.md
│   └── settings.local.json
├── scripts
│   ├── __init__.py
│   ├── directory_tree.py
│   └── hello_world.py
├── tests
│   ├── fixtures
│   │   └── sample_dir
│   │       ├── dir_a
│   │       │   ├── subdir_a1
│   │       │   │   └── file_c.txt
│   │       │   └── file_b.txt
│   │       ├── dir_b
│   │       │   └── file_d.txt
│   │       └── file_a.txt
│   ├── test_directory_tree.py
│   └── test_hello_world.py
├── .gitignore
├── CLAUDE.md
├── conftest.py
├── pyproject.toml
└── README.md
```

## Using `directory_tree` from your shell (`.zshrc`)

Add the following function to your `~/.zshrc` so you can call `dtree` from any directory:

```zsh
# --- tool-belt: directory_tree ---
# Adjust TOOL_BELT_DIR if you cloned the repo somewhere else.
TOOL_BELT_DIR="$HOME/Development/git-hub/tool-belt/tool-belt"

dtree() {
  local target="${1:-.}"   # default to current directory
  python "$TOOL_BELT_DIR/scripts/directory_tree.py" "$target"
}
```

**Apply the change:**
```bash
source ~/.zshrc
```

**Usage:**
```bash
dtree              # tree of the current directory
dtree ~/projects   # tree of any path
```

## Structure

```
scripts/    # Runnable utility scripts
tests/      # Tests for each script (pytest + Allure)
```
