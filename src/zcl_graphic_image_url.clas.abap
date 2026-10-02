"! Virtual element ImageUrl ของ ZC_GRAPHIC
"! ImageUrl ชี้ไปที่ stream ของ GraphicContent ใน service ZUI_GRAPHIC_O4
"! list report ใช้ URL นี้แสดงรูป preview
CLASS zcl_graphic_image_url DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    INTERFACES if_sadl_exit_calc_element_read.

  PRIVATE SECTION.

    TYPES:
      "! field ของ ZC_GRAPHIC ที่ใช้คำนวณ และผลลัพธ์ ImageUrl
      BEGIN OF ty_graphic,
        uuid     TYPE sysuuid_x16,
        imageurl TYPE c LENGTH 256,
      END OF ty_graphic,

      "! รายการของ ty_graphic
      tt_graphic TYPE STANDARD TABLE OF ty_graphic WITH EMPTY KEY.

    CONSTANTS:
      "! path ของ entity Graphic ใน service ZUI_GRAPHIC_O4
      "! ถ้าเปลี่ยนชื่อ service binding หรือ version ต้องแก้ตรงนี้ด้วย
      gc_entity_path TYPE string VALUE `/sap/opu/odata4/sap/zui_graphic_o4/srvd/sap/zui_graphic/0001/Graphic`.

    "! แปลง UUID แบบ hex 16 byte เป็นรูปแบบ GUID ของ OData V4 (ตัวพิมพ์เล็กมีขีด)
    "! @parameter iv_hex_uuid    | UUID แบบ hex
    "! @parameter rv_guid_string | GUID เช่น 1d80569d-c3b1-4f7c-8fd4-bc8b7e3e5c4a
    METHODS format_guid
      IMPORTING iv_hex_uuid           TYPE sysuuid_x16
      RETURNING VALUE(rv_guid_string) TYPE string.

ENDCLASS.



CLASS zcl_graphic_image_url IMPLEMENTATION.

  METHOD if_sadl_exit_calc_element_read~calculate.

    DATA(lt_graphics) = CORRESPONDING tt_graphic( it_original_data ).

    LOOP AT lt_graphics ASSIGNING FIELD-SYMBOL(<lfs_graphic>) WHERE uuid IS NOT INITIAL.
      <lfs_graphic>-imageurl = |{ gc_entity_path }(Uuid={ format_guid( <lfs_graphic>-uuid ) },IsActiveEntity=true)/GraphicContent|.
    ENDLOOP.

    ct_calculated_data = CORRESPONDING #( lt_graphics ).

  ENDMETHOD.


  METHOD if_sadl_exit_calc_element_read~get_calculation_info.

    " ImageUrl ต้องใช้ Uuid อย่างเดียว
    et_requested_orig_elements = VALUE #( ( `UUID` ) ).

  ENDMETHOD.


  METHOD format_guid.

    DATA(lv_uuid_hex) = to_lower( |{ iv_hex_uuid }| ).

    rv_guid_string = |{ lv_uuid_hex+0(8) }-{ lv_uuid_hex+8(4) }-{ lv_uuid_hex+12(4) }-{ lv_uuid_hex+16(4) }-{ lv_uuid_hex+20(12) }|.

  ENDMETHOD.

ENDCLASS.
