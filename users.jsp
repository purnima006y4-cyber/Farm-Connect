<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<jsp:include page="/jsp/common/header.jsp">
    <jsp:param name="title" value="Manage Customers - FarmConnect Admin" />
</jsp:include>

<div class="fc-container" style="padding-top: 1.5rem; padding-bottom: 3rem;">
    <!-- Breadcrumbs -->
    <nav class="fc-breadcrumb" aria-label="Breadcrumb">
        <ol>
            <li><a href="${pageContext.request.contextPath}/products">Home</a></li>
            <li><a href="${pageContext.request.contextPath}/admin/dashboard">Admin Overview</a></li>
            <li aria-current="page">Customer Accounts</li>
        </ol>
    </nav>

    <div class="fc-page-header">
        <div>
            <h1 class="fc-page-title">Customer User Accounts</h1>
            <p class="fc-page-subtitle">View registered consumer profiles and moderate user access privileges.</p>
        </div>
    </div>

    <c:choose>
        <c:when test="${empty customers}">
            <div class="fc-empty-state">
                <div class="fc-empty-icon">
                    <svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75">
                        <path d="M17 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 00-3-3.87"/><path d="M16 3.13a4 4 0 010 7.75"/>
                    </svg>
                </div>
                <h3 class="fc-empty-title">No customer accounts registered yet</h3>
                <p class="fc-empty-desc">New consumer registrations will display here once customers sign up.</p>
            </div>
        </c:when>
        <c:otherwise>
            <div class="fc-card" style="padding: 0; overflow: hidden;">
                <div class="fc-table-responsive">
                    <table class="fc-table">
                        <thead>
                            <tr>
                                <th>Customer Name</th>
                                <th>Email Address</th>
                                <th>Phone Number</th>
                                <th>Account Status</th>
                                <th style="text-align: right;">Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="u" items="${customers}">
                                <tr>
                                    <td>
                                        <div style="font-weight: 700; color: var(--color-neutral-900);">
                                            <c:out value="${u.name}"/>
                                        </div>
                                        <div style="font-size: 0.8125rem; color: var(--color-neutral-500); font-family: monospace;">
                                            UID: #<c:out value="${u.userId}"/>
                                        </div>
                                    </td>
                                    <td style="color: var(--color-neutral-700);">
                                        <c:out value="${u.email}"/>
                                    </td>
                                    <td style="color: var(--color-neutral-600);">
                                        <c:out value="${u.phone}"/>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${u.status eq 'ACTIVE'}">
                                                <span class="fc-badge fc-badge-success">Active</span>
                                            </c:when>
                                            <c:when test="${u.status eq 'BLOCKED'}">
                                                <span class="fc-badge fc-badge-danger">Blocked</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="fc-badge fc-badge-neutral"><c:out value="${u.status}"/></span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td style="text-align: right;">
                                        <c:choose>
                                            <c:when test="${u.status eq 'ACTIVE'}">
                                                <form action="${pageContext.request.contextPath}/admin/users" method="post" style="display: inline; margin: 0;" onsubmit="return confirm('Block customer ${u.name}? They will be unable to log in or place orders.');">
                                                    <input type="hidden" name="userId" value="${u.userId}">
                                                    <input type="hidden" name="action" value="block">
                                                    <button type="submit" class="fc-btn fc-btn-sm fc-btn-danger">
                                                        Block Customer
                                                    </button>
                                                </form>
                                            </c:when>
                                            <c:otherwise>
                                                <form action="${pageContext.request.contextPath}/admin/users" method="post" style="display: inline; margin: 0;">
                                                    <input type="hidden" name="userId" value="${u.userId}">
                                                    <input type="hidden" name="action" value="unblock">
                                                    <button type="submit" class="fc-btn fc-btn-sm fc-btn-primary">
                                                        Unblock Account
                                                    </button>
                                                </form>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<jsp:include page="/jsp/common/footer.jsp" />
