# Pluto Errors

This is an enum definition named `PlutoError` that conforms to the `KnownPrismError` protocol. The enum has several cases, and each case represents an error scenario with a message that describes the reason for the error.

### Error 1: Missing Data Persistence

This error occurs when the data persistence for a specific type is missing. The reason for this error could be due to the following possible reasons:

- A required data is not persisted.

The recovery solutions for this error are:

- Verify that all requirements are correctly persisted before executing this task.

### Error 2: Missing Required Fields

This error occurs when a specific type is missing required fields. The reason for this error could be due to the following possible reasons:

- The required fields are not set.
- The required fields are not valid.

The recovery solutions for this error are:

- Verify if the required fields are set.
- Check if the required fields are valid.

### Error 3: Duplication

This error occurs when trying to save a record that already exists. The reason for this error could be due to the following possible reasons:

- The record is already saved.
- The record has already been created.

The recovery solutions for this error are:

- Verify if the record is already saved.
- Check if the record has already been created.

### Error 4: Unknown Credential Type

This error occurs when the credential type is unknown. The reason for this error could be due to the following possible reasons:

- The credential type is not recognized, it should be W3C or JWT.

The recovery solutions for this error are:

- Check if the credential type is valid.

### Error 5: Invalid Credential JSON

This error occurs when the credential JSON is invalid. The reason for this error could be due to the following possible reasons:

- The credential JSON is not formatted correctly.
- The credential JSON is not valid.

The recovery solutions for this error are:

- Verify if the credential JSON is formatted correctly.
- Check if the credential JSON is valid.
