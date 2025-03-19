import subprocess
import sys
import os
import re

def run_tests(executable_path, test_dir="test"):
    # Ensure executable exists
    if not os.path.isfile(executable_path):
        print(f"Error: Executable '{executable_path}' not found.")
        sys.exit(1)

    # Ensure test directory exists
    if not os.path.isdir(test_dir):
        print(f"Error: Test directory '{test_dir}' not found.")
        sys.exit(1)

    # Find all .txt files in test directory
    test_files = [f for f in os.listdir(test_dir) if f.endswith(".txt")]

    # Sort files to maintain order
    test_files.sort()

    total_tests = len(test_files)
    passed_tests = 0

    for file in test_files:
        file_path = os.path.join(test_dir, file)

        # Extract the expected word count from the filename using regex
        match = re.match(r"(\d+)\.txt", file)
        if not match:
            print(f"Skipping {file}: Invalid filename format.")
            continue

        expected_count = int(match.group(1))

        # Run the executable with the text file
        try:
            result = subprocess.run([executable_path, file_path], capture_output=True, text=True, check=True)
            output = result.stdout.strip()

            # Ensure output is a valid number
            try:
                actual_count = int(output)
            except ValueError:
                print(f"❌ {file}: Invalid output '{output}' (expected {expected_count})")
                continue

            # Check if the output matches the expected count
            if actual_count == expected_count:
                print(f"✅ {file}: Passed (Count: {actual_count})")
                passed_tests += 1
            else:
                print(f"❌ {file}: Failed (Expected: {expected_count}, Got: {actual_count})")

        except subprocess.CalledProcessError as e:
            print(f"❌ {file}: Execution failed ({e})")

    print(f"\nTest Results: {passed_tests}/{total_tests} passed.")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Arguement Missing")
        print(f"Usage: {sys.argv[0]} <path_to_executable>")
        sys.exit(1)

    executable = sys.argv[1]
    run_tests(executable)
