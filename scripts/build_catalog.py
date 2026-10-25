"""Build a source-text Qt 5 catalog using Qt's standard QM format.

Context tags are omitted intentionally: Qt supports source-only messages.
No executable files or process memory are modified.
"""
import json, pathlib, struct, re
ROOT=pathlib.Path(__file__).resolve().parent.parent
def elf_hash(data):
    h=0
    for c in data:
        h=(h<<4)+c
        g=h&0xf0000000
        if g: h^=g>>24
        h&=~g
    return h or 1
def block(tag,data): return bytes([tag])+struct.pack('>I',len(data))+data
def compile_qm(mapping):
    messages=bytearray(); hashes=[]
    for source,translation in sorted(mapping.items()):
        src=source.encode('utf8'); dst=translation.encode('utf-16be')
        assert sorted(re.findall(r'%[Ln]?\d+|%n',source))==sorted(re.findall(r'%[Ln]?\d+|%n',translation)), source
        hashes.append((elf_hash(src),len(messages)))
        messages+=block(3,dst)+block(6,src)+block(8,b'')+b'\x01'
    data=bytes.fromhex('3cb86418caef9c95cd211cbf60a1bddd')
    data+=block(0xa7,b'zh_CN')
    data+=block(0x42,b''.join(struct.pack('>II',*p) for p in sorted(hashes)))
    data+=block(0x69,messages)
    return data
if __name__ == '__main__':
    mapping=json.loads((ROOT/'translations.json').read_text(encoding='utf8'))
    payload=ROOT/'installer/payload'
    catalog=compile_qm(mapping)
    for name in ['uaexpert_zh_CN.qm','uaexpert.qm']:
        path=payload/'bin'/name
        path.parent.mkdir(parents=True,exist_ok=True)
        path.write_bytes(catalog)
    import hashlib
    manifest=json.loads((payload/'manifest.json').read_text(encoding='utf8'))
    for entry in manifest['files']:
        assert hashlib.sha256((payload/entry['path']).read_bytes()).hexdigest()==entry['sha256'],entry['path']
    print(f'Built and verified {len(mapping)} translations')
