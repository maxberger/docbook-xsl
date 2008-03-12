<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:doc="http://nwalsh.com/xsl/documentation/1.0"
                xmlns:f="http://docbook.org/xslt/ns/extension"
                xmlns:l="http://docbook.sourceforge.net/xmlns/l10n/1.0"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                exclude-result-prefixes="doc f l xs"
                version='2.0'>

<!-- ********************************************************************
     $Id$
     ********************************************************************

     This file is part of the XSL DocBook Stylesheet distribution.
     See ../README or http://nwalsh.com/docbook/xsl/ for copyright
     and other information.

     This file contains localization templates (for internationalization)
     ******************************************************************** -->

<xsl:param name="localization.xml" select="'../common/l10n.xml'"/>
<xsl:variable name="localization.data" select="doc($localization.xml)"/>

<xsl:variable name="localization">
  <xsl:call-template name="user-localization-data"/>
  <xsl:copy-of select="$localization.data/l:i18n/l:l10n"/>
</xsl:variable>

<!-- ============================================================ -->

<doc:template name="user-localization-data"
	      xmlns="http://docbook.org/ns/docbook">
<refpurpose>A hook for customizer localization data</refpurpose>

<refdescription>
<para>This template is hook for customizers to add localization data.
Any localization rules provided by this template will override the default
localization data.</para>
</refdescription>

<refreturn>
<para>Any customizer-supplied localization data.</para>
</refreturn>
</doc:template>

<xsl:template name="user-localization-data">
  <!-- nop -->
</xsl:template>

<!-- ============================================================ -->

<doc:function name="f:l10n-language" xmlns="http://docbook.org/ns/docbook">
<refpurpose>Identifies the natural language associated with an element</refpurpose>

<refdescription>
<para>This function returns the natural language associated with specified
target.</para>
</refdescription>

<refparameter>
<variablelist>
<varlistentry><term>target</term>
<listitem>
<para>The node for which the language should be calculated.</para>
</listitem>
</varlistentry>
<varlistentry><term>xref-context</term>
<listitem>
<para>If true, the resolution is taking place in a cross-reference context.
</para>
<para>FIXME: I think there's a bug here!</para>
</listitem>
</varlistentry>
</variablelist>
</refparameter>

<refreturn>
<para>The language.</para>
</refreturn>
</doc:function>

<xsl:function name="f:l10n-language" as="xs:string">
  <xsl:param name="target" as="element()"/>
  <xsl:value-of select="f:l10n-language($target,false())"/>
</xsl:function>

<xsl:function name="f:l10n-language" as="xs:string">
  <xsl:param name="target" as="element()"/>
  <xsl:param name="xref-context" as="xs:boolean"/>

  <xsl:variable name="mc-language">
    <xsl:choose>
      <xsl:when test="$l10n.gentext.language != ''">
        <xsl:value-of select="$l10n.gentext.language"/>
      </xsl:when>

      <xsl:when test="$xref-context or $l10n.gentext.use.xref.language != 0">
        <!-- can't do this one step: attributes are unordered! -->
        <xsl:variable name="lang-scope"
                      select="$target/ancestor-or-self::*
                              [@lang or @xml:lang][last()]"/>
        <xsl:variable name="lang-attr"
                      select="($lang-scope/@lang | $lang-scope/@xml:lang)[1]"/>
        <xsl:choose>
          <xsl:when test="string($lang-attr) = ''">
            <xsl:value-of select="$l10n.gentext.default.language"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$lang-attr"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>

      <xsl:otherwise>
        <!-- can't do this one step: attributes are unordered! -->
        <xsl:variable name="lang-scope"
                      select="$target/ancestor-or-self::*
                              [@lang or @xml:lang][last()]"/>
        <xsl:variable name="lang-attr"
                      select="($lang-scope/@lang | $lang-scope/@xml:lang)[1]"/>

        <xsl:choose>
          <xsl:when test="string($lang-attr) = ''">
            <xsl:value-of select="$l10n.gentext.default.language"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$lang-attr"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="language" select="translate($mc-language,
                                        'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
                                        'abcdefghijklmnopqrstuvwxyz')"/>

  <xsl:variable name="adjusted.language">
    <xsl:choose>
      <xsl:when test="contains($language,'-')">
        <xsl:value-of select="substring-before($language,'-')"/>
        <xsl:text>_</xsl:text>
        <xsl:value-of select="substring-after($language,'-')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$language"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:choose>
    <xsl:when test="$l10n.xml/l:i18n/l:l10n[@language=$adjusted.language]">
      <xsl:value-of select="$adjusted.language"/>
    </xsl:when>
    <!-- try just the lang code without country -->
    <xsl:when test="$l10n.xml/l:i18n/l:l10n[@language=substring-before($adjusted.language,'_')]">
      <xsl:value-of select="substring-before($adjusted.language,'_')"/>
    </xsl:when>
    <!-- or use the default -->
    <xsl:otherwise>
      <xsl:message>
        <xsl:text>No localization exists for "</xsl:text>
        <xsl:value-of select="$adjusted.language"/>
        <xsl:text>" or "</xsl:text>
        <xsl:value-of select="substring-before($adjusted.language,'_')"/>
        <xsl:text>". Using default "</xsl:text>
        <xsl:value-of select="$l10n.gentext.default.language"/>
        <xsl:text>".</xsl:text>
      </xsl:message>
      <xsl:value-of select="$l10n.gentext.default.language"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!-- ============================================================ -->

<doc:template name="lang-attribute" xmlns="http://docbook.org/ns/docbook">
<refpurpose>Returns a language attribute, if appropriate.</refpurpose>

<refdescription>
<para>This template returns an attribute named <tag class="attribute">lang</tag>
with the language of the specified node, if the specified node has
an in-scope language declaration.</para>
</refdescription>

<refparameter>
<variablelist>
<varlistentry><term>node</term>
<listitem>
<para>The node for which the language should be calculated.</para>
</listitem>
</varlistentry>
</variablelist>
</refparameter>

<refreturn>
<para>A <tag class="attribute">lang</tag> attribute, or ().</para>
</refreturn>
</doc:template>

<xsl:template name="lang-attribute">
  <xsl:param name="node" select="."/>

  <xsl:variable name="language">
    <xsl:choose>
      <xsl:when test="$l10n.gentext.language != ''">
        <xsl:value-of select="$l10n.gentext.language"/>
      </xsl:when>

      <xsl:otherwise>
        <!-- can't do this one step: attributes are unordered! -->
        <xsl:variable name="lang-scope"
                      select="$node/ancestor-or-self::*
                              [@lang or @xml:lang][last()]"/>
        <xsl:variable name="lang-attr"
                      select="($lang-scope/@lang | $lang-scope/@xml:lang)[1]"/>

        <xsl:choose>
          <xsl:when test="string($lang-attr) = ''">
            <xsl:value-of select="$l10n.gentext.default.language"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$lang-attr"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:if test="$language != ''">
    <xsl:attribute name="lang">
      <xsl:value-of select="$language"/>
    </xsl:attribute>
  </xsl:if>
</xsl:template>

<!-- ============================================================ -->

<doc:template name="gentext" xmlns="http://docbook.org/ns/docbook">
<refpurpose>Returns the generated text associated with a particular key
in a particular language (locale)</refpurpose>

<refdescription>
<para>This template finds the gentext associated with a specified key
in a specified locale. If no key can be found in the specified language,
English will be used to locate a default.</para>
</refdescription>

<refparameter>
<variablelist>
<varlistentry><term>key</term>
<listitem>
<para>The gentext key, defaults to the local name of the context node.</para>
</listitem>
</varlistentry>
<varlistentry><term>lang</term>
<listitem>
<para>The gentext language (locale), defaults to the language of the
context node.</para>
</listitem>
</varlistentry>
</variablelist>
</refparameter>

<refreturn>
<para>The generated text.</para>
</refreturn>
</doc:template>

<xsl:template name="gentext">
  <xsl:param name="key" select="local-name(.)"/>
  <xsl:param name="lang" select="f:l10n-language(.)"/>

  <xsl:variable name="l10n.gentext"
		select="($localization
			 //l:l10n[@language=$lang]
			 /l:gentext[@key=$key])[1]"/>

  <xsl:choose>
    <xsl:when test="$l10n.gentext">
      <xsl:value-of select="$l10n.gentext/@text"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:message>
        <xsl:text>No "</xsl:text>
        <xsl:value-of select="$lang"/>
        <xsl:text>" localization of "</xsl:text>
        <xsl:value-of select="$key"/>
        <xsl:text>" exists</xsl:text>
        <xsl:choose>
          <xsl:when test="$lang = 'en'">
             <xsl:text>.</xsl:text>
          </xsl:when>
          <xsl:otherwise>
             <xsl:text>; using "en".</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:message>
      <xsl:value-of select="($localization
			    //l:l10n[@language='en']
			    /l:gentext[@key=$key])[1]/@text"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="gentext-space">
  <xsl:text> </xsl:text>
</xsl:template>

<!-- ============================================================ -->

<doc:template name="gentext-template" xmlns="http://docbook.org/ns/docbook">
<refpurpose>Returns the generated text template associated with a particular set
of criteria</refpurpose>

<refdescription>
<para>This template finds the gentext template associated with the specified
parameters.</para>
</refdescription>

<refparameter>
<variablelist>
<varlistentry><term>context</term>
<listitem>
<para>The context of the template.</para>
</listitem>
</varlistentry>
<varlistentry><term>name</term>
<listitem>
<para>The name of the template.</para>
</listitem>
</varlistentry>
<varlistentry><term>purpose</term>
<listitem>
<para>The purpose of the template.</para>
</listitem>
</varlistentry>
<varlistentry><term>xrefstyle</term>
<listitem>
<para>If the purpose is for a cross reference, the cross reference style.</para>
</listitem>
</varlistentry>
<varlistentry><term>referrer</term>
<listitem>
<para>If the purpose is for a cross reference, the referrer.</para>
</listitem>
</varlistentry>
<varlistentry><term>lang</term>
<listitem>
<para>The language, defaults to the language of the current context node.</para>
</listitem>
</varlistentry>
</variablelist>
</refparameter>

<refreturn>
<para>The generated text template.</para>
</refreturn>
</doc:template>

<xsl:template name="gentext-template">
  <xsl:param name="context" select="'default'"/>
  <xsl:param name="name" select="'default'"/>
  <xsl:param name="purpose"/>
  <xsl:param name="xrefstyle"/>
  <xsl:param name="referrer"/>
  <xsl:param name="lang" select="f:l10n-language(.)"/>
  <xsl:param name="origname" select="$name"/>

  <xsl:variable name="localization.nodes"
		select="$localization//l:l10n[@language=$lang]"/>

  <xsl:if test="not($localization.nodes)">
    <xsl:message>
      <xsl:text>No "</xsl:text>
      <xsl:value-of select="$lang"/>
      <xsl:text>" localization exists.</xsl:text>
    </xsl:message>
  </xsl:if>

  <xsl:variable name="context.nodes"
                select="$localization.nodes/l:context[@name=$context]"/>

  <xsl:if test="not($context.nodes)">
    <xsl:message>
      <xsl:text>No context named "</xsl:text>
      <xsl:value-of select="$context"/>
      <xsl:text>" exists in the "</xsl:text>
      <xsl:value-of select="$lang"/>
      <xsl:text>" localization.</xsl:text>
    </xsl:message>
  </xsl:if>

  <xsl:variable name="template.node"
                select="($context.nodes/l:template[@name=$name
                                                   and @style
                                                   and @style=$xrefstyle]
                        |$context.nodes/l:template[@name=$name
                                                   and not(@style)])[1]"/>

  <xsl:choose>
    <xsl:when test="$template.node/@text">
      <xsl:value-of select="$template.node/@text"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:choose>
	<xsl:when test="contains($name, '/')">
          <xsl:call-template name="gentext-template">
            <xsl:with-param name="context" select="$context"/>
            <xsl:with-param name="name" select="substring-after($name, '/')"/>
            <xsl:with-param name="origname" select="$origname"/>
            <xsl:with-param name="purpose" select="$purpose"/>
            <xsl:with-param name="xrefstyle" select="$xrefstyle"/>
            <xsl:with-param name="referrer" select="$referrer"/>
            <xsl:with-param name="lang" select="$lang"/>
          </xsl:call-template>
        </xsl:when>
	<xsl:otherwise>
          <xsl:message>
	    <xsl:text>No template for "</xsl:text>
            <xsl:value-of select="$origname"/>
            <xsl:text>" (or any of its leaves) exists
in the context named "</xsl:text>
            <xsl:value-of select="$context"/>
            <xsl:text>" in the "</xsl:text>
            <xsl:value-of select="$lang"/>
            <xsl:text>" localization.</xsl:text>
          </xsl:message>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- ============================================================ -->

<doc:template name="gentext-template-exists"
	      xmlns="http://docbook.org/ns/docbook">
<refpurpose>Tests if the generated text template associated with a particular set
of criteria exists</refpurpose>

<refdescription>
<para>This template attempts to find the gentext template associated with
the specified parameters.</para>
</refdescription>

<refparameter>
<variablelist>
<varlistentry><term>context</term>
<listitem>
<para>The context of the template.</para>
</listitem>
</varlistentry>
<varlistentry><term>name</term>
<listitem>
<para>The name of the template.</para>
</listitem>
</varlistentry>
<varlistentry><term>purpose</term>
<listitem>
<para>The purpose of the template.</para>
</listitem>
</varlistentry>
<varlistentry><term>xrefstyle</term>
<listitem>
<para>If the purpose is for a cross reference, the cross reference style.</para>
</listitem>
</varlistentry>
<varlistentry><term>referrer</term>
<listitem>
<para>If the purpose is for a cross reference, the referrer.</para>
</listitem>
</varlistentry>
<varlistentry><term>lang</term>
<listitem>
<para>The language, defaults to the language of the current context node.</para>
</listitem>
</varlistentry>
</variablelist>
</refparameter>

<refreturn>
<para>“1” if the template exists, “0” otherwise.</para>
</refreturn>
</doc:template>

<xsl:template name="gentext-template-exists">
  <xsl:param name="context" select="'default'"/>
  <xsl:param name="name" select="'default'"/>
  <xsl:param name="origname" select="$name"/>
  <xsl:param name="purpose"/>
  <xsl:param name="xrefstyle"/>
  <xsl:param name="referrer"/>
  <xsl:param name="lang" select="f:l10n-language(.)"/>

  <xsl:variable name="localization.nodes"
		select="$localization//l:l10n[@language=$lang]"/>

  <xsl:variable name="context.nodes"
                select="$localization.nodes/l:context[@name=$context]"/>

  <xsl:variable name="template.node"
                select="($context.nodes/l:template[@name=$name
                                                   and @style
                                                   and @style=$xrefstyle]
                        |$context.nodes/l:template[@name=$name
                                                   and not(@style)])[1]"/>

  <xsl:choose>
    <xsl:when test="$template.node/@text">1</xsl:when>
    <xsl:otherwise>
      <xsl:choose>
	<xsl:when test="contains($name, '/')">
	  <xsl:call-template name="gentext-template-exists">
	    <xsl:with-param name="context" select="$context"/>
	    <xsl:with-param name="name" select="substring-after($name, '/')"/>
	    <xsl:with-param name="origname" select="$origname"/>
	    <xsl:with-param name="purpose" select="$purpose"/>
	    <xsl:with-param name="xrefstyle" select="$xrefstyle"/>
	    <xsl:with-param name="referrer" select="$referrer"/>
	    <xsl:with-param name="lang" select="$lang"/>
	  </xsl:call-template>
	</xsl:when>
	<xsl:otherwise>0</xsl:otherwise>
      </xsl:choose>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- ============================================================ -->

<doc:template name="gentext-dingbat" xmlns="http://docbook.org/ns/docbook">
<refpurpose>Returns the symbol associated with a named dingbat</refpurpose>

<refdescription>
<para>See <function>dingbat</function>.</para>
</refdescription>

<refparameter>
<variablelist>
<varlistentry><term>dingbat</term>
<listitem>
<para>The name of the dingbat for which a symbol is sought.</para>
</listitem>
</varlistentry>
<varlistentry><term>lang</term>
<listitem>
<para>The language, defaults to the language of the current context node.</para>
</listitem>
</varlistentry>
</variablelist>
</refparameter>

<refreturn>
<para>The symbol.</para>
</refreturn>
</doc:template>

<xsl:template name="gentext-dingbat">
  <xsl:param name="dingbat">bullet</xsl:param>
  <xsl:param name="lang" select="f:l10n-language(.)"/>

  <xsl:value-of select="f:dingbat(., $dingbat, $lang)"/>
</xsl:template>

<!-- ============================================================ -->

<doc:template name="gentext-startquote" xmlns="http://docbook.org/ns/docbook">
<refpurpose>Returns the symbol associated with “startquote”</refpurpose>

<refdescription>
<para>See <function>dingbat</function>.</para>
</refdescription>

<refreturn>
<para>The symbol.</para>
</refreturn>
</doc:template>

<xsl:template name="gentext-startquote">
  <xsl:value-of select="f:dingbat(., 'startquote')"/>
</xsl:template>

<!-- ============================================================ -->

<doc:template name="gentext-endquote" xmlns="http://docbook.org/ns/docbook">
<refpurpose>Returns the symbol associated with “endquote”</refpurpose>

<refdescription>
<para>See <function>dingbat</function>.</para>
</refdescription>

<refreturn>
<para>The symbol.</para>
</refreturn>
</doc:template>

<xsl:template name="gentext-endquote">
  <xsl:value-of select="f:dingbat(., 'endquote')"/>
</xsl:template>

<!-- ============================================================ -->

<doc:template name="gentext-nestedstartquote"
	      xmlns="http://docbook.org/ns/docbook">
<refpurpose>Returns the symbol associated with “nestedstartquote”</refpurpose>

<refdescription>
<para>See <function>dingbat</function>.</para>
</refdescription>

<refreturn>
<para>The symbol.</para>
</refreturn>
</doc:template>

<xsl:template name="gentext-nestedstartquote">
  <xsl:value-of select="f:dingbat(., 'nestedstartquote')"/>
</xsl:template>

<!-- ============================================================ -->

<doc:template name="gentext-nestedendquote"
	      xmlns="http://docbook.org/ns/docbook">
<refpurpose>Returns the symbol associated with “nestedendquote”</refpurpose>

<refdescription>
<para>See <function>dingbat</function>.</para>
</refdescription>

<refreturn>
<para>The symbol.</para>
</refreturn>
</doc:template>

<xsl:template name="gentext-nestedendquote">
  <xsl:value-of select="f:dingbat(., 'nestedendquote')"/>
</xsl:template>

</xsl:stylesheet>

