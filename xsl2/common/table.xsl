<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns="http://www.w3.org/1999/xhtml"
		xmlns:db="http://docbook.org/docbook-ng"
                xmlns:doc="http://nwalsh.com/xsl/documentation/1.0"
		xmlns:f="http://docbook.org/xslt/ns/extension"
		xmlns:fp="http://docbook.org/xslt/ns/extension/private"
		xmlns:ghost="http://docbook.org/docbook-ng/ephemeral"
		xmlns:h="http://www.w3.org/1999/xhtml"
		xmlns:m="http://docbook.org/xslt/ns/mode"
                xmlns:u="http://nwalsh.com/xsl/unittests#"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		exclude-result-prefixes="doc f fp ghost h m u xs"
                version="2.0">

<doc:mode name="m:cals-phase-1" xmlns="http://docbook.org/docbook-ng">
<refpurpose>Mode for normalizing CALS tables</refpurpose>

<refdescription>
<para>This mode is used to normalize CALS tables. A table has a rectangular
structure with a certain number of rows and columns. In the simplest case,
each row has the same number of entries (equal to the number of columns
in the table). Two complications arise: first, cells can span columns or
rows, second, a cell can identify the column in which it appears, potentially
“skipping” earlier columns (cells cannot appear out of order, so there's
no possibility of that column being “back filled” by a later cell that
explicitly identifies the skipped column).</para>

<para>Another complication arises in the way default values for cell
properties like alignment and row or column separators are calculated.
See <function role="named-template">inherit-table-attributes</function>.
</para>

<para>These complications make processing tables quite complicated. The
result of processing a table in the <literal>m:cals-phase-1</literal> mode
is a normalized table. In the normalized table, all of rows have one
child element for each column and all of the attributes associated with
an entry appear literally on the entry.</para>

<para>In the case where a cell spans across columns or rows, the normalized
table will have a <tag>ghost:overlapped</tag> element in the phantom cells.
In the case where a cell has skipped some columns, those columns will have
a <tag>ghost:empty</tag> element.</para>

<para>Processing a normalized table is a simple matter of processing
each row and cell.</para>
</refdescription>
</doc:mode>

<xsl:template match="db:tgroup" mode="m:cals-phase-1">
  <xsl:copy>
    <xsl:copy-of select="@*"/>
    <xsl:attribute name="ghost:phase" select="1"/>
    <xsl:apply-templates mode="m:cals-phase-1"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="db:thead|db:tbody|db:tfoot"
	      mode="m:cals-phase-1">
  <xsl:variable name="overhang"
		select="for $col in (1 to xs:integer(../@cols))
			return 0"/>
  <xsl:copy>
    <xsl:copy-of select="@*"/>
    <xsl:apply-templates select="db:row[1]" mode="m:cals-phase-1">
      <xsl:with-param name="overhang" select="$overhang"/>
    </xsl:apply-templates>
  </xsl:copy>
</xsl:template>

<xsl:template match="db:row" mode="m:cals-phase-1">
  <xsl:param name="overhang" as="xs:integer+"/>

  <xsl:variable name="row">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates select="(db:entry|db:entrytbl)[1]"
			   mode="m:cals-phase-1">
	<xsl:with-param name="overhang" select="$overhang"/>
	<xsl:with-param name="prevpos" select="0"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:variable>

  <xsl:copy-of select="$row/db:row"/>

  <xsl:variable name="decremented-overhang"
		select="for $col in (1 to count($overhang))
			return xs:integer(max(($overhang[$col] - 1, 0)))"/>

  <xsl:variable name="next-overhang"
		select="for $col in (1 to count($overhang))
			return
			  xs:integer($decremented-overhang[$col]
			              + $row/db:row/*[$col]/@ghost:morerows)"/>

  <xsl:apply-templates select="following-sibling::db:row[1]"
		       mode="m:cals-phase-1">
    <xsl:with-param name="overhang" select="$next-overhang"/>
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="db:entry|db:entrytbl" mode="m:cals-phase-1">
  <xsl:param name="overhang" as="xs:integer+"/>
  <xsl:param name="prevpos" as="xs:integer"/>

  <xsl:variable name="entry" select="."/>

  <xsl:variable name="nextpos" select="f:skip-overhang($overhang, $prevpos+1)"
		as="xs:integer"/>

  <xsl:variable name="pos" as="xs:integer">
    <xsl:choose>
      <xsl:when test="@namest">
	<xsl:variable name="name" select="@namest"/>
	<xsl:variable name="colspec"
		      select="ancestor::db:tgroup[1]
			      /db:colspec[@colname=$name]"/>
	<xsl:value-of select="f:colspec-colnum($colspec)"/>
      </xsl:when>
      <xsl:when test="@colname">
	<xsl:variable name="name" select="@colname"/>
	<xsl:variable name="colspec"
		      select="ancestor::db:tgroup[1]
			      /db:colspec[@colname=$name]"/>
	<xsl:value-of select="f:colspec-colnum($colspec)"/>
      </xsl:when>
      <xsl:when test="@spanname">
	<xsl:variable name="name" select="@spanname"/>
	<xsl:variable name="spanspec"
		      select="ancestor::db:tgroup[1]
			      /db:spanspec[@spanname=$name]"/>

	<xsl:value-of select="f:spanspec-colnum-start($spanspec)"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="$nextpos"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="width" as="xs:integer">
    <xsl:choose>
      <xsl:when test="@nameend">
	<xsl:variable name="name" select="@nameend"/>
	<xsl:variable name="colspec"
		      select="ancestor::db:tgroup[1]
			      /db:colspec[@colname=$name]"/>

	<xsl:value-of select="f:colspec-colnum($colspec) - $pos + 1"/>
      </xsl:when>
      <xsl:when test="@spanname">
	<xsl:variable name="name" select="@spanname"/>
	<xsl:variable name="spanspec"
		      select="ancestor::db:tgroup[1]
			      /db:spanspec[@spanname=$name]"/>

	<xsl:value-of select="f:spanspec-colnum-end($spanspec) - $pos + 1"/>
      </xsl:when>
      <xsl:otherwise>1</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:for-each select="for $col in ($prevpos+1 to $pos - 1) return $col">
    <xsl:variable name="col" select="."/>
    <xsl:choose>
      <xsl:when test="$overhang[$col] &gt; 0">
	<ghost:overlapped ghost:colnum="{$col}" ghost:morerows="0"/>
      </xsl:when>
      <xsl:otherwise>
	<ghost:empty ghost:colnum="{$col}" ghost:morerows="0"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:for-each>

  <xsl:copy>
    <xsl:copy-of select="@*"/>
    <xsl:attribute name="ghost:colnum" select="$pos"/>
    <xsl:attribute name="ghost:width" select="$width"/>
    <xsl:attribute name="ghost:morerows"
		   select="if (@morerows)
			   then xs:integer(@morerows)
			   else 0"/>

    <xsl:call-template name="inherit-table-attributes">
      <xsl:with-param name="colnum" select="$pos"/>
    </xsl:call-template>

    <xsl:apply-templates mode="m:cals-phase-1"/>
  </xsl:copy>

  <xsl:for-each select="for $col in ($pos + 1 to $pos + $width - 1) return $col">
    <ghost:overlapped ghost:colnum="{.}">
      <xsl:attribute name="ghost:morerows"
		     select="if ($entry/@morerows)
			     then xs:integer($entry/@morerows)
			     else 0"/>
    </ghost:overlapped>
  </xsl:for-each>

  <xsl:apply-templates select="(following-sibling::db:entry
			        |following-sibling::db:entrytbl)[1]"
		       mode="m:cals-phase-1">
    <xsl:with-param name="overhang" select="$overhang"/>
    <xsl:with-param name="prevpos" select="$pos + $width - 1"/>
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="db:colspec" mode="m:cals-phase-1">
  <xsl:copy>
    <xsl:attribute name="ghost:colnum" select="f:colspec-colnum(.)"/>
    <xsl:copy-of select="@*"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="*" mode="m:cals-phase-1">
  <xsl:copy>
    <xsl:copy-of select="@*"/>
    <xsl:apply-templates mode="m:cals-phase-1"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="comment()|processing-instruction()|text()"
	      mode="m:cals-phase-1">
  <xsl:copy/>
</xsl:template>

<!-- ============================================================ -->

<doc:template name="inherit-table-attributes"
	      xmlns="http://docbook.org/docbook-ng">
<refpurpose>Calculates attribute values for table cells</refpurpose>

<refdescription>
<para>In a CALS table, each entry can have a number of properties
(alignment, row and column separators, etc.). If these properties aren't
specified directly on the entry, then their default values are calculated
by a complex series of defaults.
</para>

<para>A property can be specified in any of nine locations:</para>

<orderedlist>
<listitem>
<para>The <tag>entry</tag>.
</para>
</listitem>
<listitem>
<para>The <tag>row</tag>.
</para>
</listitem>
<listitem>
<para>The <tag>tgroup</tag>.
</para>
</listitem>
<listitem>
<para>The <tag>table</tag> or <tag>informaltable</tag>.
</para>
</listitem>
<listitem>
<para>The <tag>spanspec</tag> if this entry has
a <tag class="attribute">spanname</tag> attribute.</para>
</listitem>
<listitem>
<para>The starting column of the span as identified by the
<tag class="attribute">namest</tag> attribute on the <tag>spanspec</tag>
(if there is one, see previous.)
</para>
</listitem>
<listitem>
<para>The starting column of the span identified directly by a
<tag class="attribute">namest</tag> attribute on the <tag>entry</tag>.
</para>
</listitem>
<listitem>
<para>The <tag>colspec</tag> for the column in which it occurs (either
naturally or as a result of a <tag class="attribute">colname</tag> attribute).
</para>
</listitem>
<listitem>
<para>Some application default.
</para>
</listitem>
</orderedlist>

<para>This template performs those lookup operations and generates an
explicit attribute node for each inheritable property. In this way,
a normalized cell has all of the proper values specified directly.</para>
</refdescription>

<refparameter>
<variablelist>
<varlistentry><term>entry</term>
<listitem>
<para>The table cell element, defaults to the current context node.</para>
</listitem>
</varlistentry>
<varlistentry role="required"><term>colnum</term>
<listitem>
<para>The column number in which this entry appears.</para>
</listitem>
</varlistentry>
</variablelist>
</refparameter>

<refreturn>
<para>A sequence of attribute nodes, one for each property.</para>
</refreturn>
</doc:template>

<xsl:template name="inherit-table-attributes">
  <xsl:param name="entry" select="."/>
  <xsl:param name="colnum" required="yes"/>

  <!-- the table attributes come from:
       1. the entry
       2. the row
       3. the tgroup
       4. the table or informaltable
       5. the spanspec (@spanname)
       6. the starting column of the spanspec (spanspec/@namest)
       7. the starting column (@namest)
       8. the colspec for the $colnum
       9. application default
       in that order -->

  <xsl:variable name="tgroup" select="$entry/ancestor::db:tgroup[1]"/>
  <xsl:variable name="table" select="$tgroup/parent::*"/>
  <xsl:variable name="spanspec"
		select="$tgroup/db:spanspec[@spanname=$entry/@spanname]"/>

  <xsl:variable name="elements" as="element()*">
    <xsl:sequence select="($entry,
                           $entry/parent::db:row,
			   $tgroup,
			   $tgroup/parent::*,
			   $spanspec,
			   $tgroup/db:colspec[@colname=$spanspec/@namest],
			   $tgroup/db:colspec[@colname=$entry/@namest],
			   f:find-colspec-by-colnum($tgroup, $colnum))"/>
  </xsl:variable>

  <xsl:for-each select="('rowsep', 'colsep',
                         'align', 'valign',
			 'char', 'charoff')">
    <xsl:variable name="attr" select="QName('', .)"/>

    <xsl:choose>
      <xsl:when test="f:find-element-by-attribute($elements, $attr)">
	<xsl:attribute name="{$attr}"
		       select="f:find-element-by-attribute($elements, $attr)
			       /@*[node-name() = $attr]"/>
      </xsl:when>
      <xsl:otherwise>
	<!-- According to CALS, the default for each attribute is the
	     tgroup value, which we've already found above, if it exists,
	     except for colsep and rowsep which default to "1" -->
	<xsl:if test="$attr=QName('','rowsep') or $attr=QName('','colsep')">
	  <xsl:attribute name="{$attr}" select="1"/>
	</xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:for-each>
</xsl:template>

<!-- ============================================================ -->

<doc:template name="adjust-column-widths" xmlns="http://docbook.org/docbook-ng">
<refpurpose>Adjust column width values for HTML or XSL-FO</refpurpose>

<refdescription>
<para>CALS tables support column widths expressed in absolute (2.5in),
relative (2*), and mixed terms (1.5*+0.5in). HTML and XSL-FO support
column widths
expressed in either absolute units (only pixels in the HTML case)
or as a percentage of the total table width. This template takes an
HTML <tag>colgroup</tag> containing columns with widths expressed in CALS
terms and returns the equivalent group with columns expressed in terms
acceptable to HTML or XSL-FO.</para>

<itemizedlist>
<listitem>
<para>If there are no relative widths, the absolute widths are returned.</para>
</listitem>
<listitem>
<para>If there are no absolute widths, the relative widths are returned.</para>
</listitem>
<listitem>
<para>If there are a mixture of relative and absolute widths,</para>
  <itemizedlist>
  <listitem>
  <para>If the table width is absolute, all the column widths are converted
        to absolute widths and those are returned.</para>
  </listitem>
  <listitem>
  <para>If the table width is relative, all the column widths are converted
        to absolute widths based on a
	<parameter>nominal-table-width</parameter>. Then each width is
	converted back to a percentage and those are returned.</para>
  </listitem>
  </itemizedlist>
</listitem>
</itemizedlist>
</refdescription>

<refparameter>
<variablelist>
<varlistentry role="required"><term>table-width</term>
<listitem>
<para>The width of the table.</para>
</listitem>
</varlistentry>
<varlistentry role="required"><term>colgroup</term>
<listitem>
<para>The column group to adjust.</para>
</listitem>
</varlistentry>
<varlistentry><term>abspixels</term>
<listitem>
<para>Specifies if absolute widths should be expressed in pixels: 0 for
false, any other value for true. Converting lengths to pixels is dependent
on the <parameter>pixels.per.inch</parameter> parameter.</para>
</listitem>
</varlistentry>
</variablelist>
</refparameter>

<refreturn>
<para>The adjusted column group.</para>
</refreturn>

<u:unittests template="adjust-column-widths">
  <u:param name="pixels.per.inch" select="96"/>
  <u:param name="nominal-table-width" select="6 * $pixels.per.inch"/>
  <u:test>
    <u:param name="table-width" select="'6in'"/>
    <u:param name="colgroup" as="element()">
      <colgroup xmlns="http://www.w3.org/1999/xhtml">
	<col colwidth="3.5*"/>
	<col colwidth="2*"/>
	<col/>
	<col colwidth="1*"/>
      </colgroup>
    </u:param>
    <u:param name="abspixels">1</u:param>
    <u:result>
      <colgroup xmlns="http://www.w3.org/1999/xhtml"> 
	<col colwidth="47%"/>
	<col colwidth="27%"/>
	<col colwidth="13%"/>
	<col colwidth="13%"/>
      </colgroup>
    </u:result>
  </u:test>
  <u:test>
    <u:param name="table-width">6in</u:param>
    <u:param name="colgroup" as="element()">
      <colgroup xmlns="http://www.w3.org/1999/xhtml">
	<col colwidth="2in"/>
	<col colwidth="3in"/>
	<col colwidth="8pt"/>
	<col colwidth="1in"/>
      </colgroup>
    </u:param>
    <u:param name="abspixels">1</u:param>
    <u:result>
      <colgroup xmlns="http://www.w3.org/1999/xhtml"> 
	<col colwidth="192"/>
	<col colwidth="288"/>
	<col colwidth="10"/>
	<col colwidth="96"/>
      </colgroup>
    </u:result>
  </u:test>
  <u:test>
    <u:param name="table-width">6in</u:param>
    <u:param name="colgroup" as="element()">
      <colgroup xmlns="http://www.w3.org/1999/xhtml"> 
	<col colwidth="3.5*+2in" colname="foo"/>
	<col colwidth="2*"/>
	<col/>
	<col colwidth="1in" align="right"/>
      </colgroup>
    </u:param>
    <u:param name="abspixels">1</u:param>
    <u:result>
      <colgroup xmlns="http://www.w3.org/1999/xhtml"> 
	<col colwidth="502" colname="foo"/>
	<col colwidth="177"/>
	<col colwidth="89"/>
	<col colwidth="96" align="right"/>
      </colgroup>
    </u:result>
  </u:test>
  <u:test>
    <u:param name="table-width">'100%'</u:param>
    <u:param name="colgroup" as="element()">
      <colgroup xmlns="http://www.w3.org/1999/xhtml"> 
	<col colwidth="3.5*+2in" colname="foo"/>
	<col colwidth="2*"/>
	<col/>
	<col colwidth="1in" align="right"/>
      </colgroup>
    </u:param>
    <u:param name="abspixels">1</u:param>
    <u:result>
      <colgroup xmlns="http://www.w3.org/1999/xhtml"> 
	<col colwidth="58.12%" colname="foo"/>
	<col colwidth="20.51%"/>
	<col colwidth="10.26%"/>
	<col colwidth="11.11%" align="right"/>
      </colgroup>
    </u:result>
  </u:test>
  <u:test>
    <u:param name="table-width">6in</u:param>
    <u:param name="colgroup" as="element()">
      <colgroup xmlns="http://www.w3.org/1999/xhtml"> 
	<col colwidth="3.5*+2in" colname="foo"/>
	<col colwidth="2*"/>
	<col/>
	<col colwidth="1in" align="right"/>
      </colgroup>
    </u:param>
    <u:result>
      <colgroup xmlns="http://www.w3.org/1999/xhtml"> 
	<col colwidth="5.23in" colname="foo"/>
	<col colwidth="1.85in"/>
	<col colwidth="0.92in"/>
	<col colwidth="1.00in" align="right"/>
      </colgroup>
    </u:result>
  </u:test>
</u:unittests>
</doc:template>

<xsl:template name="adjust-column-widths" as="element()">
  <xsl:param name="table-width" as="xs:string"/>
  <xsl:param name="colgroup" as="element()"/>
  <xsl:param name="abspixels" select="0"/>

  <xsl:variable name="parsedcols" as="element()*">
    <xsl:for-each select="$colgroup/h:col">
      <xsl:choose>
	<xsl:when test="not(@colwidth)">
	  <col ghost:rel="1" ghost:abs="0">
	    <xsl:copy-of select="@*"/>
	  </col>
	</xsl:when>
	<xsl:when test="contains(@colwidth, '*')">
	  <col ghost:rel="{substring-before(@colwidth, '*')}"
	       ghost:abs="{if (substring-after(@colwidth, '*') = '')
			   then 0
			   else f:convert-length(substring-after(@colwidth, '*'))}">
	    <xsl:copy-of select="@*"/>
	  </col>
	</xsl:when>
	<xsl:when test="matches(@colwidth, '^\d+$')">
	  <col ghost:rel="0"
	       ghost:abs="{f:convert-length(concat(@colwidth,'px'))}">
	    <xsl:copy-of select="@*"/>
	  </col>
	</xsl:when>
	<xsl:otherwise>
	  <col ghost:rel="0" ghost:abs="{f:convert-length(@colwidth)}">
	    <xsl:copy-of select="@*"/>
	  </col>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:variable>

  <colgroup>
    <xsl:choose>
      <xsl:when test="sum($parsedcols/@ghost:rel) = 0">
	<xsl:for-each select="$parsedcols">
	  <col>
	    <xsl:copy-of select="@*[namespace-uri(.) != 'http://docbook.org/docbook-ng/ephemeral']"/>
	    <xsl:attribute name="colwidth">
	      <xsl:choose>
		<xsl:when test="$abspixels = 0">
		  <xsl:value-of select="format-number(@ghost:abs div $pixels.per.inch,
					              '0.00')"/>
		  <xsl:text>in</xsl:text>
		</xsl:when>
		<xsl:otherwise>
		  <xsl:value-of select="@ghost:abs"/>
		</xsl:otherwise>
	      </xsl:choose>
	    </xsl:attribute>
	  </col>
	</xsl:for-each>
      </xsl:when>
      <xsl:when test="sum($parsedcols/@ghost:abs) = 0">
	<xsl:variable name="relTotal" select="sum($parsedcols/@ghost:rel)"/>
	<xsl:for-each select="$parsedcols">
	  <col>
	    <xsl:copy-of select="@*[namespace-uri(.) != 'http://docbook.org/docbook-ng/ephemeral']"/>
	    <xsl:attribute name="colwidth">
	      <xsl:value-of select="round(@ghost:rel div $relTotal * 100)"/>
	      <xsl:text>%</xsl:text>
	    </xsl:attribute>
	  </col>
	</xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
	<xsl:variable name="relTotal" select="sum($parsedcols/@ghost:rel)"/>
	<xsl:variable name="pixelwidth"
		      select="if (contains($table-width, '%'))
			      then $nominal-table-width
			      else f:convert-length($table-width)"/>

	<xsl:variable name="convcols" as="element()*">
	  <xsl:for-each select="$parsedcols">
	    <col>
	      <xsl:copy-of select="@*"/>
	      <xsl:attribute name="ghost:rel"
			     select="(@ghost:rel div $relTotal * $pixelwidth)
				     + @ghost:abs"/>
	    </col>
	  </xsl:for-each>
	</xsl:variable>

	<xsl:variable name="absTotal" select="sum($convcols/@ghost:rel)"/>

	<xsl:if test="$absTotal &gt; $pixelwidth">
	  <xsl:message>
	    <xsl:text>Warning: table is wider than specified width.</xsl:text>
	  </xsl:message>
	</xsl:if>

	<xsl:choose>
	  <xsl:when test="contains($table-width, '%')">
	    <xsl:for-each select="$convcols">
	      <col>
		<xsl:copy-of select="@*[namespace-uri(.)
			        != 'http://docbook.org/docbook-ng/ephemeral']"/>
		<xsl:attribute name="colwidth">
		  <xsl:value-of select="format-number(@ghost:rel div $absTotal * 100,
					              '0.00')"/>
		  <xsl:text>%</xsl:text>
		</xsl:attribute>
	      </col>
	    </xsl:for-each>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:for-each select="$convcols">
	      <col>
		<xsl:copy-of select="@*[namespace-uri(.) != 'http://docbook.org/docbook-ng/ephemeral']"/>
		<xsl:attribute name="colwidth">
		  <xsl:choose>
		    <xsl:when test="$abspixels = 0">
		      <xsl:value-of select="format-number(@ghost:rel
					                  div $pixels.per.inch,
					    '0.00')"/>
		      <xsl:text>in</xsl:text>
		    </xsl:when>
		    <xsl:otherwise>
		      <xsl:value-of select="round(@ghost:rel)"/>
		    </xsl:otherwise>
		  </xsl:choose>
		</xsl:attribute>
	      </col>
	    </xsl:for-each>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </colgroup>
</xsl:template>

<!-- ============================================================ -->

<doc:function name="f:convert-length" xmlns="http://docbook.org/docbook-ng">
<refpurpose>Converts a length to pixels</refpurpose>

<refdescription>
<para>This function converts a length, for example, “3mm” or “2in”,
into an integral number of pixels. The size of a pixel is determined
by the <parameter>pixels.per.inch</parameter> parameter.</para>
<para>The following units are recognized: inches (in), centimeters
(cm), milimeters (mm), picas (pc), points (pt), and pixels (px).
A value specified without units is assumed to be pixels. For convenience,
if a percentage is provided, it is returned unchanged.</para>
<para>If an unrecognized unit is specified, it is treated like “1in”.</para>
</refdescription>

<refparameter>
<variablelist>
<varlistentry><term>length</term>
<listitem>
<para>The length to convert.</para>
</listitem>
</varlistentry>
</variablelist>
</refparameter>

<refreturn>
<para>The converted length, an integral number of pixels, unless the
length specified was a percentage, in which case it is returned unchanged.</para>
</refreturn>

<u:unittests function="f:convert-length">
  <u:test>
    <u:param>1in</u:param>
    <u:result>96</u:result>
  </u:test>
  <u:test>
    <u:param select="'+2in'"/>
    <u:result>192</u:result>
  </u:test>
  <u:test>
    <u:param>100pt</u:param>
    <u:result>133</u:result>
  </u:test>
  <u:test>
    <u:param>50%</u:param>
    <u:result>'50%'</u:result>
  </u:test>
  <u:test>
    <u:param>10barleycorn</u:param>
    <u:result>96</u:result>
  </u:test>
</u:unittests>

</doc:function>

<xsl:function name="f:convert-length">
  <xsl:param name="length" as="xs:string"/>

  <xsl:choose>
    <xsl:when test="contains($length, '%')">
      <xsl:value-of select="$length"/>
    </xsl:when>
    <xsl:when test="$length castable as xs:double">
      <xsl:value-of select="round($length cast as xs:double)"/>
    </xsl:when>
    <xsl:when test="matches($length, '^[\+\-]?\d+\.?\d*\w+$')">
      <xsl:variable name="spaced"
		    select="replace($length,
			            '(^[\+\-]?\d+\.?\d*)(\w+)$',
				    '$1 $2')"/>
      <xsl:variable name="magnitude"
		    select="xs:double(substring-before($spaced, ' '))"/>
      <xsl:variable name="units" select="substring-after($spaced, ' ')"/>
      <xsl:choose>
	<xsl:when test="$units = 'in'">
	  <xsl:value-of select="xs:integer($magnitude * $pixels.per.inch)"/>
	</xsl:when>
	<xsl:when test="$units = 'cm'">
	  <xsl:value-of select="xs:integer($magnitude * $pixels.per.inch div 2.54)"/>
	</xsl:when>
	<xsl:when test="$units = 'mm'">
	  <xsl:value-of select="xs:integer($magnitude * $pixels.per.inch div 25.4)"/>
	</xsl:when>
	<xsl:when test="$units = 'pc'">
	  <xsl:value-of select="xs:integer($magnitude * $pixels.per.inch div 72 * 12)"/>
	</xsl:when>
	<xsl:when test="$units = 'pt'">
	  <xsl:value-of select="xs:integer($magnitude * $pixels.per.inch div 72)"/>
	</xsl:when>
	<xsl:when test="$units = 'px'">
	  <xsl:value-of select="xs:integer($magnitude)"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:message>
	    <xsl:text>Unrecognized units in f:convert-length: </xsl:text>
	    <xsl:value-of select="$units"/>
	  </xsl:message>
	  <!-- 1in -->
	  <xsl:value-of select="$pixels.per.inch"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:when>
  </xsl:choose>
</xsl:function>

<!-- ============================================================ -->

<doc:function name="f:find-element-by-attribute"
	      xmlns="http://docbook.org/docbook-ng">
<refpurpose>Selects an element based on the presence of an attribute</refpurpose>

<refdescription>
<para>Given a sequence of elements and an attribute name, this
function returns the first element in the list that has the
specified attribute.</para>
</refdescription>

<refparameter>
<variablelist>
<varlistentry><term>elements</term>
<listitem>
<para>A sequence of zero or more elements.</para>
</listitem>
</varlistentry>
<varlistentry><term>attr</term>
<listitem>
<para>The name of the attribute to find.</para>
</listitem>
</varlistentry>
</variablelist>
</refparameter>

<refreturn>
<para>An element or the empty sequence if no element has the specified
attribute.</para>
</refreturn>
</doc:function>

<xsl:function name="f:find-element-by-attribute" as="element()?">
  <xsl:param name="elements" as="element()*"/>
  <xsl:param name="attr" as="xs:QName"/>

  <xsl:choose>
    <xsl:when test="not($elements)">
      <xsl:sequence select="()"/>
    </xsl:when>
    <xsl:when test="$elements[1]/@*[node-name() = $attr]">
      <xsl:sequence select="$elements[1]"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="f:find-element-by-attribute($elements[position() &gt; 1], $attr)"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!-- ============================================================ -->

<doc:function name="f:find-colspec-by-colnum"
	      xmlns="http://docbook.org/docbook-ng">
<refpurpose>Finds the <tag>colspec</tag> for the specified column
number.</refpurpose>

<refdescription>
<para>Searches the <tag>colspec</tag> elements and returns the one
for the specified column.</para>
</refdescription>

<refparameter>
<variablelist>
<varlistentry><term>tgroup</term>
<listitem>
<para>The <tag>tgroup</tag> element in which to search.</para>
</listitem>
</varlistentry>
<varlistentry><term>colnum</term>
<listitem>
<para>The column number.</para>
</listitem>
</varlistentry>
</variablelist>
</refparameter>

<refreturn>
<para>The <tag>colspec</tag> or the empty sequence if there is no
specification for that column.</para>
</refreturn>
</doc:function>

<xsl:function name="f:find-colspec-by-colnum" as="element()?">
  <xsl:param name="tgroup" as="element(db:tgroup)"/>
  <xsl:param name="colnum" as="xs:integer"/>
  
  <xsl:sequence select="fp:find-colspec($tgroup/db:colspec[1], $colnum, 0)"/>
</xsl:function>

<xsl:function name="fp:find-colspec" as="element()?">
  <xsl:param name="colspec" as="element(db:colspec)?"/>
  <xsl:param name="colnum" as="xs:integer"/>
  <xsl:param name="curcol" as="xs:integer"/>

  <xsl:choose>
    <xsl:when test="not($colspec) or $curcol &gt; $colnum">
      <xsl:sequence select="()"/>
    </xsl:when>
    <xsl:when test="$colspec/@colnum">
      <xsl:choose>
	<xsl:when test="$colnum = $colspec/@colnum">
	  <xsl:sequence select="$colspec"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:sequence select="fp:find-colspec($colspec/following-sibling::db:colspec[1], $colnum, xs:integer($colspec/@colnum))"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:choose>
	<xsl:when test="$colnum = $curcol+1">
	  <xsl:sequence select="$colspec"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:sequence select="fp:find-colspec($colspec/following-sibling::db:colspec[1], $colnum, $colnum+1)"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!-- ============================================================ -->

<doc:function name="f:skip-overhang" xmlns="http://docbook.org/docbook-ng">
<refpurpose>Finds the next available column position in a CALS table</refpurpose>

<refdescription>
<para>This function returns the next available column position in a
CALS table, skipping over the columns that contains cells which hang
down into the current row.</para>
</refdescription>

<refparameter>
<variablelist>
<varlistentry><term>overhang</term>
<listitem>
<para>A sequence of integer values giving the depth of “overhang” from
previous rows for
cells in each column of the table.</para>
</listitem>
</varlistentry>
<varlistentry><term>pos</term>
<listitem>
<para>The nominal next column. This generally one more than the
current column number.</para>
</listitem>
</varlistentry>
</variablelist>
</refparameter>

<refreturn>
<para>The next available column in the row.</para>
</refreturn>
</doc:function>

<xsl:function name="f:skip-overhang">
  <xsl:param name="overhang" as="xs:integer+"/>
  <xsl:param name="pos" as="xs:integer"/>

  <xsl:choose>
    <xsl:when test="$pos &gt; count($overhang)">0</xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="if ($overhang[$pos] = 0)
			    then $pos
			    else f:skip-overhang($overhang, $pos+1)"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!-- ============================================================ -->

<doc:function name="f:colspec-colnum" xmlns="http://docbook.org/docbook-ng">
<refpurpose>Returns the column number associated with a particuluar
<tag>colspec</tag>.</refpurpose>

<refdescription>
<para>This function returns the column number of the specified
<tag>colspec</tag>.</para>
</refdescription>

<refparameter>
<variablelist>
<varlistentry><term>colspec</term>
<listitem>
<para>The <tag>colspec</tag> element.</para>
</listitem>
</varlistentry>
</variablelist>
</refparameter>

<refreturn>
<para>The column number associated with that <tag>colspec</tag>.</para>
</refreturn>
</doc:function>

<xsl:function name="f:colspec-colnum" as="xs:integer">
  <xsl:param name="colspec" as="element(db:colspec)"/>

  <xsl:choose>
    <xsl:when test="$colspec/@colnum">
      <xsl:value-of select="$colspec/@colnum"/>
    </xsl:when>
    <xsl:when test="$colspec/preceding-sibling::db:colspec">
      <xsl:value-of select="f:colspec-colnum(
			       $colspec/preceding-sibling::db:colspec[1])
	                    + 1"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="1"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!-- ============================================================ -->

<doc:function name="f:spanspec-colnum-start"
	      xmlns="http://docbook.org/docbook-ng">
<refpurpose>Returns the column number of the starting column of a
span</refpurpose>

<refdescription>
<para>This function returns the column number of the starting column
of a span.</para>
</refdescription>

<refparameter>
<variablelist>
<varlistentry><term>spanspec</term>
<listitem>
<para>The <tag>spanspec</tag> element.</para>
</listitem>
</varlistentry>
</variablelist>
</refparameter>

<refreturn>
<para>The column number associated with the first column of the
span.</para>
</refreturn>
</doc:function>

<xsl:function name="f:spanspec-colnum-start" as="xs:integer">
  <xsl:param name="spanspec" as="element(db:spanspec)"/>

  <xsl:value-of select="f:colspec-colnum($spanspec/ancestor::db:tgroup[1]
			      /db:colspec[@colname=$spanspec/@namest])"/>
</xsl:function>

<!-- ============================================================ -->

<doc:function name="f:spanspec-colnum-end"
	      xmlns="http://docbook.org/docbook-ng">
<refpurpose>Returns the column number of the ending column of a
span</refpurpose>

<refdescription>
<para>This function returns the column number of the ending column
of a span.</para>
</refdescription>

<refparameter>
<variablelist>
<varlistentry><term>spanspec</term>
<listitem>
<para>The <tag>spanspec</tag> element.</para>
</listitem>
</varlistentry>
</variablelist>
</refparameter>

<refreturn>
<para>The column number associated with the last column of the span.</para>
</refreturn>
</doc:function>

<xsl:function name="f:spanspec-colnum-end" as="xs:integer">
  <xsl:param name="spanspec" as="element(db:spanspec)"/>

  <xsl:value-of select="f:colspec-colnum($spanspec/ancestor::db:tgroup[1]
			      /db:colspec[@colname=$spanspec/@nameend])"/>
</xsl:function>

</xsl:stylesheet>
