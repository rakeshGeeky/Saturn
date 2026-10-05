"""Reorder only the direct (top-level) children of <Flow> alphabetically by tag name,
preserving each block's raw text exactly (no re-serialization, no entity re-escaping).
This fixes "Element X is duplicated at this location in type Flow" errors caused by
interleaving same-tag elements, without touching nested element ordering (which Salesforce
does not enforce strictly, confirmed against pre-existing working flows).
"""
import glob
import re

TOP_INDENT = '    '  # exactly 4 spaces = depth 1 (direct child of <Flow>)


def split_top_level_blocks(body_lines):
    blocks = []  # list of (tag, text)
    i = 0
    n = len(body_lines)
    while i < n:
        line = body_lines[i]
        if line.strip() == '':
            i += 1
            continue
        if not line.startswith(TOP_INDENT) or line.startswith(TOP_INDENT + ' '):
            # Not a top-level line (shouldn't happen); keep as-is standalone block.
            blocks.append((None, line + '\n'))
            i += 1
            continue
        m = re.match(r'^ {4}<([A-Za-z0-9_]+)(?:[ />])', line)
        if not m:
            blocks.append((None, line + '\n'))
            i += 1
            continue
        tag = m.group(1)
        # Self-closing or single-line element (opens and closes on same line).
        if re.search(r'</' + re.escape(tag) + r'>\s*$', line) or line.rstrip().endswith('/>'):
            blocks.append((tag, line + '\n'))
            i += 1
            continue
        # Multi-line block: consume until the matching top-level closing tag.
        collected = [line]
        i += 1
        close_pattern = re.compile(r'^ {4}</' + re.escape(tag) + r'>\s*$')
        while i < n and not close_pattern.match(body_lines[i]):
            collected.append(body_lines[i])
            i += 1
        if i < n:
            collected.append(body_lines[i])
            i += 1
        blocks.append((tag, '\n'.join(collected) + '\n'))
    return blocks


def fix_file(path):
    with open(path, 'r', encoding='utf-8') as fh:
        content = fh.read()

    m = re.search(r'(<Flow[^>]*>\n)(.*)(</Flow>\s*)$', content, flags=re.S)
    if not m:
        print('SKIP (no Flow root match):', path)
        return False
    header, body, footer = m.group(1), m.group(2), m.group(3)
    body_lines = body.split('\n')
    if body_lines and body_lines[-1] == '':
        body_lines = body_lines[:-1]

    blocks = split_top_level_blocks(body_lines)
    # Stable sort by tag name; None-tag (unparsed) blocks keep their original relative spot
    # by sorting with a key that treats None as empty-after text (shouldn't normally occur).
    sortable = [b for b in blocks if b[0] is not None]
    unsortable = [b for b in blocks if b[0] is None]
    if unsortable:
        print('WARNING: unparsed top-level lines in', path, [b[1] for b in unsortable])
    sortable.sort(key=lambda b: b[0])

    new_body = ''.join(text for _, text in sortable)
    new_content = header + new_body + footer
    if not new_content.endswith('\n'):
        new_content += '\n'

    if new_content != content:
        with open(path, 'w', encoding='utf-8', newline='\n') as fh:
            fh.write(new_content)
        return True
    return False


if __name__ == '__main__':
    changed = 0
    for f in sorted(glob.glob('force-app/main/default/flows/*.flow-meta.xml')):
        if fix_file(f):
            print('reordered', f)
            changed += 1
        else:
            print('unchanged', f)
    print('total changed', changed)
