"! Handler ของ entity Graphic ใน ZR_GRAPHIC
CLASS lhc_Graphic DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    TYPES:
      "! ผลการอ่าน entity Graphic สำหรับส่งต่อให้ helper
      tt_graphic_read TYPE TABLE FOR READ RESULT zr_graphic\\Graphic.

    CONSTANTS:
      "! message class และเลข message ของ package ZBCGRAPHIC
      gc_msgid                  TYPE symsgid VALUE 'ZBCGRAPHIC',
      gc_msgno_mime_not_allowed TYPE symsgno VALUE '001',
      gc_msgno_file_extension   TYPE symsgno VALUE '002',
      gc_msgno_name_exists      TYPE symsgno VALUE '003'.

    CONSTANTS:
      "! MIME type ที่อนุญาตให้ upload
      gc_mime_jpeg TYPE string VALUE `image/jpeg`,
      gc_mime_jpg  TYPE string VALUE `image/jpg`,
      gc_mime_png  TYPE string VALUE `image/png`.

    CONSTANTS:
      "! state area ของ message จาก validation
      gc_state_mime TYPE string VALUE `VALIDATE_MIMETYPE`,
      gc_state_name TYPE string VALUE `VALIDATE_GRAPHICNAME`.

    "! อนุญาตทุก operation
    "! สิทธิ์เข้าแอปคุมด้วย business role ผ่าน IAM app
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      REQUEST requested_authorizations FOR Graphic RESULT result.

    "! ตั้ง IsActive = X ให้รูปที่สร้างใหม่
    METHODS setInitialValues FOR DETERMINE ON MODIFY
      keys FOR Graphic~setInitialValues.

    "! เดา MIME type จากนามสกุลไฟล์เมื่อ FileName เปลี่ยน
    METHODS deriveMimeTypeOnModify FOR DETERMINE ON MODIFY
      keys FOR Graphic~deriveMimeTypeOnModify.

    "! เติม GraphicName จาก FileName ตอน save ถ้ายังว่าง
    METHODS defaultGraphicNameOnSave FOR DETERMINE ON SAVE
      keys FOR Graphic~defaultGraphicNameOnSave.

    "! เติม GraphicName จาก FileName ถ้ายังว่าง และแปลง GraphicName เป็นตัวพิมพ์ใหญ่
    METHODS defaultGraphicNameOnModify FOR DETERMINE ON MODIFY
      keys FOR Graphic~defaultGraphicNameOnModify.

    "! ตรวจว่า MIME type และนามสกุลไฟล์เป็น JPEG หรือ PNG
    METHODS validateMimeType FOR VALIDATE ON SAVE
      keys FOR Graphic~validateMimeType.

    "! ตรวจว่า GraphicName ไม่ซ้ำกับรูปอื่นใน ZTBC_GRAPHIC
    METHODS validateGraphicName FOR VALIDATE ON SAVE
      keys FOR Graphic~validateGraphicName.

    "! เดา MIME type จากนามสกุลของ FileName แล้ว update ถ้าต่างจากค่าเดิม
    "! @parameter it_graphics | instance ที่อ่านมาพร้อม FileName และ MimeType
    METHODS derive_and_update_mime
      IMPORTING it_graphics TYPE tt_graphic_read.

    "! เติม GraphicName จาก FileName ที่ตัดนามสกุลออกถ้ายังว่าง
    "! ถ้ามีค่าอยู่แล้วให้แปลงเป็นตัวพิมพ์ใหญ่
    "! @parameter it_graphics | instance ที่อ่านมาพร้อม FileName และ GraphicName
    METHODS normalize_graphic_name
      IMPORTING it_graphics TYPE tt_graphic_read.

ENDCLASS.


CLASS lhc_Graphic IMPLEMENTATION.

  METHOD get_global_authorizations.

    result = VALUE #( %create = if_abap_behv=>auth-allowed
                      %update = if_abap_behv=>auth-allowed
                      %delete = if_abap_behv=>auth-allowed ).

  ENDMETHOD.


  METHOD setInitialValues.

    READ ENTITIES OF zr_graphic IN LOCAL MODE
      ENTITY Graphic
        FIELDS ( IsActive )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_graphics).

    " เติมเฉพาะ instance ที่ยังไม่มีค่า
    DELETE lt_graphics WHERE IsActive IS NOT INITIAL.

    IF lt_graphics IS INITIAL.
      RETURN.
    ENDIF.

    MODIFY ENTITIES OF zr_graphic IN LOCAL MODE
      ENTITY Graphic
        UPDATE FIELDS ( IsActive )
        WITH VALUE #( FOR ls_graphic IN lt_graphics
                      ( %tky     = ls_graphic-%tky
                        IsActive = abap_true ) ).

  ENDMETHOD.


  METHOD deriveMimeTypeOnModify.

    " หน้าที่หลักคือเดา MIME type จากนามสกุลไฟล์ เผื่อ framework เติมจาก Content-Type ไม่ได้
    " ผลข้างเคียงที่ตั้งใจคือ MODIFY ในนี้ทำให้ stream PATCH คืน entity เต็มแทน 204
    " Fiori Elements จึงแสดงไฟล์ที่ upload ทันทีโดยไม่ต้อง refresh หน้า
    READ ENTITIES OF zr_graphic IN LOCAL MODE
      ENTITY Graphic
        FIELDS ( FileName MimeType )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_graphics).

    derive_and_update_mime( lt_graphics ).

  ENDMETHOD.


  METHOD defaultGraphicNameOnSave.

    READ ENTITIES OF zr_graphic IN LOCAL MODE
      ENTITY Graphic
        FIELDS ( FileName GraphicName )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_graphics).

    normalize_graphic_name( lt_graphics ).

  ENDMETHOD.


  METHOD defaultGraphicNameOnModify.

    READ ENTITIES OF zr_graphic IN LOCAL MODE
      ENTITY Graphic
        FIELDS ( FileName GraphicName )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_graphics).

    normalize_graphic_name( lt_graphics ).

  ENDMETHOD.


  METHOD validateMimeType.

    READ ENTITIES OF zr_graphic IN LOCAL MODE
      ENTITY Graphic
        FIELDS ( MimeType FileName )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_graphics).

    LOOP AT lt_graphics INTO DATA(ls_graphic).

      " ล้าง message เก่าของ state area นี้ก่อนตรวจใหม่
      APPEND VALUE #( %tky        = ls_graphic-%tky
                      %state_area = gc_state_mime
                    ) TO reported-graphic.

      DATA(lv_mime_lower) = to_lower( ls_graphic-MimeType ).
      DATA(lv_file_lower) = to_lower( ls_graphic-FileName ).

      IF lv_mime_lower <> gc_mime_jpeg
     AND lv_mime_lower <> gc_mime_jpg
     AND lv_mime_lower <> gc_mime_png.

        APPEND VALUE #( %tky = ls_graphic-%tky ) TO failed-graphic.

        APPEND VALUE #( %tky              = ls_graphic-%tky
                        %state_area       = gc_state_mime
                        %msg              = new_message( id       = gc_msgid
                                                         number   = gc_msgno_mime_not_allowed
                                                         severity = if_abap_behv_message=>severity-error
                                                         v1       = ls_graphic-MimeType )
                        %element-MimeType = if_abap_behv=>mk-on
                      ) TO reported-graphic.

        CONTINUE.
      ENDIF.

      IF NOT ( lv_file_lower CP '*.jpg' OR lv_file_lower CP '*.jpeg' OR lv_file_lower CP '*.png' ).

        APPEND VALUE #( %tky = ls_graphic-%tky ) TO failed-graphic.

        APPEND VALUE #( %tky              = ls_graphic-%tky
                        %state_area       = gc_state_mime
                        %msg              = new_message( id       = gc_msgid
                                                         number   = gc_msgno_file_extension
                                                         severity = if_abap_behv_message=>severity-error
                                                         v1       = ls_graphic-FileName )
                        %element-FileName = if_abap_behv=>mk-on
                      ) TO reported-graphic.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD validateGraphicName.

    READ ENTITIES OF zr_graphic IN LOCAL MODE
      ENTITY Graphic
        FIELDS ( GraphicName )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_graphics).

    LOOP AT lt_graphics INTO DATA(ls_graphic).

      " ล้าง message เก่าของ state area นี้ก่อนตรวจใหม่
      APPEND VALUE #( %tky        = ls_graphic-%tky
                      %state_area = gc_state_name
                    ) TO reported-graphic.

      IF ls_graphic-GraphicName IS INITIAL.
        CONTINUE.
      ENDIF.

      " ชื่อต้องไม่ซ้ำทั้ง table ไม่ว่ารูปนั้นจะ active หรือไม่
      " ไม่นับ record ของตัวเองตอนแก้ไขรูปเดิม
      SELECT SINGLE @abap_true
        FROM ztbc_graphic
        WHERE graphic_name = @ls_graphic-GraphicName
          AND uuid        <> @ls_graphic-Uuid
        INTO @DATA(lv_name_exists).

      IF lv_name_exists = abap_false.
        CONTINUE.
      ENDIF.

      APPEND VALUE #( %tky = ls_graphic-%tky ) TO failed-graphic.

      APPEND VALUE #( %tky                 = ls_graphic-%tky
                      %state_area          = gc_state_name
                      %msg                 = new_message( id       = gc_msgid
                                                          number   = gc_msgno_name_exists
                                                          severity = if_abap_behv_message=>severity-error
                                                          v1       = ls_graphic-GraphicName )
                      %element-GraphicName = if_abap_behv=>mk-on
                    ) TO reported-graphic.

      CLEAR lv_name_exists.

    ENDLOOP.

  ENDMETHOD.


  METHOD derive_and_update_mime.

    DATA lt_update TYPE TABLE FOR UPDATE zr_graphic\\Graphic.

    " ข้าม instance ที่ยังไม่มี FileName
    LOOP AT it_graphics INTO DATA(ls_graphic) WHERE FileName IS NOT INITIAL.

      DATA(lv_file_lower) = to_lower( ls_graphic-FileName ).

      DATA(lv_derived_mime) = COND ze_graphic_mime_type(
                                WHEN lv_file_lower CP '*.jpg' OR lv_file_lower CP '*.jpeg'
                                  THEN gc_mime_jpeg
                                WHEN lv_file_lower CP '*.png'
                                  THEN gc_mime_png ).

      " update เฉพาะเมื่อเดาได้ และต่างจากค่าเดิม
      IF lv_derived_mime IS INITIAL OR lv_derived_mime = ls_graphic-MimeType.
        CONTINUE.
      ENDIF.

      APPEND VALUE #( %tky              = ls_graphic-%tky
                      MimeType          = lv_derived_mime
                      %control-MimeType = if_abap_behv=>mk-on
                    ) TO lt_update.

    ENDLOOP.

    IF lt_update IS INITIAL.
      RETURN.
    ENDIF.

    MODIFY ENTITIES OF zr_graphic IN LOCAL MODE
      ENTITY Graphic
        UPDATE FROM lt_update.

  ENDMETHOD.


  METHOD normalize_graphic_name.

    DATA lt_update TYPE TABLE FOR UPDATE zr_graphic\\Graphic.

    LOOP AT it_graphics INTO DATA(ls_graphic).

      DATA(lv_graphic_name) = to_upper( ls_graphic-GraphicName ).

      " ถ้ายังไม่มีชื่อ ให้ใช้ชื่อไฟล์ที่ตัดนามสกุลออก
      " ถ้าชื่อไฟล์ไม่มีจุด ให้ใช้ชื่อไฟล์ทั้งหมด
      IF lv_graphic_name IS INITIAL AND ls_graphic-FileName IS NOT INITIAL.
        lv_graphic_name = substring_before( val = ls_graphic-FileName
                                            sub = '.'
                                            occ = -1 ).
        IF lv_graphic_name IS INITIAL.
          lv_graphic_name = ls_graphic-FileName.
        ENDIF.
        lv_graphic_name = to_upper( lv_graphic_name ).
      ENDIF.

      " update เฉพาะเมื่อค่าเปลี่ยนจริง กัน determination วนซ้ำ
      IF lv_graphic_name = ls_graphic-GraphicName.
        CONTINUE.
      ENDIF.

      APPEND VALUE #( %tky                 = ls_graphic-%tky
                      GraphicName          = lv_graphic_name
                      %control-GraphicName = if_abap_behv=>mk-on
                    ) TO lt_update.

    ENDLOOP.

    IF lt_update IS INITIAL.
      RETURN.
    ENDIF.

    MODIFY ENTITIES OF zr_graphic IN LOCAL MODE
      ENTITY Graphic
        UPDATE FROM lt_update.

  ENDMETHOD.

ENDCLASS.
