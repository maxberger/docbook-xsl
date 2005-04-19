<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns="http://www.w3.org/1999/xhtml"
		xmlns:db="http://docbook.org/docbook-ng"
		xmlns:f="http://docbook.org/xslt/ns/extension"
		xmlns:h="http://www.w3.org/1999/xhtml"
		xmlns:m="http://docbook.org/xslt/ns/mode"
		xmlns:t="http://docbook.org/xslt/ns/template"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		exclude-result-prefixes="db f h m t xs"
                version='2.0'>

<!-- ********************************************************************
     $Id$
     ********************************************************************

     This file is part of the XSL DocBook Stylesheet distribution.
     See ../README or http://nwalsh.com/docbook/xsl/ for copyright
     and other information.

     ******************************************************************** -->

<xsl:param name="table.footnote.number.symbols" select="''"/>
<xsl:param name="table.footnote.number.format" select="'a'"/>
<xsl:param name="footnote.number.symbols" select="''"/>
<xsl:param name="footnote.number.format" select="'1'"/>

<xsl:template match="db:footnote">
  <xsl:variable name="name" select="f:node-id(.)"/>
  <sup class="{local-name(.)}">
    <xsl:text>[</xsl:text>
    <a name="{$name}" href="{concat('#ftn.', $name)}">
      <xsl:apply-templates select="." mode="m:footnote-number"/>
    </a>
    <xsl:text>]</xsl:text>
  </sup>
</xsl:template>

<xsl:template match="db:footnoteref">
  <xsl:variable name="footnote" select="key('id',@linkend)[1]"/>
  <xsl:variable name="href" select="concat('#ftn.', f:node-id(.))"/>

  <sup class="{local-name(.)}">
    <xsl:text>[</xsl:text>
    <a href="{$href}">
      <xsl:apply-templates select="$footnote" mode="m:footnote-number"/>
    </a>
    <xsl:text>]</xsl:text>
  </sup>
</xsl:template>

<xsl:template match="db:footnote" mode="m:footnote-number">
  <xsl:choose>
    <xsl:when test="string-length(@label) != 0">
      <xsl:value-of select="@label"/>
    </xsl:when>

    <xsl:when test="ancestor::db:tgroup">
      <xsl:variable name="tfnum">
        <xsl:number level="any" from="db:table|db:informaltable" format="1"/>
      </xsl:variable>

      <xsl:choose>
	<xsl:when test="string-length($table.footnote.number.symbols)
			&gt;= $tfnum">
	  <xsl:value-of select="substring($table.footnote.number.symbols,
				          $tfnum, 1)"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:number level="any" from="tgroup"
		      format="{$table.footnote.number.format}"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:variable name="pfoot" select="preceding::db:footnote[not(@label)]"/>
      <xsl:variable name="ptfoot" select="preceding::db:tgroup//db:footnote"/>
      <xsl:variable name="fnum" select="count($pfoot) - count($ptfoot) + 1"/>

      <xsl:choose>
	<xsl:when test="string-length($footnote.number.symbols) &gt;= $fnum">
	  <xsl:value-of select="substring($footnote.number.symbols, $fnum, 1)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:number value="$fnum" format="{$footnote.number.format}"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- ==================================================================== -->

<xsl:template name="t:process-footnotes">
  <xsl:variable name="footnotes" select=".//db:footnote"/>
  <!-- FIXME: what about footnotes in HTML tables? -->
  <xsl:variable name="table.footnotes"
                select=".//db:tgroup//db:footnote"/>

  <!-- Only bother to do this if there's at least one non-table footnote -->
  <xsl:if test="count($footnotes) &gt; count($table.footnotes)">
    <div class="footnotes">
      <hr width="100" align="left" class="footnotes-divider"/>
      <xsl:apply-templates select="$footnotes" mode="m:process-footnote-mode"/>
    </div>
  </xsl:if>
</xsl:template>

<xsl:template name="process.chunk.footnotes">
  <!-- nop -->
</xsl:template>

<xsl:template match="db:footnote" name="t:process-footnote"
	      mode="m:process-footnote-mode">
  <xsl:variable name="name" select="f:node-id(.)"/>

  <xsl:variable name="footnote.body" as="element()*">
    <xsl:apply-templates/>
  </xsl:variable>

  <xsl:variable name="footnote.number" as="xs:string">
    <xsl:apply-templates select="." mode="m:footnote-number"/>
  </xsl:variable>

  <div class="{name(.)}">
    <xsl:choose>
      <xsl:when test="$footnote.body[1][self::h:p]">
	<p>
	  <xsl:copy-of select="$footnote.body[1]/@*"/>
	  <sup>
	    <xsl:text>[</xsl:text>
	    <a href="#{$name}" name="{concat('ftn.', $name)}">
	      <xsl:copy-of select="$footnote.number"/>
	    </a>
	    <xsl:text>]</xsl:text>
	  </sup>
	  <xsl:sequence select="$footnote.body[1]/node()"/>
	</p>
	<xsl:sequence select="$footnote.body[position() &gt; 1]"/>
      </xsl:when>
      <xsl:otherwise>
	<!-- this is the best we can do, I think. -->
	<table border="0" cellpadding="0" cellspacing="0">
	  <tr>
	    <td valign="top" align="left">
	      <sup>
		<xsl:text>[</xsl:text>
		<a href="#{$name}" name="{concat('ftn.', $name)}">
		  <xsl:copy-of select="$footnote.number"/>
		</a>
		<xsl:text>]</xsl:text>
	      </sup>
	    </td>
	    <td valign="top" align="left">
	      <xsl:sequence select="$footnote.body"/>
	    </td>
	  </tr>
	</table>
      </xsl:otherwise>
    </xsl:choose>
  </div>
</xsl:template>

<xsl:template match="db:tgroup//db:footnote"
	      mode="m:process-footnote-mode">
</xsl:template>

<xsl:template match="db:footnote" mode="m:table-footnote-mode">
  <xsl:call-template name="t:process-footnote"/>
</xsl:template>

</xsl:stylesheet>
