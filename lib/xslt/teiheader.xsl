<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
                xmlns:exsl="http://exslt.org/common"
                xmlns:x="http://www.tei-c.org/ns/1.0"
                xmlns:tst="https://github.com/tst-project"
                exclude-result-prefixes="x tst">

<xsl:output method="html" encoding="UTF-8" omit-xml-declaration="yes"/>

<xsl:template match="x:teiHeader">
    <xsl:element name="section">
        <xsl:call-template name="lang"/>
        <xsl:apply-templates />
    </xsl:element>
    <xsl:if test="//x:text">
        <h3>Text transcription</h3>
    </xsl:if>
</xsl:template>

<xsl:template match="x:titleStmt/x:title">
    <xsl:element name="h1">
        <xsl:call-template name="lang"/>
        <xsl:apply-templates/>
    </xsl:element>
</xsl:template>

<xsl:template name="editors">
    <xsl:element name="div">
        <xsl:attribute name="class">editionStmt</xsl:attribute>
        <p>
            <xsl:text>Record edited by </xsl:text>
            <xsl:for-each select="x:editor">
                <xsl:choose>
                    <xsl:when test="position() = last() and position() != 1">
                        <xsl:text> &amp; </xsl:text>
                    </xsl:when>
                    <xsl:when test="position() != 1">
                        <xsl:text>, </xsl:text>
                    </xsl:when>
                    <xsl:otherwise/>
                </xsl:choose>
                <xsl:apply-templates/>
            </xsl:for-each>
            <xsl:text>.</xsl:text>
        </p>
   </xsl:element>
</xsl:template>

<xsl:template match="x:titleStmt/x:editor/x:persName">
    <xsl:apply-templates/>
    <xsl:text> </xsl:text>
</xsl:template>

<!--xsl:template match="x:titleStmt/x:respStmt">
    <p><xsl:apply-templates/></p>
</xsl:template>

<xsl:template match="x:respStmt/x:resp">
    <xsl:apply-templates/>
</xsl:template>

<xsl:template match="x:respStmt/x:name">
    <xsl:apply-templates/>
</xsl:template-->

<xsl:template match="x:publicationStmt">
    <xsl:element name="p">
        <xsl:text>Published in </xsl:text>
        <xsl:apply-templates select="x:date"/>
        <xsl:text> by </xsl:text>
        <xsl:apply-templates select="x:publisher"/> 
        <xsl:if test="x:pubPlace">
            <xsl:text>in </xsl:text><xsl:apply-templates select="x:pubPlace"/>
        </xsl:if>
        <xsl:text>.</xsl:text>
    </xsl:element>
</xsl:template>

<xsl:template match="x:title">
    <xsl:element name="em">
        <xsl:attribute name="class">title</xsl:attribute>
        <xsl:call-template name="lang"/>
        <xsl:apply-templates />
    </xsl:element>
</xsl:template>

<xsl:template match="x:title[@type='article']">
    <xsl:element name="em">
        <xsl:attribute name="class">title-article</xsl:attribute>
        <xsl:call-template name="lang"/>
        <xsl:apply-templates />
    </xsl:element>
</xsl:template>

<!--xsl:template match="x:msContents/x:summary/x:title">
    <xsl:element name="em">
        <xsl:call-template name="lang"/>
        <xsl:apply-templates/>
    </xsl:element>
</xsl:template-->

<xsl:template match="x:msContents/x:summary/x:sub">
    <xsl:element name="sub">
        <xsl:apply-templates/>
    </xsl:element>
</xsl:template>
<xsl:template match="x:msContents/x:summary/x:sup">
    <xsl:element name="sup">
        <xsl:apply-templates/>
    </xsl:element>
</xsl:template>

<xsl:template match="x:msIdentifier">
    <table id="msidentifier">
        <xsl:apply-templates select="x:repository"/>
        <xsl:apply-templates select="x:institution"/>
        <xsl:apply-templates select="x:idno"/>
    </table>
</xsl:template>

<xsl:template match="x:repository">
    <tr><td colspan="2"><xsl:apply-templates/></td></tr>
</xsl:template>
<xsl:template match="x:institution">
    <tr><td colspan="2"><xsl:apply-templates/></td></tr>
</xsl:template>
<xsl:template match="x:orgName">
    <xsl:element name="span">
        <xsl:attribute name="class">orgname</xsl:attribute>
        <xsl:call-template name="lang"/>
        <xsl:apply-templates/>
    </xsl:element>
</xsl:template>

<xsl:template match="x:idno">
    <xsl:if test="node()">
        <tr><th>
            <xsl:if test="@type">
              <xsl:call-template name="capitalize">
                <xsl:with-param name="str" select="@type"/>
              </xsl:call-template>
            </xsl:if>
            </th>
            <td>
                <xsl:apply-templates/>
            </td>
        </tr>
    </xsl:if>
</xsl:template>
<xsl:template match="x:idno[@type='alternate']">
    <xsl:if test="node()">
        <tr>
          <th>Other identifiers</th>
          <td><ul>
            <xsl:for-each select="x:idno">
                <li><xsl:value-of select="."/></li>
            </xsl:for-each>
          </ul></td>
        </tr>
    </xsl:if>
</xsl:template>

<xsl:template match="x:idno[@type='URI']">
    <tr><td colspan="2">
        <xsl:element name="a">
            <xsl:attribute name="href"><xsl:value-of select="."/></xsl:attribute>
            <xsl:apply-templates/>
        </xsl:element>
    </td></tr>
</xsl:template>

<xsl:template match="x:fileDesc">
    <xsl:apply-templates/>
</xsl:template>
<xsl:template match="x:titleStmt">
    <xsl:apply-templates select="x:title"/>
    <xsl:if test="x:editor">
        <xsl:call-template name="editors"/>
    </xsl:if>
</xsl:template>

<xsl:template match="x:sourceDesc">
    <xsl:apply-templates/>
</xsl:template>

<xsl:template match="x:editionStmt">
    <xsl:element name="div">
        <xsl:attribute name="class">editionStmt</xsl:attribute>
        <xsl:apply-templates/>
    </xsl:element>
</xsl:template>

<xsl:template name="msDescTemplate">
    <xsl:apply-templates select="x:head"/>
    <xsl:apply-templates select="x:msIdentifier"/>
    <xsl:apply-templates select="x:msContents"/>
    <xsl:apply-templates select="x:physDesc"/>
    <section>
        <h3>Contents</h3>
        <xsl:apply-templates select="x:msContents/@class"/>
        <xsl:apply-templates select="x:msContents/x:msItem"/>
        <xsl:apply-templates select="x:msPart"/>
        <xsl:if test="x:msPart">
            <hr/>
        </xsl:if>
    </section>
    <xsl:apply-templates select="x:history"/>
    <xsl:apply-templates select="x:additional"/>
</xsl:template>

<xsl:template match="x:msDesc">
    <xsl:call-template name="msDescTemplate"/>
</xsl:template>

<xsl:template match="x:msPart">
    <hr/>
    <section class="mspart">
        <xsl:call-template name="msDescTemplate"/>
    </section>
</xsl:template>

<xsl:template match="x:msPart/x:head">
    <h4 class="mspart"><xsl:apply-templates/></h4>
</xsl:template>

<xsl:template match="x:msContents">
    <xsl:apply-templates select="x:summary"/>
</xsl:template>

<xsl:template match="x:msContents/@class">
    <xsl:variable name="class" select="."/>
    <xsl:element name="p">
        <xsl:value-of select="$TST/tst:mstypes/tst:entry[@key=$class]"/>
        <xsl:text>.</xsl:text>
    </xsl:element>
</xsl:template>

<xsl:template name="msItemHeader">
    <xsl:element name="thead">
        <xsl:element name="tr">
            <xsl:element name="th">
                <xsl:attribute name="colspan">2</xsl:attribute>
                <xsl:attribute name="class">left-align</xsl:attribute>
                <xsl:variable name="cu" select="substring-after(@synch,'#')"/>
                <xsl:variable name="thisid" select="@xml:id"/>
                <xsl:value-of select="$cu"/>
                <xsl:choose>
                    <xsl:when test="$thisid">
                        <xsl:if test="$cu">
                            <xsl:text>, </xsl:text>
                        </xsl:if>
                        <xsl:choose>
                            <xsl:when test="//x:TEI/x:text[@corresp=concat('#',$thisid)]">
                                <xsl:element name="a">
                                    <xsl:attribute name="class">local</xsl:attribute>
                                    <xsl:attribute name="href">
                                        <xsl:text>#text-</xsl:text>
                                        <xsl:value-of select="@xml:id"/>
                                    </xsl:attribute>
                                    <xsl:attribute name="data-scroll"/>
                                    <xsl:value-of select="@xml:id"/>
                                </xsl:element>
                            </xsl:when>
                            <xsl:otherwise>
                            <xsl:value-of select="@xml:id"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:choose>
                            <xsl:when test="@defective = 'false'">
                                <xsl:text> (complete)</xsl:text>
                            </xsl:when>
                            <xsl:when test="@defective = 'true'">
                                <xsl:text> (incomplete)</xsl:text>
                            </xsl:when>
                            <xsl:otherwise/>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="$cu">
                            <xsl:text> </xsl:text>
                        </xsl:if>
                        <xsl:choose>
                            <xsl:when test="@defective = 'false'">
                                <xsl:text>(complete)</xsl:text>
                            </xsl:when>
                            <xsl:when test="@defective = 'true'">
                                <xsl:text>(incomplete)</xsl:text>
                            </xsl:when>
                            <xsl:otherwise/>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:element>
        </xsl:element>
    </xsl:element>
</xsl:template>

<xsl:template name="itemrow">
    <xsl:param name="header"/>
    <tr>
      <th><xsl:value-of select="$header"/></th>
        <xsl:element name="td">
            <xsl:call-template name="lang"/>
            <xsl:apply-templates/>
        </xsl:element>
    </tr>
</xsl:template>

<xsl:template name="excerpt">
     <xsl:param name="mainlang"/>
     <xsl:param name="xmllang"/>
     <xsl:param name="header"/>    
     <tr>
        <th><xsl:value-of select="$header"/>
            <xsl:choose>
                <xsl:when test="@type='root-text'"> (root text)</xsl:when>
                <xsl:when test="@type='commentary'"> (commentary)</xsl:when>
                <xsl:otherwise/>
            </xsl:choose>
        </th>
        <td>
            <xsl:attribute name="class">excerpt</xsl:attribute>
            <xsl:attribute name="lang">
                <xsl:choose>
                    <xsl:when test="$xmllang">
                        <xsl:value-of select="$xmllang"/>
                    </xsl:when>
                    <xsl:when test="$mainlang">
                        <xsl:value-of select="$mainlang"/>
                    </xsl:when>
                    <xsl:otherwise/>
                </xsl:choose>
            </xsl:attribute>
            <xsl:apply-templates/>
        </td>
     </tr>
</xsl:template>

<xsl:template match="x:msItem">
  <table class="msItem">
    <xsl:variable name="thisid" select="@xml:id"/>
    <xsl:call-template name="msItemHeader"/>
    <!--xsl:apply-templates/-->
    <xsl:for-each select="x:title">
        <xsl:call-template name="itemrow">
            <xsl:with-param name="header">Title</xsl:with-param>
        </xsl:call-template>
    </xsl:for-each>
    <xsl:apply-templates select="@class"/>
    <xsl:for-each select="x:author">
        <xsl:call-template name="itemrow">
            <xsl:with-param name="header">Author</xsl:with-param>
        </xsl:call-template>
    </xsl:for-each>
    <xsl:apply-templates select="x:textLang"/>
    <xsl:apply-templates select="x:filiation"/>
    <xsl:variable name="mainlang" select="substring(x:textLang/@mainLang,1,2)"/>
    <xsl:for-each select="x:rubric | //x:text[@corresp=concat('#',$thisid)]//x:seg[@function='rubric']">
         <xsl:call-template name="excerpt">
            <xsl:with-param name="header">Rubric / Namaskāra</xsl:with-param>
            <xsl:with-param name="xmllang" select="@xml:lang"/>
            <xsl:with-param name="mainlang" select="$mainlang"/>
        </xsl:call-template>
    </xsl:for-each>
    <xsl:for-each select="x:incipit | //x:text[@corresp=concat('#',$thisid)]//x:seg[@function='incipit']">
         <xsl:call-template name="excerpt">
            <xsl:with-param name="header">Incipit</xsl:with-param>
            <xsl:with-param name="xmllang" select="@xml:lang"/>
            <xsl:with-param name="mainlang" select="$mainlang"/>
        </xsl:call-template>
    </xsl:for-each>
    <xsl:for-each select="x:explicit | //x:text[@corresp=concat('#',$thisid)]//x:seg[@function='explicit']">
         <xsl:call-template name="excerpt">
            <xsl:with-param name="header">Explicit</xsl:with-param>
            <xsl:with-param name="xmllang" select="@xml:lang"/>
            <xsl:with-param name="mainlang" select="$mainlang"/>
        </xsl:call-template>
    </xsl:for-each>
    <xsl:for-each select="x:finalRubric | //x:text[@corresp=concat('#',$thisid)]//x:seg[@function='completion-statement']">
         <xsl:call-template name="excerpt">
            <xsl:with-param name="header">Completion statement</xsl:with-param>
            <xsl:with-param name="xmllang" select="@xml:lang"/>
            <xsl:with-param name="mainlang" select="$mainlang"/>
         </xsl:call-template>
    </xsl:for-each>
    <xsl:for-each select="x:colophon | //x:text[@corresp=concat('#',$thisid)]//x:seg[@function='colophon']">
         <xsl:call-template name="excerpt">
            <xsl:with-param name="header">Colophon</xsl:with-param>
            <xsl:with-param name="xmllang" select="@xml:lang"/>
            <xsl:with-param name="mainlang" select="$mainlang"/>
         </xsl:call-template>
    </xsl:for-each>
  </table>
  <xsl:if test="not(position() = last())">
    <xsl:element name="hr"/>
  </xsl:if>
</xsl:template>

<xsl:template match="x:msItem/@class">
    <tr>
      <th>Genre</th>
        <xsl:element name="td">
            <xsl:call-template name="lang"/>
            <xsl:call-template name="splitlist">
                <xsl:with-param name="list" select="."/>
                <xsl:with-param name="nocapitalize">true</xsl:with-param>
                <xsl:with-param name="map">tst:genres</xsl:with-param>
            </xsl:call-template>
        </xsl:element>
    </tr>
</xsl:template>

<xsl:template match="x:msItem/x:title">
    <xsl:apply-templates/>
</xsl:template>
<!--xsl:template match="x:msItem/x:title[not(@type)]">
    <tr>
      <th>Title</th>
        <xsl:element name="td">
            <xsl:call-template name="lang"/>
            <xsl:apply-templates />
        </xsl:element>
    </tr>
</xsl:template>

<xsl:template match="x:msItem/x:title[@type='commentary']">
  <tr>
    <th>Commentary</th>
    <xsl:element name="td">
        <xsl:call-template name="lang"/>
        <xsl:apply-templates />
    </xsl:element>
  </tr>
</xsl:template>

<xsl:template match="x:msItem/x:author">
  <tr>
    <th>Author</th>
    <xsl:element name="td">
        <xsl:call-template name="lang"/>
        <xsl:apply-templates />
    </xsl:element>
  </tr>
</xsl:template>
<xsl:template match="x:msItem/x:author[@role='commentator']">
  <tr>
    <th>Commentator</th>
    <xsl:element name="td">
        <xsl:call-template name="lang"/>
        <xsl:apply-templates />
    </xsl:element>
  </tr>
</xsl:template-->

<xsl:template match="x:textLang">
    <tr>
        <th>Language</th>
        <xsl:element name="td">
            <xsl:variable name="mainLang" select="@mainLang"/>
            <xsl:attribute name="class">record_languages</xsl:attribute>
            <xsl:attribute name="data-mainlang"><xsl:value-of select="$mainLang"/></xsl:attribute>
            <xsl:attribute name="data-otherlangs"><xsl:value-of select="@otherLangs"/></xsl:attribute>
            <xsl:value-of select="$TST/tst:langs/tst:entry[@key=$mainLang]"/>
            <xsl:if test="@otherLangs and not(@otherLangs='')">
                <xsl:text> (+ </xsl:text>
                <xsl:call-template name="splitlist">
                    <xsl:with-param name="list" select="@otherLangs"/>
                    <xsl:with-param name="nocapitalize">true</xsl:with-param>
                    <xsl:with-param name="map">tst:langs</xsl:with-param>
                </xsl:call-template>
                <xsl:text>)</xsl:text>
            </xsl:if>
        </xsl:element>
    </tr>
</xsl:template>

<xsl:template match="x:msItem//x:note">
    <xsl:element name="p">
        <xsl:call-template name="lang"/>
        <xsl:apply-templates/>
    </xsl:element>
</xsl:template>

<xsl:template match="x:filiation">
    <tr>
        <th>Other manuscript testimonies</th>
        <xsl:element name="td">
            <xsl:apply-templates/>
        </xsl:element>
    </tr>
</xsl:template>

<xsl:template match="x:summary">
    <xsl:element name="section">
        <xsl:attribute name="id">summary</xsl:attribute>
        <xsl:call-template name="lang"/>
        <xsl:choose>
            <xsl:when test="x:p">
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="p">
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:element>
</xsl:template>

<xsl:template match="x:physDesc">
  <section>
      <h3>Physical description</h3>
      <table id="physDesc">
      <xsl:apply-templates select="x:objectDesc/@form"/>
      <xsl:apply-templates select="x:objectDesc/x:supportDesc/@material"/>
      <xsl:apply-templates select="x:objectDesc/x:supportDesc/x:extent"/>
      <xsl:apply-templates select="x:objectDesc/x:supportDesc/x:collation"/>
      <xsl:if test="x:objectDesc/x:supportDesc/x:foliation">
          <tr>
            <th>Foliation</th>
            <td><ul>
              <xsl:apply-templates select="x:objectDesc/x:supportDesc/x:foliation"/>
            </ul></td>
          </tr>
      </xsl:if>
      <xsl:apply-templates select="x:objectDesc/x:supportDesc/x:condition"/>
      <xsl:apply-templates select="x:objectDesc/x:layoutDesc"/>
      <xsl:apply-templates select="x:handDesc"/>
      <xsl:apply-templates select="x:decoDesc"/>
      <xsl:apply-templates select="x:additions"/>
      <xsl:apply-templates select="x:bindingDesc"/>
      </table>
  </section>
</xsl:template>

<xsl:template match="x:scriptDesc">
    <ul>
    <xsl:apply-templates select="x:scriptNote"/>
    </ul>
</xsl:template>
<xsl:template match="x:scriptNote">
      <li><xsl:apply-templates/></li>
</xsl:template>

<xsl:template match="x:objectDesc/@form">
  <tr>
    <th>Format</th> <td><xsl:call-template name="capitalize"><xsl:with-param name="str" select="."/></xsl:call-template></td>
  </tr>
</xsl:template>

<xsl:template match="x:objectDesc/x:supportDesc/@material">
  <xsl:variable name="mat" select="."/>
  <xsl:element name="tr">
    <xsl:element name="th">Material</xsl:element>
    <xsl:element name="td">
        <xsl:value-of select="$TST/tst:materials/tst:entry[@key=$mat]"/>
        <xsl:if test="../x:support">
            <xsl:text>. </xsl:text>
            <xsl:apply-templates select="../x:support"/>
        </xsl:if>
    </xsl:element>
  </xsl:element>
</xsl:template>

<xsl:template match="x:objectDesc/x:supportDesc/x:support">
    <xsl:apply-templates/>
</xsl:template>

<xsl:template match="x:measure">
    <xsl:value-of select="@quantity"/>
    <xsl:text> </xsl:text>
    <xsl:value-of select="@unit"/>
    <xsl:text>. </xsl:text>
    <xsl:apply-templates />
</xsl:template>

<xsl:template match="x:measure[@unit='stringhole' or @unit='folio' or @unit='page']">
    <xsl:if test="@quantity and not(@quantity = '') and not(@quantity = '0')">
        <xsl:call-template name="units"/>
        <xsl:text>. </xsl:text>
        <xsl:apply-templates />
   </xsl:if>
</xsl:template>

<xsl:template match="x:objectDesc/x:supportDesc/x:extent">
  <tr>
    <th>Extent</th> 
    <td>
        <xsl:apply-templates select="x:measure"/>
    </td>
  </tr>
  <tr>
    <th>Dimensions</th>
    <td>
        <xsl:apply-templates select="x:dimensions"/>
    </td>
  </tr>
</xsl:template>

<xsl:template match="x:dimensions">
    <xsl:if test="node()[not(self::text())]">
        <ul>
            <xsl:choose>
            <xsl:when test="@type">
                <li>
                    <span class="type"><xsl:value-of select="@type"/></span>
                    <ul>
                        <xsl:apply-templates select="x:width"/>
                        <xsl:apply-templates select="x:height"/>
                        <xsl:apply-templates select="x:depth"/>
                    </ul>
                </li>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="x:width"/>
                <xsl:apply-templates select="x:height"/>
                <xsl:apply-templates select="x:depth"/>
            </xsl:otherwise>
            </xsl:choose>
        </ul>
        <xsl:apply-templates select="x:note"/>
    </xsl:if>
</xsl:template>

<xsl:template match="x:dimensions/x:note">
    <xsl:element name="p">
        <xsl:call-template name="lang"/>
        <xsl:apply-templates/>
    </xsl:element>
</xsl:template>

<xsl:template match="@quantity">
    <xsl:value-of select="."/>
    <xsl:text> </xsl:text>
</xsl:template>

<xsl:template name="min-max">
    <xsl:choose>
        <xsl:when test="@min and not(@min='') and @max and not(@max='')">
            <xsl:value-of select="@min"/><xsl:text>-</xsl:text><xsl:value-of select="@max"/>
        </xsl:when>
        <xsl:otherwise>
            <xsl:if test="@min and not(@min='')"><xsl:apply-templates select="@min"/></xsl:if>
            <xsl:if test="@max and not(@max='')"><xsl:apply-templates select="@max"/></xsl:if>
        </xsl:otherwise>
    </xsl:choose>
    <xsl:text> </xsl:text>
</xsl:template>

<xsl:template match="@min">
    <xsl:text>min. </xsl:text>
    <xsl:value-of select="."/>
    <xsl:text> </xsl:text>
</xsl:template>
<xsl:template match="@max">
    <xsl:text>max. </xsl:text>
    <xsl:value-of select="."/>
</xsl:template>

<xsl:template name="measure">
    <xsl:param name="type"/>
    <xsl:param name="q" select="@quantity"/>
    <xsl:param name="u" select="../@unit"/>
        <xsl:if test="$q or @min or @max or text()">
            <xsl:element name="li">
                <xsl:value-of select="$type"/><xsl:text>: </xsl:text>
                <xsl:apply-templates/>
                <xsl:apply-templates select="$q"/>
                <xsl:call-template name="min-max"/>
                <xsl:value-of select="$u"/>
            </xsl:element>
    </xsl:if>
</xsl:template>

<xsl:template match="x:width">
    <xsl:call-template name="measure">
        <xsl:with-param name="type">width</xsl:with-param>
    </xsl:call-template>
</xsl:template>
<xsl:template match="x:height">
    <xsl:call-template name="measure">
        <xsl:with-param name="type">height</xsl:with-param>
    </xsl:call-template>
</xsl:template>
<xsl:template match="x:depth">
    <xsl:call-template name="measure">
        <xsl:with-param name="type">depth</xsl:with-param>
    </xsl:call-template>
</xsl:template>

<xsl:template match="x:objectDesc/x:supportDesc/x:foliation">
    <li>
        <xsl:if test="@n">
            <xsl:element name="span">
                <xsl:attribute name="class">lihead</xsl:attribute>
                <xsl:value-of select="@n"/>
            </xsl:element>
            <xsl:text>: </xsl:text>
        </xsl:if>
        <xsl:apply-templates />
    </li>
</xsl:template>

<xsl:template match="x:collation">
  <xsl:if test="node()">
      <tr>
        <th>Collation</th>
        <td><ul>
          <xsl:apply-templates/>
        </ul></td>
      </tr>
  </xsl:if>
</xsl:template>

<xsl:template match="x:objectDesc/x:supportDesc/x:collation/x:desc">
    <li>
        <xsl:if test="@xml:id">
            <xsl:element name="span">
                <xsl:attribute name="class">lihead</xsl:attribute>
                <xsl:value-of select="@xml:id"/>
            </xsl:element>
            <xsl:text>: </xsl:text>
        </xsl:if>
        <xsl:apply-templates />
    </li>
</xsl:template>

<xsl:template match="x:objectDesc/x:supportDesc/x:condition">
    <xsl:if test="node()">
        <tr>
          <th>Condition</th>
          <xsl:element name="td">
            <xsl:call-template name="lang"/>
            <xsl:apply-templates/>
          </xsl:element>
        </tr>
    </xsl:if>
</xsl:template>

<xsl:template match="x:objectDesc/x:layoutDesc">
  <xsl:if test="x:layout">
  <tr>
    <th>Layout</th> 
    <td>
        <ul>
            <xsl:apply-templates/>
        </ul>
    </td>
  </tr>
  </xsl:if>
</xsl:template>

<xsl:template match="x:layout">
    <li>
      <xsl:if test="@n">
        <xsl:element name="span">
            <xsl:attribute name="class">lihead</xsl:attribute>
            <xsl:value-of select="@n"/>
            <xsl:text>: </xsl:text>
        </xsl:element>
      </xsl:if>
      <xsl:if test="@style and not(@style='')">
      <xsl:call-template name="capitalize">
        <xsl:with-param name="str" select="@style"/>
      </xsl:call-template>
      <xsl:text>. </xsl:text>
      </xsl:if>
      <xsl:if test="@columns and not(@columns='')">
        <xsl:variable name="q" select="translate(@columns,' ','-')"/>
        <xsl:call-template name="units">
            <xsl:with-param name="u">column</xsl:with-param>
            <xsl:with-param name="q" select="$q"/>
        </xsl:call-template>
        <xsl:text>. </xsl:text>
      </xsl:if>
      <xsl:if test="@streams and not(@streams='')">
        <xsl:variable name="q" select="translate(@streams,' ','-')"/>
        <xsl:call-template name="units">
            <xsl:with-param name="u">stream</xsl:with-param>
            <xsl:with-param name="q" select="$q"/>
        </xsl:call-template>
        <xsl:text>. </xsl:text>
      </xsl:if>
      <xsl:if test="@writtenLines and not(@writtenLines='')">
        <xsl:value-of select="translate(@writtenLines,' ','-')"/>
        <xsl:text> written lines per page. </xsl:text>
      </xsl:if>
      <xsl:if test="@ruledLines and not(@ruledLines='')">
        <xsl:value-of select="translate(@ruledLines,' ','-')"/>
        <xsl:text> ruled lines per page. </xsl:text>
      </xsl:if>
      <xsl:apply-templates />
    </li>
</xsl:template>

<xsl:template match="x:handDesc">
    <xsl:if test="node()[not(self::text())]">
        <tr>
          <th>Scribal Hands</th>
          <td><ul>
            <xsl:apply-templates select="x:handNote"/>
          </ul></td>
        </tr>
    </xsl:if>
</xsl:template>
<xsl:template match="x:decoDesc">
    <xsl:if test="node()[not(self::text())]">
        <tr>
          <th>Decorations &amp; Illustrations</th>
          <td><ul>
            <xsl:apply-templates select="x:decoNote"/>
          </ul></td>
        </tr>
    </xsl:if>
</xsl:template>

<xsl:template match="x:decoNote">
  <li>  
    <xsl:call-template name="synch-format"/>
    <xsl:element name="span">
        <xsl:attribute name="class">type</xsl:attribute>
        <xsl:variable name="type" select="@type"/>
        <xsl:value-of select="$TST/tst:decotype/tst:entry[@key=$type]"/>
        <xsl:if test="@subtype">
            <xsl:text> (</xsl:text>
            <xsl:variable name="subtype" select="@subtype"/>
            <xsl:call-template name="splitlist">
                <xsl:with-param name="list" select="@subtype"/>
                <xsl:with-param name="nocapitalize">true</xsl:with-param>
                <xsl:with-param name="map">tst:subtype</xsl:with-param>
            </xsl:call-template>
            <xsl:text>)</xsl:text>
        </xsl:if>
    </xsl:element>
    <xsl:if test="normalize-space(.) != ''">
        <xsl:apply-templates/>
    </xsl:if>
  </li>
</xsl:template>
<xsl:template match="x:decoNote/x:desc">
    <xsl:element name="ul">
        <xsl:element name="li">
            <xsl:call-template name="lang"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:element>
</xsl:template>

<xsl:template name="synch-format">
        <xsl:if test="@synch">
            <xsl:element name="span">
                <xsl:attribute name="class">lihead</xsl:attribute>
                <xsl:call-template name="splitlist">
                    <xsl:with-param name="list" select="translate(@synch,'#','')"/>
                    <xsl:with-param name="nocapitalize">true</xsl:with-param>
                </xsl:call-template>
                <xsl:text> </xsl:text>
            </xsl:element>
        </xsl:if>
        <xsl:if test="@corresp">
            <xsl:element name="span">
                <xsl:attribute name="class">lihead</xsl:attribute>
                <xsl:call-template name="splitlist">
                    <xsl:with-param name="list" select="translate(@corresp,'#','')"/>
                    <xsl:with-param name="nocapitalize">true</xsl:with-param>
                </xsl:call-template>
                <xsl:text> </xsl:text>
            </xsl:element>
        </xsl:if>
</xsl:template>

<xsl:template match="x:handNote">
  <xsl:variable name="script" select="@script"/>
  <xsl:element name="li">  
    <xsl:attribute name="class">record_scripts</xsl:attribute>
    <xsl:attribute name="data-script"><xsl:value-of select="$script"/></xsl:attribute>
    <xsl:call-template name="synch-format"/>
    <xsl:text>(</xsl:text><xsl:value-of select="@scope"/><xsl:text>) </xsl:text>
    <xsl:apply-templates select="@scribeRef"/>
    
    <xsl:element name="ul">
        <xsl:element name="li">
            <xsl:call-template name="splitlist">    
                <xsl:with-param name="list" select="@script"/>
            </xsl:call-template>
            <xsl:text> script</xsl:text>
            
            <xsl:if test="@scriptRef and not(@scriptRef='')">
                <xsl:text>: </xsl:text>
                <xsl:call-template name="splitlist">
                    <xsl:with-param name="list" select="@scriptRef"/>
                    <xsl:with-param name="nocapitalize">true</xsl:with-param>
                    <xsl:with-param name="map">tst:scriptRef</xsl:with-param>
                </xsl:call-template>
            </xsl:if>
            <xsl:text>.</xsl:text>

            <xsl:if test="@medium and not(@medium='')">
                <xsl:text> </xsl:text>
                <xsl:variable name="donelist">
                    <xsl:call-template name="splitlist">
                        <xsl:with-param name="list" select="@medium"/>
                        <xsl:with-param name="nocapitalize">true</xsl:with-param>
                        <xsl:with-param name="map">tst:media</xsl:with-param>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:call-template name="capitalize">
                    <xsl:with-param name="str" select="$donelist"/>
                </xsl:call-template>
                <xsl:text>.</xsl:text>
            </xsl:if>
        </xsl:element>
    </xsl:element>
    <xsl:apply-templates/>
  </xsl:element>
</xsl:template>

<xsl:template match="x:handNote/@scribeRef">
    <xsl:if test="not(. = '')">
        <xsl:variable name="scribe" select="."/>
        <xsl:value-of select="$TST/tst:scribes/tst:entry[@key=$scribe]"/>
        <xsl:text>. </xsl:text>
    </xsl:if>
</xsl:template>

<xsl:template match="x:handNote/x:p">
    <ul><li><xsl:apply-templates/></li></ul>
</xsl:template>

<xsl:template match="x:handNote/x:desc">
    <xsl:element name="ul">
        <xsl:element name="li">
            <xsl:call-template name="lang"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:element>
</xsl:template>

<xsl:template match="x:additions">
  <xsl:if test="node()[not(self::text())]">
      <tr>
        <th>Paratexts</th>
        <td>
            <ul>
              <xsl:apply-templates />
            </ul>
        </td>
      </tr>
  </xsl:if>
</xsl:template>

<xsl:template match="x:msDesc/x:physDesc/x:additions">
  <xsl:variable name="ps" select="/x:TEI/x:text//x:seg[@function != 'rubric' and 
                                @function != 'incipit' and
                                @function != 'explicit' and
                                @function != 'completion-statement' and
                                @function != 'colophon']"/>
  <xsl:if test="node()[not(self::text())] or $ps">
      <tr>
        <th>Paratexts</th>
        <td>
            <ul>
              <xsl:apply-templates />
              <xsl:for-each select="$ps">
                <li>
                    <span>
                        <xsl:attribute name="class">type</xsl:attribute>
                        <xsl:variable name="type" select="@function"/>
                        <xsl:variable name="cu" select="substring-after(ancestor::x:text/@synch,'#')"/>
                        <xsl:variable name="tu" select="substring-after(ancestor::x:text/@corresp,'#')"/>
                        <xsl:if test="$type">
                            <xsl:call-template name="splitlist">
                                <xsl:with-param name="list" select="$type"/>
                                <xsl:with-param name="nocapitalize">true</xsl:with-param>
                                <xsl:with-param name="map">tst:additiontype</xsl:with-param>
                            </xsl:call-template>
                        </xsl:if>
                        <xsl:if test="$cu or $tu">
                            <xsl:text> (</xsl:text>
                            <xsl:value-of select="$cu"/>
                            <xsl:if test="$cu and $tu">
                                <xsl:text>, </xsl:text>
                            </xsl:if>
                            <xsl:if test="$tu">
                                <xsl:element name="a">
                                    <xsl:attribute name="class">local</xsl:attribute>
                                    <xsl:attribute name="href">
                                        <xsl:text>#text-</xsl:text>
                                        <xsl:value-of select="$tu"/>
                                    </xsl:attribute>
                                    <xsl:attribute name="data-scroll"/>
                                    <xsl:value-of select="$tu"/>
                                </xsl:element>
                            </xsl:if>
                            <xsl:text>)</xsl:text>
                        </xsl:if>
                    </span>
                    <ul>
                        <li>
                            <xsl:attribute name="lang">
                                <xsl:value-of select="ancestor::*[@xml:lang]/@xml:lang"/>
                            </xsl:attribute>
                            <xsl:apply-templates/>
                        </li>
                    </ul>
                </li>
              </xsl:for-each>
            </ul>
        </td>
      </tr>
    </xsl:if>
</xsl:template>

<xsl:template match="x:additions/x:p">
    <li><xsl:apply-templates /></li>
</xsl:template>

<xsl:template match="x:additions/x:desc">
    <li> 
        <xsl:call-template name="synch-format"/>
        <xsl:element name="span">
            <xsl:attribute name="class">type</xsl:attribute>
            <xsl:variable name="type" select="@type"/>
            <xsl:if test="$type">
                <xsl:call-template name="splitlist">
                        <xsl:with-param name="list" select="$type"/>
                        <xsl:with-param name="nocapitalize">true</xsl:with-param>
                        <xsl:with-param name="map">tst:additiontype</xsl:with-param>
                </xsl:call-template>
            </xsl:if>
            <xsl:if test="@subtype">
                <xsl:text> (</xsl:text>
                <xsl:call-template name="splitlist">
                    <xsl:with-param name="list" select="@subtype"/>
                    <xsl:with-param name="nocapitalize">true</xsl:with-param>
                    <xsl:with-param name="map">tst:subtype</xsl:with-param>
                </xsl:call-template>
                <xsl:text>)</xsl:text>
            </xsl:if>
        </xsl:element>
        <xsl:if test="normalize-space(.) != ''">
            <ul>
                <li>
                    <xsl:apply-templates/>
                </li>
            </ul>
        </xsl:if>
    </li>
</xsl:template>

<xsl:template match="x:bindingDesc">
    <xsl:if test="x:binding/node()[not(self::text())]">
        <tr>
            <th>Binding</th>
            <td>
                <xsl:apply-templates/>
            </td>
        </tr>
    </xsl:if>
</xsl:template>

<xsl:template match="x:binding">
    <p><xsl:apply-templates/></p>
</xsl:template>
<xsl:template match="x:binding/x:p">
    <xsl:apply-templates/>
</xsl:template>

<xsl:template match="x:origin/x:origDate">
    <xsl:if test="@when or @notBefore or @notAfter or node()">
        <tr>
            <th>Date of production</th>
            <td>
                <xsl:call-template name="origDate"/>
                <xsl:apply-templates />
            </td>
        </tr>
    </xsl:if>
</xsl:template>
<xsl:template name="origDate">
    <xsl:if test="@when">
        <xsl:value-of select="@when"/><xsl:text>. </xsl:text>
    </xsl:if>
    <xsl:if test="@notBefore or @notAfter">
        <xsl:value-of select="@notBefore"/>
        <xsl:if test="@notAfter">
            <xsl:text>―</xsl:text><xsl:value-of select="@notAfter"/>
        </xsl:if>
        <xsl:text>. </xsl:text>
    </xsl:if>
</xsl:template>

<xsl:template match="x:history">
    <section>
    <h3>History</h3>
    <table id="history">
        <xsl:apply-templates select="x:origin/x:origDate"/>
        <xsl:if test="x:origin/x:origPlace">
        <tr>
            <th>Place of origin</th>
            <td><xsl:apply-templates select="x:origin/x:origPlace"/></td>
        </tr>
        </xsl:if>
        <xsl:if test="x:provenance/node()[not(self::text())]">
            <tr>
                <th>Provenance</th>
                <td><xsl:apply-templates select="x:provenance/node()"/></td>
            </tr>
        </xsl:if>
        <xsl:if test="x:acquisition/node()[not(self::text())]">
            <tr>
                <th>Acquisition</th>
                <td><xsl:apply-templates select="x:acquisition/node()"/></td>
            </tr>
        </xsl:if>
    </table>
    </section>
</xsl:template>

<xsl:template match="x:listBibl">
    <h3>Bibliography</h3>
    <xsl:apply-templates/>
</xsl:template>
<xsl:template match="x:bibl">
    <xsl:element name="p">
        <xsl:attribute name="class">bibliography</xsl:attribute>
        <xsl:apply-templates/>
    </xsl:element>
</xsl:template>

<xsl:template match="x:additional">
    <xsl:apply-templates/>
</xsl:template>

<xsl:template match="x:encodingDesc">
    <h3>Transcription conventions</h3>
    <xsl:apply-templates/>
</xsl:template>

<xsl:template match="x:profileDesc"/>

<xsl:template match="x:revisionDesc">
    <section>
        <h3>Revision history</h3>
        <xsl:element name="table">
            <xsl:apply-templates/>
        </xsl:element>
    </section>
</xsl:template>

<xsl:template match="x:revisionDesc/x:change">
    <xsl:element name="tr">
        <xsl:element name="th">
            <xsl:attribute name="class">when</xsl:attribute>
            <xsl:value-of select="@when"/>
        </xsl:element>
        <xsl:element name="td">
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:element>
</xsl:template>

<xsl:template match="x:ref">
    <xsl:element name="a">
        <xsl:attribute name="href"><xsl:value-of select="@target"/></xsl:attribute>
        <xsl:if test="substring(@target,1,1) = '#'">
            <xsl:attribute name="class">local</xsl:attribute>
        </xsl:if>
        <xsl:apply-templates/>
    </xsl:element>
</xsl:template>

<xsl:template match="x:material">
    <xsl:element name="span">
        <xsl:attribute name="class">material</xsl:attribute>
        <xsl:attribute name="data-anno">material</xsl:attribute>
        <xsl:apply-templates/>
    </xsl:element>
</xsl:template>

<xsl:template match="x:persName">
    <xsl:element name="span">
        <!--xsl:attribute name="href"><xsl:value-of select="$ref"/></xsl:attribute-->
        <xsl:attribute name="class">persname<xsl:call-template name="certainty"/></xsl:attribute>
        <xsl:call-template name="lang"/>
        <xsl:attribute name="data-anno">person name</xsl:attribute>
        <xsl:apply-templates/>
    </xsl:element>
</xsl:template>

<xsl:template match="x:persName[@ref]">
    <xsl:element name="a">
        <xsl:attribute name="href"><xsl:value-of select="@ref"/></xsl:attribute>
        <xsl:attribute name="class">persname</xsl:attribute>
        <xsl:call-template name="lang"/>
        <xsl:attribute name="data-anno">person name</xsl:attribute>
        <xsl:apply-templates/>
    </xsl:element>
</xsl:template>

<xsl:template match="x:geogName">
    <xsl:element name="span">
        <xsl:attribute name="class">geogname</xsl:attribute>
        <xsl:call-template name="lang"/>
        <xsl:attribute name="data-anno">geographical feature</xsl:attribute>
        <xsl:apply-templates/>
    </xsl:element>
</xsl:template>

<xsl:template match="x:placeName">
    <xsl:element name="span">
        <xsl:attribute name="class">placename</xsl:attribute>
        <xsl:call-template name="lang"/>
        <xsl:attribute name="data-anno">place name</xsl:attribute>
        <xsl:apply-templates/>
    </xsl:element>
</xsl:template>

<xsl:template match="x:sourceDoc"/>

</xsl:stylesheet>
