import sys, re

def extract_method(filepath, method_name):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    match = re.search(r'Widget\s+' + method_name + r'\s*\(.*?\)\s*\{', content, re.DOTALL)
    if not match: return None
    
    start_idx = match.start()
    brace_count = 0
    
    for i in range(match.end() - 1, len(content)):
        char = content[i]
        
        if char == '{': brace_count += 1
        elif char == '}': brace_count -= 1
        
        if brace_count == 0:
            return content[start_idx:i+1]
    return None

methods = [
    '_buildActiveBookingBanner',
    '_buildHeader',
    '_buildAvailabilityCard',
    '_buildRadarView',
    '_buildIncomingRequestView',
    '_buildWaitingForPatientView',
    '_buildActiveVisitView'
]

file = r'F:\Housepital-AI\Housepital-AI\housepital_staff\lib\features\nurse\presentation\pages\nurse_home_page.dart'
for m in methods:
    code = extract_method(file, m)
    if code:
        with open(f'{m}.txt', 'w', encoding='utf-8') as f:
            f.write(code)
        print(f'Extracted {m}')
    else:
        print(f'Failed to extract {m}')
