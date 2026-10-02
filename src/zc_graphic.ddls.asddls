@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Maintain Form Graphics'
@Metadata.allowExtensions: true
@Search.searchable: true
@ObjectModel.semanticKey: [ 'GraphicName' ]
define root view entity ZC_GRAPHIC
  provider contract transactional_query
  as projection on ZR_GRAPHIC
{
  key Uuid,

      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      GraphicName,

      FileName,

      @Semantics.mimeType: true
      MimeType,

      @Semantics.largeObject:
        { mimeType: 'MimeType',
          fileName: 'FileName',
          contentDispositionPreference: #INLINE,
          acceptableMimeTypes: [ 'image/jpeg', 'image/jpg', 'image/png' ] }
      GraphicContent,

      @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_GRAPHIC_IMAGE_URL'
      @Semantics.imageUrl: true
      virtual ImageUrl : abap.char( 256 ),

      IsActive,

      CreatedBy,

      CreatedAt,

      LastChangedBy,

      LastChangedAt,

      LocalLastChangedAt
}
