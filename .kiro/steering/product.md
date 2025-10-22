# HK IMS - Hong Kong Inventory Management System

A PostgreSQL-based inventory management system with SQLC-generated Go code for database operations.

## Core Features
- Multi-organization and multi-branch support
- User authentication and role-based access control
- Product inventory management with decimal precision
- Purchase and sales tracking with profit calculations
- Partner/supplier management
- Activity logging and audit trails

## Business Domain
- Organizations contain multiple branches
- Users belong to organizations with specific branch access
- Products are branch-specific with unique names across the system
- Financial operations use decimal precision for accuracy
- Role hierarchy: admin > adminReadOnly > branchManager > branchReadOnly > sales