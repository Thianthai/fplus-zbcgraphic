# 04 — การเรียกใช้รูปใน Adobe Form

Method อยู่ใน `ZCL_UTILITY` (package `ZBCUTILITY` · repo `fplus-zbcutility`)

| Method | คืนค่า | ใช้เมื่อ |
|---|---|---|
| `get_form_graphic( iv_graphic_name )` | `ze_graphic_content` (xstring) | ข้อมูลของ form เป็น structure แล้วให้ระบบแปลงเป็น XML (xstring ถูกเข้ารหัสเป็น base64 ให้เอง) |
| `get_form_graphic_base64( iv_graphic_name )` | `string` (base64) | ประกอบ XML เอง หรือ field ปลายทางเป็น string |

ทั้งสอง method:
- แปลง `iv_graphic_name` เป็นตัวพิมพ์ใหญ่ก่อนค้น — ส่ง `'logo'` หรือ `'LOGO'` ได้ผลเหมือนกัน
- คืนเฉพาะรูปที่ `is_active = X`
- ไม่เจอชื่อ หรือรูปไม่ active -> คืนค่าว่าง **ไม่โยน exception** caller ตัดสินเอง

## แบบที่ 1 — `get_form_graphic( )` ได้ xstring

```abap
    TYPES:
      "! ข้อมูลที่ส่งเข้า Adobe Form
      BEGIN OF ty_form_data,
        company_name TYPE string,
        logo         TYPE xstring,
      END OF ty_form_data.

    DATA ls_form_data TYPE ty_form_data.

    " ดึงรูปตามชื่อที่ตั้งไว้ในแอป Maintain Form Graphics
    " ส่งชื่อตัวพิมพ์เล็กได้ เพราะ method แปลงเป็นตัวพิมพ์ใหญ่ให้เอง
    ls_form_data-logo = zcl_utility=>get_form_graphic( 'LOGO' ).

    " ไม่เจอชื่อ หรือรูปไม่ active -> ได้ค่าว่าง โดยไม่โยน exception
    " caller ต้องตัดสินเองว่าจะพิมพ์ต่อโดยไม่มีรูป หรือหยุดพร้อมแจ้ง error
    IF ls_form_data-logo IS INITIAL.
      " ตัวอย่างนี้เลือกพิมพ์ต่อโดยเว้นช่องรูปไว้
    ENDIF.

    " ตอนแปลง structure เป็น XML ระบบจะเข้ารหัส field ที่เป็น xstring เป็น base64 ให้เอง
    CALL TRANSFORMATION id
      SOURCE form = ls_form_data
      RESULT XML DATA(lv_xml_data).
```

## แบบที่ 2 — `get_form_graphic_base64( )` ได้ base64 string

```abap
    " ดึงรูปเป็น base64 พร้อมใส่ใน XML data ของ Adobe Form ได้ทันที
    DATA(lv_logo_base64) = zcl_utility=>get_form_graphic_base64( 'LOGO' ).

    " ไม่เจอชื่อ หรือรูปไม่ active -> ได้ string ว่าง
    " ถ้าใส่ node ว่างลงไป ช่องรูปใน form จะว่างแต่ไม่ error
    IF lv_logo_base64 IS INITIAL.
      " ตัวอย่างนี้เลือกพิมพ์ต่อโดยเว้นช่องรูปไว้
    ENDIF.

    " ชื่อ node ต้องตรงกับ data binding ของ Image Field ใน layout
    " base64 มีแค่ A-Z a-z 0-9 + / = จึงใส่ใน XML ได้โดยไม่ต้อง escape
    DATA(lv_xml_data) = |<form>|
                     && |<company_name>{ escape( val = lv_company_name format = cl_abap_format=>e_xml_text ) }</company_name>|
                     && |<logo>{ lv_logo_base64 }</logo>|
                     && |</form>|.
```

## ฝั่ง layout ของ Adobe Form

- ใช้ field ชนิด **Image Field** แล้ว bind กับ node ของรูป (เช่น `logo`)
- ข้อมูลใน node ต้องเป็น base64 — ทั้งสองแบบได้ base64 เหมือนกัน
  (แบบ 1 ระบบแปลงตอนทำ XML · แบบ 2 method แปลงให้)

## ข้อควรระวัง

- **ชื่อรูปเป็นค่าคงที่ใน code ของ form** — ถ้ามีคนเปลี่ยนชื่อรูปในแอป form จะได้ค่าว่างโดยไม่มี error
  แนะนำให้ประกาศชื่อเป็น constant ที่เดียวใน class ของ form
- **ปิด active = form ได้ค่าว่าง** — ชื่อห้ามซ้ำทั้ง table จึงสร้าง record ใหม่ชื่อเดิมไม่ได้
  ถ้าจะเปลี่ยนรูป ให้ edit record เดิมแล้ว upload ไฟล์ใหม่ทับ
- **ยังไม่ได้ทดสอบ XML ทั้งสองแบบกับ form จริง** (2026-10-02)
  `CALL TRANSFORMATION id` ให้ XML แบบ asXML (มี `<asx:abap>` ครอบ) ซึ่งอาจไม่ตรงกับ data schema ของ form
  ต้องเทียบกับ XSD / data schema ของ form ของ RICEFW ที่ใช้ก่อน — ทดสอบแล้วให้อัปเดตหัวข้อนี้
