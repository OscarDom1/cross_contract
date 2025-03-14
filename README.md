## Starknet School Library System 
## Overview
The Starknet School Library System is a smart contract-based application built on Cairo for Starknet, designed to manage book records in a decentralized way. It allows:

Adding books to a library with validation checks.
Borrowing books by students while ensuring availability.
Tracking borrowed books in a student record system.
This system demonstrates secure, verifiable, and decentralized book lending on Starknet.

## Features
## 📖 Library Management
Add books with details (ID, title, author, year, edition).
Prevent duplicate book entries.
Validate book details before adding.

## 🎓 Student Borrowing System
Students can borrow books from the library.
Ensures a book is available before borrowing.
Stores student-book borrowing records.
## 🔗 Smart Contract Architecture
Modular structure with separate contracts for Library and Student Records.
Uses Starknet storage maps for efficient book tracking.
Event emission for transparency and auditability.
