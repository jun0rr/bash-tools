
# Bash Security & Utility Tools

A collection of bash scripts for encryption, obfuscation, password generation, and text formatting utilities.

## Tools Overview

### 🔐 cipher.sh - Encryption/Decryption Tool
**Purpose**: AES-256-CBC encryption/decryption with support for both password-based and RSA key-based encryption.

**Features**:
- Based on OpenSSL best pratices
- Password-based AES-256-CBC encryption
- Automatic hybrid encryption for large files (AES + RSA)
- RSA public/private key encryption
- RSA key pair generation (openssl genpkey)
- Support for files and stdin input

**Usage**:
```bash
./cipher.sh -h
# Output:
----------------------------------------
 Cipher.sh - Encryption/Decryption tool
         RSA/AES/CBC Algorithms
           Version: 202410.05
          Author: Juno Roesler
----------------------------------------
 Usage: cipher.sh [-h | -v | -g] | (-e <-k | -p <pass>> | -d [-k] -p <pass>) [file]
 Options:
   -d/--dec ...: Decrypt file or stdin. Requires -p <pass>, optionally -k.
   -e/--enc ...: Encrypt file or stdin. Requires either -k or -p <pass>.
   -g/--gen ...: Generate RSA key pair. Cannot be combined with other options.
   -h/--help ..: Print this help text.
   -k/--key ...: Specify RSA private/public key file.
   -p/--pass ..: Specify password for encryption/decryption.
   -v/--version: Print Cipher version

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
- Optional AES encryption with random, custom or environment file passwords
- Source mode for environment-modifying scripts
- Reversible obfuscation with info display

**Usage**:
```bash
# Show help
./hide.sh -h
------------------------------------
  HideSH - Bash Script Obfuscation
         Version: 202411.08
        Author: Juno Roesler
------------------------------------
 Usage: hide.sh [-h] [-o <file>] (-u | -i | [-n] [-e [-E | -p]] [-s]) [input]
   When [input] is not provided, content is readed from stdin
 Options:
   -e/--encrypt ......: Encrypt input script with random password
   -E/--env <var=file>: Use an environment file with var=password for encryption
   -h/--help .........: Print this help text
   -i/--info .........: Print info of an obfuscated cotent
   -n/--num ..........: Number of iterations (default=1)
   -o/--out ..........: Output file (default stdout)
   -p/--pass <pwd>....: Use a custom password for encryption
   -s/--src ..........: Call 'source' on script instead of executing it
   -u/--unhide .......: Unhide obfuscated content
   -v/--version ......: Print version

# Basic obfuscation
./hide.sh script.sh

# Advanced obfuscation with encryption through embedded 256 bits password
./hide.sh -n 5 -e -o obfuscated.sh deploy.sh

# Encryption with custom password, it will be prompted at runtime (manual execution)
./hide.sh -n 5 -e -p 'mypassword' -o obfuscated.sh deploy.sh

# Encryption with environment file password
./hide.sh -n 5 -e -E SECRET=/secure/.env -o obfuscated.sh deploy.sh

# Unhide obfuscated content
./hide.sh -u obfuscated.sh

# Get obfuscation info
./hide.sh -i obfuscated.sh
# Output example
------------------------------------
      Obfuscated Content Info
------------------------------------
    Iterations ...: 5
    Encryption ...: aes-256-cbc
    Size Diff ....: > 11.9%
------------------------------------
```

## Hide.sh Encryption Security Analysis

The hide.sh tool offers three distinct encryption approaches, each with different security profiles and operational characteristics. Choose the approach that best fits your security requirements and operational constraints.

### Encryption Approaches Comparison

| Consideration | Auto-Generated | Custom Password | Environment File |
|---------------|----------------|-----------------|------------------|
| **🚀 Deployment Complexity** | ⭐⭐⭐⭐⭐ Trivial | ⭐⭐⭐⭐ Simple | ⭐⭐⭐ Moderate |
| **👤 User Experience** | ⭐⭐⭐⭐⭐ Seamless | ⭐⭐⭐ Interactive prompt | ⭐⭐⭐⭐ Seamless (if env setup) |
| **❌ Error Resistance** | ⭐⭐⭐⭐⭐ No user error | ⭐⭐ Typos possible | ⭐⭐⭐⭐ Automated |
| **📈 Scalability** | ⭐⭐⭐⭐⭐ Perfect | ⭐⭐ Manual intervention | ⭐⭐⭐⭐⭐ Perfect |
| **🤖 Automation Friendly** | ⭐⭐⭐⭐⭐ Fully automated | ⭐ Cannot run unattended | ⭐⭐⭐⭐⭐ Fully automated |
| **🔄 CI/CD Integration** | ⭐⭐⭐⭐⭐ Perfect for pipelines | ⭐ Blocks automation | ⭐⭐⭐⭐⭐ Perfect for pipelines |
| **📦 Distribution Simplicity** | ⭐⭐⭐⭐⭐ Single file | ⭐⭐⭐⭐⭐ Single file | ⭐⭐⭐ Two files required |
| **🔧 Maintenance Overhead** | ⭐⭐⭐⭐⭐ Zero maintenance | ⭐⭐⭐⭐ Password management | ⭐⭐⭐ Environment file management |
| **🛡️ Static Analysis Resistance** | ⭐⭐ Password extractable | ⭐⭐⭐⭐⭐ No password stored | ⭐⭐⭐⭐⭐ No password in script |
| **🔐 Key Separation Security** | ⭐ No separation | ⭐⭐⭐⭐⭐ Interactive separation | ⭐⭐⭐⭐⭐ File separation |
| **🎯 Targeted Attack Resistance** | ⭐⭐ Single point of failure | ⭐⭐⭐⭐ Requires password knowledge | ⭐⭐⭐⭐ Requires file access |
| **🔍 Social Engineering Resistance** | ⭐⭐⭐⭐⭐ Nothing to engineer | ⭐⭐ Password can be shared | ⭐⭐⭐ Environment access |
| **👀 Shoulder Surfing Resistance** | ⭐⭐⭐⭐⭐ No typing required | ⭐⭐ Password visible during entry | ⭐⭐⭐⭐⭐ No typing required |
| **🔄 Credential Rotation** | ⭐ Requires re-obfuscation | ⭐⭐⭐⭐⭐ Change password anytime | ⭐⭐⭐⭐⭐ Update env file |
| **📋 Audit & Compliance** | ⭐⭐ Poor key management | ⭐⭐⭐ Interactive logging | ⭐⭐⭐⭐⭐ Excellent separation |
| **🧠 Memory Security** | ⭐⭐ Password always resident | ⭐⭐⭐⭐ Runtime only | ⭐⭐⭐⭐ Runtime only |
| **💪 Cryptographic Strength** | ⭐⭐⭐⭐⭐ 256-bit entropy | ⭐⭐⭐ Depends on user choice | ⭐⭐⭐⭐ Depends on env management |

### Security Tiers

#### 🥇 Tier 1: High Security
- **Custom Password**: Interactive authentication barrier requiring password knowledge
- **Environment File**: Cryptographic key separation with file-based security

#### 🥈 Tier 2: Moderate Security  
- **Auto-Generated**: Strong cryptography but vulnerable to static analysis

### Recommended Use Cases

| Use Case | Recommended Approach | Rationale |
|----------|---------------------|-----------|
| **Production Deployments** | Environment File | Best security + automation compatibility |
| **Development Scripts** | Auto-Generated | Simplicity + adequate security |
| **Administrative Tools** | Custom Password | Human verification + audit trail |
| **CI/CD Pipelines** | Environment File | Automation + credential separation |
| **Quick Prototyping** | Auto-Generated | Zero configuration overhead |
| **Team Collaboration** | Custom Password | Shared knowledge authentication |
| **Compliance Environments** | Environment File | Proper key management practices |
| **Personal Utilities** | Auto-Generated | Convenience prioritized |

### Security Analysis Summary

**Auto-Generated Approach:**
- ✅ Perfect for automation and simplicity
- ❌ Single point of failure - password embedded in script
- ⚠️ Vulnerable to determined attackers with static analysis

**Custom Password Approach:**
- ✅ Interactive security barrier with no stored credentials
- ✅ Human-controlled authentication factor
- ❌ Cannot run unattended, blocks automation

**Environment File Approach:**
- ✅ Proper cryptographic key separation
- ✅ Enterprise-grade security practices
- ✅ Automation-friendly with credential management
- ⚠️ Slightly more complex deployment

**Recommendation:** Use Environment File approach for production systems requiring high security, Auto-Generated for development convenience, and Custom Password for administrative tools requiring human verification.

### 🔑 pwg.sh - Password Generator
**Purpose**: Generate cryptographically secure random passwords with customizable character sets.

**Features**:
- Uses `/dev/urandom` for true randomness
- Configurable character types (lowercase, uppercase, numbers, symbols)
- Custom symbols characters
- Proportional character distribution
- Flexible password length

**Usage**:
```bash
# Show help
./pwg.sh -h
---------------------------------
 PWG - Random Password Generator
        Version: 202504.04
       Author: Juno Roesler
---------------------------------
 Usage: pwg [-h | -S] | ([-a] [-l] [-m <symbols>] [-n] [-s] [-u] [-w]) <length>
   Each option can be repeated to increase the occurrence of its character type.
   When no option is provided, the default is: '-l -n -s -u'
 Options:
   -a: Use lowercase letters, uppercase letters, and numbers.
   -h: Print this help text.
   -l: Use lower case letters in password.
   -m <symbols>: Use a custom set of symbols instead of the default.
   -n: Use numbers in password.
   -s: Use symbols in password.
   -S: Show default symbols character set.
   -u: Use upper case letters in password.
   -w: Use lowercase and uppercase letters only.

# Generate 12-character password (default: letters + numbers + symbols)
./pwg.sh 12             # Output: 3+pJ9.sP7{eE

# Letters and numbers only
./pwg.sh -l -u -n 16    # Output: F2bE0pL2rM1bN4kL

# Numbers only (PIN)
./pwg.sh -n 6           # Output: 258934

# High symbol density
./pwg.sh -a -s -s 20    # Output: 2%%hH4/!pQ5!:tK5..qA

# Custom symbols characters
./pwg.sh -m '@#$' 12    # Output: 4$cM0@pQ5#qY

# Show default symbols
./pwg.sh -S
Default Symbols Character Set:
 ! @ # $ % & * ( ) - = + [ ] { } | < > . , ; : / ?
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

- **cipher.sh**: v202410.05
- **hide.sh**: v202411.08
- **pwg.sh**: v202504.04

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

**Juno Roesler \<<juno.rr@gmail.com>\>**

## License

These tools are provided as-is for educational and practical use. Please ensure compliance with your organization's security policies when using encryption tools.
