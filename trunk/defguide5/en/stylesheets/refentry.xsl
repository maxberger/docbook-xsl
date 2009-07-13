<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns='http://docbook.org/ns/docbook'
		xmlns:s="http://www.ascc.net/xml/schematron"
		xmlns:set="http://exslt.org/sets"
		xmlns:exsl="http://exslt.org/common"
		xmlns:db='http://docbook.org/ns/docbook'
		xmlns:dbx="http://sourceforge.net/projects/docbook/defguide/schema/extra-markup"
		xmlns:rng='http://relaxng.org/ns/structure/1.0'
		xmlns:xlink="http://www.w3.org/1999/xlink"
		xmlns:doc='http://nwalsh.com/xmlns/schema-doc/'
		xmlns:html="http://www.w3.org/1999/xhtml"
		xmlns:a="http://relaxng.org/ns/compatibility/annotations/1.0"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:f="http://nwalsh.com/ns/xsl/functions"
		exclude-result-prefixes="db rng xlink f doc s set dbx exsl html a xs"
                version="2.0">

<xsl:include href="inline-synop.xsl"/>

<xsl:output method="xml" encoding="utf-8" indent="no"/>

<xsl:key name="div" match="rng:div" use="db:refname"/>
<xsl:key name="element" match="rng:element" use="@name"/>
<xsl:key name="define" match="rng:define" use="@name"/>
<xsl:key name="elemdef" match="rng:define" use="rng:element/@name"/>

<xsl:param name="compact-format" select="1"/>

<xsl:variable name="rngfile"
	      select="'../tools/lib/defguide.rnd'"/>

<xsl:variable name="rng" select="document($rngfile)"/>

<xsl:variable name="seealsofile"
	      select="'../tools/lib/seealso.xml'"/>

<xsl:variable name="seealso" select="document($seealsofile)"/>

<xsl:variable name="element"
	      select="/db:refentry/db:refmeta/db:refmiscinfo[@role='element']"/>

<xsl:variable name="pattern"
	      select="/db:refentry/db:refmeta/db:refmiscinfo[@role='pattern']"/>

  <!-- it's ok to mix inlines and blocks because no elements in DocBook
       contain a mixture of both -->
<xsl:variable name="test.patterns"
	      select="('db.bibliography.inlines',
		       'db.computeroutput.inlines',
		       'db.error.inlines',
		       'db.graphic.inlines',
		       'db.gui.inlines',
		       'db.htmlform.inlines',
		       'db.indexing.inlines',
		       'db.keyboard.inlines',
		       'db.link.inlines',
		       'db.markup.inlines',
		       'db.math.inlines',
		       'db.oo.inlines',
		       'db.os.inlines',
		       'db.product.inlines',
		       'db.programming.inlines',
		       'db.publishing.inlines',
		       'db.technical.inlines',
		       'db.ubiq.inlines',
		       'db.userinput.inlines',

                       'db.admonition.blocks',
		       'db.formal.blocks',
		       'db.graphic.blocks',
		       'db.htmlform.blocks',
		       'db.info.elements',
		       'db.informal.blocks',
		       'db.list.blocks',
		       'db.para.blocks',
		       'db.publishing.blocks',
		       'db.synopsis.blocks',
		       'db.technical.blocks',
		       'db.verbatim.blocks')"/>

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

    <xsl:if test="db:info/db:releaseinfo or db:info/db:pubdate">
      <refsection condition="ref.desc.changelog">
	<title>ChangeLog</title>
	<para>
	  <xsl:text>This </xsl:text>
	  <emphasis>alpha</emphasis>
	  <xsl:text> reference page is </xsl:text>
	  <xsl:value-of select="db:info/db:releaseinfo"/>
	  <xsl:text> published </xsl:text>
	  <xsl:value-of
	      select="substring-before(substring-after(db:info/db:pubdate,'('),')')"/>
	  <xsl:text>.</xsl:text>
	</para>
      </refsection>
    </xsl:if>
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
  <xsl:copy-of select="$def/ancestor::rng:div[1]/db:refpurpose/node()"/>
</xsl:template>

<xsl:template match="processing-instruction('tdg-refsynopsisdiv')">
  <xsl:apply-templates select="$rng" mode="synopsis">
    <xsl:with-param name="info" select="/db:refentry/db:info"/>
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="processing-instruction('tdg-parents')">
  <xsl:variable name="parents"
	select="$rng//rng:element[doc:content-model//rng:ref[@name=$pattern]]"/>

  <xsl:if test="$parents and $compact-format = 0">
    <refsection condition="ref.desc.parents">
      <title>Parents</title>
      <para>
	<xsl:text>These elements contain </xsl:text>

	<tag>
	  <xsl:choose>
	    <xsl:when test="$element = '_any.svg'">svg:*</xsl:when>
	    <xsl:when test="$element = '_any.mml'">mml:*</xsl:when>
	    <xsl:when test="$element = '_any'">*:*</xsl:when>
	    <xsl:otherwise>
	      <xsl:value-of select="$element"/>
	    </xsl:otherwise>
	  </xsl:choose>
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
		  <phrase role="pattern">
		    <xsl:value-of select="substring-after(current-grouping-key(),' ')"/>
		  </phrase>
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

  <xsl:if test="$children and $compact-format = 0">
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
		  <xsl:when test="@name = 'db._any.mml'">
		    <xsl:text>mml:*</xsl:text>
		  </xsl:when>
		  <xsl:when test="@name = 'db._any.svg'">
		    <xsl:text>svg:*</xsl:text>
		  </xsl:when>
		  <xsl:when test="@name = 'db._any'">
		    <xsl:text>*:*</xsl:text>
		  </xsl:when>
		  <xsl:when test="count($defs) = 0">
		    <xsl:value-of select="$elem"/>
		    <xsl:text> ??? (</xsl:text>
		    <xsl:value-of select="@name"/>
		    <xsl:text>)</xsl:text>
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
		  <phrase role="pattern">
		    <xsl:value-of select="substring-after(current-grouping-key(),' ')"/>
		  </phrase>
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

<xsl:template match="processing-instruction('tdg-attributes')">
  <xsl:variable name="elem" select="$rng/key('define', $pattern)/rng:element"/>
  <xsl:variable name="attributes"
		select="$elem/doc:attributes//rng:attribute"/>

  <xsl:variable name="cmnAttr"
		select="$attributes[@name='xml:id' and parent::rng:optional]
			|$attributes[@name='xml:lang']
			|$attributes[@name='xml:base']
			|$attributes[@name='remap']
			|$attributes[@name='xreflabel']
			|$attributes[@name='revisionflag']
			|$attributes[@name='arch']
			|$attributes[@name='audience']
			|$attributes[@name='condition']
			|$attributes[@name='conformance']
			|$attributes[@name='os']
			|$attributes[@name='revision']
			|$attributes[@name='security']
			|$attributes[@name='userlevel']
			|$attributes[@name='vendor']
			|$attributes[@name='wordsize']
			|$attributes[@name='role']
			|$attributes[@name='version']
			|$attributes[@name='dir']
			|$attributes[@name='annotations']"/>

  <xsl:variable name="cmnAttrIdReq"
		select="$attributes[@name='xml:id' and not(parent::rng:optional)]
			|$attributes[@name='xml:lang']
			|$attributes[@name='xml:base']
			|$attributes[@name='remap']
			|$attributes[@name='xreflabel']
			|$attributes[@name='revisionflag']
			|$attributes[@name='arch']
			|$attributes[@name='audience']
			|$attributes[@name='condition']
			|$attributes[@name='conformance']
			|$attributes[@name='os']
			|$attributes[@name='revision']
			|$attributes[@name='security']
			|$attributes[@name='userlevel']
			|$attributes[@name='vendor']
			|$attributes[@name='wordsize']
			|$attributes[@name='role']
			|$attributes[@name='version']
			|$attributes[@name='dir']
			|$attributes[@name='annotations']"/>

  <xsl:variable name="cmnAttrEither" select="$cmnAttr|$cmnAttrIdReq"/>

  <xsl:variable name="cmnLinkAttr"
		select="$attributes[@name='linkend']
			|$attributes[@name='linkends']
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

  <xsl:if test="(count($cmnAttrEither) != 20 and count($cmnAttrEither) != 0)
		or count($otherAttr) &gt; 0">
    <refsection condition="ref.desc.attribute-descriptions">
      <title>Attributes</title>
      <xsl:choose>
	<xsl:when test="count($cmnAttr) = 20 and count($cmnLinkAttr) = 8">
	  <para>
	    <link xlink:href="#common.attributes">Common attributes</link>
	    <xsl:text> and </xsl:text>
	    <link xlink:href="#common.linking.attributes">common linking attributes</link>
	    <xsl:text>.</xsl:text>
	  </para>
	</xsl:when>
	<xsl:when test="count($cmnAttrIdReq) = 20 and count($cmnLinkAttr) = 8">
	  <para>
	    <link xlink:href="#common.attributes">Common attributes</link>
	    <xsl:text> (ID required) and </xsl:text>
	    <link xlink:href="#common.linking.attributes">common linking attributes</link>
	    <xsl:text>.</xsl:text>
	  </para>
	</xsl:when>
	<xsl:when test="count($cmnAttr) = 20">
	  <para>
	    <link xlink:href="#common.attributes">Common attributes</link>
	    <xsl:text>.</xsl:text>
	  </para>
	</xsl:when>
	<xsl:when test="count($cmnAttrIdReq) = 20">
	  <para>
	    <link xlink:href="#common.attributes">Common attributes</link>
	    <xsl:text> (ID required).</xsl:text>
	  </para>
	</xsl:when>
	<xsl:when test="count($cmnLinkAttr) = 8">
	  <para>
	    <link xlink:href="#common.linking.attributes">Common linking attributes</link>
	    <xsl:text>.</xsl:text>
	  </para>
	</xsl:when>
      </xsl:choose>

      <xsl:variable name="allAttrNS">
	<xsl:for-each select="$elem/doc:attributes//rng:attribute">
	  <!-- In the case where there are two patterns for the same -->
	  <!-- attribute, this odd sort clause forces the one with the -->
	  <!-- dbx:description to be last -->
	  <xsl:sort select="concat(@name, '.', string(count(dbx:description)))"/>
	  <xsl:variable name="name" select="@name"/>
	  <xsl:choose>
	    <xsl:when test="$cmnAttrEither[@name=$name]
			    |$cmnLinkAttr[@name=$name]"/>
	    <xsl:otherwise>
	      <xsl:copy-of select="."/>
	    </xsl:otherwise>
	  </xsl:choose>
	</xsl:for-each>
      </xsl:variable>
	  
      <variablelist>
	<xsl:for-each select="exsl:node-set($allAttrNS)/rng:attribute">
	  <xsl:variable name="name">
	    <xsl:choose>
	      <xsl:when test="@name">
		<xsl:value-of select="@name"/>
	      </xsl:when>
	      <xsl:otherwise>*</xsl:otherwise>
	    </xsl:choose>
	  </xsl:variable>

	  <varlistentry>
	    <term role="attname">
	      <xsl:value-of select="$name"/>
	    </term>
	    <listitem>
	      <xsl:choose>
		<xsl:when test="db:refpurpose">
		  <para>
		    <xsl:copy-of select="db:refpurpose/node()"/>
		  </para>
		</xsl:when>
		<xsl:when test="dbx:description">
		  <xsl:copy-of select="dbx:description/*"/>
		</xsl:when>
		<xsl:otherwise>
		  <xsl:message>
		    <xsl:text>FIXME: </xsl:text>
		    <xsl:value-of select="$name"/>
		    <xsl:text> on </xsl:text>
		    <xsl:value-of select="$elem/@name"/>
		    <xsl:text> (no refpurpose?)</xsl:text>
		  </xsl:message>
		  <para>
		    <xsl:text>FIXME: No refpurpose?</xsl:text>
		  </para>
		</xsl:otherwise>
	      </xsl:choose>

	      <xsl:if test="rng:choice|rng:value">
		<informaltable frame="none">
		  <tgroup cols="2">
		    <colspec colname="c1" align="left" colwidth="1.25in"/>
		    <colspec colname="c2" align="left"/>
		    <thead>
		      <row>
			<entry namest="c1" nameend="c2">
			  <xsl:text>Enumerated values:</xsl:text>
			</entry>
		      </row>
		    </thead>
		    <tbody>
		      <xsl:for-each select=".//rng:value|.//rng:data">
			<xsl:variable name="doc"
				      select="following-sibling::*[1]"/>
			<row>
			  <entry>
			    <xsl:apply-templates select="." mode="value-enum"/>
			  </entry>
			  <entry>
			    <para>
			      <xsl:choose>
				<xsl:when test="$doc/self::a:documentation">
				  <xsl:value-of select="$doc"/>
				</xsl:when>
				<xsl:otherwise>
				  <xsl:message>
				    <xsl:text>FIXME: </xsl:text>
				    <xsl:value-of select="$name"/>
				    <xsl:text> on </xsl:text>
				    <xsl:value-of select="$elem/@name"/>
				    <xsl:text> (no documentation?)</xsl:text>
				  </xsl:message>
				  <xsl:text>FIXME: No documentation?</xsl:text>
				</xsl:otherwise>
			      </xsl:choose>
			    </para>
			  </entry>
			</row>
		      </xsl:for-each>
		    </tbody>
		  </tgroup>
		</informaltable>
	      </xsl:if>
	    </listitem>
	  </varlistentry>
	</xsl:for-each>
      </variablelist>
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
    <refsection condition="ref.desc.seealso">
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
	      <xsl:text>&#160;</xsl:text>
	      <phrase role="pattern">
		<xsl:text>(</xsl:text>
		<xsl:value-of select="@pattern"/>
		<xsl:text>)</xsl:text>
	      </phrase>
	    </xsl:if>
	  </member>
	</xsl:for-each-group>
      </simplelist>
    </refsection>
  </xsl:if>
</xsl:template>

<xsl:template match="*">
  <xsl:element name="{name(.)}" namespace="{namespace-uri(.)}">
    <xsl:copy-of select="@*"/>
    <xsl:apply-templates/>
  </xsl:element>
</xsl:template>

<xsl:template match="processing-instruction('tdg')" priority="20">
  <xsl:choose>
    <xsl:when test="contains(., 'gentext=')">
      <xsl:choose>
	<xsl:when test="contains(., 'pexp.linespecific')">
	  <xsl:text>This element is displayed “verbatim”; whitespace and linebreaks within this element are significant.</xsl:text>
	</xsl:when>
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
	<xsl:when test="contains(., 'calssemantics')">This element is
expected to obey the semantics of the
<link linkend='calsdtd'><citetitle>CALS Table Model
Document Type Definition</citetitle></link>, as specified by <citetitle>
<link xlink:href='http://www.oasis-open.org/html/a502.htm'>OASIS
Technical Memorandum TM 9502:1995</link></citetitle>.</xsl:when>
	<xsl:when test="contains(., 'htmltablesemantics')">This element is
expected to obey the semantics described in
<citetitle xlink:href="http://www.w3.org/TR/html401/struct/tables.html">Tables</citetitle>,
as specified in <citetitle linkend="xhtml"><trademark>XHTML</trademark> 1.0</citetitle>.
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
  <xsl:param name="info"/>
  <xsl:variable name="def" select="key('define', $pattern)"/>
  <xsl:apply-templates select="$def">
    <xsl:with-param name="info" select="$info"/>
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="rng:define[rng:element]" priority="2">
  <xsl:param name="info"/>

  <refsynopsisdiv>
    <title>
      <xsl:text>Synopsis</xsl:text>
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

<!--
  <refsection condition="ref.desc.content-model">
    <title>Content Model</title>
-->

    <para>
      <xsl:choose>
	<xsl:when test="@name">
	  <xsl:value-of select="@name"/>
	</xsl:when>
	<xsl:otherwise>
	  <emphasis>
	    <xsl:value-of select="ancestor::rng:div[1]/db:refname"/>
	  </emphasis>
	</xsl:otherwise>
      </xsl:choose>

      <xsl:if test="count($xdefs) &gt; 1">
	<xsl:text> (</xsl:text>
	<xsl:value-of select="../@name"/>
	<xsl:text>)</xsl:text>
      </xsl:if>
      <xsl:text>&#160;</xsl:text>
      <phrase role="cceq">::=</phrase>
    </para>

    <xsl:variable name="synop" as="element(db:itemizedlist)">
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
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="$compact-format = 0">
	<xsl:copy-of select="$synop"/>
      </xsl:when>
      <xsl:otherwise>
	<para>
	  <xsl:apply-templates select="$synop" mode="inlinesynop"/>
	</para>
      </xsl:otherwise>
    </xsl:choose>

<!--
  </refsection>
-->

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
			|$attributes[@name='audience']
			|$attributes[@name='condition']
			|$attributes[@name='conformance']
			|$attributes[@name='os']
			|$attributes[@name='revision']
			|$attributes[@name='security']
			|$attributes[@name='userlevel']
			|$attributes[@name='vendor']
			|$attributes[@name='wordsize']
			|$attributes[@name='role']
			|$attributes[@name='version']
			|$attributes[@name='dir']
			|$attributes[@name='annotations']"/>

  <xsl:variable name="cmnAttrIdReq"
		select="$attributes[@name='xml:id' and not(parent::rng:optional)]
			|$attributes[@name='xml:lang']
			|$attributes[@name='xml:base']
			|$attributes[@name='remap']
			|$attributes[@name='xreflabel']
			|$attributes[@name='revisionflag']
			|$attributes[@name='arch']
			|$attributes[@name='audience']
			|$attributes[@name='condition']
			|$attributes[@name='conformance']
			|$attributes[@name='os']
			|$attributes[@name='revision']
			|$attributes[@name='security']
			|$attributes[@name='userlevel']
			|$attributes[@name='vendor']
			|$attributes[@name='wordsize']
			|$attributes[@name='role']
			|$attributes[@name='version']
			|$attributes[@name='dir']
			|$attributes[@name='annotations']"/>

  <xsl:variable name="cmnAttrEither" select="$cmnAttr|$cmnAttrIdReq"/>

  <xsl:variable name="cmnLinkAttr"
		select="$attributes[@name='linkend']
			|$attributes[@name='linkends']
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

  <xsl:if test="count($cmnAttrEither) &gt; 0 or count($otherAttr) &gt; 0">
    <refsection condition="ref.desc.attributes">
      <title>Attributes</title>

      <xsl:choose>
	<xsl:when test="count($cmnAttr) = 20 and count($cmnLinkAttr) = 8">
	  <para>
	    <link xlink:href="#common.attributes">Common attributes</link>
	    <xsl:text> and </xsl:text>
	    <link xlink:href="#common.linking.attributes">common linking attributes</link>
	    <xsl:text>.</xsl:text>
	  </para>
	</xsl:when>
	<xsl:when test="count($cmnAttrIdReq) = 20 and count($cmnLinkAttr) = 8">
	  <para>
	    <link xlink:href="#common.attributes">Common attributes</link>
	    <xsl:text> (ID required) and </xsl:text>
	    <link xlink:href="#common.linking.attributes">common linking attributes</link>
	    <xsl:text>.</xsl:text>
	  </para>
	</xsl:when>
	<xsl:when test="count($cmnAttr) = 20">
	  <para>
	    <link xlink:href="#common.attributes">Common attributes</link>
	    <xsl:text>.</xsl:text>
	  </para>
	</xsl:when>
	<xsl:when test="count($cmnAttrIdReq) = 20">
	  <para>
	    <link xlink:href="#common.attributes">Common attributes</link>
	    <xsl:text> (ID required).</xsl:text>
	  </para>
	</xsl:when>
	<xsl:when test="count($cmnLinkAttr) = 8">
	  <para>
	    <link xlink:href="#common.linking.attributes">Common linking attributes</link>
	    <xsl:text>.</xsl:text>
	  </para>
	</xsl:when>
      </xsl:choose>

      <xsl:if test="count($cmnAttrEither) != 20 or count($otherAttr) &gt; 0">
	<para>
	  <xsl:choose>
	    <xsl:when test="count($cmnAttr) = 20 
			    or count($cmnAttrIdReq) = 20">
	      <xsl:text>Additional attributes:</xsl:text>
	    </xsl:when>
	    <xsl:otherwise>
	      <xsl:text>Attributes:</xsl:text>
	    </xsl:otherwise>
	  </xsl:choose>
	</para>

	<itemizedlist spacing='compact' role="element-synopsis">
	  <xsl:for-each select="rng:interleave/*|*[not(self::rng:interleave)]">
	    <xsl:sort select="descendant-or-self::rng:attribute[1]/@name"/>
	    <!-- don't bother with common attributes -->
	    <xsl:variable name="name"
			  select="descendant-or-self::rng:attribute/@name"/>
	    <xsl:choose>
	      <xsl:when test="$cmnAttrEither[@name=$name]|$cmnLinkAttr[@name=$name]"/>
	      <xsl:otherwise>
		<xsl:apply-templates select="." mode="attributes"/>
	      </xsl:otherwise>
	    </xsl:choose>
	  </xsl:for-each>
	</itemizedlist>

	<xsl:if test=".//rng:attribute[not(ancestor::rng:optional)
		                       and not(ancestor::rng:zeroOrMore)]">
	  <para>
	    <xsl:text>Required attributes are shown in </xsl:text>
	    <emphasis role="bold">bold</emphasis>
	    <xsl:text>.</xsl:text>
	  </para>
	</xsl:if>
      </xsl:if>
    </refsection>
  </xsl:if>
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
	<xsl:when test="ancestor::rng:zeroOrMore">
	  <emphasis>Zero or more:</emphasis>
	</xsl:when>
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
  <xsl:choose>
    <xsl:when test="count(rng:optional) = count(*)">
      <!-- interleave of optional attributes isn't important -->
      <xsl:apply-templates mode="attributes"/>
    </xsl:when>
    <xsl:otherwise>
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
    </xsl:otherwise>
  </xsl:choose>
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

<xsl:template match="rng:attribute" mode="attributes">
  <xsl:param name="optional"
	     select="parent::rng:optional
		     or parent::rng:choice/parent::rng:optional
		     or parent::rng:interleave/parent::rng:choice/parent::rng:optional
		     or parent::rng:zeroOrMore
		     or parent::rng:choice/parent::rng:zeroOrMore
		     or parent::rng:interleave/parent::rng:choice/parent::rng:zeroOrMore"/>

  <xsl:param name="choice" select="ancestor::rng:choice"/>

  <xsl:variable name="name">
    <xsl:choose>
      <xsl:when test="@name">
	<xsl:value-of select="@name"/>
      </xsl:when>
      <xsl:otherwise>
	<emphasis>Any attribute</emphasis>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <listitem>
    <para>
      <xsl:choose>
	<xsl:when test="$optional">
	  <xsl:copy-of select="$name"/>
	</xsl:when>
	<xsl:otherwise>
	  <emphasis role="bold">
	    <xsl:copy-of select="$name"/>
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

      <xsl:if test="@a:defaultValue">
	<xsl:text> [default=“</xsl:text>
	<xsl:value-of select="@a:defaultValue"/>
	<xsl:text>”]</xsl:text>
      </xsl:if>
    </para>

    <xsl:if test="rng:choice|rng:value">
      <itemizedlist spacing='compact' role="element-synopsis">
	<xsl:for-each
	    select="rng:choice/rng:value|rng:value|rng:choice/rng:data|rng:data">
	  <listitem>
	    <para>
	      <xsl:apply-templates select="." mode="value-enum"/>
	    </para>
	  </listitem>
	</xsl:for-each>
      </itemizedlist>
    </xsl:if>
  </listitem>
</xsl:template>

<xsl:template match="rng:value" mode="value-enum">
  <xsl:text>“</xsl:text>
  <xsl:value-of select="."/>
  <xsl:text>”</xsl:text>
</xsl:template>

<xsl:template match="rng:data" mode="value-enum">
  <literal>
    <xsl:text>xsd:</xsl:text>
    <xsl:value-of select="@type"/>
  </literal>
  <xsl:if test="rng:param">
    <xsl:text> (Pattern: “</xsl:text>
    <xsl:value-of select="rng:param" separator=", "/>
    <xsl:text>”)</xsl:text>
  </xsl:if>
</xsl:template>

<xsl:template match="doc:rules">
  <refsection condition="ref.desc.rules">
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

  <!--
  <xsl:message>name: "<xsl:value-of select="@name"/>"</xsl:message>
  -->

  <xsl:variable name="content">
    <xsl:choose>
      <xsl:when test="@name = 'db._any.mml'">
	<tag>mml:*</tag>
	<xsl:if test="parent::rng:optional">?</xsl:if>
      </xsl:when>
      <xsl:when test="@name = 'db._any.svg'">
	<tag>svg:*</tag>
	<xsl:if test="parent::rng:optional">?</xsl:if>
      </xsl:when>
      <xsl:when test="@name = 'db._any'">
	<tag>*:*</tag>
	<xsl:if test="parent::rng:optional">?</xsl:if>
      </xsl:when>
      <xsl:when test="$elemName">
	<tag>
	  <xsl:value-of select="key('define', @name)/rng:element/@name"/>
	</tag>
	<xsl:if test="parent::rng:optional">?</xsl:if>
      </xsl:when>
      <xsl:otherwise>
	<xsl:message>
	  <xsl:text>Failed to find </xsl:text>
	  <xsl:value-of select="$elemName"/>
	  <xsl:text> for "</xsl:text>
	  <xsl:value-of select="."/>
	  <xsl:value-of select="@name"/>
	  <xsl:text>"</xsl:text>
	</xsl:message>
	<xsl:value-of select="@name"/>
	<xsl:if test="parent::rng:optional">?</xsl:if>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:if test="count($xdefs) &gt; 1">
      <xsl:text>&#160;</xsl:text>
      <phrase role="pattern">
	<xsl:text>(</xsl:text>
	<xsl:value-of select="@name"/>
	<xsl:text>)</xsl:text>
      </phrase>
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
      <xsl:choose>
	<xsl:when test="rng:except">
	  <xsl:text> except:</xsl:text>
	</xsl:when>
	<xsl:otherwise>.</xsl:otherwise>
      </xsl:choose>
    </para>
    <xsl:if test="rng:except">
      <itemizedlist>
	<xsl:for-each select="rng:except/rng:nsName">
	  <listitem>
	    <para>
	      <xsl:choose>
		<xsl:when test="@ns">
		  <xsl:text>Elements from the </xsl:text>
		  <uri>
		    <xsl:value-of select="@ns"/>
		  </uri>
		  <xsl:text> namespace.</xsl:text>
		</xsl:when>
		<xsl:otherwise>
		  <xsl:text>Elements from the </xsl:text>
		  <uri>http://docbook.org/ns/docbook</uri>
		  <xsl:text> namespace.</xsl:text>
		</xsl:otherwise>
	      </xsl:choose>
	    </para>
	  </listitem>
	</xsl:for-each>
      </itemizedlist>
    </xsl:if>
  </listitem>
</xsl:template>

<xsl:template match="rng:optional">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="rng:zeroOrMore">
  <xsl:variable name="context" select="."/>

  <xsl:variable name="contains" as="xs:string*">
    <xsl:for-each select="$test.patterns">
      <xsl:if test="f:containsPattern($context, .)">
	<xsl:sequence select="."/>
      </xsl:if>
    </xsl:for-each>
  </xsl:variable>

  <xsl:variable name="trimmed" as="element()*">
    <xsl:for-each select="*">
      <xsl:choose>
	<xsl:when test="not(self::rng:ref)">
	  <xsl:sequence select="."/>
	</xsl:when>
	<xsl:when test="f:isContained($context,.,$contains)">
	  <!-- drop it -->
	</xsl:when>
	<xsl:otherwise>
	  <xsl:sequence select="."/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:variable>

  <listitem>
    <para>Zero or more of:</para>

    <itemizedlist spacing='compact' role="element-synopsis">
      <xsl:apply-templates select="$trimmed">
	<xsl:sort select="key('define',@name)/rng:element/@name"/>
	<xsl:sort select="@name"/>
      </xsl:apply-templates>

      <xsl:for-each select="$contains">
	<xsl:call-template name="format-pattern">
	  <xsl:with-param name="context" select="$context"/>
	  <xsl:with-param name="pattern" select="."/>
	</xsl:call-template>
      </xsl:for-each>

    </itemizedlist>
  </listitem>
</xsl:template>

<xsl:function name="f:containsPattern" as="xs:boolean">
  <xsl:param name="context"/>
  <xsl:param name="pattern"/>

  <xsl:if test="not($context/key('define',$pattern))">
    <xsl:message>No pattern: <xsl:value-of select="$pattern"/></xsl:message>
  </xsl:if>

  <xsl:variable name="p.refs" select="$context/key('define', $pattern)//rng:ref"/>
  <xsl:variable name="c.refs" select="$context/rng:ref"/>

  <xsl:variable name="patn" as="xs:integer*">
    <xsl:for-each select="$p.refs">
      <xsl:variable name="n" select="@name"/>
      <xsl:if test="not($c.refs[@name = $n])">0</xsl:if>
    </xsl:for-each>
  </xsl:variable>

  <xsl:value-of select="count($patn) = 0"/>
</xsl:function>

<xsl:function name="f:isContained" as="xs:boolean">
  <xsl:param name="context"/>
  <xsl:param name="ref"/>
  <xsl:param name="patterns"/>

  <xsl:variable name="contains" as="xs:integer*">
    <xsl:for-each select="$patterns">
      <xsl:variable name="patname" select="."/>
      <!-- work around apparent bug in Saxon -->
      <xsl:variable name="def"
		    select="root($context)//rng:define[@name = $patname]"/>
      <xsl:for-each select="$def//rng:ref">
	<xsl:if test="@name = $ref/@name">
	  <xsl:sequence select="1"/>
	</xsl:if>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:variable>

  <xsl:value-of select="count($contains) &gt; 0"/>
</xsl:function>

<xsl:template name="format-pattern">
  <xsl:param name="context"/>
  <xsl:param name="pattern"/>

  <listitem xml:id="{generate-id($context)}-{$pattern}">
    <para>
      <emphasis role="patnlink">
	<xsl:choose>
	  <xsl:when test="$pattern = 'db.bibliography.inlines'">
	    <xsl:text>Bibliography inlines</xsl:text>
	  </xsl:when>
          <xsl:when test="$pattern = 'db.computeroutput.inlines'">
            <xsl:text>Computer-output inlines</xsl:text>
          </xsl:when>
          <xsl:when test="$pattern = 'db.error.inlines'">
            <xsl:text>Error inlines</xsl:text>
          </xsl:when>
          <xsl:when test="$pattern = 'db.graphic.inlines'">
            <xsl:text>Graphic inlines</xsl:text>
          </xsl:when>
          <xsl:when test="$pattern = 'db.gui.inlines'">
            <xsl:text>GUI inlines</xsl:text>
          </xsl:when>
          <xsl:when test="$pattern = 'db.htmlform.inlines'">
            <xsl:text>HTML Form inlines</xsl:text>
          </xsl:when>
          <xsl:when test="$pattern = 'db.indexing.inlines'">
            <xsl:text>Indexing inlines</xsl:text>
          </xsl:when>
          <xsl:when test="$pattern = 'db.keyboard.inlines'">
            <xsl:text>Keyboard inlines</xsl:text>
          </xsl:when>
          <xsl:when test="$pattern = 'db.link.inlines'">
            <xsl:text>Linking inlines</xsl:text>
          </xsl:when>
          <xsl:when test="$pattern = 'db.markup.inlines'">
            <xsl:text>Markup inlines</xsl:text>
          </xsl:when>
          <xsl:when test="$pattern = 'db.math.inlines'">
            <xsl:text>Math inlines</xsl:text>
          </xsl:when>
          <xsl:when test="$pattern = 'db.oo.inlines'">
            <xsl:text>Object-oriented programming inlines</xsl:text>
          </xsl:when>
          <xsl:when test="$pattern = 'db.os.inlines'">
            <xsl:text>Operating system inlines</xsl:text>
          </xsl:when>
          <xsl:when test="$pattern = 'db.product.inlines'">
            <xsl:text>Product inlines</xsl:text>
          </xsl:when>
          <xsl:when test="$pattern = 'db.programming.inlines'">
            <xsl:text>Programming inlines</xsl:text>
          </xsl:when>
          <xsl:when test="$pattern = 'db.publishing.inlines'">
            <xsl:text>Publishing inlines</xsl:text>
          </xsl:when>
          <xsl:when test="$pattern = 'db.technical.inlines'">
            <xsl:text>Technical inlines</xsl:text>
          </xsl:when>
          <xsl:when test="$pattern = 'db.ubiq.inlines'">
            <xsl:text>Ubiquitous inlines</xsl:text>
          </xsl:when>
          <xsl:when test="$pattern = 'db.userinput.inlines'">
            <xsl:text>User-input inlines</xsl:text>
          </xsl:when>
          <xsl:when test="$pattern = 'db.admonition.blocks'">
            <xsl:text>Admonition elements</xsl:text>
          </xsl:when>
          <xsl:when test="$pattern = 'db.formal.blocks'">
            <xsl:text>Formal elements</xsl:text>
          </xsl:when>
          <xsl:when test="$pattern = 'db.graphic.blocks'">
            <xsl:text>Graphic elements</xsl:text>
          </xsl:when>
          <xsl:when test="$pattern = 'db.htmlform.blocks'">
            <xsl:text>HTML Form elements</xsl:text>
          </xsl:when>
          <xsl:when test="$pattern = 'db.info.elements'">
            <xsl:text>“Info” elements</xsl:text>
          </xsl:when>
          <xsl:when test="$pattern = 'db.informal.blocks'">
            <xsl:text>Informal elements</xsl:text>
          </xsl:when>
          <xsl:when test="$pattern = 'db.list.blocks'">
            <xsl:text>List elements</xsl:text>
          </xsl:when>
          <xsl:when test="$pattern = 'db.para.blocks'">
            <xsl:text>Paragraph elements</xsl:text>
          </xsl:when>
          <xsl:when test="$pattern = 'db.publishing.blocks'">
            <xsl:text>Publishing elements</xsl:text>
          </xsl:when>
          <xsl:when test="$pattern = 'db.synopsis.blocks'">
            <xsl:text>Synopsis elements</xsl:text>
          </xsl:when>
          <xsl:when test="$pattern = 'db.technical.blocks'">
            <xsl:text>Technical elements</xsl:text>
          </xsl:when>
          <xsl:when test="$pattern = 'db.verbatim.blocks'">
            <xsl:text>Verbatim elements</xsl:text>
          </xsl:when>
	  <xsl:otherwise>
	    <xsl:message>
	      <xsl:text>Warning: no prose for </xsl:text>
	      <xsl:value-of select="$pattern"/>
	    </xsl:message>
	    <xsl:value-of select="$pattern"/>
	  </xsl:otherwise>
	</xsl:choose>
      </emphasis>
    </para>

    <xsl:variable name="def"
		  select="root($context)//rng:define[@name = $pattern]"/>

    <itemizedlist role="patnlist {$pattern}"
		  xml:id="l.{generate-id($context)}-{$pattern}">
      <xsl:for-each select="$def//rng:ref">
	<xsl:sort select="key('define',@name)/rng:element/@name"/>
	<xsl:sort select="@name"/>
	<xsl:apply-templates select="."/>
      </xsl:for-each>
    </itemizedlist>
  </listitem>
</xsl:template>

<xsl:template match="rng:oneOrMore">
  <xsl:variable name="context" select="."/>

  <xsl:variable name="contains" as="xs:string*">
    <xsl:for-each select="$test.patterns">
      <xsl:if test="f:containsPattern($context, .)">
	<xsl:sequence select="."/>
      </xsl:if>
    </xsl:for-each>
  </xsl:variable>

  <xsl:variable name="trimmed" as="element()*">
    <xsl:for-each select="*">
      <xsl:choose>
	<xsl:when test="not(self::rng:ref)">
	  <xsl:sequence select="."/>
	</xsl:when>
	<xsl:when test="f:isContained($context,.,$contains)">
	  <!-- drop it -->
	</xsl:when>
	<xsl:otherwise>
	  <xsl:sequence select="."/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:variable>

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
      <xsl:apply-templates select="$trimmed">
	<xsl:sort select="key('define',@name)/rng:element/@name"/>
	<xsl:sort select="@name"/>
      </xsl:apply-templates>

      <xsl:for-each select="$contains">
	<xsl:call-template name="format-pattern">
	  <xsl:with-param name="context" select="$context"/>
	  <xsl:with-param name="pattern" select="."/>
	</xsl:call-template>
      </xsl:for-each>
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
