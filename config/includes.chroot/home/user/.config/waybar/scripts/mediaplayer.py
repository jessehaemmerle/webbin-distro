#!/usr/bin/env python3

import json
import subprocess
import sys


def get_player_status():
    try:
        # Get the current player
        cmd = ["playerctl", "metadata", "--format", 
               '{"text": "{{artist}} - {{title}}", "tooltip": "{{playerName}}: {{artist}} - {{title}}", "alt": "{{status}}", "class": "{{status}}"}']
        
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=5)
        
        if result.returncode == 0 and result.stdout.strip():
            data = json.loads(result.stdout.strip())
            
            # Limit text length
            if len(data["text"]) > 40:
                data["text"] = data["text"][:37] + "..."
            
            return data
        else:
            return {"text": "", "tooltip": "No media playing", "alt": "stopped", "class": "stopped"}
            
    except (subprocess.TimeoutExpired, json.JSONDecodeError, FileNotFoundError):
        return {"text": "", "tooltip": "Player not available", "alt": "stopped", "class": "stopped"}


if __name__ == "__main__":
    status = get_player_status()
    print(json.dumps(status))
