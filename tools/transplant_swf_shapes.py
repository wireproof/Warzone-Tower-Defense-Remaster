import sys,struct,zlib,hashlib

def unpack(path):
 b=open(path,'rb').read();d=b[:8]+zlib.decompress(b[8:]) if b[:3]==b'CWS' else b
 if d[:3] not in (b'CWS',b'FWS'):raise ValueError('unsupported SWF')
 n=d[8]>>3;o=8+(5+4*n+7)//8+4;head=d[8:o];tags=[]
 while o+2<=len(d):
  start=o;h=struct.unpack_from('<H',d,o)[0];o+=2;t=h>>6;l=h&63
  if l==63:l=struct.unpack_from('<I',d,o)[0];o+=4
  body=d[o:o+l];o+=l
  if len(body)!=l:raise ValueError('truncated tag')
  tags.append((t,body,d[start:o]))
  if t==0:break
 return d[3],head,tags
v,h,original=unpack(sys.argv[1]);v2,h2,changed=unpack(sys.argv[2]);assert (v,h)==(v2,h2)
ids={int(x) for x in sys.argv[4].split(",")} if len(sys.argv)>4 else {645,650,654,659,664}; replacements={}
for code,body,raw in changed:
 if code in (2,22,32,83) and len(body)>=2:
  cid=struct.unpack_from('<H',body)[0]
  if cid in ids:
   if cid in replacements:raise ValueError('duplicate replacement')
   replacements[cid]=(code,raw)
assert set(replacements)==ids
out=[];seen=set()
for code,body,raw in original:
 cid=struct.unpack_from('<H',body)[0] if code in (2,22,32,83) and len(body)>=2 else None
 if cid in ids:
  assert cid not in seen and replacements[cid][0]==code;out.append(replacements[cid][1]);seen.add(cid)
 else:out.append(raw)
assert seen==ids
payload=h+b''.join(out); result=b'CWS'+bytes([v])+struct.pack('<I',len(payload)+8)+zlib.compress(payload,9)
open(sys.argv[3],'wb').write(result)
print('Transplanted only shape IDs',sorted(seen),'output sha256',hashlib.sha256(result).hexdigest())
