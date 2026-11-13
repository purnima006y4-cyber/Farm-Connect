<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<jsp:include page="/jsp/common/header.jsp">
    <jsp:param name="title" value="Edit Produce - FarmConnect" />
</jsp:include>

<div class="fc-container" style="padding-top: 1.5rem; padding-bottom: 3rem; max-width: 760px;">
    <!-- Breadcrumbs -->
    <nav class="fc-breadcrumb" aria-label="Breadcrumb">
        <ol>
            <li><a href="${pageContext.request.contextPath}/products">Home</a></li>
            <li><a href="${pageContext.request.contextPath}/farmer/products">My Produce Listings</a></li>
            <li aria-current="page">Edit #<c:out value="${product.productId}"/></li>
        </ol>
    </nav>

    <div class="fc-page-header" style="margin-bottom: 1.5rem;">
        <div>
            <h1 class="fc-page-title">Edit Produce Details</h1>
            <p class="fc-page-subtitle">Update pricing, available stock inventory, harvest information, or produce images.</p>
        </div>
    </div>

    <div class="fc-card" style="padding: 2rem;">
        <form action="${pageContext.request.contextPath}/farmer/products/edit" method="post" enctype="multipart/form-data" novalidate id="editProductForm">
            <!-- Hidden inputs preserving product identification -->
            <input type="hidden" name="productId" value="${product.productId}">
            <input type="hidden" name="existingImage" value="<c:out value='${product.imagePath}'/>">

            <!-- Product Name -->
            <div class="fc-form-group">
                <label for="name" class="fc-label">Crop / Product Name <span style="color: var(--color-danger-600);">*</span></label>
                <input type="text" id="name" name="name" class="fc-input" value="<c:out value='${product.name}'/>" required>
            </div>

            <!-- Category -->
            <div class="fc-form-group">
                <label for="categoryId" class="fc-label">Category <span style="color: var(--color-danger-600);">*</span></label>
                <select id="categoryId" name="categoryId" class="fc-select" required>
                    <c:forEach var="cat" items="${categories}">
                        <option value="${cat.categoryId}" <c:if test="${cat.categoryId eq product.categoryId}">selected</c:if>>
                            <c:out value="${cat.name}"/>
                        </option>
                    </c:forEach>
                </select>
            </div>

            <!-- Price and Quantity -->
            <div class="fc-grid-2">
                <div class="fc-form-group">
                    <label for="price" class="fc-label">Price per Unit (&#8377;) <span style="color: var(--color-danger-600);">*</span></label>
                    <div style="position: relative;">
                        <span style="position: absolute; left: 0.875rem; top: 50%; transform: translateY(-50%); color: var(--color-neutral-500); font-weight: 600;">&#8377;</span>
                        <input type="number" id="price" name="price" class="fc-input" style="padding-left: 2rem;" value="${product.price}" step="0.01" min="0.01" required>
                    </div>
                </div>

                <div class="fc-form-group">
                    <label for="quantity" class="fc-label">Current Stock / Quantity <span style="color: var(--color-danger-600);">*</span></label>
                    <input type="number" id="quantity" name="quantity" class="fc-input" value="${product.quantity}" min="0" required>
                    <c:if test="${product.quantity lt 10}">
                        <span class="fc-hint" style="color: var(--color-danger-600); font-weight: 600;">⚠️ Low stock warning active on this listing</span>
                    </c:if>
                </div>
            </div>

            <!-- Harvest Date & Season -->
            <div class="fc-grid-2">
                <div class="fc-form-group">
                    <label for="harvestDate" class="fc-label">Harvest Date</label>
                    <input type="date" id="harvestDate" name="harvestDate" class="fc-input" value="${product.harvestDate}">
                </div>

                <div class="fc-form-group">
                    <label for="season" class="fc-label">Season Suitability</label>
                    <select id="season" name="season" class="fc-select">
                        <option value="ALL" <c:if test="${product.season eq 'ALL'}">selected</c:if>>All Seasons</option>
                        <option value="SUMMER" <c:if test="${product.season eq 'SUMMER'}">selected</c:if>>Summer</option>
                        <option value="MONSOON" <c:if test="${product.season eq 'MONSOON'}">selected</c:if>>Monsoon</option>
                        <option value="WINTER" <c:if test="${product.season eq 'WINTER'}">selected</c:if>>Winter</option>
                    </select>
                </div>
            </div>

            <!-- Current Image & Replacement -->
            <div class="fc-form-group" style="margin-top: 0.5rem;">
                <label for="image" class="fc-label">Produce Photo</label>
                <c:if test="${not empty product.imagePath}">
                    <div style="display: flex; align-items: center; gap: 1rem; margin-bottom: 0.75rem; background: var(--color-neutral-50); padding: 0.75rem; border-radius: var(--radius-sm); border: 1px solid var(--color-neutral-200);">
                        <img src="${pageContext.request.contextPath}/images/<c:out value='${product.imagePath}'/>" alt="Current Photo" style="width: 54px; height: 54px; object-fit: cover; border-radius: var(--radius-sm); border: 1px solid var(--color-neutral-300);">
                        <div>
                            <span style="display: block; font-size: 0.875rem; font-weight: 600; color: var(--color-neutral-800);">Active Photo Attached</span>
                            <span style="font-size: 0.75rem; color: var(--color-neutral-500);"><c:out value="${product.imagePath}"/></span>
                        </div>
                    </div>
                </c:if>
                <div style="border: 2px dashed var(--color-neutral-300); border-radius: var(--radius-md); padding: 1.25rem; text-align: center; background: var(--color-neutral-50);">
                    <input type="file" id="image" name="image" accept="image/jpeg,image/png" style="font-size: 0.875rem; color: var(--color-neutral-600);">
                    <div style="font-size: 0.75rem; color: var(--color-neutral-500); margin-top: 0.35rem;">
                        Select a new file (JPG, PNG under 2 MB) to replace current photo. Leave empty to keep existing image.
                    </div>
                </div>
            </div>

            <!-- Form Actions -->
            <div style="display: flex; gap: 1rem; margin-top: 2rem; border-top: 1px solid var(--color-neutral-200); padding-top: 1.5rem;">
                <button type="submit" class="fc-btn fc-btn-primary" style="flex: 1; padding: 0.875rem;">
                    Save Listing Changes
                </button>
                <a href="${pageContext.request.contextPath}/farmer/products" class="fc-btn fc-btn-outline" style="flex: 0.5; padding: 0.875rem; text-align: center;">
                    Cancel
                </a>
            </div>
        </form>
    </div>
</div>

<jsp:include page="/jsp/common/footer.jsp" />
