<%
/**
 * Copyright (c) 2000-2009 Liferay, Inc. All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
%>

<%@ include file="/html/portlet/journal/init.jsp" %>

<%
String langType = ParamUtil.getString(request, "langType");

String editorType = ParamUtil.getString(request, "editorType");

if (Validator.isNotNull(editorType)) {
	portalPrefs.setValue(PortletKeys.JOURNAL, "editor-type", editorType);
}
else {
	editorType = portalPrefs.getValue(PortletKeys.JOURNAL, "editor-type", "html");
}

boolean useEditorCodepress = editorType.equals("codepress");

String defaultContent = ContentUtil.get(PropsUtil.get(PropsKeys.JOURNAL_TEMPLATE_LANGUAGE_CONTENT, new Filter(langType)));
%>

<script type="text/javascript">
	function <portlet:namespace />getEditorContent() {
		var xslContent = AUI().one('input[name=<portlet:namespace />xslContent]');

		if (xslContent) {
			var content = decodeURIComponent(xslContent.val());
		}

		if (!content) {
			content = "<%= UnicodeFormatter.toString(defaultContent) %>";
		}

		return content;
	}

	function <portlet:namespace />updateEditorType() {

		<%
		String newEditorType = "codepress";

		if (useEditorCodepress) {
			newEditorType = "html";
		}
		%>

		var editorForm = AUI().one(document.<portlet:namespace />editorForm);

		if (editorForm) {
			var popup = editorForm.ancestor('.aui-widget-bd');

			if (popup) {
				popup = popup.getDOM();
			}
		}

		Liferay.Util.switchEditor(
			{
				url: '<portlet:renderURL windowState="<%= LiferayWindowState.EXCLUSIVE.toString() %>"><portlet:param name="struts_action" value="/journal/edit_template_xsl" /><portlet:param name="langType" value="<%= langType %>" /><portlet:param name="editorType" value="<%= newEditorType %>" /></portlet:renderURL>',
				textarea: '<portlet:namespace />xslContent',
				popup: popup
			}
		);
	}

	function <portlet:namespace />updateTemplateXsl() {
		var xslContent = AUI().one('input[name=<portlet:namespace />xslContent]');
		var content = '';

		<c:choose>
			<c:when test="<%= useEditorCodepress %>">
				if (xslContent) {
					content = encodeURIComponent(<portlet:namespace />xslContent.getCode());
				}
			</c:when>
			<c:otherwise>
				content = encodeURIComponent(document.<portlet:namespace />editorForm.<portlet:namespace />xslContent.value);
			</c:otherwise>
		</c:choose>

		xslContent.attr('value', content);

		AUI().DialogManager.closeByChild(document.<portlet:namespace />editorForm);
	}
</script>

<aui:form method="post" name="editorForm">
	<aui:fieldset>
		<aui:select name="editorType" onChange='<%= renderResponse.getNamespace() + "updateEditorType();" %>'>
			<aui:option label="plain" value="1" />
			<aui:option label="rich" selected="<%= useEditorCodepress %>" value="0" />
		</aui:select>
	</aui:fieldset>

	<c:choose>
		<c:when test="<%= useEditorCodepress %>">
			<aui:input name="xslContent" type="textarea" wrap="off" />
		</c:when>
		<c:otherwise>
			<aui:input name="xslContent" onKeyDown="Liferay.Util.checkTab(this); Liferay.Util.disableEsc();" type="textarea" wrap="off" />
		</c:otherwise>
	</c:choose>

	<aui:button-row>
		<aui:button onClick='<%= renderResponse.getNamespace() + "updateTemplateXsl();" %>' type="button" value="update" />

		<c:if test="<%= !useEditorCodepress %>">
			<aui:button onClick='<%= "Liferay.Util.selectAndCopy(document." + renderResponse.getNamespace() + "editorForm." + renderResponse.getNamespace() + "xslContent);" %>' type="button" value="select-and-copy" />
		</c:if>

		<aui:button onClick="AUI().DialogManager.closeByChild(this);" type="button" value="cancel" />
	</aui:button-row>
</aui:form>

<script type="text/javascript">
	AUI().ready(
		function() {
			document.<portlet:namespace />editorForm.<portlet:namespace />xslContent.value = <portlet:namespace />getEditorContent();

			Liferay.Util.resizeTextarea('<portlet:namespace />xslContent', <%= useEditorCodepress %>, true);
		}
	);
</script>

<c:if test="<%= useEditorCodepress %>">
	<script src="<%= themeDisplay.getPathContext() %>/html/js/editor/codepress/codepress.js" type="text/javascript"></script>
</c:if>