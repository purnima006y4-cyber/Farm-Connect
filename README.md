# 🌾 FarmConnect - Direct Farmer-to-Customer Marketplace

FarmConnect is a full-featured Java backend web application designed to connect local farmers directly with consumers, eliminating middlemen and providing transparent pricing, seasonal produce search, and streamlined order tracking.

---

## 🛠️ Technology Stack (Strict MVC Architecture)

- **Language / Runtime:** Java 17 (also fully compatible with Java 8, 11, and 25)
- **Application Server:** Apache Tomcat 9.x (`javax.servlet.*`)
- **Build Tool:** Maven (Packaging: `WAR`)
- **Database:** Oracle Database 10g Express Edition (Release 10.2.0.1, 32-bit)
- **JDBC Driver:** Oracle JDBC Driver `ojdbc6:11.2.0.4` (Class: `oracle.jdbc.OracleDriver`)
- **Data Access Layer:** Plain JDBC with DAO design pattern. **No ORM, no Hibernate, no JPA, no Spring.**
- **Presentation Layer (View):** JSP (JavaServer Pages) + JSTL (`<c:out>`, `<c:forEach>`, formatting tags). JSPs contain **no SQL** and **no business logic**.
- **Controller Layer:** Java Servlets (`@WebServlet`) handling input validation, security, and Post-Redirect-Get (PRG) patterns.
- **Authentication & Security:** 
  - JWT (JSON Web Tokens) using **jjwt 0.11.x (HS256)** stored in an **HttpOnly; SameSite=Strict** cookie.
  - Password hashing using **jBCrypt with cost factor 12**.
  - SQL Injection prevention using `PreparedStatement` with parameterized placeholders (`?`).
  - Cross-Site Scripting (XSS) prevention using JSTL `<c:out>` escaping.

---

## 🏛️ Oracle 10g Express Edition (10.2) Configuration

### 1. Database Setup in SQL*Plus
Run the following commands using the Oracle 10g SQL*Plus command line utility:

```bash
# 1. Connect as SYS or SYSTEM to create the application user
sqlplus system/<your_system_password>@XE

# 2. In SQL*Plus, create user and grant standard permissions:
CREATE USER farmconnect IDENTIFIED BY farmconnect123;
GRANT CONNECT, RESOURCE, CREATE SESSION TO farmconnect;
EXIT;

# 3. Import the 10g-compatible schema:
sqlplus farmconnect/farmconnect123@XE @sql/schema.sql

# 4. Import the sample dataset with BCrypt cost-12 credentials:
sqlplus farmconnect/farmconnect123@XE @sql/sample_data.sql
```

---

### 2. Handled Oracle 10g Limitations & Refactoring Summary

| Area | Oracle 12c+ / Modern Syntax | Oracle 10.2 Compatible Refactoring |
|---|---|---|
| **Primary Keys** | `NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY` | `NUMBER PRIMARY KEY` with a dedicated sequence (`START WITH 1 INCREMENT BY 1 NOCACHE`) and a `BEFORE INSERT` trigger. |
| **Trigger Logic** | `:NEW.id := seq.NEXTVAL;` (11g) or `DEFAULT seq.NEXTVAL` (12c) | `IF :NEW.id IS NULL THEN SELECT seq.NEXTVAL INTO :NEW.id FROM dual; END IF;` |
| **Drop Scripts** | `DROP TABLE ... CASCADE CONSTRAINTS PURGE` (direct) | Wrapped in `BEGIN EXECUTE IMMEDIATE 'DROP TABLE ... CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END; /` |
| **Pagination** | `OFFSET ? ROWS FETCH NEXT ? ROWS ONLY` (12c) | Standard 10g `ROWNUM` wrapper: `SELECT * FROM (SELECT a.*, ROWNUM rn FROM (<query>) a WHERE ROWNUM <= ?) WHERE rn > ?` |
| **Limit Queries** | `FETCH FIRST ? ROWS ONLY` (12c) | Nested subquery: `SELECT * FROM (<query>) WHERE ROWNUM <= ?` |
| **Grouping/Reports** | `LISTAGG`, `PIVOT`, `CROSS APPLY` (11g/12c) | Replaced with standard ANSI SQL `GROUP BY`, `SUM`, `COUNT`, `TO_CHAR(order_date, 'YYYY-MM')`, and `TRUNC()`. |
| **Syntax Errors** | Avoided `ORA-00907: missing right parenthesis` caused by 11g/12c reserved keywords. | Completely purged all virtual columns, `DEFAULT ON NULL`, and invisible column definitions. |

---

### 3. Resolving the Port 8080 Conflict (Oracle 10g XE vs Apache Tomcat)
By default, **Oracle 10g Express Edition runs its embedded HTTP listener (Oracle XML DB / APEX) on port 8080**.
If you attempt to start Apache Tomcat on the default port `8080`, Tomcat will fail to bind with `java.net.BindException: Address already in use: bind`.

You can resolve this with either of two options:

#### Option A: Change Oracle 10g XE HTTP Port (Recommended)
Connect to Oracle 10g XE as `SYSTEM` in SQL*Plus and re-assign the embedded HTTP port to `8088` (or `0` to disable):
```sql
sqlplus system/<your_system_password>@XE
EXEC DBMS_XDB.SETHTTPPORT(8088);
COMMIT;
EXIT;
```
Now Tomcat can freely use port `8080`.

#### Option B: Change Apache Tomcat Port
Open Tomcat's `conf/server.xml` file, locate the HTTP connector, and change `port="8080"` to `port="8081"`:
```xml
<Connector port="8081" protocol="HTTP/1.1"
           connectionTimeout="20000"
           redirectPort="8443" />
```
Then access FarmConnect at `http://localhost:8081/FarmConnect`.

---

### 4. Connection Pool & Session Exhaustion in Oracle 10g XE
Oracle 10g XE has a small default session/process limit (`processes=40`).
To prevent connection leaks and `ORA-00018: maximum number of sessions exceeded`:
- Every DAO method in FarmConnect strictly manages JDBC resources using Java's `try-with-resources`.
- `Connection`, `PreparedStatement`, and `ResultSet` are deterministically closed as soon as query execution completes.

---

## ⚙️ Setup & Configuration

### 1. Configure `db.properties`
Update `src/main/resources/db.properties` with your Oracle 10g XE credentials:
```properties
# Oracle 10g XE connection URL (SID = XE)
db.url=jdbc:oracle:thin:@localhost:1521:XE
db.username=farmconnect
db.password=farmconnect123

# JWT secret (>= 32 bytes / 256 bits for HMAC-SHA256)
jwt.secret=FarmConnectSecretKey2024ChangeThis!MinLen32

# File upload storage (outside webapp for persistence & security)
upload.dir=C:/farmconnect-uploads
upload.maxSize=2097152
```

> **Security Note:** `db.properties` is ignored by Git (`.gitignore`). Use `src/main/resources/db.properties.example` as a template.

### 2. Build the WAR Package
To compile and package the application:
```powershell
.\mvn.ps1 clean package -DskipTests
```
The WAR file will be generated at `target/FarmConnect.war`.

### 3. Deploy to Tomcat 9
1. Copy `target/FarmConnect.war` into Tomcat's `webapps/` folder.
2. Start Tomcat (`bin/startup.bat`).
3. Open your browser at: **`http://localhost:8080/FarmConnect`** (or port `8081` if changed).

---

## 🔍 Database Diagnostics Endpoint (`/dbtest`)

Visit **`http://localhost:8080/FarmConnect/dbtest`** to check database status:
- **Oracle Version Banner:** Displays the version banner from `SELECT banner FROM v$version WHERE ROWNUM = 1` (e.g., `Oracle Database 10g Express Edition Release 10.2.0.1.0 - Product`).
- **Session User:** Displays the active user from `SELECT USER FROM DUAL`.
- **Schema Health (9 Tables):** Verifies the existence and displays row counts for:
  - `USERS`
  - `FARMER_PROFILE`
  - `CATEGORY`
  - `PRODUCT`
  - `ORDERS`
  - `ORDER_ITEM`
  - `CART_ITEM`
  - `REVIEW`
  - `COMPLAINT`
- **Zero Exposure:** Database passwords and stack traces are never exposed.

---

## 🔧 Oracle 10g Troubleshooting Guide

| Error | Cause | Fix |
|---|---|---|
| **ORA-01017: invalid username/password; logon denied** | Incorrect username or password in `db.properties`, or default placeholder values. | Enter valid credentials in `src/main/resources/db.properties`. Verify with `sqlplus username/password@XE`. |
| **ORA-12505: TNS listener does not currently know of SID** | Incorrect SID in JDBC URL. | Oracle 10g XE uses `XE` as its SID. Verify the URL is `jdbc:oracle:thin:@localhost:1521:XE`. |
| **ORA-12541: TNS:no listener** | Oracle TNS Listener service is not running. | Run `lsnrctl start` in an Administrator command prompt or start `OracleXETnsListener` in `services.msc`. |
| **ORA-00942: table or view does not exist** | `schema.sql` was not run under the configured database user. | Run `sqlplus username/password@XE @sql/schema.sql` and `sqlplus username/password@XE @sql/sample_data.sql`. |
| **ORA-00907: missing right parenthesis** | Occurs in Oracle 10g when 11g/12c SQL features (`OFFSET/FETCH` or `IDENTITY`) are executed. | Our 10g refactor replaced all `IDENTITY` columns with sequences and all `OFFSET/FETCH` queries with `ROWNUM` wrappers. |
| **Driver Class / Connection Errors** | Missing or incompatible JDBC driver. | FarmConnect bundles `com.oracle.database.jdbc:ojdbc6:11.2.0.4` inside `WEB-INF/lib/` which connects to Oracle 10.2 natively and runs on Java 8 through 25. |

---

## 🔑 Sample Login Credentials

Pre-configured in `sql/sample_data.sql` with BCrypt cost-12 hashes:

| Role | Email Address | Plain Password | Status / Permissions |
|---|---|---|---|
| **Admin** | `admin@farmconnect.com` | `Admin@1234` | Full management, approvals, categories, reports |
| **Farmer (Approved)** | `farmer1@farmconnect.com` | `Farmer@1234` | Ramesh Kumar (Ramesh Green Acres, Pune) - Verified ✓ |
| **Farmer (Approved)** | `farmer2@farmconnect.com` | `Farmer@1234` | Suresh Patel (Patel Organic Farms, Mumbai) - Verified ✓ |
| **Farmer (Pending)** | `farmer3@farmconnect.com` | `Farmer@1234` | Mohan Singh (Nashik) - PENDING approval |
| **Customer** | `customer1@farmconnect.com` | `Customer@1234` | Priya Sharma (Has 1 sample delivered order) |
| **Customer** | `customer2@farmconnect.com` | `Customer@1234` | Anjali Verma (Active customer) |

---

## 🗺️ Servlet URL & Endpoint Map

| HTTP Method | URL Pattern | Access Level | Description |
|---|---|---|---|
| `GET` | `/products` | Public | Marketplace homepage: search, category/season/city filter, pagination |
| `GET` | `/product?id=N` | Public | Product details, farmer profile, ratings, and customer reviews |
| `GET` / `POST` | `/login` | Public | Authentication: validates credentials, sets HttpOnly JWT cookie |
| `GET` / `POST` | `/register` | Public | User registration: Customer (ACTIVE) or Farmer (PENDING) |
| `GET` | `/logout` | Authenticated | Clears HttpOnly authentication cookie |
| `GET` | `/cart` | Customer | Views shopping cart lines and totals |
| `POST` | `/cart/add` | Customer | Adds produce to cart with stock validation check |
| `POST` | `/cart/update` | Customer | Updates line quantity (enforces available stock limit) |
| `POST` | `/cart/remove` | Customer | Removes an item from cart |
| `GET` / `POST` | `/checkout` | Customer | Order review and multi-farmer atomic checkout transaction |
| `GET` | `/customer/orders` | Customer | Customer order tracking list |
| `GET` | `/customer/order?id=N` | Customer | Detailed view of an individual owned order |
| `POST` | `/customer/orders/cancel` | Customer | Cancels an order in `PLACED` state and restores stock |
| `POST` | `/customer/review` | Customer | Submits a rating/review (only for delivered orders, 1/product) |
| `POST` | `/customer/complaint` | Customer | Raises a dispute/complaint against an owned order |
| `GET` | `/customer/complaints` | Customer | Lists customer's submitted grievances and statuses |
| `GET` | `/farmer/dashboard` | Farmer | Sales summary, total orders, and low-stock alerts (< 10 units) |
| `GET` | `/farmer/products` | Farmer | Lists farmer's own products and stock counts |
| `GET` / `POST` | `/farmer/products/add` | Farmer | Adds a new product listing with image upload |
| `GET` / `POST` | `/farmer/products/edit` | Farmer | Edits an owned product (enforces `WHERE farmer_id = ?`) |
| `POST` | `/farmer/products/delete`| Farmer | Soft-deletes / deactivates product |
| `GET` | `/farmer/orders` | Farmer | Incoming orders for the farmer's produce |
| `GET` | `/farmer/order?id=N` | Farmer | Detail view of an order with packaging items |
| `POST` | `/farmer/orders/advance`| Farmer | Progresses status: `PLACED`→`CONFIRMED`→`PACKED`→`OUT_FOR_DELIVERY`→`DELIVERED` |
| `POST` | `/farmer/orders/reject` | Farmer | Rejects order in `PLACED`/`CONFIRMED` state and restores stock |
| `GET` | `/farmer/sales` | Farmer | Monthly sales analytics aggregated using SQL `GROUP BY` |
| `GET` | `/admin/dashboard` | Admin | Metrics: farmer counts, customer counts, pending requests, total revenue |
| `GET` / `POST` | `/admin/farmers` | Admin | Approves pending farmers (`verified='Y'`, `status='ACTIVE'`) or blocks |
| `GET` / `POST` | `/admin/categories` | Admin | Full CRUD for product categories |
| `GET` | `/admin/products` | Admin | Global product inspection with pagination |
| `GET` | `/admin/orders` | Admin | Global order monitor with pagination |
| `GET` / `POST` | `/admin/complaints` | Admin | Resolves or closes customer complaints |
| `GET` / `POST` | `/admin/users` | Admin | Manages and blocks/unblocks customer accounts |
| `GET` | `/admin/reports` | Admin | Reports: monthly platform revenue and top selling products |
| `GET` | `/dbtest` | Public | Database diagnostics: Oracle banner, session user, 9-table counts |
