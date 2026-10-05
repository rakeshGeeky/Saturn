import re, glob, os

root = os.path.dirname(os.path.abspath(__file__))
objs_dir = os.path.join(root, "force-app", "main", "default", "objects")
ps_dir = os.path.join(root, "force-app", "main", "default", "permissionsets")

required_cache = {}

def is_required(obj, field):
    key = (obj, field)
    if key in required_cache:
        return required_cache[key]
    # standard object field, assume not required (can't check easily) -> False
    path = os.path.join(objs_dir, obj, "fields", field + ".field-meta.xml")
    result = False
    if os.path.isfile(path):
        with open(path, encoding="utf-8") as f:
            content = f.read()
        m = re.search(r"<required>(true|false)</required>", content)
        if m:
            result = m.group(1) == "true"
    required_cache[key] = result
    return result

fp_re = re.compile(r"[ \t]*<fieldPermissions>\s*<editable>(true|false)</editable>\s*<field>([^<]+)</field>\s*<readable>(true|false)</readable>\s*</fieldPermissions>\s*\n", re.MULTILINE)

removed_total = 0
for path in glob.glob(os.path.join(ps_dir, "*.permissionset-meta.xml")):
    with open(path, encoding="utf-8") as f:
        content = f.read()

    def repl(m):
        global removed_total
        field_full = m.group(2)
        obj, field = field_full.split(".", 1)
        if is_required(obj, field):
            removed_total += 1
            return ""
        return m.group(0)

    new_content = fp_re.sub(repl, content)
    if new_content != content:
        with open(path, "w", encoding="utf-8") as f:
            f.write(new_content)
        print("Updated", os.path.basename(path))

print("Removed", removed_total, "required-field fieldPermissions entries")
