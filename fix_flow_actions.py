import re, glob

mapping = {
    'Send_Post_Visit_Template': 'ZcoSendTemplateMessageAction',
    'Send_Checkin_Template': 'ZcoSendTemplateMessageAction',
    'Capture_Consent': 'ZcoCaptureConsentAction',
    'Evaluate_Eligibility': 'ZcoEvaluateIntakeEligibilityAction',
    'Send_Decline_Template': 'ZcoSendTemplateMessageAction',
    'Send_Holding_Template': 'ZcoSendTemplateMessageAction',
    'Scan_Banned_Phrase': 'ZcoScanBannedPhraseAction',
    'Evaluate_Threshold': 'ZcoEvaluateObservationThresholdAction',
    'Match_Patient': 'ZcoMatchPatientByPhoneAction',
    'Scan_Safety_Keywords': 'ZcoScanSafetyKeywordsAction',
    'Create_Safety_Case': 'ZcoEscalateSafetyCaseAction',
    'Send_Safety_Template': 'ZcoSendTemplateMessageAction',
}

def repl_block(m):
    block = m.group(0)
    name_match = re.search(r'<name>([^<]+)</name>', block)
    if not name_match:
        return block
    name = name_match.group(1)
    if name not in mapping:
        return block
    newclass = mapping[name]
    block = re.sub(r'<actionName>ZcoFlowActions</actionName>', f'<actionName>{newclass}</actionName>', block)
    block = re.sub(r'<nameSegment>ZcoFlowActions</nameSegment>', f'<nameSegment>{newclass}</nameSegment>', block)
    return block

count_files = 0
for f in glob.glob('force-app/main/default/flows/*.flow-meta.xml'):
    with open(f, encoding='utf-8') as fh:
        content = fh.read()
    if 'ZcoFlowActions' not in content:
        continue
    newcontent = re.sub(r'<actionCalls>.*?</actionCalls>', repl_block, content, flags=re.S)
    if newcontent != content:
        with open(f, 'w', encoding='utf-8', newline='\n') as fh:
            fh.write(newcontent)
        count_files += 1
        print('updated', f)
print('total updated', count_files)
