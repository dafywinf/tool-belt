"""Root conftest — adds the project root to sys.path for direct imports."""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
