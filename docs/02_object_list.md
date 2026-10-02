# 02 — Object List + Phase

`⬜` ยังไม่สร้าง · `🟨` ส่ง code แล้วรอสร้าง · `🟦` activate แล้วรอ push · `✅` อยู่ใน repo

> ชื่อชุดนี้ผู้ใช้ตกลงแล้ว 2026-10-02 (OQ-01) แต่ยังต้องสรุปให้ confirm ซ้ำทุก phase ก่อนส่ง code
> `<APP>` ของ RAP object = `GRAPHIC` (ตรงกับ source แค่เปลี่ยน Y -> Z)

## Phase 0 — ตั้ง repo

| Object | Type | ไฟล์ | Status |
|---|---|---|---|
| `ZBCGRAPHIC` | Package | `src/package.devc.xml` | ✅ baseline `cfa2aee` (`/src/` · FULL) |
| เอกสาร | `README.md` `CLAUDE.md` `.gitignore` `docs/` | — | ✅ |

## Phase 1 — DDIC + message class

| Object | Type | Clone จาก | หน้าที่ | Status |
|---|---|---|---|---|
| `ZD_GRAPHIC_NAME` | Domain CHAR 128 ตัวพิมพ์ใหญ่ | `/DMO/FILENAME` | domain ของชื่อรูป (OQ-09 แบบ B) | ✅ `a30c754` |
| `ZD_GRAPHIC_TEXT` | Domain CHAR 128 lowercase | `/DMO/FILENAME` | domain ของชื่อไฟล์ / MIME | ✅ `a30c754` |
| `ZE_GRAPHIC_NAME` | Data element | `YE_GRAPHICNAME` | ชื่อรูปที่ form ใช้ค้น | ✅ `a30c754` |
| `ZE_GRAPHIC_FILE_NAME` | Data element | `/DMO/FILENAME` | ชื่อไฟล์ที่ upload | ✅ `a30c754` |
| `ZE_GRAPHIC_MIME_TYPE` | Data element | `/DMO/MIME_TYPE` | MIME type | ✅ `a30c754` |
| `ZE_GRAPHIC_CONTENT` | Data element RAWSTRING | `/DMO/ATTACHMENT` | ตัวรูป (ผู้ใช้เปลี่ยนชื่อจาก `ZE_GRAPHIC_ATTACHMENT`) | ✅ `a30c754` |
| `ZTBC_GRAPHIC` | Table | `YTBC_GRAPHIC` | เก็บรูป · field `isactive` -> `is_active` · `attachment` -> `graphic_content` · เพิ่ม `local_last_changed_at` · primary key แบบ inverted individual | ✅ `a30c754` |
| `ZBCGRAPHIC` | Message class | `/DMO/CM_FLIGHT_MESSAGES` | ข้อความ validation (MIME · นามสกุลไฟล์ · ชื่อซ้ำ) | ✅ `a30c754` |

### Field ของ `ZTBC_GRAPHIC`

`@AbapCatalog.primaryKey.invertedIndividualIndex : true` (serialize เป็น `PK_IS_INVHASH = X`)

| Field | Key | Data element | หมายเหตุ |
|---|---|---|---|
| `client` | X | `abap.clnt` | |
| `uuid` | X | `SYSUUID_X16` | managed numbering |
| `graphic_name` | | `ZE_GRAPHIC_NAME` | ห้ามซ้ำทั้ง table · เก็บตัวพิมพ์ใหญ่ |
| `file_name` | | `ZE_GRAPHIC_FILE_NAME` | |
| `mime_type` | | `ZE_GRAPHIC_MIME_TYPE` | |
| `graphic_content` | | `ZE_GRAPHIC_CONTENT` | |
| `is_active` | | `ABAP_BOOLEAN` | |
| `created_by` | | `ABP_CREATION_USER` | |
| `created_at` | | `ABP_CREATION_TSTMPL` | |
| `last_changed_by` | | `ABP_LASTCHANGE_USER` | |
| `last_changed_at` | | `ABP_LASTCHANGE_TSTMPL` | total etag |
| `local_last_changed_at` | | `ABP_LOCINST_LASTCHANGE_TSTMPL` | etag master (ใหม่) |

### Message ของ `ZBCGRAPHIC`

| No. | ข้อความ (EN) |
|---|---|
| 001 | MIME type &1 is not allowed. Upload a JPEG or PNG file. |
| 002 | File &1 must have extension .jpg, .jpeg or .png. |
| 003 | Graphic name &1 already exists. |

## Phase 2 — Business object

> confirm 2026-10-02 · CDS alias: `Uuid` `GraphicName` `FileName` `MimeType` `GraphicContent` `IsActive` `CreatedBy` `CreatedAt` `LastChangedBy` `LastChangedAt` `LocalLastChangedAt` + virtual `ImageUrl`
> behavior: `setInitialValues` (IsActive = X) · `deriveMimeTypeOnModify` · `defaultGraphicNameOnSave` / `OnModify` (ตัดนามสกุล + ตัวพิมพ์ใหญ่) · `validateMimeType` · `validateGraphicName` (ห้ามซ้ำทั้ง table) · auth global อย่างเดียว · etag master `LocalLastChangedAt` / total etag `LastChangedAt`

| Object | Type | Clone จาก | หน้าที่ | Status |
|---|---|---|---|---|
| `ZR_GRAPHIC` | CDS root view entity | `YR_GRAPHIC` | interface ของ table | ⬜ |
| `ZR_GRAPHIC` | BDEF managed + draft | `YR_GRAPHIC` | behavior หลัก | ⬜ |
| `ZTBC_GRAPHIC_D` | Draft table | `YTBC_GRAPHIC_D` | สร้างจาก quick fix ของ BDEF | ⬜ |
| `ZBP_R_GRAPHIC` | Behavior pool | `YBP_R_GRAPHIC` | `lhc_Graphic` | ⬜ |
| `ZCL_GRAPHIC_IMAGE_URL` | Class (virtual element) | `YCL_IMAGE_URL` | คำนวณ `ImageUrl` สำหรับ preview | ⬜ |
| `ZC_GRAPHIC` | CDS projection | `YC_GRAPHIC` | สำหรับ UI | ⬜ |
| `ZC_GRAPHIC` | BDEF projection | `YC_GRAPHIC` | | ⬜ |
| `ZC_GRAPHIC` | Metadata extension | `YC_GRAPHIC` | layout Fiori Elements | ⬜ |

## Phase 3 — Service + ทดสอบ

| Object | Type | Clone จาก | หน้าที่ | Status |
|---|---|---|---|---|
| `ZUI_GRAPHIC` | Service definition | `YUI_GRAPHIC` | expose `ZC_GRAPHIC as Graphic` | ⬜ |
| `ZUI_GRAPHIC_O4` | Service binding OData V4 UI | `YUI_GRAPHIC_O4` | publish + preview | ⬜ |
| SCO2 / SUSH ของ binding | generated | — | SAP สร้างตอน publish | ⬜ |
| Fiori app (BAS · List Report OData V4) | — | — | deploy ขึ้น tenant · ชื่อ app / BSP ตั้งตอนสรุป phase | ⬜ |
| IAM app | — | — | ผูก service + Fiori app | ⬜ |
| Business catalog | — | — | ผูก IAM app ให้ assign ผ่าน business role | ⬜ |

## Phase 4 — Utility method (repo `fplus-zbcutility`)

| Object | Type | หน้าที่ | Status |
|---|---|---|---|
| `ZCL_UTILITY=>get_form_graphic( )` | Method ใหม่ | รับ `graphic_name` -> คืน `graphic_content` ของรูปที่ `is_active = X` | ⬜ |
| `ZCL_UTILITY=>get_form_graphic_base64( )` | Method ใหม่ | เหมือนตัวบนแต่คืน base64 string สำหรับ XML data ของ Adobe Form | ⬜ |
| `ZCL_UTILITY` testclasses | ABAP Unit | test ด้วย SQL test double | ⬜ |
