<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:db="http://docbook.org/docbook-ng"
		xmlns:f="http://docbook.org/xslt/ns/extension"
		xmlns:fn="http://www.w3.org/2003/11/xpath-functions"
		xmlns:m="http://docbook.org/xslt/ns/mode"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		exclude-result-prefixes="f m fn xs"
                version="2.0">

<!-- ********************************************************************
     $Id$
     ********************************************************************

     This file is part of the XSL DocBook Stylesheet distribution.
     See ../README or http://nwalsh.com/docbook/xsl/ for copyright
     and other information.

     ******************************************************************** -->

<xsl:param name="component.label.includes.part.label" select="1"/>
<xsl:param name="section.label.includes.component.label" select="1"/>
<xsl:param name="qanda.inherit.numeration" select="1"/>
<xsl:param name="label.from.part" select="1"/>

<!-- ==================================================================== -->
<!-- label markup -->

<xsl:template match="*" mode="m:intralabel-punctuation">
  <xsl:text>.</xsl:text>
</xsl:template>

<xsl:template match="*" mode="m:label-markup">
  <xsl:param name="verbose" select="1"/>
  <xsl:if test="$verbose">
    <xsl:message>
      <xsl:text>Request for label of unexpected element: </xsl:text>
      <xsl:value-of select="name(.)"/>
    </xsl:message>
  </xsl:if>
</xsl:template>

<xsl:template match="db:set|db:book" mode="m:label-markup">
  <xsl:if test="@label">
    <xsl:value-of select="@label"/>
  </xsl:if>
</xsl:template>

<xsl:template match="db:part" mode="m:label-markup">
  <xsl:choose>
    <xsl:when test="@label">
      <xsl:value-of select="@label"/>
    </xsl:when>
    <xsl:when test="$part.autolabel != 0">
      <xsl:number from="db:book" count="db:part" format="I"/>
    </xsl:when>
  </xsl:choose>
</xsl:template>

<xsl:template match="partintro" mode="m:label-markup">
  <!-- no label -->
</xsl:template>

<xsl:template match="db:preface" mode="m:label-markup">
  <xsl:choose>
    <xsl:when test="@label">
      <xsl:value-of select="@label"/>
    </xsl:when>
    <xsl:when test="$preface.autolabel != 0">
      <xsl:if test="$component.label.includes.part.label != 0 and
		    ancestor::db:part">
        <xsl:variable name="part.label">
          <xsl:apply-templates select="ancestor::db:part" 
                               mode="m:label-markup"/>
        </xsl:variable>
        <xsl:if test="$part.label != ''">
          <xsl:value-of select="$part.label"/>
          <xsl:apply-templates select="ancestor::db:part" 
			       mode="m:intralabel-punctuation"/>
        </xsl:if>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="$label.from.part != 0 and ancestor::db:part">
          <xsl:number from="db:part" count="db:preface" format="1" level="any"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:number from="db:book" count="db:preface" format="1" level="any"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
  </xsl:choose>
</xsl:template>

<xsl:template match="db:chapter" mode="m:label-markup">
  <xsl:choose>
    <xsl:when test="@label">
      <xsl:value-of select="@label"/>
    </xsl:when>
    <xsl:when test="$chapter.autolabel != 0">
      <xsl:if test="$component.label.includes.part.label != 0 and
		    ancestor::db:part">
        <xsl:variable name="part.label">
          <xsl:apply-templates select="ancestor::db:part" 
                               mode="m:label-markup"/>
        </xsl:variable>
        <xsl:if test="$part.label != ''">
          <xsl:value-of select="$part.label"/>
          <xsl:apply-templates select="ancestor::db:part" 
                               mode="m:intralabel-punctuation"/>
        </xsl:if>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="$label.from.part != 0 and ancestor::db:part">
          <xsl:number from="db:part" count="db:chapter" format="1" level="any"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:number from="db:book" count="db:chapter" format="1" level="any"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
  </xsl:choose>
</xsl:template>

<xsl:template match="db:appendix" mode="m:label-markup">
  <xsl:choose>
    <xsl:when test="@label">
      <xsl:value-of select="@label"/>
    </xsl:when>
    <xsl:when test="$appendix.autolabel != 0">
      <xsl:if test="$component.label.includes.part.label != 0 and
		    ancestor::db:part">
        <xsl:variable name="part.label">
          <xsl:apply-templates select="ancestor::db:part" 
                               mode="m:label-markup"/>
        </xsl:variable>
        <xsl:if test="$part.label != ''">
          <xsl:value-of select="$part.label"/>
          <xsl:apply-templates select="ancestor::db:part" 
                               mode="m:intralabel-punctuation"/>
        </xsl:if>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="$label.from.part != 0 and ancestor::db:part">
          <xsl:number from="db:part" count="db:appendix" format="A" level="any"/>
        </xsl:when>
        <xsl:otherwise>
	  <xsl:number from="db:book|db:article"
		      count="db:appendix" format="A" level="any"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
  </xsl:choose>
</xsl:template>

<xsl:template match="db:article" mode="m:label-markup">
  <xsl:if test="@label">
    <xsl:value-of select="@label"/>
  </xsl:if>
</xsl:template>

<xsl:template match="db:dedication|db:colophon" mode="m:label-markup">
  <xsl:if test="@label">
    <xsl:value-of select="@label"/>
  </xsl:if>
</xsl:template>

<xsl:template match="db:reference" mode="m:label-markup">
  <xsl:choose>
    <xsl:when test="@label">
      <xsl:value-of select="@label"/>
    </xsl:when>
    <xsl:when test="$part.autolabel != 0">
      <xsl:number from="db:book" count="db:reference" format="I" level="any"/>
    </xsl:when>
  </xsl:choose>
</xsl:template>

<xsl:template match="db:refentry" mode="m:label-markup">
  <xsl:if test="@label">
    <xsl:value-of select="@label"/>
  </xsl:if>
</xsl:template>

<xsl:template match="db:section" mode="m:label-markup">
  <xsl:if test="@label or f:label-this-section(.)">
    <!-- if this is a nested section, label the parent -->
    <xsl:if test="../self::db:section and f:label-this-section(..)">
      <xsl:apply-templates select=".." mode="m:label-markup"/>
      <xsl:apply-templates select=".." mode="m:intralabel-punctuation"/>
    </xsl:if>

    <xsl:if test="$section.label.includes.component.label != 0
		  and f:is-component(..)">
      <xsl:variable name="parent.label">
	<xsl:apply-templates select=".." mode="m:label-markup"/>
      </xsl:variable>
      <xsl:if test="$parent.label != ''">
	<xsl:copy-of select="$parent.label"/>
	<xsl:apply-templates select=".." mode="m:intralabel-punctuation"/>
      </xsl:if>
    </xsl:if>

    <xsl:choose>
      <xsl:when test="@label">
	<xsl:value-of select="@label"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:number count="db:section"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:if>
</xsl:template>

<xsl:template match="db:sect1" mode="m:label-markup">
  <xsl:if test="@label or f:label-this-section(.)">
    <!-- if the parent is a component, maybe label that too -->
    <xsl:if test="$section.label.includes.component.label != 0
		  and f:is-component(..)">
      <xsl:variable name="parent.label">
	<xsl:apply-templates select=".." mode="m:label-markup"/>
      </xsl:variable>
      <xsl:if test="$parent.label != ''">
	<xsl:copy-of select="$parent.label"/>
	<xsl:apply-templates select=".." mode="m:intralabel-punctuation"/>
      </xsl:if>
    </xsl:if>

    <xsl:choose>
      <xsl:when test="@label">
	<xsl:value-of select="@label"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:number count="db:sect1"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:if>
</xsl:template>

<xsl:template match="db:sect2|db:sect3|db:sect4|db:sect5" mode="m:label-markup">
  <xsl:if test="@label or f:label-this-section(.)">
    <!-- label the parent -->
    <xsl:if test="f:label-this-section(..)">
      <xsl:apply-templates select=".." mode="m:label-markup"/>
      <xsl:apply-templates select=".." mode="m:intralabel-punctuation"/>
    </xsl:if>

    <xsl:choose>
      <xsl:when test="@label">
	<xsl:value-of select="@label"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:choose>
	  <xsl:when test="self::db:sect2">
	    <xsl:number count="db:sect2"/>
	  </xsl:when>
	  <xsl:when test="self::db:sect3">
	    <xsl:number count="db:sect3"/>
	  </xsl:when>
	  <xsl:when test="self::db:sect4">
	    <xsl:number count="db:sect4"/>
	  </xsl:when>
	  <xsl:when test="self::db:sect5">
	    <xsl:number count="db:sect5"/>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:message>label.markup: this can't happen!</xsl:message>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:if>
</xsl:template>

<xsl:template match="db:bridgehead" mode="m:label-markup">
  <!-- FIXME: could we do a better job here? -->
  <xsl:variable name="contsec"
                select="(ancestor::db:section
                         |ancestor::db:simplesect
                         |ancestor::db:sect1
                         |ancestor::db:sect2
                         |ancestor::db:sect3
                         |ancestor::db:sect4
                         |ancestor::db:sect5
                         |ancestor::db:refsect1
                         |ancestor::db:refsect2
                         |ancestor::db:refsect3
                         |ancestor::db:chapter
                         |ancestor::db:appendix
                         |ancestor::db:preface)[last()]"/>

  <xsl:apply-templates select="$contsec" mode="m:label-markup"/>
</xsl:template>

<xsl:template match="db:refsect1" mode="m:label-markup">
  <xsl:choose>
    <xsl:when test="@label">
      <xsl:value-of select="@label"/>
    </xsl:when>
    <xsl:when test="$section.autolabel != 0">
      <xsl:number count="db:refsect1"/>
    </xsl:when>
  </xsl:choose>
</xsl:template>

<xsl:template match="db:refsect2|db:refsect3" mode="m:label-markup">
  <xsl:if test="@label or ($section.autolabel != 0)">
    <!-- label the parent -->
    <xsl:variable name="parent.label">
      <xsl:apply-templates select=".." mode="m:label-markup"/>
    </xsl:variable>
    <xsl:if test="$parent.label != ''">
      <xsl:copy-of select="$parent.label"/>
      <xsl:apply-templates select=".." mode="m:intralabel-punctuation"/>
    </xsl:if>

    <xsl:choose>
      <xsl:when test="@label">
	<xsl:value-of select="@label"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:choose>
	  <xsl:when test="self::db:refsect2">
	    <xsl:number count="db:refsect2"/>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:number count="db:refsect3"/>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:if>
</xsl:template>

<xsl:template match="db:simplesect" mode="m:label-markup">
  <xsl:if test="@label or f:label-this-section(.)">
    <!-- if this is a nested section, label the parent -->
    <xsl:if test="../self::db:section
		  | ../self::db:sect1
		  | ../self::db:sect2
		  | ../self::db:sect3
		  | ../self::db:sect4
		  | ../self::db:sect5">
      <xsl:variable name="parent.section.label">
	<xsl:apply-templates select=".." mode="m:label-markup"/>
      </xsl:variable>
      <xsl:if test="$parent.section.label != ''">
	<xsl:copy-of select="$parent.section.label"/>
	<xsl:apply-templates select=".." mode="m:intralabel-punctuation"/>
      </xsl:if>
    </xsl:if>

    <xsl:if test="$section.label.includes.component.label != 0
		  and f:is-component(..)">
      <xsl:variable name="parent.label">
	<xsl:apply-templates select=".." mode="m:label-markup"/>
      </xsl:variable>
      <xsl:if test="$parent.label != ''">
	<xsl:copy-of select="$parent.label"/>
	<xsl:apply-templates select=".." mode="m:intralabel-punctuation"/>
      </xsl:if>
    </xsl:if>

    <xsl:choose>
      <xsl:when test="@label">
	<xsl:value-of select="@label"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:number count="db:simplesect"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:if>
</xsl:template>

<xsl:template match="db:qandadiv" mode="m:label-markup">
  <xsl:if test="$qandadiv.autolabel != 0">
    <xsl:variable name="lparent" select="(ancestor::db:set
					  |ancestor::db:book
					  |ancestor::db:chapter
					  |ancestor::db:appendix
					  |ancestor::db:preface
					  |ancestor::db:section
					  |ancestor::db:simplesect
					  |ancestor::db:sect1
					  |ancestor::db:sect2
					  |ancestor::db:sect3
					  |ancestor::db:sect4
					  |ancestor::db:sect5
					  |ancestor::db:refsect1
					  |ancestor::db:refsect2
					  |ancestor::db:refsect3)[last()]"/>

    <xsl:variable name="lparent.prefix">
      <xsl:apply-templates select="$lparent" mode="m:label-markup"/>
    </xsl:variable>

    <xsl:variable name="prefix">
      <xsl:if test="$qanda.inherit.numeration != 0">
	<xsl:if test="$lparent.prefix != ''">
	  <xsl:copy-of select="$lparent.prefix"/>
	  <xsl:apply-templates select="$lparent"
			       mode="m:intralabel-punctuation"/>
	</xsl:if>
      </xsl:if>
    </xsl:variable>

    <xsl:value-of select="$prefix"/>
    <xsl:number level="multiple" count="db:qandadiv" format="1"/>
  </xsl:if>
</xsl:template>

<xsl:template match="db:question|db:answer" mode="m:label-markup">
  <xsl:variable name="lparent" select="(ancestor::db:set
                                       |ancestor::db:book
                                       |ancestor::db:chapter
                                       |ancestor::db:appendix
                                       |ancestor::db:preface
                                       |ancestor::db:section
                                       |ancestor::db:simplesect
                                       |ancestor::db:sect1
                                       |ancestor::db:sect2
                                       |ancestor::db:sect3
                                       |ancestor::db:sect4
                                       |ancestor::db:sect5
                                       |ancestor::db:refsect1
                                       |ancestor::db:refsect2
                                       |ancestor::db:refsect3)[last()]"/>

  <xsl:variable name="lparent.prefix">
    <xsl:apply-templates select="$lparent" mode="m:label-markup"/>
  </xsl:variable>

  <xsl:variable name="prefix">
    <xsl:if test="$qanda.inherit.numeration != 0">
      <xsl:if test="$lparent.prefix != ''">
	<xsl:copy-of select="$lparent.prefix"/>
	<xsl:apply-templates select="$lparent" mode="m:intralabel-punctuation"/>
      </xsl:if>

      <xsl:if test="ancestor::db:qandadiv">
        <xsl:apply-templates select="ancestor::db:qandadiv[1]"
			     mode="m:label-markup"/>
	<xsl:apply-templates select="ancestor::db:qandadiv[1]"
			     mode="m:intralabel-punctuation"/>
      </xsl:if>
    </xsl:if>
  </xsl:variable>

  <xsl:variable name="inhlabel"
		select="ancestor-or-self::db:qandaset/@defaultlabel[1]"/>

  <xsl:variable name="deflabel">
    <xsl:choose>
      <xsl:when test="$inhlabel != ''">
        <xsl:value-of select="$inhlabel"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$qanda.defaultlabel"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:choose>
    <xsl:when test="db:label">
      <xsl:apply-templates select="db:label"/>
    </xsl:when>

    <xsl:when test="$deflabel = 'qanda'">
      <xsl:if test="self::db:question">
	<xsl:call-template name="gentext">
	  <xsl:with-param name="key" select="'Question'"/>
	</xsl:call-template>
      </xsl:if>

      <xsl:if test="self::db:anser">
	<xsl:call-template name="gentext">
	  <xsl:with-param name="key" select="'Answer'"/>
	</xsl:call-template>
      </xsl:if>
    </xsl:when>

    <xsl:when test="$deflabel = 'number' and self::db:question">
      <xsl:value-of select="$prefix"/>
      <xsl:number level="multiple" count="db:qandaentry" format="1"/>
    </xsl:when>
  </xsl:choose>
</xsl:template>

<xsl:template match="db:bibliography|db:glossary|db:index|db:setindex"
	      mode="m:label-markup">
  <xsl:if test="@label">
    <xsl:value-of select="@label"/>
  </xsl:if>
</xsl:template>

<xsl:template match="db:figure|db:table|db:example|db:procedure"
	      mode="m:label-markup">

  <xsl:variable name="pchap"
                select="ancestor::db:chapter
                        |ancestor::db:appendix
                        |ancestor::db:article[ancestor::db:book]"/>

  <xsl:choose>
    <xsl:when test="@label">
      <xsl:value-of select="@label"/>
    </xsl:when>
    <xsl:when test="self::db:procedure and $formal.procedures = 0">
      <!-- No label -->
    </xsl:when>
    <xsl:otherwise>
      <xsl:choose>
        <xsl:when test="$pchap">
	  <xsl:variable name="prefix">
	    <xsl:apply-templates select="$pchap" mode="m:label-markup"/>
	  </xsl:variable>

	  <xsl:if test="$prefix != ''">
	    <xsl:copy-of select="$prefix"/>
	    <xsl:apply-templates select="$pchap"
				 mode="m:intralabel-punctuation"/>
	  </xsl:if>
	  <xsl:number format="1" from="db:chapter|db:appendix" level="any"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:number format="1" from="db:book|db:article" level="any"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="db:equation" mode="m:label-markup">
  <xsl:variable name="pchap"
                select="ancestor::chapter
                        |ancestor::appendix
                        |ancestor::article[ancestor::book]"/>

  <xsl:choose>
    <xsl:when test="@label">
      <xsl:value-of select="@label"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:if test="$pchap">
	<xsl:variable name="prefix">
	  <xsl:apply-templates select="$pchap" mode="m:label-markup"/>
	</xsl:variable>

	<xsl:if test="$prefix != ''">
	  <xsl:copy-of select="$prefix"/>
	  <xsl:apply-templates select="$pchap"
			       mode="m:intralabel-punctuation"/>
	</xsl:if>
      </xsl:if>

      <xsl:number format="1" count="db:equation[db:info/db:title]"
		  from="db:chapter|db:appendix" level="any"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="db:orderedlist/db:listitem" mode="m:label-markup">
  <xsl:variable name="numeration" select="f:orderedlist-numeration(..)"/>
  <xsl:variable name="type">
    <xsl:choose>
      <xsl:when test="$numeration='arabic'">1</xsl:when>
      <xsl:when test="$numeration='loweralpha'">a</xsl:when>
      <xsl:when test="$numeration='lowerroman'">i</xsl:when>
      <xsl:when test="$numeration='upperalpha'">A</xsl:when>
      <xsl:when test="$numeration='upperroman'">I</xsl:when>
      <!-- What!? This should never happen -->
      <xsl:otherwise>
        <xsl:message>
          <xsl:text>Unexpected numeration: </xsl:text>
          <xsl:value-of select="$numeration"/>
        </xsl:message>
        <xsl:value-of select="1."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:number value="f:orderedlist-item-number(.)"
	      format="{$type}"/>
</xsl:template>

<xsl:template match="db:abstract" mode="m:label-markup">
  <!-- nop -->
</xsl:template>

<!-- ============================================================ -->

</xsl:stylesheet>
