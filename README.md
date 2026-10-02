# ZBCGRAPHIC — Maintain Form Graphics

| Item | Value |
|------|-------|
| RICEFW ID | **ZBCGRAPHIC** |
| Description | Maintain Form Graphics |
| Platform | SAP S/4HANA Cloud **Public Edition** |
| Development model | **ABAP Cloud** (Developer Extensibility) — RAP managed + draft |
| Repo sync | abapGit (local ⇄ GitHub ⇄ S/4HANA Cloud) |
| Package | **`ZBCGRAPHIC`** |
| ที่มา | Clone จาก `YGRAPHIC` — https://github.com/Thianthai/demo-ygraphic.git |
| ของกลางที่เกี่ยวข้อง | `ZCL_UTILITY` (package `ZBCUTILITY` · repo `fplus-zbcutility`) |

## Scope

1. แอป Fiori Elements สำหรับ upload / maintain รูป (JPEG / PNG) ที่ใช้ใน Adobe Form
   ตั้งชื่อรูป (`graphic_name`) และเปิด/ปิดใช้งาน (`is_active`)
2. method ใน `ZCL_UTILITY` รับ `graphic_name` แล้วคืน `graphic_content` ของรูปที่ `is_active = X`
   ให้ form ทุกตัวเรียกไป binding ใน Adobe Form

```
ผู้ใช้ ──▶ Fiori app (ZBCGRAPHIC-manage) ──▶ ZTBC_GRAPHIC
                                              │
Adobe Form ของ RICEFW ต่าง ๆ ──▶ ZCL_UTILITY ──┘  (graphic_name + is_active = X -> graphic_content)
```

## เอกสาร

| ไฟล์ | เนื้อหา |
|---|---|
| [docs/01_source_analysis.md](docs/01_source_analysis.md) | วิเคราะห์ source YGRAPHIC · สิ่งที่ต้องปรับตอน clone |
| [docs/02_object_list.md](docs/02_object_list.md) | รายการ object + แผน phase + สถานะ |
| [docs/03_open_questions.md](docs/03_open_questions.md) | ทะเบียนข้อสงสัย |

## การแบ่งงาน push

| สิ่งที่ทำ | ใคร |
|---|---|
| **ABAP object ทุกชนิด** | **ผู้ใช้** ผ่าน abapGit จาก ADT |
| **เอกสาร** (`docs/`, `README.md`, `CLAUDE.md`) | **Claude** |
