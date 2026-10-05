"""Validate flow XML files: well-formed, and top-level <Flow> children grouped by tag
(no interleaving of the same tag with a different tag in between)."""
import glob
import xml.etree.ElementTree as ET

ALPHA_ORDER = [
    'actionCalls', 'apiVersion', 'areMetricsLoggedToDataCloud', 'assignments',
    'decisions', 'description', 'formulas', 'interviewLabel', 'label', 'loops',
    'processMetadataValues', 'processType', 'recordCreates', 'recordLookups',
    'recordUpdates', 'start', 'status', 'subflows', 'variables',
]


def local(tag):
    return tag.split('}', 1)[1] if '}' in tag else tag


def check(path):
    try:
        root = ET.parse(path).getroot()
    except ET.ParseError as e:
        print('PARSE ERROR', path, e)
        return False
    tags = [local(c.tag) for c in root]
    seen = set()
    last_group = None
    ok = True
    for t in tags:
        if t != last_group:
            if t in seen:
                print('INTERLEAVED/DUPLICATED GROUP', path, t)
                ok = False
            seen.add(t)
            last_group = t
    # alphabetical order check (best-effort warning only)
    order_seen = []
    for t in tags:
        if not order_seen or order_seen[-1] != t:
            order_seen.append(t)
    sorted_check = sorted(order_seen, key=lambda t: ALPHA_ORDER.index(t) if t in ALPHA_ORDER else 999)
    if order_seen != sorted_check:
        print('NOT ALPHABETICAL', path, order_seen, '!=', sorted_check)
    return ok


if __name__ == '__main__':
    all_ok = True
    for f in sorted(glob.glob('force-app/main/default/flows/*.flow-meta.xml')):
        if not check(f):
            all_ok = False
    print('ALL OK' if all_ok else 'ISSUES FOUND')
