<?xml version="1.0" encoding="UTF-8"?>

<!-- TORTILLA XSL -->
<!-- version 1.3 -->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="html" encoding="UTF-8" indent="yes"/>

  <!-- PARAMETERS -->

  <xsl:param name="WEBROOT"/>
  <xsl:param name="CSS"/>

  <xsl:param name="GET_0"/>
  <!-- language -->
  <xsl:param name="GET_1"/>
  <!-- page -->
  <xsl:param name="GET_2"/>
  <!-- division -->
  <xsl:param name="GET_3"/>
  <!-- section -->
  <xsl:param name="GET_4"/>
  <!-- file -->

  <!-- web path names -->
  <xsl:variable name="WEBLANG" select="concat($WEBROOT,'/',$GET_0)"/>

  <!-- server path names -->
  <xsl:variable name="SITE" select="document(concat($WEBROOT,'/content/',$GET_0,'/site.xml'))/site"/>
  <xsl:variable name="PAGE" select="document(concat($WEBROOT,'/content/',$GET_0,'/',page/meta-information/filename))/page"/>

  <!-- HTML HEADER AND BODY -->

  <xsl:template match="page">
    <xsl:element name="html">
      <!-- html header -->
      <head>
        <title>
          <xsl:apply-templates select="$SITE//title"/>
          <xsl:text> - </xsl:text>
          <xsl:apply-templates select="//page/meta-information/title"/>
        </title>
        <xsl:apply-templates select="meta-information"/>
        <!-- include google web font, load css and favicon -->
        <link href="http://fonts.googleapis.com/css?family=Port+Lligat+Sans" rel="stylesheet" type="text/css"/>
        <link rel="stylesheet" type="text/css" href="{$WEBROOT}/{$CSS}"/>
        <link rel="icon" href="images/favicon.png" type="image/png"/>
      </head>
      <!-- html body -->
      <body>
        <div class="page">
          <!-- page header -->
          <div class="header">
            <xsl:call-template name="translations"/>
            <h1>
              <a href="{$WEBLANG}">
                <xsl:value-of select="$SITE/title"/>
              </a>
            </h1>
            <xsl:call-template name="navigation"/>
          </div>
          <!-- page content -->
          <xsl:apply-templates select="content"/>
          <!-- page footer -->
          <div class="byline">
            <xsl:choose>
              <xsl:when test="$GET_0='de'">
                <p>Herausgeber: <xsl:call-template name="get-authors"/> – Stand: <xsl:apply-templates select="//meta-information/date"/> – <a
                    href="{$WEBLANG}/impressum">Impressum</a> – <a href="{$WEBLANG}/kontakt">Kontakt</a></p>
              </xsl:when>
              <xsl:when test="$GET_0='en'">
                <p>Copyright: <xsl:call-template name="get-authors"/> – <xsl:apply-templates select="//meta-information/date"/> – <a
                    href="{$WEBLANG}/impressum">Legal Notice</a> – <a href="{$WEBLANG}/contact">Contact</a></p>
              </xsl:when>
            </xsl:choose>
          </div>
        </div>
      </body>
    </xsl:element>
  </xsl:template>

  <!-- META-INFORMATION -->

  <xsl:template match="meta-information">
    <meta http-equiv="content-type" content="text/html; charset=UTF-8"/>
    <meta http-equiv="content-style-type" content="text/css"/>
    <meta name="content-language" content="{$SITE/language}"/>
    <meta name="author">
      <xsl:attribute name="content">
        <xsl:call-template name="get-authors"/>
      </xsl:attribute>
    </meta>
    <meta name="copyright">
      <xsl:attribute name="content">
        <xsl:call-template name="get-authors"/>
      </xsl:attribute>
    </meta>
    <meta name="date" content="{date}"/>
    <meta name="keywords">
      <xsl:attribute name="content">
        <xsl:value-of select="title"/>
        <xsl:for-each select="//division[name=$GET_2]/heading">,<xsl:value-of select="."/></xsl:for-each>
      </xsl:attribute>
    </meta>
    <meta name="language" content="{$SITE/language}"/>
    <meta name="robots" content="index,follow"/>
  </xsl:template>

  <xsl:template name="get-authors">
    <xsl:for-each select="//meta-information/author">
      <xsl:if test="not(position()=1)">, </xsl:if>
      <xsl:apply-templates/>
    </xsl:for-each>
  </xsl:template>

  <!-- TRANSLATIONS -->

  <xsl:template name="translations">
    <div class="translations">
      <xsl:for-each select="//meta-information/translation">
        <xsl:variable name="LANG" select="@lang"/>
        <xsl:if test="not(position()=1)"> | </xsl:if>
        <xsl:text>&gt;&gt; </xsl:text>
        <a>
          <xsl:attribute name="href">
            <xsl:text>/</xsl:text>
            <xsl:value-of select="$LANG"/>
            <xsl:text>/</xsl:text>
            <xsl:value-of select="."/>
            <xsl:if test="$PAGE/content/division[@name=$GET_2]/translation[@lang=$LANG]">
              <xsl:text>/</xsl:text>
              <xsl:apply-templates select="$PAGE/content/division[@name=$GET_2]/translation[@lang=$LANG]"/>
            </xsl:if>
          </xsl:attribute>
          <xsl:choose>
            <xsl:when test="$LANG='de'">Deutsch</xsl:when>
            <xsl:when test="$LANG='en'">English</xsl:when>
          </xsl:choose>
        </a>
      </xsl:for-each>
    </div>
  </xsl:template>

  <xsl:template match="translation"/>

  <!-- NAVIGATION -->

  <xsl:template name="navigation">
    <!-- main navigation -->
    <ul class="navigation level1">
      <xsl:for-each select="$SITE/navigation/item">
        <li>
          <!-- set active tab -->
          <xsl:if test="@name=$GET_1 or (position()=1 and $GET_1='')">
            <xsl:attribute name="class">active</xsl:attribute>
          </xsl:if>
          <a href="{$WEBLANG}/{@name}">
            <xsl:apply-templates/>
          </a>
        </li>
        <!-- sub navigation (cascading type) -->
        <xsl:if test="(@name=$GET_1 or (position()=1 and $GET_1='')) and $SITE/navigation/@type='cascading'">
          <xsl:call-template name="sub-navigation"/>
        </xsl:if>
      </xsl:for-each>
    </ul>
    <!-- sub navigation (parallel type) -->
    <xsl:if test="$SITE/navigation/@type = 'parallel'">
      <xsl:call-template name="sub-navigation"/>
    </xsl:if>
  </xsl:template>

  <xsl:template name="sub-navigation">
    <ul class="navigation level2">
      <xsl:for-each select="$PAGE/content/division[@name]">
        <li>
          <!-- set active tab -->
          <xsl:if test="@name=$GET_2 or (position()=1 and $GET_2='' and ../@display='by-divisions' and ../@default='first-division')">
            <xsl:attribute name="class">active</xsl:attribute>
          </xsl:if>
          <!-- division links -->
          <a href="{$WEBLANG}/{$GET_1}/{@name}">
            <xsl:choose>
              <xsl:when test="heading/@short">
                <xsl:value-of select="heading/@short"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="heading"/>
              </xsl:otherwise>
            </xsl:choose>
          </a>
        </li>
      </xsl:for-each>
    </ul>
  </xsl:template>

  <!-- CONTENT -->

  <xsl:template match="content">
    <div class="content">
      <xsl:choose>
        <xsl:when test="$GET_4 and division[@name=$GET_2]//paragraph[image[@filename=$GET_4]]">
          <!-- display selected object -->
          <xsl:apply-templates select="division[@name=$GET_2]//paragraph[image[@filename=$GET_4]]"/>
        </xsl:when>
        <xsl:when test="$GET_3 and division[@name=$GET_2]//paragraph[image[@filename=$GET_3]]">
          <!-- display selected object -->
          <xsl:apply-templates select="division[@name=$GET_2]//paragraph[image[@filename=$GET_3]]"/>
        </xsl:when>
        <xsl:otherwise>
          <!-- display divisions -->
          <xsl:choose>
            <!-- optional: only one at a time -->
            <xsl:when test="@display='by-divisions'">
              <xsl:choose>
                <!-- display selected division -->
                <xsl:when test="$GET_2 and division[@name=$GET_2]">
                  <xsl:apply-templates select="heading"/>
                  <xsl:apply-templates select="division[@name=$GET_2]"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:choose>
                    <!-- default option: first division -->
                    <xsl:when test="@default='first-division'">
                      <xsl:apply-templates select="heading"/>
                      <xsl:apply-templates select="division[1]"/>
                    </xsl:when>
                    <!-- display division list -->
                    <xsl:when test="@default='division-list'">
                      <xsl:apply-templates select="*[name() != 'division']"/>
                      <ul class="bullets">
                        <xsl:for-each select="division[@name]">
                          <li>
                            <a href="{$WEBLANG}/{$GET_1}/{@name}">
                              <xsl:value-of select="heading"/>
                            </a>
                          </li>
                        </xsl:for-each>
                      </ul>
                    </xsl:when>
                    <xsl:otherwise> </xsl:otherwise>
                  </xsl:choose>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <!-- default: all divisions -->
            <xsl:otherwise>
              <xsl:apply-templates/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
      <!-- clearing paragraph (for floating pictures) -->
      <p class="clear"/>
    </div>
  </xsl:template>

  <!-- DIVISIONS -->

  <xsl:template match="content/division">
    <div>
      <xsl:if test="@class">
        <xsl:attribute name="class">
          <xsl:value-of select="@class"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <!-- HEADINGS -->

  <xsl:template match="content/heading">
    <h2>
      <xsl:if test="@class">
        <xsl:attribute name="class">
          <xsl:value-of select="@class"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/>
    </h2>
  </xsl:template>

  <xsl:template match="content/division/heading">
    <h3>
      <xsl:if test="@class">
        <xsl:attribute name="class">
          <xsl:value-of select="@class"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/>
    </h3>
  </xsl:template>

  <xsl:template match="content/division/section/heading">
    <h4>
      <xsl:if test="@class">
        <xsl:attribute name="class">
          <xsl:value-of select="@class"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/>
    </h4>
  </xsl:template>

  <!-- PARAGRAPHS -->

  <xsl:template match="content//paragraph">
    <p>
      <xsl:apply-templates/>
    </p>
  </xsl:template>

  <xsl:template match="content//paragraph[@content='image']">
    <xsl:choose>
      <xsl:when test="$GET_4">
        <!-- display selected image in full size -->
        <xsl:if test="image/@filename=$GET_4">
          <div class="image">
            <a href="{$WEBLANG}/{$GET_1}/{ancestor::division/@name}">
              <img src="{$WEBLANG}/images/{ancestor::division/@name}/{ancestor::section/@name}/{image/@filename}.{image/@extension}"
                alt="{../../title}" title="{../../title}"/>
            </a>
            <p>
              <xsl:apply-templates select="*[not(name()='image')]"/>
            </p>
          </div>
        </xsl:if>
      </xsl:when>
      <xsl:when test="$GET_3">
        <!-- display selected image in full size -->
        <xsl:if test="image/@filename=$GET_3">
          <div class="image">
            <a href="{$WEBLANG}/{$GET_1}/{ancestor::division/@name}">
              <img src="{$WEBLANG}/images/{ancestor::division/@name}/{image/@filename}.{image/@extension}" alt="{../title}" title="{../title}"/>
            </a>
            <p>
              <xsl:apply-templates select="*[not(name()='image')]"/>
            </p>
          </div>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <div class="image">
          <!-- display all images -->
          <xsl:for-each select="image">
            <xsl:choose>
              <xsl:when test="ancestor::section/@name">
                <a href="{$WEBLANG}/{$GET_1}/{ancestor::division/@name}/{ancestor::section/@name}/{@filename}">
                  <img src="{$WEBROOT}/images/{ancestor::division/@name}/{ancestor::section/@name}/{@filename}-preview.{@extension}" alt="{../title}"
                    title="{../title}"/>
                </a>
              </xsl:when>
              <xsl:otherwise>
                <a href="{$WEBLANG}/{$GET_1}/{ancestor::division/@name}/{@filename}">
                  <img src="{$WEBROOT}/images/{ancestor::division/@name}/{@filename}-preview.{@extension}" alt="{../title}" title="{../title}"/>
                </a>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:for-each>
          <p>
            <xsl:apply-templates select="*[not(name()='image')]"/>
          </p>
        </div>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- LINES -->

  <xsl:template match="content//line">
    <xsl:choose>
      <xsl:when test="@content">
        <span class="{@content}">
          <xsl:apply-templates/>
        </span>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
    <br/>
  </xsl:template>

  <!-- IMAGES -->

  <xsl:template match="content//image">
    <img src="{$WEBROOT}/images/{@filename}.{@extension}" alt="{.}" title="{.}" class="{@class}"/>
  </xsl:template>

  <!-- MAPS -->

  <xsl:template match="content//map">
    <div id="map"/>
    <script src="http://www.openlayers.org/api/OpenLayers.js"/>
    <script src="{$WEBROOT}/javascript/openstreetmap.js"/>
    <script>
      initMap(<xsl:value-of select="@latitude"/>,<xsl:value-of select="@longitude"/>,<xsl:value-of select="@zoom"/>,'<xsl:value-of select="@filename"/>');
    </script>
  </xsl:template>

  <!-- VIDEOS -->

  <xsl:template match="content//video">
    <object class="video" type="application/x-shockwave-flash" data="{$WEBROOT}/design/flash/player_flv_maxi.swf" height="{@height+@margin*2}"
      width="{@width+@margin*2}">
      <param name="movie" value="{$WEBROOT}/design/flash/player_flv_maxi.swf"/>
      <param name="allowFullScreen" value="true"/>
      <param name="FlashVars"
        value="flv={$WEBROOT}/videos/{@filename}&amp;title={@title}&amp;startimage={$WEBROOT}/videos/{@startimage}&amp;width={@width}&amp;height={@height}&amp;config={$WEBROOT}/design/flash/config_flv_maxi.txt"
      />
    </object>
  </xsl:template>

  <xsl:template match="content//youtube">
    <div class="video">
      <object width="425" height="344">
        <param name="movie" value="http://www.youtube.com/v/{@code}"/>
        <param name="allowFullScreen" value="true"/>
        <param name="allowscriptaccess" value="always"/>
        <embed src="http://www.youtube.com/v/{@code}" type="application/x-shockwave-flash" allowscriptaccess="always" allowfullscreen="true"
          width="425" height="344"/>
      </object>
    </div>
  </xsl:template>

  <!-- LISTS -->

  <xsl:template match="content//list">
    <ul class="{@type}">
      <xsl:apply-templates/>
    </ul>
  </xsl:template>

  <!-- lists with floating first lines -->
  <xsl:template match="content//list[@type='floating-first-lines']/item">
    <li>
      <!-- get the first list item -->
      <div class="first-item">
        <xsl:apply-templates select="*[1]"/>
      </div>
      <!-- all other list items -->
      <div class="following-items">
        <xsl:apply-templates select="*[position()>1]"/>
      </div>
    </li>
  </xsl:template>

  <!-- lists with bullets -->
  <xsl:template match="content//list[@type='bullets']/item">
    <li>
      <xsl:apply-templates/>
    </li>
  </xsl:template>

  <!-- LINKS -->

  <xsl:template match="content//link[@type='site']">
    <xsl:choose>
      <xsl:when test="@href">
        <a class="site" href="{$WEBLANG}/{@href}">
          <xsl:apply-templates/>
        </a>
      </xsl:when>
      <xsl:otherwise>
        <a class="site" href="{$WEBLANG}/{.}">
          <xsl:apply-templates/>
        </a>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="content//link[@type='file']">
    <xsl:choose>
      <xsl:when test="@href">
        <a class="file" href="{$WEBROOT}/files/{@href}">
          <xsl:apply-templates/>
        </a>
      </xsl:when>
      <xsl:otherwise>
        <a class="file" href="{$WEBROOT}/files/{.}">
          <xsl:apply-templates/>
        </a>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="content//link[@type='web']">
    <xsl:choose>
      <xsl:when test="@href">
        <a class="web" target="_blank" href="{@href}">
          <xsl:apply-templates/>
        </a>
      </xsl:when>
      <xsl:otherwise>
        <a class="web" target="_blank" href="{.}">
          <xsl:apply-templates/>
        </a>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="content//link[@type='email']">
    <a class="email">
      <!-- obfuscate email address -->
      <xsl:attribute name="href">
        <xsl:element name="code">&#109;&#97;&#105;&#108;&#116;&#111;&#58;</xsl:element>
        <xsl:value-of select="substring-before(.,'@')"/>
        <xsl:element name="code">&#64;</xsl:element>
        <xsl:value-of select="substring-after(.,'@')"/>
      </xsl:attribute>
      <xsl:value-of select="substring-before(.,'@')"/>
      <xsl:element name="code">&#64;</xsl:element>
      <xsl:value-of select="substring-after(.,'@')"/>
    </a>
  </xsl:template>

  <xsl:template match="content//link[@type='openstreetmap']">
    <xsl:choose>
      <xsl:when test="@latitude and @longitude and @zoom">
        <a class="openstreetmap" target="_blank"
          href="http://www.openstreetmap.org/?mlat={@latitude}&amp;mlon={@longitude}&amp;zoom={@zoom}&amp;layers=M">
          <xsl:apply-templates/>
        </a>
      </xsl:when>
      <xsl:otherwise>
        <a class="openstreetmap" target="_blank" href="http://www.openstreetmap.org">
          <xsl:apply-templates/>
        </a>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- EXTERNAL CONTENT -->

  <xsl:template match="content//get-content">
    <xsl:variable name="IMPORTFILE" select="document(concat($WEBROOT,'/content/',@from))"/>
    <xsl:variable name="FOREIGN_ELEMENT" select="@element"/>
    <xsl:variable name="FOREIGN_CONAINER" select="@container"/>
    <xsl:variable name="FOREIGN_POSITION" select="@position"/>
    <xsl:apply-templates select="$IMPORTFILE//*[@name=$FOREIGN_CONAINER]//*[name()=$FOREIGN_ELEMENT][position()=$FOREIGN_POSITION]"/>
  </xsl:template>

</xsl:stylesheet>
