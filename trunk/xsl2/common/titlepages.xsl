<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns="http://www.w3.org/1999/xhtml"
		xmlns:db="http://docbook.org/docbook-ng"
                xmlns:doc="http://nwalsh.com/xsl/documentation/1.0"
		xmlns:f="http://docbook.org/xslt/ns/extension"
		xmlns:fn="http://www.w3.org/2004/10/xpath-functions"
		xmlns:h="http://www.w3.org/1999/xhtml"
		xmlns:m="http://docbook.org/xslt/ns/mode"
		xmlns:t="http://docbook.org/xslt/ns/template"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		exclude-result-prefixes="h f m fn db doc t xs"
                version="2.0">

<doc:template name="titlepage" xmlns="http://docbook.org/docbook-ng">
<refpurpose>Processes a title page</refpurpose>

<refdescription>
<para>This template processes the title page content for an element
based on a specified template.
For each element in the template, the corresponding element from the
content is processed (with <code>apply-templates</code>).</para>
</refdescription>

<refparameter>
<variablelist>
<varlistentry><term>info</term>
<listitem>
<para>The bibliographic metadata associated with the element. By default,
this is <tag>db:info/*</tag>.</para>
</listitem>
</varlistentry>
<varlistentry><term>content</term>
<listitem>
<para>The title page template.</para>
</listitem>
</varlistentry>
</variablelist>
</refparameter>

<refreturn>
<para>The formatted title page.</para>
</refreturn>
</doc:template>

<xsl:template name="titlepage">
  <xsl:param name="info" select="db:info/*" as="element()*"/>
  <xsl:param name="content"/>

  <xsl:if test="$info">
    <xsl:choose>
      <xsl:when test="$content instance of document-node()">
	<xsl:apply-templates select="$content" mode="m:titlepage-templates">
	  <xsl:with-param name="node" select="." tunnel="yes"/>
	  <xsl:with-param name="info" select="$info" tunnel="yes"/>
	</xsl:apply-templates>
      </xsl:when>
      <xsl:when test="$content instance of element()">
	<xsl:apply-templates select="$content/*" mode="m:titlepage-templates">
	  <xsl:with-param name="node" select="." tunnel="yes"/>
	  <xsl:with-param name="info" select="$info" tunnel="yes"/>
	</xsl:apply-templates>
      </xsl:when>
      <xsl:when test="fn:empty($content)">
	<xsl:message>
	  <xsl:text>Empty $content in titlepage template (for </xsl:text>
	  <xsl:value-of select="name(.)"/>
	  <xsl:text>).</xsl:text>
	</xsl:message>
      </xsl:when>
      <xsl:otherwise>
	<xsl:message>
	  <xsl:text>Unexpected $content in titlepage template (for </xsl:text>
	  <xsl:value-of select="name(.)"/>
	  <xsl:text>).</xsl:text>
	</xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:if>
</xsl:template>

<doc:mode name="m:titlepage-templates" xmlns="http://docbook.org/docbook-ng">
<refpurpose>Mode for processing the title page template contents</refpurpose>

<refdescription>
<para>This mode is used to process the title page template contents.
For each DocBook element in the template, the corresponding element from
the metadata (if there is one) is formatted. Elements in other namespaces
are copied directly to the title page.</para>
</refdescription>
</doc:mode>

<xsl:template match="db:*" mode="m:titlepage-templates" priority="1000">
  <xsl:param name="node" tunnel="yes"/>
  <xsl:param name="info" tunnel="yes"/>

  <xsl:variable name="this" select="."/>
  <xsl:variable name="content" select="$info[f:node-matches($this,.)]"/>

  <xsl:if test="$content">
    <xsl:apply-templates select="$content" mode="m:titlepage-mode"/>
  </xsl:if>
</xsl:template>

<xsl:template match="*" mode="m:titlepage-templates">
  <xsl:element name="{local-name(.)}" namespace="{namespace-uri(.)}">
    <xsl:copy-of select="@*"/>
    <xsl:apply-templates mode="m:titlepage-templates"/>
  </xsl:element>
</xsl:template>

<xsl:template match="processing-instruction()|comment()"
	      mode="m:titlepage-templates">
  <xsl:copy/>
</xsl:template>

<xsl:template match="text()"
	      mode="m:titlepage-templates">
  <xsl:if test="fn:normalize-space(.) != ''">
    <xsl:copy/>
  </xsl:if>
</xsl:template>

<doc:function name="f:node-matches" xmlns="http://docbook.org/docbook-ng">
<refpurpose>Tests if an element from the title page content matches an element
from the document.</refpurpose>

<refdescription>
<para>An element from the document matches an element from the title page
content if it has the same (qualified) name and if all the attributes
specified in the title page content are equal to the attributes on the
document element.</para>

<para>See also: <function>f:user-node-matches</function>.</para>
</refdescription>

<refparameter>
<variablelist>
<varlistentry><term>template-node</term>
<listitem>
<para>The node from the title page content.</para>
</listitem>
</varlistentry>
<varlistentry><term>document-node</term>
<listitem>
<para>The node from the document.</para>
</listitem>
</varlistentry>
</variablelist>
</refparameter>

<refreturn>
<para>True if the nodes match.</para>
</refreturn>
</doc:function>

<xsl:function name="f:node-matches" as="xs:boolean">
  <xsl:param name="template-node" as="element()"/>
  <xsl:param name="document-node" as="element()"/>

  <xsl:choose>
    <xsl:when test="fn:node-name($template-node) = fn:node-name($document-node)">
      <xsl:variable name="attrMatch">
	<xsl:for-each select="$template-node/@*[namespace-uri(.) = '']">
	  <xsl:variable name="aname" select="local-name(.)"/>
	  <xsl:variable name="attr"
			select="$document-node/@*[local-name(.) = $aname]"/>
	  <xsl:choose>
            <xsl:when test="$attr = .">1</xsl:when>
	    <xsl:otherwise>0</xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </xsl:variable>

      <xsl:choose>
	<xsl:when test="not(contains($attrMatch, '0'))">
	  <xsl:value-of select="f:user-node-matches($template-node,
				                    $document-node)"/>
	</xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="false()"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="false()"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<doc:function name="f:user-node-matches" xmlns="http://docbook.org/docbook-ng">
<refpurpose>Tests if an element from the title page content matches an element
from the document.</refpurpose>

<refdescription>
<para>An element from the document matches an element from the title page
content if it has the same (qualified) name and if all the attributes
specified in the title page content are equal to the attributes on the
document element.</para>

<para>See also: <function>f:user-node-matches</function>.</para>

<para>This function is a hook to customize
<function>f:node-matches</function>. 
Customizers can make the node matching algorithm more selective by redefining
<function>f:user-node-matches</function>, which will be called for every
matching element. If <function>f:user-node-matches</function> returns
<literal>false()</literal>, the elements will be deemed not to match.</para>

<para>Note that <function>f:user-node-matches</function> can only make
the match more selective. There is no function that can force a non-matching
element to match.</para>
</refdescription>

<refparameter>
<variablelist>
<varlistentry><term>template-node</term>
<listitem>
<para>The node from the title page content.</para>
</listitem>
</varlistentry>
<varlistentry><term>document-node</term>
<listitem>
<para>The node from the document.</para>
</listitem>
</varlistentry>
</variablelist>
</refparameter>

<refreturn>
<para>True if the nodes match.</para>
</refreturn>
</doc:function>

<xsl:function name="f:user-node-matches" as="xs:boolean">
  <xsl:param name="template-node" as="element()"/>
  <xsl:param name="document-node" as="element()"/>
  <xsl:value-of select="true()"/>
</xsl:function>

</xsl:stylesheet>
