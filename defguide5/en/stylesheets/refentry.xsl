<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns='http://docbook.org/docbook-ng'
		xmlns:s="http://www.ascc.net/xml/schematron"
		xmlns:set="http://exslt.org/sets"
		xmlns:db='http://docbook.org/docbook-ng'
		xmlns:dbx="http://sourceforge.net/projects/docbook/defguide/schema/extra-markup"
		xmlns:rng='http://relaxng.org/ns/structure/1.0'
		xmlns:xlink="http://www.w3.org/1999/xlink"
		xmlns:doc='http://nwalsh.com/xmlns/schema-doc/'
		exclude-result-prefixes="db rng xlink doc s set dbx"
                version="2.0">

<xsl:output method="xml" encoding="utf-8" indent="no"/>

<xsl:key name="div" match="rng:div" use="db:refname"/>
<xsl:key name="element" match="rng:element" use="@name"/>
<xsl:key name="define" match="rng:define" use="@name"/>
<xsl:key name="elemdef" match="rng:define" use="rng:element/@name"/>

<xsl:variable name="rngfile"
	      select="'/sourceforge/docbook/docbook/relaxng/docbook-rng.xml'"/>

<xsl:variable name="rng" select="document($rngfile,.)"/>

<xsl:variable name="seealsofile"
	      select="'../tools/lib/seealso.xml'"/>

<xsl:variable name="seealso" select="document($seealsofile)"/>

<xsl:variable name="element"
	      select="/db:refentry/db:refmeta/db:refmiscinfo[@role='element']"/>

<xsl:variable name="pattern"
	      select="/db:refentry/db:refmeta/db:refmiscinfo[@role='pattern']"/>

<xsl:template match="/">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="db:refentry">
  <xsl:element name="{name(.)}">
    <xsl:copy-of select="@*"/>
    <xsl:attribute name="xml:id" select="translate(concat('element.', $pattern),':','-')"/>
    <xsl:processing-instruction name="dbhtml">
      <xsl:text>filename="</xsl:text>
      <xsl:choose>
	<xsl:when test="starts-with($pattern, 'db.')">
	  <xsl:value-of select="substring-after($pattern, 'db.')"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="$pattern"/>
	</xsl:otherwise>
      </xsl:choose>
      <xsl:text>.html"</xsl:text>
    </xsl:processing-instruction>
    <xsl:apply-templates/>
  </xsl:element>
</xsl:template>

<xsl:template match="db:refmeta">
  <xsl:element name="{name(.)}">
    <xsl:copy-of select="@*"/>
    <indexterm>
      <primary>elements</primary>
      <secondary><xsl:value-of select="$element"/></secondary>
    </indexterm>
    <xsl:apply-templates/>
  </xsl:element>
</xsl:template>

<xsl:template match="processing-instruction('tdg-refentrytitle')">
  <xsl:value-of select="$element"/>
  <xsl:if test="count($rng/key('elemdef', $element)) &gt; 1">
    <xsl:text> (</xsl:text>
    <xsl:value-of select="$pattern"/>
    <xsl:text>)</xsl:text>
  </xsl:if>
</xsl:template>

<xsl:template match="processing-instruction('tdg-refname')">
  <xsl:value-of select="$element"/>
</xsl:template>

<xsl:template match="processing-instruction('tdg-refpurpose')">
  <xsl:variable name="def" select="$rng/key('define', $pattern)"/>
  <xsl:value-of select="$def/ancestor::rng:div[1]/db:refpurpose"/>
</xsl:template>

<xsl:template match="processing-instruction('tdg-refsynopsisdiv')">
  <xsl:apply-templates select="$rng" mode="synopsis"/>
</xsl:template>

<xsl:template match="processing-instruction('tdg-parents')">
  <xsl:variable name="parents"
	select="$rng//rng:element[doc:content-model//rng:ref[@name=$pattern]]"/>

  <xsl:if test="$parents">
    <refsection condition="ref.desc.parents">
      <title>Parents</title>
      <para>
	<xsl:text>These elements contain </xsl:text>
	<tag>
	  <xsl:value-of select="$element"/>
	</tag>

	<xsl:text>: </xsl:text>

	<simplelist type='inline'>
	  <xsl:variable name="names">
	    <xsl:for-each select="$parents">
	      <xsl:variable name="defs" select="key('elemdef', @name)"/>
	      <member>
		<xsl:choose>
		  <xsl:when test="count($defs) = 0">
		    <xsl:value-of select="@name"/>
		    <xsl:text> ???</xsl:text>
		  </xsl:when>
		  <xsl:when test="count($defs) = 1">
		    <xsl:value-of select="@name"/>
		  </xsl:when>
		  <xsl:otherwise>
		    <xsl:value-of select="@name"/>
		    <xsl:text> (</xsl:text>
		    <xsl:value-of select="parent::rng:define/@name"/>
		    <xsl:text>)</xsl:text>
		  </xsl:otherwise>
		</xsl:choose>
	      </member>
	    </xsl:for-each>
	  </xsl:variable>

	  <xsl:for-each-group select="$names" group-by="db:member">
	    <xsl:sort select="current-grouping-key()" data-type="text"/>
	    <member>
	      <xsl:choose>
		<xsl:when test="contains(current-grouping-key(),' ')">
		  <tag>
		    <xsl:value-of select="substring-before(current-grouping-key(),' ')"/>
		  </tag>
		  <xsl:text>&#160;</xsl:text>
		  <xsl:value-of select="substring-after(current-grouping-key(),' ')"/>
		</xsl:when>
		<xsl:otherwise>
		  <tag>
		    <xsl:value-of select="current-grouping-key()"/>
		  </tag>
		</xsl:otherwise>
	      </xsl:choose>
	    </member>
	  </xsl:for-each-group>
	</simplelist>
	<xsl:text>.</xsl:text>
      </para>
    </refsection>
  </xsl:if>
</xsl:template>

<xsl:template match="processing-instruction('tdg-children')">
  <xsl:variable name="elem" select="$rng/key('define', $pattern)/rng:element"/>
  <xsl:variable name="children"
		select="$elem/doc:content-model//rng:ref"/>

  <xsl:if test="$children">
    <refsection condition="ref.desc.children">
      <title>Children</title>
      <para>
	<xsl:text>The following elements occur in </xsl:text>
	<xsl:value-of select="$element"/>
	<xsl:text>: </xsl:text>
	<simplelist type='inline'>
	  <xsl:if test="$elem/doc:content-model//rng:text">
	    <member><emphasis>text</emphasis></member>
	  </xsl:if>

	  <xsl:variable name="names">
	    <xsl:for-each select="$children">
	      <xsl:variable name="def" select="key('define', @name)"/>
	      <xsl:variable name="elem" select="$def/rng:element/@name"/>
	      <xsl:variable name="defs" select="key('elemdef', $elem)"/>
	      <member>
		<xsl:choose>
		  <xsl:when test="count($defs) = 0">
		    <xsl:value-of select="$elem"/>
		    <xsl:text> ???</xsl:text>
		  </xsl:when>
		  <xsl:when test="count($defs) = 1">
		    <xsl:value-of select="$elem"/>
		  </xsl:when>
		  <xsl:otherwise>
		    <xsl:value-of select="$elem"/>
		    <xsl:text> (</xsl:text>
		    <xsl:value-of select="@name"/>
		    <xsl:text>)</xsl:text>
		  </xsl:otherwise>
		</xsl:choose>
	      </member>
	    </xsl:for-each>
	  </xsl:variable>

	  <xsl:for-each-group select="$names" group-by="db:member">
	    <xsl:sort select="current-grouping-key()" data-type="text"/>
	    <member>
	      <xsl:choose>
		<xsl:when test="contains(current-grouping-key(),' ')">
		  <tag>
		    <xsl:value-of select="substring-before(current-grouping-key(),' ')"/>
		  </tag>
		  <xsl:text>&#160;</xsl:text>
		  <xsl:value-of select="substring-after(current-grouping-key(),' ')"/>
		</xsl:when>
		<xsl:otherwise>
		  <tag>
		    <xsl:value-of select="current-grouping-key()"/>
		  </tag>
		</xsl:otherwise>
	      </xsl:choose>
	    </member>
	  </xsl:for-each-group>

	</simplelist>
	<xsl:text>.</xsl:text>
      </para>
    </refsection>
  </xsl:if>
</xsl:template>

<xsl:template match="processing-instruction('tdg-seealso')">
  <xsl:variable name="xdefs" select="$rng/key('elemdef', $element)"/>
  <xsl:variable name="seealsolist">
    <xsl:copy-of select="$seealso//group[elem[@name=$element]]
			 /*[@name != $element]"/>
    <xsl:if test="count($xdefs) &gt; 1">
      <xsl:for-each select="$xdefs">
	<xsl:if test="@name != $pattern">
	  <elem name="{$element}" pattern="{@name}" xmlns=""/>
	</xsl:if>
      </xsl:for-each>
    </xsl:if>
  </xsl:variable>

  <xsl:if test="$seealsolist/*">
    <refsection>
      <title>See Also</title>

      <simplelist type="inline">
	<!-- use f-e-g to remove duplicates -->
	<xsl:for-each-group select="$seealsolist/*" group-by="@name">
	  <xsl:sort select="current-grouping-key()" data-type="text"/>
	  <member>
	    <tag>
	      <xsl:value-of select="current-grouping-key()"/>
	    </tag>
	    <xsl:if test="@pattern">
	      <xsl:text>&#160;(</xsl:text>
	      <xsl:value-of select="@pattern"/>
	      <xsl:text>)</xsl:text>
	    </xsl:if>
	  </member>
	</xsl:for-each-group>
      </simplelist>
    </refsection>
  </xsl:if>
</xsl:template>

<xsl:template match="*">
  <xsl:element name="{name(.)}">
    <xsl:copy-of select="@*"/>
    <xsl:apply-templates/>
  </xsl:element>
</xsl:template>

<xsl:template match="processing-instruction('tdg')" priority="20">
  <xsl:choose>
    <xsl:when test="contains(., 'gentext=')">
      <xsl:choose>
	<xsl:when test="contains(., 'format.inline')">
	  <xsl:text>Formatted inline.</xsl:text>
	</xsl:when>
	<xsl:when test="contains(., 'format.block')">
	  <xsl:text>Formatted as a displayed block.</xsl:text>
	</xsl:when>
	<xsl:when test="contains(., 'format.heading')">
	  <xsl:text>Formatted as a heading.</xsl:text>
	</xsl:when>
	<xsl:when test="contains(., 'format.context')">
	  <xsl:text>May be formatted inline or as a displayed block, depending on context.</xsl:text>
	</xsl:when>
	<xsl:when test="contains(., 'format.csuppress')">
	  <xsl:text>Sometimes suppressed.</xsl:text>
	</xsl:when>
	<xsl:when test="contains(., 'format.suppress')">
	  <xsl:text>Suppressed.</xsl:text>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:message>
	    <xsl:text>Unrecognized tdg PI: </xsl:text>
	    <xsl:value-of select="."/>
	  </xsl:message>
	  <xsl:copy/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="comment()|processing-instruction()|text()">
  <xsl:copy/>
</xsl:template>

<!-- ============================================================ -->

<xsl:template match="/" mode="synopsis">
  <xsl:variable name="def" select="key('define', $pattern)"/>
  <xsl:apply-templates select="$def"/>
</xsl:template>

<xsl:template match="rng:define[rng:element]" priority="2">
  <refsynopsisdiv>
    <title>
      <xsl:text>Synopsis&#160;</xsl:text>
      <annotation>
	<para>
	  <xsl:value-of select="/db:refentry/db:info/db:releaseinfo"/>
	</para>
	<para>
	  <xsl:value-of select="/db:refentry/db:info/db:pubdate"/>
	</para>
      </annotation>
    </title>
    <xsl:apply-templates/>
  </refsynopsisdiv>
</xsl:template>

<xsl:template match="rng:text">
  <xsl:param name="li" select="1"/>

  <xsl:choose>
    <xsl:when test="$li = 1">
      <listitem>
	<para>
	  <emphasis>text</emphasis>
	</para>
      </listitem>
    </xsl:when>
    <xsl:otherwise>
      <emphasis>text</emphasis>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="rng:notAllowed">
  <!-- nop -->
</xsl:template>

<xsl:template match="rng:empty">
  <listitem>
    <para>
      <emphasis>empty</emphasis>
    </para>
  </listitem>
</xsl:template>

<xsl:template match="rng:element">
  <xsl:param name="elemNum" select="1"/>
  <xsl:variable name="xdefs" select="key('elemdef', @name)"/>

  <refsection>
    <title>Content Model</title>

    <para>
      <xsl:value-of select="@name"/>
      <xsl:if test="count($xdefs) &gt; 1">
	<xsl:text> (</xsl:text>
	<xsl:value-of select="../@name"/>
	<xsl:text>)</xsl:text>
      </xsl:if>
      <xsl:text> ::=</xsl:text>
    </para>

    <itemizedlist spacing='compact' role="element-synopsis">
      <xsl:choose>
	<xsl:when test="doc:content-model">
	  <xsl:apply-templates select="doc:content-model/*"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:apply-templates/>
	</xsl:otherwise>
      </xsl:choose>
    </itemizedlist>
  </refsection>

  <xsl:apply-templates select="doc:attributes"/>
  <xsl:apply-templates select="doc:rules"/>
</xsl:template>

<xsl:template match="doc:attributes">
  <xsl:variable name="attributes" select=".//rng:attribute"/>

  <xsl:variable name="cmnAttr"
		select="$attributes[@name='xml:id' and parent::rng:optional]
			|$attributes[@name='xml:lang']
			|$attributes[@name='xml:base']
			|$attributes[@name='remap']
			|$attributes[@name='xreflabel']
			|$attributes[@name='revisionflag']
			|$attributes[@name='arch']
			|$attributes[@name='condition']
			|$attributes[@name='conformance']
			|$attributes[@name='os']
			|$attributes[@name='revision']
			|$attributes[@name='security']
			|$attributes[@name='userlevel']
			|$attributes[@name='vendor']
			|$attributes[@name='wordsize']
			|$attributes[@name='role']
			|$attributes[@name='version']"/>

  <xsl:variable name="cmnAttrIdReq"
		select="$attributes[@name='xml:id' and not(parent::rng:optional)]
			|$attributes[@name='xml:lang']
			|$attributes[@name='xml:base']
			|$attributes[@name='remap']
			|$attributes[@name='xreflabel']
			|$attributes[@name='revisionflag']
			|$attributes[@name='arch']
			|$attributes[@name='condition']
			|$attributes[@name='conformance']
			|$attributes[@name='os']
			|$attributes[@name='revision']
			|$attributes[@name='security']
			|$attributes[@name='userlevel']
			|$attributes[@name='vendor']
			|$attributes[@name='wordsize']
			|$attributes[@name='role']
			|$attributes[@name='version']"/>

  <xsl:variable name="cmnAttrEither" select="$cmnAttr|$cmnAttrIdReq"/>

  <xsl:variable name="cmnLinkAttr"
		select="$attributes[@name='linkend']
                        |$attributes[@name='xlink:href']
                        |$attributes[@name='xlink:type']
                        |$attributes[@name='xlink:role']
                        |$attributes[@name='xlink:arcrole']
                        |$attributes[@name='xlink:title']
                        |$attributes[@name='xlink:show']
                        |$attributes[@name='xlink:actuate']"/>

  <xsl:variable name="otherAttr"
		select="set:difference($attributes,
			               $cmnAttr|$cmnAttrIdReq|$cmnLinkAttr)"/>

  <refsection>
    <title>Attributes</title>

    <xsl:choose>
      <xsl:when test="count($cmnAttr) = 17 and count($cmnLinkAttr) = 8">
	<para>Common attributes and common linking attributes.</para>
      </xsl:when>
      <xsl:when test="count($cmnAttrIdReq) = 17 and count($cmnLinkAttr) = 8">
	<para>Common attributes (ID required) and common linking atttributes.</para>
      </xsl:when>
      <xsl:when test="count($cmnAttr) = 17">
	<para>Common attributes.</para>
      </xsl:when>
      <xsl:when test="count($cmnAttrIdReq) = 17">
	<para>Common attributes (ID required).</para>
      </xsl:when>
      <xsl:when test="count($cmnLinkAttr) = 8">
	<para>Common linking attributes.</para>
      </xsl:when>
    </xsl:choose>

    <xsl:if test="count($cmnAttrEither) != 17 or count($otherAttr) &gt; 0">
      <para>
	<xsl:choose>
	  <xsl:when test="count($cmnAttr) = 17 
		          or count($cmnAttrIdReq) = 17">
	    <xsl:text>Additional attributes:</xsl:text>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:text>Attributes:</xsl:text>
	  </xsl:otherwise>
	</xsl:choose>
	<xsl:text> (Required attributes, if any, are </xsl:text>
	<emphasis role="bold">bold</emphasis>
	<xsl:text>)</xsl:text>
      </para>

      <itemizedlist spacing='compact' role="element-synopsis">
	<xsl:for-each select="rng:interleave/*|*[not(self::rng:interleave)]">
	  <xsl:sort select="descendant-or-self::rng:attribute[1]/@name"/>
	  <!-- don't bother with common attributes -->
	  <xsl:variable name="name" select="descendant-or-self::rng:attribute/@name"/>
	  <xsl:choose>
	    <xsl:when test="$cmnAttrEither[@name=$name]|$cmnLinkAttr[@name=$name]"/>
	    <xsl:otherwise>
	      <xsl:apply-templates select="." mode="attributes"/>
	    </xsl:otherwise>
	  </xsl:choose>
	</xsl:for-each>
      </itemizedlist>
    </xsl:if>
  </refsection>
</xsl:template>

<xsl:template match="db:*" mode="attributes"/>
<xsl:template match="dbx:*" mode="attributes"/>
  
<xsl:template match="rng:optional" mode="attributes">
  <xsl:apply-templates mode="attributes"/>
</xsl:template>

<xsl:template match="rng:choice" mode="attributes">
  <listitem>
    <para>
      <xsl:choose>
	<xsl:when test="ancestor::rng:optional">
	  <emphasis>At most one of:</emphasis>
	</xsl:when>
	<xsl:otherwise>
	  <emphasis>Exactly one of:</emphasis>
	</xsl:otherwise>
      </xsl:choose>
    </para>
    <itemizedlist spacing='compact' role="element-synopsis">
      <xsl:apply-templates mode="attributes"/>
    </itemizedlist>
  </listitem>
</xsl:template>

<xsl:template match="rng:interleave" mode="attributes">
  <listitem>
    <para>
      <xsl:choose>
	<xsl:when test="ancestor::rng:optional">
	  <emphasis>All or none of:</emphasis>
	</xsl:when>
	<xsl:otherwise>
	  <emphasis>All of:</emphasis>
	</xsl:otherwise>
      </xsl:choose>
    </para>
    <itemizedlist spacing='compact' role="element-synopsis">
      <xsl:apply-templates mode="attributes"/>
    </itemizedlist>
  </listitem>
</xsl:template>

<xsl:template match="rng:group" mode="attributes">
  <listitem>
    <para>
      <emphasis>Each of:</emphasis>
    </para>
    <itemizedlist spacing='compact' role="element-synopsis">
      <xsl:apply-templates mode="attributes"/>
    </itemizedlist>
  </listitem>
</xsl:template>

<xsl:template match="rng:ref" mode="attributes">
  <xsl:variable name="attrs" select="key('define', @name)/rng:attribute"/>

  <xsl:choose>
    <xsl:when test="count($attrs) &gt; 1">
      <listitem>
	<para>
	  <xsl:choose>
	    <xsl:when test="ancestor::rng:optional">
	      <emphasis>At most one of:</emphasis>
	    </xsl:when>
	    <xsl:otherwise>
	      <emphasis role="bold">Each of:</emphasis>
	    </xsl:otherwise>
	  </xsl:choose>
	</para>
	<itemizedlist spacing='compact' role="element-synopsis">
	  <xsl:apply-templates select="$attrs" mode="attributes">
	    <xsl:with-param name="optional" select="ancestor::rng:optional"/>
	    <xsl:with-param name="choice" select="ancestor::rng:choice"/>
	  </xsl:apply-templates>
	</itemizedlist>
      </listitem>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates select="$attrs" mode="attributes">
	<xsl:with-param name="optional" select="ancestor::rng:optional"/>
	<xsl:with-param name="choice" select="ancestor::rng:choice"/>
      </xsl:apply-templates>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="rng:attribute" mode="attributes">
  <xsl:param name="optional" select="parent::rng:optional"/>
  <xsl:param name="choice" select="ancestor::rng:choice"/>

  <listitem>
    <para>
      <xsl:choose>
	<xsl:when test="$optional">
	  <xsl:value-of select="@name"/>
	</xsl:when>
	<xsl:otherwise>
	  <emphasis role="bold">
	    <xsl:value-of select="@name"/>
	  </emphasis>
	</xsl:otherwise>
      </xsl:choose>

      <xsl:choose>
	<xsl:when test="rng:choice|rng:value">
	  <xsl:text> (enumeration)</xsl:text>
	</xsl:when>
	<xsl:when test="rng:data">
	  <xsl:text> (</xsl:text>
	  <xsl:value-of select="rng:data/@type"/>
	  <xsl:text>)</xsl:text>
	</xsl:when>
      </xsl:choose>
    </para>

    <xsl:if test="rng:choice|rng:value">
      <itemizedlist spacing='compact' role="element-synopsis">
	<xsl:for-each select="rng:choice/rng:value|rng:value">
	  <listitem>
	    <para>
	      <xsl:text>“</xsl:text>
	      <xsl:value-of select="."/>
	      <xsl:text>”</xsl:text>
	    </para>
	  </listitem>
	</xsl:for-each>
      </itemizedlist>
    </xsl:if>
  </listitem>
</xsl:template>

<xsl:template match="doc:rules">
  <refsection>
    <title>Additional Constraints</title>

    <itemizedlist spacing='compact' role="element-synopsis">
      <xsl:for-each select=".//s:assert">
	<listitem>
	  <para>
	    <xsl:value-of select="."/>
	  </para>
	</listitem>
      </xsl:for-each>
    </itemizedlist>
  </refsection>
</xsl:template>

<xsl:template match="rng:value">
  <xsl:if test="position() &gt; 1"> | </xsl:if>
  <phrase role="{local-name()}">
    <xsl:text>“</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>”</xsl:text>
  </phrase>
</xsl:template>

<xsl:template match="rng:ref">
  <xsl:param name="li" select="1"/>
  <xsl:variable name="elemName"
		select="(key('define', @name)/rng:element)[1]/@name"/>
  <xsl:variable name="xdefs" select="key('elemdef', $elemName)"/>
  <xsl:variable name="content">
    <xsl:choose>
      <xsl:when test="$elemName">
	<tag>
	  <xsl:value-of select="key('define', @name)/rng:element/@name"/>
	</tag>
	<xsl:if test="parent::rng:optional">?</xsl:if>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="@name"/>
	<xsl:if test="parent::rng:optional">?</xsl:if>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:if test="count($xdefs) &gt; 1">
      <xsl:text>&#160;(</xsl:text>
      <xsl:value-of select="@name"/>
      <xsl:text>)</xsl:text>
    </xsl:if>
  </xsl:variable>

  <xsl:choose>
    <xsl:when test="$li = 1">
      <listitem>
	<para>
	  <xsl:copy-of select="$content"/>
	</para>
      </listitem>
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy-of select="$content"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="rng:nsName">
  <listitem>
    <para>
      <xsl:text>Any element from the </xsl:text>
      <xsl:value-of select="@ns"/>
      <xsl:text> namespace.</xsl:text>
    </para>
  </listitem>
</xsl:template>

<xsl:template match="rng:data">
  <listitem>
    <para>
      <xsl:text>A </xsl:text>
      <xsl:value-of select="@type"/>
      <xsl:text> value.</xsl:text>
    </para>
  </listitem>
</xsl:template>

<xsl:template match="rng:anyName">
  <listitem>
    <para>
      <xsl:text>Any element from any namespace</xsl:text>
      <xsl:if test="rng:except">
	<xsl:text> (with exceptions!)</xsl:text>
      </xsl:if>
      <xsl:text>.</xsl:text>
    </para>
  </listitem>
</xsl:template>

<xsl:template match="rng:optional">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="rng:zeroOrMore">
  <listitem>
    <para>Zero or more of:</para>

    <itemizedlist spacing='compact' role="element-synopsis">
      <xsl:apply-templates>
	<xsl:sort select="key('define',@name)/rng:element/@name"/>
	<xsl:sort select="@name"/>
      </xsl:apply-templates>
    </itemizedlist>

<!--
    <itemizedlist spacing='compact' role="element-synopsis">
      <xsl:choose>
	<xsl:when test="*[not(self::rng:ref) and not(self::rng:text)]">
	  <xsl:apply-templates>
	    <xsl:sort select="key('define',@name)/rng:element/@name"/>
	    <xsl:sort select="@name"/>
	  </xsl:apply-templates>
	</xsl:when>
	<xsl:otherwise>
	  <listitem>
	    <simplelist type='inline'>
	      <xsl:for-each select="*">
		<xsl:sort select="key('define',@name)/rng:element/@name"/>
		<xsl:sort select="@name"/>
		<member>
		  <xsl:apply-templates select=".">
		    <xsl:with-param name="li" select="0"/>
		  </xsl:apply-templates>
		</member>
	      </xsl:for-each>
	    </simplelist>
	  </listitem>
	</xsl:otherwise>
      </xsl:choose>
    </itemizedlist>
-->
  </listitem>
</xsl:template>

<xsl:template match="rng:oneOrMore">
  <listitem>
    <para>
      <xsl:choose>
	<xsl:when test="parent::rng:optional">
	  <xsl:text>Optional one or more of:</xsl:text>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:text>One or more of:</xsl:text>
	</xsl:otherwise>
      </xsl:choose>
    </para>
    <itemizedlist spacing='compact' role="element-synopsis">
      <xsl:apply-templates>
	<xsl:sort select="key('define',@name)/rng:element/@name"/>
	<xsl:sort select="@name"/>
      </xsl:apply-templates>
    </itemizedlist>
  </listitem>
</xsl:template>

<xsl:template match="rng:group">
  <listitem>
    <para>
      <xsl:choose>
	<xsl:when test="parent::rng:optional">
	  <xsl:text>Optional sequence of:</xsl:text>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:text>Sequence of:</xsl:text>
	</xsl:otherwise>
      </xsl:choose>
    </para>
    <itemizedlist spacing='compact' role="element-synopsis">
      <xsl:apply-templates/>
    </itemizedlist>
  </listitem>
</xsl:template>

<xsl:template match="rng:interleave">
  <listitem>
    <para>
      <xsl:choose>
	<xsl:when test="parent::rng:optional">
	  <xsl:text>Optional interleave of:</xsl:text>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:text>Interleave of:</xsl:text>
	</xsl:otherwise>
      </xsl:choose>
    </para>
    <itemizedlist spacing='compact' role="element-synopsis">
      <xsl:apply-templates/>
    </itemizedlist>
  </listitem>
</xsl:template>

<xsl:template match="rng:choice">
  <listitem>
    <para>
      <xsl:choose>
	<xsl:when test="parent::rng:optional">
	  <xsl:text>Optionally one of: </xsl:text>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:text>One of: </xsl:text>
	</xsl:otherwise>
      </xsl:choose>
    </para>
    <itemizedlist spacing='compact' role="element-synopsis">
      <xsl:apply-templates>
	<xsl:sort select="key('define',@name)/rng:element/@name"/>
	<xsl:sort select="@name"/>
      </xsl:apply-templates>
    </itemizedlist>
  </listitem>
</xsl:template>

</xsl:stylesheet>
