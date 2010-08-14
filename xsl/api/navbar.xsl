<?xml version="1.0" encoding="utf-8"?>
<!--
   Copyright (c) 2002 Douglas Gregor <doug.gregor -at- gmail.com>
  
   Distributed under the Boost Software License, Version 1.0.
   (See accompanying file LICENSE_1_0.txt or copy at
   http://www.boost.org/LICENSE_1_0.txt)
  -->
<xsl:stylesheet exclude-result-prefixes="d"
                 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:d="http://docbook.org/ns/docbook"
version="1.0">

<!-- Already included in the main style sheet -->
<!-- <xsl:import href="relative-href.xsl"/> -->
 
   <!--
      docbook.defaults:
        *custom  - only use explicitly set parameters
         API   - use standard API extension settings, can be overridden
   -->
   <xsl:param name = "docbook.defaults" select = "'none'"/>

   <!--
      how to render the Home | Libraries | ... | More contents
        *none       - do not display ("standalone" mode)
         horizontal - display in old-API style format (default for API)
         vertical   - like the new Getting Started layout
   -->
   <xsl:param name = "nav.layout">
      <xsl:choose>
         <xsl:when test = "$docbook.defaults='API'">horizontal</xsl:when>
         <xsl:otherwise>none</xsl:otherwise>
      </xsl:choose>
   </xsl:param>
   <!--
      header border layout
         API - place the old-API border around the header
        *none  - do not place a border around the header
   -->
   <xsl:param name = "nav.border" select = "'none'" />

   <!--
      nav.flow:
         none    - do not display navigation at the header
         DocBook - display the navigation after the header
        *Spirit  - display "mini" navigation on the right
   -->
   <xsl:param name = "nav.flow" select = "'Spirit'"/>
   
   <!-- location of the various DocBook API elements -->

   <xsl:param name = "api.root"      select = "'.'"/>
   <xsl:param name = "api.website"   select = "'http://wiki.docbook.org/topic/BoostBookIntegration'"/>
   <!-- Logo image location, leave empty for no logo -->
   <xsl:param name = "api.image.src">
      <xsl:if test = "$docbook.defaults = 'API'">
         <xsl:value-of select = "concat($api.root, '/images/db.png')"/>
      </xsl:if>
   </xsl:param>
   <xsl:param name = "api.image.alt">
      <xsl:if test = "$docbook.defaults = 'API'">
         <xsl:value-of select = "'DocBook API Dcoumentation'"/>
      </xsl:if>
   </xsl:param>
   <xsl:param name = "api.image.w">
      <xsl:if test = "$docbook.defaults = 'API'">
         <xsl:value-of select = "177"/>
      </xsl:if>
   </xsl:param>
   <xsl:param name = "api.image.h">
      <xsl:if test = "$docbook.defaults = 'API'">
         <xsl:value-of select = "86"/>
      </xsl:if>
   </xsl:param>
<!--    <xsl:param name = "api.libraries">
      <xsl:if test = "$docbook.defaults = 'API'">
         <xsl:value-of select = "concat($api.root, '/libs/libraries.htm')"/>
      </xsl:if>
   </xsl:param>
 -->
   <!-- header -->

   <xsl:template name = "header.navigation">
      <xsl:param name = "prev" select = "/d:foo"/>
      <xsl:param name = "next" select = "/d:foo"/>
      <xsl:param name = "nav.context"/>

      <xsl:variable name = "home" select = "/*[1]"/>
      <xsl:variable name = "up"   select = "parent::*"/>

      <table cellpadding = "2" width = "100%"><tr>
         <xsl:if test = "$nav.border = 'API'">
            <xsl:attribute name = "class">api-head</xsl:attribute>
         </xsl:if>

         <td valign = "top">
            <xsl:if test = "$nav.border = 'API'">
               <xsl:attribute name = "style">background-color: white; width: 50%;</xsl:attribute>
            </xsl:if>
            <xsl:if test = "boolean(normalize-space($api.image.src))">
               <img alt="{$api.image.alt}" width="{$api.image.w}" height="{$api.image.h}">
                   <xsl:attribute name="src">
                       <xsl:call-template name="href.target.relative">
                           <xsl:with-param name="target" select="$api.image.src"/>
                       </xsl:call-template>
                   </xsl:attribute>
               </img>
            </xsl:if>
         </td><xsl:choose>
            <xsl:when test = "$nav.layout = 'horizontal'">
               <xsl:call-template name = "header.navdata-horiz"/>
            </xsl:when><xsl:when test = "$nav.layout = 'vertical'">
               <xsl:call-template name = "header.navdata-vert"/>
            </xsl:when>
         </xsl:choose>
      </tr></table>
      <hr/>
      <xsl:choose>
         <xsl:when test = "$nav.flow = 'DocBook'">
            <table width = "100%" class = "navheader">
               <xsl:call-template name = "navbar.docbook-homeinfo">
                  <xsl:with-param name = "prev" select = "$prev"/>
                  <xsl:with-param name = "next" select = "$next"/>
                  <xsl:with-param name = "nav.context" select = "$nav.context"/>
               </xsl:call-template>
               <xsl:call-template name = "navbar.docbook-prevnext">
                  <xsl:with-param name = "prev" select = "$prev"/>
                  <xsl:with-param name = "next" select = "$next"/>
                  <xsl:with-param name = "nav.context" select = "$nav.context"/>
               </xsl:call-template>
            </table>
         </xsl:when><xsl:when test = "$nav.flow = 'Spirit'">
            <xsl:call-template name = "navbar.spirit">
               <xsl:with-param name = "prev" select = "$prev"/>
               <xsl:with-param name = "next" select = "$next"/>
               <xsl:with-param name = "nav.context" select = "$nav.context"/>
            </xsl:call-template>
         </xsl:when>
      </xsl:choose>
   </xsl:template>

   <xsl:template name = "header.navdata-horiz">
      <xsl:variable name="home_link">
         <xsl:call-template name="href.target.relative">
            <xsl:with-param name="target" select="concat( $api.root, '/index.html' )"/>
         </xsl:call-template>
      </xsl:variable>
<!--       <xsl:variable name="libraries_link">
         <xsl:if test = "boolean($api.libraries)">
            <xsl:call-template name="href.target.relative">
               <xsl:with-param name="target" select="$api.libraries"/>
            </xsl:call-template>
         </xsl:if>
      </xsl:variable>
       -->
      <xsl:variable name="project_link">
         <xsl:call-template name="href.target.relative">
            <xsl:with-param name="target" select="'http://wiki.docbook.org/topic/BoostBookIntegration'"/> 
         </xsl:call-template>
      </xsl:variable>
<!--       <xsl:variable name="faq_link">
         <xsl:call-template name="href.target.relative">
            <xsl:with-param name="target" select="concat( $api.website, '/users/faq.html' )"/> 
         </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="more_link">
         <xsl:call-template name="href.target.relative">
            <xsl:with-param name="target" select="concat( $api.root, '/more/index.htm' )"/>
         </xsl:call-template>
      </xsl:variable>
 -->      
      <xsl:choose>
         <xsl:when test = "$nav.border = 'API'">
            <td align = "center" class = "api-headtd"><a href = "{$home_link}" class = "api-headelem">Home</a></td>
<!--             <xsl:if test = "boolean($libraries_link)">
              <td align = "center" class = "api-headtd"><a href = "{$libraries_link}" class = "api-headelem">Libraries</a></td>
            </xsl:if>
             -->
            <td align = "center" class = "api-headtd"><a href = "{$project_link}" class = "api-headelem">Project</a></td>
<!--             <td align = "center" class = "api-headtd"><a href = "{$faq_link}" class = "api-headelem">FAQ</a></td>
            <td align = "center" class = "api-headtd"><a href = "{$more_link}" class = "api-headelem">More</a></td>  -->
         </xsl:when><xsl:otherwise>
            <td align = "center"><a href = "{$home_link}">Home</a></td>
<!--             <td align = "center"><a href = "{$libraries_link}">Libraries</a></td>  -->
            <td align = "center"><a href = "{$project_link}">Project</a></td>
<!--            <td align = "center"><a href = "{$faq_link}">FAQ</a></td>
            <td align = "center"><a href = "{$more_link}">More</a></td> -->
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template name = "header.navdata-vert">
      <xsl:variable name="home_link">
         <xsl:call-template name="href.target.relative">
            <xsl:with-param name="target" select="concat( $api.root, '/index.html' )"/>
         </xsl:call-template>
      </xsl:variable>
<!--       <xsl:variable name="libraries_link">
         <xsl:call-template name="href.target.relative">
            <xsl:with-param name="target" select="$api.libraries"/>
         </xsl:call-template>
      </xsl:variable>
 -->
      <xsl:variable name="project_link">
         <xsl:call-template name="href.target.uri">
            <xsl:with-param name="target" select="'http://wiki.docbook.org/topic/BoostBookIntegration'"/>
         </xsl:call-template>
      </xsl:variable>
<!-- 
      <xsl:variable name="faq_link">
         <xsl:call-template name="href.target.relative">
            <xsl:with-param name="target" select="concat( $api.website, '/users/faq.html' )"/>
         </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="more_link">
         <xsl:call-template name="href.target.relative">
            <xsl:with-param name="target" select="concat( $api.root, '/more/index.htm' )"/>
         </xsl:call-template>
      </xsl:variable>
 -->
      <td><div>
         <xsl:if test = "$nav.border != 'API'">
            <xsl:attribute name = "class">api-toc</xsl:attribute>
         </xsl:if>
         <div><a href = "{$home_link}">Home</a></div>
<!--          <div><a href = "{$libraries_link}">Libraries</a></div> -->
         <div><a href = "{$project_link}">Project</a></div>
<!--          <div><a href = "{$faq_link}">FAQ</a></div>
         <div><a href = "{$more_link}">More</a></div>  -->
      </div></td>
   </xsl:template>


   <!-- footer -->

   <xsl:template name = "footer.navigation">
      <xsl:param name = "prev" select = "/d:foo"/>
      <xsl:param name = "next" select = "/d:foo"/>
      <xsl:param name = "nav.context"/>

      <hr/>
      <xsl:choose>
         <xsl:when test = "$nav.flow = 'DocBook'">
            <table width = "100%" class = "navheader">
               <xsl:call-template name = "navbar.docbook-prevnext">
                  <xsl:with-param name = "prev" select = "$prev"/>
                  <xsl:with-param name = "next" select = "$next"/>
                  <xsl:with-param name = "nav.context" select = "$nav.context"/>
               </xsl:call-template>
               <xsl:call-template name = "navbar.docbook-homeinfo">
                  <xsl:with-param name = "prev" select = "$prev"/>
                  <xsl:with-param name = "next" select = "$next"/>
                  <xsl:with-param name = "nav.context" select = "$nav.context"/>
               </xsl:call-template>
            </table>
         </xsl:when><xsl:when test = "$nav.flow = 'Spirit'">
            <xsl:call-template name = "navbar.spirit">
               <xsl:with-param name = "prev" select = "$prev"/>
               <xsl:with-param name = "next" select = "$next"/>
               <xsl:with-param name = "nav.context" select = "$nav.context"/>
            </xsl:call-template>
         </xsl:when>
      </xsl:choose>
   </xsl:template>

   <!-- navbar -->

   <xsl:template name = "navbar.docbook-homeinfo">
      <xsl:param name = "prev" select = "/d:foo"/>
      <xsl:param name = "next" select = "/d:foo"/>
      <xsl:param name = "nav.context"/>

      <xsl:variable name = "home" select = "/*[1]"/>
      <tr>
         <td align = "left" width = "40%">
            <xsl:if test = "$navig.showtitles != 0"> <!-- prev:name -->
               <xsl:apply-templates select = "$prev" mode = "object.title.markup"/>
            </xsl:if>
         </td><td align = "center" width = "20%">
            <!-- home -->
            <xsl:if test = "$home != . or $nav.context = 'toc'">
               <a accesskey = "h">
                  <xsl:attribute name = "href"><xsl:call-template name = "href.target">
                     <xsl:with-param name = "object" select = "$home"/>
                  </xsl:call-template></xsl:attribute>
                  <xsl:call-template name = "navig.content">
                     <xsl:with-param name = "direction" select = "'home'"/>
                  </xsl:call-template>
               </a>
               <xsl:if test = "$chunk.tocs.and.lots != 0 and $nav.context != 'toc'">
                  <xsl:text>|</xsl:text>
               </xsl:if>
            </xsl:if>
            <xsl:if test = "$chunk.tocs.and.lots != 0 and $nav.context != 'toc'"><a accesskey = "t">
               <xsl:attribute name = "href">
                  <xsl:apply-templates select = "/*[1]" mode = "recursive-chunk-filename"/>
                  <xsl:text>-toc</xsl:text>
                  <xsl:value-of select = "$html.ext"/>
               </xsl:attribute>
               <xsl:call-template name = "gentext">
                  <xsl:with-param name = "key" select = "'nav-toc'"/>
               </xsl:call-template>
            </a></xsl:if>
         </td><td align = "right" width = "40%">
            <xsl:if test = "$navig.showtitles != 0"> <!-- next:name -->
               <xsl:apply-templates select = "$next" mode = "object.title.markup"/>
            </xsl:if>
         </td>
      </tr>
   </xsl:template>

   <xsl:template name = "navbar.docbook-prevnext">
      <xsl:param name = "prev" select = "/d:foo"/>
      <xsl:param name = "next" select = "/d:foo"/>
      <xsl:param name = "nav.context"/>

      <xsl:variable name = "up" select = "parent::*"/>
      <tr>
         <td align = "left" width = "40%">
            <xsl:if test = "count($prev)>0"><a accesskey = "p"> <!-- prev -->
               <xsl:attribute name = "href"><xsl:call-template name = "href.target">
                   <xsl:with-param name = "object" select = "$prev"/>
               </xsl:call-template></xsl:attribute>
               <xsl:call-template name = "navig.content">
                  <xsl:with-param name = "direction" select = "'prev'"/>
               </xsl:call-template>
            </a></xsl:if>
         </td><td align = "center" width = "20%">
            <xsl:if test = "count($up)>0"><a accesskey = "u"> <!-- up -->
               <xsl:attribute name = "href"><xsl:call-template name = "href.target">
                  <xsl:with-param name = "object" select = "$up"/>
               </xsl:call-template></xsl:attribute>
               <xsl:call-template name = "navig.content">
                  <xsl:with-param name = "direction" select = "'up'"/>
               </xsl:call-template>
            </a></xsl:if>
         </td><td align = "right" width = "40%">
            <xsl:if test = "count($next)>0"><a accesskey = "n"> <!-- next -->
               <xsl:attribute name = "href"><xsl:call-template name = "href.target">
                  <xsl:with-param name = "object" select = "$next"/>
               </xsl:call-template></xsl:attribute>
               <xsl:call-template name = "navig.content">
                  <xsl:with-param name = "direction" select = "'next'"/>
               </xsl:call-template>
            </a></xsl:if>
         </td>
      </tr>
   </xsl:template>

   <xsl:template name = "navbar.spirit">
      <xsl:param name = "prev" select = "/d:foo"/>
      <xsl:param name = "next" select = "/d:foo"/>
      <xsl:param name = "nav.context"/>

      <xsl:variable name = "home" select = "/*[1]"/>
      <xsl:variable name = "up"   select = "parent::*"/>

      <div class = "spirit-nav">
         <!-- prev -->
         <xsl:if test = "count($prev)>0"><a accesskey = "p">
            <xsl:attribute name = "href"><xsl:call-template name = "href.target">
               <xsl:with-param name = "object" select = "$prev"/>
            </xsl:call-template></xsl:attribute>
            <xsl:call-template name = "navig.content">
               <xsl:with-param name = "direction" select = "'prev'"/>
            </xsl:call-template>
         </a></xsl:if>
         <!-- up -->
         <xsl:if test = "count($up)>0"><a accesskey = "u">
            <xsl:attribute name = "href"><xsl:call-template name = "href.target">
               <xsl:with-param name = "object" select = "$up"/>
            </xsl:call-template></xsl:attribute>
            <xsl:call-template name = "navig.content">
               <xsl:with-param name = "direction" select = "'up'"/>
            </xsl:call-template>
         </a></xsl:if>
         <!-- home -->
         <xsl:if test = "generate-id($home) != generate-id(.) or $nav.context = 'toc'">
            <a accesskey = "h">
               <xsl:attribute name = "href"><xsl:call-template name = "href.target">
                  <xsl:with-param name = "object" select = "$home"/>
               </xsl:call-template></xsl:attribute>
               <xsl:call-template name = "navig.content">
                  <xsl:with-param name = "direction" select = "'home'"/>
               </xsl:call-template>
            </a>
            <xsl:if test = "$chunk.tocs.and.lots != 0 and $nav.context != 'toc'">
               <xsl:text>|</xsl:text>
            </xsl:if>
         </xsl:if>
         <xsl:if test = "$chunk.tocs.and.lots != 0 and $nav.context != 'toc'"><a accesskey = "t">
            <xsl:attribute name = "href">
               <xsl:apply-templates select = "/*[1]" mode = "recursive-chunk-filename"/>
               <xsl:text>-toc</xsl:text>
               <xsl:value-of select = "$html.ext"/>
            </xsl:attribute>
            <xsl:call-template name = "gentext">
               <xsl:with-param name = "key" select = "'nav-toc'"/>
            </xsl:call-template>
         </a></xsl:if>
         <!-- next -->
         <xsl:if test = "count($next)>0"><a accesskey = "n">
            <xsl:attribute name = "href"><xsl:call-template name = "href.target">
               <xsl:with-param name = "object" select = "$next"/>
            </xsl:call-template></xsl:attribute>
            <xsl:call-template name = "navig.content">
               <xsl:with-param name = "direction" select = "'next'"/>
            </xsl:call-template>
         </a></xsl:if>
      </div>
   </xsl:template>
</xsl:stylesheet>
