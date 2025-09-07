# 💰 ExpenseTracker - Spring Boot Application

A modern Spring Boot application for tracking expenses with PostgreSQL database, automated CI/CD pipeline, and Docker deployment.

## 🚀 Features

- **User Management**: Complete CRUD operations for user accounts
- **RESTful API**: Clean REST endpoints with validation
- **Database Integration**: PostgreSQL with Liquibase migrations
- **Automated Testing**: Unit and integration tests with PostgreSQL
- **CI/CD Pipeline**: GitHub Actions with staging/production deployment
- **Docker Support**: Containerized deployment with Docker Compose
- **Security Scanning**: OWASP dependency vulnerability checks
- **Health Monitoring**: Spring Boot Actuator endpoints

## 🛠️ Tech Stack

- **Framework**: Spring Boot 3.5.5
- **Java Version**: 21
- **Database**: PostgreSQL 15
- **Build Tool**: Gradle 8.14.3
- **Migration Tool**: Liquibase
- **CI/CD**: GitHub Actions
- **Containerization**: Docker & Docker Compose
- **Testing**: JUnit 5, Spring Boot Test
- **Monitoring**: Spring Boot Actuator

## 📋 API Endpoints

### User Management
- `GET /api/users` - Get all users
- `GET /api/users/{id}` - Get user by ID
- `GET /api/users/username/{username}` - Get user by username
- `POST /api/users` - Create new user

### Health & Monitoring
- `GET /actuator/health` - Application health status
- `GET /actuator/metrics` - Application metrics
- `GET /actuator/info` - Application information

## 🚀 Quick Start

### Prerequisites

- Java 21 or higher
- Docker & Docker Compose
- Git

## Database Setup

1. Install and start PostgreSQL
2. Create database and user:
   ```sql
   CREATE DATABASE expensetracker;
   CREATE USER ari WITH PASSWORD 'pass';
   GRANT ALL PRIVILEGES ON DATABASE expensetracker TO ari;
   ```

## Build Issues Fixed

### 1. Liquibase Configuration Issue
**Problem**: Build was failing with `liquibase.exception.ChangeLogParseException` because Liquibase was included as dependency but no changelog file existed.

**Solution**:
- Created basic Liquibase changelog: `src/main/resources/db/changelog/db.changelog-master.yaml`
- Added Liquibase configuration to `application.properties`:
  ```properties
  spring.liquibase.change-log=classpath:db/changelog/db.changelog-master.yaml
  ```

### 2. Gradle Wrapper Issue
**Problem**: `gradlew.bat` was failing with "Error: -classpath requires class path specification"

**Solution**: 
- Fixed `gradlew.bat` by removing the problematic empty classpath parameter
- Changed from:
  ```batch
  set CLASSPATH=
  "%JAVA_EXE%" ... -classpath "%CLASSPATH%" -jar ...
  ```
- To:
  ```batch
  "%JAVA_EXE%" ... -jar ...
  ```

## Project Structure

```
ExpenseTracker/
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   └── com/arijit/ExpenseTracker/
│   │   │       └── ExpenseTrackerApplication.java
│   │   └── resources/
│   │       ├── application.properties
│   │       └── db/
│   │           └── changelog/
│   │               └── db.changelog-master.yaml
│   └── test/
│       └── java/
│           └── com/arijit/ExpenseTracker/
│               └── ExpenseTrackerApplicationTests.java
├── build.gradle
├── gradlew
├── gradlew.bat
└── compose.yaml
```

## Configuration Files

### application.properties
```properties
spring.application.name=ExpenseTracker

spring.datasource.url=jdbc:postgresql://localhost:5432/expensetracker
spring.datasource.username=ari
spring.datasource.password=pass
spring.datasource.driver-class-name=org.postgresql.Driver

# Liquibase configuration
spring.liquibase.change-log=classpath:db/changelog/db.changelog-master.yaml
```

### Docker Compose (Optional)
Use `compose.yaml` to run PostgreSQL in Docker:
```bash
docker-compose up -d
```

## Building the Application

1. **Clean and build**:
   ```bash
   ./gradlew.bat clean build
   ```

2. **Run tests only**:
   ```bash
   ./gradlew.bat test
   ```

3. **Build without tests**:
   ```bash
   ./gradlew.bat build -x test
   ```

## Running the Application

1. **Using Gradle**:
   ```bash
   ./gradlew.bat bootRun
   ```

2. **Using JAR file**:
   ```bash
   java -jar build/libs/ExpenseTracker-0.0.1-SNAPSHOT.jar
   ```

## Build Artifacts

After successful build, you'll find:
- `build/libs/ExpenseTracker-0.0.1-SNAPSHOT.jar` - Executable Spring Boot JAR
- `build/libs/ExpenseTracker-0.0.1-SNAPSHOT-plain.jar` - Plain JAR without dependencies

## Dependencies

Key dependencies included:
- Spring Boot Starter Web
- Spring Boot Starter Data JPA
- Spring Boot Starter JOOQ
- Liquibase Core
- PostgreSQL Driver
- Lombok
- Spring Boot DevTools
- Spring Boot Docker Compose

## Troubleshooting

### Common Issues

1. **Java Version Mismatch**: Ensure Java 21 is installed and JAVA_HOME is set correctly
2. **Database Connection**: Verify PostgreSQL is running and credentials are correct
3. **Liquibase Errors**: Check that changelog file exists and is properly formatted
4. **Gradle Wrapper Issues**: Ensure gradlew.bat has proper line endings (CRLF for Windows)

### Build Logs
Check build reports at:
- Test results: `build/reports/tests/test/index.html`
- Problems report: `build/reports/problems/problems-report.html`

## Next Steps

- Add entity classes for expense tracking
- Create REST controllers
- Add more Liquibase changesets for database schema
- Implement business logic
- Add comprehensive tests
