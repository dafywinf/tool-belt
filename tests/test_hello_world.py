import subprocess
import sys

import allure


@allure.feature("hello_world")
class TestHelloWorld:
    @allure.title("Script exits with code 0")
    @allure.description("Verify hello_world.py runs without errors")
    def test_exit_code(self) -> None:
        result = subprocess.run(
            [sys.executable, "scripts/hello_world.py"],
            capture_output=True,
            text=True,
        )
        assert result.returncode == 0

    @allure.title("Script prints 'Hello, World!'")
    @allure.description("Verify hello_world.py outputs the expected greeting to stdout")
    def test_output(self) -> None:
        result = subprocess.run(
            [sys.executable, "scripts/hello_world.py"],
            capture_output=True,
            text=True,
        )
        assert result.stdout.strip() == "Hello, World!"
