<!-- ============================================================= -->
<!--                    PUBLIC DOCUMENT TYPE DEFINITION            -->
<!--                    TYPICAL INVOCATION                         -->
<!--                                                               -->
<!--  Refer to this file by the following public identfier or an 
      appropriate system identifier 
PUBLIC "-//TEUX//ELEMENTS DITA Photo File//RU"
      Delivered as file "photo.mod"                                -->


<!-- ============================================================= -->
<!--                   ARCHITECTURE ENTITIES                       -->
<!-- ============================================================= -->

<!-- default namespace prefix for DITAArchVersion attribute can be
     overridden through predefinition in the document type shell   -->
<!ENTITY % DITAArchNSPrefix
                       "ditaarch"                                    >
					   
<!-- must be instanced on each topic type                          -->
<!ENTITY % arch-atts "
             xmlns:%DITAArchNSPrefix; 
                        CDATA                              #FIXED
                       'http://dita.oasis-open.org/architecture/2005/'
             %DITAArchNSPrefix;:DITAArchVersion
                        CDATA                              #FIXED
                       '1.0'"                                        >


<!-- ============================================================= -->
<!--                   SPECIALIZATION OF DECLARED ELEMENTS         -->
<!-- ============================================================= -->

<!ENTITY % photo-info-types ""        	               >

<!-- ============================================================= -->
<!--                   ELEMENT NAME ENTITIES                       -->
<!-- ============================================================= -->

<!ENTITY % photoFile "photoFile">
<!ENTITY % photoBody "photoBody">
<!ENTITY % photoSection "photoSection">
<!ENTITY % expandSection "expandSection">
<!ENTITY % storySection "storySection">
<!ENTITY % everyTrail "everyTrail">
<!ENTITY % youTube "youTube">
<!ENTITY % floatFig "floatFig">
<!ENTITY % clearFloat "clearFloat">

<!ENTITY % storySection.cnt "%p; | %note; | %ul; | %ol; | %pr-d-pre; |
	%fig; | %table; | %simpletable; | %pre; | %floatFig; | %clearFloat;">

<!-- ============================================================= -->
<!--                    DOMAINS ATTRIBUTE OVERRIDE                 -->
<!-- ============================================================= -->

<!ENTITY included-domains ""                                         >

<!-- ============================================================= -->
<!--                    ELEMENT DECLARATIONS                       -->
<!-- ============================================================= -->

<!ELEMENT photoFile     (%title;, (%titlealts;)?, (%shortdesc;)?, 
                         (%prolog;)?, (%photoBody;)?, (%photo-info-types;)* )                     >
<!ATTLIST photoFile
             id         ID                               #REQUIRED
             conref     CDATA                            #IMPLIED
             %select-atts;
             xml:lang   NMTOKEN                          #IMPLIED
             %arch-atts;
             domains    CDATA                  "&included-domains;"
             outputclass 
                        CDATA                            #IMPLIED    >

<!ELEMENT photoBody       ((%storySection.cnt;)*, (%section; | %photoSection; | %expandSection; | %storySection;)* )>

<!ATTLIST photoBody         
             %id-atts;
             xml:lang   NMTOKEN                          #IMPLIED
             outputclass 
                        CDATA                            #IMPLIED   >

<!ELEMENT photoSection     ((%title;)?, p*, ((%fig;) | (%object;))*) >						
<!ATTLIST photoSection
			%id-atts;
			outputclass 
                       CDATA                            #IMPLIED
			base       CDATA                            #IMPLIED			
			%redim-d-attribute;
			%phsize-d-attribute;									>

<!ELEMENT expandSection       ((%title;)?, (%storySection.cnt;)*)   >
<!ATTLIST expandSection         
             spectitle  CDATA                            #IMPLIED
             %univ-atts;
             outputclass 
                        CDATA                            #IMPLIED    >

<!ELEMENT storySection       ((%title;)?,(%storySection.cnt; | %everyTrail; | %youTube; )*)  >
<!ATTLIST storySection         
             spectitle  CDATA                            #IMPLIED
             %univ-atts;
             outputclass 
                        CDATA                            #IMPLIED    >

<!ELEMENT everyTrail       (#PCDATA)                             >
<!ATTLIST everyTrail         
             width  CDATA                            "740"
			 height CDATA                            "600"
			 tripId CDATA                            #IMPLIED    >

<!ELEMENT youTube       (#PCDATA)                             >
<!ATTLIST youTube         
             width  CDATA                            "425"
			 height CDATA                            "344"
			 href CDATA                            #IMPLIED    >	

<!ELEMENT floatFig       ((%title;)?, %image;)                             >
<!ATTLIST floatFig
			 %float-d-attribute;
			 %phsize-d-attribute;	 									   >	
<!ELEMENT clearFloat      (#PCDATA)                            >
						
<!ATTLIST photoFile     %global-atts;  class  CDATA "- topic/topic       photoFile/photoFile " >
<!ATTLIST photoBody     %global-atts;  class  CDATA "- topic/body        photoFile/photoBody " >
<!ATTLIST photoSection  %global-atts;  class  CDATA "- topic/section     photoFile/photoSection " >
<!ATTLIST expandSection  %global-atts;  class  CDATA "- topic/section     photoFile/expandSection " >
<!ATTLIST storySection  %global-atts;  class  CDATA "- topic/section     photoFile/storySection " >
<!ATTLIST everyTrail  %global-atts;  class  CDATA "- photoFile/everyTrail " >
<!ATTLIST youTube  %global-atts;  class  CDATA "- photoFile/youTube " >
<!ATTLIST floatFig  %global-atts;  class  CDATA "- topic/fig  photoFile/floatFig " >
<!ATTLIST clearFloat  %global-atts;  class  CDATA "- topic/p  photoFile/clarFloat " >

 
<!-- ================== End DITA Reference  =========================== -->

