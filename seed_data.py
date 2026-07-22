import subprocess
import sys
import os

if __name__ == "__main__":
    print("Triggering database seed operations...")
    backend_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), "backend")
    # Run backend/seed_data.py
    res = subprocess.run([sys.executable, "seed_data.py"], cwd=backend_dir)
    sys.exit(res.returncode)
