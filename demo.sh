#!/bin/bash

echo "=========================================="
echo "  Bash Security & Utility Tools Demo"
echo "=========================================="
echo ""

# Function to create a test file for demos
create_test_file() {
    echo "#!/bin/bash" > test_script.sh
    echo "echo 'This is a test script'" >> test_script.sh
    echo "echo 'Hello from the encrypted world!'" >> test_script.sh
    chmod +x test_script.sh
}

# Function to clean up test files
cleanup() {
    rm -f test_script.sh encrypted.txt obfuscated.sh *.pem 2>/dev/null
    echo "Cleanup completed."
}

echo "🔑 PWG.sh - Password Generator Demo"
echo "-----------------------------------"
echo "Generating a 12-character password:"
./pwg.sh 12
echo ""
echo "Generating a letters and numbers only password (16 chars):"
./pwg.sh -l -u -n 16
echo ""
echo "Generating a PIN (6 digits):"
./pwg.sh -n 6
echo ""

echo "📏 Size.sh - File Size Converter Demo"
echo "------------------------------------"
echo "Converting 1536 bytes to human readable:"
./size.sh 1536
echo ""
echo "Converting 2.5M back to bytes:"
./size.sh 2.5M
echo ""
echo "Size of README.md file:"
./size.sh README.md
echo ""

echo "📝 Spad.sh - Text Padding Demo"
echo "------------------------------"
echo "Sourcing spad.sh to use padding functions:"
source ./spad.sh
echo "Center aligned text (width 50):"
padCenter 50 '-' "CENTERED TEXT"
echo ""
echo "Right aligned text (width 30):"
padLeft 30 ' ' "Right Aligned"
echo ""
echo "Left aligned text (width 30):"
padRight 30 '.' "Left Aligned"
echo ""

echo "🫥 Hide.sh - Script Obfuscation Demo"
echo "-----------------------------------"
create_test_file
echo "Original test script:"
cat test_script.sh
echo ""
echo "Obfuscating script (1 iteration):"
./hide.sh test_script.sh > obfuscated.sh
echo "Obfuscated script size: $(wc -c < obfuscated.sh) bytes"
echo ""
echo "Getting obfuscation info:"
./hide.sh -i obfuscated.sh
echo ""
echo "Testing obfuscated script execution:"
chmod +x obfuscated.sh
./obfuscated.sh
echo ""

echo "🔐 Cipher.sh - Encryption Demo"
echo "-----------------------------"
echo "Creating a test message file:"
echo "This is a secret message that needs encryption!" > secret.txt
echo ""
echo "Encrypting with password 'testpass123':"
./cipher.sh -e -p "testpass123" secret.txt > encrypted.txt
echo "Encrypted file size: $(wc -c < encrypted.txt) bytes"
echo ""
echo "Decrypting the message:"
./cipher.sh -d -p "testpass123" encrypted.txt
echo ""

echo "🧹 Cleaning up demo files..."
cleanup
rm -f secret.txt encrypted.txt 2>/dev/null

echo ""
echo "=========================================="
echo "        Demo completed successfully!"
echo "=========================================="
echo ""
echo "Available tools:"
echo "  • ./cipher.sh -h    - Encryption/Decryption help"
echo "  • ./hide.sh -h      - Script obfuscation help"
echo "  • ./pwg.sh -h       - Password generator help"
echo "  • ./size.sh 1024    - Convert file sizes"
echo "  • source ./spad.sh  - Load text padding functions"
echo ""
echo "For detailed usage, check the README.md file."