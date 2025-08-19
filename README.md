
# Bash Security & Utility Tools

A collection of bash scripts for encryption, obfuscation, password generation, and text formatting utilities.

## Tools Overview

### 🔐 cipher.sh - Encryption/Decryption Tool
**Purpose**: AES-256-CBC encryption/decryption with support for both password-based and RSA key-based encryption.

**Features**:
- Password-based AES-256-CBC encryption
- RSA public/private key encryption
- RSA key pair generation (openssl genpkey)
- Automatic hybrid encryption for large files (AES + RSA)
- Support for files and stdin input

**Usage**:
```bash
# Password encryption
./cipher.sh -e -p "mypassword" file.txt > encrypted.txt
./cipher.sh -d -p "mypassword" encrypted.txt

# RSA key encryption
./cipher.sh -e -k public.pem file.txt > encrypted.txt
./cipher.sh -d -k private.pem -p "keypass" encrypted.txt

# RSA key pair generation
./cipher.sh -g
# Output
[INFO] Generating RSA key pair...
  RSA key bits <1024|2048|4096> (2048):
  Private key file (pkey.pem):
  Public key file (pubkey.pem):
  Enter key password:

[INFO] Key pair generated successfully!
-rw------- 1 root root 1.7K Aug 19 12:22 ./pkey.pem
-rw------- 1 root root  451 Aug 19 12:22 ./pubkey.pem
```

### 🫥 hide.sh - Script Obfuscation Tool
**Purpose**: Obfuscate bash scripts to make them unreadable while maintaining functionality.

**Features**:
- Multi-level obfuscation with configurable iterations
- Optional AES encryption with random passwords
- Source mode for environment-modifying scripts
- Reversible obfuscation with info display

**Usage**:
```bash
# Basic obfuscation
./hide.sh script.sh

# Advanced obfuscation with encryption
./hide.sh -e -n 5 -o obfuscated.sh deploy.sh

# Unhide obfuscated content
./hide.sh -u obfuscated.sh

# Get obfuscation info
./hide.sh -i obfuscated.sh
# Output example
--------------------------------------
       Obfuscated Content Info
--------------------------------------
    Iterations ...: 5
    Encryption ...: aes-256-cbc
    Size Diff ....: > 23.0%
--------------------------------------
```

### 🔑 pwg.sh - Password Generator
**Purpose**: Generate cryptographically secure random passwords with customizable character sets.

**Features**:
- Uses `/dev/urandom` for true randomness
- Configurable character types (lowercase, uppercase, numbers, symbols)
- Proportional character distribution
- Flexible password length

**Usage**:
```bash
# Generate 12-character password (default: letters + numbers + symbols)
./pwg.sh 12             # Output: 3+pJ9.sP7{eE

# Letters and numbers only
./pwg.sh -l -u -n 16    # Output: F2bE0pL2rM1bN4kL

# Numbers only (PIN)
./pwg.sh -n 6           # Output: 258934

# High symbol density
./pwg.sh -a -s -s 20    # Output: 2%%hH4/!pQ5!:tK5..qA
```

### 📏 size.sh - File Size Converter
**Purpose**: Convert between bytes and human-readable file sizes (B, K, M, G, T).

**Features**:
- Convert bytes to human-readable format
- Convert human-readable sizes back to bytes
- Support for decimal values
- File size detection

**Usage**:
```bash
./size.sh 1536          # Output: 1.50K
./size.sh 2.5M          # Output: 2621440
./size.sh myfile.txt    # Output: file size in human format
```

### 📝 spad.sh - Text Padding Utilities
**Purpose**: Text alignment and padding functions for formatted output.

**Features**:
- Center text alignment with padding
- Left/right text alignment
- Text justification with character distribution
- Configurable padding characters

**Functions**:
- `padCenter()` - Center align text
- `padLeft()` - Right align text
- `padRight()` - Left align text  
- `justify()` - Justify text with even spacing

## Security Features

### Encryption Standards
- **AES-256-CBC**: Industry-standard symmetric encryption
- **RSA**: Asymmetric encryption with key pair support
- **PBKDF2**: Key derivation for password-based encryption
- **Salt**: Random salt generation for enhanced security

### Obfuscation Techniques
- **Base64 encoding**: Data transformation
- **Gzip compression**: Size reduction and obfuscation
- **Multi-layer wrapping**: Configurable iteration depth
- **UUID-based temporary files**: Secure temporary storage

### Random Generation
- **True randomness**: Uses `/dev/urandom` instead of pseudo-random
- **Cryptographic security**: Suitable for password generation
- **Uniform distribution**: Balanced character selection

## Dependencies

- **OpenSSL**: Required for encryption operations
- **Base64**: For encoding/decoding operations
- **Gzip**: For compression in obfuscation
- **UUID tools**: For temporary file generation

## Version Information

- **cipher.sh**: v202410.02
- **hide.sh**: v202411.06  
- **pwg.sh**: v202504.01

## Use Cases

### Development Security
- Protect deployment scripts before sharing
- Obfuscate configuration scripts
- Generate secure API keys and passwords

### Data Protection
- Encrypt sensitive files before storage/transfer
- Create tamper-resistant script distribution
- Secure inter-team script sharing

### System Administration
- Generate secure passwords for user accounts
- Protect automation scripts
- Create encrypted backup scripts

## Security Considerations

- Always use strong passwords for encryption
- Store RSA private keys securely
- Regularly rotate encryption keys
- Verify script integrity after obfuscation
- Use appropriate iteration counts for obfuscation based on security needs

## Author

**Juno Roesler - juno.rr@gmail.com**

## License

These tools are provided as-is for educational and practical use. Please ensure compliance with your organization's security policies when using encryption tools.
