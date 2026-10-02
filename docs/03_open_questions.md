# 03 — Open Questions

| # | เรื่อง | ข้อสรุป | สถานะ |
|---|---|---|---|
| OQ-01 | ชื่อ object / `<APP>` | RAP ใช้ชื่อ source เปลี่ยน Y -> Z (`ZR_GRAPHIC` `ZC_GRAPHIC` `ZUI_GRAPHIC_O4` `ZBP_R_GRAPHIC`) · table `ZTBC_GRAPHIC` · class virtual element `ZCL_GRAPHIC_IMAGE_URL` · data element `ZE_GRAPHIC_NAME` (ไม่ใช่ `ZE_GRAPHICNAME`) · field `is_active` (ไม่ใช่ `isactive`) | ✅ 2026-10-02 |
| OQ-02 | เลิกพึ่ง `/DMO/*` | สร้าง domain + data element `Z*` เอง | ✅ 2026-10-02 |
| OQ-03 | `graphic_name` ซ้ำได้ไหม | **ห้ามซ้ำทั้ง table** (ไม่ว่า active หรือไม่) -> validation ใน BDEF | ✅ 2026-10-02 |
| OQ-04 | clone ตรง ๆ หรือ clean-up behavior | **clean-up**: ตัด `setAdminData` / `setLastChangedData` ให้ managed เติมเอง · เพิ่ม `local_last_changed_at` เป็น etag master · คง `deriveMimeTypeOnModify` (ช่วย refresh UI) | ✅ 2026-10-02 |
| OQ-05 | ผู้ใช้จริงเข้าแอปทางไหน | ทำ **Fiori app + IAM app + business catalog** ครบ (phase 3) | ✅ 2026-10-02 |
| OQ-06 | signature ของ utility | `get_form_graphic( iv_graphic_name ) RETURNING rv_graphic_content TYPE xstring` · ไม่เจอ = ค่าว่าง · **เพิ่ม `get_form_graphic_base64( )` คู่กัน** | ✅ 2026-10-02 |
| OQ-07 | unit test ของ utility | ใช้ `cl_osql_test_environment` จำลอง table ไม่แตะข้อมูลจริง | ✅ 2026-10-02 · test class แยก `ltc_form_graphic` · อ่านจาก table ตรง |
| OQ-08 | ข้อมูลใน `YTBC_GRAPHIC` | **ไม่ใช้ข้อมูลเดิม** upload ใหม่ | ✅ 2026-10-02 |
| OQ-09 | ตัวพิมพ์เล็ก/ใหญ่ของ `graphic_name` | **แบบ B**: domain `ZD_GRAPHIC_NAME` ไม่รับตัวพิมพ์เล็ก -> เก็บเป็นตัวพิมพ์ใหญ่ · utility แปลง `iv_graphic_name` เป็นตัวพิมพ์ใหญ่ก่อนค้น | ✅ 2026-10-02 |
| OQ-10 | GraphicName ที่ default จาก FileName | **ตัดนามสกุลไฟล์** แล้วแปลงเป็นตัวพิมพ์ใหญ่ (`logo.png` -> `LOGO`) | ✅ 2026-10-02 |
| OQ-11 | ค่าเริ่มต้นของ IsActive ตอน create | **default `X`** -> determination `setInitialValues` | ✅ 2026-10-02 |
| OQ-12 | Authorization | `authorization master ( global )` อย่างเดียว อนุญาตทุก operation · สิทธิ์เข้าแอปคุมด้วย business role | ✅ 2026-10-02 |
