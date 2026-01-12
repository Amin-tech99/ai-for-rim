import os
import re
import json

def process_files(directory):
    files = [f for f in os.listdir(directory) if f.lower().startswith("part") and f.lower().endswith(".txt")]
    
    translation_data = []
    support_data = []

    for filename in files:
        filepath = os.path.join(directory, filename)
        print(f"Processing {filename}...")
        
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()

        # Split by conversation separators
        conversations = re.split(r'———|---|___', content)

        for conv in conversations:
            lines = conv.strip().split('\n')
            
            current_support_messages = []
            
            # Temporary storage for pairing AR and HS lines
            last_ar_line = None

            support_conv_lines = []

            for line in lines:
                line = line.strip()
                if not line:
                    continue
                
                # Check for AR lines
                ar_match = re.match(r'^\d*[:\s]*AR:\s*(.*)', line, re.IGNORECASE)
                if ar_match:
                    ar_text = ar_match.group(1).strip()
                    last_ar_line = ar_text
                    continue

                # Check for HS lines
                hs_match = re.match(r'^\d*[:\s]*HS:\s*(.*)', line, re.IGNORECASE)
                if hs_match:
                    hs_text = hs_match.group(1).strip()
                    
                    # Add to Translation Dataset if we have a pending AR line
                    if last_ar_line:
                        translation_entry = {
                            "messages": [
                                {"role": "user", "content": f"Translate the following to Hassaniya: {last_ar_line}"},
                                {"role": "model", "content": hs_text}
                            ]
                        }
                        translation_data.append(translation_entry)
                        last_ar_line = None # Reset
                    
                    # Add to Support Dataset collector
                    support_conv_lines.append(hs_text)
            
            # Process Support Conversation
            # We assume alternating turns: User -> Model -> User -> Model
            # Or at least we need to map them to roles.
            # Since the user asked for "customer support conversation", let's assume:
            # First HS line is User, Second is Support, etc.
            if support_conv_lines:
                messages = [{"role": "system", "content": "You are a helpful customer support assistant who speaks Hassaniya."}]
                for i, text in enumerate(support_conv_lines):
                    role = "user" if i % 2 == 0 else "model"
                    messages.append({"role": role, "content": text})
                
                # Only add if we have at least one exchange (User + Model)
                if len(messages) > 2:
                     support_data.append({"messages": messages})

    return translation_data, support_data

def save_jsonl(data, output_path):
    with open(output_path, 'w', encoding='utf-8') as f:
        for entry in data:
            f.write(json.dumps(entry, ensure_ascii=False) + '\n')
    print(f"Saved {len(data)} entries to {output_path}")

if __name__ == "__main__":
    work_dir = r"c:\Users\slash\Desktop\work\hassaniya work"
    
    trans_data, supp_data = process_files(work_dir)
    
    save_jsonl(trans_data, os.path.join(work_dir, "ar_to_hs_translation.jsonl"))
    save_jsonl(supp_data, os.path.join(work_dir, "hassaniya_customer_support.jsonl"))
