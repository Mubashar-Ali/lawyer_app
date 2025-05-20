class FormValidators {
  /// Validates an email address
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }
  
  /// Validates a password
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    
    return null;
  }
  
  /// Validates a required field
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    
    return null;
  }
  
  /// Validates a phone number
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Phone might be optional
    }
    
    final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');
    if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'[\s\-$$$$]'), ''))) {
      return 'Please enter a valid phone number';
    }
    
    return null;
  }
  
  /// Validates a case number (alphanumeric with optional hyphens)
  static String? validateCaseNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Case number is required';
    }
    
    final caseNumberRegex = RegExp(r'^[a-zA-Z0-9\-]+$');
    if (!caseNumberRegex.hasMatch(value)) {
      return 'Case number can only contain letters, numbers, and hyphens';
    }
    
    return null;
  }
}
