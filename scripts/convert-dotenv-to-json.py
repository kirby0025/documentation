#!/usr/bin/env python3
import json
import sys

def env_to_json(file_path):
    # Open dotenv file
    with open(file_path, 'r') as file:
        # Store dotenv variables in a dict
        data = {}
        for line in file:
            # Ignore comment and empty lines
            if line.startswith('#') or not line.strip():
                continue
            # Split key from value
            key, value = line.strip().split("=", 1)
            data[key] = value.replace('\'', '').replace('"', '')

    # Convert to json
    json_data = json.dumps(data, indent=4)

    return json_data

def main():
    print(env_to_json(sys.argv[1]))

if __name__ == "__main__":
    main()
