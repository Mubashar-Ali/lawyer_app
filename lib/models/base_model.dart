abstract class BaseModel {
  /// Validates the model data
  /// Returns a map of field names to error messages
  /// Empty map means the model is valid
  Map<String, String> validate();
  
  /// Converts the model to a JSON map
  Map<String, dynamic> toJson();
}
