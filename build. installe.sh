#!/bin/bash

echo "🚀 در حال ساخت فایل اجرایی نصب‌کننده GameHub Vault..."

# بررسی نصب بودن pkg
if ! command -v pkg &> /dev/null
then
    echo "❌ ابزار pkg نصب نیست. لطفاً با دستور زیر نصب کنید:"
    echo "npm install -g pkg"
    exit 1
fi

# ساخت فایل اجرایی برای ویندوز، لینوکس و مک
pkg installer.js --targets node18-win-x64,node18-linux-x64,node18-macos-x64 --output gamehub-installer

echo "✅ فایل‌های اجرایی ساخته شدند:"
echo "🖥️ gamehub-installer.exe (ویندوز)"
echo "🐧 gamehub-installer-linux (لینوکس)"
echo "🍎 gamehub-installer-macos (مک)"