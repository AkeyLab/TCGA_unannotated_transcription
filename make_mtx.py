import os
import pandas as pd
import glob
import sys

def process_depth_files(input_dir, output_file, selected_chrom):
    all_files = glob.glob(os.path.join(input_dir, "*.txt"))  # Get all .txt files
    depth_dict = {}
    file_names = []
    
    for file_path in all_files:
        print(file_path)
        print(depth_dict)
        file_name = os.path.basename(file_path)  # Extract file name
        file_names.append(file_name)
        
        with open(file_path, 'r') as f:
            for line in f:
                parts = line.strip().split()
                if len(parts) < 4:
                    continue
                chrom, start, _, depth = parts  # Extract relevant columns
                
                if chrom != selected_chrom:
                    continue  # Skip lines not matching the selected chromosome
                
                bin_label = f"{chrom}-{start}"
                
                if bin_label not in depth_dict:
                    depth_dict[bin_label] = {}
                
                depth_dict[bin_label][file_name] = float(depth)  # Store depth value
    
    # Convert to DataFrame
    df = pd.DataFrame.from_dict(depth_dict, orient='index', dtype=float)
    df.index.name = "chrom-start"
    df = df.reindex(sorted(df.index))  # Sort by chrom-start
    
    # Fill missing values with 0
    df = df.fillna(0)
    
    # Save to output file
    df.to_csv(output_file, sep='\t')
    
    print(f"Merged data for chromosome {selected_chrom} saved to {output_file}")

if __name__ == "__main__":
    process_depth_files(sys.argv[1], sys.argv[2], sys.argv[3])
    #input_dir = "binned_counts"  # Change this to your actual directory
    #output_file = "output.tsv"  # Change this to your desired output filename
    #selected_chrom = input("Enter the chromosome to process (e.g., 'chr1'): ")
    #process_depth_files(input_dir, output_file, selected_chrom)
