#!/usr/bin/env python3
import json
import sys

def json_to_env(json_string):
    # Load json to dict
    data = json.loads(json_string)
    # Store value to string and print corresponding key
    env_string = ""
    for key, value in data.items():
        env_string += f'{key}={value}\n'
    return env_string

def main():
    print(json_to_env(sys.argv[1]))

if __name__ == "__main__":
    main()
