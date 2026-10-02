@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Maintain Form Graphics'
@Metadata.allowExtensions: true
define root view entity ZR_GRAPHIC
  as select from ztbc_graphic
{
  key uuid                  as Uuid,

      graphic_name          as GraphicName,

      file_name             as FileName,

      @Semantics.mimeType: true
      mime_type             as MimeType,

      @Semantics.largeObject:
        { mimeType: 'MimeType',
          fileName: 'FileName',
          contentDispositionPreference: #INLINE,
          acceptableMimeTypes: [ 'image/jpeg', 'image/jpg', 'image/png' ] }
      graphic_content       as GraphicContent,

      is_active             as IsActive,

      @Semantics.user.createdBy: true
      created_by            as CreatedBy,

      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,

      @Semantics.user.lastChangedBy: true
      last_changed_by       as LastChangedBy,

      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,

      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt
}
