import re, glob, os

root = os.path.dirname(os.path.abspath(__file__))
layouts_dir = os.path.join(root, "force-app", "main", "default", "layouts")

section_re = re.compile(r"(<layoutSections>)(.*?)(</layoutSections>)", re.DOTALL)
column_re = re.compile(r"<layoutColumns>\s*(.*?)\s*</layoutColumns>", re.DOTALL)
item_re = re.compile(r"<layoutItems>.*?</layoutItems>", re.DOTALL)

def fix_section(match):
    open_tag, body, close_tag = match.group(1), match.group(2), match.group(3)
    columns = column_re.findall(body)
    items = []
    for col in columns:
        items.extend(item_re.findall(col))
    if not items:
        # empty section (e.g. blank placeholder), leave as-is but still ensure 2 columns tags exist
        new_columns = "<layoutColumns>\n        </layoutColumns>\n        <layoutColumns>\n        </layoutColumns>"
    else:
        left = items[0::2]
        right = items[1::2]
        def render(col_items):
            if not col_items:
                return "<layoutColumns>\n        </layoutColumns>"
            inner = "\n            ".join(col_items)
            return "<layoutColumns>\n            " + inner + "\n        </layoutColumns>"
        new_columns = render(left) + "\n        " + render(right)
    # remove old layoutColumns blocks from body, then insert new ones before <style>
    body_wo_columns = column_re.sub("", body)
    if "<style>" in body_wo_columns:
        body_fixed = body_wo_columns.replace("<style>", new_columns + "\n        <style>", 1)
    else:
        body_fixed = body_wo_columns.rstrip() + "\n        " + new_columns + "\n    "
    return open_tag + body_fixed + close_tag

changed = 0
for path in glob.glob(os.path.join(layouts_dir, "*.layout-meta.xml")):
    with open(path, encoding="utf-8") as f:
        content = f.read()
    new_content = section_re.sub(fix_section, content)
    # collapse extra blank lines
    new_content = re.sub(r"\n[ \t]*\n+", "\n", new_content)
    if new_content != content:
        with open(path, "w", encoding="utf-8") as f:
            f.write(new_content)
        changed += 1

print("Fixed", changed, "layout files")
