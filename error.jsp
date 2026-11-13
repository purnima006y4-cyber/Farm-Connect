<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<jsp:include page="/jsp/common/header.jsp">
    <jsp:param name="title" value="Page Notice - FarmConnect" />
</jsp:include>
<%
Throwable ex = (Throwable) request.getAttribute("javax.servlet.error.exception");
if (ex == null) ex = (Throwable) request.getAttribute("exception");
if (ex != null) {
    application.log("FarmConnect unhandled exception", ex);
}
%>

<div class="fc-container" style="padding-top: var(--space-12); padding-bottom: var(--space-16); max-width: 620px;">
    <div class="fc-card" style="text-align: center; padding: var(--space-10) var(--space-8);">
        <div style="width: 72px; height: 72px; border-radius: 50%; background: var(--color-primary-light); color: var(--color-primary); display: flex; align-items: center; justify-content: center; margin: 0 auto var(--space-6) auto;">
            <svg width="36" height="36" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75">
                <path d="M12 2a10 10 0 0 1 10 10c0 5.523-4.477 10-10 10S2 17.523 2 12c0-2.5 1-4.5 2-6"/>
                <path d="M12 2c0 4 2 8 8 10"/>
                <path d="M7 17l5-5"/>
            </svg>
        </div>

        <h1 style="font-family: var(--font-display); font-size: 1.85rem; color: var(--color-text); margin-bottom: var(--space-2);">
            Unexpected Interruption
        </h1>
        <p style="color: var(--color-text-muted); font-size: 0.95rem; line-height: 1.6; margin-bottom: var(--space-8);">
            We encountered a slight hiccup while processing your request. Rest assured, your account details and orders remain safe in the harvest registry.
        </p>

        <div style="display: flex; gap: var(--space-3); justify-content: center; flex-wrap: wrap;">
            <a href="${pageContext.request.contextPath}/products" class="btn btn-primary btn-lg">
                Return to Marketplace 🛒
            </a>
            <a href="javascript:history.back()" class="btn btn-secondary btn-lg">
                &larr; Go Back
            </a>
        </div>
    </div>
</div>

<jsp:include page="/jsp/common/footer.jsp" />
