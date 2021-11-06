<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
                xmlns:exsl="http://exslt.org/common"
                xmlns:x="http://www.tei-c.org/ns/1.0"
                xmlns:tst="https://github.com/tst-project"
                exclude-result-prefixes="x tst">

<xsl:import href="../../../xslt/functions.xsl"/>
<xsl:import href="../../../xslt/definitions.xsl"/>
<xsl:import href="../../../xslt/common.xsl"/>
<xsl:import href="../../../xslt/teiheader.xsl"/>
<xsl:import href="../../../xslt/transcription.xsl"/>

<xsl:output method="html" encoding="UTF-8" omit-xml-declaration="yes"/>

<xsl:template match="x:TEI">
    <xsl:apply-templates/>
</xsl:template>

<xsl:template match="node()">
    <xsl:apply-templates select="node()"/>
</xsl:template>

<xsl:template match="text()">
    <xsl:value-of select="."/>
</xsl:template>
</xsl:stylesheet>
