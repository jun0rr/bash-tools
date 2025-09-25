# Overview

Bash Security & Utility Tools is a collection of command-line utilities focused on cryptographic operations and text processing. The primary tool is cipher.sh, which provides comprehensive encryption and decryption capabilities using industry-standard algorithms like AES-256-CBC and RSA encryption. The project is designed as a portable security toolkit for bash environments.

# User Preferences

Preferred communication style: Simple, everyday language.

# System Architecture

## Core Design Pattern
The project follows a modular script-based architecture where each tool is a self-contained bash script with specific security or utility functions. The main architectural decisions include:

**Script-Based Modularity**: Each tool is implemented as an independent bash script, making them portable and easy to deploy without complex installation procedures.

**OpenSSL Integration**: The cipher tool leverages OpenSSL as the cryptographic backend, ensuring industry-standard encryption practices rather than implementing custom cryptographic algorithms.

**Hybrid Encryption Model**: For large file encryption, the system automatically uses hybrid encryption (AES + RSA), where AES handles the bulk encryption and RSA encrypts the AES key, combining the speed of symmetric encryption with the security of asymmetric encryption.

**Flexible Input/Output**: Scripts support both file-based operations and stdin/stdout piping, enabling integration into shell pipelines and automation workflows.

## Security Architecture
**Multi-Algorithm Support**: The cipher tool supports both password-based encryption (AES-256-CBC) and key-based encryption (RSA), allowing users to choose the appropriate method based on their security requirements.

**Key Management**: RSA key pair generation is built into the tool, with support for password-protected private keys to add an additional security layer.

**Standard Compliance**: All cryptographic operations follow OpenSSL best practices, ensuring compatibility and security standards compliance.

# External Dependencies

## System Dependencies
- **OpenSSL**: Core cryptographic library used for all encryption, decryption, and key generation operations
- **Bash**: Shell environment for script execution
- **Standard Unix utilities**: Basic command-line tools typically available in Unix/Linux environments

## No External Services
The project is designed to be completely self-contained and does not depend on external web services, APIs, or remote databases. All operations are performed locally using system-installed cryptographic libraries.