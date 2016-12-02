<?xml version="1.0" encoding="UTF-8" ?>

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:ditamsg="http://dita-ot.sourceforge.net/ns/200704/ditamsg"
                exclude-result-prefixes="ditamsg xs">

    <!-- XHTML output with XML syntax -->
    <xsl:output method="xml" encoding="UTF-8" indent="no"/>

    <!-- Обработка фотосекции. Размещение фотографий в таблицу и оборачивание в ссылки  -->
    <!-- ============================================================================== -->
    <xsl:template match="*[contains(@class,' photoFile/photoSection ')]">
        <xsl:variable name="fotoSection" select="."/>
        <xsl:variable name="fotoDimension" select="('small', 'middle', 'large', 'xlarge')"/>
        <xsl:variable name="columnCount" select="(4, 2, 1, 1)"/>
        <xsl:variable name="secPosition"
                      select="count(preceding::*[contains(@class,' photoFile/photoSection ')])+1"/>

        <center>
            <!-- Если есть заголовок -->
            <xsl:if test="*[1][self::title]">
                <h2>
                    <xsl:value-of select="*[1]"/>
                </h2>
            </xsl:if>

            <xsl:value-of select="$newline"/>
            <!-- Таблица фотографий  -->
            <div class="photo-section">
                <xsl:variable name="iter"
                              select="if (index-of($fotoDimension, @phsize) > 0) then index-of($fotoDimension, @phsize) else 2"/>
                <xsl:call-template name="makePhotoTable">
                    <xsl:with-param name="secPosition" select="$secPosition"/>
                    <xsl:with-param name="sec" select="$fotoSection"/>
                    <xsl:with-param name="dim" select="$fotoDimension[$iter]"/>
                    <xsl:with-param name="col" select="$columnCount[$iter]"/>
                </xsl:call-template>
            </div>
        </center>
    </xsl:template>


    <!-- Плавающая иллюстрация floatFig в StorySection  -->
    <!-- ============================================================================== -->
    <xsl:template match="*[contains(@class,' photoFile/floatFig ')]">
        <div class="{if(@float='right') then 'float-right' else 'float-left'}">
            <table>
                <tbody>
                    <tr>
                        <td>
                            <!-- Фотография плашка -->
                            <a>
                                <xsl:attribute name="href">
                                    <xsl:call-template name="getPhotoRef">
                                        <xsl:with-param name="ref" select="image/@href"/>
                                        <xsl:with-param name="type" select="'show'"/>
                                    </xsl:call-template>
                                </xsl:attribute>
                                <xsl:attribute name="rel">
                                    <xsl:value-of select="'cbgroup'"/>
                                </xsl:attribute>
                                <xsl:attribute name="title">
                                    <xsl:value-of select="if(title) then title else ''"/>
                                </xsl:attribute>
                                <img class="imagecenter">
                                    <xsl:attribute name="src">
                                        <xsl:call-template name="getPhotoRef">
                                            <xsl:with-param name="ref" select="image/@href"/>
                                            <xsl:with-param name="type" select="@phsize"/>
                                        </xsl:call-template>
                                    </xsl:attribute>
                                </img>
                            </a>
                        </td>
                        <xsl:if test="contains(@otherprops, 'full-link')">
                            <td valign="top">
                                <!--Ссылка на оригинал (фотокамера)-->
                                <a title="Полный размер" target="_blank">
                                    <xsl:attribute name="href">
                                        <xsl:call-template name="getPhotoRef">
                                            <xsl:with-param name="ref" select="image/@href"/>
                                            <xsl:with-param name="type" select="'full'"/>
                                        </xsl:call-template>
                                    </xsl:attribute>
                                    <img src="images/camera.gif"/>
                                </a>
                            </td>
                        </xsl:if>
                    </tr>
                </tbody>
            </table>
            <xsl:apply-templates select="*[contains(@class, ' topic/title ')]" mode="floating-title"
                    />
        </div>
    </xsl:template>


    <!--floating-title-->
    <xsl:template match="*" mode="floating-title">
        <p class="floating-title">
            <xsl:value-of select="."/>
        </p>
    </xsl:template>

    <xsl:template match="*[contains(@class,' photoFile/clarFloat ')]">
        <br class="clearFloat"/>
    </xsl:template>


    <!-- Создание таблицы с фотографиями -->
    <!-- =============================== -->
    <xsl:template name="makePhotoTable">
        <xsl:param name="secPosition"/>
        <xsl:param name="sec"/>
        <xsl:param name="dim"/>
        <xsl:param name="col"/>
        <xsl:variable name="colBalance" select="(1 to $col)"/>

        <xsl:value-of select="$newline"/>
        <table class="photoFile photo-section--table" cellspacing="10px">
            <xsl:attribute name="id">
                <xsl:text>photo</xsl:text>
                <xsl:value-of select="$secPosition"/>
                <xsl:text>_</xsl:text>
                <xsl:value-of select="$dim"/>
            </xsl:attribute>
            <!-- Балансировка ширины колонок в таблице -->
            <colgroup>
                <xsl:for-each select="$colBalance">
                    <col>
                        <xsl:attribute name="width">
                            <xsl:text>1*</xsl:text>
                        </xsl:attribute>
                    </col>
                </xsl:for-each>
            </colgroup>
            <tbody>
                <!-- Распределение списка фотографий по строкам таблицы -->
                <xsl:for-each-group
                        select="$sec/*[contains(@class,' topic/fig ') or contains(@class,' topic/object ')]"
                        group-by="(position()-1) idiv $col">
                    <tr>
                        <xsl:for-each select="current-group()">
                            <td>
                                <xsl:choose>
                                    <!-- Размещение объекта -->
                                    <xsl:when test="self::*[contains(@class,' topic/object ')]">
                                        <xsl:call-template name="topic.object"/>
                                        <!-- Размещение подписи к объекту-->
                                        <xsl:if test="desc">
                                            <p class="photoTitle">
                                                <xsl:apply-templates select="desc"/>
                                            </p>
                                        </xsl:if>
                                    </xsl:when>
                                    <!-- Размещение картинки в ссылке -->
                                    <xsl:when test="self::*[contains(@class,' topic/fig ')]">
                                        <xsl:variable name="curFig" select="."/>
                                        <xsl:variable name="titleText" select="title/text()"/>
                                        <!-- Иконка со ссылкой на полный размер фотографии -->
                                        <p class="camera">
                                            <a title="Полный размер" target="_blank">
                                                <xsl:attribute name="href">
                                                    <xsl:call-template name="getPhotoRef">
                                                        <xsl:with-param name="ref" select="image/@href"/>
                                                        <xsl:with-param name="type" select="'full'"/>
                                                    </xsl:call-template>
                                                </xsl:attribute>
                                                <img src="images/camera.gif"/>
                                            </a>
                                        </p>
                                        <!-- Ссылка на фотографию и отображаемая плашка фотографии -->
                                        <a>
                                            <xsl:attribute name="href">
                                                <xsl:call-template name="getPhotoRef">
                                                    <xsl:with-param name="ref" select="image/@href"/>
                                                    <xsl:with-param name="type" select="'show'"/>
                                                </xsl:call-template>
                                            </xsl:attribute>
                                            <xsl:attribute name="rel">
                                                <xsl:value-of
                                                        select="if (contains($sec/@base, 'slideshow')) then 'slideshow' else 'cbgroup'"
                                                        />
                                            </xsl:attribute>
                                            <xsl:attribute name="title">
                                                <xsl:value-of
                                                        select="if($titleText != '') then $titleText else $curFig/ancestor::*[title][1]/title"
                                                        />
                                            </xsl:attribute>
                                            <img class="photo photo-section--photo">
                                                <xsl:attribute name="src">
                                                    <xsl:call-template name="getPhotoRef">
                                                        <xsl:with-param name="ref" select="image/@href"/>
                                                        <xsl:with-param name="type" select="$dim"/>
                                                    </xsl:call-template>
                                                </xsl:attribute>
                                            </img>
                                        </a>

                                        <!-- Размещение подписи к фотографии-->
                                        <xsl:if test="title">
                                            <p class="photoTitle">
                                                <xsl:value-of select="title"/>
                                            </p>
                                        </xsl:if>
                                        <xsl:if test="desc">
                                            <p class="photoTitle">
                                                <xsl:apply-templates select="desc"/>
                                            </p>
                                        </xsl:if>
                                    </xsl:when>
                                </xsl:choose>
                            </td>
                            <xsl:value-of select="$newline"/>
                        </xsl:for-each>
                    </tr>
                    <xsl:value-of select="$newline"/>
                </xsl:for-each-group>
            </tbody>
        </table>
    </xsl:template>


    <!-- Ссылка на фотографию на одном из фотохостингов -->
    <!-- ============================================== -->
    <xsl:template name="getPhotoRef">
        <xsl:param name="ref"/>
        <!-- Исходная ссылка -->
        <xsl:param name="type"/>
        <!-- Требуемый тип ссылки -->

        <xsl:choose>
            <xsl:when test="contains($ref,'photo.qip.ru')">
                <!-- Ссылка на Фотофайл -->
                <xsl:analyze-string select="$ref" flags="x"
                                    regex="(http://photo.qip.(name|ru)/photo/(.+/) (\d+/)) \w+/ ( (\d+) \..+)">
                    <xsl:matching-substring>
                        <xsl:choose>
                            <xsl:when test="$type='full'">
                                <xsl:text>http://photo.qip.ru/users/</xsl:text>
                                <xsl:value-of select="regex-group(3)"/>
                                <xsl:value-of select="regex-group(4)"/>
                                <xsl:value-of select="regex-group(6)"/>
                                <xsl:text>/full_image/</xsl:text>
                            </xsl:when>
                            <xsl:when test="$type='show'">
                                <xsl:value-of select="regex-group(1)"/>
                                <xsl:text>xlarge/</xsl:text>
                                <xsl:value-of select="regex-group(5)"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="regex-group(1)"/>
                                <xsl:value-of select="$type"/>
                                <xsl:text>/</xsl:text>
                                <xsl:value-of select="regex-group(5)"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:matching-substring>
                </xsl:analyze-string>
            </xsl:when>
            <!-- Ссылка на Яндекс фотки -->
            <xsl:when test="contains($ref,'yandex')">
                <xsl:analyze-string select="$ref" flags="x" regex="^(.+[_\-])([SMLX]+)(\..+)$">
                    <xsl:matching-substring>
                        <xsl:value-of select="regex-group(1)"/>
                        <xsl:choose>
                            <xsl:when test="$type='full'">
                                <xsl:text>orig</xsl:text>
                            </xsl:when>
                            <xsl:when test="$type='show'">
                                <xsl:text>XL</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:if test="$type='small'">
                                    <xsl:text>S</xsl:text>
                                </xsl:if>
                                <xsl:if test="$type='middle'">
                                    <xsl:text>M</xsl:text>
                                </xsl:if>
                                <xsl:if test="$type='large'">
                                    <xsl:text>L</xsl:text>
                                </xsl:if>
                                <xsl:if test="$type='xlarge'">
                                    <xsl:text>XL</xsl:text>
                                </xsl:if>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:value-of select="regex-group(3)"/>
                    </xsl:matching-substring>
                </xsl:analyze-string>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$ref"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <!-- Обработка раскрывающейся секции -->
    <!-- ======================================================================= -->
    <xsl:template match="*[contains(@class,' photoFile/expandSection ')]">
        <xsl:variable name="secPosition" select="count(preceding::expandSection)+1"/>
        <div class="expandSection">
            <a class="expandCaption" href="#nowere">
                <xsl:attribute name="name">
                    <xsl:text>exp</xsl:text>
                    <xsl:value-of select="$secPosition"/>
                </xsl:attribute>
                <xsl:attribute name="onclick">
                    <!-- Вызов fadeDIV с двумя парметрами - 1. Ссылка на тело секции, 2. Ссылка на краткое описание -->
                    <xsl:text>fadeDIV('exp_body</xsl:text>
                    <xsl:value-of select="$secPosition"/>
                    <xsl:text>','exp_short</xsl:text>
                    <xsl:value-of select="$secPosition"/>
                    <xsl:text>')</xsl:text>
                </xsl:attribute>
                <xsl:value-of select="if (*[1][self::title]) then title else 'Секция'"/>
                <!-- Краткое описание - N символов первого параграфа -->
                <br/>
                <span class="expandShort">
                    <xsl:attribute name="id">
                        <xsl:text>exp_short</xsl:text>
                        <xsl:value-of select="$secPosition"/>
                    </xsl:attribute>
                    <xsl:value-of select="substring(p[1],1,115)"/>
                    <xsl:text>...</xsl:text>
                </span>
            </a>
            <!-- Тело раскрывающейся секции -->
            <div style="display: none">
                <xsl:attribute name="id">
                    <xsl:text>exp_body</xsl:text>
                    <xsl:value-of select="$secPosition"/>
                </xsl:attribute>
                <xsl:apply-templates
                        select="if (*[1][self::title]) then *[not(position()=1)] else *"/>
            </div>
        </div>
    </xsl:template>


    <!-- Обработка shortdescription секции (модификация оригинального шаблона) -->
    <!-- ======================================================================= -->
    <xsl:template match="*[contains(@class,' topic/shortdesc ')]" mode="outofline">
        <p class="short">
            <xsl:call-template name="commonattributes"/>
            <xsl:apply-templates select="." mode="outputContentsWithFlagsAndStyle"/>
        </p>
        <xsl:value-of select="$newline"/>
    </xsl:template>

    <!-- Обработка примечаний (подмена оригинального шаблона) -->
    <!-- ======================================================================= -->
    <xsl:template match="*" mode="process.note.common-processing">
        <xsl:param name="type" select="@type"/>
        <xsl:param name="title">
            <xsl:call-template name="getString">
                <!-- For the parameter, turn "note" into "Note", caution => Caution, etc -->
                <xsl:with-param name="stringName"
                                select="concat(translate(substring($type, 1, 1),'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ'),
                          substring($type, 2))"/>
            </xsl:call-template>
        </xsl:param>
        <div class="{$type}">
            <xsl:call-template name="commonattributes">
                <xsl:with-param name="default-output-class" select="$type"/>
            </xsl:call-template>
            <xsl:call-template name="setidaname"/>
            <!-- Normal flags go before the generated title; revision flags only go on the content. -->
            <xsl:apply-templates select="*[contains(@class,' ditaot-d/ditaval-startprop ')]/prop"
                                 mode="ditaval-outputflag"/>
            <img src="images/note.gif"/>
            <xsl:text> </xsl:text>
            <xsl:apply-templates select="*[contains(@class,' ditaot-d/ditaval-startprop ')]/revprop"
                                 mode="ditaval-outputflag"/>
            <xsl:apply-templates/>
            <!-- Normal end flags and revision end flags both go out after the content. -->
            <xsl:apply-templates select="*[contains(@class,' ditaot-d/ditaval-endprop ')]" mode="out-of-line"/>
        </div>
    </xsl:template>

    <!-- Карта EveryTrail. Новый шаблон -->
    <xsl:template match="*[contains(@class,' photoFile/everyTrail ')]">
        <xsl:variable name="w" select="@width"/>
        <xsl:variable name="h" select="@height"/>

        <center>
            <iframe marginheight="0" marginwidth="0" frameborder="0" scrolling="no">
                <xsl:attribute name="src">
                    <xsl:text>http://www.everytrail.com/iframe2.php?trip_id=</xsl:text><xsl:value-of select="@tripId"/>
                    <xsl:text>&amp;width=</xsl:text><xsl:value-of select="@width"/>
                    <xsl:text>&amp;height=</xsl:text><xsl:value-of select="@height"/>
                </xsl:attribute>
                <xsl:attribute name="width">
                    <xsl:value-of select="@width"/>
                </xsl:attribute>
                <xsl:attribute name="height">
                    <xsl:value-of select="@height"/>
                </xsl:attribute>
            </iframe>
            <br/>
            <!--<a target="_blank">
                <xsl:attribute name="href">
                    <xsl:text>http://www.everytrail.com/fullscreen.php?trip_id=</xsl:text><xsl:value-of
                        select="@tripId"/>
                </xsl:attribute>
                Смотреть карту во весь экран<xsl:text/>
            </a>-->
        </center>
    </xsl:template>

    <!--Блок parallax -->
    <xsl:template match="*[contains(@class,' photoFile/parallax ')]">
        <div class="parallax js-module" data-module="Parallax" data-slowdown="{@slowdown}">
            <xsl:if test="@height">
                <xsl:attribute name="style">height:<xsl:value-of select="@height"/>px;</xsl:attribute>
            </xsl:if>
            <div class="parallax--scroll-container">
                <img class="parallax--bg-image" src="{image/@href}">
                    <xsl:if test="@slowdown">
                        <xsl:attribute name="style">bottom:0</xsl:attribute>
                    </xsl:if>
                </img>
            </div>
            <a class="parallax--link" href="{@href}" target="_blank">
                <div class="parallax--content">
                    <xsl:apply-templates select="*[not(contains(@class, ' topic/image '))]" mode="parallax"/>
                </div>
            </a>
        </div>
    </xsl:template>

    <xsl:template match="*" mode="parallax">
        <span class="{concat('parallax--', substring-after(@class, '/'))}">
            <xsl:apply-templates select="node()"/>
        </span>
    </xsl:template>

    <!-- Карта umap -->
    <xsl:template match="*[contains(@class,' photoFile/umap ')]">
        <center>
            <iframe width="100%" height="300px" frameBorder="0">
                <xsl:attribute name="src">
                    <xsl:text>http://umap.openstreetmap.fr/ru/map/</xsl:text>
                    <xsl:value-of select="@mapId"/>
                    <xsl:text>?</xsl:text>
                    <xsl:text>scaleControl=false&amp;</xsl:text>
                    <xsl:text>miniMap=false&amp;</xsl:text>
                    <xsl:text>scrollWheelZoom=false&amp;</xsl:text>
                    <xsl:text>zoomControl=true&amp;</xsl:text>
                    <xsl:text>allowEdit=false&amp;</xsl:text>
                    <xsl:text>moreControl=false&amp;</xsl:text>
                    <xsl:text>datalayersControl=false&amp;</xsl:text>
                    <xsl:text>onLoadPanel=undefined</xsl:text>
                </xsl:attribute>
            </iframe>
            <br/>
            <a target="_blank">
                <xsl:attribute name="href">
                    <xsl:text>http://umap.openstreetmap.fr/ru/map/</xsl:text>
                    <xsl:value-of select="@mapId"/>
                </xsl:attribute>
                Смотреть карту во весь экран<xsl:text/>
            </a>
        </center>
    </xsl:template>

    <!-- Видео YouTube. Новый шаблон -->
    <xsl:template match="*[contains(@class,' photoFile/youTube ')]">
        <center>
            <xsl:choose>
                <xsl:when test="matches(@href, 'http://youtu.be/.+' )">
                    <iframe frameborder="0" allowfullscreen="yes">
                        <xsl:attribute name="width"
                                       select="if(@width cast as xs:integer) then @width else 560"/>
                        <xsl:attribute name="height"
                                       select="if(@height  cast as xs:integer) then @height else 315"/>
                        <xsl:attribute name="src">
                            <xsl:value-of select="'http://www.youtube.com/embed/'"/>
                            <xsl:value-of select="replace(@href,'http://youtu.be/(.+)','$1')"/>
                        </xsl:attribute>
                    </iframe>
                </xsl:when>
                <xsl:otherwise>
                    <object>
                        <xsl:if test="@height">
                            <xsl:attribute name="height">
                                <xsl:value-of select="@height"/>
                            </xsl:attribute>
                        </xsl:if>
                        <!-- Если не указана ширина, тогда 100% -->
                        <xsl:attribute name="width">
                            <xsl:choose>
                                <xsl:when test="@width">
                                    <xsl:value-of select="@width"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>100%</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
                        <param name="movie">
                            <xsl:attribute name="value">
                                <xsl:value-of select="@href"/>
                                <xsl:value-of disable-output-escaping="yes"
                                              select="if (contains(@href, 'rel=0')) then '' else '&amp;rel=0'"
                                        />
                            </xsl:attribute>
                        </param>
                        <param name="allowFullScreen" value="true"/>
                        <param name="allowscriptaccess" value="always"/>
                        <embed>
                            <xsl:if test="@height">
                                <xsl:attribute name="height">
                                    <xsl:value-of select="@height"/>
                                </xsl:attribute>
                            </xsl:if>
                            <xsl:attribute name="width">
                                <xsl:choose>
                                    <xsl:when test="@width">
                                        <xsl:value-of select="@width"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>100%</xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:attribute>
                            <xsl:attribute name="type">
                                <xsl:text>application/x-shockwave-flash</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="src">
                                <xsl:value-of select="@href"/>
                                <xsl:value-of disable-output-escaping="yes"
                                              select="if (contains(@href, 'rel=0')) then '' else '&amp;rel=0'"
                                        />
                            </xsl:attribute>
                            <xsl:attribute name="play">
                                <xsl:text>true</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="loop">
                                <xsl:text>false</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="WMODE">
                                <xsl:text>transparent</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="allowScriptAccess">
                                <xsl:text>sameDomain</xsl:text>
                            </xsl:attribute>
                        </embed>
                    </object>
                </xsl:otherwise>
            </xsl:choose>
        </center>
    </xsl:template>

    <!-- Видео vimeo -->
    <xsl:template match="*[contains(@class,' photoFile/vimeo ')]">
        <center>
            <xsl:if test="matches(@href, 'https://vimeo.com/\d+' )">
                <iframe frameborder="0" allowfullscreen="yes">
                    <xsl:attribute name="width"
                                   select="if(@width cast as xs:integer) then @width else 746"/>
                    <xsl:attribute name="height"
                                   select="if(@height  cast as xs:integer) then @height else 420"/>
                    <xsl:attribute name="src">
                        <xsl:value-of select="'https://player.vimeo.com/video/'"/>
                        <xsl:value-of select="replace(@href,'https://vimeo.com/(\d+)','$1')"/>
                    </xsl:attribute>
                    <xsl:attribute name="webkitallowfullscreen" />
                    <xsl:attribute name="mozallowfullscreen" />
                    <xsl:attribute name="allowfullscreen" />
                </iframe>
            </xsl:if>
        </center>
    </xsl:template>


    <!-- Замена шаблон для обработки элемента object -->
    <!-- ============================================================== -->
    <xsl:template match="*[contains(@class,' topic/object ')]" name="topic.object" priority="-1">
        <xsl:choose>
            <xsl:when test="*[contains(@class,' topic/param ')][contains(@name,'EveryTrail')]">
                <xsl:call-template name="insert.everytrail"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="insert.object"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Вставляем карту c EveryTrail -->
    <xsl:template name="insert.everytrail">
        <xsl:variable name="tripId"
                      select="*[contains(@class,' topic/param ')][contains(@name, 'EveryTrail')]/@value"/>
        <xsl:variable name="w" select="@width"/>
        <xsl:variable name="h" select="@height"/>
        <!-- Тип карты -->
        <xsl:variable name="mType">
            <xsl:choose>
                <xsl:when test="*[contains(@class,' topic/param ')][contains(@name,'hybrid')]">
                    <xsl:text>Hybrid</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>Terrain</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <center>
            <object codebase="http://fpdownload.macromedia.com/get/flashplayer/current/swflash.cab">
                <xsl:attribute name="width">
                    <xsl:value-of select="@width"/>
                </xsl:attribute>
                <xsl:attribute name="height">
                    <xsl:value-of select="@height"/>
                </xsl:attribute>
                <param name="wmode" value="transparent"/>
                <param name="movie" value="http://www.everytrail.com/swf/widget.swf"/>
                <param name="FlashVars">
                    <xsl:attribute name="value">
                        <xsl:text>units=metric&amp;mode=1&amp;mapType=</xsl:text>
                        <xsl:value-of select="$mType"/>
                        <xsl:text>&amp;tripId=</xsl:text>
                        <xsl:value-of select="$tripId"/>
                    </xsl:attribute>
                </param>
                <embed src="http://www.everytrail.com/swf/widget.swf" quality="high"
                       type="application/x-shockwave-flash"
                       pluginspage="http://www.adobe.com/go/getflashplayer" wmode="transparent">
                    <xsl:attribute name="width">
                        <xsl:value-of select="@width"/>
                    </xsl:attribute>
                    <xsl:attribute name="height">
                        <xsl:value-of select="@height"/>
                    </xsl:attribute>
                    <xsl:attribute name="FlashVars">
                        <xsl:text>units=metric&amp;mode=1&amp;mapType=</xsl:text>
                        <xsl:value-of select="$mType"/>
                        <xsl:text>&amp;tripId=</xsl:text>
                        <xsl:value-of select="$tripId"/>
                    </xsl:attribute>
                </embed>
            </object>
            <br/>
            <a target="_blank">
                <xsl:attribute name="href">
                    <xsl:text>http://www.everytrail.com/fullscreen.php?trip_id=</xsl:text><xsl:value-of
                        select="$tripId"/>
                </xsl:attribute>
                Смотреть карту во весь экран<xsl:text/>
            </a>
        </center>

    </xsl:template>

    <!-- Вставляем объект object -->
    <xsl:template name="insert.object">
        <center>
            <xsl:element name="object">
                <xsl:if test="@id">
                    <xsl:attribute name="id">
                        <xsl:value-of select="@id"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="@declare">
                    <xsl:attribute name="declare">
                        <xsl:value-of select="@declare"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="@codebase">
                    <xsl:attribute name="codebase">
                        <xsl:value-of select="@codebase"/>
                    </xsl:attribute>
                </xsl:if>
                <!-- <xsl:if test="@type"><xsl:attribute name="type"><xsl:value-of select="@type"/></xsl:attribute></xsl:if> -->
                <xsl:if test="@archive">
                    <xsl:attribute name="archive">
                        <xsl:value-of select="@archive"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="@height">
                    <xsl:attribute name="height">
                        <xsl:value-of select="@height"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="@usemap">
                    <xsl:attribute name="usemap">
                        <xsl:value-of select="@usemap"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="@tabindex">
                    <xsl:attribute name="tabindex">
                        <xsl:value-of select="@tabindex"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="@classid">
                    <xsl:attribute name="classid">
                        <xsl:value-of select="@classid"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="@data">
                    <xsl:attribute name="data">
                        <xsl:value-of select="@data"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="@codetype">
                    <xsl:attribute name="codetype">
                        <xsl:value-of select="@codetype"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="@standby">
                    <xsl:attribute name="standby">
                        <xsl:value-of select="@standby"/>
                    </xsl:attribute>
                </xsl:if>
                <!-- Если не указана ширина, тогда 100% -->
                <xsl:attribute name="width">
                    <xsl:choose>
                        <xsl:when test="@width">
                            <xsl:value-of select="@width"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>100%</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                <xsl:if test="@name">
                    <xsl:attribute name="name">
                        <xsl:value-of select="@name"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="@longdescref or longdescref">
                    <xsl:apply-templates select="." mode="ditamsg:longdescref-on-object"/>
                </xsl:if>
                <xsl:apply-templates select="*[not(contains(@class, ' topic/desc '))]"/>
                <!-- Test for Flash movie; include EMBED statement for non-IE browsers -->

                <xsl:element name="embed">
                    <xsl:if test="@id">
                        <xsl:attribute name="name">
                            <xsl:value-of select="@id"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:if test="@height">
                        <xsl:attribute name="height">
                            <xsl:value-of select="@height"/>
                        </xsl:attribute>
                    </xsl:if>
                    <!-- <xsl:attribute name="wmode"><xsl: select="transparent"/></xsl:attribute> -->
                    <xsl:attribute name="width">
                        <xsl:choose>
                            <xsl:when test="@width">
                                <xsl:value-of select="@width"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>100%</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:attribute name="type">
                        <xsl:text>application/x-shockwave-flash</xsl:text>
                    </xsl:attribute>
                    <!-- <xsl:attribute name="pluginspage"><xsl:text>http://www.adobe.com/go/getflashplayer</xsl:text></xsl:attribute> -->
                    <!-- С этим слишком медленно грузятся html-странички  -->
                    <xsl:if test="./*[contains(@class,' topic/param ')]/@name='movie'">
                        <xsl:attribute name="src">
                            <xsl:value-of
                                    select="./*[contains(@class,' topic/param ')][@name='movie']/@value"
                                    />
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:if test="./*[contains(@class,' topic/param ')]/@name='quality'">
                        <xsl:attribute name="quality">
                            <xsl:value-of
                                    select="./*[contains(@class,' topic/param ')][@name='quality']/@value"
                                    />
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:if test="./*[contains(@class,' topic/param ')]/@name='bgcolor'">
                        <xsl:attribute name="bgcolor">
                            <xsl:value-of
                                    select="./*[contains(@class,' topic/param ')][@name='bgcolor']/@value"
                                    />
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:if test="./*[contains(@class,' topic/param ')]/@name='FlashVars'">
                        <xsl:attribute name="FlashVars">
                            <xsl:value-of
                                    select="./*[contains(@class,' topic/param ')][@name='FlashVars']/@value"
                                    />
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:if test="./*[contains(@class,' topic/param ')]/@name='FlashVars'">
                        <xsl:attribute name="FlashVars">
                            <xsl:value-of
                                    select="./*[contains(@class,' topic/param ')][@name='FlashVars']/@value"
                                    />
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:attribute name="play">
                        <xsl:text>true</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="loop">
                        <xsl:text>false</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="WMODE">
                        <xsl:text>transparent</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="allowScriptAccess">
                        <xsl:text>sameDomain</xsl:text>
                    </xsl:attribute>

                </xsl:element>
            </xsl:element>
        </center>
    </xsl:template>

    <!-- Заголовок таблиц - убрана нумерация -->
    <!-- table caption -->
    <xsl:template name="place-tbl-lbl">
        <xsl:param name="stringName"/>
        <!-- Number of table/title's before this one -->
        <xsl:variable name="tbl-count-actual"
                      select="count(preceding::*[contains(@class,' topic/table ')]/*[contains(@class,' topic/title ')])+1"/>

        <!-- normally: "Table 1. " -->
        <xsl:variable name="ancestorlang">
            <xsl:call-template name="getLowerCaseLang"/>
        </xsl:variable>

        <xsl:choose>
            <!-- title -or- title & desc -->
            <xsl:when test="*[contains(@class,' topic/title ')]">
                <caption>
                    <span class="tablecap">
                        <xsl:choose>
                            <!-- Hungarian: "1. Table " -->
                            <xsl:when
                                    test="( (string-length($ancestorlang)=5 and contains($ancestorlang,'hu-hu')) or (string-length($ancestorlang)=2 and contains($ancestorlang,'hu')) )">
                                <xsl:value-of select="$tbl-count-actual"/>
                                <xsl:text>. </xsl:text>
                                <xsl:call-template name="getString">
                                    <xsl:with-param name="stringName" select="'Table'"/>
                                </xsl:call-template>
                                <xsl:text> </xsl:text>
                            </xsl:when>
                            <xsl:otherwise/>
                        </xsl:choose>
                        <xsl:apply-templates select="./*[contains(@class,' topic/title ')]"
                                             mode="tabletitle"/>
                    </span>
                    <xsl:if test="*[contains(@class,' topic/desc ')]">
                        <xsl:text>. </xsl:text>
                        <span class="tabledesc">
                            <xsl:for-each select="./*[contains(@class,' topic/desc ')]">
                                <xsl:call-template name="commonattributes"/>
                            </xsl:for-each>
                            <xsl:apply-templates select="./*[contains(@class,' topic/desc ')]"
                                                 mode="tabledesc"/>
                        </span>
                    </xsl:if>
                </caption>
            </xsl:when>
            <!-- desc -->
            <xsl:when test="*[contains(@class,' topic/desc ')]">
                <span class="tabledesc">
                    <xsl:for-each select="./*[contains(@class,' topic/desc ')]">
                        <xsl:call-template name="commonattributes"/>
                    </xsl:for-each>
                    <xsl:apply-templates select="./*[contains(@class,' topic/desc ')]"
                                         mode="tabledesc"/>
                </span>
            </xsl:when>
        </xsl:choose>
    </xsl:template>


    <!--взято из диты. оригинальная версия не берет текст ссылки из заголовка целевого файла-->
    <xsl:template match="*[contains(@class,' topic/xref ')]" name="topic.xref">
        <xsl:choose>
            <xsl:when test="@href and normalize-space(@href)!=''">
                <xsl:apply-templates select="." mode="add-xref-highlight-at-start"/>
                <a>
                    <xsl:call-template name="commonattributes"/>
                    <xsl:apply-templates select="." mode="add-linking-attributes"/>
                    <xsl:apply-templates select="." mode="add-desc-as-hoverhelp"/>
                    <!-- if there is text or sub element other than desc, apply templates to them
          otherwise, use the href as the value of link text. -->
                    <xsl:choose>
                        <xsl:when test="@type='fn'">
                            <sup>
                                <xsl:choose>
                                    <xsl:when test="*[not(contains(@class,' topic/desc '))]|text()">
                                        <xsl:apply-templates select="*[not(contains(@class,' topic/desc '))]|text()"/>
                                        <!--use xref content-->
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:call-template name="href"/>
                                        <!--use href text-->
                                    </xsl:otherwise>
                                </xsl:choose>
                            </sup>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:choose>
                                <xsl:when test="*[not(contains(@class,' topic/desc '))]">
                                    <xsl:apply-templates select="*[not(contains(@class,' topic/desc '))]|text()"/>
                                    <!--use xref content-->
                                </xsl:when>
                                <!--teux -->
                                <xsl:when test="normalize-space(text()) != ''">
                                    <xsl:value-of select="normalize-space(text())"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <!--teux - start-->
                                    <xsl:variable name="title" select="document(@href)/*/title"/>
                                    <xsl:choose>
                                        <xsl:when test="$title != ''">
                                            <xsl:value-of select="normalize-space($title)"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:call-template name="href"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                    <!--teux - end-->
                                    <!--<xsl:call-template name="href"/>--><!--use href text-->
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:otherwise>
                    </xsl:choose>
                </a>
                <xsl:apply-templates select="." mode="add-xref-highlight-at-end"/>
            </xsl:when>
            <xsl:otherwise>
                <span>
                    <xsl:call-template name="commonattributes"/>
                    <xsl:apply-templates select="." mode="add-desc-as-hoverhelp"/>
                    <xsl:apply-templates
                            select="*[not(contains(@class,' topic/desc '))]|text()|comment()|processing-instruction()"/>
                </span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
