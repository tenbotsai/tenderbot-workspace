#!/bin/bash
set -e

echo "Setting up TenderBot workspace..."

# Clone repos if they don't exist
if [ ! -d "backend" ]; then
    echo "Cloning backend..."
    git clone git@github.com:tenbotsai/backend.git
else
    echo "✓ backend already exists"
fi

if [ ! -d "signup" ]; then
    echo "Cloning signup..."
    git clone git@github.com:tenbotsai/signup.git
else
    echo "✓ signup already exists"
fi

if [ ! -d "remix-of-tenderbot-prototype" ]; then
    echo "Cloning remix-of-tenderbot-prototype..."
    git clone git@github.com:tenbotsai/remix-of-tenderbot-prototype.git
else
    echo "✓ remix-of-tenderbot-prototype already exists"
fi

echo ""
echo "✓ Repositories ready"
echo ""
echo "Next steps:"
echo "  - cd backend && pip install -r requirements.txt"
echo "  - cd signup && npm install"
