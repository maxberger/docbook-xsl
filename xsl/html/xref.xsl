<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:suwl="http://nwalsh.com/xslt/ext/com.nwalsh.saxon.UnwrapLinks"
                exclude-result-prefixes="suwl"
                version='1.0'>

<!-- ********************************************************************
     $Id$
     ********************************************************************

     This file is part of the XSL DocBook Stylesheet distribution.
     See ../README or http://nwalsh.com/docbook/xsl/ for copyright
     and other information.

     ******************************************************************** -->

<!-- ==================================================================== -->

<xsl:template match="anchor">
  <xsl:call-template name="anchor"/>
</xsl:template>

<!-- ==================================================================== -->

<xsl:template match="xref" name="xref">
  <xsl:variable name="targets" select="key('id',@linkend)"/>
  <xsl:variable name="target" select="$targets[1]"/>
  <xsl:variable name="refelem" select="local-name($target)"/>

  <xsl:call-template name="check.id.unique">
    <xsl:with-param name="linkend" select="@linkend"/>
  </xsl:call-template>

  <xsl:call-template name="anchor"/>

  <xsl:choose>
    <xsl:when test="count($target) = 0">
      <xsl:message>
	<xsl:text>XRef to nonexistent id: </xsl:text>
	<xsl:value-of select="@linkend"/>
      </xsl:message>
      <xsl:text>???</xsl:text>
    </xsl:when>

    <xsl:when test="$target/@xreflabel">
      <a>
        <xsl:attribute name="href">
          <xsl:call-template name="href.target">
            <xsl:with-param name="object" select="$target"/>
          </xsl:call-template>
        </xsl:attribute>
        <xsl:call-template name="xref.xreflabel">
          <xsl:with-param name="target" select="$target"/>
        </xsl:call-template>
      </a>
    </xsl:when>

    <xsl:otherwise>
      <xsl:variable name="href">
        <xsl:call-template name="href.target">
          <xsl:with-param name="object" select="$target"/>
        </xsl:call-template>
      </xsl:variable>

      <xsl:choose>
        <xsl:when test="@endterm">
          <xsl:variable name="etargets" select="key('id',@endterm)"/>
          <xsl:variable name="etarget" select="$etargets[1]"/>
          <xsl:choose>
            <xsl:when test="count($etarget) = 0">
              <xsl:message>
                <xsl:value-of select="count($etargets)"/>
                <xsl:text>Endterm points to nonexistent ID: </xsl:text>
                <xsl:value-of select="@endterm"/>
              </xsl:message>
              <a href="{$href}">
                <xsl:text>???</xsl:text>
              </a>
            </xsl:when>
            <xsl:otherwise>
              <a href="{$href}">
                <xsl:apply-templates select="$etarget" mode="endterm"/>
              </a>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>

        <xsl:otherwise>
          <xsl:apply-templates select="$target" mode="xref-to-prefix"/>

          <a href="{$href}">
            <xsl:if test="$target/title or $target/*/title">
              <xsl:attribute name="title">
                <xsl:apply-templates select="$target" mode="xref-title"/>
              </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates select="$target" mode="xref-to">
              <xsl:with-param name="referrer" select="."/>
              <xsl:with-param name="xrefstyle">
                <xsl:choose>
                  <xsl:when test="$use.role.as.xrefstyle != 0">
                    <xsl:value-of select="@role"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="@xrefstyle"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:with-param>
            </xsl:apply-templates>
          </a>

          <xsl:apply-templates select="$target" mode="xref-to-suffix"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="*" mode="endterm">
  <!-- Process the children of the endterm element -->
  <xsl:apply-templates select="child::node()"/>
</xsl:template>

<!-- ==================================================================== -->

<xsl:template match="*" mode="xref-to-prefix"/>
<xsl:template match="*" mode="xref-to-suffix"/>

<xsl:template match="*" mode="xref-to">
  <xsl:param name="referrer"/>
  <xsl:param name="xrefstyle"/>

  <xsl:message>
    <xsl:text>Don't know what gentext to create for xref to: "</xsl:text>
    <xsl:value-of select="name(.)"/>
    <xsl:text>", ("</xsl:text>
    <xsl:value-of select="@id"/>
    <xsl:text>")</xsl:text>
  </xsl:message>
  <xsl:text>???</xsl:text>
</xsl:template>

<xsl:template match="title" mode="xref-to">
  <xsl:param name="referrer"/>
  <xsl:param name="xrefstyle"/>

  <!-- if you xref to a title, xref to the parent... -->
  <xsl:choose>
    <!-- FIXME: how reliable is this? -->
    <xsl:when test="contains(local-name(parent::*), 'info')">
      <xsl:apply-templates select="parent::*[2]" mode="xref-to">
        <xsl:with-param name="referrer" select="$referrer"/>
        <xsl:with-param name="xrefstyle" select="$xrefstyle"/>
      </xsl:apply-templates>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates select="parent::*" mode="xref-to">
        <xsl:with-param name="referrer" select="$referrer"/>
        <xsl:with-param name="xrefstyle" select="$xrefstyle"/>
      </xsl:apply-templates>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="abstract|article|authorblurb|bibliodiv|bibliomset
                     |biblioset|blockquote|calloutlist|caution|colophon
                     |constraintdef|formalpara|glossdiv|important|indexdiv
                     |itemizedlist|legalnotice|lot|msg|msgexplan|msgmain
                     |msgrel|msgset|msgsub|note|orderedlist|partintro
                     |productionset|qandadiv|refsynopsisdiv|segmentedlist
                     |set|setindex|sidebar|tip|toc|variablelist|warning"
              mode="xref-to">
  <xsl:param name="referrer"/>
  <xsl:param name="xrefstyle"/>

  <!-- catch-all for things with (possibly optional) titles -->
  <xsl:apply-templates select="." mode="object.xref.markup">
    <xsl:with-param name="purpose" select="'xref'"/>
    <xsl:with-param name="xrefstyle" select="$xrefstyle"/>
    <xsl:with-param name="referrer" select="$referrer"/>
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="author|editor|othercredit|personname" mode="xref-to">
  <xsl:param name="referrer"/>
  <xsl:param name="xrefstyle"/>

  <xsl:call-template name="person.name"/>
</xsl:template>

<xsl:template match="authorgroup" mode="xref-to">
  <xsl:param name="referrer"/>
  <xsl:param name="xrefstyle"/>

  <xsl:call-template name="person.name.list"/>
</xsl:template>

<xsl:template match="figure|example|table|equation" mode="xref-to">
  <xsl:param name="referrer"/>
  <xsl:param name="xrefstyle"/>

  <xsl:apply-templates select="." mode="object.xref.markup">
    <xsl:with-param name="purpose" select="'xref'"/>
    <xsl:with-param name="xrefstyle" select="$xrefstyle"/>
    <xsl:with-param name="referrer" select="$referrer"/>
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="procedure" mode="xref-to">
  <xsl:param name="referrer"/>
  <xsl:param name="xrefstyle"/>

  <xsl:apply-templates select="." mode="object.xref.markup">
    <xsl:with-param name="purpose" select="'xref'"/>
    <xsl:with-param name="xrefstyle" select="$xrefstyle"/>
    <xsl:with-param name="referrer" select="$referrer"/>
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="cmdsynopsis" mode="xref-to">
  <xsl:apply-templates select="(.//command)[1]" mode="xref"/>
</xsl:template>

<xsl:template match="funcsynopsis" mode="xref-to">
  <xsl:apply-templates select="(.//function)[1]" mode="xref"/>
</xsl:template>

<xsl:template match="dedication|preface|chapter|appendix|article" mode="xref-to">
  <xsl:param name="referrer"/>
  <xsl:param name="xrefstyle"/>

  <xsl:apply-templates select="." mode="object.xref.markup">
    <xsl:with-param name="purpose" select="'xref'"/>
    <xsl:with-param name="xrefstyle" select="$xrefstyle"/>
    <xsl:with-param name="referrer" select="$referrer"/>
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="bibliography" mode="xref-to">
  <xsl:param name="referrer"/>
  <xsl:param name="xrefstyle"/>

  <xsl:apply-templates select="." mode="object.xref.markup">
    <xsl:with-param name="purpose" select="'xref'"/>
    <xsl:with-param name="xrefstyle" select="$xrefstyle"/>
    <xsl:with-param name="referrer" select="$referrer"/>
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="biblioentry|bibliomixed" mode="xref-to-prefix">
  <xsl:text>[</xsl:text>
</xsl:template>

<xsl:template match="biblioentry|bibliomixed" mode="xref-to-suffix">
  <xsl:text>]</xsl:text>
</xsl:template>

<xsl:template match="biblioentry|bibliomixed" mode="xref-to">
  <xsl:param name="referrer"/>
  <xsl:param name="xrefstyle"/>

  <!-- handles both biblioentry and bibliomixed -->
  <xsl:choose>
    <xsl:when test="string(.) = ''">
      <xsl:variable name="bib" select="document($bibliography.collection)"/>
      <xsl:variable name="id" select="@id"/>
      <xsl:variable name="entry" select="$bib/bibliography/*[@id=$id][1]"/>
      <xsl:choose>
        <xsl:when test="$entry">
          <xsl:choose>
            <xsl:when test="local-name($entry/*[1]) = 'abbrev'">
              <xsl:apply-templates select="$entry/*[1]"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="@id"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message>
            <xsl:text>No bibliography entry: </xsl:text>
            <xsl:value-of select="$id"/>
            <xsl:text> found in </xsl:text>
            <xsl:value-of select="$bibliography.collection"/>
          </xsl:message>
          <xsl:value-of select="@id"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:choose>
        <xsl:when test="local-name(*[1]) = 'abbrev'">
          <xsl:apply-templates select="*[1]"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="@id"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="glossary" mode="xref-to">
  <xsl:param name="referrer"/>
  <xsl:param name="xrefstyle"/>

  <xsl:apply-templates select="." mode="object.xref.markup">
    <xsl:with-param name="purpose" select="'xref'"/>
    <xsl:with-param name="xrefstyle" select="$xrefstyle"/>
    <xsl:with-param name="referrer" select="$referrer"/>
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="index" mode="xref-to">
  <xsl:param name="referrer"/>
  <xsl:param name="xrefstyle"/>

  <xsl:apply-templates select="." mode="object.xref.markup">
    <xsl:with-param name="purpose" select="'xref'"/>
    <xsl:with-param name="xrefstyle" select="$xrefstyle"/>
    <xsl:with-param name="referrer" select="$referrer"/>
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="listitem" mode="xref-to">
  <xsl:param name="referrer"/>
  <xsl:param name="xrefstyle"/>

  <xsl:apply-templates select="." mode="object.xref.markup">
    <xsl:with-param name="purpose" select="'xref'"/>
    <xsl:with-param name="xrefstyle" select="$xrefstyle"/>
    <xsl:with-param name="referrer" select="$referrer"/>
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="section|simplesect
                     |sect1|sect2|sect3|sect4|sect5
                     |refsect1|refsect2|refsect3" mode="xref-to">
  <xsl:param name="referrer"/>
  <xsl:param name="xrefstyle"/>

  <xsl:apply-templates select="." mode="object.xref.markup">
    <xsl:with-param name="purpose" select="'xref'"/>
    <xsl:with-param name="xrefstyle" select="$xrefstyle"/>
    <xsl:with-param name="referrer" select="$referrer"/>
  </xsl:apply-templates>
  <!-- FIXME: What about "in Chapter X"? -->
</xsl:template>

<xsl:template match="bridgehead" mode="xref-to">
  <xsl:param name="referrer"/>
  <xsl:param name="xrefstyle"/>

  <xsl:apply-templates select="." mode="object.xref.markup">
    <xsl:with-param name="purpose" select="'xref'"/>
    <xsl:with-param name="xrefstyle" select="$xrefstyle"/>
    <xsl:with-param name="referrer" select="$referrer"/>
  </xsl:apply-templates>
  <!-- FIXME: What about "in Chapter X"? -->
</xsl:template>

<xsl:template match="qandaset" mode="xref-to">
  <xsl:param name="referrer"/>
  <xsl:param name="xrefstyle"/>

  <xsl:apply-templates select="." mode="object.xref.markup">
    <xsl:with-param name="purpose" select="'xref'"/>
    <xsl:with-param name="xrefstyle" select="$xrefstyle"/>
    <xsl:with-param name="referrer" select="$referrer"/>
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="qandadiv" mode="xref-to">
  <xsl:param name="referrer"/>
  <xsl:param name="xrefstyle"/>

  <xsl:apply-templates select="." mode="object.xref.markup">
    <xsl:with-param name="purpose" select="'xref'"/>
    <xsl:with-param name="xrefstyle" select="$xrefstyle"/>
    <xsl:with-param name="referrer" select="$referrer"/>
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="qandaentry" mode="xref-to">
  <xsl:param name="referrer"/>
  <xsl:param name="xrefstyle"/>

  <xsl:apply-templates select="question[1]" mode="object.xref.markup">
    <xsl:with-param name="purpose" select="'xref'"/>
    <xsl:with-param name="xrefstyle" select="$xrefstyle"/>
    <xsl:with-param name="referrer" select="$referrer"/>
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="question|answer" mode="xref-to">
  <xsl:param name="referrer"/>
  <xsl:param name="xrefstyle"/>

  <xsl:apply-templates select="." mode="object.xref.markup">
    <xsl:with-param name="purpose" select="'xref'"/>
    <xsl:with-param name="xrefstyle" select="$xrefstyle"/>
    <xsl:with-param name="referrer" select="$referrer"/>
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="part|reference" mode="xref-to">
  <xsl:param name="referrer"/>
  <xsl:param name="xrefstyle"/>

  <xsl:apply-templates select="." mode="object.xref.markup">
    <xsl:with-param name="purpose" select="'xref'"/>
    <xsl:with-param name="xrefstyle" select="$xrefstyle"/>
    <xsl:with-param name="referrer" select="$referrer"/>
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="refentry" mode="xref-to">
  <xsl:param name="referrer"/>
  <xsl:param name="xrefstyle"/>

  <xsl:choose>
    <xsl:when test="refmeta/refentrytitle">
      <xsl:apply-templates select="refmeta/refentrytitle"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates select="refnamediv/refname[1]"/>
    </xsl:otherwise>
  </xsl:choose>
  <xsl:apply-templates select="refmeta/manvolnum"/>
</xsl:template>

<xsl:template match="refnamediv" mode="xref-to">
  <xsl:param name="referrer"/>
  <xsl:param name="xrefstyle"/>

  <xsl:apply-templates select="refname[1]" mode="xref-to">
    <xsl:with-param name="xrefstyle" select="$xrefstyle"/>
    <xsl:with-param name="referrer" select="$referrer"/>
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="refname" mode="xref-to">
  <xsl:param name="referrer"/>
  <xsl:param name="xrefstyle"/>

  <xsl:apply-templates mode="xref-to"/>
</xsl:template>

<xsl:template match="step" mode="xref-to">
  <xsl:param name="referrer"/>
  <xsl:param name="xrefstyle"/>

  <xsl:call-template name="gentext">
    <xsl:with-param name="key" select="'Step'"/>
  </xsl:call-template>
  <xsl:text> </xsl:text>
  <xsl:apply-templates select="." mode="number"/>
</xsl:template>

<xsl:template match="varlistentry" mode="xref-to">
  <xsl:param name="referrer"/>
  <xsl:param name="xrefstyle"/>

  <xsl:apply-templates select="term[1]" mode="xref-to">
    <xsl:with-param name="xrefstyle" select="$xrefstyle"/>
    <xsl:with-param name="referrer" select="$referrer"/>
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="varlistentry/term" mode="xref-to">
  <xsl:param name="referrer"/>
  <xsl:param name="xrefstyle"/>

  <!-- to avoid the comma that will be generated if there are several terms -->
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="co" mode="xref-to">
  <xsl:param name="referrer"/>
  <xsl:param name="xrefstyle"/>

  <xsl:apply-templates select="." mode="callout-bug"/>
</xsl:template>

<xsl:template match="book" mode="xref-to">
  <xsl:param name="referrer"/>
  <xsl:param name="xrefstyle"/>

  <xsl:apply-templates select="." mode="object.xref.markup">
    <xsl:with-param name="purpose" select="'xref'"/>
    <xsl:with-param name="xrefstyle" select="$xrefstyle"/>
    <xsl:with-param name="referrer" select="$referrer"/>
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="para" mode="xref-to">
  <xsl:param name="referrer"/>
  <xsl:param name="xrefstyle"/>

  <xsl:variable name="context" select="(ancestor::simplesect
                                       |ancestor::section
                                       |ancestor::sect1
                                       |ancestor::sect2
                                       |ancestor::sect3
                                       |ancestor::sect4
                                       |ancestor::sect5
                                       |ancestor::refsection
                                       |ancestor::refsect1
                                       |ancestor::refsect2
                                       |ancestor::refsect3
                                       |ancestor::chapter
                                       |ancestor::appendix
                                       |ancestor::preface
                                       |ancestor::partintro
                                       |ancestor::dedication
                                       |ancestor::colophon
                                       |ancestor::bibliography
                                       |ancestor::index
                                       |ancestor::glossary
                                       |ancestor::glossentry
                                       |ancestor::listitem
                                       |ancestor::varlistentry)[last()]"/>

  <xsl:apply-templates select="$context" mode="xref-to"/>
<!--
  <xsl:apply-templates select="." mode="object.xref.markup">
    <xsl:with-param name="purpose" select="'xref'"/>
    <xsl:with-param name="xrefstyle" select="$xrefstyle"/>
    <xsl:with-param name="referrer" select="$referrer"/>
  </xsl:apply-templates>
-->
</xsl:template>

<!-- ==================================================================== -->

<xsl:template match="*" mode="xref-title">
  <xsl:variable name="title">
    <xsl:apply-templates select="." mode="object.title.markup"/>
  </xsl:variable>

  <xsl:value-of select="$title"/>
</xsl:template>

<xsl:template match="author" mode="xref-title">
  <xsl:variable name="title">
    <xsl:call-template name="person.name"/>
  </xsl:variable>

  <xsl:value-of select="$title"/>
</xsl:template>

<xsl:template match="authorgroup" mode="xref-title">
  <xsl:variable name="title">
    <xsl:call-template name="person.name.list"/>
  </xsl:variable>

  <xsl:value-of select="$title"/>
</xsl:template>

<xsl:template match="cmdsynopsis" mode="xref-title">
  <xsl:variable name="title">
    <xsl:apply-templates select="(.//command)[1]" mode="xref"/>
  </xsl:variable>

  <xsl:value-of select="$title"/>
</xsl:template>

<xsl:template match="funcsynopsis" mode="xref-title">
  <xsl:variable name="title">
    <xsl:apply-templates select="(.//function)[1]" mode="xref"/>
  </xsl:variable>

  <xsl:value-of select="$title"/>
</xsl:template>

<xsl:template match="biblioentry|bibliomixed" mode="xref-title">
  <!-- handles both biblioentry and bibliomixed -->
  <xsl:variable name="title">
    <xsl:text>[</xsl:text>
    <xsl:choose>
      <xsl:when test="local-name(*[1]) = 'abbrev'">
        <xsl:apply-templates select="*[1]"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="@id"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>]</xsl:text>
  </xsl:variable>

  <xsl:value-of select="$title"/>
</xsl:template>

<xsl:template match="step" mode="xref-title">
  <xsl:call-template name="gentext">
    <xsl:with-param name="key" select="'Step'"/>
  </xsl:call-template>
  <xsl:text> </xsl:text>
  <xsl:apply-templates select="." mode="number"/>
</xsl:template>

<xsl:template match="co" mode="xref-title">
  <xsl:variable name="title">
    <xsl:apply-templates select="." mode="callout-bug"/>
  </xsl:variable>

  <xsl:value-of select="$title"/>
</xsl:template>

<!-- ==================================================================== -->

<xsl:template match="link" name="link">
  <xsl:param name="a.target"/>

  <xsl:variable name="targets" select="key('id',@linkend)"/>
  <xsl:variable name="target" select="$targets[1]"/>

  <xsl:call-template name="check.id.unique">
    <xsl:with-param name="linkend" select="@linkend"/>
  </xsl:call-template>

  <a>
    <xsl:if test="@id">
      <xsl:attribute name="name"><xsl:value-of select="@id"/></xsl:attribute>
    </xsl:if>

    <xsl:if test="$a.target">
      <xsl:attribute name="target"><xsl:value-of select="$a.target"/></xsl:attribute>
    </xsl:if>

    <xsl:attribute name="href">
      <xsl:call-template name="href.target">
        <xsl:with-param name="object" select="$target"/>
      </xsl:call-template>
    </xsl:attribute>

    <!-- FIXME: is there a better way to tell what elements have a title? -->
    <xsl:if test="local-name($target) = 'book'
                  or local-name($target) = 'set'
                  or local-name($target) = 'chapter'
                  or local-name($target) = 'preface'
                  or local-name($target) = 'appendix'
                  or local-name($target) = 'bibliography'
                  or local-name($target) = 'glossary'
                  or local-name($target) = 'index'
                  or local-name($target) = 'part'
                  or local-name($target) = 'refentry'
                  or local-name($target) = 'reference'
                  or local-name($target) = 'example'
                  or local-name($target) = 'equation'
                  or local-name($target) = 'table'
                  or local-name($target) = 'figure'
                  or local-name($target) = 'simplesect'
                  or starts-with(local-name($target),'sect')
                  or starts-with(local-name($target),'refsect')">
      <xsl:attribute name="title">
        <xsl:apply-templates select="$target"
                             mode="object.title.markup.textonly"/>
      </xsl:attribute>
    </xsl:if>

    <xsl:choose>
      <xsl:when test="count(child::node()) &gt; 0">
        <!-- If it has content, use it -->
        <xsl:apply-templates/>
      </xsl:when>
      <xsl:otherwise>
        <!-- else look for an endterm -->
        <xsl:choose>
          <xsl:when test="@endterm">
            <xsl:variable name="etargets" select="key('id',@endterm)"/>
            <xsl:variable name="etarget" select="$etargets[1]"/>
            <xsl:choose>
              <xsl:when test="count($etarget) = 0">
                <xsl:message>
                  <xsl:value-of select="count($etargets)"/>
                  <xsl:text>Endterm points to nonexistent ID: </xsl:text>
                  <xsl:value-of select="@endterm"/>
                </xsl:message>
                <xsl:text>???</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                  <xsl:apply-templates select="$etarget" mode="endterm"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>

          <xsl:otherwise>
            <xsl:message>
              <xsl:text>Link element has no content and no Endterm. </xsl:text>
              <xsl:text>Nothing to show in the link to </xsl:text>
              <xsl:value-of select="$target"/>
            </xsl:message>
            <xsl:text>???</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </a>
</xsl:template>

<xsl:template match="ulink" name="ulink">
  <xsl:variable name="link">
    <a>
      <xsl:if test="@id">
        <xsl:attribute name="name">
          <xsl:value-of select="@id"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:attribute name="href"><xsl:value-of select="@url"/></xsl:attribute>
      <xsl:if test="$ulink.target != ''">
        <xsl:attribute name="target">
          <xsl:value-of select="$ulink.target"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="count(child::node())=0">
          <xsl:value-of select="@url"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates/>
        </xsl:otherwise>
      </xsl:choose>
    </a>
  </xsl:variable>

  <xsl:choose>
    <xsl:when test="function-available('suwl:unwrapLinks')">
      <xsl:copy-of select="suwl:unwrapLinks($link)"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy-of select="$link"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="olink" name="olink">
  <xsl:call-template name="anchor"/>
  <xsl:variable name="localinfo" select="@localinfo"/>

  <xsl:variable name="href">
    <xsl:choose>
      <xsl:when test="@linkmode">
        <!-- use the linkmode to get the base URI, use localinfo as fragid -->
        <xsl:variable name="modespec" select="key('id',@linkmode)"/>
        <xsl:if test="count($modespec) != 1
                      or local-name($modespec) != 'modespec'">
          <xsl:message>Warning: olink linkmode pointer is wrong.</xsl:message>
        </xsl:if>
        <xsl:value-of select="$modespec"/>
        <xsl:if test="@localinfo">
          <xsl:text>#</xsl:text>
          <xsl:value-of select="@localinfo"/>
        </xsl:if>
      </xsl:when>
      <xsl:when test="@type = 'href'">
        <xsl:call-template name="olink.outline">
          <xsl:with-param name="outline.base.uri"
                          select="unparsed-entity-uri(@targetdocent)"/>
          <xsl:with-param name="localinfo" select="@localinfo"/>
          <xsl:with-param name="return" select="'href'"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$olink.resolver"/>
        <xsl:text>?</xsl:text>
        <xsl:value-of select="$olink.sysid"/>
        <xsl:value-of select="unparsed-entity-uri(@targetdocent)"/>
        <!-- XSL gives no access to the public identifier (grumble...) -->
        <xsl:if test="@localinfo">
          <xsl:text>&amp;</xsl:text>
          <xsl:value-of select="$olink.fragid"/>
          <xsl:value-of select="@localinfo"/>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <a href="{$href}">
    <xsl:choose>
      <xsl:when test="count(node()) &gt; 0">
        <xsl:apply-templates/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="olink.outline">
          <xsl:with-param name="outline.base.uri"
                          select="unparsed-entity-uri(@targetdocent)"/>
          <xsl:with-param name="localinfo" select="@localinfo"/>
          <xsl:with-param name="return" select="'xref'"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </a>
</xsl:template>

<xsl:template name="olink.outline">
  <xsl:param name="outline.base.uri"/>
  <xsl:param name="localinfo"/>
  <xsl:param name="return" select="href"/>

  <xsl:variable name="outline-file"
                select="concat($outline.base.uri,
                               $olink.outline.ext)"/>

  <xsl:variable name="outline" select="document($outline-file,.)/div"/>

  <xsl:variable name="node-href">
    <xsl:choose>
      <xsl:when test="$localinfo != ''">
        <xsl:variable name="node" select="$outline//*[@id=$localinfo]"/>
        <xsl:value-of select="$node/@href"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$outline/@href"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="node-xref">
    <xsl:choose>
      <xsl:when test="$localinfo != ''">
        <xsl:variable name="node" select="$outline//*[@id=$localinfo]"/>
        <xsl:copy-of select="$node/xref"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$outline/xref"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:choose>
    <xsl:when test="$return = 'href'">
      <xsl:value-of select="$node-href"/>
    </xsl:when>
    <xsl:when test="$return = 'xref'">
      <xsl:value-of select="$node-xref"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy-of select="$node-xref"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- ==================================================================== -->

<xsl:template name="xref.xreflabel">
  <!-- called to process an xreflabel...you might use this to make  -->
  <!-- xreflabels come out in the right font for different targets, -->
  <!-- for example. -->
  <xsl:param name="target" select="."/>
  <xsl:value-of select="$target/@xreflabel"/>
</xsl:template>

<!-- ==================================================================== -->

<xsl:template match="title" mode="xref">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="command" mode="xref">
  <xsl:call-template name="inline.boldseq"/>
</xsl:template>

<xsl:template match="function" mode="xref">
  <xsl:call-template name="inline.monoseq"/>
</xsl:template>

<xsl:template match="*" mode="pagenumber.markup">
  <xsl:message>
    <xsl:text>Page numbers make no sense in HTML! (Don't use %p in templates)</xsl:text>
  </xsl:message>
</xsl:template>

<!-- ==================================================================== -->

<xsl:template match="*" mode="insert.title.markup">
  <xsl:param name="purpose"/>
  <xsl:param name="xrefstyle"/>
  <xsl:param name="title"/>

  <xsl:copy-of select="$title"/>
</xsl:template>

<xsl:template match="chapter" mode="insert.title.markup">
  <xsl:param name="purpose"/>
  <xsl:param name="xrefstyle"/>
  <xsl:param name="title"/>

  <xsl:choose>
    <xsl:when test="$purpose = 'xref'">
      <i>
        <xsl:copy-of select="$title"/>
      </i>
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy-of select="$title"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="*" mode="insert.subtitle.markup">
  <xsl:param name="purpose"/>
  <xsl:param name="xrefstyle"/>
  <xsl:param name="subtitle"/>

  <xsl:copy-of select="$subtitle"/>
</xsl:template>

<xsl:template match="*" mode="insert.label.markup">
  <xsl:param name="purpose"/>
  <xsl:param name="xrefstyle"/>
  <xsl:param name="label"/>

  <xsl:copy-of select="$label"/>
</xsl:template>

<xsl:template match="*" mode="insert.pagenumber.markup">
  <xsl:param name="purpose"/>
  <xsl:param name="xrefstyle"/>
  <xsl:param name="pagenumber"/>

  <xsl:copy-of select="$pagenumber"/>
</xsl:template>

<xsl:template match="*" mode="insert.direction.markup">
  <xsl:param name="purpose"/>
  <xsl:param name="xrefstyle"/>
  <xsl:param name="direction"/>

  <xsl:copy-of select="$direction"/>
</xsl:template>

</xsl:stylesheet>
