# ZBCGRAPHIC — Maintain Form Graphics

## Project constraints

1. **Platform**: SAP S/4HANA Cloud **Public Edition** — Developer Extensibility
2. **ABAP Language Version**: **ABAP for Cloud Development** เท่านั้น
3. ใช้ได้เฉพาะ object ที่อยู่ใน **Released APIs (C1 contract)**
4. Sync ผ่าน **abapGit** เท่านั้น
5. ทุก object ลง package **`ZBCGRAPHIC`** ตัวเดียว (ไม่มี sub-package)

## ที่มา

Clone จาก `YGRAPHIC` (repo อ้างอิง https://github.com/Thianthai/demo-ygraphic.git) มาเป็น `Z*` ทั้งชุด
- repo อ้างอิงใช้อ่านอย่างเดียว ห้ามแก้
- ผลวิเคราะห์ source + สิ่งที่ปรับตอน clone อยู่ใน `docs/01_source_analysis.md`

## Naming convention

ใช้กฎกลางใน `~/.claude/CLAUDE.md` ทุกข้อ **แต่เปลี่ยน prefix จาก `Y*` เป็น `Z*`** (ผู้ใช้สั่ง 2026-10-02)
ชื่อจริงทุกตัวอยู่ใน `docs/02_object_list.md` — ต้องให้ผู้ใช้ confirm ทุกเฟสก่อนส่ง code

## ของกลางที่เกี่ยวข้อง

`ZCL_UTILITY` (package `ZBCUTILITY` · repo `fplus-zbcutility`) จะมี method ใหม่สำหรับดึงรูปไป binding ใน Adobe Form
- method อยู่ใน repo `fplus-zbcutility` ไม่ใช่ repo นี้ — เอกสารของ method ต้องอัปเดตที่ `fplus-zbcutility/docs/01_objects.md` ด้วย
- `ZCL_UTILITY` จะอ่าน table / CDS ของ package นี้ -> **transport `ZBCGRAPHIC` ขึ้นก่อนหรือพร้อม `ZBCUTILITY` เสมอ**

## Coding rules

ใช้กฎกลางทั้งหมด โดยเฉพาะ
- **Comment หนึ่งบรรทัดหนึ่งเรื่อง** ห้ามใช้ `·` คั่น ใช้ `->` ไม่ใช่ `→`
- **Comment ห้ามอ้างเลขเอกสาร / เลข object ของ test data** และห้ามอ้างเลข phase / OQ
- **ห้ามใส่ emoji ใน comment ของ ABAP object**
- **ABAP Doc (`"!`) ทุก class · method · constant group · type** (ยกเว้น `REDEFINITION`)
- **ห้าม `CONV #( )` ที่ไม่จำเป็น**
- **table ใหม่ทุกตัวต้องมี `@AbapCatalog.primaryKey.invertedIndividualIndex : true`**
  ไม่งั้นได้ warning `Key must have the type Inverted Individual on the database` (เจอจริงที่ `ZTBC_GRAPHIC` 2026-10-02)
- ตัวรูปใช้ชื่อ `graphic_content` / `GraphicContent` / `ZE_GRAPHIC_CONTENT` ไม่ใช่ `attachment` แบบ source (ผู้ใช้สั่ง 2026-10-02)

## Git — การแบ่งงาน

| สิ่งที่ทำ | ใคร commit/push |
|---|---|
| **ABAP object ทุกชนิด** | **ผู้ใช้** ผ่าน abapGit จาก ADT (Claude เตรียม commit message ให้) |
| **เอกสาร** (`docs/`, `README.md`, `CLAUDE.md`) | **Claude** |

- Claude **ห้ามสร้างไฟล์ ABAP ลง repo** — ส่งเป็น code block ใน chat หลังผู้ใช้บอกว่าพร้อมรับ
- หลังผู้ใช้ push ทุกครั้ง Claude ต้อง `git pull` แล้วตรวจไฟล์ที่ serialize มาเทียบกับ code ที่ส่งไป
  แล้วอัปเดต status ใน `docs/02_object_list.md`
- `.abapgit.xml` และ `package.devc.xml` เป็นของที่ **SAP serialize เอง** (baseline `cfa2aee` · `/src/` · FULL)
- Remote: https://github.com/Thianthai/fplus-zbcgraphic.git
