import re
import os

corpus_path = "/Users/minhdong/development/fluentish/lib/src/features/language/corpus/travel_corpus.dart"
engine_path = "/Users/minhdong/development/fluentish/lib/src/features/language/translator_engine.dart"

def audit_corpus():
    print("=== AUDITING TRAVEL CORPUS ===")
    with open(corpus_path, "r", encoding="utf-8") as f:
        content = f.read()
    
    # Extract entries: find all { 'vi': '...', 'en': '...', 'category': '...' }
    # Since single and double quotes can be used, let's match both.
    entry_pattern = re.compile(
        r"\{\s*['\"]vi['\"]\s*:\s*['\"](.*?)['\"]\s*,\s*['\"]en['\"]\s*:\s*['\"](.*?)['\"]\s*,\s*['\"]category['\"]\s*:\s*['\"](.*?)['\"]\s*\}",
        re.DOTALL
    )
    
    entries = entry_pattern.findall(content)
    print(f"Found {len(entries)} entries in travel_corpus.dart.")
    
    # 1. Check for double question marks
    double_qm = []
    # 2. Check for slashes (multiple choices)
    slashes = []
    # 3. Check for duplicates
    vi_seen = {}
    en_seen = {}
    duplicates = []
    
    for idx, (vi, en, cat) in enumerate(entries, 1):
        vi_clean = vi.strip()
        en_clean = en.strip()
        
        # Check double question marks
        if "??" in vi or "??" in en:
            double_qm.append((idx, vi, en))
        
        # Check slashes
        if "/" in vi or "/" in en:
            slashes.append((idx, vi, en))
            
        # Check duplicates
        if vi_clean in vi_seen:
            duplicates.append((idx, "vi", vi_clean, vi_seen[vi_clean]))
        else:
            vi_seen[vi_clean] = idx
            
        if en_clean in en_seen:
            duplicates.append((idx, "en", en_clean, en_seen[en_clean]))
        else:
            en_seen[en_clean] = idx

    print(f"\nRule violations in travel_corpus.dart:")
    print(f"Double question marks ({len(double_qm)}):")
    for idx, vi, en in double_qm:
        print(f"  Line/Index {idx}: vi: {vi} | en: {en}")
        
    print(f"\nMultiple choices with slashes ({len(slashes)}):")
    for idx, vi, en in slashes:
        print(f"  Line/Index {idx}: vi: {vi} | en: {en}")
        
    print(f"\nDuplicate entries ({len(duplicates)}):")
    for idx, lang, text, prev_idx in duplicates:
        print(f"  Index {idx} ({lang}) is duplicate of Index {prev_idx}: {text}")

    return entries

def audit_dictionary():
    print("\n=== AUDITING DICTIONARY ===")
    with open(engine_path, "r", encoding="utf-8") as f:
        content = f.read()
    
    # Find _dictionary block
    dict_start = content.find("static final Map<String, String> _dictionary = {")
    if dict_start == -1:
        print("Could not find _dictionary start.")
        return
    
    # Find closing brace of the dictionary
    # Let's count braces to find the exact end of _dictionary
    brace_count = 0
    dict_content = ""
    for char in content[dict_start:]:
        dict_content += char
        if char == '{':
            brace_count += 1
        elif char == '}':
            brace_count -= 1
            if brace_count == 0:
                break
                
    # Now extract keys and values from dict_content
    # Format: 'key': 'value', or "key": "value",
    # Note: keys/values might have escaped quotes
    pair_pattern = re.compile(
        r"['\"](.*?)['\"]\s*:\s*['\"](.*?)['\"]\s*,",
        re.MULTILINE
    )
    pairs = pair_pattern.findall(dict_content)
    print(f"Found {len(pairs)} dictionary entries.")
    
    double_qm = []
    slashes = []
    keys_seen = {}
    duplicates = []
    
    for idx, (k, v) in enumerate(pairs, 1):
        k_clean = k.strip()
        v_clean = v.strip()
        
        if "??" in k or "??" in v:
            double_qm.append((idx, k, v))
            
        if "/" in k or "/" in v:
            slashes.append((idx, k, v))
            
        if k_clean in keys_seen:
            duplicates.append((idx, k_clean, keys_seen[k_clean]))
        else:
            keys_seen[k_clean] = idx
            
    print(f"\nRule violations in _dictionary:")
    print(f"Double question marks ({len(double_qm)}):")
    for idx, k, v in double_qm:
        print(f"  Index {idx}: key: {k} | val: {v}")
        
    print(f"\nMultiple choices with slashes ({len(slashes)}):")
    for idx, k, v in slashes:
        print(f"  Index {idx}: key: {k} | val: {v}")
        
    print(f"\nDuplicate keys ({len(duplicates)}):")
    for idx, k, prev_idx in duplicates:
        print(f"  Index {idx}: key '{k}' is duplicate of Index {prev_idx}")

if __name__ == "__main__":
    import sys
    # Redirect print to file
    orig_stdout = sys.stdout
    f_out = open("/Users/minhdong/development/fluentish/.agents/auditor_corpus/raw_audit_results.txt", "w", encoding="utf-8")
    sys.stdout = f_out
    
    audit_corpus()
    audit_dictionary()
    
    sys.stdout = orig_stdout
    f_out.close()
    print("Done! Audit results written to raw_audit_results.txt.")

