# EduVerify - Academic Credential Verification System

A decentralized academic credential verification system built on Stacks blockchain, providing tamper-proof degree authentication and institutional record management.

## Overview

EduVerify enables educational institutions to issue verifiable digital credentials while allowing authorized verifiers to authenticate academic achievements in a transparent and immutable manner.

## Features

- Digital credential issuance by educational institutions
- Authorized verifier registration and management
- Immutable academic record storage
- Field of study and graduation year tracking
- Student identifier privacy protection

## Smart Contract Functions

### Public Functions
- `register-academic-verifier`: Register authorized credential verifiers
- `issue-academic-credential`: Issue new academic credentials
- `verify-academic-credential`: Verify credentials by authorized verifiers

### Read-Only Functions
- `get-academic-credential`: Retrieve credential information
- `get-institution-records`: Get institution's credential records
- `is-academic-verifier`: Check verifier authorization status

## Usage

Deploy the contract with a registry administrator account. Register academic verifiers, then institutions can issue credentials which can be verified by authorized parties.

## Security

- Administrative access control for verifier registration
- Comprehensive input validation and sanitization
- Principal validation to prevent system exploitation
- Record capacity limits for resource management