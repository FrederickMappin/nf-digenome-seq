#!/usr/bin/env python3
"""
CSV File Processor

This script processes all CSV files in a given folder and adds the filename 
(without extension) as the first column in each CSV file. After processing,
it can optionally concatenate all files into a single combined CSV.

Usage:
    python process_csv_files.py [folder_path] [--no-concat] [output_filename]
    
Arguments:
    folder_path: Path to folder containing CSV files (default: current directory)
    --no-concat: Skip concatenation step (default: concatenate files)
    output_filename: Name for combined file (default: combined_data.csv)

Examples:
    python process_csv_files.py                           # Process current dir, create combined_data.csv
    python process_csv_files.py /path/to/folder          # Process specific folder
    python process_csv_files.py . --no-concat           # Process but don't concatenate
    python process_csv_files.py . combined all_data.csv # Custom output filename
"""

import os
import sys
import pandas as pd
from pathlib import Path

def process_csv_files(folder_path=".", concatenate=True, output_file="combined_data.csv"):
    """
    Process all CSV files in the given folder by adding the filename as the first column,
    then optionally concatenate them into a single file.
    
    Args:
        folder_path (str): Path to the folder containing CSV files. Defaults to current directory.
        concatenate (bool): Whether to concatenate all files after processing. Defaults to True.
        output_file (str): Name of the output file for concatenated data. Defaults to "combined_data.csv".
    """
    folder = Path(folder_path)
    
    if not folder.exists():
        print(f"Error: Folder '{folder_path}' does not exist.")
        return
    
    if not folder.is_dir():
        print(f"Error: '{folder_path}' is not a directory.")
        return
    
    # Find all CSV files in the folder, excluding the output file
    all_csv_files = list(folder.glob("*.csv"))
    output_path = folder / output_file
    csv_files = [f for f in all_csv_files if f != output_path]
    
    if not csv_files:
        print(f"No CSV files found in '{folder_path}' (excluding output file).")
        return
    
    print(f"Found {len(csv_files)} CSV file(s) to process:")
    
    processed_dataframes = []
    
    for csv_file in csv_files:
        try:
            print(f"Processing: {csv_file.name}")
            
            # Read the CSV file
            df = pd.read_csv(csv_file)
            
            # Get the filename without extension
            filename_without_ext = csv_file.stem
            
            # Check if Filename column already exists
            if 'Filename' in df.columns:
                print(f"  ⚠ Filename column already exists in {csv_file.name}, updating values...")
                # Update existing filename column
                df['Filename'] = filename_without_ext
            else:
                # Add filename as the first column
                df.insert(0, 'Filename', filename_without_ext)
            
            # Save the modified CSV back to the same location
            df.to_csv(csv_file, index=False)
            
            # Store the dataframe for concatenation
            if concatenate:
                processed_dataframes.append(df)
            
            print(f"  ✓ Added filename column to {csv_file.name}")
            
        except Exception as e:
            print(f"  ✗ Error processing {csv_file.name}: {str(e)}")
    
    # Concatenate all processed files if requested
    if concatenate and processed_dataframes:
        print(f"\nConcatenating {len(processed_dataframes)} file(s)...")
        try:
            # Combine all dataframes
            combined_df = pd.concat(processed_dataframes, ignore_index=True)
            
            # Save the combined file
            output_path = folder / output_file
            combined_df.to_csv(output_path, index=False)
            
            print(f"✓ Combined data saved to: {output_file}")
            print(f"  Total rows: {len(combined_df)}")
            print(f"  Total columns: {len(combined_df.columns)}")
            
        except Exception as e:
            print(f"✗ Error concatenating files: {str(e)}")
    elif concatenate and not processed_dataframes:
        print("\nNo files to concatenate (all files may have been skipped or had errors).")
    
    print("\nProcessing complete!")

def main():
    """Main function to handle command line arguments and run the processor."""
    if len(sys.argv) > 1:
        folder_path = sys.argv[1]
    else:
        folder_path = "."
    
    # Check for additional command line arguments
    concatenate = True
    output_file = "combined_data.csv"
    
    if len(sys.argv) > 2:
        if sys.argv[2].lower() == "--no-concat":
            concatenate = False
    
    if len(sys.argv) > 3:
        output_file = sys.argv[3]
    
    print(f"Processing CSV files in: {os.path.abspath(folder_path)}")
    if concatenate:
        print(f"Will concatenate files into: {output_file}")
    print("-" * 50)
    
    process_csv_files(folder_path, concatenate, output_file)

if __name__ == "__main__":
    main()