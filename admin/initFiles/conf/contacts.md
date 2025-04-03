# Contacts JSON Explanation

This JSON represents an array containing a single object. This object holds contact information for a person.

## Object Structure

The object has the following key-value pairs:

- **name**: A string representing the full name of the contact (e.g., "Full name").
- **email**: An array of strings, where each string is an email address for the contact (e.g., \["email@example.com"]).
- **phones**: An array of strings, where each string is a phone number for the contact (e.g., \["+55 99 99999-9999"]).

## Example

```json
[
  {
    "name": "Full name",
    "email": [
      "email@example.com"
    ],
    "phones": [
      "+55 99 99999-9999"
    ]
  }
]