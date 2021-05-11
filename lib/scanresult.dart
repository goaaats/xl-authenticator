class ScanResult {
  late ScanResultType type;
  late String data;

  ScanResult(this.type, this.data);
  ScanResult.uri(this.data) : type = ScanResultType.Uri;
  ScanResult.raw(this.data) : type = ScanResultType.Raw;
}

enum ScanResultType {
  Uri,
  Raw
}