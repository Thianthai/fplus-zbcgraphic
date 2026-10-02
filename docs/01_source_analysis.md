# 01 — วิเคราะห์ source YGRAPHIC

Source: https://github.com/Thianthai/demo-ygraphic.git (commit `e337d98`, package `YGRAPHIC`)

## Object ใน source

| Object | Type | หน้าที่ |
|---|---|---|
| `YE_GRAPHICNAME` | Data element (domain `/DMO/FILENAME`) | ชื่อรูป |
| `YTBC_GRAPHIC` | Table (client-dep., key `client` + `uuid`) | เก็บรูป |
| `YTBC_GRAPHIC_D` | Draft table | draft ของ `YR_GRAPHIC` |
| `YR_GRAPHIC` | CDS root view entity | interface ของ table |
| `YC_GRAPHIC` | CDS projection (transactional_query) | สำหรับ UI · มี virtual element `ImageUrl` |
| `YC_GRAPHIC` | Metadata extension | layout Fiori Elements (list + object page) |
| `YR_GRAPHIC` | BDEF managed + draft | determination 5 ตัว · validation 1 ตัว |
| `YC_GRAPHIC` | BDEF projection | use create/update/delete + draft action |
| `YBP_R_GRAPHIC` | Behavior pool | `lhc_Graphic` |
| `YCL_IMAGE_URL` | Class (`IF_SADL_EXIT_CALC_ELEMENT_READ`) | คำนวณ `ImageUrl` = URL stream ของ `Attachment` ให้ list แสดง preview |
| `YUI_GRAPHIC` | Service definition | expose `YC_GRAPHIC as Graphic` |
| `YUI_GRAPHIC_O4` | Service binding OData V4 UI | published |
| `YUI_GRAPHIC_O4_0001_G4BA` (SCO2) · `3FD4…HT` (SUSH) | generated | SAP สร้างให้ตอน publish binding — ไม่ต้องสร้างเอง |

### Field ของ table

| Field | Data element | หมายเหตุ |
|---|---|---|
| `client` | — (CLNT) | key |
| `uuid` | `SYSUUID_X16` | key · managed numbering |
| `attachment` | `/DMO/ATTACHMENT` | rawstring — ตัวรูป |
| `mime_type` | `/DMO/MIME_TYPE` | |
| `file_name` | `/DMO/FILENAME` | |
| `graphic_name` | `YE_GRAPHICNAME` | ชื่อที่ form ใช้ค้น |
| `isactive` | `ABAP_BOOLEAN` | |
| `created_by` / `created_at` / `last_changed_by` / `last_changed_at` | `ABP_*` | admin |

### Behavior ใน `YBP_R_GRAPHIC`

| ชื่อ | trigger | ทำอะไร |
|---|---|---|
| `setAdminData` | on save / create | เติม created/changed by/at เอง |
| `setLastChangedData` | on modify / FileName MimeType GraphicName IsActive | เติม last changed by/at เอง |
| `deriveMimeTypeOnModify` | on modify / FileName | เดา MIME จากนามสกุล · **ผลข้างเคียงที่ตั้งใจ**: บังคับให้ stream PATCH คืน entity เต็ม -> Fiori refresh field รูปทันที |
| `defaultGraphicNameOnSave` / `OnModify` | on save create / on modify FileName | ถ้า GraphicName ว่าง ให้ใช้ FileName |
| `validateMimeType` | on save / create + MimeType FileName | อนุญาต jpeg / jpg / png เท่านั้น |
| auth | global + instance | allowed ทั้งหมด |

## สิ่งที่พบ และสิ่งที่ทำตอน clone (ตกลงแล้ว 2026-10-02)

| # | เรื่อง | ใน source | ข้อเสนอ |
|---|---|---|---|
| F1 | URL service hard-code ใน `YCL_IMAGE_URL` | `/sap/opu/odata4/sap/yui_graphic_o4/srvd/sap/yui_graphic/0001` | **ต้องเปลี่ยน** เป็นชื่อ Z — ไม่งั้น preview ชี้ไป service เก่า |
| F2 | message ของ `validateMimeType` | `/dmo/cm_flight_messages=>not_authorized` -> ผู้ใช้เห็นข้อความ "not authorized" ซึ่งไม่ตรงเรื่อง | สร้าง message class ของ package นี้ ใช้ `new_message( )` |
| F3 | พึ่ง `/DMO/*` (data element 3 ตัว + message class) | `/DMO` เป็น demo content | แทนด้วย domain + data element `Z*` ของ package เอง |
| F4 | `graphic_name` ซ้ำได้ | ไม่มี validation | utility ค้นด้วยชื่อ -> ถ้าซ้ำและ active หลายตัวจะได้รูปไม่แน่นอน -> เพิ่ม validation ห้ามซ้ำทั้ง table |
| F5 | admin field เติมเองด้วย determination | `setAdminData` / `setLastChangedData` | managed RAP เติม field ที่มี `@Semantics.user/systemDateTime` ให้เองอยู่แล้ว -> ตัดออก |
| F6 | etag | `lock master total etag LastChangedAt` + `etag master LastChangedAt` ใช้ field เดียวกัน | แบบมาตรฐานของ draft คือเพิ่ม `local_last_changed_at` เป็น etag master -> ทำตามนั้น |
| F7 | naming ใน code | `DATA(key)`, `<data>`, ไม่มี ABAP Doc | ปรับให้ตรงกฎกลาง (`ls_key`, `<lfs_data>`, `"!`) |
| F8 | comment block / code ที่ comment ทิ้ง | `deriveMimeTypeOnSave`, lineItem ของ FileName | ไม่ยกมา |
| F9 | `validateMimeType` trigger | `create; field MimeType, FileName` | ok — คงไว้ |
| F11 | ชื่อ field / data element | `isactive` · `attachment` · `YE_GRAPHICNAME` · `/DMO/ATTACHMENT` | เปลี่ยนเป็น `is_active` · `graphic_content` · `ZE_GRAPHIC_NAME` · `ZE_GRAPHIC_CONTENT` (ผู้ใช้สั่ง) |
| F12 | primary key ของ table | ไม่ได้ระบุ | ต้องใส่ `@AbapCatalog.primaryKey.invertedIndividualIndex : true` ไม่งั้นได้ warning `Key must have the type Inverted Individual on the database` |
| F10 | MIME `image/jpg` | อยู่ใน acceptableMimeTypes และ allowed list | ไม่ใช่ MIME มาตรฐานแต่ browser บางตัวส่งมา -> คงไว้ |
