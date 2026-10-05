import glob
import re
import xml.etree.ElementTree as ET

NS = 'http://soap.sforce.com/2006/04/metadata'
ET.register_namespace('', NS)


def local(tag):
    return tag.split('}', 1)[1] if '}' in tag else tag


def sort_children(elem):
    """Stable-sort direct children alphabetically by local tag name, recursing first."""
    for child in elem:
        sort_children(child)
    children = list(elem)
    children.sort(key=lambda c: local(c.tag))
    for c in children:
        elem.remove(c)
    for c in children:
        elem.append(c)


def fix_file(path):
    tree = ET.parse(path)
    root = tree.getroot()
    sort_children(root)
    tree.write(path, encoding='UTF-8', xml_declaration=True)
    # Fix single->double quotes in the XML declaration and ensure trailing newline.
    with open(path, 'r', encoding='utf-8') as fh:
        content = fh.read()
    content = content.replace(
        "<?xml version='1.0' encoding='UTF-8'?>",
        '<?xml version="1.0" encoding="UTF-8"?>'
    )
    if not content.endswith('\n'):
        content += '\n'
    with open(path, 'w', encoding='utf-8', newline='\n') as fh:
        fh.write(content)


if __name__ == '__main__':
    files = sorted(glob.glob('force-app/main/default/flows/*.flow-meta.xml'))
    for f in files:
        fix_file(f)
        print('reordered', f)
    print('total', len(files))
