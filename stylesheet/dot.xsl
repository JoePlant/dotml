<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:dot="http://dotml.googlecode.com">
	<xsl:output method="text" encoding="UTF-8"/>
	<xsl:variable name="rankdir">
		<xsl:choose>
			<xsl:when test="//@rankdir">
				<xsl:value-of select="//@rankdir"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>TB</xsl:text>
			</xsl:otherwise>
		</xsl:choose>		
	</xsl:variable>
	<xsl:template match="/">
		<xsl:apply-templates/>
	</xsl:template>
	<xsl:template name="getAncestorGraphCount">
		<xsl:value-of select="count( ancestor::dot:graph | ancestor::dot:digraph | ancestor::dot:subgraph )"/>
	</xsl:template>
	<xsl:template name="putIndent">
		<xsl:param name="tabSize">
			<xsl:call-template name="getAncestorGraphCount"/>
		</xsl:param>
		<xsl:if test="$tabSize > 0">
			<xsl:text>    </xsl:text>
			<xsl:call-template name="putIndent">
				<xsl:with-param name="tabSize" select="$tabSize - 1"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
	<xsl:template match="dot:graph | dot:digraph | dot:subgraph">
		<xsl:call-template name="putIndent"/>
		<xsl:if test="@strict">
			<xsl:text>strict </xsl:text>
		</xsl:if>
		<xsl:variable name="lname">
			<xsl:choose>
				<xsl:when test="contains( name(), ':' )">
					<xsl:value-of select="substring-after( name(), ':' )"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="name()"/>
				</xsl:otherwise>
			</xsl:choose>			
		</xsl:variable>
		<xsl:value-of select="$lname"/>
		<xsl:text> </xsl:text>
		<xsl:choose>
			<xsl:when test="$lname = 'subgraph'">
				<xsl:call-template name="putQuoted">
					<xsl:with-param name="text" select="@id"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="putQuoted">
					<xsl:with-param name="text" select="$lname"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text> {</xsl:text>
		<xsl:text>&#10;</xsl:text>
		<xsl:call-template name="putAttrs">
			<xsl:with-param name="inline" select="false()"/>
		</xsl:call-template>
		<xsl:apply-templates/>
		<xsl:call-template name="putIndent"/>
		<xsl:text>}</xsl:text>
		<xsl:text>&#10;</xsl:text>
	</xsl:template>
	<xsl:template name="putAttrs">
		<xsl:param name="inline" select="true()"/>
		<xsl:for-each
			select="@*[ not( name() = 'id' or name() = 'name' or name() = 'align' or name() = 'from' or name() = 'to' or name() = 'fromCid' or name() = 'toCid' or contains( name(), 'colorgrade' ) ) ]">
			<xsl:variable name="value" select="normalize-space(.)"/>
			<xsl:if test="not( $inline = true() )">
				<xsl:call-template name="putIndent"/>
			</xsl:if>
			<xsl:choose>
				<xsl:when test="contains( name(), 'color' )">
					<xsl:value-of select="name()"/>
					<xsl:text>=</xsl:text>
					<xsl:value-of select="."/>
					<xsl:for-each select="../@*">
						<xsl:if test="contains( name(), 'colorgrade' )">
							<xsl:value-of select="."/>
						</xsl:if>
					</xsl:for-each>
				</xsl:when>
				<xsl:when test="name() = 'size'">
					<xsl:value-of select="name()"/>
					<xsl:text>="</xsl:text>
					<xsl:value-of select="substring-before( $value, ' ')"/>
					<xsl:text>, </xsl:text>
					<xsl:value-of select="substring-after( $value, ' ')"/>
					<xsl:text>"</xsl:text>
				</xsl:when>
				<xsl:when
					test="name() = 'label' or name() = 'taillabel' or name() = 'headlabel' or contains( name(), 'fontname' )">
					<xsl:value-of select="name()"/>
					<xsl:text>="</xsl:text>
					<xsl:value-of select="."/>
					<xsl:text>"</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="name()"/>
					<xsl:text>=</xsl:text>
					<xsl:value-of select="."/>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:choose>
				<xsl:when test="$inline = true()">
					<xsl:if test="not( position() = last() )">
						<xsl:text>, </xsl:text>
					</xsl:if>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>&#10;</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="getPutAttrCount">
		<xsl:variable name="counttxt">
			<xsl:for-each select="@*">
				<xsl:choose>
					<xsl:when
						test="name() = 'id' or name() = 'name' or name() = 'align' or name() = 'from' or name() = 'to' or name() = 'fromCid' or name() = 'toCid' or contains( name(), 'colorgrade' )"/>
					<xsl:otherwise>1</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
		</xsl:variable>
		<xsl:value-of select="string-length( $counttxt )"/>
	</xsl:template>
	<xsl:template match="dot:node">
		<xsl:call-template name="putIndent"/>
		<xsl:variable name="label">
			<xsl:value-of select="@id"/>
		</xsl:variable>
		<xsl:call-template name="putQuoted">
			<xsl:with-param name="text" select="$label"/>
		</xsl:call-template>
		<xsl:variable name="putAttrCnt">
			<xsl:call-template name="getPutAttrCount"/>
		</xsl:variable>
		<xsl:if test="$putAttrCnt > 0 or child::*">
			<xsl:text> [ </xsl:text>
			<xsl:choose>
				<xsl:when test="dot:row">
					<xsl:text>label="</xsl:text>
					<xsl:if test="$rankdir = 'TB' or $rankdir = 'BT'">
						<xsl:text>{</xsl:text>	
					</xsl:if>					
					<xsl:apply-templates select="dot:row"/>
					<xsl:if test="$rankdir = 'TB' or $rankdir = 'BT'">
						<xsl:text>}</xsl:text>	
					</xsl:if>
					<xsl:text>"</xsl:text>
					<xsl:if test="$putAttrCnt > 0">
						<xsl:text>, </xsl:text>
					</xsl:if>
				</xsl:when>
				<xsl:when test="dot:col">
					<xsl:if test="$rankdir = 'LR' or $rankdir = 'RL'">
						<xsl:text>{</xsl:text>	
					</xsl:if>
					<xsl:apply-templates select="dot:col"/>
					<xsl:if test="$rankdir = 'LR' or $rankdir = 'RL'">
						<xsl:text>{</xsl:text>	
					</xsl:if>
					<xsl:if test="$putAttrCnt > 0">
						<xsl:text>, </xsl:text>
					</xsl:if>
				</xsl:when>
			</xsl:choose>
			<xsl:call-template name="putAttrs"/>
			<xsl:text> ]</xsl:text>
		</xsl:if>
		<xsl:text>&#10;</xsl:text>
	</xsl:template>
	<xsl:template match="dot:row">
		<xsl:if test="@cid">
			<xsl:text>&lt;</xsl:text>
			<xsl:value-of select="@cid"/>
			<xsl:text>&gt;</xsl:text>
		</xsl:if>
		<xsl:choose>
			<xsl:when test="@label">
				<xsl:value-of select="@label"/>
			</xsl:when>
			<xsl:when test="@cid">
				<xsl:value-of select="@cid"/>
			</xsl:when>
			<xsl:when test="dot:col">
				<xsl:text>{</xsl:text>
				<xsl:apply-templates select="dot:col"/>
				<xsl:text>}</xsl:text>
			</xsl:when>
		</xsl:choose>
		<xsl:apply-templates select="@align"/>
		<xsl:apply-templates select="dot:nl"/>
		<xsl:if test="following-sibling::dot:row">|</xsl:if>
	</xsl:template>
	<xsl:template match="dot:col">
		<xsl:if test="@cid">
			<xsl:text>&lt;</xsl:text>
			<xsl:value-of select="@cid"/>
			<xsl:text>&gt;</xsl:text>
		</xsl:if>
		<xsl:choose>
			<xsl:when test="@label">
				<xsl:value-of select="@label"/>
			</xsl:when>
			<xsl:when test="dot:row">
				<xsl:text>{</xsl:text>
				<xsl:apply-templates select="dot:row"/>
				<xsl:text>}</xsl:text>
			</xsl:when>
		</xsl:choose>
		<xsl:apply-templates select="@align"/>
		<xsl:apply-templates select="dot:nl"/>
		<xsl:if test="following-sibling::dot:row">|</xsl:if>
	</xsl:template>
	<xsl:template match="dot:nodeGlobalAttr">
		<xsl:call-template name="putIndent"/>
		<xsl:text>node [ </xsl:text>
		<xsl:call-template name="putAttrs"/>
		<xsl:text> ]</xsl:text>
		<xsl:text>&#10;</xsl:text>
	</xsl:template>
	<xsl:template name="putQuoted">
		<xsl:param name="text"/>
		<xsl:text>"</xsl:text>
		<xsl:value-of select="$text"/>
		<xsl:text>"</xsl:text>
	</xsl:template>
	<xsl:template match="dot:edge">
		<xsl:call-template name="putIndent"/>
		<xsl:call-template name="putQuoted">
			<xsl:with-param name="text" select="@from"/>
		</xsl:call-template>
		<xsl:if test="@fromCid">
			<xsl:text>:</xsl:text>
			<xsl:value-of select="@fromCid"/>
		</xsl:if>
		<xsl:text> -> </xsl:text>
		<xsl:call-template name="putQuoted">
			<xsl:with-param name="text" select="@to"/>
		</xsl:call-template>
		<xsl:if test="@toCid">
			<xsl:text>:</xsl:text>
			<xsl:value-of select="@toCid"/>
		</xsl:if>
		<xsl:variable name="putAttrCnt">
			<xsl:call-template name="getPutAttrCount"/>
		</xsl:variable>
		<xsl:if test="$putAttrCnt > 0 or child::*">
			<xsl:text> [ </xsl:text>
			<xsl:call-template name="putAttrs"/>
			<xsl:text> ]</xsl:text>
		</xsl:if>
		<xsl:text>&#10;</xsl:text>
	</xsl:template>
	<xsl:template match="dot:edgeGlobalAttr">
		<xsl:call-template name="putIndent"/>
		<xsl:text>edge [ </xsl:text>
		<xsl:call-template name="putAttrs"/>
		<xsl:text> ]</xsl:text>
		<xsl:text>&#10;</xsl:text>
	</xsl:template>
	<xsl:template match="*">
		<xsl:text>&#10;</xsl:text>
		<xsl:text>Unmatched element found : '</xsl:text>
		<xsl:value-of select="name(..)"/>
		<xsl:text>/</xsl:text>
		<xsl:value-of select="name()"/>
		<xsl:text>'</xsl:text>
	</xsl:template>
	<xsl:template match="text()"/>
	<xsl:template match="@align">
		<xsl:variable name="type" select="."/>
		<xsl:choose>
			<xsl:when test="$type = 'left'">\l</xsl:when>
			<xsl:when test="$type = 'right'">\r</xsl:when>
			<xsl:otherwise>\n</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="dot:nl">		
		<xsl:if test="( not( preceding-sibling::* ) and not( ../@align ) and ( ../@id or ../@label ) ) or ( preceding-sibling::* and not( preceding-sibling::*/@align ) )">
			<xsl:text>\n</xsl:text>
		</xsl:if>
		<xsl:value-of select="."/>
		<xsl:apply-templates select="@align"/>
	</xsl:template>
</xsl:stylesheet>
