import re, glob, os

root = os.path.dirname(os.path.abspath(__file__))
flows_dir = os.path.join(root, "force-app", "main", "default", "flows")

block_re = re.compile(r"(<(actionCalls|recordLookups)>)(.*?)(</\2>)", re.DOTALL)

def fix(match):
    open_tag, tag, body, close_tag = match.groups()
    if "<storeOutputAutomatically>" in body:
        return match.group(0)
    body = body.rstrip() + "\n        <storeOutputAutomatically>true</storeOutputAutomatically>\n    "
    return open_tag + body + close_tag

changed = 0
for path in glob.glob(os.path.join(flows_dir, "*.flow-meta.xml")):
    with open(path, encoding="utf-8") as f:
        content = f.read()
    new_content = block_re.sub(fix, content)
    if new_content != content:
        with open(path, "w", encoding="utf-8") as f:
            f.write(new_content)
        changed += 1
        print("Updated", os.path.basename(path))

print("Done,", changed, "files changed")
