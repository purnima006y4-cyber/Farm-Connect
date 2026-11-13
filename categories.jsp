<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<jsp:include page="/jsp/common/header.jsp">
    <jsp:param name="title" value="Produce Categories - FarmConnect Admin" />
</jsp:include>

<div class="fc-container" style="padding-top: 1.5rem; padding-bottom: 3rem;">
    <!-- Breadcrumbs -->
    <nav class="fc-breadcrumb" aria-label="Breadcrumb">
        <ol>
            <li><a href="${pageContext.request.contextPath}/products">Home</a></li>
            <li><a href="${pageContext.request.contextPath}/admin/dashboard">Admin Overview</a></li>
            <li aria-current="page">Categories</li>
        </ol>
    </nav>

    <div class="fc-page-header">
        <div>
            <h1 class="fc-page-title">Manage Produce Categories</h1>
            <p class="fc-page-subtitle">Define taxonomy and catalog groupings for farm harvests and produce listings.</p>
        </div>
    </div>

    <div style="display: grid; grid-template-columns: 1fr 2fr; gap: 2rem; align-items: start;">
        <!-- Add Category Form -->
        <div class="fc-card" style="padding: 1.5rem;">
            <h3 style="font-size: 1.125rem; font-weight: 700; margin-bottom: 1.25rem; color: var(--color-neutral-900); border-bottom: 1px solid var(--color-neutral-200); padding-bottom: 0.75rem;">
                Add New Category
            </h3>
            <form action="${pageContext.request.contextPath}/admin/categories" method="post" id="addCategoryForm">
                <input type="hidden" name="action" value="add">

                <div class="fc-form-group">
                    <label for="catName" class="fc-label">Category Name <span style="color: var(--color-danger-600);">*</span></label>
                    <input type="text" id="catName" name="name" class="fc-input" required placeholder="e.g. Exotic Herbs">
                </div>

                <div class="fc-form-group">
                    <label for="catDesc" class="fc-label">Description (Optional)</label>
                    <textarea id="catDesc" name="description" class="fc-textarea" rows="3" placeholder="Briefly describe what produce belongs here..."></textarea>
                </div>

                <button type="submit" class="fc-btn fc-btn-primary" style="width: 100%; padding: 0.75rem; margin-top: 0.5rem;">
                    Create Category
                </button>
            </form>
        </div>

        <!-- Categories Table -->
        <div class="fc-card" style="padding: 0; overflow: hidden;">
            <div style="padding: 1.25rem 1.5rem; border-bottom: 1px solid var(--color-neutral-200); background: var(--color-neutral-50);">
                <h3 style="font-size: 1.125rem; font-weight: 700; color: var(--color-neutral-900); margin: 0;">Active Categories</h3>
            </div>

            <c:choose>
                <c:when test="${empty categories}">
                    <div style="padding: 3rem 1.5rem; text-align: center; color: var(--color-neutral-500);">
                        <p style="margin: 0;">No produce categories defined yet.</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="fc-table-responsive">
                        <table class="fc-table">
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Category Title</th>
                                    <th>Description</th>
                                    <th style="text-align: right;">Action</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="c" items="${categories}">
                                    <tr>
                                        <td>
                                            <span style="font-family: monospace; font-weight: 700; color: var(--color-neutral-600);">#<c:out value="${c.categoryId}"/></span>
                                        </td>
                                        <td>
                                            <strong style="color: var(--color-primary-800);"><c:out value="${c.name}"/></strong>
                                        </td>
                                        <td style="color: var(--color-neutral-600); font-size: 0.875rem; max-width: 320px;">
                                            <c:out value="${c.description}"/>
                                        </td>
                                        <td style="text-align: right;">
                                            <form action="${pageContext.request.contextPath}/admin/categories" method="post" style="display: inline; margin: 0;" onsubmit="return confirm('Delete category &quot;${c.name}&quot;? Only categories with zero attached products can be removed.');">
                                                <input type="hidden" name="action" value="delete">
                                                <input type="hidden" name="categoryId" value="${c.categoryId}">
                                                <button type="submit" class="fc-btn fc-btn-sm fc-btn-danger">
                                                    Delete
                                                </button>
                                            </form>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</div>

<jsp:include page="/jsp/common/footer.jsp" />
