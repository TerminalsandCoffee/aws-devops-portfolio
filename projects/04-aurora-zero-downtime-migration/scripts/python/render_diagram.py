#!/usr/bin/env python3
"""
Render Mermaid diagram to PNG using mermaid-cli.

This script wraps the mermaid-cli (mmdc) tool to render .mmd files to .png.
"""

import sys
import argparse
import subprocess
import os
from pathlib import Path


def render_diagram(
    input_file: str,
    output_file: str = None,
    theme: str = "dark",
    background: str = "transparent",
    width: int = 2000
) -> bool:
    """
    Render a Mermaid diagram file to PNG.
    
    Args:
        input_file: Path to input .mmd file
        output_file: Path to output .png file (default: same as input with .png extension)
        theme: Diagram theme (default: dark)
        background: Background color (default: transparent)
        width: Diagram width in pixels (default: 2000)
        
    Returns:
        True if successful, False otherwise
    """
    input_path = Path(input_file)
    
    if not input_path.exists():
        print(f"Error: Input file '{input_file}' does not exist", file=sys.stderr)
        return False
    
    if input_path.suffix.lower() != '.mmd':
        print(f"Warning: Input file '{input_file}' does not have .mmd extension", file=sys.stderr)
    
    if output_file is None:
        output_file = str(input_path.with_suffix('.png'))
    
    try:
        # Check if mmdc is available
        result = subprocess.run(
            ['mmdc', '--version'],
            capture_output=True,
            text=True
        )
        
        if result.returncode != 0:
            print("Error: mermaid-cli (mmdc) is not installed or not in PATH", file=sys.stderr)
            print("Install it with: npm install -g @mermaid-js/mermaid-cli", file=sys.stderr)
            return False
        
        # Build mmdc command
        cmd = [
            'mmdc',
            '-i', str(input_path),
            '-o', output_file,
            '-t', theme,
            '-b', background,
            '--width', str(width)
        ]
        
        print(f"Rendering diagram: {input_file} -> {output_file}")
        
        result = subprocess.run(cmd, capture_output=True, text=True)
        
        if result.returncode == 0:
            print(f"✓ Successfully rendered: {output_file}")
            return True
        else:
            print(f"Error rendering diagram: {result.stderr}", file=sys.stderr)
            return False
            
    except FileNotFoundError:
        print("Error: mermaid-cli (mmdc) is not installed or not in PATH", file=sys.stderr)
        print("Install it with: npm install -g @mermaid-js/mermaid-cli", file=sys.stderr)
        return False
    except Exception as e:
        print(f"Unexpected error: {e}", file=sys.stderr)
        return False


def main():
    parser = argparse.ArgumentParser(
        description="Render Mermaid diagram to PNG"
    )
    parser.add_argument(
        'input_file',
        help="Path to input .mmd file"
    )
    parser.add_argument(
        '-o', '--output',
        help="Path to output .png file (default: same as input with .png extension)"
    )
    parser.add_argument(
        '-t', '--theme',
        default='dark',
        choices=['dark', 'default', 'forest', 'neutral'],
        help="Diagram theme (default: dark)"
    )
    parser.add_argument(
        '-b', '--background',
        default='transparent',
        help="Background color (default: transparent)"
    )
    parser.add_argument(
        '-w', '--width',
        type=int,
        default=2000,
        help="Diagram width in pixels (default: 2000)"
    )
    
    args = parser.parse_args()
    
    success = render_diagram(
        args.input_file,
        args.output,
        args.theme,
        args.background,
        args.width
    )
    
    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()

